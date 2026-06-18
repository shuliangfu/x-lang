/**
 * tests/backtrace/xplat_quality.c — STD-147 跨平台符号质量烟测入口
 */
#include <stdint.h>

extern int32_t backtrace_xplat_quality_c(void);

int main(void) {
  return (int)backtrace_xplat_quality_c();
}
