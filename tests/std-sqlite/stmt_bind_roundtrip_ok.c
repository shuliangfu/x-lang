/* STD-070：stmt bind C 烟测入口 */
extern int db_sqlite_stmt_bind_smoke_c(void);

int main(void) {
  return db_sqlite_stmt_bind_smoke_c();
}
