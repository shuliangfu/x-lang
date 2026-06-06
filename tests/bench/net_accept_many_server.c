/**
 * net_accept_many_server.c — L0 基线 server：循环 accept（C -O2 对照，无 accept_many/io_uring）
 * 用法：net_accept_many_server [n_conns] [port]  默认 4096 / 38456
 */
#include <arpa/inet.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

enum { NET_BENCH_PORT_DEFAULT = 38456, NET_BENCH_CONNS_DEFAULT = 4096 };

/** accept 后立即 close；SO_LINGER=0 减轻连续 bench 的 TIME_WAIT 堆积。 */
static void bench_close_accepted(int fd) {
  struct linger ling;
  ling.l_onoff = 1;
  ling.l_linger = 0;
  (void)setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));
  (void)close(fd);
}

int main(int argc, char **argv) {
  int listener;
  int total = 0;
  int target = NET_BENCH_CONNS_DEFAULT;
  uint16_t port = (uint16_t)NET_BENCH_PORT_DEFAULT;
  struct sockaddr_in sin;
  int opt = 1;
  if (argc >= 2)
    target = atoi(argv[1]);
  if (target <= 0)
    target = NET_BENCH_CONNS_DEFAULT;
  if (argc >= 3)
    port = (uint16_t)atoi(argv[2]);
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
    close(listener);
    return 1;
  }
  if (listen(listener, 256) != 0) {
    perror("listen");
    close(listener);
    return 1;
  }
  while (total < target) {
    int fd = accept(listener, NULL, NULL);
    if (fd < 0) {
      perror("accept");
      close(listener);
      return 2;
    }
    bench_close_accepted(fd);
    total++;
  }
  if (close(listener) != 0) {
    perror("close listener");
    return 3;
  }
  return 0;
}
