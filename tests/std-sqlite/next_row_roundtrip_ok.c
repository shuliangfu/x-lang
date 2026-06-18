/**
 * tests/std-db/next_row_roundtrip_ok.c — STD-067 C next_row 游标烟测入口
 */
#include <stdint.h>

extern int32_t db_sqlite_next_row_smoke_c(void);

int main(void) {
  return (int)db_sqlite_next_row_smoke_c();
}
