#include <stdint.h>
extern int32_t random_rng_smoke_c(void);
int main(void) { return random_rng_smoke_c() != 0; }
