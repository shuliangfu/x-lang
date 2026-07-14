/* seeds/rt_util_surface.from_x.c
 * G-02f rt_util R2 full surface — isomorphic with src/runtime/rt_util.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_util.x) + rest seed empty under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (2 public: unlink + basename)
 * Regen: ./shux -E ... src/runtime/rt_util.x | filter DBG + polish prologue
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
/* libc unlink via unistd.h (prove/g05 strip -E extern int32_t unlink) */
void driver_unlink_failed_output(uint8_t * out_path) {
  if ((out_path == ((uint8_t *)(0)))) {
    return;
  }
  if (((out_path)[((size_t)(0))] == ((uint8_t)(0)))) {
    return;
  }
  {
    (void)(unlink((const char *)out_path));
  }
  (void)(0);
  return;
}
int32_t driver_argv0_basename_is(uint8_t * argv0, uint8_t * base) {
  if ((base == ((uint8_t *)(0)))) {
    return 0;
  }
  if ((argv0 != ((uint8_t *)(0)))) {
    int32_t i = 0;
    int32_t last = (0 - 1);
    while ((i < 4096)) {
      uint8_t c = (argv0)[i];
      if ((c == 0)) {
        break;
      }
      if ((c == 47)) {
        (void)((last = i));
      }
      if ((c == 92)) {
        (void)((last = i));
      }
      (void)((i = (i + 1)));
    }
    if ((last >= 0)) {
      int32_t j = 0;
      while ((j < 256)) {
        uint8_t a = (argv0)[((last + 1) + j)];
        uint8_t b = (base)[j];
        if ((a != b)) {
          return 0;
        }
        if ((a == 0)) {
          return 1;
        }
        (void)((j = (j + 1)));
      }
      return 0;
    }
  }
  if ((argv0 == ((uint8_t *)(0)))) {
    if (((base)[0] == 0)) {
      return 1;
    }
    return 0;
  }
  int32_t j2 = 0;
  while ((j2 < 256)) {
    uint8_t a2 = (argv0)[j2];
    uint8_t b2 = (base)[j2];
    if ((a2 != b2)) {
      return 0;
    }
    if ((a2 == 0)) {
      return 1;
    }
    (void)((j2 = (j2 + 1)));
  }
  return 0;
}
