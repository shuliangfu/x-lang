#!/usr/bin/env node
/**
 * 最小 Engine.IO polling 握手 mock（无 socket.io npm）。
 * 用法：node tests/socketio/mock_eio_polling_server.js [port]
 * 响应 GET /socket.io/?EIO=4&transport=polling（无 sid）→ open 包。
 */
'use strict';

const http = require('http');

const port = Number(process.argv[2] || 13001);
const openBody =
  '0{"sid":"live1","upgrades":["websocket"],"pingInterval":25000,"pingTimeout":20000}';

const server = http.createServer((req, res) => {
  const url = req.url || '';
  if (
    req.method === 'GET' &&
    url.includes('EIO=4') &&
    url.includes('transport=polling') &&
    !url.includes('sid=')
  ) {
    res.writeHead(200, {
      'Content-Type': 'text/plain; charset=UTF-8',
      Connection: 'keep-alive',
    });
    res.end(openBody);
    return;
  }
  res.writeHead(404);
  res.end('not found');
});

server.listen(port, '127.0.0.1', () => {
  process.stdout.write(`mock_eio_polling_server listening on ${port}\n`);
});
