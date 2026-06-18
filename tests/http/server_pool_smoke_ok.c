/**
 * tests/http/server_pool_smoke_ok.c — STD-107 C server+pool 烟测入口
 */
#include <stdint.h>

extern int32_t http_server_pool_smoke_c(void);

int main(void) {
  return (int)http_server_pool_smoke_c();
}
