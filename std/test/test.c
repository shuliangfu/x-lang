/**
 * std/test/test.c — 测试断言与 runner（对标 Zig std.testing、Rust test）
 *
 * 【文件职责】expect(cond)、expect_eq_i32、expect_ne_i32 返回 0/1；test_run_c(fn) 调用并返回退出码。
 * STD-054：bench_run / bench_report / fuzz_seed / fuzz_next / fuzz_run 占位 API。
 * STD-145：统一 runner 报告 test_runner_report_case_c / runner_finish 汇总行。
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if !defined(_WIN32) && !defined(_WIN64)
#include <time.h>
#endif

int32_t test_expect_c(int32_t cond) {
  return cond ? 0 : 1;
}

int32_t test_expect_eq_i32_c(int32_t a, int32_t b) {
  return (a == b) ? 0 : 1;
}

int32_t test_expect_eq_u32_c(uint32_t a, uint32_t b) {
  return (a == b) ? 0 : 1;
}

int32_t test_expect_ne_i32_c(int32_t a, int32_t b) {
  return (a != b) ? 0 : 1;
}

/* 调用无参返回 i32 的测试函数，返回其返回值（0=通过，非0=失败）。fn 为函数地址（usize）。 */
int32_t test_run_c(void *fn) {
  if (fn == 0) return -1;
  return ((int32_t (*)(void))fn)();
}

/** 单调时钟纳秒（bench 计时用）。 */
static int64_t test_now_ns(void) {
#if defined(_WIN32) || defined(_WIN64)
  return 0;
#else
  struct timespec ts;
  if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) return 0;
  return (int64_t)ts.tv_sec * 1000000000LL + (int64_t)ts.tv_nsec;
#endif
}

/** 调用无参 fn 共 iters 次，返回纳秒耗时；失败 -1。 */
int64_t test_bench_run_c(void *fn, int32_t iters) {
  int32_t i;
  int64_t t0;
  int64_t t1;
  int32_t (*f)(void);
  if (!fn || iters <= 0) return -1;
  f = (int32_t (*)(void))fn;
  t0 = test_now_ns();
  for (i = 0; i < iters; i++) {
    (void)f();
  }
  t1 = test_now_ns();
  return t1 - t0;
}

/** 写 bench 报告行到 stderr：shux: [SHUX_BENCH] name=… ns=… */
int32_t test_bench_report_c(const uint8_t *name, int32_t len, int64_t ns) {
  char line[256];
  char nbuf[128];
  if (!name || len <= 0) return -1;
  if (len >= (int32_t)sizeof(nbuf)) len = (int32_t)sizeof(nbuf) - 1;
  memcpy(nbuf, name, (size_t)len);
  nbuf[len] = 0;
  if (snprintf(line, sizeof(line), "shux: [SHUX_BENCH] name=%s ns=%lld\n", nbuf, (long long)ns) <= 0) {
    return -1;
  }
  fputs(line, stderr);
  return 0;
}

/** 读取 SHUX_FUZZ_SEED 或默认 0xABCDEF01。 */
uint32_t test_fuzz_seed_c(void) {
  const char *v = getenv("SHUX_FUZZ_SEED");
  if (v && v[0]) return (uint32_t)strtoul(v, NULL, 0);
  return 0xABCDEF01u;
}

/** LCG 单步 PRNG；state 为 in/out 种子。 */
uint32_t test_fuzz_next_c(uint32_t *state) {
  if (!state) return 0;
  *state = (*state * 1103515245u + 12345u) & 0x7fffffffu;
  return *state;
}

/** 每轮推进 PRNG 后调用 fn；全部返回 0 则 0，否则 1，参数非法 -1。 */
int32_t test_fuzz_run_c(void *fn, int32_t iters) {
  uint32_t state;
  int32_t i;
  int32_t (*f)(void);
  if (!fn || iters <= 0) return -1;
  f = (int32_t (*)(void))fn;
  state = test_fuzz_seed_c();
  for (i = 0; i < iters; i++) {
    (void)test_fuzz_next_c(&state);
    if (f() != 0) return 1;
  }
  return 0;
}

/** C 内置 noop（bench/fuzz runner 用）。 */
static int32_t test_noop_fn(void) { return 0; }

/** STD-054 C 烟测：bench_report 行 + bench_run + fuzz_next 非零。 */
int32_t test_bench_fuzz_smoke_c(void) {
  const uint8_t name[] = "smoke";
  int64_t ns;
  uint32_t st;
  if (test_bench_report_c(name, 5, 42) != 0) return 1;
  ns = test_bench_run_c((void *)test_noop_fn, 8);
  if (ns < 0) return 2;
  st = test_fuzz_seed_c();
  if (test_fuzz_next_c(&st) == 0) return 3;
  return 0;
}

/** STD-143：对内置 noop 跑 bench_run，返回纳秒。 */
int64_t test_bench_run_noop_c(int32_t iters) {
  return test_bench_run_c((void *)test_noop_fn, iters);
}

/** STD-143：对内置 noop 跑 fuzz_run。 */
int32_t test_fuzz_run_noop_c(int32_t iters) {
  return test_fuzz_run_c((void *)test_noop_fn, iters);
}

/** STD-145 runner 计数器。 */
static int32_t s_runner_total = 0;
static int32_t s_runner_pass = 0;
static int32_t s_runner_fail = 0;
static int32_t s_runner_skip = 0;

/** 复制用例名到 NUL 结尾缓冲。 */
static void test_runner_copy_name(char *out, int32_t cap, const uint8_t *name, int32_t len) {
  if (!out || cap <= 0) return;
  if (!name || len <= 0) {
    out[0] = 0;
    return;
  }
  if (len >= cap) len = cap - 1;
  memcpy(out, name, (size_t)len);
  out[len] = 0;
}

/** 重置 runner 计数（STD-145）。 */
void test_runner_reset_c(void) {
  s_runner_total = 0;
  s_runner_pass = 0;
  s_runner_fail = 0;
  s_runner_skip = 0;
}

/** 报告单条用例：shux: [SHUX_TEST] name=… status=pass|fail code=… */
int32_t test_runner_report_case_c(const uint8_t *name, int32_t len, int32_t exit_code) {
  char nbuf[128];
  const char *status;
  test_runner_copy_name(nbuf, (int32_t)sizeof(nbuf), name, len);
  s_runner_total++;
  if (exit_code == 0) {
    status = "pass";
    s_runner_pass++;
  } else {
    status = "fail";
    s_runner_fail++;
  }
  fprintf(stderr, "shux: [SHUX_TEST] name=%s status=%s code=%d\n", nbuf, status, exit_code);
  return exit_code;
}

/** 报告 skip 用例。 */
int32_t test_runner_report_skip_c(const uint8_t *name, int32_t len) {
  char nbuf[128];
  test_runner_copy_name(nbuf, (int32_t)sizeof(nbuf), name, len);
  s_runner_total++;
  s_runner_skip++;
  fprintf(stderr, "shux: [SHUX_TEST] name=%s status=skip code=0\n", nbuf);
  return 0;
}

/** 输出汇总行并返回 fail 数。 */
int32_t test_runner_finish_c(void) {
  fprintf(stderr, "shux: [SHUX_TEST_SUMMARY] total=%d pass=%d fail=%d skip=%d\n", s_runner_total,
          s_runner_pass, s_runner_fail, s_runner_skip);
  return s_runner_fail;
}
