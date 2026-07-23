/* seeds/labi_path_pure_surface.from_x.c
 * G-02f labi_path_pure R2 full surface — isomorphic with src/runtime/labi_path_pure.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_path_pure.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (wave183 29× thin + wave184 empty/effective + wave185 rel_o + wave189 set/clear user_o + wave253/258 user_env path + push_minimal companion
 *   + wave262 private helper short names: labi_user_extra_cstr_eq / ends_with_dot_o)
 * Cap residual: Windows #if path sep mega cold; link_abi_getenv Cap (wave223 G.7); skip_missing+bank_push Cap;
 *   link_abi_realpath_cap Cap (wave146; also wave164–166/180/181 path ladders + task→sched);
 *   bank_push Cap (wave147);
 *   skip/rel/bank/diag Cap (wave148 push_obj); call_ensure Cap (wave149 push_glue);
 *   peer pure thin runtime_*_o_path (wave183 BSS; was Cap residual wave150/161);
 *   table+access Cap (wave151 append_user_extra);
 *   xlang_resolve_compiler_dir Cap (wave160 compiler_o_path_copy; wave181 bootstrap stubs path);
 *   resolve+rel_o_path Cap (wave162 repo_root);
 *   realpath_if_exists+getcwd+skip Cap (wave163 panic_o_path);
 *   realpath_cap+getcwd Cap (wave164–166 crt0_user / freestanding_io / async_scheduler_o_path);
 *   path_readable+realpath_cap Cap (wave180 scheduler_o_for_task_link);
 *   realpath_cap+xlang_resolve_compiler_dir Cap (wave181 bootstrap_nostdlib_stubs_o_path)
 *   resolve Cap (wave184 effective_link_argv0; empty path stubs pure)
 *   realpath_cap+getcwd+cstr_dup+skip Cap (wave185 rel_o_path heap; pure orch)
 *   reset/push Cap (wave189 set/clear user_o_files; pure argv .o scan)
 * Regen: ./xlang_asm -E ... src/runtime/labi_path_pure.x | filter DBG + polish prologue
 * PLATFORM: SHARED — symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h> /* getcwd */
