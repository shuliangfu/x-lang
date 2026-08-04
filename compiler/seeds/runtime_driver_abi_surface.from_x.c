/* seeds/runtime_driver_abi_surface.from_x.c
 * G-02f runtime_driver_abi R2 mixed surface - isomorphic with src/runtime_driver_abi.x
 * Product PREFER_X_O: xlang_asm -E(.x) -> full.o (this surface mirrors the public symbol face)
 * Prove: full.x vs this surface -> nm IDENTICAL (61 symbols)
 * Mode: mixed - 54 DIRECT compute + 7 thin+rest forwards to _impl / host bridges
 * Cap residual: 39 extern bridges (link_abi_getenv host getenv,
 *     9 driver_*_flag_slot, driver_current_dep_path_store/load,
 *     driver_print_check_ok_impl, driver_compile_phase_timing_begin/end/flush_impl,
 *     xlang_driver_wall_clock_sec, xlang_read_file_into_path,
 *     driver_pipeline_fail_code_rc_impl/path_impl,
 *     xlang_driver_run_thread_on_large_stack_pthread, xlang_driver_call_fn_void_arg,
 *     bootstrap_nostdlib_pthread_is_stub, driver_get_module_num_funcs,
 *     driver_get_module_main_func_index, driver_print_x_smoke_parse_ok_impl,
 *     driver_print_x_smoke_parse_empty_impl, driver_print_x_smoke_typeck_ok_impl,
 *     xlang_driver_path_read_preprocess_malloc, driver_path_last_preprocess_len,
 *     driver_pipeline_entry_source_len_store/load_and_maybe_debug,
 *     xlang_driver_bump_stack_limit, driver_argv_at, driver_defines_set_at,
 *     xlang_cstr_offset, driver_os_define_lit, xlang_driver_argv_append_uname,
 *     driver_large_stack_thread_trampoline_impl, free from libc).
 * doc_anchor: none (runtime_driver_abi.x does not declare a doc_anchor function).
 * Logic: 61 functions = 54 DIRECT compute
 *   + 7 thin+rest forwards (driver_print_check_ok,
 *      driver_compile_phase_timing_begin, driver_compile_phase_timing_end,
 *      driver_compile_phase_timing_flush, driver_pipeline_fail_code,
 *      driver_print_x_smoke_summary, driver_source_has_top_level_import_path).
 *   Note: runtime_driver_abi.x is the full variant; the thin variant
 *   runtime_driver_abi_thin.x is registered as the driver_abi module.
 * Regen: xlang_asm -E src/runtime_driver_abi.x | filter DBG + polish prologue
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
/* Forward declarations for all 61 surface functions (nm IDENTICAL targets). */
extern int32_t driver_check_quiet_ok_get(void);
extern int32_t driver_typeck_force_c_enabled(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern int32_t driver_asm_entry_emit_heavy(void);
extern int32_t driver_asm_entry_module_only_from_env(void);
extern int32_t driver_asm_parse_metric_only_from_env(void);
extern void driver_check_only_set(int32_t v);
extern int32_t driver_check_only_get(void);
extern void driver_check_diag_emitted_reset(void);
extern void driver_check_diag_emitted_note(void);
extern int32_t driver_check_diag_emitted_get(void);
extern void driver_freestanding_set(int32_t v);
extern int32_t driver_freestanding_get(void);
extern void driver_sanitize_address_set(int32_t v);
extern int32_t driver_sanitize_address_get(void);
extern void driver_fmt_check_only_set(int32_t v);
extern int32_t driver_fmt_check_only_get(void);
extern int32_t driver_x_pipeline_skip_typeck_get(void);
extern void driver_x_pipeline_skip_typeck_set(int32_t v);
extern int32_t driver_x_pipeline_skip_codegen_get(void);
extern void driver_x_pipeline_skip_codegen_set(int32_t v);
extern void driver_skip_codegen_dep_0_set(int32_t v);
extern int32_t driver_skip_codegen_dep_0_get(void);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t driver_is_large_stack_thread(void);
extern void driver_large_stack_thread_mark(int32_t on);
extern void driver_set_current_dep_path_for_codegen(uint8_t * path);
extern uint8_t * driver_get_current_dep_path_for_codegen(void);
extern void driver_print_check_ok(uint8_t * input_path);
extern int32_t driver_compile_phase_timing_enabled(void);
extern int32_t driver_compile_phase_index_ok(int32_t phase);
extern void driver_compile_phase_timing_begin(int32_t phase);
extern void driver_compile_phase_timing_end(int32_t phase);
extern void driver_compile_phase_timing_flush(void);
extern int32_t driver_peek_source_file(uint8_t * path, uint8_t * content, int64_t cap);
extern void driver_pipeline_fail_code(int32_t rc, uint8_t * path);
extern int32_t driver_pipeline_no_large_stack_env(void);
extern void driver_run_fn_on_current_large_stack(uint8_t * fn, uint8_t * arg);
extern void driver_run_thread_on_large_stack(uint8_t * fn, uint8_t * arg);
extern void driver_run_on_large_stack_pthread(uint8_t * fn, uint8_t * arg);
extern void driver_print_x_smoke_summary(uint8_t * module, int64_t codegen_len);
extern int32_t driver_source_has_top_level_import(uint8_t * src, int64_t src_len);
extern int32_t driver_source_has_top_level_import_path(uint8_t * path);
extern void driver_set_pipeline_entry_source_len(int64_t len);
extern int64_t driver_pipeline_entry_source_len(void);
extern int64_t driver_parse_u32_cstr(uint8_t * s);
extern int64_t driver_stack_limit_want_bytes(void);
extern void driver_bump_stack_limit(void);
extern int32_t driver_argv_is_D_alone(uint8_t * arg);
extern int32_t driver_argv_is_D_inline(uint8_t * arg);
extern int32_t driver_argv_is_target_flag(uint8_t * arg);
extern int32_t driver_argv_is_value_skip_flag(uint8_t * arg);
extern int32_t driver_cstr_contains_bytes(uint8_t * hay, uint8_t n0, uint8_t n1, uint8_t n2, uint8_t n3, uint8_t n4, int32_t nlen);
extern int32_t driver_target_arg_os_kind(uint8_t * target);
extern int32_t driver_argv_collect_defines(int32_t argc, uint8_t * argv, uint8_t * defines, int32_t max_defines);
extern int32_t driver_pipeline_entry_source_len_i32(void);
extern int32_t driver_source_scan_top_level_import(uint8_t * src, int64_t src_len);
extern double compile_phase_now_sec(void);
extern uint8_t * driver_large_stack_thread_trampoline(uint8_t * v);
extern int32_t compile_phase_timing_enabled(void);
extern int32_t driver_ascii_toupper(int32_t c);
/* Cap residual: 39 extern bridges (thin+rest forwards target these + host getenv + libc free). */
extern uint8_t * link_abi_getenv(uint8_t * name);
extern int32_t * driver_check_only_flag_slot(void);
extern int32_t * driver_check_diag_emitted_flag_slot(void);
extern int32_t * driver_freestanding_flag_slot(void);
extern int32_t * driver_sanitize_address_flag_slot(void);
extern int32_t * driver_fmt_check_only_flag_slot(void);
extern int32_t * driver_x_pipeline_skip_typeck_flag_slot(void);
extern int32_t * driver_x_pipeline_skip_codegen_flag_slot(void);
extern int32_t * driver_skip_codegen_dep_0_flag_slot(void);
extern int32_t * driver_large_stack_thread_flag_slot(void);
extern void driver_current_dep_path_store(uint8_t * path);
extern uint8_t * driver_current_dep_path_load(void);
extern void driver_print_check_ok_impl(uint8_t * input_path);
extern void driver_compile_phase_timing_begin_impl(int32_t phase);
extern void driver_compile_phase_timing_end_impl(int32_t phase);
extern void driver_compile_phase_timing_flush_impl(void);
extern double xlang_driver_wall_clock_sec(void);
extern int32_t xlang_read_file_into_path(uint8_t * path, uint8_t * buf, int64_t cap);
extern void driver_pipeline_fail_code_rc_impl(int32_t rc);
extern void driver_pipeline_fail_code_path_impl(uint8_t * path);
extern void xlang_driver_run_thread_on_large_stack_pthread(uint8_t * fn, uint8_t * arg);
extern void xlang_driver_call_fn_void_arg(uint8_t * fn, uint8_t * arg);
extern int32_t bootstrap_nostdlib_pthread_is_stub(void);
extern int32_t driver_get_module_num_funcs(uint8_t * m);
extern int32_t driver_get_module_main_func_index(uint8_t * m);
extern void driver_print_x_smoke_parse_ok_impl(int32_t num_funcs, int32_t main_ix, int64_t codegen_len);
extern void driver_print_x_smoke_parse_empty_impl(void);
extern void driver_print_x_smoke_typeck_ok_impl(void);
extern uint8_t * xlang_driver_path_read_preprocess_malloc(uint8_t * path);
extern int64_t driver_path_last_preprocess_len(void);
extern void driver_pipeline_entry_source_len_store(int64_t len);
extern int64_t driver_pipeline_entry_source_len_load_and_maybe_debug(void);
extern void xlang_driver_bump_stack_limit(int64_t want_bytes);
extern uint8_t * driver_argv_at(uint8_t * argv, int32_t i);
extern void driver_defines_set_at(uint8_t * defines, int32_t i, uint8_t * s);
extern uint8_t * xlang_cstr_offset(uint8_t * s, int32_t off);
extern uint8_t * driver_os_define_lit(int32_t kind);
extern int32_t xlang_driver_argv_append_uname(uint8_t * defines, int32_t ndefines, int32_t max_defines);
extern uint8_t * driver_large_stack_thread_trampoline_impl(uint8_t * v);
int32_t driver_check_quiet_ok_get(void) {
  return 1;
}
int32_t driver_typeck_force_c_enabled(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x54\x59\x50\x45\x43\x4b\x5f\x46\x4f\x52\x43\x45\x5f\x43"));
    if ((e ==0)) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
int32_t driver_asm_build_skip_typeck(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x41\x53\x4d\x5f\x42\x55\x49\x4c\x44\x5f\x53\x4b\x49\x50\x5f\x54\x59\x50\x45\x43\x4b"));
    if ((e ==0)) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
int32_t driver_asm_entry_emit_heavy(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x41\x53\x4d\x5f\x45\x4e\x54\x52\x59\x5f\x45\x4d\x49\x54\x5f\x48\x45\x41\x56\x59"));
    if ((e ==0)) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
int32_t driver_asm_entry_module_only_from_env(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x41\x53\x4d\x5f\x45\x4e\x54\x52\x59\x5f\x4d\x4f\x44\x55\x4c\x45\x5f\x4f\x4e\x4c\x59"));
    if ((e ==0)) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
int32_t driver_asm_parse_metric_only_from_env(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x41\x53\x4d\x5f\x50\x41\x52\x53\x45\x5f\x4d\x45\x54\x52\x49\x43\x5f\x4f\x4e\x4c\x59"));
    if ((e ==0)) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
void driver_check_only_set(int32_t v) {
  {
    int32_t * p = driver_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
}
int32_t driver_check_only_get(void) {
  {
    int32_t * p = driver_check_only_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
void driver_check_diag_emitted_reset(void) {
  {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 0));
  }
}
void driver_check_diag_emitted_note(void) {
  {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 1));
  }
}
int32_t driver_check_diag_emitted_get(void) {
  {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
void driver_freestanding_set(int32_t v) {
  {
    int32_t * p = driver_freestanding_flag_slot();
    (void)(((p)[0] = v));
  }
}
int32_t driver_freestanding_get(void) {
  {
    int32_t * p = driver_freestanding_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
void driver_sanitize_address_set(int32_t v) {
  {
    int32_t * p = driver_sanitize_address_flag_slot();
    (void)(((p)[0] = v));
  }
}
int32_t driver_sanitize_address_get(void) {
  {
    int32_t * p = driver_sanitize_address_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x53\x41\x4e\x49\x54\x49\x5a\x45\x5f\x41\x44\x44\x52\x45\x53\x53"));
    if ((e ==0)) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
void driver_fmt_check_only_set(int32_t v) {
  {
    int32_t * p = driver_fmt_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
}
int32_t driver_fmt_check_only_get(void) {
  {
    int32_t * p = driver_fmt_check_only_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t driver_x_pipeline_skip_typeck_get(void) {
  {
    int32_t * p = driver_x_pipeline_skip_typeck_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
void driver_x_pipeline_skip_typeck_set(int32_t v) {
  {
    int32_t * p = driver_x_pipeline_skip_typeck_flag_slot();
    (void)(((p)[0] = v));
  }
}
int32_t driver_x_pipeline_skip_codegen_get(void) {
  {
    int32_t * p = driver_x_pipeline_skip_codegen_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
void driver_x_pipeline_skip_codegen_set(int32_t v) {
  {
    int32_t * p = driver_x_pipeline_skip_codegen_flag_slot();
    (void)(((p)[0] = v));
  }
}
void driver_skip_codegen_dep_0_set(int32_t v) {
  {
    int32_t * p = driver_skip_codegen_dep_0_flag_slot();
    (void)(((p)[0] = v));
  }
}
int32_t driver_skip_codegen_dep_0_get(void) {
  {
    int32_t * p = driver_skip_codegen_dep_0_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t driver_typeck_skip_large_entry(void) {
  {
    int32_t len = driver_pipeline_entry_source_len_i32();
    if ((len > 150000)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t driver_is_large_stack_thread(void) {
  {
    int32_t * p = driver_large_stack_thread_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
void driver_large_stack_thread_mark(int32_t on) {
  {
    int32_t * p = driver_large_stack_thread_flag_slot();
    (void)(((p)[0] = on));
  }
}
void driver_set_current_dep_path_for_codegen(uint8_t * path) {
  (void)(driver_current_dep_path_store(path));
}
uint8_t * driver_get_current_dep_path_for_codegen(void) {
  {
    uint8_t * r = driver_current_dep_path_load();
    return r;
  }
  return ((uint8_t *)(0));
}
void driver_print_check_ok(uint8_t * input_path) {
  if ((driver_check_quiet_ok_get() !=0)) {
    return;
  }
  (void)(driver_print_check_ok_impl(input_path));
}
int32_t driver_compile_phase_timing_enabled(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x43\x4f\x4d\x50\x49\x4c\x45\x5f\x50\x48\x41\x53\x45\x5f\x54\x49\x4d\x49\x4e\x47"));
    if ((e ==0)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
int32_t driver_compile_phase_index_ok(int32_t phase) {
  if ((phase < 0)) {
    return 0;
  }
  if ((phase >=3)) {
    return 0;
  }
  return 1;
}
void driver_compile_phase_timing_begin(int32_t phase) {
  if ((driver_compile_phase_timing_enabled() ==0)) {
    return;
  }
  if ((driver_compile_phase_index_ok(phase) ==0)) {
    return;
  }
  (void)(driver_compile_phase_timing_begin_impl(phase));
}
void driver_compile_phase_timing_end(int32_t phase) {
  if ((driver_compile_phase_timing_enabled() ==0)) {
    return;
  }
  if ((driver_compile_phase_index_ok(phase) ==0)) {
    return;
  }
  (void)(driver_compile_phase_timing_end_impl(phase));
}
void driver_compile_phase_timing_flush(void) {
  if ((driver_compile_phase_timing_enabled() ==0)) {
    return;
  }
  (void)(driver_compile_phase_timing_flush_impl());
}
int32_t driver_peek_source_file(uint8_t * path, uint8_t * content, int64_t cap) {
  if ((path ==0)) {
    return -1;
  }
  if ((content ==0)) {
    return -1;
  }
  if ((cap <=1)) {
    return -1;
  }
  {
    int32_t n = xlang_read_file_into_path(path, content, (cap - 1));
    return n;
  }
  return -1;
}
void driver_pipeline_fail_code(int32_t rc, uint8_t * path) {
  (void)(driver_pipeline_fail_code_rc_impl(rc));
  if ((rc !=-7)) {
    return;
  }
  if ((path ==0)) {
    return;
  }
  (void)(driver_pipeline_fail_code_path_impl(path));
}
int32_t driver_pipeline_no_large_stack_env(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x50\x49\x50\x45\x4c\x49\x4e\x45\x5f\x4e\x4f\x5f\x4c\x41\x52\x47\x45\x5f\x53\x54\x41\x43\x4b"));
    if ((e ==0)) {
      return 0;
    }
    if (((e)[0] ==0)) {
      return 0;
    }
    if (((e)[0] ==48)) {
      return 0;
    }
    return 1;
  }
  return 0;
}
void driver_run_fn_on_current_large_stack(uint8_t * fn, uint8_t * arg) {
  if ((fn ==0)) {
    return;
  }
  (void)(driver_large_stack_thread_mark(1));
  (void)(driver_bump_stack_limit());
  (void)(xlang_driver_call_fn_void_arg(fn, arg));
  (void)(driver_large_stack_thread_mark(0));
}
void driver_run_thread_on_large_stack(uint8_t * fn, uint8_t * arg) {
  if ((fn ==0)) {
    return;
  }
  if ((driver_is_large_stack_thread() !=0)) {
    (void)(xlang_driver_call_fn_void_arg(fn, arg));
    return;
  }
  (void)(driver_bump_stack_limit());
  if ((bootstrap_nostdlib_pthread_is_stub() !=0)) {
    (void)(driver_run_fn_on_current_large_stack(fn, arg));
    return;
  }
  if ((driver_pipeline_no_large_stack_env() !=0)) {
    (void)(driver_run_fn_on_current_large_stack(fn, arg));
    return;
  }
  (void)(xlang_driver_run_thread_on_large_stack_pthread(fn, arg));
}
void driver_run_on_large_stack_pthread(uint8_t * fn, uint8_t * arg) {
  if ((fn ==0)) {
    return;
  }
  (void)(driver_run_thread_on_large_stack(fn, arg));
}
void driver_print_x_smoke_summary(uint8_t * module, int64_t codegen_len) {
  if ((module ==0)) {
    return;
  }
  {
    if ((driver_check_diag_emitted_get() !=0)) {
      return;
    }
    int32_t num_funcs = driver_get_module_num_funcs(module);
    int32_t main_ix = driver_get_module_main_func_index(module);
    (void)(driver_print_x_smoke_parse_ok_impl(num_funcs, main_ix, codegen_len));
    if ((num_funcs <=0)) {
      (void)(driver_print_x_smoke_parse_empty_impl());
      return;
    }
    (void)(driver_print_x_smoke_typeck_ok_impl());
  }
}
int32_t driver_source_has_top_level_import(uint8_t * src, int64_t src_len) {
  if ((src ==0)) {
    return 0;
  }
  if ((src_len < 9)) {
    return 0;
  }
  return driver_source_scan_top_level_import(src, src_len);
}
int32_t driver_source_has_top_level_import_path(uint8_t * path) {
  if ((path ==0)) {
    return 0;
  }
  {
    uint8_t * src = xlang_driver_path_read_preprocess_malloc(path);
    if ((src ==0)) {
      return 0;
    }
    int64_t len = driver_path_last_preprocess_len();
    int32_t has = driver_source_has_top_level_import(src, len);
    (void)(free(src));
    return has;
  }
  return 0;
}
void driver_set_pipeline_entry_source_len(int64_t len) {
  (void)(driver_pipeline_entry_source_len_store(len));
}
int64_t driver_pipeline_entry_source_len(void) {
  return driver_pipeline_entry_source_len_load_and_maybe_debug();
  return 0;
}
int64_t driver_parse_u32_cstr(uint8_t * s) {
  if ((s ==0)) {
    return -1;
  }
  {
    if (((s)[0] ==0)) {
      return -1;
    }
    int64_t n = 0;
    int32_t i = 0;
    while ((i < 20)) {
      uint8_t c = (s)[i];
      if ((c ==0)) {
        break;
      }
      if ((c < 48)) {
        return -1;
      }
      if ((c > 57)) {
        return -1;
      }
      int32_t dig = (((int32_t)(c)) - 48);
      (void)((n = ((n * 10) + ((int64_t)(dig)))));
      (void)((i = (i + 1)));
    }
    if ((i ==0)) {
      return -1;
    }
    return n;
  }
  return -1;
}
int64_t driver_stack_limit_want_bytes(void) {
  int64_t def = 536870912;
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x53\x54\x41\x43\x4b\x5f\x4c\x49\x4d\x49\x54\x5f\x4d\x42"));
    if ((e ==0)) {
      return def;
    }
    if (((e)[0] ==0)) {
      return def;
    }
    int64_t mb = driver_parse_u32_cstr(e);
    if ((mb < 64)) {
      return def;
    }
    if ((mb > 8192)) {
      return def;
    }
    return (mb * 1048576);
  }
  return def;
}
void driver_bump_stack_limit(void) {
  int64_t want = driver_stack_limit_want_bytes();
  (void)(xlang_driver_bump_stack_limit(want));
}
int32_t driver_argv_is_D_alone(uint8_t * arg) {
  if ((arg ==0)) {
    return 0;
  }
  if (((arg)[0] !=45)) {
    return 0;
  }
  if (((arg)[1] !=68)) {
    return 0;
  }
  if (((arg)[2] !=0)) {
    return 0;
  }
  return 1;
  return 0;
}
int32_t driver_argv_is_D_inline(uint8_t * arg) {
  if ((arg ==0)) {
    return 0;
  }
  if (((arg)[0] !=45)) {
    return 0;
  }
  if (((arg)[1] !=68)) {
    return 0;
  }
  if (((arg)[2] ==0)) {
    return 0;
  }
  return 1;
  return 0;
}
int32_t driver_argv_is_target_flag(uint8_t * arg) {
  if ((arg ==0)) {
    return 0;
  }
  if (((arg)[0] !=45)) {
    return 0;
  }
  if (((arg)[1] !=116)) {
    return 0;
  }
  if (((arg)[2] !=97)) {
    return 0;
  }
  if (((arg)[3] !=114)) {
    return 0;
  }
  if (((arg)[4] !=103)) {
    return 0;
  }
  if (((arg)[5] !=101)) {
    return 0;
  }
  if (((arg)[6] !=116)) {
    return 0;
  }
  if (((arg)[7] !=0)) {
    return 0;
  }
  return 1;
  return 0;
}
int32_t driver_argv_is_value_skip_flag(uint8_t * arg) {
  if ((arg ==0)) {
    return 0;
  }
  if (((arg)[0] !=45)) {
    return 0;
  }
  if (((arg)[1] ==111)) {
    if (((arg)[2] ==0)) {
      return 1;
    }
  }
  if (((arg)[1] ==76)) {
    if (((arg)[2] ==0)) {
      return 1;
    }
  }
  if (((arg)[1] ==79)) {
    if (((arg)[2] ==0)) {
      return 1;
    }
  }
  if (((arg)[1] ==98)) {
    if (((arg)[2] ==97)) {
      if (((arg)[3] ==99)) {
        if (((arg)[4] ==107)) {
          if (((arg)[5] ==101)) {
            if (((arg)[6] ==110)) {
              if (((arg)[7] ==100)) {
                if (((arg)[8] ==0)) {
                  return 1;
                }
              }
            }
          }
        }
      }
    }
  }
  return 0;
}
int32_t driver_cstr_contains_bytes(uint8_t * hay, uint8_t n0, uint8_t n1, uint8_t n2, uint8_t n3, uint8_t n4, int32_t nlen) {
  if ((hay ==0)) {
    return 0;
  }
  if ((nlen <=0)) {
    return 0;
  }
  {
    int32_t i = 0;
    while ((i < 4096)) {
      if (((hay)[i] ==0)) {
        return 0;
      }
      if (((hay)[i] ==n0)) {
        if ((nlen ==1)) {
          return 1;
        }
        if (((hay)[(i + 1)] ==n1)) {
          if ((nlen ==2)) {
            return 1;
          }
          if (((hay)[(i + 2)] ==n2)) {
            if ((nlen ==3)) {
              return 1;
            }
            if (((hay)[(i + 3)] ==n3)) {
              if ((nlen ==4)) {
                return 1;
              }
              if (((hay)[(i + 4)] ==n4)) {
                return 1;
              }
            }
          }
        }
      }
      (void)((i = (i + 1)));
    }
  }
  return 0;
}
int32_t driver_target_arg_os_kind(uint8_t * target) {
  if ((target ==0)) {
    return 0;
  }
  if ((driver_cstr_contains_bytes(target, 108, 105, 110, 117, 120, 5) !=0)) {
    return 1;
  }
  if ((driver_cstr_contains_bytes(target, 100, 97, 114, 119, 105, 5) !=0)) {
    return 2;
  }
  if ((driver_cstr_contains_bytes(target, 97, 112, 112, 108, 101, 5) !=0)) {
    return 2;
  }
  if ((driver_cstr_contains_bytes(target, 102, 114, 101, 101, 98, 5) !=0)) {
    return 3;
  }
  if ((driver_cstr_contains_bytes(target, 119, 105, 110, 100, 111, 5) !=0)) {
    return 4;
  }
  return 0;
}
int32_t driver_argv_collect_defines(int32_t argc, uint8_t * argv, uint8_t * defines, int32_t max_defines) {
  if ((argv ==0)) {
    return 0;
  }
  if ((defines ==0)) {
    return 0;
  }
  if ((max_defines <=0)) {
    return 0;
  }
  if ((argc <=0)) {
    return 0;
  }
  int32_t ndefines = 0;
  uint8_t * target_arg = 0;
  int32_t i = 1;
  while ((i < argc)) {
    {
      uint8_t * arg = driver_argv_at(argv, i);
      if ((arg ==0)) {
        (void)((i = (i + 1)));
      } else {
        if ((driver_argv_is_D_alone(arg) !=0)) {
          if (((i + 1) >=argc)) {
            (void)((i = (i + 1)));
          } else {
            uint8_t * v = driver_argv_at(argv, (i + 1));
            if ((v !=0)) {
              if ((ndefines < max_defines)) {
                (void)(driver_defines_set_at(defines, ndefines, v));
                (void)((ndefines = (ndefines + 1)));
              }
            }
            (void)((i = (i + 2)));
          }
        } else {
          if ((driver_argv_is_D_inline(arg) !=0)) {
            uint8_t * def = xlang_cstr_offset(arg, 2);
            if ((def !=0)) {
              if ((ndefines < max_defines)) {
                (void)(driver_defines_set_at(defines, ndefines, def));
                (void)((ndefines = (ndefines + 1)));
              }
            }
            (void)((i = (i + 1)));
          } else {
            if ((driver_argv_is_target_flag(arg) !=0)) {
              if (((i + 1) < argc)) {
                (void)((target_arg = driver_argv_at(argv, (i + 1))));
                (void)((i = (i +2)));
              } else {
                (void)((i = (i + 1)));
              }
            } else {
              if ((driver_argv_is_value_skip_flag(arg) !=0)) {
                if (((i + 1) < argc)) {
                  (void)((i = (i + 2)));
                } else {
                  (void)((i = (i + 1)));
                }
              } else {
                (void)((i = (i + 1)));
              }
            }
          }
        }
      }
    }
  }
  if ((target_arg !=0)) {
    if ((ndefines < max_defines)) {
      int32_t k = driver_target_arg_os_kind(target_arg);
      if ((k !=0)) {
        {
          uint8_t * lit = driver_os_define_lit(k);
          if ((lit !=0)) {
            (void)(driver_defines_set_at(defines, ndefines, lit));
            (void)((ndefines = (ndefines + 1)));
          }
        }
      }
    }
  }
  if (((ndefines + 2) <=max_defines)) {
    (void)((ndefines = xlang_driver_argv_append_uname(defines, ndefines, max_defines)));
  }
  return ndefines;
}
int32_t driver_pipeline_entry_source_len_i32(void) {
  {
    int64_t len = driver_pipeline_entry_source_len_load_and_maybe_debug();
    if ((len > 2147483647)) {
      return 2147483647;
    }
    if ((len < 0)) {
      return 0;
    }
    return ((int32_t)(len));
  }
  return 0;
}
int32_t driver_source_scan_top_level_import(uint8_t * src, int64_t src_len) {
  if ((src ==0)) {
    return 0;
  }
  if ((src_len < 8)) {
    return 0;
  }
  {
    int64_t i = 0;
    while (((i + 8) <=src_len)) {
      if (((src)[i] ==105)) {
        if (((src)[(i + 1)] ==109)) {
          if (((src)[(i + 2)] ==112)) {
            if (((src)[(i + 3)] ==111)) {
              if (((src)[(i + 4)] ==114)) {
                if (((src)[(i + 5)] ==116)) {
                  if (((src)[(i + 6)] ==40)) {
                    if (((src)[(i + 7)] ==34)) {
                      return 1;
                    }
                  }
                }
              }
            }
          }
        }
      }
      if (((i + 9) <=src_len)) {
        if (((src)[i] ==61)) {
          if (((src)[(i + 1)] ==32)) {
            if (((src)[(i + 2)] ==105)) {
              if (((src)[(i + 3)] ==109)) {
                if (((src)[(i + 4)] ==112)) {
                  if (((src)[(i + 5)] ==111)) {
                    if (((src)[(i + 6)] ==114)) {
                      if (((src)[(i + 7)] ==116)) {
                        if (((src)[(i + 8)] ==40)) {
                          return 1;
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
      (void)((i = (i + 1)));
    }
  }
  return 0;
}
double compile_phase_now_sec(void) {
  return xlang_driver_wall_clock_sec();
  return 0.0;
}
uint8_t * driver_large_stack_thread_trampoline(uint8_t * v) {
  if ((v ==0)) {
    return ((uint8_t *)(0));
  }
  return driver_large_stack_thread_trampoline_impl(v);
  return ((uint8_t *)(0));
}
int32_t compile_phase_timing_enabled(void) {
  {
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x43\x4f\x4d\x50\x49\x4c\x45\x5f\x50\x48\x41\x53\x45\x5f\x54\x49\x4d\x49\x4e\x47"));
    if ((e !=0)) {
      return 1;
    }
  }
  return 0;
}
int32_t driver_ascii_toupper(int32_t c) {
  if ((c >=97)) {
    if ((c <=122)) {
      return (c - 32);
    }
  }
  return c;
}
