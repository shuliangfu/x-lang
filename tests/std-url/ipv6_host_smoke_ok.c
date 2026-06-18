#include <stdint.h>

/** STD-134 C 金样驱动。 */
extern int32_t url_ipv6_host_smoke_c(void);

int main(void) {
  return url_ipv6_host_smoke_c() != 0;
}