extern int32_t link_abi_path_readable(uint8_t * path);
extern int32_t xlang_resolve_compiler_dir(uint8_t * argv0, uint8_t * out_dir, int64_t out_dir_sz);
extern uint8_t * link_abi_realpath_cap(uint8_t * path, uint8_t * out);
extern uint8_t * link_abi_cstr_dup(uint8_t * s);
/* wave223 G.7: env lookup authority = public pure thin link_abi_getenv (labi_diag_pure). */
extern uint8_t * link_abi_getenv(uint8_t * name);
/* wave185: pure body below; forward for push_obj / repo_root call sites. */
uint8_t * xlang_rel_o_path_from_argv0(uint8_t * argv0, uint8_t * rel);
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern uint8_t * xlang_asm_ld_bank_push(uint8_t * b, uint8_t * path);
extern void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path);
extern int32_t link_abi_call_ensure_argv0(uint8_t * ensure_fn, uint8_t * link_argv0);
extern int32_t link_abi_user_extra_o_count(void);
extern uint8_t * link_abi_user_extra_o_at(int32_t i);
extern void link_abi_user_extra_o_reset(void);
extern int32_t link_abi_user_extra_o_push(uint8_t * p);
extern uint8_t * xlang_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved);
extern int32_t xlang_io_register(uint8_t *ptr, size_t len, size_t handle);
extern int32_t xlang_io_submit_read(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t xlang_io_submit_write(uint8_t *ptr, size_t len, size_t handle, uint32_t timeout_m);
extern int32_t xlang_io_read_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);
extern int32_t xlang_io_write_fixed(size_t handle, uint32_t buf_index, size_t offset, size_t len, uint32_t timeout_m);
extern uint8_t *xlang_io_read_ptr(size_t handle, unsigned timeout_ms);
extern int32_t xlang_io_read_ptr_len(void);
extern int32_t xlang_io_read_ptr_gen_valid(uint64_t saved);
extern int32_t xlang_io_read_ptr_backend(void);
extern uint64_t xlang_io_read_ptr_gen(void);
extern struct xlang_slice_uint8_t xlang_io_read_ptr_slice(size_t handle, uint32_t timeout_ms);
extern int32_t xlang_io_register_provided_buffers(uint32_t nr, uint32_t bufsz);
extern void xlang_io_unregister_provided_buffers(void);
extern uint8_t *xlang_io_provided_buffer_ptr(uint32_t bid);
extern uint32_t xlang_io_provided_buffer_size(void);
extern int32_t xlang_io_read_provided(size_t handle, uint32_t timeout_ms, uint32_t *out_bid, uint32_t *out_len);
extern int32_t xlang_io_read_batch_provided(size_t handle, int32_t n, uint32_t timeout_ms, uint32_t *out_bids, uint32_t *out_lens);
extern int32_t xlang_io_submit_read_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t xlang_io_complete_read_async(void);
extern int32_t xlang_io_complete_read_async_slot(int32_t slot);
extern int32_t xlang_io_submit_write_async(uint8_t *ptr, size_t len, size_t handle);
extern int32_t xlang_io_complete_write_async(void);
extern int32_t xlang_io_complete_write_async_slot(int32_t slot);
extern uint32_t xlang_io_poll_async_completions(uint32_t timeout_ms);
extern int32_t xlang_io_uring_is_available_c(void);
extern void xlang_panic_(int, int);
extern int32_t labi_suffix_eq2(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1);
extern int32_t labi_suffix_eq4(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3);
extern int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s);
extern int32_t xlang_output_is_elf_o(uint8_t * path);
extern int32_t xlang_output_want_exe(uint8_t * path);
extern int32_t xlang_path_has_sep(uint8_t * s);
extern uint8_t * xlang_path_last_sep(uint8_t * s);
extern int32_t xlang_asm_ld_lib_root_ptr_usable(uint8_t * p);
extern void xlang_asm_ld_lib_root_default(uint8_t * root_buf);
extern uint8_t * xlang_asm_ld_try_under_lib_roots(uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank);
extern int32_t link_abi_asm_ld_argv_has_obj(uint8_t * * argv, int32_t la, uint8_t * path);
extern void link_abi_asm_ld_argv_push_stable(uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, uint8_t * p);
extern int32_t link_abi_asm_ld_push_obj(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, int32_t * flag_out);
extern void link_abi_asm_ld_push_glue_after_std(int32_t have_std, uint8_t * ensure_fn, uint8_t * glue_primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la);
extern uint8_t * xlang_runtime_panic_o_path(uint8_t * argv0);
extern uint8_t * xlang_crt0_user_o_path(uint8_t * argv0);
extern uint8_t * xlang_freestanding_io_o_path(uint8_t * argv0);
extern uint8_t * xlang_std_async_scheduler_o_path(uint8_t * argv0);
extern void link_abi_asm_ld_push_minimal_runtime_objs(uint8_t * link_argv0, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la);
extern void xlang_asm_ld_append_user_extra_o_files(uint8_t * * argv, int32_t * la, int32_t max_la);
extern void xlang_invoke_cc_set_user_o_files_from_argv(int32_t argc, uint8_t * * argv);
extern void xlang_invoke_cc_clear_user_o_files(void);
extern int32_t xlang_runtime_compiler_o_path_copy(uint8_t * argv0, uint8_t * leaf, uint8_t * out, int64_t out_sz);
extern uint8_t * xlang_repo_root_from_argv0(uint8_t * argv0);
extern uint8_t * scheduler_o_for_task_link(uint8_t * task_o, uint8_t * explicit_scheduler);
extern uint8_t * xlang_bootstrap_nostdlib_stubs_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_asm_io_stubs_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_process_argv_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_process_os_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_test_fn_invoke_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_random_fill_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_compress_zlib_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_heap_user_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_time_os_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_queue_contention_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_dynlib_os_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_env_os_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_link_abi_user_env_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_backtrace_platform_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_log_os_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_math_libm_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_atomic_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_channel_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_net_udp_batch_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_net_workers_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_sync_os_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_sync_lock_diag_tls_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_thread_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_scheduler_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_http_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_tls_mbedtls_bio_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_kv_mmap_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_arrow_simd_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_sqlite_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_crypto_inc_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_ed25519_ref10_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_empty_cstr(void);
extern uint8_t * xlang_std_io_o_path(uint8_t * argv0);
extern uint8_t * xlang_std_compress_o_path(uint8_t * argv0);
extern uint8_t * xlang_asm_ld_effective_link_argv0(uint8_t * link_argv0, uint8_t * syn_buf, int64_t syn_sz);
extern int32_t labi_path_pure_count(void);
#undef g_labi_repo_root_buf
static uint8_t g_labi_repo_root_buf[512];
#undef g_labi_panic_o_path_buf
static uint8_t g_labi_panic_o_path_buf[512];
#undef g_labi_panic_o_path_resolved
static uint8_t g_labi_panic_o_path_resolved[4096];
#undef g_labi_crt0_user_o_path_buf
static uint8_t g_labi_crt0_user_o_path_buf[512];
#undef g_labi_crt0_user_o_path_resolved
static uint8_t g_labi_crt0_user_o_path_resolved[4096];
#undef g_labi_freestanding_io_o_path_buf
static uint8_t g_labi_freestanding_io_o_path_buf[512];
#undef g_labi_freestanding_io_o_path_resolved
static uint8_t g_labi_freestanding_io_o_path_resolved[4096];
#undef g_labi_async_scheduler_o_path_buf
static uint8_t g_labi_async_scheduler_o_path_buf[4096];
#undef g_labi_async_scheduler_o_path_resolved
static uint8_t g_labi_async_scheduler_o_path_resolved[4096];
#undef g_labi_sched_for_task_derived
static uint8_t g_labi_sched_for_task_derived[4096];
#undef g_labi_sched_for_task_cwd
static uint8_t g_labi_sched_for_task_cwd[4096];
#undef g_labi_bootstrap_nostdlib_stubs_o_path_buf
static uint8_t g_labi_bootstrap_nostdlib_stubs_o_path_buf[4096];
#undef g_labi_bootstrap_nostdlib_stubs_o_path_resolved
static uint8_t g_labi_bootstrap_nostdlib_stubs_o_path_resolved[4096];
#undef g_labi_empty_cstr_buf
static uint8_t g_labi_empty_cstr_buf[1];
#undef g_labi_asm_io_stubs_o_path_buf
static uint8_t g_labi_asm_io_stubs_o_path_buf[4096];
#undef g_labi_process_argv_o_path_buf
static uint8_t g_labi_process_argv_o_path_buf[4096];
#undef g_labi_process_os_glue_o_path_buf
static uint8_t g_labi_process_os_glue_o_path_buf[4096];
#undef g_labi_test_fn_invoke_o_path_buf
static uint8_t g_labi_test_fn_invoke_o_path_buf[4096];
#undef g_labi_random_fill_o_path_buf
static uint8_t g_labi_random_fill_o_path_buf[4096];
#undef g_labi_compress_zlib_glue_o_path_buf
static uint8_t g_labi_compress_zlib_glue_o_path_buf[4096];
#undef g_labi_heap_user_o_path_buf
static uint8_t g_labi_heap_user_o_path_buf[4096];
#undef g_labi_time_os_o_path_buf
static uint8_t g_labi_time_os_o_path_buf[4096];
#undef g_labi_queue_contention_o_path_buf
static uint8_t g_labi_queue_contention_o_path_buf[4096];
#undef g_labi_dynlib_os_o_path_buf
static uint8_t g_labi_dynlib_os_o_path_buf[4096];
#undef g_labi_env_os_o_path_buf
static uint8_t g_labi_env_os_o_path_buf[4096];
/* wave253/258: thin durable BSS for runtime_link_abi_user_env.o companion face. */
#undef g_labi_link_abi_user_env_o_path_buf
static uint8_t g_labi_link_abi_user_env_o_path_buf[4096];
#undef g_labi_backtrace_platform_o_path_buf
static uint8_t g_labi_backtrace_platform_o_path_buf[4096];
#undef g_labi_log_os_o_path_buf
static uint8_t g_labi_log_os_o_path_buf[4096];
#undef g_labi_math_libm_o_path_buf
static uint8_t g_labi_math_libm_o_path_buf[4096];
#undef g_labi_atomic_glue_o_path_buf
static uint8_t g_labi_atomic_glue_o_path_buf[4096];
#undef g_labi_channel_glue_o_path_buf
static uint8_t g_labi_channel_glue_o_path_buf[4096];
#undef g_labi_net_udp_batch_o_path_buf
static uint8_t g_labi_net_udp_batch_o_path_buf[4096];
#undef g_labi_net_workers_o_path_buf
static uint8_t g_labi_net_workers_o_path_buf[4096];
#undef g_labi_sync_os_o_path_buf
static uint8_t g_labi_sync_os_o_path_buf[4096];
#undef g_labi_sync_lock_diag_tls_o_path_buf
static uint8_t g_labi_sync_lock_diag_tls_o_path_buf[4096];
#undef g_labi_thread_glue_o_path_buf
static uint8_t g_labi_thread_glue_o_path_buf[4096];
#undef g_labi_scheduler_glue_o_path_buf
static uint8_t g_labi_scheduler_glue_o_path_buf[4096];
#undef g_labi_http_glue_o_path_buf
static uint8_t g_labi_http_glue_o_path_buf[4096];
#undef g_labi_tls_mbedtls_bio_o_path_buf
static uint8_t g_labi_tls_mbedtls_bio_o_path_buf[4096];
#undef g_labi_kv_mmap_glue_o_path_buf
static uint8_t g_labi_kv_mmap_glue_o_path_buf[4096];
#undef g_labi_arrow_simd_glue_o_path_buf
static uint8_t g_labi_arrow_simd_glue_o_path_buf[4096];
#undef g_labi_sqlite_glue_o_path_buf
static uint8_t g_labi_sqlite_glue_o_path_buf[4096];
#undef g_labi_crypto_inc_glue_o_path_buf
static uint8_t g_labi_crypto_inc_glue_o_path_buf[4096];
#undef g_labi_ed25519_ref10_glue_o_path_buf
static uint8_t g_labi_ed25519_ref10_glue_o_path_buf[4096];
static void init_globals(void) {
}
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern uint8_t * xlang_asm_ld_bank_push(uint8_t * b, uint8_t * path);
extern uint8_t * link_abi_realpath_cap(uint8_t * path, uint8_t * out);
extern uint8_t * link_abi_cstr_dup(uint8_t * s);
extern void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path);
extern int32_t link_abi_call_ensure_argv0(uint8_t * ensure_fn, uint8_t * link_argv0);
extern int32_t link_abi_user_extra_o_count(void);
extern uint8_t * link_abi_user_extra_o_at(int32_t i);
extern void link_abi_user_extra_o_reset(void);
extern int32_t link_abi_user_extra_o_push(uint8_t * p);
extern int32_t link_abi_path_readable(uint8_t * path);
extern int32_t xlang_resolve_compiler_dir(uint8_t * argv0, uint8_t * out_dir, int64_t out_dir_sz);
extern uint8_t * xlang_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved);
int32_t labi_suffix_eq2(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1) {
  if ((n < 2)) {
    return 0;
  }
  if (((s)[(n - 2)] !=a0)) {
    return 0;
  }
  if (((s)[(n - 1)] !=a1)) {
    return 0;
  }
  return 1;
}
int32_t labi_suffix_eq4(uint8_t * s, int32_t n, uint8_t a0, uint8_t a1, uint8_t a2, uint8_t a3) {
  if ((n < 4)) {
    return 0;
  }
  if (((s)[(n - 4)] !=a0)) {
    return 0;
  }
  if (((s)[(n - 3)] !=a1)) {
    return 0;
  }
  if (((s)[(n - 2)] !=a2)) {
    return 0;
  }
  if (((s)[(n - 1)] !=a3)) {
    return 0;
  }
  return 1;
}
int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s) {
  int32_t n = 0;
  if ((s ==0)) {
    return 0;
  }
  if (((s)[0] ==0)) {
    return 0;
  }
  while (((s)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(s, n, 46, 111) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq4(s, n, 46, 111, 98, 106) !=0)) {
    return 1;
  }
  return 0;
}
int32_t xlang_output_is_elf_o(uint8_t * path) {
  int32_t n = 0;
  if ((path ==0)) {
    return 0;
  }
  while (((path)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(path, n, 46, 111) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq2(path, n, 46, 79) !=0)) {
    return 1;
  }
  if ((labi_suffix_eq4(path, n, 46, 111, 98, 106) !=0)) {
    return 1;
  }
  return 0;
}
int32_t xlang_output_want_exe(uint8_t * path) {
  int32_t n = 0;
  if ((path ==0)) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  while (((path)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((labi_suffix_eq2(path, n, 46, 111) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq2(path, n, 46, 79) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq2(path, n, 46, 115) !=0)) {
    return 0;
  }
  if ((labi_suffix_eq4(path, n, 46, 111, 98, 106) !=0)) {
    return 0;
  }
  return 1;
}
int32_t xlang_path_has_sep(uint8_t * s) {
  if ((s ==0)) {
    return 0;
  }
  int32_t i = 0;
  while (((s)[i] !=0)) {
    if (((s)[i] ==47)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
uint8_t * xlang_path_last_sep(uint8_t * s) {
  if ((s ==0)) {
    return ((uint8_t *)(0));
  }
  int32_t last = 0;
  int32_t found = 0;
  int32_t i = 0;
  while (((s)[i] !=0)) {
    if (((s)[i] ==47)) {
      (void)((last = i));
      (void)((found = 1));
    }
    (void)((i = (i + 1)));
  }
  if ((found ==0)) {
    return ((uint8_t *)(0));
  }
  size_t base = ((size_t)(s));
  return ((uint8_t *)((base + ((size_t)(last)))));
}
int32_t xlang_asm_ld_lib_root_ptr_usable(uint8_t * p) {
  if ((p ==0)) {
    return 0;
  }
  if ((((size_t)(p)) < 4096)) {
    return 0;
  }
  if (((p)[0] ==0)) {
    return 0;
  }
  return 1;
}
void xlang_asm_ld_lib_root_default(uint8_t * root_buf) {
  (void)(((root_buf)[0] = 46));
  (void)(((root_buf)[1] = 0));
  uint8_t * def = 0;
  (void)((def = link_abi_getenv(((uint8_t *)"\x53\x48\x55\x58\x5f\x4c\x49\x42"))));
  if ((xlang_asm_ld_lib_root_ptr_usable(def) ==0)) {
    return;
  }
  int32_t i = 0;
  while ((i < 511)) {
    uint8_t c = (def)[i];
    (void)(((root_buf)[i] = c));
    if ((c ==0)) {
      return;
    }
    (void)((i = (i + 1)));
  }
  (void)(((root_buf)[511] = 0));
}
uint8_t * xlang_asm_ld_try_under_lib_roots(uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank) {
  if ((xlang_asm_ld_lib_root_ptr_usable(rel) ==0)) {
    return ((uint8_t *)(0));
  }
  if ((bank ==0)) {
    return ((uint8_t *)(0));
  }
  if ((((size_t)(bank)) < 4096)) {
    return ((uint8_t *)(0));
  }
  uint8_t * roots_base = ((uint8_t *)(lib_roots));
  if ((roots_base ==0)) {
    return ((uint8_t *)(0));
  }
  if ((((size_t)(roots_base)) < 4096)) {
    return ((uint8_t *)(0));
  }
  if ((n_lib_roots <=0)) {
    return ((uint8_t *)(0));
  }
  int32_t rel_n = 0;
  while (((rel)[rel_n] !=0)) {
    (void)((rel_n = (rel_n + 1)));
  }
  int32_t i = 0;
  while ((i < n_lib_roots)) {
    if ((i >=24)) {
      break;
    }
    uint8_t * root = (lib_roots)[i];
    if ((xlang_asm_ld_lib_root_ptr_usable(root) ==0)) {
      (void)((i = (i + 1)));
      continue;
    }
    int32_t rn = 0;
    while (((root)[rn] !=0)) {
      (void)((rn = (rn + 1)));
    }
    while ((rn > 1)) {
      if (((root)[(rn - 1)] !=47)) {
        break;
      }
      (void)((rn = (rn - 1)));
    }
    if ((((rn + 2) + rel_n) >=4096)) {
      (void)((i = (i + 1)));
      continue;
    }
    uint8_t tmp[4096] = {};
    if ((rn > 0)) {
      int32_t j = 0;
      while ((j < rn)) {
        (void)(((tmp)[j] = (root)[j]));
        (void)((j = (j + 1)));
      }
      (void)(((tmp)[rn] = 47));
      int32_t k = 0;
      while ((k <=rel_n)) {
        (void)(((tmp)[((rn + 1) + k)] = (rel)[k]));
        (void)((k = (k + 1)));
      }
    } else {
      int32_t k2 = 0;
      while ((k2 <=rel_n)) {
        (void)(((tmp)[k2] = (rel)[k2]));
        (void)((k2 = (k2 + 1)));
      }
    }
    uint8_t * hit = 0;
    (void)((hit = asm_link_obj_skip_missing(&((tmp)[0]))));
    if ((hit ==0)) {
      (void)((i = (i + 1)));
      continue;
    }
    uint8_t * pushed = 0;
    (void)((pushed = xlang_asm_ld_bank_push(bank, &((tmp)[0]))));
    return pushed;
  }
  return ((uint8_t *)(0));
}
int32_t link_abi_asm_ld_argv_has_obj(uint8_t * * argv, int32_t la, uint8_t * path) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return 0;
  }
  if ((la <=0)) {
    return 0;
  }
  if ((path ==0)) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  uint8_t abs_new[4096] = {};
  uint8_t * use_new = path;
  uint8_t * rn = 0;
  (void)((rn = link_abi_realpath_cap(path, &((abs_new)[0]))));
  if ((rn !=0)) {
    (void)((use_new = rn));
  }
  int32_t k = 0;
  while ((k < la)) {
    uint8_t * exist = (argv)[k];
    if ((exist ==0)) {
      (void)((k = (k + 1)));
      continue;
    }
    if (((exist)[0] ==0)) {
      (void)((k = (k + 1)));
      continue;
    }
    int32_t eq_path = 1;
    int32_t i0 = 0;
    while ((i0 < 1048576)) {
      uint8_t ca = (exist)[i0];
      uint8_t cb = (path)[i0];
      if ((ca !=cb)) {
        (void)((eq_path = 0));
        break;
      }
      if ((ca ==0)) {
        break;
      }
      (void)((i0 = (i0 + 1)));
    }
    if ((eq_path !=0)) {
      return 1;
    }
    int32_t eq_new = 1;
    int32_t i1 = 0;
    while ((i1 < 1048576)) {
      uint8_t ca2 = (exist)[i1];
      uint8_t cb2 = (use_new)[i1];
      if ((ca2 !=cb2)) {
        (void)((eq_new = 0));
        break;
      }
      if ((ca2 ==0)) {
        break;
      }
      (void)((i1 = (i1 + 1)));
    }
    if ((eq_new !=0)) {
      return 1;
    }
    uint8_t abs_exist[4096] = {};
    uint8_t * re = 0;
    (void)((re = link_abi_realpath_cap(exist, &((abs_exist)[0]))));
    if ((re !=0)) {
      int32_t eq_re = 1;
      int32_t i2 = 0;
      while ((i2 < 1048576)) {
        uint8_t ca3 = (re)[i2];
        uint8_t cb3 = (use_new)[i2];
        if ((ca3 !=cb3)) {
          (void)((eq_re = 0));
          break;
        }
        if ((ca3 ==0)) {
          break;
        }
        (void)((i2 = (i2 + 1)));
      }
      if ((eq_re !=0)) {
        return 1;
      }
    }
    (void)((k = (k + 1)));
  }
  return 0;
}
void link_abi_asm_ld_argv_push_stable(uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, uint8_t * p) {
  if ((p ==0)) {
    return;
  }
  if (((p)[0] ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  int32_t cur = (la)[0];
  if ((cur >=(max_la - 1))) {
    return;
  }
  uint8_t * use_p = p;
  if ((bank !=0)) {
    uint8_t * bp = 0;
    (void)((bp = xlang_asm_ld_bank_push(bank, p)));
    if ((bp !=0)) {
      (void)((use_p = bp));
    }
  }
  if ((link_abi_asm_ld_argv_has_obj(argv, cur, use_p) !=0)) {
    return;
  }
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  (void)(((argv)[cur] = use_p));
  (void)(((la)[0] = (cur + 1)));
}
int32_t link_abi_asm_ld_push_obj(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la, int32_t * flag_out) {
  if ((la ==0)) {
    return 0;
  }
  int32_t cur = (la)[0];
  if ((cur >=(max_la - 1))) {
    return 0;
  }
  int32_t debug_runtime_obj = 0;
  if ((rel !=0)) {
    uint8_t * t1 = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73\x2e\x6f");
    uint8_t * t2 = ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f");
    int32_t eq1 = 1;
    int32_t i1 = 0;
    while ((i1 < 1048576)) {
      uint8_t ca = (rel)[i1];
      uint8_t cb = (t1)[i1];
      if ((ca !=cb)) {
        (void)((eq1 = 0));
        break;
      }
      if ((ca ==0)) {
        break;
      }
      (void)((i1 = (i1 + 1)));
    }
    if ((eq1 !=0)) {
      (void)((debug_runtime_obj = 1));
    }
    if ((debug_runtime_obj ==0)) {
      int32_t eq2 = 1;
      int32_t i2 = 0;
      while ((i2 < 1048576)) {
        uint8_t ca2 = (rel)[i2];
        uint8_t cb2 = (t2)[i2];
        if ((ca2 !=cb2)) {
          (void)((eq2 = 0));
          break;
        }
        if ((ca2 ==0)) {
          break;
        }
        (void)((i2 = (i2 + 1)));
      }
      if ((eq2 !=0)) {
        (void)((debug_runtime_obj = 1));
      }
    }
  }
  if ((debug_runtime_obj !=0)) {
    uint8_t * dbg = 0;
    (void)((dbg = link_abi_getenv(((uint8_t *)"\x53\x48\x55\x58\x5f\x44\x45\x42\x55\x47\x5f\x4c\x44"))));
    if ((dbg !=0)) {
      uint8_t * pp = primary;
      if ((pp ==0)) {
        (void)((pp = ((uint8_t *)"\x28\x6e\x75\x6c\x6c\x29")));
      }
      (void)(link_diag_ld_debug_push(rel, ((uint8_t *)"\x70\x72\x69\x6d\x61\x72\x79"), pp));
    }
  }
  uint8_t * p = 0;
  if ((primary !=0)) {
    if (((primary)[0] !=0)) {
      (void)((p = asm_link_obj_skip_missing(primary)));
    }
  }
  if ((debug_runtime_obj !=0)) {
    uint8_t * dbg2 = 0;
    (void)((dbg2 = link_abi_getenv(((uint8_t *)"\x53\x48\x55\x58\x5f\x44\x45\x42\x55\x47\x5f\x4c\x44"))));
    if ((dbg2 !=0)) {
      uint8_t * ap = p;
      if ((ap ==0)) {
        (void)((ap = ((uint8_t *)"\x28\x6e\x75\x6c\x6c\x29")));
      }
      (void)(link_diag_ld_debug_push(rel, ((uint8_t *)"\x61\x66\x74\x65\x72\x2d\x70\x72\x69\x6d\x61\x72\x79"), ap));
    }
  }
  if ((p ==0)) {
    if ((rel !=0)) {
      if (((rel)[0] !=0)) {
        uint8_t * relp = 0;
        (void)((relp = xlang_rel_o_path_from_argv0(link_argv0, rel)));
        if ((relp !=0)) {
          (void)((p = asm_link_obj_skip_missing(relp)));
        }
      }
    }
  }
  if ((p ==0)) {
    if ((bank !=0)) {
      if ((rel !=0)) {
        if (((rel)[0] !=0)) {
          (void)((p = xlang_asm_ld_try_under_lib_roots(rel, lib_roots, n_lib_roots, bank)));
        }
      }
    }
  }
  if ((p ==0)) {
    return 0;
  }
  if ((bank !=0)) {
    uint8_t * bp = 0;
    (void)((bp = xlang_asm_ld_bank_push(bank, p)));
    if ((bp ==0)) {
      return 0;
    }
    (void)((p = bp));
  }
  if ((debug_runtime_obj !=0)) {
    uint8_t * dbg3 = 0;
    (void)((dbg3 = link_abi_getenv(((uint8_t *)"\x53\x48\x55\x58\x5f\x44\x45\x42\x55\x47\x5f\x4c\x44"))));
    if ((dbg3 !=0)) {
      uint8_t * fp = p;
      if ((fp ==0)) {
        (void)((fp = ((uint8_t *)"\x28\x6e\x75\x6c\x6c\x29")));
      }
      (void)(link_diag_ld_debug_push(rel, ((uint8_t *)"\x66\x69\x6e\x61\x6c"), fp));
    }
  }
  int32_t before = (la)[0];
  (void)(link_abi_asm_ld_argv_push_stable(0, argv, la, max_la, p));
  if (((la)[0] <=before)) {
    return 0;
  }
  if ((flag_out !=0)) {
    (void)(((flag_out)[0] = 1));
  }
  return 1;
}
void link_abi_asm_ld_push_glue_after_std(int32_t have_std, uint8_t * ensure_fn, uint8_t * glue_primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la) {
  if ((have_std ==0)) {
    return;
  }
  if ((ensure_fn !=0)) {
    int32_t rc = 0;
    (void)((rc = link_abi_call_ensure_argv0(ensure_fn, link_argv0)));
    if ((rc !=0)) {
      return;
    }
  }
  int32_t _pushed = link_abi_asm_ld_push_obj(glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_pushed ==0)) {
    return;
  }
}
uint8_t * xlang_runtime_panic_o_path(uint8_t * argv0) {
  (void)(((g_labi_panic_o_path_buf)[0] = 0));
  (void)(((g_labi_panic_o_path_resolved)[0] = 0));
  uint8_t * hit = 0;
  (void)((hit = xlang_runtime_o_realpath_if_exists(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f"), &((g_labi_panic_o_path_resolved)[0]))));
  if ((hit !=0)) {
    return hit;
  }
  (void)((hit = xlang_runtime_o_realpath_if_exists(((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f"), &((g_labi_panic_o_path_resolved)[0]))));
  if ((hit !=0)) {
    return hit;
  }
  uint8_t cwd[512] = {};
  uint8_t * gp = 0;
  (void)((gp = getcwd(&((cwd)[0]), 488)));
  if ((gp !=0)) {
    int32_t L = 0;
    while (((cwd)[L] !=0)) {
      (void)((L = (L + 1)));
    }
    if (((L + 24) < 512)) {
      uint8_t * suf = ((uint8_t *)"\x2f\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f");
      int32_t si = 0;
      while ((si <=24)) {
        (void)(((cwd)[(L + si)] = (suf)[si]));
        (void)((si = (si + 1)));
      }
      (void)((hit = xlang_runtime_o_realpath_if_exists(&((cwd)[0]), &((g_labi_panic_o_path_resolved)[0]))));
      if ((hit !=0)) {
        return hit;
      }
    }
  }
  if ((argv0 !=0)) {
    if (((argv0)[0] !=0)) {
      int32_t i = 0;
      int32_t last_sep_i = -1;
      while (((argv0)[i] !=0)) {
        if (((argv0)[i] ==47)) {
          (void)((last_sep_i = i));
        }
        (void)((i = (i + 1)));
      }
      int32_t n = 0;
      if ((last_sep_i >=0)) {
        if ((last_sep_i >=492)) {
          return &((g_labi_panic_o_path_buf)[0]);
        }
        int32_t j = 0;
        while ((j < last_sep_i)) {
          (void)(((g_labi_panic_o_path_buf)[j] = (argv0)[j]));
          (void)((j = (j + 1)));
        }
        (void)(((g_labi_panic_o_path_buf)[last_sep_i] = 0));
        (void)((n = last_sep_i));
      } else {
        (void)(((g_labi_panic_o_path_buf)[0] = 46));
        (void)(((g_labi_panic_o_path_buf)[1] = 0));
        (void)((n = 1));
      }
      if (((n + 18) < 512)) {
        uint8_t * leaf = ((uint8_t *)"\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f");
        int32_t k = 0;
        while (((leaf)[k] !=0)) {
          (void)(((g_labi_panic_o_path_buf)[(n + k)] = (leaf)[k]));
          (void)((k = (k + 1)));
        }
        (void)(((g_labi_panic_o_path_buf)[(n + k)] = 0));
        (void)((hit = xlang_runtime_o_realpath_if_exists(&((g_labi_panic_o_path_buf)[0]), &((g_labi_panic_o_path_resolved)[0]))));
        if ((hit !=0)) {
          return hit;
        }
        uint8_t * sm = 0;
        (void)((sm = asm_link_obj_skip_missing(&((g_labi_panic_o_path_buf)[0]))));
        if ((sm !=0)) {
          return &((g_labi_panic_o_path_buf)[0]);
        }
      }
    }
  }
  return &((g_labi_panic_o_path_buf)[0]);
}
uint8_t * xlang_crt0_user_o_path(uint8_t * argv0) {
  (void)(((g_labi_crt0_user_o_path_buf)[0] = 0));
  (void)(((g_labi_crt0_user_o_path_resolved)[0] = 0));
  uint8_t * hit = 0;
  (void)((hit = link_abi_realpath_cap(((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f"), &((g_labi_crt0_user_o_path_resolved)[0]))));
  if ((hit !=0)) {
    return hit;
  }
  uint8_t cwd[512] = {};
  uint8_t * gp = 0;
  (void)((gp = getcwd(&((cwd)[0]), 490)));
  if ((gp !=0)) {
    int32_t L = 0;
    while (((cwd)[L] !=0)) {
      (void)((L = (L + 1)));
    }
    if (((L + 21) < 512)) {
      uint8_t * suf = ((uint8_t *)"\x2f\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
      int32_t si = 0;
      while ((si <=21)) {
        (void)(((cwd)[(L + si)] = (suf)[si]));
        (void)((si = (si + 1)));
      }
      (void)((hit = link_abi_realpath_cap(&((cwd)[0]), &((g_labi_crt0_user_o_path_resolved)[0]))));
      if ((hit !=0)) {
        return hit;
      }
    }
  }
  if ((argv0 !=0)) {
    if (((argv0)[0] !=0)) {
      int32_t i = 0;
      int32_t last_sep_i = -1;
      while (((argv0)[i] !=0)) {
        if (((argv0)[i] ==47)) {
          (void)((last_sep_i = i));
        }
        (void)((i = (i + 1)));
      }
      int32_t n = 0;
      if ((last_sep_i >=0)) {
        if ((last_sep_i >=496)) {
          return &((g_labi_crt0_user_o_path_buf)[0]);
        }
        int32_t j = 0;
        while ((j < last_sep_i)) {
          (void)(((g_labi_crt0_user_o_path_buf)[j] = (argv0)[j]));
          (void)((j = (j + 1)));
        }
        (void)(((g_labi_crt0_user_o_path_buf)[last_sep_i] = 0));
        (void)((n = last_sep_i));
      } else {
        (void)(((g_labi_crt0_user_o_path_buf)[0] = 46));
        (void)(((g_labi_crt0_user_o_path_buf)[1] = 0));
        (void)((n = 1));
      }
      if (((n + 14) < 512)) {
        uint8_t * leaf = ((uint8_t *)"\x2f\x63\x72\x74\x30\x5f\x75\x73\x65\x72\x2e\x6f");
        int32_t k = 0;
        while (((leaf)[k] !=0)) {
          (void)(((g_labi_crt0_user_o_path_buf)[(n + k)] = (leaf)[k]));
          (void)((k = (k + 1)));
        }
        (void)(((g_labi_crt0_user_o_path_buf)[(n + k)] = 0));
        (void)((hit = link_abi_realpath_cap(&((g_labi_crt0_user_o_path_buf)[0]), &((g_labi_crt0_user_o_path_resolved)[0]))));
        if ((hit !=0)) {
          return hit;
        }
        return &((g_labi_crt0_user_o_path_buf)[0]);
      }
    }
  }
  return &((g_labi_crt0_user_o_path_buf)[0]);
}
uint8_t * xlang_freestanding_io_o_path(uint8_t * argv0) {
  (void)(((g_labi_freestanding_io_o_path_buf)[0] = 0));
  (void)(((g_labi_freestanding_io_o_path_resolved)[0] = 0));
  uint8_t * hit = 0;
  (void)((hit = link_abi_realpath_cap(((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f"), &((g_labi_freestanding_io_o_path_resolved)[0]))));
  if ((hit !=0)) {
    return hit;
  }
  uint8_t cwd[512] = {};
  uint8_t * gp = 0;
  (void)((gp = getcwd(&((cwd)[0]), 484)));
  if ((gp !=0)) {
    int32_t L = 0;
    while (((cwd)[L] !=0)) {
      (void)((L = (L + 1)));
    }
    if (((L + 27) < 512)) {
      uint8_t * suf = ((uint8_t *)"\x2f\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
      int32_t si = 0;
      while ((si <=27)) {
        (void)(((cwd)[(L + si)] = (suf)[si]));
        (void)((si = (si + 1)));
      }
      (void)((hit = link_abi_realpath_cap(&((cwd)[0]), &((g_labi_freestanding_io_o_path_resolved)[0]))));
      if ((hit !=0)) {
        return hit;
      }
    }
  }
  if ((argv0 !=0)) {
    if (((argv0)[0] !=0)) {
      int32_t i = 0;
      int32_t last_sep_i = -1;
      while (((argv0)[i] !=0)) {
        if (((argv0)[i] ==47)) {
          (void)((last_sep_i = i));
        }
        (void)((i = (i + 1)));
      }
      int32_t n = 0;
      if ((last_sep_i >=0)) {
        if ((last_sep_i >=492)) {
          return &((g_labi_freestanding_io_o_path_buf)[0]);
        }
        int32_t j = 0;
        while ((j < last_sep_i)) {
          (void)(((g_labi_freestanding_io_o_path_buf)[j] = (argv0)[j]));
          (void)((j = (j + 1)));
        }
        (void)(((g_labi_freestanding_io_o_path_buf)[last_sep_i] = 0));
        (void)((n = last_sep_i));
      } else {
        (void)(((g_labi_freestanding_io_o_path_buf)[0] = 46));
        (void)(((g_labi_freestanding_io_o_path_buf)[1] = 0));
        (void)((n = 1));
      }
      if (((n + 18) < 512)) {
        uint8_t * leaf = ((uint8_t *)"\x2f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x69\x6f\x2e\x6f");
        int32_t k = 0;
        while (((leaf)[k] !=0)) {
          (void)(((g_labi_freestanding_io_o_path_buf)[(n + k)] = (leaf)[k]));
          (void)((k = (k + 1)));
        }
        (void)(((g_labi_freestanding_io_o_path_buf)[(n + k)] = 0));
        (void)((hit = link_abi_realpath_cap(&((g_labi_freestanding_io_o_path_buf)[0]), &((g_labi_freestanding_io_o_path_resolved)[0]))));
        if ((hit !=0)) {
          return hit;
        }
        return &((g_labi_freestanding_io_o_path_buf)[0]);
      }
    }
  }
  return &((g_labi_freestanding_io_o_path_buf)[0]);
}
uint8_t * xlang_std_async_scheduler_o_path(uint8_t * argv0) {
  (void)(((g_labi_async_scheduler_o_path_buf)[0] = 0));
  (void)(((g_labi_async_scheduler_o_path_resolved)[0] = 0));
  uint8_t * hit = 0;
  (void)((hit = link_abi_realpath_cap(((uint8_t *)"\x73\x74\x64\x2f\x61\x73\x79\x6e\x63\x2f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x2e\x6f"), &((g_labi_async_scheduler_o_path_resolved)[0]))));
  if ((hit !=0)) {
    return hit;
  }
  uint8_t cwd[512] = {};
  uint8_t * gp = 0;
  (void)((gp = getcwd(&((cwd)[0]), 486)));
  if ((gp !=0)) {
    int32_t L = 0;
    while (((cwd)[L] !=0)) {
      (void)((L = (L + 1)));
    }
    if (((L + 26) <=512)) {
      uint8_t * suf = ((uint8_t *)"\x2f\x73\x74\x64\x2f\x61\x73\x79\x6e\x63\x2f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x2e\x6f");
      int32_t si = 0;
      while ((si <=22)) {
        (void)(((cwd)[(L + si)] = (suf)[si]));
        (void)((si = (si + 1)));
      }
      (void)((hit = link_abi_realpath_cap(&((cwd)[0]), &((g_labi_async_scheduler_o_path_resolved)[0]))));
      if ((hit !=0)) {
        return hit;
      }
    }
  }
  if ((argv0 !=0)) {
    if (((argv0)[0] !=0)) {
      uint8_t * rp = 0;
      (void)((rp = link_abi_realpath_cap(argv0, &((g_labi_async_scheduler_o_path_buf)[0]))));
      if ((rp !=0)) {
        int32_t i = 0;
        int32_t last_sep_i = -1;
        while (((g_labi_async_scheduler_o_path_buf)[i] !=0)) {
          if (((g_labi_async_scheduler_o_path_buf)[i] ==47)) {
            (void)((last_sep_i = i));
          }
          (void)((i = (i + 1)));
        }
        if ((last_sep_i >=0)) {
          if (((last_sep_i + 26) < 4096)) {
            (void)(((g_labi_async_scheduler_o_path_buf)[last_sep_i] = 0));
            int32_t n = last_sep_i;
            uint8_t * leaf = ((uint8_t *)"\x2f\x2e\x2e\x2f\x73\x74\x64\x2f\x61\x73\x79\x6e\x63\x2f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x2e\x6f");
            int32_t k = 0;
            while (((leaf)[k] !=0)) {
              (void)(((g_labi_async_scheduler_o_path_buf)[(n + k)] = (leaf)[k]));
              (void)((k = (k + 1)));
            }
            (void)(((g_labi_async_scheduler_o_path_buf)[(n + k)] = 0));
            (void)((hit = link_abi_realpath_cap(&((g_labi_async_scheduler_o_path_buf)[0]), &((g_labi_async_scheduler_o_path_resolved)[0]))));
            if ((hit !=0)) {
              return hit;
            }
          }
        }
      }
    }
  }
  return &((g_labi_async_scheduler_o_path_buf)[0]);
}
/* wave150/253/258: push_minimal pure orch (surface ≡ .x; always attempt user_env companion). */
void link_abi_asm_ld_push_minimal_runtime_objs(uint8_t * link_argv0, uint8_t * * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * * argv, int32_t * la, int32_t max_la) {
  uint8_t * io_p = 0;
  uint8_t * proc_p = 0;
  uint8_t * panic_p = 0;
  (void)((io_p = xlang_runtime_asm_io_stubs_o_path(link_argv0)));
  (void)((proc_p = xlang_runtime_process_argv_o_path(link_argv0)));
  (void)((panic_p = xlang_runtime_panic_o_path(link_argv0)));
  int32_t _io = link_abi_asm_ld_push_obj(io_p, link_argv0, ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73\x2e\x6f"), lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_io ==0)) {
  }
  int32_t _pa = link_abi_asm_ld_push_obj(proc_p, link_argv0, ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f"), lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_pa ==0)) {
  }
  int32_t _pn = link_abi_asm_ld_push_obj(panic_p, link_argv0, ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f"), lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
  if ((_pn ==0)) {
    /* continue: missing panic does not block user_env companion (wave258 ≡ cold twin) */
  }
  /* wave253/258: companion user-domain face (weak; residual declare-only; panic C strong wins). */
  {
    uint8_t * ue_p = 0;
    (void)((ue_p = xlang_runtime_link_abi_user_env_o_path(link_argv0)));
    int32_t _ue = link_abi_asm_ld_push_obj(ue_p, link_argv0, ((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6c\x69\x6e\x6b\x5f\x61\x62\x69\x5f\x75\x73\x65\x72\x5f\x65\x6e\x76\x2e\x6f"), lib_roots, n_lib_roots, bank, argv, la, max_la, 0);
    if ((_ue ==0)) {
    }
  }
}
void xlang_asm_ld_append_user_extra_o_files(uint8_t * * argv, int32_t * la, int32_t max_la) {
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  int32_t n = 0;
  (void)((n = link_abi_user_extra_o_count()));
  int32_t ui = 0;
  while ((ui < n)) {
    int32_t cur = (la)[0];
    if ((cur >=(max_la - 1))) {
      break;
    }
    uint8_t * p = 0;
    (void)((p = link_abi_user_extra_o_at(ui)));
    (void)((ui = (ui + 1)));
    if ((p ==0)) {
      continue;
    }
    if (((p)[0] ==0)) {
      continue;
    }
    int32_t ok = 0;
    (void)((ok = link_abi_path_readable(p)));
    if ((ok ==0)) {
      continue;
    }
    (void)(((argv)[cur] = p));
    (void)(((la)[0] = (cur + 1)));
  }
}
int32_t xlang_runtime_compiler_o_path_copy(uint8_t * argv0, uint8_t * leaf, uint8_t * out, int64_t out_sz) {
  if ((out ==0)) {
    return -1;
  }
  if ((out_sz ==0)) {
    return -1;
  }
  if ((leaf ==0)) {
    return -1;
  }
  if (((leaf)[0] ==0)) {
    return -1;
  }
  (void)(((out)[0] = 0));
  uint8_t comp_dir[4096] = {};
  int32_t rc = 0;
  (void)((rc = xlang_resolve_compiler_dir(argv0, &((comp_dir)[0]), 4096)));
  if ((rc !=0)) {
    return -1;
  }
  int32_t dn = 0;
  while (((comp_dir)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  int32_t ln = 0;
  while (((leaf)[ln] !=0)) {
    (void)((ln = (ln + 1)));
  }
  int64_t need = ((((int64_t)(dn)) + 1) + ((int64_t)(ln)));
  if ((need >=out_sz)) {
    (void)(((out)[0] = 0));
    return -1;
  }
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out)[i] = (comp_dir)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out)[dn] = 47));
  int32_t k = 0;
  while ((k <=ln)) {
    (void)(((out)[((dn + 1) + k)] = (leaf)[k]));
    (void)((k = (k + 1)));
  }
  return 0;
}
uint8_t * xlang_repo_root_from_argv0(uint8_t * argv0) {
  (void)(((g_labi_repo_root_buf)[0] = 0));
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = xlang_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc ==0)) {
    if (((comp)[0] !=0)) {
      int32_t n = 0;
      while (((comp)[n] !=0)) {
        (void)((n = (n + 1)));
      }
      if ((n < 512)) {
        int32_t i = 0;
        while ((i <=n)) {
          (void)(((g_labi_repo_root_buf)[i] = (comp)[i]));
          (void)((i = (i + 1)));
        }
        uint8_t * last = xlang_path_last_sep(&((g_labi_repo_root_buf)[0]));
        if ((last !=0)) {
          if ((last !=&((g_labi_repo_root_buf)[0]))) {
            (void)(((last)[0] = 0));
            return &((g_labi_repo_root_buf)[0]);
          }
        }
        (void)(((g_labi_repo_root_buf)[0] = 0));
      }
    }
  }
  uint8_t * rel = ((uint8_t *)"\x73\x74\x64\x2f\x70\x72\x6f\x63\x65\x73\x73\x2f\x70\x72\x6f\x63\x65\x73\x73\x2e\x6f");
  uint8_t * proc_o = 0;
  (void)((proc_o = xlang_rel_o_path_from_argv0(argv0, rel)));
  if ((proc_o ==0)) {
    return &((g_labi_repo_root_buf)[0]);
  }
  if (((proc_o)[0] ==0)) {
    return &((g_labi_repo_root_buf)[0]);
  }
  int32_t pn = 0;
  while (((proc_o)[pn] !=0)) {
    (void)((pn = (pn + 1)));
  }
  if ((pn >=512)) {
    return &((g_labi_repo_root_buf)[0]);
  }
  int32_t j = 0;
  while ((j <=pn)) {
    (void)(((g_labi_repo_root_buf)[j] = (proc_o)[j]));
    (void)((j = (j + 1)));
  }
  int32_t k = 0;
  while ((k < 3)) {
    uint8_t * last2 = xlang_path_last_sep(&((g_labi_repo_root_buf)[0]));
    if ((last2 ==0)) {
      break;
    }
    if ((last2 ==&((g_labi_repo_root_buf)[0]))) {
      break;
    }
    (void)(((last2)[0] = 0));
    (void)((k = (k + 1)));
  }
  return &((g_labi_repo_root_buf)[0]);
}
uint8_t * scheduler_o_for_task_link(uint8_t * task_o, uint8_t * explicit_scheduler) {
  if ((explicit_scheduler !=0)) {
    if (((explicit_scheduler)[0] !=0)) {
      return explicit_scheduler;
    }
  }
  if ((task_o ==0)) {
    return ((uint8_t *)(0));
  }
  if (((task_o)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  int32_t n = 0;
  while (((task_o)[n] !=0)) {
    (void)((n = (n + 1)));
  }
  if ((n >=4096)) {
    return ((uint8_t *)(0));
  }
  int32_t ci = 0;
  while ((ci <=n)) {
    (void)(((g_labi_sched_for_task_derived)[ci] = (task_o)[ci]));
    (void)((ci = (ci + 1)));
  }
  uint8_t * from = ((uint8_t *)"\x73\x74\x64\x2f\x74\x61\x73\x6b\x2f\x74\x61\x73\x6b\x2e\x6f");
  int32_t from_len = 15;
  uint8_t * to = ((uint8_t *)"\x73\x74\x64\x2f\x61\x73\x79\x6e\x63\x2f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x2e\x6f");
  int32_t to_len = 22;
  int32_t delta = 7;
  int32_t pos = -1;
  int32_t i = 0;
  while (((i + from_len) <=n)) {
    if ((pos < 0)) {
      int32_t j = 0;
      int32_t ok = 1;
      while ((j < from_len)) {
        if ((ok !=0)) {
          if (((g_labi_sched_for_task_derived)[(i + j)] !=(from)[j])) {
            (void)((ok = 0));
          }
        }
        (void)((j = (j + 1)));
      }
      if ((ok !=0)) {
        (void)((pos = i));
      }
    }
    (void)((i = (i + 1)));
  }
  if ((pos >=0)) {
    int32_t new_n = (n + delta);
    if ((new_n < 4096)) {
      int32_t si = n;
      while ((si >=(pos + from_len))) {
        (void)(((g_labi_sched_for_task_derived)[(si + delta)] = (g_labi_sched_for_task_derived)[si]));
        (void)((si = (si - 1)));
      }
      int32_t k = 0;
      while ((k < to_len)) {
        (void)(((g_labi_sched_for_task_derived)[(pos + k)] = (to)[k]));
        (void)((k = (k + 1)));
      }
      int32_t readable = 0;
      (void)((readable = link_abi_path_readable(&((g_labi_sched_for_task_derived)[0]))));
      if ((readable !=0)) {
        return &((g_labi_sched_for_task_derived)[0]);
      }
    }
  }
  (void)(((g_labi_sched_for_task_cwd)[0] = 0));
  uint8_t * hit = 0;
  (void)((hit = link_abi_realpath_cap(((uint8_t *)"\x73\x74\x64\x2f\x61\x73\x79\x6e\x63\x2f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x2e\x6f"), &((g_labi_sched_for_task_cwd)[0]))));
  if ((hit !=0)) {
    return hit;
  }
  return ((uint8_t *)(0));
}
uint8_t * xlang_bootstrap_nostdlib_stubs_o_path(uint8_t * argv0) {
  (void)(((g_labi_bootstrap_nostdlib_stubs_o_path_buf)[0] = 0));
  (void)(((g_labi_bootstrap_nostdlib_stubs_o_path_resolved)[0] = 0));
  uint8_t * hit = 0;
  (void)((hit = link_abi_realpath_cap(((uint8_t *)"\x63\x6f\x6d\x70\x69\x6c\x65\x72\x2f\x73\x72\x63\x2f\x61\x73\x6d\x2f\x62\x6f\x6f\x74\x73\x74\x72\x61\x70\x5f\x6e\x6f\x73\x74\x64\x6c\x69\x62\x5f\x73\x74\x75\x62\x73\x2e\x6f"), &((g_labi_bootstrap_nostdlib_stubs_o_path_resolved)[0]))));
  if ((hit !=0)) {
    return hit;
  }
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = xlang_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc ==0)) {
    int32_t dn = 0;
    while (((comp)[dn] !=0)) {
      (void)((dn = (dn + 1)));
    }
    uint8_t * leaf = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x62\x6f\x6f\x74\x73\x74\x72\x61\x70\x5f\x6e\x6f\x73\x74\x64\x6c\x69\x62\x5f\x73\x74\x75\x62\x73\x2e\x6f");
    int32_t ln = 0;
    while (((leaf)[ln] !=0)) {
      (void)((ln = (ln + 1)));
    }
    if ((((dn + 1) + ln) < 4096)) {
      int32_t i = 0;
      while ((i < dn)) {
        (void)(((g_labi_bootstrap_nostdlib_stubs_o_path_buf)[i] = (comp)[i]));
        (void)((i = (i + 1)));
      }
      (void)(((g_labi_bootstrap_nostdlib_stubs_o_path_buf)[dn] = 47));
      int32_t k = 0;
      while ((k <=ln)) {
        (void)(((g_labi_bootstrap_nostdlib_stubs_o_path_buf)[((dn + 1) + k)] = (leaf)[k]));
        (void)((k = (k + 1)));
      }
      (void)((hit = link_abi_realpath_cap(&((g_labi_bootstrap_nostdlib_stubs_o_path_buf)[0]), &((g_labi_bootstrap_nostdlib_stubs_o_path_resolved)[0]))));
      if ((hit !=0)) {
        return hit;
      }
      return &((g_labi_bootstrap_nostdlib_stubs_o_path_buf)[0]);
    }
  }
  return &((g_labi_bootstrap_nostdlib_stubs_o_path_buf)[0]);
}
uint8_t * xlang_runtime_asm_io_stubs_o_path(uint8_t * argv0) {
  (void)(((g_labi_asm_io_stubs_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73\x2e\x6f"), &((g_labi_asm_io_stubs_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_asm_io_stubs_o_path_buf)[0] = 0));
  }
  return &((g_labi_asm_io_stubs_o_path_buf)[0]);
}
uint8_t * xlang_runtime_process_argv_o_path(uint8_t * argv0) {
  (void)(((g_labi_process_argv_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f"), &((g_labi_process_argv_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_process_argv_o_path_buf)[0] = 0));
  }
  return &((g_labi_process_argv_o_path_buf)[0]);
}
uint8_t * xlang_runtime_process_os_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_process_os_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x6f\x73\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_process_os_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_process_os_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_process_os_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_test_fn_invoke_o_path(uint8_t * argv0) {
  (void)(((g_labi_test_fn_invoke_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x6f"), &((g_labi_test_fn_invoke_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_test_fn_invoke_o_path_buf)[0] = 0));
  }
  return &((g_labi_test_fn_invoke_o_path_buf)[0]);
}
uint8_t * xlang_runtime_random_fill_o_path(uint8_t * argv0) {
  (void)(((g_labi_random_fill_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x2e\x6f"), &((g_labi_random_fill_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_random_fill_o_path_buf)[0] = 0));
  }
  return &((g_labi_random_fill_o_path_buf)[0]);
}
uint8_t * xlang_runtime_compress_zlib_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_compress_zlib_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x6c\x69\x62\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_compress_zlib_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_compress_zlib_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_compress_zlib_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_heap_user_o_path(uint8_t * argv0) {
  (void)(((g_labi_heap_user_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72\x2e\x6f"), &((g_labi_heap_user_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_heap_user_o_path_buf)[0] = 0));
  }
  return &((g_labi_heap_user_o_path_buf)[0]);
}
uint8_t * xlang_runtime_time_os_o_path(uint8_t * argv0) {
  (void)(((g_labi_time_os_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x5f\x6f\x73\x2e\x6f"), &((g_labi_time_os_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_time_os_o_path_buf)[0] = 0));
  }
  return &((g_labi_time_os_o_path_buf)[0]);
}
uint8_t * xlang_runtime_queue_contention_o_path(uint8_t * argv0) {
  (void)(((g_labi_queue_contention_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x71\x75\x65\x75\x65\x5f\x63\x6f\x6e\x74\x65\x6e\x74\x69\x6f\x6e\x2e\x6f"), &((g_labi_queue_contention_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_queue_contention_o_path_buf)[0] = 0));
  }
  return &((g_labi_queue_contention_o_path_buf)[0]);
}
uint8_t * xlang_runtime_dynlib_os_o_path(uint8_t * argv0) {
  (void)(((g_labi_dynlib_os_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x64\x79\x6e\x6c\x69\x62\x5f\x6f\x73\x2e\x6f"), &((g_labi_dynlib_os_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_dynlib_os_o_path_buf)[0] = 0));
  }
  return &((g_labi_dynlib_os_o_path_buf)[0]);
}
uint8_t * xlang_runtime_env_os_o_path(uint8_t * argv0) {
  (void)(((g_labi_env_os_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x6e\x76\x5f\x6f\x73\x2e\x6f"), &((g_labi_env_os_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_env_os_o_path_buf)[0] = 0));
  }
  return &((g_labi_env_os_o_path_buf)[0]);
}
/* wave253/258: thin durable path for runtime_link_abi_user_env.o (companion face). */
uint8_t * xlang_runtime_link_abi_user_env_o_path(uint8_t * argv0) {
  (void)(((g_labi_link_abi_user_env_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6c\x69\x6e\x6b\x5f\x61\x62\x69\x5f\x75\x73\x65\x72\x5f\x65\x6e\x76\x2e\x6f"), &((g_labi_link_abi_user_env_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_link_abi_user_env_o_path_buf)[0] = 0));
  }
  return &((g_labi_link_abi_user_env_o_path_buf)[0]);
}
uint8_t * xlang_runtime_backtrace_platform_o_path(uint8_t * argv0) {
  (void)(((g_labi_backtrace_platform_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x62\x61\x63\x6b\x74\x72\x61\x63\x65\x5f\x70\x6c\x61\x74\x66\x6f\x72\x6d\x2e\x6f"), &((g_labi_backtrace_platform_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_backtrace_platform_o_path_buf)[0] = 0));
  }
  return &((g_labi_backtrace_platform_o_path_buf)[0]);
}
uint8_t * xlang_runtime_log_os_o_path(uint8_t * argv0) {
  (void)(((g_labi_log_os_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6c\x6f\x67\x5f\x6f\x73\x2e\x6f"), &((g_labi_log_os_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_log_os_o_path_buf)[0] = 0));
  }
  return &((g_labi_log_os_o_path_buf)[0]);
}
uint8_t * xlang_runtime_math_libm_o_path(uint8_t * argv0) {
  (void)(((g_labi_math_libm_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6d\x61\x74\x68\x5f\x6c\x69\x62\x6d\x2e\x6f"), &((g_labi_math_libm_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_math_libm_o_path_buf)[0] = 0));
  }
  return &((g_labi_math_libm_o_path_buf)[0]);
}
uint8_t * xlang_runtime_atomic_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_atomic_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_atomic_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_atomic_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_atomic_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_channel_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_channel_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_channel_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_channel_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_channel_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_net_udp_batch_o_path(uint8_t * argv0) {
  (void)(((g_labi_net_udp_batch_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x61\x74\x63\x68\x2e\x6f"), &((g_labi_net_udp_batch_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_net_udp_batch_o_path_buf)[0] = 0));
  }
  return &((g_labi_net_udp_batch_o_path_buf)[0]);
}
uint8_t * xlang_runtime_net_workers_o_path(uint8_t * argv0) {
  (void)(((g_labi_net_workers_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x77\x6f\x72\x6b\x65\x72\x73\x2e\x6f"), &((g_labi_net_workers_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_net_workers_o_path_buf)[0] = 0));
  }
  return &((g_labi_net_workers_o_path_buf)[0]);
}
uint8_t * xlang_runtime_sync_os_o_path(uint8_t * argv0) {
  (void)(((g_labi_sync_os_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6f\x73\x2e\x6f"), &((g_labi_sync_os_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_sync_os_o_path_buf)[0] = 0));
  }
  return &((g_labi_sync_os_o_path_buf)[0]);
}
uint8_t * xlang_runtime_sync_lock_diag_tls_o_path(uint8_t * argv0) {
  (void)(((g_labi_sync_lock_diag_tls_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6c\x6f\x63\x6b\x5f\x64\x69\x61\x67\x5f\x74\x6c\x73\x2e\x6f"), &((g_labi_sync_lock_diag_tls_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_sync_lock_diag_tls_o_path_buf)[0] = 0));
  }
  return &((g_labi_sync_lock_diag_tls_o_path_buf)[0]);
}
uint8_t * xlang_runtime_thread_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_thread_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x68\x72\x65\x61\x64\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_thread_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_thread_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_thread_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_scheduler_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_scheduler_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_scheduler_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_scheduler_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_scheduler_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_http_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_http_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x74\x74\x70\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_http_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_http_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_http_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_tls_mbedtls_bio_o_path(uint8_t * argv0) {
  (void)(((g_labi_tls_mbedtls_bio_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x6c\x73\x5f\x6d\x62\x65\x64\x74\x6c\x73\x5f\x62\x69\x6f\x2e\x6f"), &((g_labi_tls_mbedtls_bio_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_tls_mbedtls_bio_o_path_buf)[0] = 0));
  }
  return &((g_labi_tls_mbedtls_bio_o_path_buf)[0]);
}
uint8_t * xlang_runtime_kv_mmap_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_kv_mmap_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6b\x76\x5f\x6d\x6d\x61\x70\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_kv_mmap_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_kv_mmap_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_kv_mmap_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_arrow_simd_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_arrow_simd_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x72\x72\x6f\x77\x5f\x73\x69\x6d\x64\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_arrow_simd_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_arrow_simd_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_arrow_simd_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_sqlite_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_sqlite_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x71\x6c\x69\x74\x65\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_sqlite_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_sqlite_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_sqlite_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_crypto_inc_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_crypto_inc_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x72\x79\x70\x74\x6f\x5f\x69\x6e\x63\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_crypto_inc_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_crypto_inc_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_crypto_inc_glue_o_path_buf)[0]);
}
uint8_t * xlang_runtime_ed25519_ref10_glue_o_path(uint8_t * argv0) {
  (void)(((g_labi_ed25519_ref10_glue_o_path_buf)[0] = 0));
  int32_t rc = xlang_runtime_compiler_o_path_copy(argv0, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x64\x32\x35\x35\x31\x39\x5f\x72\x65\x66\x31\x30\x5f\x67\x6c\x75\x65\x2e\x6f"), &((g_labi_ed25519_ref10_glue_o_path_buf)[0]), 4096);
  if ((rc !=0)) {
    (void)(((g_labi_ed25519_ref10_glue_o_path_buf)[0] = 0));
  }
  return &((g_labi_ed25519_ref10_glue_o_path_buf)[0]);
}
uint8_t * xlang_empty_cstr(void) {
  (void)(((g_labi_empty_cstr_buf)[0] = 0));
  return &((g_labi_empty_cstr_buf)[0]);
}
uint8_t * xlang_std_io_o_path(uint8_t * argv0) {
  if ((argv0 !=0)) {
  }
  return xlang_empty_cstr();
}
uint8_t * xlang_std_compress_o_path(uint8_t * argv0) {
  if ((argv0 !=0)) {
  }
  return xlang_empty_cstr();
}
uint8_t * xlang_asm_ld_effective_link_argv0(uint8_t * link_argv0, uint8_t * syn_buf, int64_t syn_sz) {
  if ((link_argv0 !=0)) {
    if (((link_argv0)[0] !=0)) {
      return link_argv0;
    }
  }
  if ((syn_buf ==0)) {
    return ((uint8_t *)(0));
  }
  if ((syn_sz ==0)) {
    return ((uint8_t *)(0));
  }
  (void)(((syn_buf)[0] = 0));
  uint8_t comp_dir[4096] = {};
  int32_t rc = 0;
  (void)((rc = xlang_resolve_compiler_dir(0, &((comp_dir)[0]), 4096)));
  if ((rc !=0)) {
    return ((uint8_t *)(0));
  }
  int32_t dn = 0;
  while (((comp_dir)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  int32_t ln = 4;
  int64_t need = ((((int64_t)(dn)) + 1) + ((int64_t)(ln)));
  if ((need >=syn_sz)) {
    (void)(((syn_buf)[0] = 0));
    return ((uint8_t *)(0));
  }
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((syn_buf)[i] = (comp_dir)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((syn_buf)[dn] = 47));
  (void)(((syn_buf)[(dn + 1)] = 115));
  (void)(((syn_buf)[(dn + 2)] = 104));
  (void)(((syn_buf)[(dn + 3)] = 117));
  (void)(((syn_buf)[(dn + 4)] = 120));
  (void)(((syn_buf)[(dn + 5)] = 0));
  return syn_buf;
}
uint8_t * xlang_rel_o_path_from_argv0(uint8_t * argv0, uint8_t * rel) {
  uint8_t * empty = ((uint8_t *)"");
  if ((rel ==0)) {
    return link_abi_cstr_dup(empty);
  }
  if (((rel)[0] ==0)) {
    return link_abi_cstr_dup(empty);
  }
  int32_t rel_len = 0;
  while (((rel)[rel_len] !=0)) {
    (void)((rel_len = (rel_len + 1)));
  }
  uint8_t resolved[4096] = {};
  uint8_t * rp = 0;
  (void)((rp = link_abi_realpath_cap(rel, &((resolved)[0]))));
  if ((rp !=0)) {
    return link_abi_cstr_dup(rp);
  }
  uint8_t cwd[512] = {};
  uint8_t * gp = 0;
  (void)((gp = getcwd(&((cwd)[0]), 510)));
  if ((gp !=0)) {
    int32_t L = 0;
    while (((cwd)[L] !=0)) {
      (void)((L = (L + 1)));
    }
    if (((((L + 1) + rel_len) + 1) <=512)) {
      (void)(((cwd)[L] = 47));
      int32_t ci = 0;
      while ((ci <=rel_len)) {
        (void)(((cwd)[((L + 1) + ci)] = (rel)[ci]));
        (void)((ci = (ci + 1)));
      }
      (void)((rp = link_abi_realpath_cap(&((cwd)[0]), &((resolved)[0]))));
      if ((rp !=0)) {
        return link_abi_cstr_dup(rp);
      }
    }
  }
  if ((argv0 !=0)) {
    if (((argv0)[0] !=0)) {
      uint8_t buf[512] = {};
      int32_t i = 0;
      int32_t last_sep_i = -1;
      while (((argv0)[i] !=0)) {
        if (((argv0)[i] ==47)) {
          (void)((last_sep_i = i));
        }
        (void)((i = (i + 1)));
      }
      int32_t n = 0;
      if ((last_sep_i >=0)) {
        if ((last_sep_i >=(512 - (3 + rel_len)))) {
          return link_abi_cstr_dup(empty);
        }
        int32_t j = 0;
        while ((j < last_sep_i)) {
          (void)(((buf)[j] = (argv0)[j]));
          (void)((j = (j + 1)));
        }
        (void)(((buf)[last_sep_i] = 0));
        (void)((n = last_sep_i));
      } else {
        (void)(((buf)[0] = 46));
        (void)(((buf)[1] = 0));
        (void)((n = 1));
      }
      if ((((n + 3) + rel_len) < 512)) {
        (void)(((buf)[n] = 47));
        (void)(((buf)[(n + 1)] = 46));
        (void)(((buf)[(n + 2)] = 46));
        (void)(((buf)[(n + 3)] = 47));
        int32_t k = 0;
        while ((k <=rel_len)) {
          (void)(((buf)[((n + 4) + k)] = (rel)[k]));
          (void)((k = (k + 1)));
        }
        (void)((rp = link_abi_realpath_cap(&((buf)[0]), &((resolved)[0]))));
        if ((rp !=0)) {
          return link_abi_cstr_dup(rp);
        }
        uint8_t * sm = 0;
        (void)((sm = asm_link_obj_skip_missing(&((buf)[0]))));
        if ((sm !=0)) {
          return link_abi_cstr_dup(&((buf)[0]));
        }
        return link_abi_cstr_dup(empty);
      }
    }
  }
  return link_abi_cstr_dup(empty);
}
int32_t labi_path_pure_count(void) {
  return 58;
}

/* wave189: set/clear user_o_files pure orch (≡ .x -E polish) */
int32_t labi_user_extra_cstr_eq(uint8_t * a, uint8_t * b) {
  if ((a ==0)) {
    return 0;
  }
  if ((b ==0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 1048576)) {
    uint8_t ca = (a)[i];
    uint8_t cb = (b)[i];
    if ((ca !=cb)) {
      return 0;
    }
    if ((ca ==0)) {
      return 1;
    }
    (void)((i = (i + 1)));
  }
  return 0;
}
int32_t labi_user_extra_ends_with_dot_o(uint8_t * a) {
  if ((a ==0)) {
    return 0;
  }
  if (((a)[0] ==0)) {
    return 0;
  }
  int32_t len = 0;
  while ((len < 1048576)) {
    if (((a)[len] ==0)) {
      break;
    }
    (void)((len = (len + 1)));
  }
  if ((len < 2)) {
    return 0;
  }
  if (((a)[(len - 2)] !=46)) {
    return 0;
  }
  if (((a)[(len - 1)] !=111)) {
    return 0;
  }
  return 1;
}
void xlang_invoke_cc_set_user_o_files_from_argv(int32_t argc, uint8_t * * argv) {
  (void)(link_abi_user_extra_o_reset());
  uint8_t * ab = ((uint8_t *)(argv));
  if ((ab ==0)) {
    return;
  }
  if ((argc <=1)) {
    return;
  }
  int32_t i = 1;
  while ((i < argc)) {
    uint8_t * a = (argv)[i];
    if ((a ==0)) {
      (void)((i = (i + 1)));
      continue;
    }
    if (((a)[0] ==0)) {
      (void)((i = (i + 1)));
      continue;
    }
    if (((a)[0] ==45)) {
      int32_t two = 0;
      if ((labi_user_extra_cstr_eq(a, ((uint8_t *)"\x2d\x6f")) !=0)) {
        (void)((two = 1));
      }
      if ((labi_user_extra_cstr_eq(a, ((uint8_t *)"\x2d\x4c")) !=0)) {
        (void)((two = 1));
      }
      if ((labi_user_extra_cstr_eq(a, ((uint8_t *)"\x2d\x49")) !=0)) {
        (void)((two = 1));
      }
      if ((labi_user_extra_cstr_eq(a, ((uint8_t *)"\x2d\x74\x61\x72\x67\x65\x74")) !=0)) {
        (void)((two = 1));
      }
      if ((labi_user_extra_cstr_eq(a, ((uint8_t *)"\x2d\x62\x61\x63\x6b\x65\x6e\x64")) !=0)) {
        (void)((two = 1));
      }
      if ((labi_user_extra_cstr_eq(a, ((uint8_t *)"\x2d\x4f")) !=0)) {
        (void)((two = 1));
      }
      if ((labi_user_extra_cstr_eq(a, ((uint8_t *)"\x2d\x6f\x70\x74")) !=0)) {
        (void)((two = 1));
      }
      if ((two !=0)) {
        if (((i + 1) < argc)) {
          (void)((i = (i + 1)));
        }
      }
      (void)((i = (i + 1)));
      continue;
    }
    if ((labi_user_extra_ends_with_dot_o(a) !=0)) {
      {
        int32_t _p = link_abi_user_extra_o_push(a);
      }
    }
    (void)((i = (i + 1)));
  }
}
void xlang_invoke_cc_clear_user_o_files(void) {
  (void)(link_abi_user_extra_o_reset());
}
