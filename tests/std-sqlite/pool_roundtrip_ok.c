/* STD-084：sqlite pool C 烟测入口 */
extern int db_sqlite_pool_smoke_c(void);

int main(void) {
  return db_sqlite_pool_smoke_c();
}
