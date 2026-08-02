/**
 * zero_copy_sendfile_sink.c — Z1 基线 sink：接受单连接并 drain 至 EOF（供 sendfile client 驱动）
 * 用法：zero_copy_sendfile_sink [port]  默认 38459
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

enum { SINK_PORT_DEFAULT = 38459, DRAIN_BUF = 65536 };

/** 单连接 recv 直至对端 close；返回接收总字节数（低 32 位供 client 校验）。 */
static uint32_t drain_connection(int fd) {
  uint8_t buf[DRAIN_BUF];
  uint64_t total = 0;
  for (;;) {
    ssize_t nr = recv(fd, buf, sizeof(buf), 0);
    if (nr <= 0)
      break;
    total += (uint64_t)nr;
  }
  (void)close(fd);
  return (uint32_t)(total & 0xffffffffu);
}

int main(int argc, char **argv) {
  int listener;
  int client;
  uint16_t port = (uint16_t)SINK_PORT_DEFAULT;
  struct sockaddr_in sin;
  socklen_t peer_len = sizeof(sin);
  int opt = 1;
  uint32_t got;
  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  listener = socket(AF_INET, SOCK_STREAM, 0);
  if (listener < 0) {
    perror("socket");
    return 1;
  }
  (void)setsockopt(listener, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt));
  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
  if (bind(listener, (struct sockaddr *)&sin, sizeof(sin)) != 0) {
    perror("bind");
    (void)close(listener);
    return 1;
  }
  if (listen(listener, 4) != 0) {
    perror("listen");
    (void)close(listener);
    return 1;
  }
  client = accept(listener, (struct sockaddr *)&sin, &peer_len);
  if (client < 0) {
    perror("accept");
    (void)close(listener);
    return 2;
  }
  (void)close(listener);
  got = drain_connection(client);
  return (int)(got & 255u);
}
