/**
 * tests/std-db/query_rows_roundtrip_ok.c — STD-066 C query_rows 烟测入口
 */
#include <stdint.h>

extern int32_t db_sqlite_query_rows_smoke_c(void);

int main(void) {
  return (int)db_sqlite_query_rows_smoke_c();
}
