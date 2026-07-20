/* seeds/rt_dispatch_impl_surface.from_x.c
 * R2 full surface — isomorphic with src/runtime/rt_dispatch_impl.x
 * Product PREFER_X_O: full .x + hybrid rest seed (FROM_X 仅 marker)
 * Cap residual: driver_dispatch_* in driver_abi
 * Prove: full.x vs this seed → nm IDENTICAL
 * Regen: ./shux -E ... | filter DBG + polish libc redecls
 * Track-L (2026-07-16): helpers rt_di_env_shux_lto / rt_di_argv_has_e_extern /
 * rt_di_effective_use_lto keep short names; .x has #[no_mangle] export
 * (was module-prefix mangle on non-export functions).
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
struct RtDispatchState {
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

extern uint8_t * rt_di_env_shux_lto(void);
extern int32_t rt_di_argv_has_e_extern(int32_t argc, uint8_t * argv);
extern int32_t rt_di_effective_use_lto(int32_t use_lto);
extern int32_t driver_run_asm_backend_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv);
extern int32_t driver_run_emit_c_path_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv);
extern int32_t driver_run_x_emit_c_from_compile_state(struct RtDispatchState * state, int32_t argc, uint8_t * argv);
extern int32_t driver_run_compiler_full_x_post_parse_impl_c(struct RtDispatchState * state, int32_t argc, uint8_t * argv);
extern int32_t driver_run_compiler_full_x_impl_c(int32_t argc, uint8_t * argv);
extern int32_t driver_get_argv_i(int32_t argc, uint8_t * argv, int32_t i, uint8_t * buf, int32_t max);
extern void driver_set_pending_target_cpu_features(uint32_t features);
extern int32_t driver_run_asm_backend(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_roots, int32_t n_lib, uint8_t * target, int32_t argc, uint8_t * argv);
extern int32_t driver_check_only_get(void);
extern int32_t driver_source_has_top_level_import_path(uint8_t * path);
extern int32_t driver_asm_entry_module_only_from_env(void);
extern int32_t driver_argv_has_emit_c_flag(int32_t argc, uint8_t * argv);
extern int32_t driver_asm_output_want_exe(uint8_t * path);
extern int32_t driver_source_has_generic_syntax(uint8_t * path, int32_t path_len);
extern void driver_freestanding_set(int32_t v);
extern void cfg_set_freestanding(int32_t v);
extern int32_t driver_run_x_emit_c_set_emit_extern(int32_t v);
extern int32_t driver_run_x_emit_c_set_path(uint8_t * path, int32_t path_len);
extern int32_t driver_run_x_emit_c_set_lib(int32_t i, uint8_t * buf, int32_t len);
extern int32_t driver_run_x_emit_c_set_n_lib_roots(int32_t n);
extern int32_t driver_run_x_emit_c(void);
extern int32_t runtime_try_handle_explain_cli(int32_t argc, uint8_t * argv);
extern int32_t driver_compile_argv_is_help_c(int32_t argc, uint8_t * argv);
extern void driver_print_usage_c(void);
extern void driver_bump_stack_limit(void);
extern struct RtDispatchState * driver_compile_state_alloc_c(void);
extern void driver_compile_state_free_c(struct RtDispatchState * state);
extern int32_t driver_compile_parse_argv_impl_c(int32_t argc, uint8_t * argv, struct RtDispatchState * state);
extern void shu_target_cpu_print(uint8_t * out, uint32_t features);
extern uint8_t * driver_stdio_stdout(void);
extern uint8_t * driver_dispatch_lib_roots_from_key(uint8_t * lib_key, int32_t * n_out);
extern uint8_t * driver_dispatch_lib_root_at(uint8_t * roots, int32_t i);
extern int32_t driver_dispatch_run_compiler_parsed(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_roots, int32_t n_lib, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv);
extern uint8_t * driver_dispatch_opt_default(void);
uint8_t * rt_di_env_shux_lto(void) {
  uint8_t * p = ((uint8_t *)(0));
  {
    (void)((p = malloc(((size_t)(16)))));
  }
  if ((p ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  (void)(((p)[0] = 83));
  (void)(((p)[1] = 72));
  (void)(((p)[2] = 85));
  (void)(((p)[3] = 88));
  (void)(((p)[4] = 95));
  (void)(((p)[5] = 76));
  (void)(((p)[6] = 84));
  (void)(((p)[7] = 79));
  (void)(((p)[8] = 0));
  return p;
}
int32_t rt_di_argv_has_e_extern(int32_t argc, uint8_t * argv) {
  int32_t k = 1;
  uint8_t * buf = ((uint8_t *)(0));
  int32_t n = 0;
  {
    (void)((buf = malloc(((size_t)(32)))));
  }
  if ((buf ==((uint8_t *)(0)))) {
    return 0;
  }
  while ((k < argc)) {
    {
      (void)((n = driver_get_argv_i(argc, argv, k, buf, 31)));
    }
    if ((n ==9)) {
      if (((((((((((buf)[0] ==45) && ((buf)[1] ==69)) && ((buf)[2] ==45)) && ((buf)[3] ==101)) && ((buf)[4] ==120)) && ((buf)[5] ==116)) && ((buf)[6] ==101)) && ((buf)[7] ==114)) && ((buf)[8] ==110))) {
        {
          (void)(free(buf));
        }
        return 1;
      }
    }
    (void)((k = (k + 1)));
  }
  {
    (void)(free(buf));
  }
  return 0;
}
int32_t rt_di_effective_use_lto(int32_t use_lto) {
  uint8_t * env_name = ((uint8_t *)(0));
  uint8_t * env_val = ((uint8_t *)(0));
  if ((use_lto !=0)) {
    return 1;
  }
  (void)((env_name = rt_di_env_shux_lto()));
  if ((env_name ==((uint8_t *)(0)))) {
    return 0;
  }
  {
    (void)((env_val = getenv(env_name)));
    (void)(free(env_name));
  }
  if ((env_val ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((((env_val)[0] ==49) && ((env_val)[1] ==0))) {
    return 1;
  }
  return 0;
}
int32_t driver_run_asm_backend_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, int32_t argc, uint8_t * argv) {
  int32_t n = 0;
  uint8_t * roots = ((uint8_t *)(0));
  uint32_t feat = 0;
  uint8_t * tgt = ((uint8_t *)(0));
  {
    (void)((roots = driver_dispatch_lib_roots_from_key(lib_key, &(n))));
  }
  if ((lib_key !=((uint8_t *)(0)))) {
    struct RtDispatchState * st = ((struct RtDispatchState *)(lib_key));
    (void)((feat = ((uint32_t)((st->target_cpu_features)))));
  }
  {
    (void)(driver_set_pending_target_cpu_features(feat));
  }
  if ((target !=((uint8_t *)(0)))) {
    if (((target)[0] !=0)) {
      (void)((tgt = target));
    }
  }
  {
    return driver_run_asm_backend(input_path, out_path, roots, n, tgt, argc, argv);
  }
  return 1;
}
int32_t driver_run_emit_c_path_impl_c(uint8_t * input_path, uint8_t * out_path, uint8_t * lib_key, uint8_t * target, uint8_t * opt_level, int32_t use_lto, int32_t argc, uint8_t * argv) {
  int32_t n = 0;
  uint8_t * roots = ((uint8_t *)(0));
  uint8_t * tgt = ((uint8_t *)(0));
  uint8_t * opt = ((uint8_t *)(0));
  int32_t lto = 0;
  {
    (void)((roots = driver_dispatch_lib_roots_from_key(lib_key, &(n))));
  }
  if ((target !=((uint8_t *)(0)))) {
    if (((target)[0] !=0)) {
      (void)((tgt = target));
    }
  }
  if ((opt_level !=((uint8_t *)(0)))) {
    if (((opt_level)[0] !=0)) {
      (void)((opt = opt_level));
    }
  }
  if ((opt ==((uint8_t *)(0)))) {
    {
      (void)((opt = driver_dispatch_opt_default()));
    }
  }
  (void)((lto = rt_di_effective_use_lto(use_lto)));
  {
    return driver_dispatch_run_compiler_parsed(input_path, out_path, roots, n, tgt, opt, lto, argc, argv);
  }
  return 1;
}
int32_t driver_run_x_emit_c_from_compile_state(struct RtDispatchState * state, int32_t argc, uint8_t * argv) {
  int32_t want_extern = 0;
  int32_t n = 0;
  uint8_t * roots = ((uint8_t *)(0));
  int32_t k = 0;
  uint8_t * row = ((uint8_t *)(0));
  size_t llen = 0;
  uint8_t * dot = ((uint8_t *)(0));
  if ((state ==((struct RtDispatchState *)(0)))) {
    return 1;
  }
  if (((state->path_len) <=0)) {
    return 1;
  }
  (void)((want_extern = rt_di_argv_has_e_extern(argc, argv)));
  {
    (void)(driver_run_x_emit_c_set_emit_extern(want_extern));
    (void)(driver_run_x_emit_c_set_path(&(((state->path_buf))[0]), (state->path_len)));
    (void)((roots = driver_dispatch_lib_roots_from_key(((uint8_t *)(state)), &(n))));
  }
  if ((n <=0)) {
    {
      (void)((dot = malloc(((size_t)(4)))));
    }
    if ((dot ==((uint8_t *)(0)))) {
      return 1;
    }
    (void)(((dot)[0] = 46));
    (void)(((dot)[1] = 0));
    {
      (void)(driver_run_x_emit_c_set_lib(0, dot, 1));
      (void)(driver_run_x_emit_c_set_n_lib_roots(1));
      (void)(free(dot));
    }
  } else {
    (void)((k = 0));
    while ((k < n)) {
      {
        (void)((row = driver_dispatch_lib_root_at(roots, k)));
      }
      if ((row ==((uint8_t *)(0)))) {
        (void)((llen = ((size_t)(0))));
      } else {
        {
          (void)((llen = strlen(row)));
        }
      }
      {
        (void)(driver_run_x_emit_c_set_lib(k, row, ((int32_t)(llen))));
      }
      (void)((k = (k + 1)));
    }
    {
      (void)(driver_run_x_emit_c_set_n_lib_roots(n));
    }
  }
  {
    return driver_run_x_emit_c();
  }
  return 1;
}
int32_t driver_run_compiler_full_x_post_parse_impl_c(struct RtDispatchState * state, int32_t argc, uint8_t * argv) {
  uint8_t * out_ptr = ((uint8_t *)(0));
  uint8_t * target_ptr = ((uint8_t *)(0));
  int32_t want_generic_check = 0;
  int32_t has_import = 0;
  int32_t entry_only = 0;
  if ((state ==((struct RtDispatchState *)(0)))) {
    return 1;
  }
  {
    if ((driver_argv_has_emit_c_flag(argc, argv) !=0)) {
      return driver_run_x_emit_c_from_compile_state(state, argc, argv);
    }
  }
  {
    if ((driver_check_only_get() !=0)) {
      (void)(((state->use_asm_backend) = 0));
    }
  }
  (void)((want_generic_check = 0));
  if (((state->out_path_len) ==0)) {
    (void)((want_generic_check = 1));
  } else {
    {
      if ((driver_asm_output_want_exe(&(((state->out_path_buf))[0])) !=0)) {
        (void)((want_generic_check = 1));
      }
    }
  }
  if (((state->use_asm_backend) !=0)) {
    if ((want_generic_check !=0)) {
      {
        if ((driver_source_has_generic_syntax(&(((state->path_buf))[0]), (state->path_len)) !=0)) {
          (void)(((state->use_asm_backend) = 0));
        }
      }
    }
  }
  if (((state->out_path_len) > 0)) {
    (void)((out_ptr = &(((state->out_path_buf))[0])));
  }
  if (((state->target_len) > 0)) {
    (void)((target_ptr = &(((state->target_buf))[0])));
  }
  if (((state->out_path_len) > 0)) {
    if (((state->backend_asm_explicit) ==0)) {
      {
        (void)((has_import = driver_source_has_top_level_import_path(&(((state->path_buf))[0]))));
      }
      if ((has_import ==0)) {
        (void)(((state->backend_asm_explicit) = 1));
      }
    }
  }
  if (((state->use_asm_backend) !=0)) {
    if (((state->backend_asm_explicit) ==0)) {
      {
        (void)((entry_only = driver_asm_entry_module_only_from_env()));
        (void)((has_import = driver_source_has_top_level_import_path(&(((state->path_buf))[0]))));
      }
      if ((entry_only ==0)) {
        if ((has_import !=0)) {
          (void)(((state->use_asm_backend) = 0));
        }
      }
    }
  }
  if (((state->use_freestanding) !=0)) {
    (void)(((state->use_asm_backend) = 1));
    (void)(((state->backend_asm_explicit) = 1));
    {
      (void)(driver_freestanding_set(1));
      (void)(cfg_set_freestanding(1));
    }
  }
  if (((state->use_asm_backend) !=0)) {
    return driver_run_asm_backend_impl_c(&(((state->path_buf))[0]), out_ptr, ((uint8_t *)(state)), target_ptr, argc, argv);
  }
  return driver_run_emit_c_path_impl_c(&(((state->path_buf))[0]), out_ptr, ((uint8_t *)(state)), target_ptr, &(((state->opt_level_buf))[0]), (state->use_lto), argc, argv);
}
int32_t driver_run_compiler_full_x_impl_c(int32_t argc, uint8_t * argv) {
  struct RtDispatchState * state = ((struct RtDispatchState *)(0));
  int32_t rc = 0;
  int32_t explain_rc = 0;
  uint8_t * out = ((uint8_t *)(0));
  {
    (void)((explain_rc = runtime_try_handle_explain_cli(argc, argv)));
  }
  if ((explain_rc >=0)) {
    return explain_rc;
  }
  {
    if ((driver_compile_argv_is_help_c(argc, argv) !=0)) {
      (void)(driver_print_usage_c());
      return 0;
    }
  }
  if ((argc < 2)) {
    {
      (void)(driver_print_usage_c());
    }
    return 0;
  }
  {
    (void)(driver_bump_stack_limit());
    (void)((state = driver_compile_state_alloc_c()));
  }
  if ((state ==((struct RtDispatchState *)(0)))) {
    return 1;
  }
  {
    if ((driver_compile_parse_argv_impl_c(argc, argv, state) !=0)) {
      (void)(driver_compile_state_free_c(state));
      return 1;
    }
  }
  if (((state->print_target_cpu) !=0)) {
    {
      (void)((out = driver_stdio_stdout()));
      (void)(shu_target_cpu_print(out, ((uint32_t)((state->target_cpu_features)))));
      (void)(driver_compile_state_free_c(state));
    }
    return 0;
  }
  (void)((rc = driver_run_compiler_full_x_post_parse_impl_c(state, argc, argv)));
  {
    (void)(driver_compile_state_free_c(state));
  }
  return rc;
}
