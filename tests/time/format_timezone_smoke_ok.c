#include <stdint.h>

extern int32_t time_format_timezone_smoke_c(void);

int main(void) {
  return time_format_timezone_smoke_c() != 0;
}
