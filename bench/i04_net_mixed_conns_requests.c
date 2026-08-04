/**
 * net_mixed_conns_requests.c — PERF-003 混合 client（C -O2 对照）
 *
 * 256 次建连 × 每连接 16 轮 512B echo；记录每轮 RTT，stderr 输出 BENCH_P99_US=。
 * 用法：net_mixed_conns_requests [port]  默认 38459
 */
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <time.h>
#include <unistd.h>

enum {
  MIXED_PORT_DEFAULT = 38459,
  MIXED_CONNS = 256,
  MIXED_ROUNDS = 16,
  MIXED_PAYLOAD = 512,
  MAX_SAMPLES = MIXED_CONNS * MIXED_ROUNDS
};

static uint64_t lat_us[MAX_SAMPLES];
static int n_samples;

/** 单调时钟微秒。 */
static uint64_t bench_now_us(void) {
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0)
    return 0;
  return (uint64_t)ts.tv_sec * 1000000ull + (uint64_t)(ts.tv_nsec / 1000);
}

/** uint64 升序比较（qsort）。 */
static int cmp_u64(const void *a, const void *b) {
  const uint64_t x = *(const uint64_t *)a;
  const uint64_t y = *(const uint64_t *)b;
  if (x < y)
    return -1;
  if (x > y)
    return 1;
  return 0;
}

/** 计算已采集样本的 P99（微秒）。 */
static uint64_t bench_p99_us(void) {
  int idx;
  if (n_samples <= 0)
    return 0;
  qsort(lat_us, (size_t)n_samples, sizeof(lat_us[0]), cmp_u64);
  idx = (n_samples * 99) / 100;
  if (idx >= n_samples)
    idx = n_samples - 1;
  return lat_us[idx];
}

/** 单次 TCP connect；成功返回 fd。 */
static int bench_connect_once(uint16_t port) {
  int fd = socket(AF_INET, SOCK_STREAM, 0);
  struct sockaddr_in sin;
  struct linger ling;
  if (fd < 0)
    return -1;
  memset(&sin, 0, sizeof(sin));
  sin.sin_family = AF_INET;
  sin.sin_port = htons(port);
  sin.sin_addr.s_addr = htonl(0x7f000001u);
  if (connect(fd, (struct sockaddr *)&sin, sizeof(sin)) != 0) {
    close(fd);
    return -1;
  }
  ling.l_onoff = 1;
  ling.l_linger = 0;
  (void)setsockopt(fd, SOL_SOCKET, SO_LINGER, &ling, sizeof(ling));
  return fd;
}

/** 写满 MIXED_PAYLOAD 字节。 */
static int bench_write_all(int fd, uint8_t *buf) {
  ssize_t off = 0;
  while (off < (ssize_t)MIXED_PAYLOAD) {
    ssize_t nw = write(fd, buf + off, (size_t)(MIXED_PAYLOAD - off));
    if (nw <= 0)
      return -1;
    off += nw;
  }
  return 0;
}

/** 读满 MIXED_PAYLOAD 字节。 */
static int bench_read_all(int fd, uint8_t *buf) {
  ssize_t off = 0;
  while (off < (ssize_t)MIXED_PAYLOAD) {
    ssize_t nr = read(fd, buf + off, (size_t)(MIXED_PAYLOAD - off));
    if (nr <= 0)
      return -1;
    off += nr;
  }
  return 0;
}

int main(int argc, char **argv) {
  uint16_t port = (uint16_t)MIXED_PORT_DEFAULT;
  uint8_t buf[MIXED_PAYLOAD];
  int32_t sum = 0;
  int ci;
  int round;
  if (argc >= 2)
    port = (uint16_t)atoi(argv[1]);
  n_samples = 0;
  for (ci = 0; ci < MIXED_CONNS; ci++) {
    int fd = bench_connect_once(port);
    uint64_t t0;
    uint64_t t1;
    if (fd < 0) {
      perror("connect");
      return 2;
    }
    for (round = 0; round < MIXED_ROUNDS; round++) {
      int bi;
      for (bi = 0; bi < MIXED_PAYLOAD; bi++)
        buf[bi] = (uint8_t)((ci + round + bi) & 255);
      t0 = bench_now_us();
      if (bench_write_all(fd, buf) != 0 || bench_read_all(fd, buf) != 0) {
        (void)close(fd);
        return 3;
      }
      t1 = bench_now_us();
      if (n_samples < MAX_SAMPLES)
        lat_us[n_samples++] = (t1 > t0) ? (t1 - t0) : 1;
      for (bi = 0; bi < MIXED_PAYLOAD; bi++)
        sum += (int32_t)buf[bi];
    }
    (void)close(fd);
  }
  fprintf(stderr, "BENCH_P99_US=%llu\n", (unsigned long long)bench_p99_us());
  return sum & 255;
}
