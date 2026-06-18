/**
 * STD-115：特殊函数 C 烟测入口（链接 math.o + -lm）。
 */
#include <stdint.h>

extern int32_t math_special_smoke_c(void);

int main(void) {
  return math_special_smoke_c() != 0 ? 1 : 0;
}
