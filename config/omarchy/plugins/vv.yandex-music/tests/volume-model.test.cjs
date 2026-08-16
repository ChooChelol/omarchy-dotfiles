const test = require('node:test');
const assert = require('node:assert/strict');
const Model = require('../MediaModel.js');

function stream(binary, volume = 1) {
  return {
    ready: true,
    isStream: true,
    isSink: true,
    properties: {
      'application.process.binary': binary,
      'application.name': binary === 'yandexmusic' ? 'Chromium' : 'Chromium'
    },
    audio: { volume, muted: false }
  };
}

test('selects only dedicated Yandex Music PipeWire stream', () => {
  const chromium = stream('chromium');
  const yandex = stream('yandexmusic', 0.72);

  assert.equal(Model.isYandexPlaybackStream(chromium), false);
  assert.equal(Model.isYandexPlaybackStream(yandex), true);
  assert.equal(Model.findYandexPlaybackStream([chromium, yandex]), yandex);
});

test('accepts installed Yandex binary spelling variants', () => {
  assert.equal(Model.isYandexPlaybackStream(stream('/usr/bin/yandex-music')), true);
  assert.equal(Model.isYandexPlaybackStream(stream('/opt/yandex/yandexmusic')), true);
});

test('clamps plugin volume to PipeWire slider range', () => {
  assert.equal(Model.clampVolume(-1), 0);
  assert.equal(Model.clampVolume(0.65), 0.65);
  assert.equal(Model.clampVolume(2), 1.5);
  assert.equal(Model.clampVolume(Number.NaN), 0);
});
