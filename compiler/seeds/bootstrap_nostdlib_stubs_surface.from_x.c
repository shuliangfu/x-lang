/* seeds/bootstrap_nostdlib_stubs_surface.from_x.c
 * G-02f-80 bootstrap_nostdlib_stubs R2 mixed surface - isomorphic with src/asm/bootstrap_nostdlib_stubs.x
 * Product PREFER_X_O: xlang-c -E(.x) -> thin.o + ld -r with rest (seeds/bootstrap_nostdlib_stubs.from_x.c)
 * Prove: full.x vs this surface -> nm IDENTICAL (6 #[no_mangle] + 1 doc_anchor)
 * Mode: mixed - 5 thin+rest forwards to _impl + 1 DIRECT pure compute (bootstrap_align16)
 * Cap residual: 5 _impl bridges (heap_grow/syscall3/syscall4/format_double/vfprintf_fd)
 * doc_anchor bootstrap_nostdlib_stubs_x_doc_anchor (no ast_; no module prefix on doc_anchor).
 * Note: bootstrap_ prefix not trigger ast_ (confirmed wave545+).
 * Logic: 6 functions = 5 thin+rest + 1 DIRECT. seed 全守卫 #ifndef XLANG_BOOTSTRAP_NOSTDLIB_STUBS_FROM_X.
 * Regen: ./xlang-c -E ... bootstrap_nostdlib_stubs.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int32_t bootstrap_heap_grow_impl(size_t need);
extern int64_t bootstrap_syscall3_impl(int64_t nr, int64_t a0, int64_t a1, int64_t a2);
extern int64_t bootstrap_syscall4_impl(int64_t nr, int64_t a0, int64_t a1, int64_t a2, int64_t a3);
extern int32_t bootstrap_format_double_impl(double x, uint8_t *out, size_t cap);
extern int32_t bootstrap_vfprintf_fd_impl(int32_t fd, uint8_t *fmt, uint8_t *ap);

int32_t bootstrap_nostdlib_stubs_x_doc_anchor(void) { return 0; }

/* === 5 thin+rest forwards === */

int32_t bootstrap_heap_grow(size_t need) {
  return bootstrap_heap_grow_impl(need);
}

int64_t bootstrap_syscall3(int64_t nr, int64_t a0, int64_t a1, int64_t a2) {
  return bootstrap_syscall3_impl(nr, a0, a1, a2);
}

int64_t bootstrap_syscall4(int64_t nr, int64_t a0, int64_t a1, int64_t a2, int64_t a3) {
  return bootstrap_syscall4_impl(nr, a0, a1, a2, a3);
}

int32_t bootstrap_format_double(double x, uint8_t *out, size_t cap) {
  return bootstrap_format_double_impl(x, out, cap);
}

int32_t bootstrap_vfprintf_fd(int32_t fd, uint8_t *fmt, uint8_t *ap) {
  return bootstrap_vfprintf_fd_impl(fd, fmt, ap);
}

/* === 1 DIRECT pure compute === */

size_t bootstrap_align16(size_t n) {
  /* (n + 15) & ~15 — mirror .x: (n + 15) & (0 - 16) */
  return (n + 15u) & ~(size_t)15u;
}
