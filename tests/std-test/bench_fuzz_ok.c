/**
 * tests/std-test/bench_fuzz_ok.c — STD-054 C 烟测入口
 */
#include <stdint.h>

extern int32_t test_bench_fuzz_smoke_c(void);

int main(void) {
  return test_bench_fuzz_smoke_c();
}
