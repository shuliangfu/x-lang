/* STD-041：future.c 烟测入口 */
#include <stdint.h>

extern int32_t xlang_async_future_smoke_c(void);

int main(void) {
  return (int)xlang_async_future_smoke_c();
}
