/* STD-086：config.c 烟测入口 */
#include <stdint.h>
extern int32_t config_smoke_c(void);

int main(void) {
  return (int)config_smoke_c();
}
