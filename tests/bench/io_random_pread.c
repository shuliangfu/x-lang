/**
 * io_random_pread.c — I/O 基线：随机 offset pread（C -O2 对照，PERF-002）
 * 路径须与 run-perf-io.sh 生成的 tests/bench/.io_mmap_bench_tmp 一致。
 */
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

enum { CHUNK = 4096, PAGES = 4096, ROUNDS = 1024 };

int main(void) {
  const char *path = "tests/bench/.io_mmap_bench_tmp";
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    perror("open");
    return 1;
  }
  uint8_t buf[CHUNK];
  int32_t sum = 0;
  uint32_t seed = 12345u;
  for (int r = 0; r < ROUNDS; r++) {
    seed = seed * 1103515245u + 12345u;
    uint32_t page = seed % PAGES;
    off_t off = (off_t)page * CHUNK;
    ssize_t nr = pread(fd, buf, CHUNK, off);
    if (nr != CHUNK) {
      perror("pread");
      close(fd);
      return 2;
    }
    for (int bi = 0; bi < CHUNK; bi++) {
      sum += (int32_t)buf[bi];
    }
  }
  if (close(fd) != 0) {
    perror("close");
    return 3;
  }
  return sum & 255;
}
