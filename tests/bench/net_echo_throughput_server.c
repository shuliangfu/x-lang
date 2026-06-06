/**
 * net_echo_throughput_server.c — N2 echo server：readv 4×4KiB 后立即 writev 回显（供 client bench 驱动）
 * 用法：net_echo_throughput_server [port]  默认 38457
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/uio.h>
#include <unistd.h>

enum { ECHO_BENCH_PORT = 38457, ECHO_SEG = 4096 };

/** 单连接 echo：4 段 readv 后原样 writev。 */
static void echo_session(int fd) {
  uint8_t b0[ECHO_SEG];
  uint8_t b1[ECHO_SEG];
  uint8_t b2[ECHO_SEG];
  uint8_t b3[ECHO_SEG];
  struct iovec iov[4];
  for (;;) {
    iov[0].iov_base = b0;
    iov[0].iov_len = ECHO_SEG;
    iov[1].iov_base = b1;
    iov[1].iov_len = ECHO_SEG;
    iov[2].iov_base = b2;
    iov[2].iov_len = ECHO_SEG;
    iov[3].iov_base = b3;
    iov[3].iov_len = ECHO_SEG;
    ssize_t nr = readv(fd, iov, 4);
    if (nr <= 0)
      break;
    if (writev(fd, iov, 4) != nr)
      break;
  }
  (void)close(fd);
}

int main(int argc, char **argv) {
  int listener;
  int client;
  uint16_t port = (uint16_t)ECHO_BENCH_PORT;
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
  if (listen(listener, 8) != 0) {
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
  echo_session(client);
  return 0;
}
