/**
 * tests/dynlib/win_path_smoke.c — STD-097 Windows 正斜杠路径 C 烟测（非 Windows 返回 0）
 */
#include <stdint.h>

extern int32_t dynlib_win_path_smoke_c(void);

int main(void) {
  return (int)dynlib_win_path_smoke_c();
}
