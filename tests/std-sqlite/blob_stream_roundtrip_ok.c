/* STD-137：blob stream C 烟测入口 */
#include <stdint.h>

extern int32_t db_sqlite_blob_stream_smoke_c(void);

int main(void) {
  return (int)db_sqlite_blob_stream_smoke_c();
}
