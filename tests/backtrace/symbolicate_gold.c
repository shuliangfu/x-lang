/**
 * tests/backtrace/symbolicate_gold.c — STD-052 C 金样烟测入口
 */
#include <stdint.h>

extern int32_t backtrace_symbolicate_smoke_c(void);

int main(void) {
  return backtrace_symbolicate_smoke_c();
}
