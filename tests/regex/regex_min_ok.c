/**
 * tests/regex/regex_min_ok.c — STD-051 C 烟测入口（三平台 cc 可编）
 */
#include <stdint.h>

extern int32_t regex_min_smoke_c(void);

int main(void) {
  return regex_min_smoke_c();
}
