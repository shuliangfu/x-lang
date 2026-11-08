/* Win tip-cold fix: pure-asm driver_run_emit_c_path_impl_c reads argc/argv
 * from 0x10/0x18(%rbp) (rcx/rdx homes = input/out paths) instead of Win64
 * 7th/8th stack slots 0x40/0x48. That feeds pointer-as-argc into
 * driver_dispatch_run_compiler_parsed → asm_collect_defines → SEGV in
 * driver_argv_is_D_alone. Strong T before runtime_driver_no_c.o (first-win).
 * PLATFORM: WINDOWS. */
#include <stdint.h>
#include <stdlib.h>

extern uint8_t *driver_dispatch_lib_roots_from_key(uint8_t *lib_key, int32_t *n_out);
extern uint8_t *driver_dispatch_opt_default(void);
extern int32_t driver_dispatch_run_compiler_parsed(uint8_t *input_path, uint8_t *out_path,
                                                    uint8_t *lib_roots, int32_t n_lib,
                                                    uint8_t *target, uint8_t *opt_level,
                                                    int32_t use_lto, int32_t argc, uint8_t *argv);

/* Match rt_di_effective_use_lto: honor explicit flag; XLANG_LTO=1 also sets. */
static int32_t rt_di_effective_use_lto_win(int32_t use_lto) {
  const char *e;
  if (use_lto != 0) {
    return 1;
  }
  e = getenv("XLANG_LTO");
  if (e && e[0] == '1' && e[1] == '\0') {
    return 1;
  }
  return 0;
}

int32_t driver_run_emit_c_path_impl_c(uint8_t *input_path, uint8_t *out_path, uint8_t *lib_key,
                                      uint8_t *target, uint8_t *opt_level, int32_t use_lto,
                                      int32_t argc, uint8_t *argv) {
  int32_t n = 0;
  uint8_t *roots = 0;
  uint8_t *tgt = 0;
  uint8_t *opt = 0;
  int32_t lto = 0;

  roots = driver_dispatch_lib_roots_from_key(lib_key, &n);
  if (target != 0 && target[0] != 0) {
    tgt = target;
  }
  if (opt_level != 0 && opt_level[0] != 0) {
    opt = opt_level;
  }
  if (opt == 0) {
    opt = driver_dispatch_opt_default();
  }
  lto = rt_di_effective_use_lto_win(use_lto);
  return driver_dispatch_run_compiler_parsed(input_path, out_path, roots, n, tgt, opt, lto, argc,
                                             argv);
}
