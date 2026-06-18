/**
 * tests/bench/obs_structured_log_smoke.c — OBS-003 结构化日志烟测
 *
 * 调用 log_write_structured_kv_c，验证 stderr 行可被 gate grep。
 *
 * 编译：cc -std=gnu11 -o obs_structured_log_smoke \
 *         tests/bench/obs_structured_log_smoke.c std/log/log.o
 */
#include <stdint.h>
#include <stdio.h>

extern int32_t log_write_structured_kv_c(const char *component, int32_t level, const char *kv_body);

/**
 * 入口：输出一条结构化 info 行，exit 0。
 */
int main(void) {
  if (log_write_structured_kv_c("obs_smoke", 1, "event=gate_ok case=1") != 0) {
    fprintf(stderr, "obs_structured_log_smoke: log_write_structured_kv_c failed\n");
    return 1;
  }
  return 0;
}
