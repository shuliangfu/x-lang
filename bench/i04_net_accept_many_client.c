/**
 * net_accept_many_client.c — L0 基线 client：向 127.0.0.1 快速建连 N 次（供 run-perf-net.sh 驱动 server）
 * 用法：net_accept_many_client [port] [n_conns]  默认 38456 / 4096
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

enum { NET_BENCH_PORT_DEFAULT = 38456, NET_BENCH_CONNS_DEFAULT = 4096 };

/** 单次 TCP connect；成功返回 fd，失败 -1。 */
static int bench_connect_once(uint16_t port) {
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  struct sockaddr_in sin;
  if (fd < 0)
    return -1;
  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(0x7f000001u); /* 127.0.0.1 */
  if (connect(fd, (struct sockaddr *)&sin, sizeof(sin)) != 0) {
    close(fd);
    return -1;
  }
  {
    /* 快速 close，减轻 TIME_WAIT 堆积（macOS 上连续 4096 建连 bench）。 */
    struct linger ling;
    ling.l_onoff = 1;
    ling.l_linger = 0;
    (void)setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));
  }
  return fd;
}

int main(int argc, char **argv) {
  uint16_t port = (uint16_t)NET_BENCH_PORT_DEFAULT;
  int n_conns = NET_BENCH_CONNS_DEFAULT;
  int i;
  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  if (argc >= 3)
    n_conns = atoi(argv[2]);
  if (n_conns <= 0) {
    fprintf(stderr, "net_accept_many_client: invalid n_conns\n");
    return 1;
  }
  for (i = 0; i < n_conns; i++) {
    int fd = bench_connect_once(port);
    if (fd < 0) {
      perror("connect");
      return 2;
    }
    (void)close(fd);
  }
  return 0;
}
