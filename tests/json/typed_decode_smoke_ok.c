/**
 * STD-116：JSON typed decode C 烟测入口。
 */
#include <stdint.h>

extern int32_t json_typed_decode_smoke_c(void);

int main(void) {
  return json_typed_decode_smoke_c() != 0 ? 1 : 0;
}
