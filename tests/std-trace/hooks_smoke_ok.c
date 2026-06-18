/**
 * STD-118：trace hooks C 烟测入口。
 */
#include <stdint.h>

extern int32_t trace_hooks_smoke_c(void);

int main(void) {
  return trace_hooks_smoke_c() != 0 ? 1 : 0;
}
