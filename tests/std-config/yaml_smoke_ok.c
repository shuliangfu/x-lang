/**
 * STD-119：config YAML C 烟测入口。
 * Knife 11.42: pass through config_yaml_smoke_c() exit (same honesty as
 * config_smoke_ok.c). Do not collapse non-zero residual (e.g. 3 from 11.31
 * cfg_trim/out_len shape) into generic exit 1.
 */
#include <stdint.h>

extern int32_t config_yaml_smoke_c(void);

int main(void) {
  return (int)config_yaml_smoke_c();
}
