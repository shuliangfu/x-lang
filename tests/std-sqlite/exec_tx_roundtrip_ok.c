/**
 * tests/std-db/exec_tx_roundtrip_ok.c — STD-065 C 事务 exec 烟测入口
 */
#include <stdint.h>

extern int32_t db_sqlite_tx_exec_smoke_c(void);

int main(void) {
  return (int)db_sqlite_tx_exec_smoke_c();
}
