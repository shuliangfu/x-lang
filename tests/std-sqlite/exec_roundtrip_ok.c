/**
 * tests/std-db/exec_roundtrip_ok.c — STD-057 C exec 往返烟测入口
 */
#include <stdint.h>

extern int32_t db_sqlite_exec_smoke_c(void);

int main(void) {
  return (int)db_sqlite_exec_smoke_c();
}
