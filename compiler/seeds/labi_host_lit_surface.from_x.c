/* seeds/labi_host_lit_surface.from_x.c
 * G-02f labi_host_lit R2 full surface — isomorphic with src/runtime/labi_host_lit.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_host_lit.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (2 public gates + count)
 * Cap residual: host #if → mega _impl
 * Regen: ./xlang -E ... src/runtime/labi_host_lit.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern int32_t xlang_host_is_linux(void);
extern int32_t xlang_host_is_apple_aarch64(void);
extern int32_t labi_host_lit_count(void);
extern int32_t xlang_host_is_linux_impl(void);
extern int32_t xlang_host_is_apple_aarch64_impl(void);
int32_t xlang_host_is_linux(void) {
  {
    return xlang_host_is_linux_impl();
  }
  return 0;
}
int32_t xlang_host_is_apple_aarch64(void) {
  {
    return xlang_host_is_apple_aarch64_impl();
  }
  return 0;
}
int32_t labi_host_lit_count(void) {
  return 2;
}
