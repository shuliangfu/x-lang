/* prove surface: isomorphic to src/runtime_driver_abi_thin.x (g05_try_x_to_o aligned) */
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#ifndef _WIN32
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#endif
extern int32_t driver_env_flag_truthy(uint8_t * name);
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
extern int32_t driver_argv_is_D_alone(uint8_t * arg);
extern int32_t driver_argv_is_D_inline(uint8_t * arg);
extern int32_t driver_argv_is_target_flag(uint8_t * arg);
extern int32_t driver_argv_is_value_skip_flag(uint8_t * arg);
extern int32_t driver_cstr_contains_bytes(uint8_t * hay, uint8_t n0, uint8_t n1, uint8_t n2, uint8_t n3, uint8_t n4, int32_t nlen);
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
int32_t driver_env_flag_truthy(uint8_t * name) {
  {
    uint8_t * e = getenv(name);
    if ((e ==((uint8_t *)(0)))) {
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
extern int32_t driver_check_quiet_ok_get(void);
extern uint8_t * driver_argv_at(uint8_t * argv, int32_t i);
extern uint8_t * shux_cstr_offset(uint8_t * s, int32_t off);
extern int32_t driver_argv_collect_append_uname_impl(uint8_t * defines, int32_t ndefines, int32_t max_defines);
extern void driver_pipeline_fail_code_rc_impl(int32_t rc);
extern void driver_pipeline_fail_code_path_impl(uint8_t * path);
extern void driver_print_x_smoke_parse_ok_impl(int32_t num_funcs, int32_t main_ix, int64_t codegen_len);
extern void driver_print_x_smoke_parse_empty_impl(void);
extern void driver_print_x_smoke_typeck_ok_impl(void);
extern int32_t driver_get_module_num_funcs(uint8_t * m);
extern int32_t driver_get_module_main_func_index(uint8_t * m);
extern int32_t shux_read_file_into_path(uint8_t * path, uint8_t * buf, int64_t cap);
extern int32_t bootstrap_nostdlib_pthread_is_stub(void);
extern void driver_run_thread_on_large_stack_pthread_impl(uint8_t * fn, uint8_t * arg);
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
int32_t driver_argv_is_D_alone(uint8_t * arg) {
  if ((arg ==((uint8_t *)(0)))) {
    return 0;
  }
  {
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
  }
  return 0;
}
int32_t driver_argv_is_D_inline(uint8_t * arg) {
  if ((arg ==((uint8_t *)(0)))) {
    return 0;
  }
  {
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
  }
  return 0;
}
int32_t driver_argv_is_target_flag(uint8_t * arg) {
  if ((arg ==((uint8_t *)(0)))) {
    return 0;
  }
  {
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
  }
  return 0;
}
int32_t driver_argv_is_value_skip_flag(uint8_t * arg) {
  if ((arg ==((uint8_t *)(0)))) {
    return 0;
  }
  {
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
  }
  return 0;
}
int32_t driver_cstr_contains_bytes(uint8_t * hay, uint8_t n0, uint8_t n1, uint8_t n2, uint8_t n3, uint8_t n4, int32_t nlen) {
  if ((hay ==((uint8_t *)(0)))) {
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
  if ((target ==((uint8_t *)(0)))) {
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
  if ((fn ==((uint8_t *)(0)))) {
    return;
  }
  (void)(driver_large_stack_thread_mark(1));
  (void)(driver_bump_stack_limit());
  {
    (void)(driver_call_fn_void_arg_impl(fn, arg));
  }
  (void)(driver_large_stack_thread_mark(0));
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
  int32_t len = driver_pipeline_entry_source_len_i32();
  if ((len > 150000)) {
    return 1;
  }
  return 0;
}
int32_t driver_sanitize_address_get(void) {
  {
    int32_t * p = driver_sanitize_address_flag_slot();
    if (((p)[0] !=0)) {
      return 1;
    }
    return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 83, 65, 78, 73, 84, 73, 90, 69, 95, 65, 68, 68, 82, 69, 83, 83, 0 });
  }
  return 0;
}
int32_t driver_typeck_force_c_enabled(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 84, 89, 80, 69, 67, 75, 95, 70, 79, 82, 67, 69, 95, 67, 0 });
}
int32_t driver_asm_build_skip_typeck(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 65, 83, 77, 95, 66, 85, 73, 76, 68, 95, 83, 75, 73, 80, 95, 84, 89, 80, 69, 67, 75, 0 });
}
int32_t driver_asm_entry_emit_heavy(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 65, 83, 77, 95, 69, 78, 84, 82, 89, 95, 69, 77, 73, 84, 95, 72, 69, 65, 86, 89, 0 });
}
int32_t driver_pipeline_no_large_stack_env(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 80, 73, 80, 69, 76, 73, 78, 69, 95, 78, 79, 95, 76, 65, 82, 71, 69, 95, 83, 84, 65, 67, 75, 0 });
}
int32_t driver_asm_entry_module_only_from_env(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 65, 83, 77, 95, 69, 78, 84, 82, 89, 95, 77, 79, 68, 85, 76, 69, 95, 79, 78, 76, 89, 0 });
}
int32_t driver_asm_parse_metric_only_from_env(void) {
  return driver_env_flag_truthy((uint8_t[]){83, 72, 85, 88, 95, 65, 83, 77, 95, 80, 65, 82, 83, 69, 95, 77, 69, 84, 82, 73, 67, 95, 79, 78, 76, 89, 0 });
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
extern uint8_t * driver_get_current_dep_path_for_codegen_impl(void);
void driver_pipeline_fail_code(int32_t rc, uint8_t * path) {
  {
    (void)(driver_pipeline_fail_code_rc_impl(rc));
    if ((rc !=(0 - 7))) {
      return;
    }
    if ((path ==((uint8_t *)(0)))) {
      return;
    }
    (void)(driver_pipeline_fail_code_path_impl(path));
  }
  (void)(0);
  return;
}
void driver_print_x_smoke_summary(uint8_t * module, int64_t codegen_len) {
  if ((module ==((uint8_t *)(0)))) {
    return;
  }
  {
    int32_t num_funcs = driver_get_module_num_funcs(module);
    int32_t main_ix = driver_get_module_main_func_index(module);
    if ((driver_check_diag_emitted_get() !=0)) {
      return;
    }
    (void)(driver_print_x_smoke_parse_ok_impl(num_funcs, main_ix, codegen_len));
    if ((num_funcs <=0)) {
      (void)(driver_print_x_smoke_parse_empty_impl());
      return;
    }
    (void)(driver_print_x_smoke_typeck_ok_impl());
  }
  (void)(0);
  return;
}
int32_t driver_peek_source_file(uint8_t * path, uint8_t * content, int64_t cap) {
  if ((path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  if ((content ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  if ((cap <=1)) {
    return (0 - 1);
  }
  {
    int32_t n = shux_read_file_into_path(path, content, (cap - 1));
    return n;
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
  if ((argv ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((defines ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((max_defines <=0)) {
    return 0;
  }
  if ((argc <=0)) {
    return 0;
  }
  int32_t ndefines = 0;
  uint8_t * target_arg = ((uint8_t *)(0));
  int32_t i = 1;
  while ((i < argc)) {
    {
      uint8_t * arg = driver_argv_at(argv, i);
      if ((arg ==((uint8_t *)(0)))) {
        (void)((i = (i + 1)));
      } else {
        if ((driver_argv_is_D_alone(arg) !=0)) {
          if (((i + 1) >=argc)) {
            (void)((i = (i + 1)));
          } else {
            uint8_t * v = driver_argv_at(argv, (i + 1));
            if ((v !=((uint8_t *)(0)))) {
              if ((ndefines < max_defines)) {
                (void)(driver_defines_set_at(defines, ndefines, v));
                (void)((ndefines = (ndefines + 1)));
              }
            }
            (void)((i = (i + 2)));
          }
        } else {
          if ((driver_argv_is_D_inline(arg) !=0)) {
            uint8_t * def = shux_cstr_offset(arg, 2);
            if ((def !=((uint8_t *)(0)))) {
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
                (void)((i = (i + 2)));
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
  if ((target_arg !=((uint8_t *)(0)))) {
    if ((ndefines < max_defines)) {
      int32_t k = driver_target_arg_os_kind(target_arg);
      if ((k !=0)) {
        {
          uint8_t * lit = driver_os_define_lit(k);
          if ((lit !=((uint8_t *)(0)))) {
            (void)(driver_defines_set_at(defines, ndefines, lit));
            (void)((ndefines = (ndefines + 1)));
          }
        }
      }
    }
  }
  if (((ndefines + 2) <=max_defines)) {
    {
      (void)((ndefines = driver_argv_collect_append_uname_impl(defines, ndefines, max_defines)));
    }
  }
  return ndefines;
}
int32_t driver_source_scan_top_level_import(uint8_t * src, int64_t src_len) {
  if ((src ==((uint8_t *)(0)))) {
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
int32_t driver_source_has_top_level_import(uint8_t * src, int64_t src_len) {
  if ((src ==((uint8_t *)(0)))) {
    return 0;
  }
  if ((src_len < 9)) {
    return 0;
  }
  return driver_source_scan_top_level_import(src, src_len);
}
int32_t driver_source_has_top_level_import_path(uint8_t * path) {
  if ((path ==((uint8_t *)(0)))) {
    return 0;
  }
  {
    uint8_t * src = driver_path_read_preprocess_malloc(path);
    if ((src ==((uint8_t *)(0)))) {
      return 0;
    }
    int64_t len = driver_path_last_preprocess_len();
    int32_t has = driver_source_has_top_level_import(src, len);
    (void)(free(src));
    return has;
  }
  return 0;
}
void driver_run_thread_on_large_stack(uint8_t * fn, uint8_t * arg) {
  if ((fn ==((uint8_t *)(0)))) {
    return;
  }
  if ((driver_is_large_stack_thread() !=0)) {
    {
      (void)(driver_call_fn_void_arg_impl(fn, arg));
    }
    return;
  }
  (void)(driver_bump_stack_limit());
  {
    if ((bootstrap_nostdlib_pthread_is_stub() !=0)) {
      (void)(driver_run_fn_on_current_large_stack(fn, arg));
      return;
    }
  }
  if ((driver_pipeline_no_large_stack_env() !=0)) {
    (void)(driver_run_fn_on_current_large_stack(fn, arg));
    return;
  }
  {
    (void)(driver_run_thread_on_large_stack_pthread_impl(fn, arg));
  }
}
void driver_run_on_large_stack_pthread(uint8_t * fn, uint8_t * arg) {
  if ((fn ==((uint8_t *)(0)))) {
    return;
  }
  (void)(driver_run_thread_on_large_stack(fn, arg));
}
extern int64_t driver_pipeline_entry_source_len_load_and_maybe_debug_impl(void);
int64_t driver_pipeline_entry_source_len_load_and_maybe_debug(void) {
  {
    return driver_pipeline_entry_source_len_load_and_maybe_debug_impl();
  }
  return 0;
}
int64_t driver_pipeline_entry_source_len(void) {
  return driver_pipeline_entry_source_len_load_and_maybe_debug();
}
