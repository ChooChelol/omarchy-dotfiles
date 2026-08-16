const targets = await (await fetch('http://127.0.0.1:9223/json/list')).json();
const page = targets.find(t => t.type === 'page' && t.url === 'music-application://desktop/');
if (!page) throw new Error('Yandex Music desktop page not found');

const ws = new WebSocket(page.webSocketDebuggerUrl);
await new Promise((resolve, reject) => {
  ws.onopen = resolve;
  ws.onerror = reject;
});

let serial = 1;
function call(method, params = {}) {
  const id = serial++;
  return new Promise((resolve, reject) => {
    const handler = event => {
      const message = JSON.parse(event.data);
      if (message.id !== id) return;
      ws.removeEventListener('message', handler);
      if (message.error) reject(new Error(JSON.stringify(message.error)));
      else resolve(message.result);
    };
    ws.addEventListener('message', handler);
    ws.send(JSON.stringify({ id, method, params }));
  });
}

let clicked = false;
for (let attempt = 0; attempt < 150 && !clicked; attempt++) {
  const result = await call('Runtime.evaluate', {
    expression: `(() => {
      const buttons = [...document.querySelectorAll('button')];
      const direct = buttons.find(b => String(b.className).includes('VibePlayerControls_playButton'));
      const fallback = buttons.filter(b => {
        const aria = (b.getAttribute('aria-label') || '').toLowerCase();
        const r = b.getBoundingClientRect();
        return (aria === 'playback' || aria === 'pause' || aria === 'play')
          && r.width > 0 && r.height > 0 && r.y > innerHeight * 0.65;
      }).at(-1);
      const button = direct || fallback;
      if (!button) return false;
      button.click();
      return true;
    })()`,
    returnByValue: true
  });
  clicked = result.result.value === true;
  if (!clicked) await new Promise(resolve => setTimeout(resolve, 100));
}

if (!clicked) throw new Error('Yandex Music playback button not found after 15s');

ws.close();
