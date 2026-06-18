/**
 * tests/std-base64/stream_smoke_ok.c — STD-109 C 流式 base64 烟测入口
 */
#include <stdint.h>

extern int32_t base64_stream_smoke_c(void);

int main(void) {
  return (int)base64_stream_smoke_c();
}
