/**
 * net_echo_throughput.c — N2 基线 client：readv/writev 4×4KiB×1024 轮 echo（C -O2 对照）
 * 用法：net_echo_throughput [port]  默认 38457
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

enum { ECHO_PORT_DEFAULT = 38457, ECHO_SEG = 4096, ECHO_ROUNDS = 1024 };

int main(int argc, char **argv) {
  uint16_t port = (uint16_t)ECHO_PORT_DEFAULT;
  int fd;
  struct sockaddr_in sin;
  uint8_t b0[ECHO_SEG];
  uint8_t b1[ECHO_SEG];
  uint8_t b2[ECHO_SEG];
  uint8_t b3[ECHO_SEG];
  struct iovec iov[4];
  int32_t sum = 0;
  int round;
  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  fd = socket(AF_INET, SOCK_STREAM, 0);
  if (fd < 0) {
    perror("socket");
    return 1;
  }
  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(0x7f000001u);
  if (connect(fd, (struct sockaddr *)&sin, sizeof(sin)) != 0) {
    perror("connect");
    (void)close(fd);
    return 1;
  }
  iov[0].iov_base = b0;
  iov[0].iov_len = ECHO_SEG;
  iov[1].iov_base = b1;
  iov[1].iov_len = ECHO_SEG;
  iov[2].iov_base = b2;
  iov[2].iov_len = ECHO_SEG;
  iov[3].iov_base = b3;
  iov[3].iov_len = ECHO_SEG;
  for (round = 0; round < ECHO_ROUNDS; round++) {
    int bi;
    for (bi = 0; bi < ECHO_SEG; bi++) {
      b0[bi] = (uint8_t)((round + bi) & 255);
      b1[bi] = (uint8_t)((round + bi + 1) & 255);
      b2[bi] = (uint8_t)((round + bi + 2) & 255);
      b3[bi] = (uint8_t)((round + bi + 3) & 255);
    }
    if (writev(fd, iov, 4) != (ssize_t)(ECHO_SEG * 4)) {
      perror("writev");
      (void)close(fd);
      return 2;
    }
    if (readv(fd, iov, 4) != (ssize_t)(ECHO_SEG * 4)) {
      perror("readv");
      (void)close(fd);
      return 3;
    }
    for (bi = 0; bi < ECHO_SEG; bi++) {
      sum += (int32_t)b0[bi];
      sum += (int32_t)b1[bi];
      sum += (int32_t)b2[bi];
      sum += (int32_t)b3[bi];
    }
  }
  if (close(fd) != 0) {
    perror("close");
    return 4;
  }
  return sum & 255;
}
