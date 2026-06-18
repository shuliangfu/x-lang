/**
 * STD-119：config YAML C 烟测入口。
 */
#include <stdint.h>

extern int32_t config_yaml_smoke_c(void);

int main(void) {
  return config_yaml_smoke_c() != 0 ? 1 : 0;
}
