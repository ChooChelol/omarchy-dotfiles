#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

for file in config/hypr/*.lua; do
  luac -p "$file"
done
jq -e . config/omarchy/shell.json >/dev/null
jq -e . config/omarchy/plugins/vv.yandex-music/manifest.json >/dev/null
bash -n scripts/restore.sh
bash -n scripts/update-snapshot.sh
bash -n config/omarchy/plugins/vv.yandex-music/scripts/start-hidden.sh
bash -n config/omarchy/plugins/vv.yandex-music/scripts/play-pause.sh
node --check config/omarchy/plugins/vv.yandex-music/scripts/play-pause.mjs
node --test config/omarchy/plugins/vv.yandex-music/tests/volume-model.test.cjs

if command -v shellcheck >/dev/null; then
  shellcheck scripts/restore.sh scripts/update-snapshot.sh \
    config/omarchy/plugins/vv.yandex-music/scripts/start-hidden.sh \
    config/omarchy/plugins/vv.yandex-music/scripts/play-pause.sh
fi

if command -v omarchy >/dev/null; then
  omarchy plugin validate config/omarchy/plugins/vv.yandex-music >/dev/null
fi

python3 - "$ROOT" <<'PY'
from pathlib import Path
import re, struct, sys
root = Path(sys.argv[1])
patterns = {
    "private key": re.compile(rb"-----BEGIN [A-Z ]*PRIVATE KEY-----"),
    "GitHub token": re.compile(rb"(?:gh[opurs]_[A-Za-z0-9_]{20,}|github_pat_[A-Za-z0-9_]{20,})"),
    "OpenAI-style key": re.compile(rb"\bsk-[A-Za-z0-9_-]{20,}"),
    "AWS access key": re.compile(rb"\bAKIA[0-9A-Z]{16}\b"),
    "Slack token": re.compile(rb"\bxox[baprs]-[A-Za-z0-9-]{10,}"),
    "Authorization bearer": re.compile(rb"(?i)authorization\s*[:=]\s*bearer\s+[A-Za-z0-9._~-]{12,}"),
    "hard-coded old home": re.compile(rb"/home/" + b"v" + b"v" + rb"(?:/|\b)"),
}
errors=[]
for p in root.rglob('*'):
    if not p.is_file() or '.git' in p.parts:
        continue
    data=p.read_bytes()
    for label, rx in patterns.items():
        if rx.search(data): errors.append(f"{p.relative_to(root)}: {label}")

png=root/'config/omarchy/themes/comfyui-temp-uavpr-00022/backgrounds/ComfyUI_temp_uavpr_00022_.png'
data=png.read_bytes(); pos=8; metadata=[]
while pos+12 <= len(data):
    n=struct.unpack('>I', data[pos:pos+4])[0]
    kind=data[pos+4:pos+8]
    if kind in {b'tEXt', b'zTXt', b'iTXt', b'eXIf'}: metadata.append(kind.decode())
    pos += 12+n
if metadata: errors.append(f"{png.relative_to(root)}: metadata chunks {metadata}")

if errors:
    print("Public safety check failed:", file=sys.stderr)
    print("\n".join(f"- {x}" for x in errors), file=sys.stderr)
    raise SystemExit(1)
print("secret/path/PNG-metadata scan: clean")
PY

printf 'all checks passed\n'
