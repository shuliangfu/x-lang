/**
 * zero_copy_sendfile.c — Z1 基线 client：sendfile 文件→socket（C -O2 对照）
 * 用法：zero_copy_sendfile [port]  默认 38459
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

#if defined(__linux__)
#include <sys/sendfile.h>
#elif defined(__APPLE__)
#include <sys/types.h>
#endif

enum { SINK_PORT_DEFAULT = 38459, BENCH_BYTES = 16777216, CHUNK = 1048576 };

/** 单次 sendfile；成功返回发送字节数，失败 -1。 */
static ssize_t bench_sendfile_once(int out_fd, int in_fd, size_t count) {
#if defined(__linux__)
  return sendfile(out_fd, in_fd, NULL, count);
#elif defined(__APPLE__)
  off_t len = (off_t)count;
  if (sendfile(in_fd, out_fd, 0, &len, NULL, 0) < 0)
    return -1;
  return (ssize_t)len;
#else
  (void)out_fd;
  (void)in_fd;
  (void)count;
  return -1;
#endif
}

int main(int argc, char **argv) {
  const char *path = "tests/bench/.io_mmap_bench_tmp";
  uint16_t port = (uint16_t)SINK_PORT_DEFAULT;
  int file_fd;
  int sock;
  struct sockaddr_in sin;
  size_t sent = 0;
  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  file_fd = open(path, O_RDONLY);
  if (file_fd < 0) {
    perror("open");
    return 1;
  }
  sock = socket(AF_INET, SOCK_STREAM, 0);
  if (sock < 0) {
    perror("socket");
    (void)close(file_fd);
    return 1;
  }
  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(0x7f000001u);
  if (connect(sock, (struct sockaddr *)&sin, sizeof(sin)) != 0) {
    perror("connect");
    (void)close(sock);
    (void)close(file_fd);
    return 2;
  }
  while (sent < (size_t)BENCH_BYTES) {
    size_t left = (size_t)BENCH_BYTES - sent;
    size_t ask = CHUNK;
    ssize_t n;
    if (left < ask)
      ask = left;
    n = bench_sendfile_once(sock, file_fd, ask);
    if (n <= 0) {
      perror("sendfile");
      (void)close(sock);
      (void)close(file_fd);
      return 3;
    }
    sent += (size_t)n;
  }
  if (close(sock) != 0) {
    perror("close sock");
    (void)close(file_fd);
    return 4;
  }
  if (close(file_fd) != 0) {
    perror("close file");
    return 5;
  }
  return (int)(sent & 255u);
}
