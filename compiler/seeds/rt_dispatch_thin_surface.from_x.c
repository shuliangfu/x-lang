/* seeds/rt_dispatch_thin_surface.from_x.c
 * G-02f rt_dispatch R2 full surface — isomorphic with src/runtime/rt_dispatch_thin.x
 * Product PREFER_X_O: g05_try_x_to_o(full.x) + rest marker seed
 *   seeds/rt_dispatch_thin.from_x.c (-DXLANG_RT_DISPATCH_THIN_FROM_X) ld -r into runtime_driver_no_c
 * FROM_X rest business H=0 (marker only); Cap residual: sibling spawn in driver_abi
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface)
 * Regen: ./xlang -E ... src/runtime/rt_dispatch_thin.x | filter DBG + polish externs
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
/* PLATFORM: SHARED — include/unistd.h shim provides POSIX wrappers on MinGW
 *            (read/write/close/lseek/open/pread/pwrite/setenv/unsetenv).
 *            include/poll.h and include/sys/uio.h shims also available.
 *            macOS/Linux delegate to system headers via #include_next.
 *            Historical #ifndef _WIN32 guard removed for safe includes. */
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
extern int32_t driver_run_asm_backend_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv);
extern int32_t driver_run_emit_c_path_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv);
extern int32_t driver_run_compiler_full_x_impl_c(int32_t argc, uint8_t * argv);
extern int32_t driver_dispatch_sibling_try_spawn(int32_t argc, uint8_t * argv);
int32_t driver_run_asm_backend_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv) {
  {
    return driver_run_asm_backend_impl_c(input_path, out_path, lib_key, target, argc, argv);
  }
  return 0;
}
int32_t driver_run_emit_c_path_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv) {
  {
    return driver_run_emit_c_path_impl_c(input_path, out_path, lib_key, target, opt_level, use_lto, argc, argv);
  }
  return 0;
}
int32_t driver_run_compiler_full(int32_t argc, uint8_t * argv) {
  {
    return driver_run_compiler_full_x_impl_c(argc, argv);
  }
  return 0;
}
int32_t driver_try_compile_via_shu_c_sibling(int32_t argc, uint8_t * argv) {
  {
    return driver_dispatch_sibling_try_spawn(argc, argv);
  }
  return (0 - 1);
}
