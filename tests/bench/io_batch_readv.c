/**
 * io_batch_readv.c — I/O 基线：4 段 readv 顺序读满 16MiB（C -O2 对照）
 * 输入 tests/bench/.io_mmap_bench_tmp（默认 16MiB）。
 */
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/uio.h>
#include <unistd.h>

enum { SEG = 4096, ROUNDS = 1024 };

int main(void) {
  const char *path = "tests/bench/.io_mmap_bench_tmp";
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    perror("open");
    return 1;
  }
  uint8_t b0[SEG];
  uint8_t b1[SEG];
  uint8_t b2[SEG];
  uint8_t b3[SEG];
  struct iovec iov[4];
  int32_t sum = 0;
  for (int r = 0; r < ROUNDS; r++) {
    iov[0].iov_base = b0;
    iov[0].iov_len = SEG;
    iov[1].iov_base = b1;
    iov[1].iov_len = SEG;
    iov[2].iov_base = b2;
    iov[2].iov_len = SEG;
    iov[3].iov_base = b3;
    iov[3].iov_len = SEG;
    ssize_t nr = readv(fd, iov, 4);
    if (nr != (ssize_t)(SEG * 4)) {
      perror("readv");
      close(fd);
      return 2;
    }
    for (int i = 0; i < SEG; i++) {
      sum += (int32_t)b0[i];
      sum += (int32_t)b1[i];
      sum += (int32_t)b2[i];
      sum += (int32_t)b3[i];
    }
  }
  if (close(fd) != 0) {
    perror("close");
    return 3;
  }
  return sum & 255;
}
