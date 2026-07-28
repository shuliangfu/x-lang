/* seeds/runtime_asm_io_stubs_surface.from_x.c
 * G-02f-100 runtime_asm_io_stubs R2 thin+rest surface — isomorphic with src/asm/runtime_asm_io_stubs.x
 * Product PREFER_X_O: xlang-c -E(.x) → thin.o + ld -r with rest (seeds/runtime_asm_io_stubs.from_x.c)
 * Prove: full.x vs this surface → nm IDENTICAL (3 #[no_mangle] + 1 doc_anchor)
 * Mode: thin+rest — .x provides 3 public wrappers (seed_io_syscall_write/read + seed_io_write_fd1);
 *   _impl bridges (Linux x86_64 raw syscall write/read + io_write delegate) stay in rest seed
 * Cap residual: 3 _impl — seed_io_syscall_write_impl/read_impl (Linux x86_64 inline asm syscall) +
 *   seed_io_write_fd1_impl (delegates to io_write → POSIX write/Windows shim)
 * Note: doc_anchor runtime_asm_io_stubs_x_doc_anchor present in .x — prove includes it.
 * Logic: 3 functions = seed_io_syscall_write + seed_io_syscall_read + seed_io_write_fd1.
 *   All forward to _impl extern C bridges in rest.
 * Regen: ./xlang-c -E ... runtime_asm_io_stubs.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>

extern int64_t seed_io_syscall_write_impl(int32_t fd, uint8_t *buf, size_t count);
extern int64_t seed_io_syscall_read_impl(int32_t fd, uint8_t *buf, size_t count);
extern int32_t seed_io_write_fd1_impl(uint8_t *ptr, size_t len, uint32_t timeout_ms);

int32_t runtime_asm_io_stubs_x_doc_anchor(void) {
  return 0;
}

int64_t seed_io_syscall_write(int32_t fd, uint8_t *buf, size_t count) {
  return seed_io_syscall_write_impl(fd, buf, count);
}

int64_t seed_io_syscall_read(int32_t fd, uint8_t *buf, size_t count) {
  return seed_io_syscall_read_impl(fd, buf, count);
}

int32_t seed_io_write_fd1(uint8_t *ptr, size_t len, uint32_t timeout_ms) {
  return seed_io_write_fd1_impl(ptr, len, timeout_ms);
}
