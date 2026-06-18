#include <stdint.h>
extern int32_t crypto_ed25519_smoke_c(void);
int main(void) { return crypto_ed25519_smoke_c() != 0; }
