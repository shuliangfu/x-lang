/**
 * STD-113：ChaCha20-Poly1305 C 烟测入口。
 */
#include <stdint.h>

extern int32_t crypto_chacha20_poly1305_smoke_c(void);

int main(void) {
  return crypto_chacha20_poly1305_smoke_c() != 0 ? 1 : 0;
}
