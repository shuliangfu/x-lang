/* PLATFORM: SHARED — pure-asm formal vehicle for std/debug (class-batch 2).
 *
 * Why C face: mod.x co-emits std.fmt / core.assert and is not required for the
 * soft residual smoke (assert + println). Product body stays in std/debug/mod.x.
 * G.7: single formal vehicle for pure-asm product link (std/debug/debug.o).
 * formal_mod kind=c_face.
 * Darwin arm64 product body is compiler/src/asm/std_debug_formal_darwin.x
 * (libSystem write). This file stays the Linux and Windows face, and the
 * Darwin fallback when pure asm leaves no object.
 */
#include <stdint.h>
#include <unistd.h>

int32_t std_debug_assert(int32_t b) {
  return b ? 0 : -1;
}

int32_t std_debug_println_u8_ptr_i32(uint8_t *ptr, int32_t len) {
  /* tests/run-debug std-debug checks stderr non-empty. */
  if (ptr != NULL && len > 0) {
    (void)write(2, ptr, (size_t)len);
  }
  (void)write(2, "\n", 1);
  return 0;
}

int32_t std_debug_print_u8_ptr_i32(uint8_t *ptr, int32_t len) {
  if (ptr != NULL && len > 0) {
    (void)write(2, ptr, (size_t)len);
  }
  return 0;
}
