/**
 * net_mixed_conns_requests_server.c — PERF-003 混合 bench server
 *
 * 单线程 accept 循环：每连接处理 MIXED_ROUNDS 轮 MIXED_PAYLOAD 字节 echo 后关闭。
 * 用法：net_mixed_conns_requests_server [port]  默认 38459
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

enum {
  MIXED_PORT_DEFAULT = 38459,
  MIXED_CONNS = 256,
  MIXED_ROUNDS = 16,
  MIXED_PAYLOAD = 512
};

/** 单连接：固定长度 echo 往返 MIXED_ROUNDS 次。 */
static void mixed_session(int fd) {
  uint8_t buf[MIXED_PAYLOAD];
  int round;
  for (round = 0; round < MIXED_ROUNDS; round++) {
    ssize_t nr = 0;
    ssize_t got = 0;
    while (got < (ssize_t)MIXED_PAYLOAD) {
      nr = read(fd, buf + got, (size_t)(MIXED_PAYLOAD - got));
      if (nr <= 0)
        goto done;
      got += nr;
    }
    got = 0;
    while (got < (ssize_t)MIXED_PAYLOAD) {
      nr = write(fd, buf + got, (size_t)(MIXED_PAYLOAD - got));
      if (nr <= 0)
        goto done;
      got += nr;
    }
  }
done:
  (void)close(fd);
}

int main(int argc, char **argv) {
  int listener;
  int client;
  uint16_t port = (uint16_t)MIXED_PORT_DEFAULT;
  struct sockaddr_in sin;
  socklen_t peer_len = sizeof(sin);
  int opt = 1;
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
  if (listen(listener, 16) != 0) {
    perror("listen");
    (void)close(listener);
    return 1;
  }
  {
    int ci;
    for (ci = 0; ci < MIXED_CONNS; ci++) {
      client = accept(listener, (struct sockaddr *)&sin, &peer_len);
      if (client < 0) {
        perror("accept");
        (void)close(listener);
        return 2;
      }
      mixed_session(client);
    }
  }
  (void)close(listener);
  return 0;
}
