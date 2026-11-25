/*
 * DIG s223: freestanding stub for malloc_trim.
 *
 * Leftover pipeline_abi.from_x.c may call malloc_trim without weak;
 * pure-ld nostdlib then UNDEFs. Seed path uses weak + null-check.
 * This strong stub returns 0 (no-op trim) so product links without
 * pulling glibc. PLATFORM: LINUX gold / SHARED host-cc.
 */
#include <stddef.h>

/**
 * No-op malloc_trim for freestanding / nostdlib product links.
 * @return 0 — trim not performed
 */
int malloc_trim(size_t pad) {
  (void)pad;
  return 0;
}
