/* seeds/rt_emit_flags_surface.from_x.c
 * G-02f rt_emit_flags R2 full surface — isomorphic with src/runtime/rt_emit_flags.x
 * Product PREFER_X_O: g05_try_x_to_o(rt_emit_flags.x) + rest seed empty under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (3 public: has_emit + set_use_lto + set_print_target_cpu)
 * Regen: ./shux -E ... src/runtime/rt_emit_flags.x | filter DBG + polish prologue
 * Track-L (2026-07-16): helpers rt_argv_is_minus_E / rt_argv_is_minus_E_extern /
 * rt_scan_argv_emit keep short names; .x has #[no_mangle] (was module-prefix mangle).
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
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
struct RtEmitFlagsState {
  uint8_t path_buf[512];
  int32_t path_len;
  uint8_t out_path_buf[512];
  int32_t out_path_len;
  int32_t use_asm_backend;
  int32_t target_arch;
  uint8_t target_buf[512];
  int32_t target_len;
  uint8_t opt_level_buf[8];
  int32_t opt_level_len;
  int32_t use_lto;
  int32_t backend_asm_explicit;
  int32_t use_freestanding;
  int32_t parse_saw_target;
  uint8_t target_cpu_buf[64];
  int32_t target_cpu_len;
  int32_t target_cpu_features;
  int32_t print_target_cpu;
  int32_t parse_saw_target_cpu;
};

extern int32_t rt_argv_is_minus_E(uint8_t * s);
extern int32_t rt_argv_is_minus_E_extern(uint8_t * s);
extern int32_t rt_scan_argv_emit(int32_t argc, uint8_t * * argv, int32_t i);
extern int32_t driver_argv_has_emit_c_flag(int32_t argc, uint8_t * * argv);
extern void driver_compile_argv_set_use_lto_c(struct RtEmitFlagsState * state);
extern void driver_compile_argv_set_print_target_cpu_c(struct RtEmitFlagsState * state);
int32_t rt_argv_is_minus_E(uint8_t * s) {
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((s)[0] !=45)) {
    return 0;
  }
  if (((s)[1] !=69)) {
    return 0;
  }
  if (((s)[2] !=0)) {
    return 0;
  }
  return 1;
}
int32_t rt_argv_is_minus_E_extern(uint8_t * s) {
  if ((s ==((uint8_t *)(0)))) {
    return 0;
  }
  if (((s)[0] !=45)) {
    return 0;
  }
  if (((s)[1] !=69)) {
    return 0;
  }
  if (((s)[2] !=45)) {
    return 0;
  }
  if (((s)[3] !=101)) {
    return 0;
  }
  if (((s)[4] !=120)) {
    return 0;
  }
  if (((s)[5] !=116)) {
    return 0;
  }
  if (((s)[6] !=101)) {
    return 0;
  }
  if (((s)[7] !=114)) {
    return 0;
  }
  if (((s)[8] !=110)) {
    return 0;
  }
  if (((s)[9] !=0)) {
    return 0;
  }
  return 1;
}
int32_t rt_scan_argv_emit(int32_t argc, uint8_t * * argv, int32_t i) {
  if ((i >=argc)) {
    return 0;
  }
  if ((rt_argv_is_minus_E((argv)[i]) !=0)) {
    return 1;
  }
  if ((rt_argv_is_minus_E_extern((argv)[i]) !=0)) {
    return 1;
  }
  return rt_scan_argv_emit(argc, argv, (i + 1));
}
int32_t driver_argv_has_emit_c_flag(int32_t argc, uint8_t * * argv) {
  if ((argc < 2)) {
    return 0;
  }
  return rt_scan_argv_emit(argc, argv, 1);
}
void driver_compile_argv_set_use_lto_c(struct RtEmitFlagsState * state) {
  if ((state ==((struct RtEmitFlagsState *)(0)))) {
    return;
  }
  (void)(((state->use_lto) = 1));
}
void driver_compile_argv_set_print_target_cpu_c(struct RtEmitFlagsState * state) {
  if ((state ==((struct RtEmitFlagsState *)(0)))) {
    return;
  }
  (void)(((state->print_target_cpu) = 1));
}
