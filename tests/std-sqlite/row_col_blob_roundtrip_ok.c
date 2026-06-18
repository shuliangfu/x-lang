/**
 * tests/std-db/row_col_blob_roundtrip_ok.c — STD-069 C row_col_blob BLOB 列烟测入口
 */
#include <stdint.h>

extern int32_t db_sqlite_row_col_blob_smoke_c(void);

int main(void) {
  return (int)db_sqlite_row_col_blob_smoke_c();
}
