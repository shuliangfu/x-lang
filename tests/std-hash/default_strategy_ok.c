/**
 * tests/std-hash/default_strategy_ok.c — STD-148 默认策略 C 烟测入口
 */
#include <stdint.h>

extern int32_t hash_default_strategy_smoke_c(void);

int main(void) {
  return (int)hash_default_strategy_smoke_c();
}
