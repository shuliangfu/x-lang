/* r07_hash.c — FNV-1a 64-bit hash benchmark (matches r07_hash.x / .zig)
 * Tests: 64-bit integer arithmetic, byte-level memory access, dependency chain.
 * Algorithm: FNV-1a 64-bit, repeated R=10 rounds over N=10M byte buffer.
 * Init: buf[i] = i & 0xFF. Each round resets hash to offset basis.
 * Anti-fold: memory barrier after init makes buf opaque; __asm__ on hash per round. */
#include <stdint.h>

enum { N = 10000000, R = 10 };

int main(void) {
  static uint8_t buf[N];
  int32_t i = 0;
  while (i < N) {
    buf[i] = (uint8_t)(i & 0xFF);
    i = i + 1;
  }
  /* B-CMP: memory barrier prevents the compiler from assuming buf[i] = i & 0xFF
   * during the hash loop, blocking compile-time hash evaluation. */
  __asm__ volatile("" : : : "memory");

  uint64_t hash = 0;
  int32_t r = 0;
  while (r < R) {
    uint64_t h = 14695981039346656037ULL; /* FNV-1a 64-bit offset basis */
    i = 0;
    while (i < N) {
      h ^= (uint64_t)buf[i];
      h *= 1099511628211ULL; /* FNV-1a 64-bit prime */
      i = i + 1;
    }
    hash += h;
    /* B-CMP: make hash opaque so the compiler cannot skip or fold rounds. */
    __asm__ volatile("" : "+r"(hash) : : "memory");
    r = r + 1;
  }

  int32_t result = (int32_t)(hash & 0xFFFFFFFFu);
  __asm__ volatile("" : "+r"(result) : : "memory");
  return (int)result;
}
