/**
 * tests/http/http_timeout_smoke.c — STD-095 http_get_timeout_c 超时 C 烟测
 */
#include <stdint.h>

extern int32_t http_timeout_smoke_c(void);

int main(void) {
  return (int)http_timeout_smoke_c();
}
