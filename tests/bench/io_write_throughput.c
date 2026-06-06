/**
 * io_write_throughput.c — I/O 基线：大文件顺序 write（C -O2 对照）
 * 输出 tests/bench/.io_write_bench_tmp（默认 16MiB）。
 */
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <unistd.h>

enum { CHUNK = 4096, NUM_CHUNKS = 4096 };

int main(void) {
  const char *path = "tests/bench/.io_write_bench_tmp";
  int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (fd < 0) {
    perror("open");
    return 1;
  }
  uint8_t buf[CHUNK];
  int32_t sum = 0;
  for (int ci = 0; ci < NUM_CHUNKS; ci++) {
    for (int bi = 0; bi < CHUNK; bi++) {
      uint8_t b = (uint8_t)((ci + bi) & 255);
      buf[bi] = b;
      sum += (int32_t)b;
    }
    ssize_t nw = write(fd, buf, CHUNK);
    if (nw != CHUNK) {
      perror("write");
      close(fd);
      return 2;
    }
  }
  if (close(fd) != 0) {
    perror("close");
    return 3;
  }
  return sum & 255;
}
