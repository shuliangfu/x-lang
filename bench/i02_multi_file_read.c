/**
 * i02_multi_file_read.c — 多文件并发读吞吐（C -O2 -pthread 对照）
 *
 * 算法：
 *   1. 在 /tmp 下创建 F=8 个临时文件，每个 1 MiB
 *   2. 用 T=4 线程并发读取，每线程读 F/T=2 个文件，累加读取字节数
 *   3. 测总吞吐（GB/s）
 *   4. 退出前清理临时文件
 *
 * 返回：总读取字节数 & 0xFF（== 8*1024*1024 & 0xFF == 0）
 *
 * 编译：cc -O2 -pthread bench/i02_multi_file_read.c -o /tmp/test_i02
 */
#include <pthread.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>

/* PLATFORM: SHARED — POSIX file I/O (open/read/write/close/unlink). */
enum { F = 8, T = 4, FILE_BYTES = 1024 * 1024, CHUNK = 64 * 1024 };

typedef struct {
  int file_start;
  int file_count;
  int64_t bytes_read;
  int ok;
} reader_arg;

/** make_path：将 /tmp/i02_bench_file_{idx}.dat 写入 buf。 */
static void make_path(char *buf, size_t n, int idx) {
  snprintf(buf, n, "/tmp/i02_bench_file_%d.dat", idx);
}

/** reader：读取 file_count 个文件（从 file_start 开始），累加字节数。 */
static void *reader(void *arg) {
  reader_arg *a = (reader_arg *)arg;
  uint8_t buf[CHUNK];
  int64_t total = 0;
  int fi = a->file_start;
  while (fi < a->file_start + a->file_count) {
    char path[64];
    make_path(path, sizeof(path), fi);
    int fd = open(path, O_RDONLY);
    if (fd < 0) {
      perror("i02: open");
      a->ok = 0;
      a->bytes_read = total;
      return NULL;
    }
    int remaining = FILE_BYTES;
    while (remaining > 0) {
      int to_read = CHUNK;
      if (to_read > remaining) to_read = remaining;
      ssize_t nr = read(fd, buf, (size_t)to_read);
      if (nr <= 0) break;
      total += nr;
      remaining -= (int)nr;
    }
    close(fd);
    fi = fi + 1;
  }
  /* 防止 total 被折叠。 */
  __asm__ volatile("" : "+r"(total) : : "memory");
  a->bytes_read = total;
  a->ok = 1;
  return NULL;
}

/** cleanup_files：删除所有 F 个临时文件（best-effort）。 */
static void cleanup_files(void) {
  for (int f = 0; f < F; f++) {
    char path[64];
    make_path(path, sizeof(path), f);
    unlink(path);
  }
}

int main(void) {
  /* ---- Phase 1: 写 F × 1 MiB 临时文件 ---- */
  uint8_t wbuf[CHUNK];
  for (int i = 0; i < CHUNK; i++) wbuf[i] = (uint8_t)(i & 255);

  for (int f = 0; f < F; f++) {
    char path[64];
    make_path(path, sizeof(path), f);
    int fd = open(path, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (fd < 0) {
      perror("i02: create");
      cleanup_files();
      return 1;
    }
    int remaining = FILE_BYTES;
    while (remaining > 0) {
      int to_write = CHUNK;
      if (to_write > remaining) to_write = remaining;
      ssize_t nw = write(fd, wbuf, (size_t)to_write);
      if (nw <= 0) {
        perror("i02: write");
        close(fd);
        cleanup_files();
        return 2;
      }
      remaining -= (int)nw;
    }
    close(fd);
  }

  /* ---- Phase 2: T 线程并发读，计时 ---- */
  struct timespec t0, t1;
  clock_gettime(CLOCK_MONOTONIC, &t0);

  pthread_t threads[T];
  reader_arg args[T];
  int per = F / T;
  for (int i = 0; i < T; i++) {
    args[i].file_start = i * per;
    args[i].file_count = per;
    args[i].bytes_read = 0;
    args[i].ok = 0;
    if (pthread_create(&threads[i], NULL, reader, &args[i]) != 0) {
      fprintf(stderr, "i02: pthread_create %d failed\n", i);
      /* 已 spawn 的线程 join 后再清理。 */
      for (int j = 0; j < i; j++) pthread_join(threads[j], NULL);
      cleanup_files();
      return 3;
    }
  }

  int64_t total_bytes = 0;
  int all_ok = 1;
  for (int i = 0; i < T; i++) {
    pthread_join(threads[i], NULL);
    total_bytes += args[i].bytes_read;
    if (!args[i].ok) all_ok = 0;
  }

  clock_gettime(CLOCK_MONOTONIC, &t1);
  double secs = (double)(t1.tv_sec - t0.tv_sec)
              + (double)(t1.tv_nsec - t0.tv_nsec) / 1e9;
  double gbps = ((double)total_bytes / (1024.0 * 1024.0 * 1024.0)) / secs;
  fprintf(stderr,
          "i02: files=%d threads=%d bytes=%lld (%s) in %.6fs = %.3f GB/s\n",
          F, T, (long long)total_bytes, all_ok ? "ok" : "partial",
          secs, gbps);

  /* ---- Phase 3: 清理临时文件 ---- */
  cleanup_files();

  if (!all_ok) return 4;

  /* 防止 total_bytes 被折叠。 */
  __asm__ volatile("" : "+r"(total_bytes) : : "memory");
  return (int)(total_bytes & 255);
}
