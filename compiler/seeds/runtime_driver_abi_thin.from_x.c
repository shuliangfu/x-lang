/* seeds/runtime_driver_abi_thin.from_x.c
 * G-02f runtime_driver_abi L2 thin surface — isomorphic with src/runtime_driver_abi_thin.x
 * Product PREFER_X_O: g05_try_x_to_o(thin.x) + full seed rest (-DSHUX_L2_RDABI_THIN_FROM_X) ld -r
 * Cold full seed: seeds/runtime_driver_abi.from_x.c (unchanged)
 * Prove: thin.x vs this seed → nm IDENTICAL (public surface; _impl are U)
 * Regen: ./shux-c -E ... src/runtime_driver_abi_thin.x | filter DBG + polish externs
 */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
extern int32_t * driver_check_only_flag_slot(void);
extern int32_t * driver_check_diag_emitted_flag_slot(void);
extern int32_t * driver_freestanding_flag_slot(void);
extern int32_t * driver_sanitize_address_flag_slot(void);
extern int32_t * driver_fmt_check_only_flag_slot(void);
extern int32_t * driver_x_pipeline_skip_typeck_flag_slot(void);
extern int32_t * driver_x_pipeline_skip_codegen_flag_slot(void);
extern int32_t * driver_skip_codegen_dep_0_flag_slot(void);
extern int32_t * driver_large_stack_thread_flag_slot(void);
extern uint8_t * driver_path_read_preprocess_malloc(uint8_t * path);
extern void driver_fmt_check_only_set(int32_t v);
extern void driver_large_stack_thread_mark(int32_t on);
extern int32_t driver_is_large_stack_thread(void);
extern void driver_check_only_set(int32_t v);
extern int32_t driver_skip_codegen_dep_0_get(void);
extern int32_t driver_x_pipeline_skip_typeck_get(void);
extern int32_t driver_freestanding_get(void);
extern int32_t driver_check_only_get(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t * path);
extern void driver_current_dep_path_store(uint8_t * path);
extern uint8_t * driver_current_dep_path_load(void);
extern void driver_pipeline_entry_source_len_store(int64_t len);
extern int32_t driver_target_arg_os_kind(uint8_t * target);
extern void driver_x_pipeline_skip_typeck_set(int32_t v);
extern void driver_x_pipeline_skip_codegen_set(int32_t v);
extern void driver_sanitize_address_set(int32_t v);
extern int32_t driver_x_pipeline_skip_codegen_get(void);
extern void driver_skip_codegen_dep_0_set(int32_t v);
extern void driver_freestanding_set(int32_t v);
extern void driver_check_diag_emitted_note(void);
extern void driver_check_diag_emitted_reset(void);
extern int32_t driver_fmt_check_only_get(void);
extern int32_t driver_check_diag_emitted_get(void);
extern void driver_print_check_ok(uint8_t * input_path);
extern double compile_phase_now_sec(void);
extern void driver_run_fn_on_current_large_stack(uint8_t * fn, uint8_t * arg);
extern int32_t driver_compile_phase_index_ok(int32_t phase);
extern int32_t driver_compile_phase_timing_enabled(void);
extern void driver_compile_phase_timing_begin(int32_t phase);
extern void driver_compile_phase_timing_end(int32_t phase);
extern void driver_compile_phase_timing_flush(void);
extern int32_t driver_ascii_toupper(int32_t c);
extern int32_t driver_typeck_skip_large_entry(void);
extern int32_t driver_sanitize_address_get(void);
extern int32_t driver_typeck_force_c_enabled(void);
extern int32_t driver_asm_build_skip_typeck(void);
extern int32_t driver_asm_entry_emit_heavy(void);
extern int32_t driver_pipeline_no_large_stack_env(void);
extern int32_t driver_asm_entry_module_only_from_env(void);
extern int32_t driver_asm_parse_metric_only_from_env(void);
extern int32_t driver_pipeline_entry_source_len_i32(void);
extern void driver_defines_set_at(uint8_t * defines, int32_t i, uint8_t * s);
extern int64_t driver_stack_limit_want_bytes(void);
extern int64_t driver_path_last_preprocess_len(void);
extern void driver_bump_stack_limit(void);
extern void driver_set_pipeline_entry_source_len(int64_t len);
extern int32_t compile_phase_timing_enabled(void);
extern uint8_t * driver_os_define_lit(int32_t kind);
extern void driver_pipeline_fail_code(int32_t rc, uint8_t * path);
extern void driver_print_x_smoke_summary(uint8_t * module, int64_t codegen_len);
extern int32_t driver_peek_source_file(uint8_t * path, uint8_t * content, int64_t cap);
extern uint8_t * driver_get_current_dep_path_for_codegen(void);
extern int32_t driver_argv_collect_defines(int32_t argc, uint8_t * argv, uint8_t * defines, int32_t max_defines);
extern int32_t driver_source_scan_top_level_import(uint8_t * src, int64_t src_len);
extern int32_t driver_source_has_top_level_import(uint8_t * src, int64_t src_len);
extern int32_t driver_source_has_top_level_import_path(uint8_t * path);
extern void driver_run_thread_on_large_stack(uint8_t * fn, uint8_t * arg);
extern void driver_run_on_large_stack_pthread(uint8_t * fn, uint8_t * arg);
extern int64_t driver_pipeline_entry_source_len_load_and_maybe_debug(void);
extern int64_t driver_pipeline_entry_source_len(void);
extern int32_t * driver_check_only_flag_slot_impl(void);
extern int32_t * driver_check_diag_emitted_flag_slot_impl(void);
extern int32_t * driver_freestanding_flag_slot_impl(void);
extern int32_t * driver_sanitize_address_flag_slot_impl(void);
extern int32_t * driver_fmt_check_only_flag_slot_impl(void);
extern int32_t * driver_x_pipeline_skip_typeck_flag_slot_impl(void);
extern int32_t * driver_x_pipeline_skip_codegen_flag_slot_impl(void);
extern int32_t * driver_skip_codegen_dep_0_flag_slot_impl(void);
extern int32_t * driver_large_stack_thread_flag_slot_impl(void);
extern uint8_t * driver_path_read_preprocess_malloc_impl(uint8_t * path);
extern void driver_current_dep_path_store_impl(uint8_t * path);
extern uint8_t * driver_current_dep_path_load_impl(void);
extern void driver_pipeline_entry_source_len_store_impl(int64_t len);
extern int32_t driver_target_arg_os_kind_impl(uint8_t * target);
extern int32_t driver_pipeline_entry_source_len_i32_impl(void);
extern int32_t driver_sanitize_address_env_enabled_impl(void);
extern int32_t driver_check_quiet_ok_get(void);
int32_t * driver_check_only_flag_slot(void) {
  {
    return driver_check_only_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_check_diag_emitted_flag_slot(void) {
  {
    return driver_check_diag_emitted_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_freestanding_flag_slot(void) {
  {
    return driver_freestanding_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_sanitize_address_flag_slot(void) {
  {
    return driver_sanitize_address_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_fmt_check_only_flag_slot(void) {
  {
    return driver_fmt_check_only_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_x_pipeline_skip_typeck_flag_slot(void) {
  {
    return driver_x_pipeline_skip_typeck_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_x_pipeline_skip_codegen_flag_slot(void) {
  {
    return driver_x_pipeline_skip_codegen_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_skip_codegen_dep_0_flag_slot(void) {
  {
    return driver_skip_codegen_dep_0_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
int32_t * driver_large_stack_thread_flag_slot(void) {
  {
    return driver_large_stack_thread_flag_slot_impl();
  }
  return ((int32_t *)(0));
}
uint8_t * driver_path_read_preprocess_malloc(uint8_t * path) {
  {
    return driver_path_read_preprocess_malloc_impl(path);
  }
  return ((uint8_t *)(0));
}
void driver_fmt_check_only_set(int32_t v) {
  {
    int32_t * p = driver_fmt_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
  (void)(0);
  return;
}
void driver_large_stack_thread_mark(int32_t on) {
  {
    int32_t * p = driver_large_stack_thread_flag_slot();
    (void)(((p)[0] = on));
  }
  (void)(0);
  return;
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
void driver_check_only_set(int32_t v) {
  {
    int32_t * p = driver_check_only_flag_slot();
    (void)(((p)[0] = v));
  }
  (void)(0);
  return;
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
void driver_set_current_dep_path_for_codegen(uint8_t * path) {
  {
    (void)(driver_current_dep_path_store_impl(path));
  }
  (void)(0);
  return;
}
void driver_current_dep_path_store(uint8_t * path) {
  {
    (void)(driver_current_dep_path_store_impl(path));
  }
  (void)(0);
  return;
}
uint8_t * driver_current_dep_path_load(void) {
  {
    return driver_current_dep_path_load_impl();
  }
  return ((uint8_t *)(0));
}
void driver_pipeline_entry_source_len_store(int64_t len) {
  {
    (void)(driver_pipeline_entry_source_len_store_impl(len));
  }
  (void)(0);
  return;
}
int32_t driver_target_arg_os_kind(uint8_t * target) {
  {
    return driver_target_arg_os_kind_impl(target);
  }
  return 0;
}
void driver_x_pipeline_skip_typeck_set(int32_t v) {
  {
    int32_t * p = driver_x_pipeline_skip_typeck_flag_slot();
    (void)(((p)[0] = v));
  }
  (void)(0);
  return;
}
void driver_x_pipeline_skip_codegen_set(int32_t v) {
  {
    int32_t * p = driver_x_pipeline_skip_codegen_flag_slot();
    (void)(((p)[0] = v));
  }
  (void)(0);
  return;
}
void driver_sanitize_address_set(int32_t v) {
  {
    int32_t * p = driver_sanitize_address_flag_slot();
    (void)(((p)[0] = v));
  }
  (void)(0);
  return;
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
void driver_skip_codegen_dep_0_set(int32_t v) {
  {
    int32_t * p = driver_skip_codegen_dep_0_flag_slot();
    (void)(((p)[0] = v));
  }
  (void)(0);
  return;
}
void driver_freestanding_set(int32_t v) {
  {
    int32_t * p = driver_freestanding_flag_slot();
    (void)(((p)[0] = v));
  }
  (void)(0);
  return;
}
void driver_check_diag_emitted_note(void) {
  {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 1));
  }
  (void)(0);
  return;
}
void driver_check_diag_emitted_reset(void) {
  {
    int32_t * p = driver_check_diag_emitted_flag_slot();
    (void)(((p)[0] = 0));
  }
  (void)(0);
  return;
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
extern void driver_print_check_ok_impl(uint8_t * input_path);
extern double compile_phase_now_sec_impl(void);
extern void driver_call_fn_void_arg_impl(uint8_t * fn, uint8_t * arg);
void driver_print_check_ok(uint8_t * input_path) {
  {
    if ((driver_check_quiet_ok_get() !=0)) {
      return;
    }
    (void)(driver_print_check_ok_impl(input_path));
  }
  (void)(0);
  return;
}
double compile_phase_now_sec(void) {
  {
    return compile_phase_now_sec_impl();
  }
  return 0.0;
}
void driver_run_fn_on_current_large_stack(uint8_t * fn, uint8_t * arg) {
  {
    (void)(driver_call_fn_void_arg_impl(fn, arg));
  }
  (void)(0);
  return;
}
extern void driver_compile_phase_timing_begin_impl(int32_t phase);
extern void driver_compile_phase_timing_end_impl(int32_t phase);
extern void driver_compile_phase_timing_flush_impl(void);
extern int32_t driver_compile_phase_timing_enabled_impl(void);
int32_t driver_compile_phase_index_ok(int32_t phase) {
  if ((phase < 0)) {
    return 0;
  }
  if ((phase >=3)) {
    return 0;
  }
  return 1;
}
int32_t driver_compile_phase_timing_enabled(void) {
  {
    return driver_compile_phase_timing_enabled_impl();
  }
  return 0;
}
void driver_compile_phase_timing_begin(int32_t phase) {
  {
    if ((driver_compile_phase_timing_enabled_impl() ==0)) {
      return;
    }
    if ((driver_compile_phase_index_ok(phase) ==0)) {
      return;
    }
    (void)(driver_compile_phase_timing_begin_impl(phase));
  }
  (void)(0);
  return;
}
void driver_compile_phase_timing_end(int32_t phase) {
  {
    if ((driver_compile_phase_timing_enabled_impl() ==0)) {
      return;
    }
    if ((driver_compile_phase_index_ok(phase) ==0)) {
      return;
    }
    (void)(driver_compile_phase_timing_end_impl(phase));
  }
  (void)(0);
  return;
}
void driver_compile_phase_timing_flush(void) {
  {
    if ((driver_compile_phase_timing_enabled_impl() ==0)) {
      return;
    }
    (void)(driver_compile_phase_timing_flush_impl());
  }
  (void)(0);
  return;
}
int32_t driver_ascii_toupper(int32_t c) {
  if ((c < 97)) {
    return c;
  }
  if ((c > 122)) {
    return c;
  }
  return (c - 32);
}
int32_t driver_typeck_skip_large_entry(void) {
  {
    int32_t len = driver_pipeline_entry_source_len_i32_impl();
    if ((len > 150000)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t driver_sanitize_address_get(void) {
  {
    int32_t * p = driver_sanitize_address_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return driver_sanitize_address_env_enabled_impl();
  }
  return 0;
}
extern int32_t driver_typeck_force_c_enabled_impl(void);
extern int32_t driver_asm_build_skip_typeck_impl(void);
extern int32_t driver_asm_entry_emit_heavy_impl(void);
extern int32_t driver_pipeline_no_large_stack_env_impl(void);
int32_t driver_typeck_force_c_enabled(void) {
  {
    return driver_typeck_force_c_enabled_impl();
  }
  return 0;
}
int32_t driver_asm_build_skip_typeck(void) {
  {
    return driver_asm_build_skip_typeck_impl();
  }
  return 0;
}
int32_t driver_asm_entry_emit_heavy(void) {
  {
    return driver_asm_entry_emit_heavy_impl();
  }
  return 0;
}
int32_t driver_pipeline_no_large_stack_env(void) {
  {
    return driver_pipeline_no_large_stack_env_impl();
  }
  return 0;
}
extern int32_t driver_asm_entry_module_only_from_env_impl(void);
extern int32_t driver_asm_parse_metric_only_from_env_impl(void);
int32_t driver_asm_entry_module_only_from_env(void) {
  {
    return driver_asm_entry_module_only_from_env_impl();
  }
  return 0;
}
int32_t driver_asm_parse_metric_only_from_env(void) {
  {
    return driver_asm_parse_metric_only_from_env_impl();
  }
  return 0;
}
int32_t driver_pipeline_entry_source_len_i32(void) {
  {
    return driver_pipeline_entry_source_len_i32_impl();
  }
  return 0;
}
extern void driver_defines_set_at_impl(uint8_t * defines, int32_t i, uint8_t * s);
extern int64_t driver_stack_limit_want_bytes_impl(void);
extern int64_t driver_path_last_preprocess_len_impl(void);
void driver_defines_set_at(uint8_t * defines, int32_t i, uint8_t * s) {
  {
    (void)(driver_defines_set_at_impl(defines, i, s));
  }
  (void)(0);
  return;
}
int64_t driver_stack_limit_want_bytes(void) {
  {
    return driver_stack_limit_want_bytes_impl();
  }
  return 0;
}
int64_t driver_path_last_preprocess_len(void) {
  {
    return driver_path_last_preprocess_len_impl();
  }
  return 0;
}
extern void driver_bump_stack_limit_to_impl(int64_t want_bytes);
extern int32_t compile_phase_timing_enabled_impl(void);
extern uint8_t * driver_os_define_lit_impl(int32_t kind);
void driver_bump_stack_limit(void) {
  {
    (void)(driver_bump_stack_limit_to_impl(driver_stack_limit_want_bytes_impl()));
  }
  (void)(0);
  return;
}
void driver_set_pipeline_entry_source_len(int64_t len) {
  {
    (void)(driver_pipeline_entry_source_len_store_impl(len));
  }
  (void)(0);
  return;
}
int32_t compile_phase_timing_enabled(void) {
  {
    return compile_phase_timing_enabled_impl();
  }
  return 0;
}
uint8_t * driver_os_define_lit(int32_t kind) {
  {
    return driver_os_define_lit_impl(kind);
  }
  return ((uint8_t *)(0));
}
extern void driver_pipeline_fail_code_impl(int32_t rc, uint8_t * path);
extern void driver_print_x_smoke_summary_impl(uint8_t * module, int64_t codegen_len);
extern int32_t driver_peek_source_file_impl(uint8_t * path, uint8_t * content, int64_t cap);
extern uint8_t * driver_get_current_dep_path_for_codegen_impl(void);
extern int32_t driver_argv_collect_defines_impl(int32_t argc, uint8_t * argv, uint8_t * defines, int32_t max_defines);
void driver_pipeline_fail_code(int32_t rc, uint8_t * path) {
  {
    (void)(driver_pipeline_fail_code_impl(rc, path));
  }
  (void)(0);
  return;
}
void driver_print_x_smoke_summary(uint8_t * module, int64_t codegen_len) {
  {
    (void)(driver_print_x_smoke_summary_impl(module, codegen_len));
  }
  (void)(0);
  return;
}
int32_t driver_peek_source_file(uint8_t * path, uint8_t * content, int64_t cap) {
  {
    return driver_peek_source_file_impl(path, content, cap);
  }
  return (0 - 1);
}
uint8_t * driver_get_current_dep_path_for_codegen(void) {
  {
    return driver_get_current_dep_path_for_codegen_impl();
  }
  return ((uint8_t *)(0));
}
int32_t driver_argv_collect_defines(int32_t argc, uint8_t * argv, uint8_t * defines, int32_t max_defines) {
  {
    return driver_argv_collect_defines_impl(argc, argv, defines, max_defines);
  }
  return 0;
}
extern int32_t driver_source_scan_top_level_import_impl(uint8_t * src, int64_t src_len);
extern int32_t driver_source_has_top_level_import_impl(uint8_t * src, int64_t src_len);
extern int32_t driver_source_has_top_level_import_path_impl(uint8_t * path);
extern void driver_run_thread_on_large_stack_impl(uint8_t * fn, uint8_t * arg);
extern void driver_run_on_large_stack_pthread_impl(uint8_t * fn, uint8_t * arg);
int32_t driver_source_scan_top_level_import(uint8_t * src, int64_t src_len) {
  {
    return driver_source_scan_top_level_import_impl(src, src_len);
  }
  return 0;
}
int32_t driver_source_has_top_level_import(uint8_t * src, int64_t src_len) {
  {
    return driver_source_has_top_level_import_impl(src, src_len);
  }
  return 0;
}
int32_t driver_source_has_top_level_import_path(uint8_t * path) {
  {
    return driver_source_has_top_level_import_path_impl(path);
  }
  return 0;
}
void driver_run_thread_on_large_stack(uint8_t * fn, uint8_t * arg) {
  {
    (void)(driver_run_thread_on_large_stack_impl(fn, arg));
  }
  (void)(0);
  return;
}
void driver_run_on_large_stack_pthread(uint8_t * fn, uint8_t * arg) {
  {
    (void)(driver_run_on_large_stack_pthread_impl(fn, arg));
  }
  (void)(0);
  return;
}
extern int64_t driver_pipeline_entry_source_len_load_and_maybe_debug_impl(void);
extern int64_t driver_pipeline_entry_source_len_impl(void);
int64_t driver_pipeline_entry_source_len_load_and_maybe_debug(void) {
  {
    return driver_pipeline_entry_source_len_load_and_maybe_debug_impl();
  }
  return 0;
}
int64_t driver_pipeline_entry_source_len(void) {
  {
    return driver_pipeline_entry_source_len_impl();
  }
  return 0;
}
