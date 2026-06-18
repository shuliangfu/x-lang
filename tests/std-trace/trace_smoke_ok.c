/* STD-088：trace.c 烟测入口 */
#include <stdint.h>
extern int32_t trace_smoke_c(void);

int main(void) {
  return (int)trace_smoke_c();
}
