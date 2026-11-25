/*
 * DIG s223: host-cc twin for field_load_sz_bytes_eq.
 *
 * LINUX wave540 HARD BAN tip reinject of helpers thin; leftover
 * runtime_pipeline_abi.o can keep U field_load_sz_bytes_eq with no T
 * provider. Authority: runtime_pipeline_abi_field_load_sz_helpers_thin.x
 * (same byte-compare contract). PLATFORM: SHARED host-cc LINK_WINNERS.
 */
#include <stdint.h>

/**
 * Compare n bytes at a and b; 1 if equal, else 0.
 * n<=0 → 1; null a or b → 0.
 */
int32_t field_load_sz_bytes_eq(uint8_t *a, uint8_t *b, int32_t n) {
  int32_t i;
  if (n <= 0) {
    return 1;
  }
  if (a == 0 || b == 0) {
    return 0;
  }
  i = 0;
  while (i < n) {
    if (a[i] != b[i]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}
