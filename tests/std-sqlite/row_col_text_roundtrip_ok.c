/**
 * tests/std-db/row_col_text_roundtrip_ok.c — STD-068 C row_col_text 文本列烟测入口
 */
#include <stdint.h>

extern int32_t db_sqlite_row_col_text_smoke_c(void);

int main(void) {
  return (int)db_sqlite_row_col_text_smoke_c();
}
