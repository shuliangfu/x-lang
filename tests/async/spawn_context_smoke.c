/**
 * tests/async/spawn_context_smoke.c — STD-093 C 烟测入口（链 scheduler.o + context.o）
 */
#include <stdint.h>

extern int32_t shu_async_spawn_ctx_smoke_c(void);

int main(void) {
  return shu_async_spawn_ctx_smoke_c();
}
