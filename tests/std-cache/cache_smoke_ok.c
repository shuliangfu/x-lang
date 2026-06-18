/* STD-087：cache.c 烟测入口 */
#include <stdint.h>
extern int32_t cache_smoke_c(void);

int main(void) {
  return (int)cache_smoke_c();
}
