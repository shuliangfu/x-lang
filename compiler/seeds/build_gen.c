/**
 * seeds/build_gen.c — pinned C for build.x (G-05)
 * Matches build_use_asm_only / build_get_step_at / build_get_step_count.
 * Regenerate with: shux -x -E -L .. ../build.x  (when -x -E is stable for this file).
 */
#include <stdint.h>
#include <stddef.h>

int32_t build_use_asm_only(void) {
  return 1;
}

int32_t build_get_step_at(int32_t i) {
  if (i == 0) {
    return 0;
  }
  if (i == 1) {
    return 6;
  }
  if (i == 2) {
    return 1;
  }
  if (i == 3) {
    return 2;
  }
  if (i == 4) {
    return 3;
  }
  if (i == 5) {
    return 4;
  }
  if (i == 6) {
    return 5;
  }
  return -1;
}

int32_t build_get_step_count(void) {
  return 7;
}
