/* STD-089：task.c 烟测入口 */
#include <stdint.h>
extern int32_t task_smoke_c(void);

int main(void) {
  return (int)task_smoke_c();
}
