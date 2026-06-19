/* STD-139：stub 后端 C 烟测入口 */
#include <stdint.h>

extern int32_t db_sqlite_stub_smoke_c(void);

int main(void) {
  return (int)db_sqlite_stub_smoke_c();
}
