/**
 * io_mmap_throughput.c — I/O 基线：大文件 mmap 顺序扫描（C -O2 对照）
 * 路径须与 run-perf-io.sh 生成的 tests/bench/.io_mmap_bench_tmp 一致。
 */
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <unistd.h>

int main(void) {
  const char *path = "tests/bench/.io_mmap_bench_tmp";
  int fd = open(path, O_RDONLY);
  if (fd < 0) {
    perror("open");
    return 1;
  }
  struct stat st;
  if (fstat(fd, &st) != 0) {
    perror("fstat");
    close(fd);
    return 1;
  }
  size_t len = (size_t)st.st_size;
  if (len == 0) {
    close(fd);
    return 1;
  }
  void *p = mmap(NULL, len, PROT_READ, MAP_PRIVATE, fd, 0);
  if (p == MAP_FAILED) {
    perror("mmap");
    close(fd);
    return 1;
  }
  close(fd);
  int32_t sum = 0;
  const uint8_t *bytes = (const uint8_t *)p;
  for (size_t i = 0; i < len; i++) {
    sum += (int32_t)bytes[i];
  }
  if (munmap(p, len) != 0) {
    perror("munmap");
    return 2;
  }
  return sum & 255;
}
