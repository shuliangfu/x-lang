/* STD-116：json 点分路径 decode 烟测入口 */
#include <stdint.h>

extern int32_t json_typed_decode_smoke_c(void);

int main(void) {
  return (int)json_typed_decode_smoke_c();
}
