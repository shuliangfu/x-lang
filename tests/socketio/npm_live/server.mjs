/**
 * socket.io v4 最小服务（npm live gate：polling + WS + /chat echo）。
 * 用法：PORT=13002 node tests/socketio/npm_live/server.mjs
 */
import http from 'node:http';
import { Server } from 'socket.io';

const port = Number(process.env.PORT || 13002);
const httpServer = http.createServer();
const io = new Server(httpServer, {
  cors: { origin: '*' },
  transports: ['polling', 'websocket'],
});

/** 默认 namespace `/` */
io.on('connection', () => {
  /* polling 握手后客户端可 POST CONNECT */
});

/** npm plugin live：插件注册 + plugin_ping/pong */
function registerChatPlugins(io) {
  io.of('/chat').use((socket, next) => {
    socket.data.authed = false;
    socket.data.plugin_ok = false;
    next();
  });
}
registerChatPlugins(io);

/** /chat namespace：npm WS live 回 pong；npm room live 广播 room_pong；npm mw live auth 中间件 */
const chat = io.of('/chat');
chat.on('connection', (socket) => {
  socket.data.plugin_ok = true;
  socket.join('lobby');
  socket.on('ping', () => {
    socket.emit('pong', 'ok');
  });
  socket.on('room_ping', () => {
    chat.to('lobby').emit('room_pong', 'ok');
  });
  socket.on('auth', (tok) => {
    if (tok === 'shux') {
      socket.data.authed = true;
      socket.emit('auth_ok', '1');
    }
  });
  socket.on('mw_ping', () => {
    if (socket.data.authed) {
      socket.emit('mw_pong', 'ok');
    }
  });
  socket.on('plugin_ping', () => {
    if (socket.data.plugin_ok) {
      socket.emit('plugin_pong', 'ok');
    }
  });
});

httpServer.listen(port, '127.0.0.1', () => {
  process.stdout.write(`socket.io npm live server on ${port}\n`);
});
