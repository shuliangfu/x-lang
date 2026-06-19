/* STD-041：future.c 烟测入口 */
#include <stdint.h>

extern int32_t shux_async_future_smoke_c(void);

int main(void) {
  return (int)shux_async_future_smoke_c();
}
