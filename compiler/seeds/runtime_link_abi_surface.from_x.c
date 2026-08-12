/* seeds/runtime_link_abi_surface.from_x.c
 * G-02f runtime_link_abi R2 mixed surface - isomorphic with src/runtime_link_abi.x
 * Product PREFER_X_O: xlang_asm -E(.x) -> thin.o + ld -r with rest
 * Prove: nm IDENTICAL (145 symbols)
 * Mode: mixed - 75 DIRECT compute + 70 thin+rest forwards to _impl
 * Cap residual: 91 _impl bridges + 7 helper externs (main_entry, link_abi_getenv,
 *   xlang_host_is_linux, xlang_host_is_apple_aarch64, driver_argv_at,
 *   link_abi_generated_c_contains_substr, xlang_empty_cstr)
 * doc_anchor: not present in this module
 * Logic: 145 functions = 75 DIRECT compute
 *   (link_abi_user_o_needs_*, link_abi_generated_c_needs_*, xlang_output_is_elf_o,
 *    xlang_asm_ld_lib_root_default, driver_copy_cstr_n, xlang_path_has_sep,
 *    xlang_path_last_sep, link_diag_code_for_kind, xlang_invoke_cc, ...)
 *   + 70 thin+rest forwards to _impl (30 xlang_ensure_runtime_*, 12 link_diag_*,
 *    2 xlang_ensure_crt0/freestanding_io, xlang_asm_ld_effective_link_argv0,
 *    xlang_runtime_asm_io_stubs_o_path, xlang_runtime_process_argv_o_path,
 *    xlang_linux_host_gcc_path, xlang_linux_ld_child_path,
 *    xlang_runtime_o_realpath_if_exists, xlang_runtime_compiler_o_path_copy,
 *    link_abi_link_needs_heap_user_c, link_abi_link_needs_std_heap_import,
 *    link_abi_asm_ld_argv_has_obj, link_abi_asm_ld_argv_push_stable,
 *    link_abi_asm_ld_push_obj, xlang_cc_compile_sync, xlang_link_perror,
 *    ld_append_brew_lib_paths, link_abi_generated_c_contains_any_substr,
 *    link_abi_asm_ld_push_glue_after_std, link_abi_asm_ld_push_minimal_runtime_objs,
 *    xlang_cc_compile_sync_ex, xlang_asm_nostdlib_minimal_selfcontained_exe_link,
 *    xlang_debug_hello_stage1_report, xlang_waitpid_retry, ensure_std_net_o_auto_tls)
 * Regen: xlang_asm -E src/runtime_link_abi.x | filter DBG + polish prologue
 */
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
#include <sys/uio.h>
#include <poll.h>
#include <dirent.h>
#endif
/* Forward declarations for all 145 surface functions (nm IDENTICAL targets). */
extern int32_t xlang_forward_main_to_main_entry(int32_t argc, uint8_t * argv);
extern int32_t xlang_freestanding_user_o_needs_panic(uint8_t * user_o);
extern int32_t xlang_freestanding_user_o_needs_io(uint8_t * user_o);
extern int32_t invoke_cc_skip_native_tuning(void);
extern int32_t xlang_link_freestanding_enabled(int32_t driver_freestanding);
extern int32_t link_abi_user_o_needs_libc_heap(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_map(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_set(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_queue(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_test(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_core_mem(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_core_slice(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_heap_page_mmap(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_sys_linux(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_sys(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_net(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_std_heap_api(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_heap_user_syms(uint8_t * user_o);
extern int32_t link_abi_user_o_needs_async_scheduler(uint8_t * user_o);
extern int32_t link_abi_obj_needs_zlib(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_zstd(uint8_t * obj_o);
extern int32_t link_abi_obj_needs_brotli(uint8_t * obj_o);
extern int32_t link_abi_user_o_needs_compress_libs(uint8_t * user_o);
extern int32_t link_abi_generated_c_needs_core_builtin(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_core_mem(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_libc_heap(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_win32(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_win32_wsa(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_db_kv(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_db_arrow(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_core_slice(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_fs(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_zlib(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_zstd(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_brotli(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_random(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_time(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_runtime(uint8_t * c_path);
extern int32_t xlang_generated_c_needs_async_scheduler(uint8_t * c_path);
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern int32_t driver_get_argv_i(int32_t argc, uint8_t * argv, int32_t i, uint8_t * buf, int32_t max);
extern int32_t driver_resolve_target_arch(int32_t parsed_target, int32_t saw_target_flag);
extern void bootstrap_init_static_tls(void);
extern void bootstrap_init_environ(int32_t argc, uint8_t * argv);
extern int32_t bootstrap_nostdlib_pthread_is_stub(void);
extern uint8_t * xlang_std_io_o_path(uint8_t * argv0);
extern uint8_t * xlang_std_compress_o_path(uint8_t * argv0);
extern uint8_t * xlang_asm_ld_effective_link_argv0(uint8_t * link_argv0, uint8_t * syn_buf, int32_t syn_sz);
extern uint8_t * xlang_asm_ld_bank_push(uint8_t * b, uint8_t * path);
extern uint8_t * xlang_runtime_asm_io_stubs_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_process_argv_o_path(uint8_t * argv0);
extern int32_t xlang_output_is_elf_o(uint8_t * path);
extern int32_t xlang_output_want_exe(uint8_t * path);
extern int32_t xlang_path_is_nonempty_regular_file(uint8_t * path);
extern int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s);
extern int32_t xlang_invoke_ld_for_exe(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots);
extern void xlang_asm_ld_append_mach_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, uint8_t * argv, int32_t * la, int32_t max_la, int32_t append_lsystem);
extern void xlang_asm_ld_append_unix_gcc_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, int32_t need_pt, uint8_t * argv, int32_t * la, int32_t max_la);
extern int32_t xlang_ensure_runtime_arrow_simd_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_asm_io_stubs_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_atomic_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_backtrace_platform_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_channel_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_compress_zlib_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_crypto_inc_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_dynlib_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_ed25519_ref10_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_env_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_heap_user_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_http_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_kv_mmap_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_log_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_math_libm_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_net_udp_batch_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_net_workers_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_panic_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_process_argv_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_process_os_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_queue_contention_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_random_fill_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_scheduler_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sqlite_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sync_lock_diag_tls_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sync_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_test_fn_invoke_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_thread_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_time_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_tls_mbedtls_bio_o(uint8_t * argv0);
extern int32_t xlang_ensure_crt0_user_o(uint8_t * argv0, int32_t driver_freestanding);
extern int32_t xlang_ensure_freestanding_io_o(uint8_t * argv0, int32_t driver_freestanding);
extern int32_t xlang_waitpid_retry(int64_t pid, int32_t * status_out);
extern int32_t xlang_asm_user_o_has_undef_syms(uint8_t * o_path);
extern void asm_ld_append_compress_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * argv, int32_t * la, int32_t max_la);
extern void invoke_cc_append_compress_ld(uint8_t * argv, int32_t * i, int32_t argv_cap, uint8_t * compress_o, uint8_t * user_o);
extern int32_t invoke_cc_argv_push_existing(uint8_t * argv, int32_t * ia, int32_t max_ia, uint8_t * path);
extern int32_t xlang_asm_ld_prepare_for_exe_link(uint8_t * link_eff, uint8_t * user_o, int32_t driver_freestanding, int32_t use_macho_o, int32_t use_coff_o);
extern int32_t xlang_resolve_compiler_dir(uint8_t * argv0, uint8_t * out_dir, int64_t out_dir_sz);
extern int32_t xlang_asm_invoke_ld_platform(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, int32_t driver_freestanding);
extern void xlang_asm_ld_append_std_objs(uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * flags);
extern void xlang_asm_ld_append_on_demand_user_objs(uint8_t * link_argv0, uint8_t * user_o, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * flags);
extern int32_t invoke_cc_append_net_tls_ld(uint8_t * argv, int32_t * i, int32_t argv_cap, uint8_t * net_o, uint8_t * repo_root);
extern void ensure_std_net_o_auto_tls(uint8_t * repo_root);
extern int32_t xlang_invoke_cc(uint8_t * c_paths, int32_t n, uint8_t * out_path, uint8_t * target, uint8_t * opt_level, int32_t use_lto, uint8_t * io_o, uint8_t * fs_o, uint8_t * process_o, uint8_t * string_o, uint8_t * heap_o, uint8_t * path_o, uint8_t * runtime_o, uint8_t * runtime_panic_o, uint8_t * net_o, uint8_t * thread_o, uint8_t * time_o, uint8_t * random_o, uint8_t * env_o, uint8_t * sync_o, uint8_t * encoding_o, uint8_t * base64_o, uint8_t * crypto_o, uint8_t * log_o, uint8_t * atomic_o, uint8_t * channel_o, uint8_t * backtrace_o, uint8_t * hash_o, uint8_t * math_o, uint8_t * sort_o, uint8_t * ffi_o, uint8_t * db_o, uint8_t * elf_o, uint8_t * json_o, uint8_t * csv_o, uint8_t * regex_o, uint8_t * compress_o, uint8_t * unicode_o, uint8_t * dynlib_o, uint8_t * http_o, uint8_t * tar_o, uint8_t * simd_o, uint8_t * context_o, uint8_t * datetime_o, uint8_t * uuid_o, uint8_t * url_o, uint8_t * cli_o, uint8_t * security_o, uint8_t * config_o, uint8_t * cache_o, uint8_t * trace_o, uint8_t * task_o, uint8_t * schema_o, uint8_t * test_o, uint8_t * include_root, uint8_t * async_scheduler_o);
extern void xlang_append_linux_link_harden(uint8_t * argv, int32_t * la, int32_t cap);
extern int32_t xlang_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym);
extern int32_t xlang_link_obj_has_defined_sym(uint8_t * o_path, uint8_t * sym);
extern void link_diag_tool_status(uint8_t * tool, int32_t status);
extern void link_diag_runtime_source_missing(uint8_t * obj_name, uint8_t * source_path);
extern void link_diag_runtime_source_missing_under(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix);
extern void link_diag_runtime_obj_missing(uint8_t * obj_name, uint8_t * out_o);
extern void link_diag_runtime_obj_resolve_fail(uint8_t * obj_name, uint8_t * hint);
extern void link_diag_runtime_obj_build_status(uint8_t * obj_name, int32_t status);
extern void link_diag_errno(uint8_t * kind, uint8_t * op);
extern void link_diag_errno_path(uint8_t * kind, uint8_t * op, uint8_t * path);
extern void link_diag_freestanding_missing(uint8_t * obj_name, uint8_t * symbol_name);
extern void link_diag_freestanding_unsupported(void);
extern void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path);
extern void link_diag_ld_debug_argv(uint8_t * label, uint8_t * argv);
extern void xlang_asm_ld_lib_root_default(uint8_t * root_buf);
extern uint8_t * xlang_linux_host_gcc_path(void);
extern void xlang_linux_ld_child_path(void);
extern uint8_t * xlang_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved);
extern int32_t xlang_runtime_compiler_o_path_copy(uint8_t * argv0, uint8_t * leaf, uint8_t * out, int64_t out_sz);
extern int32_t link_abi_link_needs_heap_user_c(uint8_t * user_o, uint8_t * argv, int32_t la);
extern int32_t link_abi_link_needs_std_heap_import(uint8_t * user_o, uint8_t * argv, int32_t la);
extern int32_t link_abi_asm_ld_argv_has_obj(uint8_t * argv, int32_t la, uint8_t * path);
extern void link_abi_asm_ld_argv_push_stable(uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * p);
extern int32_t link_abi_asm_ld_push_obj(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, int32_t * flag_out);
extern int32_t xlang_cc_compile_sync(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s);
extern int32_t xlang_spawn_sync(uint8_t * prog, uint8_t * argv);
extern void xlang_link_perror(uint8_t * msg);
extern void ld_append_brew_lib_paths(uint8_t * argv, int32_t * la, int32_t max_la);
extern int32_t link_abi_generated_c_contains_any_substr(uint8_t * c_path, uint8_t * needles, int32_t n_needles);
extern void link_abi_asm_ld_push_glue_after_std(int32_t have_std, uint8_t * ensure_fn, uint8_t * glue_primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la);
extern void link_abi_asm_ld_push_minimal_runtime_objs(uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la);
extern int32_t xlang_cc_compile_sync_ex(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s, uint8_t * extra_flags);
extern int32_t xlang_asm_nostdlib_minimal_selfcontained_exe_link(uint8_t * o_path, uint8_t * exe_path, uint8_t * link_eff, uint8_t * lib_roots, int32_t n_lib_roots);
extern int32_t link_abi_obj_exports_marker(uint8_t * obj_o, uint8_t * marker);
extern int32_t link_abi_obj_has_undef_sym(uint8_t * obj_o, uint8_t * sym);
extern void xlang_debug_hello_stage1_report(void);
extern int32_t xlang_asm_ld_lib_root_ptr_usable(uint8_t * p);
extern int32_t driver_copy_cstr_n(uint8_t * src, uint8_t * buf, int32_t max);
extern int32_t xlang_path_has_sep(uint8_t * s);
extern uint8_t * xlang_path_last_sep(uint8_t * s);
extern uint8_t * link_diag_code_for_kind(uint8_t * kind);
/* Cap residual bridges: 91 _impl forwards + 7 helper externs (defined in rest C). */
extern int32_t main_entry(int32_t argc, uint8_t * argv);
extern int32_t xlang_link_obj_needs_undef_sym_impl(uint8_t * user_o, uint8_t * sym);
extern int32_t xlang_link_obj_has_defined_sym_impl(uint8_t * o_path, uint8_t * sym);
extern uint8_t * link_abi_getenv(uint8_t * name);
extern int32_t xlang_host_is_linux(void);
extern int32_t xlang_host_is_apple_aarch64(void);
extern uint8_t * driver_argv_at(uint8_t * argv, int32_t i);
extern int32_t xlang_path_is_nonempty_regular_file_impl(uint8_t * path);
extern int32_t link_abi_obj_exports_marker_impl(uint8_t * obj_o, uint8_t * marker);
extern int32_t link_abi_obj_has_undef_sym_impl(uint8_t * obj_o, uint8_t * sym);
extern int32_t link_abi_generated_c_contains_substr(uint8_t * c_path, uint8_t * needle);
extern uint8_t * xlang_empty_cstr(void);
extern uint8_t * xlang_asm_ld_bank_push_impl(uint8_t * b, uint8_t * path);
extern uint8_t * xlang_runtime_asm_io_stubs_o_path_impl(uint8_t * argv0);
extern uint8_t * xlang_runtime_process_argv_o_path_impl(uint8_t * argv0);
extern uint8_t * xlang_asm_ld_effective_link_argv0_impl(uint8_t * link_argv0, uint8_t * syn_buf, int32_t syn_sz);
extern int32_t xlang_invoke_ld_for_exe_impl(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots);
extern void xlang_asm_ld_append_mach_tail_libs_impl(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, uint8_t * argv, int32_t * la, int32_t max_la, int32_t append_lsystem);
extern void xlang_asm_ld_append_unix_gcc_tail_libs_impl(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, int32_t need_pt, uint8_t * argv, int32_t * la, int32_t max_la);
extern int32_t xlang_ensure_runtime_arrow_simd_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_asm_io_stubs_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_atomic_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_backtrace_platform_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_channel_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_compress_zlib_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_crypto_inc_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_dynlib_os_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_ed25519_ref10_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_env_os_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_heap_user_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_http_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_kv_mmap_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_log_os_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_math_libm_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_net_udp_batch_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_net_workers_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_panic_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_process_argv_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_process_os_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_queue_contention_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_random_fill_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_scheduler_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sqlite_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sync_lock_diag_tls_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sync_os_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_test_fn_invoke_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_thread_glue_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_time_os_o_impl(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_tls_mbedtls_bio_o_impl(uint8_t * argv0);
extern void link_diag_tool_status_impl(uint8_t * tool, int32_t status);
extern void link_diag_runtime_source_missing_impl(uint8_t * obj_name, uint8_t * source_path);
extern void link_diag_runtime_source_missing_under_impl(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix);
extern void link_diag_runtime_obj_missing_impl(uint8_t * obj_name, uint8_t * out_o);
extern void link_diag_runtime_obj_resolve_fail_impl(uint8_t * obj_name, uint8_t * hint);
extern void link_diag_runtime_obj_build_status_impl(uint8_t * obj_name, int32_t status);
extern void link_diag_errno_impl(uint8_t * kind, uint8_t * op);
extern void link_diag_errno_path_impl(uint8_t * kind, uint8_t * op, uint8_t * path);
extern void link_diag_freestanding_missing_impl(uint8_t * obj_name, uint8_t * symbol_name);
extern void link_diag_freestanding_unsupported_impl(void);
extern void link_diag_ld_debug_push_impl(uint8_t * rel, uint8_t * stage, uint8_t * path);
extern void link_diag_ld_debug_argv_impl(uint8_t * label, uint8_t * argv);
extern int32_t xlang_asm_ld_lib_root_ptr_usable_impl(uint8_t * p);
extern void xlang_asm_ld_lib_root_default_impl(uint8_t * root_buf);
extern uint8_t * xlang_linux_host_gcc_path_impl(void);
extern void xlang_linux_ld_child_path_impl(void);
extern uint8_t * xlang_runtime_o_realpath_if_exists_impl(uint8_t * path, uint8_t * resolved);
extern int32_t xlang_runtime_compiler_o_path_copy_impl(uint8_t * argv0, uint8_t * leaf, uint8_t * out, int64_t out_sz);
extern int32_t link_abi_link_needs_heap_user_c_impl(uint8_t * user_o, uint8_t * argv, int32_t la);
extern int32_t link_abi_link_needs_std_heap_import_impl(uint8_t * user_o, uint8_t * argv, int32_t la);
extern int32_t link_abi_asm_ld_argv_has_obj_impl(uint8_t * argv, int32_t la, uint8_t * path);
extern void link_abi_asm_ld_argv_push_stable_impl(uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * p);
extern int32_t link_abi_asm_ld_push_obj_impl(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, int32_t * flag_out);
extern int32_t xlang_cc_compile_sync_impl(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s);
extern int32_t xlang_spawn_sync_impl(uint8_t * prog, uint8_t * argv);
extern void xlang_link_perror_impl(uint8_t * msg);
extern void ld_append_brew_lib_paths_impl(uint8_t * argv, int32_t * la, int32_t max_la);
extern int32_t link_abi_generated_c_contains_any_substr_impl(uint8_t * c_path, uint8_t * needles, int32_t n_needles);
extern void link_abi_asm_ld_push_glue_after_std_impl(int32_t have_std, uint8_t * ensure_fn, uint8_t * glue_primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la);
extern void link_abi_asm_ld_push_minimal_runtime_objs_impl(uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la);
extern int32_t xlang_cc_compile_sync_ex_impl(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s, uint8_t * extra_flags);
extern int32_t xlang_asm_nostdlib_minimal_selfcontained_exe_link_impl(uint8_t * o_path, uint8_t * exe_path, uint8_t * link_eff, uint8_t * lib_roots, int32_t n_lib_roots);
int32_t xlang_forward_main_to_main_entry(int32_t argc, uint8_t * argv) {
  {
    int32_t r = main_entry(argc, argv);
    return r;
  }
  return 0;
}
int32_t xlang_freestanding_user_o_needs_panic(uint8_t * user_o) {
  {
    int32_t r = xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x70\x61\x6e\x69\x63\x5f"));
    return r;
  }
  return 0;
}
int32_t xlang_freestanding_user_o_needs_io(uint8_t * user_o) {
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x72\x65\x61\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x63\x6c\x6f\x73\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x65\x78\x69\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x6f\x70\x65\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x6f\x70\x65\x6e\x61\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x6d\x6d\x61\x70")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x6d\x75\x6e\x6d\x61\x70")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x73\x6f\x63\x6b\x65\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x63\x6f\x6e\x6e\x65\x63\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x62\x69\x6e\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x6c\x69\x73\x74\x65\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x73\x79\x73\x5f\x61\x63\x63\x65\x70\x74")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t invoke_cc_skip_native_tuning(void) {
  {
    uint8_t * a = link_abi_getenv(((uint8_t *)"\x43\x49"));
    if ((a !=0)) {
      return 1;
    }
    uint8_t * b = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x43\x49\x5f\x44\x4f\x43\x4b\x45\x52"));
    if ((b !=0)) {
      return 1;
    }
    uint8_t * c = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x4e\x4f\x5f\x4d\x41\x52\x43\x48\x5f\x4e\x41\x54\x49\x56\x45"));
    if ((c !=0)) {
      return 1;
    }
    return 0;
  }
  return 0;
}
int32_t xlang_link_freestanding_enabled(int32_t driver_freestanding) {
  {
    if ((xlang_host_is_linux() ==0)) {
      return 0;
    }
    if ((driver_freestanding !=0)) {
      return 1;
    }
    uint8_t * e = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x46\x52\x45\x45\x53\x54\x41\x4e\x44\x49\x4e\x47"));
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
int32_t link_abi_user_o_needs_libc_heap(uint8_t * user_o) {
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6d\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x72\x65\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x66\x72\x65\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x70\x6f\x73\x69\x78\x5f\x6d\x65\x6d\x61\x6c\x69\x67\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x67\x65\x74\x65\x6e\x76")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_map(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x65\x6d\x70\x74\x79\x5f\x73\x69\x7a\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x6e\x65\x77\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x77\x69\x74\x68\x5f\x63\x61\x70\x61\x63\x69\x74\x79\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x69\x6e\x73\x65\x72\x74\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x67\x65\x74\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x66\x69\x6e\x64\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x64\x65\x69\x6e\x69\x74\x5f\x4d\x61\x70\x5f\x69\x33\x32\x5f\x69\x33\x32\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x73\x74\x72\x5f\x6e\x65\x77")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6d\x61\x70\x5f\x73\x74\x72\x5f\x69\x6e\x73\x65\x72\x74")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_set(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6e\x65\x77\x5f\x69\x33\x32\x5f\x72\x65\x74\x53\x65\x74\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6e\x65\x77\x5f\x69\x33\x32\x5f\x72\x65\x74\x53\x65\x74\x5f\x75\x36\x34")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x77\x69\x74\x68\x5f\x63\x61\x70\x61\x63\x69\x74\x79\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x69\x6e\x73\x65\x72\x74\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x69\x6e\x73\x65\x72\x74\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x70\x74\x72\x5f\x75\x36\x34")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x63\x6f\x6e\x74\x61\x69\x6e\x73\x5f\x6b\x65\x79\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x63\x6f\x6e\x74\x61\x69\x6e\x73\x5f\x6b\x65\x79\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x75\x36\x34")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x72\x65\x6d\x6f\x76\x65\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x72\x65\x6d\x6f\x76\x65\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x70\x74\x72\x5f\x75\x36\x34")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6c\x65\x6e\x67\x74\x68\x5f\x53\x65\x74\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x6c\x65\x6e\x67\x74\x68\x5f\x53\x65\x74\x5f\x75\x36\x34")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x64\x65\x69\x6e\x69\x74\x5f\x53\x65\x74\x5f\x69\x33\x32\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x64\x65\x69\x6e\x69\x74\x5f\x53\x65\x74\x5f\x75\x36\x34\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x74\x72\x5f\x6e\x65\x77")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x74\x72\x5f\x69\x6e\x73\x65\x72\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x69\x6e\x73\x65\x72\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x63\x6f\x6e\x74\x61\x69\x6e\x73")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x72\x65\x6d\x6f\x76\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x6c\x65\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x65\x74\x5f\x73\x65\x74\x5f\x69\x33\x32\x5f\x64\x65\x69\x6e\x69\x74")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_queue(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x6e\x65\x77\x5f\x72\x65\x74\x51\x75\x65\x75\x65\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x6e\x65\x77\x5f\x72\x65\x74\x51\x75\x65\x75\x65\x5f\x75\x38")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x75\x73\x68\x5f\x62\x61\x63\x6b\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32\x5f\x70\x74\x72\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x75\x73\x68\x5f\x62\x61\x63\x6b\x5f\x51\x75\x65\x75\x65\x5f\x75\x38\x5f\x70\x74\x72\x5f\x75\x38")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x75\x73\x68\x5f\x66\x72\x6f\x6e\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x6f\x70\x5f\x66\x72\x6f\x6e\x74\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x70\x6f\x70\x5f\x62\x61\x63\x6b")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x67\x65\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x6c\x65\x6e\x67\x74\x68\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x69\x73\x5f\x65\x6d\x70\x74\x79\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x64\x65\x69\x6e\x69\x74\x5f\x51\x75\x65\x75\x65\x5f\x69\x33\x32\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x71\x75\x65\x75\x65\x5f\x77\x69\x74\x68\x5f\x63\x61\x70\x61\x63\x69\x74\x79")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_test(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x74\x65\x73\x74\x5f\x63\x61\x6c\x6c\x5f\x69\x33\x32\x5f\x76\x6f\x69\x64\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x74\x65\x73\x74\x5f\x72\x75\x6e\x6e\x65\x72\x5f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x74\x65\x73\x74\x5f\x65\x78\x70\x65\x63\x74\x5f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x74\x65\x73\x74\x5f\x62\x65\x6e\x63\x68\x5f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x74\x65\x73\x74\x5f\x66\x5f\x74\x65\x73\x74\x5f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x74\x65\x73\x74\x5f\x69\x6f\x5f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x74\x65\x73\x74\x5f\x66\x75\x7a\x7a\x5f")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_core_mem(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x61\x6c\x69\x67\x6e\x5f\x75\x70")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x61\x6c\x69\x67\x6e\x5f\x64\x6f\x77\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x63\x6f\x70\x79")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x73\x65\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x7a\x65\x72\x6f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x6d\x6f\x76\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x6d\x65\x6d\x5f\x6d\x65\x6d\x5f\x63\x6f\x6d\x70\x61\x72\x65")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_core_slice(uint8_t * user_o) {
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_heap_page_mmap(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x69\x6e\x69\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x64\x65\x69\x6e\x69\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x70\x61\x67\x65\x5f\x6d\x6d\x61\x70\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_sys_linux(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x69\x6e\x76\x6f\x6b\x65\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x61\x6e\x6f\x6e\x79\x6d\x6f\x75\x73\x5f\x6d\x6d\x61\x70")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x6d\x75\x6e\x6d\x61\x70")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x72\x65\x61\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x77\x72\x69\x74\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x63\x6c\x6f\x73\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x65\x78\x69\x74")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_sys(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65\x5f\x73\x74\x64\x6f\x75\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65\x5f\x73\x74\x64\x65\x72\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x77\x72\x69\x74\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x72\x65\x61\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x63\x6c\x6f\x73\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x65\x78\x69\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x66\x72\x65\x65\x73\x74\x61\x6e\x64\x69\x6e\x67\x5f\x77\x72\x69\x74\x65\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x73\x79\x73\x5f\x6c\x69\x6e\x75\x78\x5f\x73\x79\x73\x63\x61\x6c\x6c\x5f\x74\x61\x62\x6c\x65\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_net(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x6c\x69\x73\x74\x65\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x63\x6f\x6e\x6e\x65\x63\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x69\x6e\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x72\x65\x63\x76\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x73\x65\x6e\x64\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x61\x64\x64\x72\x5f\x74\x6f\x5f\x75\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x6e\x65\x74\x5f\x63\x6c\x6f\x73\x65\x5f\x75\x64\x70")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x73\x74\x72\x65\x61\x6d\x5f\x77\x72\x69\x74\x65\x5f\x62\x61\x74\x63\x68\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x74\x63\x70\x5f\x63\x6f\x6e\x6e\x65\x63\x74\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x74\x63\x70\x5f\x6c\x69\x73\x74\x65\x6e\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x69\x6e\x64\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x72\x65\x63\x76\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x73\x65\x6e\x64\x5f\x6d\x61\x6e\x79\x5f\x62\x75\x66\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x63\x6c\x6f\x73\x65\x5f\x73\x6f\x63\x6b\x65\x74\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x75\x64\x70\x5f\x73\x65\x6e\x64\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x64\x6e\x73\x5f\x72\x65\x73\x6f\x6c\x76\x65\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x6e\x65\x74\x5f\x73\x6f\x63\x6b\x5f\x63\x72\x65\x61\x74\x65\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_std_heap_api(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x38")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x38")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x73\x69\x7a\x65\x5f\x7a\x65\x72\x6f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x73\x69\x7a\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x38\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x64\x65\x66\x61\x75\x6c\x74\x5f\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6b\x69\x6e\x64\x5f\x61\x72\x65\x6e\x61")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x41\x6c\x6c\x6f\x63\x61\x74\x6f\x72\x5f\x75\x73\x69\x7a\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x72\x65\x61\x6c\x6c\x6f\x63\x5f\x41\x6c\x6c\x6f\x63\x61\x74\x6f\x72\x5f\x75\x38\x5f\x70\x74\x72\x5f\x75\x73\x69\x7a\x65")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x41\x6c\x6c\x6f\x63\x61\x74\x6f\x72\x5f\x75\x38\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x61\x6c\x6c\x6f\x63\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x61\x6c\x69\x67\x6e\x65\x64\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x69\x33\x32\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x38\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x75\x36\x34\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x69\x33\x32\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x38\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x75\x36\x34\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6d\x61\x70\x5f\x66\x69\x6e\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x73\x74\x64\x5f\x68\x65\x61\x70\x5f\x6c\x69\x62\x63\x5f\x68\x65\x61\x70\x5f\x63\x6f\x70\x79\x5f\x75\x38\x5f\x61\x74\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_heap_user_syms(uint8_t * user_o) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x68\x65\x61\x70\x5f\x72\x65\x61\x6c\x6c\x6f\x63\x5f\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x36\x34\x5f\x61\x6c\x6c\x6f\x63\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_async_scheduler(uint8_t * user_o) {
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67\x5f\x6a\x6d\x70")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x63\x70\x73\x5f\x73\x75\x73\x70\x65\x6e\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x70\x68\x61\x73\x65\x5f\x62\x79\x5f\x69\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x73\x74\x6f\x72\x65\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x6c\x6f\x61\x64\x5f\x74\x6f\x5f\x70\x74\x72")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x61\x73\x6d\x5f\x66\x72\x61\x6d\x65\x5f\x72\x65\x73\x65\x74\x5f\x62\x79\x5f\x69\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x63\x70\x73\x5f\x73\x75\x73\x70\x65\x6e\x64\x5f\x69\x6f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x74\x61\x73\x6b\x5f\x73\x75\x62\x6d\x69\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x74\x61\x73\x6b\x5f\x73\x75\x62\x6d\x69\x74\x5f\x74\x6f")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x64\x72\x61\x69\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x77\x6f\x72\x6b\x65\x72\x5f\x64\x72\x61\x69\x6e")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x77\x6f\x72\x6b\x65\x72\x5f\x63\x6f\x75\x6e\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x77\x6f\x72\x6b\x65\x72\x5f\x70\x65\x6e\x64\x69\x6e\x67")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x71\x75\x65\x75\x65\x5f\x72\x65\x73\x65\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x70\x65\x6e\x64\x69\x6e\x67")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x69\x6f\x5f\x77\x61\x6b\x65\x5f\x61\x6c\x6c")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x69\x6f\x5f\x77\x61\x69\x74\x65\x72\x73\x5f\x70\x65\x6e\x64\x69\x6e\x67")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x69\x6f\x6e\x73\x5f\x72\x65\x61\x64\x79")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x73\x65\x74\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x72\x65\x73\x65\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x70\x75\x73\x68\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x70\x75\x73\x68\x5f\x75\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x70\x75\x73\x68\x5f\x69\x36\x34")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x76\x61\x6c\x69\x64")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x75\x33\x32")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f\x74\x61\x6b\x65\x5f\x69\x36\x34")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x69\x6f\x5f\x73\x75\x62\x6d\x69\x74\x5f\x72\x65\x61\x64\x5f\x61\x73\x79\x6e\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x72\x65\x61\x64\x5f\x61\x73\x79\x6e\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x72\x65\x61\x64\x5f\x61\x73\x79\x6e\x63\x5f\x73\x6c\x6f\x74")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x69\x6f\x5f\x73\x75\x62\x6d\x69\x74\x5f\x77\x72\x69\x74\x65\x5f\x61\x73\x79\x6e\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x77\x72\x69\x74\x65\x5f\x61\x73\x79\x6e\x63")) !=0)) {
    return 1;
  }
  if ((xlang_link_obj_needs_undef_sym_impl(user_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x69\x6f\x5f\x63\x6f\x6d\x70\x6c\x65\x74\x65\x5f\x77\x72\x69\x74\x65\x5f\x61\x73\x79\x6e\x63\x5f\x73\x6c\x6f\x74")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_obj_needs_zlib(uint8_t * obj_o) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  if ((link_abi_obj_exports_marker(obj_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x6c\x69\x62\x5f\x6d\x61\x72\x6b\x65\x72")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x32")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x5f\x64\x65\x66\x6c\x61\x74\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x5f\x69\x6e\x66\x6c\x61\x74\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x5f\x75\x6e\x63\x6f\x6d\x70\x72\x65\x73\x73")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_obj_needs_zstd(uint8_t * obj_o) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  if ((link_abi_obj_exports_marker(obj_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x73\x74\x64\x5f\x6d\x61\x72\x6b\x65\x72")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x5a\x53\x54\x44\x5f")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x5f\x5a\x53\x54\x44")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_obj_needs_brotli(uint8_t * obj_o) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  if ((link_abi_obj_exports_marker(obj_o, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x62\x72\x6f\x74\x6c\x69\x5f\x6d\x61\x72\x6b\x65\x72")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x45\x6e\x63\x6f\x64\x65\x72\x43\x6f\x6d\x70\x72\x65\x73\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_obj_has_undef_sym(obj_o, ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x44\x65\x63\x6f\x64\x65\x72\x44\x65\x63\x6f\x6d\x70\x72\x65\x73\x73")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_user_o_needs_compress_libs(uint8_t * user_o) {
  if ((link_abi_obj_needs_zlib(user_o) !=0)) {
    return 1;
  }
  if ((link_abi_obj_needs_zstd(user_o) !=0)) {
    return 1;
  }
  if ((link_abi_obj_needs_brotli(user_o) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_core_builtin(uint8_t * c_path) {
  return 0;
}
int32_t link_abi_generated_c_needs_core_mem(uint8_t * c_path) {
  return 0;
}
int32_t link_abi_generated_c_needs_libc_heap(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x6d\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x72\x65\x61\x6c\x6c\x6f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x70\x6f\x73\x69\x78\x5f\x6d\x65\x6d\x61\x6c\x69\x67\x6e")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x68\x65\x61\x70\x5f\x66\x72\x65\x65\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x68\x65\x61\x70\x5f\x72\x65\x61\x6c\x6c\x6f\x63\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x7a\x65\x72\x6f\x65\x64\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x67\x65\x74\x65\x6e\x76")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_win32(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x47\x65\x74\x53\x74\x64\x48\x61\x6e\x64\x6c\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x57\x72\x69\x74\x65\x46\x69\x6c\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x43\x72\x65\x61\x74\x65\x46\x69\x6c\x65\x41")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x52\x65\x61\x64\x46\x69\x6c\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x43\x6c\x6f\x73\x65\x48\x61\x6e\x64\x6c\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x45\x78\x69\x74\x50\x72\x6f\x63\x65\x73\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x77\x72\x69\x74\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x72\x65\x61\x64\x5f\x66\x69\x6c\x65\x5f\x69\x6e\x74\x6f")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x65\x78\x69\x74\x5f\x70\x72\x6f\x63\x65\x73\x73")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_win32_wsa(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x57\x53\x41\x53\x74\x61\x72\x74\x75\x70")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x57\x53\x41\x43\x6c\x65\x61\x6e\x75\x70")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x77\x69\x6e\x33\x32\x5f\x6e\x65\x74\x5f\x61\x76\x61\x69\x6c\x61\x62\x6c\x65")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_db_kv(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x6f\x70\x65\x6e\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x70\x75\x74\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x67\x65\x74\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x61\x70\x70\x65\x6e\x64\x5f\x74\x73\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x77\x61\x6c\x5f\x66\x6c\x75\x73\x68\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x63\x6f\x6d\x70\x61\x63\x74\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x62\x5f\x6b\x76\x5f\x73\x73\x74\x5f\x6c\x65\x76\x65\x6c\x5f\x63\x6f\x75\x6e\x74\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_db_arrow(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x63\x6f\x6c\x75\x6d\x6e\x5f")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x62\x61\x74\x63\x68\x5f")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x61\x72\x72\x6f\x77\x5f\x73\x6d\x6f\x6b\x65\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_core_slice(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x69\x33\x32\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x38\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x66\x72\x6f\x6d\x5f\x70\x74\x72\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x6f\x72\x65\x5f\x73\x75\x62\x73\x6c\x69\x63\x65\x5f\x75\x36\x34\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_fs(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x66\x73\x5f\x6f\x70\x65\x6e\x5f\x72\x65\x61\x64\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x66\x73\x5f\x6c\x61\x73\x74\x5f\x65\x72\x72\x6f\x72\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x66\x73\x5f\x63\x6c\x6f\x73\x65\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x66\x73\x5f\x72\x65\x61\x64\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x66\x73\x5f\x77\x72\x69\x74\x65\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_zlib(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x32")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5f\x64\x65\x66\x6c\x61\x74\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5f\x69\x6e\x66\x6c\x61\x74\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5f\x75\x6e\x63\x6f\x6d\x70\x72\x65\x73\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x63\x6f\x6d\x70\x72\x65\x73\x73\x32")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x64\x65\x66\x6c\x61\x74\x65\x49\x6e\x69\x74")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x69\x6e\x66\x6c\x61\x74\x65\x49\x6e\x69\x74")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_zstd(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5a\x53\x54\x44\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5a\x53\x54\x44\x5f\x64\x65\x63\x6f\x6d\x70\x72\x65\x73\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5a\x53\x54\x44\x5f\x63\x72\x65\x61\x74\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5a\x53\x54\x44\x5f\x66\x72\x65\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x5a\x53\x54\x44\x5f\x69\x73\x45\x72\x72\x6f\x72")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_brotli(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x45\x6e\x63\x6f\x64\x65\x72")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x42\x72\x6f\x74\x6c\x69\x44\x65\x63\x6f\x64\x65\x72")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_random(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x72\x6e\x67\x5f\x73\x6d\x6f\x6b\x65\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x5f\x62\x79\x74\x65\x73\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x72\x61\x6e\x64\x6f\x6d\x5f\x75\x36\x34\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_time(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x73\x74\x64\x5f\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x74\x69\x6d\x65\x7a\x6f\x6e\x65\x5f\x73\x6d\x6f\x6b\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x6d\x6f\x6e\x6f\x74\x6f\x6e\x69\x63\x5f\x6e\x73\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x74\x69\x6d\x65\x5f\x73\x6c\x65\x65\x70\x5f\x6d\x73\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x74\x69\x6d\x65\x5f\x64\x75\x72\x61\x74\x69\x6f\x6e\x5f\x6e\x73\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x74\x69\x6d\x65\x5f\x6e\x6f\x77\x5f\x77\x61\x6c\x6c\x5f\x6e\x73\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x74\x69\x6d\x65\x5f\x66\x6f\x72\x6d\x61\x74\x5f\x74\x69\x6d\x65\x7a\x6f\x6e\x65\x5f\x73\x6d\x6f\x6b\x65\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t link_abi_generated_c_needs_runtime(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x72\x61\x73\x68\x5f\x65\x76\x69\x64\x65\x6e\x63\x65\x5f\x63\x6f\x6c\x6c\x65\x63\x74\x5f\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x62\x6f\x72\x74")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
int32_t xlang_generated_c_needs_async_scheduler(uint8_t * c_path) {
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x69\x33\x32")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x63\x70\x73\x5f\x73\x75\x73\x70\x65\x6e\x64")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x74\x61\x73\x6b\x5f\x73\x75\x62\x6d\x69\x74")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x73\x65\x65\x64\x5f")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67\x5f\x6a\x6d\x70")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x63\x6f\x6f\x70\x5f\x70\x69\x6e\x67\x70\x6f\x6e\x67")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x72\x75\x6e\x5f\x64\x72\x61\x69\x6e\x5f\x75\x6e\x74\x69\x6c\x5f\x69\x64\x6c\x65")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x71\x75\x65\x75\x65\x5f\x72\x65\x73\x65\x74")) !=0)) {
    return 1;
  }
  if ((link_abi_generated_c_contains_substr(c_path, ((uint8_t *)"\x78\x6c\x61\x6e\x67\x5f\x61\x73\x79\x6e\x63\x5f\x62\x69\x6e\x64\x5f\x63\x6f\x6e\x74\x65\x78\x74\x5f\x63")) !=0)) {
    return 1;
  }
  return 0;
  return 0;
}
uint8_t * asm_link_obj_skip_missing(uint8_t * path) {
  if ((path ==0)) {
    return ((uint8_t *)(0));
  }
  if (((path)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  if ((xlang_path_is_nonempty_regular_file(path) ==0)) {
    return ((uint8_t *)(0));
  }
  return path;
  return ((uint8_t *)(0));
}
int32_t driver_get_argv_i(int32_t argc, uint8_t * argv, int32_t i, uint8_t * buf, int32_t max) {
  if ((argv ==0)) {
    return -1;
  }
  if ((buf ==0)) {
    return -1;
  }
  if ((max <=0)) {
    return -1;
  }
  if ((i < 0)) {
    return -1;
  }
  if ((i >=argc)) {
    return -1;
  }
  {
    uint8_t * s = driver_argv_at(argv, i);
    if ((s ==0)) {
      return -1;
    }
    int32_t r = driver_copy_cstr_n(s, buf, max);
    return r;
  }
  return -1;
}
int32_t driver_resolve_target_arch(int32_t parsed_target, int32_t saw_target_flag) {
  if ((saw_target_flag !=0)) {
    return parsed_target;
  }
  if ((xlang_host_is_apple_aarch64() !=0)) {
    return 1;
  }
  return parsed_target;
  return parsed_target;
}
void bootstrap_init_static_tls(void) {
}
void bootstrap_init_environ(int32_t argc, uint8_t * argv) {
}
int32_t bootstrap_nostdlib_pthread_is_stub(void) {
  return 0;
}
uint8_t * xlang_std_io_o_path(uint8_t * argv0) {
  return xlang_empty_cstr();
  return ((uint8_t *)(0));
}
uint8_t * xlang_std_compress_o_path(uint8_t * argv0) {
  return xlang_empty_cstr();
  return ((uint8_t *)(0));
}
uint8_t * xlang_asm_ld_effective_link_argv0(uint8_t * link_argv0, uint8_t * syn_buf, int32_t syn_sz) {
  return xlang_asm_ld_effective_link_argv0_impl(link_argv0, syn_buf, syn_sz);
  return ((uint8_t *)(0));
}
uint8_t * xlang_asm_ld_bank_push(uint8_t * b, uint8_t * path) {
  if ((b ==0)) {
    return ((uint8_t *)(0));
  }
  if ((path ==0)) {
    return ((uint8_t *)(0));
  }
  if (((path)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  return xlang_asm_ld_bank_push_impl(b, path);
  return ((uint8_t *)(0));
}
uint8_t * xlang_runtime_asm_io_stubs_o_path(uint8_t * argv0) {
  return xlang_runtime_asm_io_stubs_o_path_impl(argv0);
  return ((uint8_t *)(0));
}
uint8_t * xlang_runtime_process_argv_o_path(uint8_t * argv0) {
  return xlang_runtime_process_argv_o_path_impl(argv0);
  return ((uint8_t *)(0));
}
int32_t xlang_output_is_elf_o(uint8_t * path) {
  if ((path ==0)) {
    return 0;
  }
  {
    int64_t n = 0;
    while (((path)[n] !=0)) {
      (void)((n = (n + 1)));
    }
    if ((n >=2)) {
      if (((path)[(n - 2)] ==46)) {
        if (((path)[(n - 1)] ==111)) {
          return 1;
        }
        if (((path)[(n - 1)] ==79)) {
          return 1;
        }
      }
    }
    if ((n >=4)) {
      if (((path)[(n - 4)] ==46)) {
        if (((path)[(n - 3)] ==111)) {
          if (((path)[(n - 2)] ==98)) {
            if (((path)[(n - 1)] ==106)) {
              return 1;
            }
          }
        }
      }
    }
    return 0;
  }
  return 0;
}
int32_t xlang_output_want_exe(uint8_t * path) {
  if ((path ==0)) {
    return 0;
  }
  {
    if (((path)[0] ==0)) {
      return 0;
    }
    int64_t n = 0;
    while (((path)[n] !=0)) {
      (void)((n = (n + 1)));
    }
    if ((n >=2)) {
      if (((path)[(n - 2)] ==46)) {
        if (((path)[(n - 1)] ==111)) {
          return 0;
        }
        if (((path)[(n - 1)] ==79)) {
          return 0;
        }
        if (((path)[(n - 1)] ==115)) {
          return 0;
        }
      }
    }
    if ((n >=4)) {
      if (((path)[(n - 4)] ==46)) {
        if (((path)[(n - 3)] ==111)) {
          if (((path)[(n - 2)] ==98)) {
            if (((path)[(n - 1)] ==106)) {
              return 0;
            }
          }
        }
      }
    }
    return 1;
  }
  return 0;
}
int32_t xlang_path_is_nonempty_regular_file(uint8_t * path) {
  if ((path ==0)) {
    return 0;
  }
  if (((path)[0] ==0)) {
    return 0;
  }
  return xlang_path_is_nonempty_regular_file_impl(path);
  return 0;
}
int32_t link_abi_ld_argv_entry_is_obj(uint8_t * s) {
  if ((s ==0)) {
    return 0;
  }
  {
    if (((s)[0] ==0)) {
      return 0;
    }
    int64_t n = 0;
    while (((s)[n] !=0)) {
      (void)((n = (n + 1)));
    }
    if ((n >=2)) {
      if (((s)[(n - 2)] ==46)) {
        if (((s)[(n - 1)] ==111)) {
          return 1;
        }
      }
    }
    if ((n >=4)) {
      if (((s)[(n - 4)] ==46)) {
        if (((s)[(n - 3)] ==111)) {
          if (((s)[(n - 2)] ==98)) {
            if (((s)[(n - 1)] ==106)) {
              return 1;
            }
          }
        }
      }
    }
    return 0;
  }
  return 0;
}
int32_t xlang_invoke_ld_for_exe(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots) {
  if ((o_path ==0)) {
    return -1;
  }
  if ((exe_path ==0)) {
    return -1;
  }
  return xlang_invoke_ld_for_exe_impl(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots);
  return -1;
}
void xlang_asm_ld_append_mach_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, uint8_t * argv, int32_t * la, int32_t max_la, int32_t append_lsystem) {
  if ((flags ==0)) {
    return;
  }
  if ((argv ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  if ((*(la) < 0)) {
    return;
  }
  (void)(xlang_asm_ld_append_mach_tail_libs_impl(compress_o, user_o, flags, argv, la, max_la, append_lsystem));
}
void xlang_asm_ld_append_unix_gcc_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, int32_t need_pt, uint8_t * argv, int32_t * la, int32_t max_la) {
  if ((flags ==0)) {
    return;
  }
  if ((argv ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  if ((*(la) < 0)) {
    return;
  }
  (void)(xlang_asm_ld_append_unix_gcc_tail_libs_impl(compress_o, user_o, flags, need_pt, argv, la, max_la));
}
extern int32_t xlang_ensure_crt0_user_o_impl(uint8_t * argv0, int32_t driver_freestanding);
extern int32_t xlang_ensure_freestanding_io_o_impl(uint8_t * argv0, int32_t driver_freestanding);
extern int32_t xlang_waitpid_retry_impl(int64_t pid, int32_t * status_out);
extern int32_t xlang_asm_user_o_has_undef_syms_impl(uint8_t * o_path);
extern void asm_ld_append_compress_libs_impl(uint8_t * compress_o, uint8_t * user_o, uint8_t * argv, int32_t * la, int32_t max_la);
extern void invoke_cc_append_compress_ld_impl(uint8_t * argv, int32_t * i, int32_t argv_cap, uint8_t * compress_o, uint8_t * user_o);
extern int32_t invoke_cc_argv_push_existing_impl(uint8_t * argv, int32_t * ia, int32_t max_ia, uint8_t * path);
extern int32_t xlang_asm_ld_prepare_for_exe_link_impl(uint8_t * link_eff, uint8_t * user_o, int32_t driver_freestanding, int32_t use_macho_o, int32_t use_coff_o);
int32_t xlang_ensure_runtime_arrow_simd_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_arrow_simd_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_asm_io_stubs_o(uint8_t * argv0) {
  return xlang_ensure_runtime_asm_io_stubs_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_atomic_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_atomic_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_backtrace_platform_o(uint8_t * argv0) {
  return xlang_ensure_runtime_backtrace_platform_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_channel_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_channel_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_compress_zlib_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_compress_zlib_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_crypto_inc_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_crypto_inc_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_dynlib_os_o(uint8_t * argv0) {
  return xlang_ensure_runtime_dynlib_os_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_ed25519_ref10_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_ed25519_ref10_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_env_os_o(uint8_t * argv0) {
  return xlang_ensure_runtime_env_os_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_heap_user_o(uint8_t * argv0) {
  return xlang_ensure_runtime_heap_user_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_http_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_http_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_kv_mmap_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_kv_mmap_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_log_os_o(uint8_t * argv0) {
  return xlang_ensure_runtime_log_os_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_math_libm_o(uint8_t * argv0) {
  return xlang_ensure_runtime_math_libm_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_net_udp_batch_o(uint8_t * argv0) {
  return xlang_ensure_runtime_net_udp_batch_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_net_workers_o(uint8_t * argv0) {
  return xlang_ensure_runtime_net_workers_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_panic_o(uint8_t * argv0) {
  return xlang_ensure_runtime_panic_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_process_argv_o(uint8_t * argv0) {
  return xlang_ensure_runtime_process_argv_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_process_os_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_process_os_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_queue_contention_o(uint8_t * argv0) {
  return xlang_ensure_runtime_queue_contention_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_random_fill_o(uint8_t * argv0) {
  return xlang_ensure_runtime_random_fill_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_scheduler_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_scheduler_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_sqlite_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_sqlite_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_sync_lock_diag_tls_o(uint8_t * argv0) {
  return xlang_ensure_runtime_sync_lock_diag_tls_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_sync_os_o(uint8_t * argv0) {
  return xlang_ensure_runtime_sync_os_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_test_fn_invoke_o(uint8_t * argv0) {
  return xlang_ensure_runtime_test_fn_invoke_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_thread_glue_o(uint8_t * argv0) {
  return xlang_ensure_runtime_thread_glue_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_time_os_o(uint8_t * argv0) {
  return xlang_ensure_runtime_time_os_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_runtime_tls_mbedtls_bio_o(uint8_t * argv0) {
  return xlang_ensure_runtime_tls_mbedtls_bio_o_impl(argv0);
  return -1;
}
int32_t xlang_ensure_crt0_user_o(uint8_t * argv0, int32_t driver_freestanding) {
  return xlang_ensure_crt0_user_o_impl(argv0, driver_freestanding);
  return -1;
}
int32_t xlang_ensure_freestanding_io_o(uint8_t * argv0, int32_t driver_freestanding) {
  return xlang_ensure_freestanding_io_o_impl(argv0, driver_freestanding);
  return -1;
}
extern int32_t xlang_resolve_compiler_dir_impl(uint8_t * argv0, uint8_t * out_dir, int64_t out_dir_sz);
extern int32_t xlang_asm_invoke_ld_platform_impl(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, int32_t driver_freestanding);
extern void xlang_asm_ld_append_std_objs_impl(uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * flags);
extern void xlang_asm_ld_append_on_demand_user_objs_impl(uint8_t * link_argv0, uint8_t * user_o, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * flags);
extern int32_t invoke_cc_append_net_tls_ld_impl(uint8_t * argv, int32_t * i, int32_t argv_cap, uint8_t * net_o, uint8_t * repo_root);
extern void ensure_std_net_o_auto_tls_impl(uint8_t * repo_root);
int32_t xlang_waitpid_retry(int64_t pid, int32_t * status_out) {
  return xlang_waitpid_retry_impl(pid, status_out);
  return -1;
}
int32_t xlang_asm_user_o_has_undef_syms(uint8_t * o_path) {
  if ((o_path ==0)) {
    return 1;
  }
  return xlang_asm_user_o_has_undef_syms_impl(o_path);
  return 1;
}
void asm_ld_append_compress_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * argv, int32_t * la, int32_t max_la) {
  if ((argv ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  (void)(asm_ld_append_compress_libs_impl(compress_o, user_o, argv, la, max_la));
}
void invoke_cc_append_compress_ld(uint8_t * argv, int32_t * i, int32_t argv_cap, uint8_t * compress_o, uint8_t * user_o) {
  if ((argv ==0)) {
    return;
  }
  if ((i ==0)) {
    return;
  }
  (void)(invoke_cc_append_compress_ld_impl(argv, i, argv_cap, compress_o, user_o));
}
int32_t invoke_cc_argv_push_existing(uint8_t * argv, int32_t * ia, int32_t max_ia, uint8_t * path) {
  if ((argv ==0)) {
    return 0;
  }
  if ((ia ==0)) {
    return 0;
  }
  return invoke_cc_argv_push_existing_impl(argv, ia, max_ia, path);
  return 0;
}
int32_t xlang_asm_ld_prepare_for_exe_link(uint8_t * link_eff, uint8_t * user_o, int32_t driver_freestanding, int32_t use_macho_o, int32_t use_coff_o) {
  if ((link_eff ==0)) {
    return -1;
  }
  if ((user_o ==0)) {
    return -1;
  }
  return xlang_asm_ld_prepare_for_exe_link_impl(link_eff, user_o, driver_freestanding, use_macho_o, use_coff_o);
  return -1;
}
extern int32_t xlang_invoke_cc_impl(uint8_t * c_paths, int32_t n, uint8_t * out_path, uint8_t * target, uint8_t * opt_level, int32_t use_lto, uint8_t * io_o, uint8_t * fs_o, uint8_t * process_o, uint8_t * string_o, uint8_t * heap_o, uint8_t * path_o, uint8_t * runtime_o, uint8_t * runtime_panic_o, uint8_t * net_o, uint8_t * thread_o, uint8_t * time_o, uint8_t * random_o, uint8_t * env_o, uint8_t * sync_o, uint8_t * encoding_o, uint8_t * base64_o, uint8_t * crypto_o, uint8_t * log_o, uint8_t * atomic_o, uint8_t * channel_o, uint8_t * backtrace_o, uint8_t * hash_o, uint8_t * math_o, uint8_t * sort_o, uint8_t * ffi_o, uint8_t * db_o, uint8_t * elf_o, uint8_t * json_o, uint8_t * csv_o, uint8_t * regex_o, uint8_t * compress_o, uint8_t * unicode_o, uint8_t * dynlib_o, uint8_t * http_o, uint8_t * tar_o, uint8_t * simd_o, uint8_t * context_o, uint8_t * datetime_o, uint8_t * uuid_o, uint8_t * url_o, uint8_t * cli_o, uint8_t * security_o, uint8_t * config_o, uint8_t * cache_o, uint8_t * trace_o, uint8_t * task_o, uint8_t * schema_o, uint8_t * test_o, uint8_t * include_root, uint8_t * async_scheduler_o);
extern void xlang_append_linux_link_harden_impl(uint8_t * argv, int32_t * la, int32_t cap);
int32_t xlang_resolve_compiler_dir(uint8_t * argv0, uint8_t * out_dir, int64_t out_dir_sz) {
  if ((out_dir ==0)) {
    return -1;
  }
  if ((out_dir_sz ==0)) {
    return -1;
  }
  return xlang_resolve_compiler_dir_impl(argv0, out_dir, out_dir_sz);
  return -1;
}
int32_t xlang_asm_invoke_ld_platform(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, int32_t driver_freestanding) {
  if ((o_path ==0)) {
    return -1;
  }
  if ((exe_path ==0)) {
    return -1;
  }
  return xlang_asm_invoke_ld_platform_impl(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots, driver_freestanding);
  return -1;
}
void xlang_asm_ld_append_std_objs(uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * flags) {
  if ((argv ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  if ((flags ==0)) {
    return;
  }
  (void)(xlang_asm_ld_append_std_objs_impl(link_argv0, lib_roots, n_lib_roots, bank, argv, la, max_la, flags));
}
void xlang_asm_ld_append_on_demand_user_objs(uint8_t * link_argv0, uint8_t * user_o, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * flags) {
  if ((user_o ==0)) {
    return;
  }
  if ((argv ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  if ((flags ==0)) {
    return;
  }
  (void)(xlang_asm_ld_append_on_demand_user_objs_impl(link_argv0, user_o, lib_roots, n_lib_roots, bank, argv, la, max_la, flags));
}
int32_t invoke_cc_append_net_tls_ld(uint8_t * argv, int32_t * i, int32_t argv_cap, uint8_t * net_o, uint8_t * repo_root) {
  if ((argv ==0)) {
    return 0;
  }
  if ((i ==0)) {
    return 0;
  }
  return invoke_cc_append_net_tls_ld_impl(argv, i, argv_cap, net_o, repo_root);
  return 0;
}
void ensure_std_net_o_auto_tls(uint8_t * repo_root) {
  (void)(ensure_std_net_o_auto_tls_impl(repo_root));
}
/* Stage 12.2.3: early host-cc gate (G.7 ≡ labi_gates_surface / labi_invoke_cc_list). */
extern int32_t invoke_cc_host_cc_spawn_gate(void);
int32_t xlang_invoke_cc(uint8_t * c_paths, int32_t n, uint8_t * out_path, uint8_t * target, uint8_t * opt_level, int32_t use_lto, uint8_t * io_o, uint8_t * fs_o, uint8_t * process_o, uint8_t * string_o, uint8_t * heap_o, uint8_t * path_o, uint8_t * runtime_o, uint8_t * runtime_panic_o, uint8_t * net_o, uint8_t * thread_o, uint8_t * time_o, uint8_t * random_o, uint8_t * env_o, uint8_t * sync_o, uint8_t * encoding_o, uint8_t * base64_o, uint8_t * crypto_o, uint8_t * log_o, uint8_t * atomic_o, uint8_t * channel_o, uint8_t * backtrace_o, uint8_t * hash_o, uint8_t * math_o, uint8_t * sort_o, uint8_t * ffi_o, uint8_t * db_o, uint8_t * elf_o, uint8_t * json_o, uint8_t * csv_o, uint8_t * regex_o, uint8_t * compress_o, uint8_t * unicode_o, uint8_t * dynlib_o, uint8_t * http_o, uint8_t * tar_o, uint8_t * simd_o, uint8_t * context_o, uint8_t * datetime_o, uint8_t * uuid_o, uint8_t * url_o, uint8_t * cli_o, uint8_t * security_o, uint8_t * config_o, uint8_t * cache_o, uint8_t * trace_o, uint8_t * task_o, uint8_t * schema_o, uint8_t * test_o, uint8_t * include_root, uint8_t * async_scheduler_o) {
  if ((c_paths ==0)) {
    return -1;
  }
  if ((out_path ==0)) {
    return -1;
  }
  /* Early deny: skip heavy impl ensure/argv when host-cc is not opt-in. */
  if ((invoke_cc_host_cc_spawn_gate() == 0)) {
    return -1;
  }
  return xlang_invoke_cc_impl(c_paths, n, out_path, target, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, include_root, async_scheduler_o);
  return -1;
}
void xlang_append_linux_link_harden(uint8_t * argv, int32_t * la, int32_t cap) {
  if ((argv ==0)) {
    return;
  }
  if ((la ==0)) {
    return;
  }
  (void)(xlang_append_linux_link_harden_impl(argv, la, cap));
}
int32_t xlang_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym) {
  if ((user_o ==0)) {
    return 0;
  }
  if (((user_o)[0] ==0)) {
    return 0;
  }
  if ((sym ==0)) {
    return 0;
  }
  if (((sym)[0] ==0)) {
    return 0;
  }
  return xlang_link_obj_needs_undef_sym_impl(user_o, sym);
  return 0;
}
int32_t xlang_link_obj_has_defined_sym(uint8_t * o_path, uint8_t * sym) {
  if ((o_path ==0)) {
    return 0;
  }
  if (((o_path)[0] ==0)) {
    return 0;
  }
  if ((sym ==0)) {
    return 0;
  }
  if (((sym)[0] ==0)) {
    return 0;
  }
  return xlang_link_obj_has_defined_sym_impl(o_path, sym);
  return 0;
}
void link_diag_tool_status(uint8_t * tool, int32_t status) {
  (void)(link_diag_tool_status_impl(tool, status));
}
void link_diag_runtime_source_missing(uint8_t * obj_name, uint8_t * source_path) {
  (void)(link_diag_runtime_source_missing_impl(obj_name, source_path));
}
void link_diag_runtime_source_missing_under(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix) {
  (void)(link_diag_runtime_source_missing_under_impl(obj_name, base_dir, suffix));
}
void link_diag_runtime_obj_missing(uint8_t * obj_name, uint8_t * out_o) {
  (void)(link_diag_runtime_obj_missing_impl(obj_name, out_o));
}
void link_diag_runtime_obj_resolve_fail(uint8_t * obj_name, uint8_t * hint) {
  (void)(link_diag_runtime_obj_resolve_fail_impl(obj_name, hint));
}
void link_diag_runtime_obj_build_status(uint8_t * obj_name, int32_t status) {
  (void)(link_diag_runtime_obj_build_status_impl(obj_name, status));
}
void link_diag_errno(uint8_t * kind, uint8_t * op) {
  (void)(link_diag_errno_impl(kind, op));
}
void link_diag_errno_path(uint8_t * kind, uint8_t * op, uint8_t * path) {
  (void)(link_diag_errno_path_impl(kind, op, path));
}
void link_diag_freestanding_missing(uint8_t * obj_name, uint8_t * symbol_name) {
  (void)(link_diag_freestanding_missing_impl(obj_name, symbol_name));
}
void link_diag_freestanding_unsupported(void) {
  (void)(link_diag_freestanding_unsupported_impl());
}
void link_diag_ld_debug_push(uint8_t * rel, uint8_t * stage, uint8_t * path) {
  (void)(link_diag_ld_debug_push_impl(rel, stage, path));
}
void link_diag_ld_debug_argv(uint8_t * label, uint8_t * argv) {
  (void)(link_diag_ld_debug_argv_impl(label, argv));
}
void xlang_asm_ld_lib_root_default(uint8_t * root_buf) {
  (void)(((root_buf)[0] = 46));
  (void)(((root_buf)[1] = 0));
  uint8_t * def = 0;
  (void)((def = link_abi_getenv(((uint8_t *)"\x58\x4c\x41\x4e\x47\x5f\x4c\x49\x42"))));
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
uint8_t * xlang_linux_host_gcc_path(void) {
  return xlang_linux_host_gcc_path_impl();
  return ((uint8_t *)(0));
}
void xlang_linux_ld_child_path(void) {
  (void)(xlang_linux_ld_child_path_impl());
}
uint8_t * xlang_runtime_o_realpath_if_exists(uint8_t * path, uint8_t * resolved) {
  return xlang_runtime_o_realpath_if_exists_impl(path, resolved);
  return ((uint8_t *)(0));
}
int32_t xlang_runtime_compiler_o_path_copy(uint8_t * argv0, uint8_t * leaf, uint8_t * out, int64_t out_sz) {
  return xlang_runtime_compiler_o_path_copy_impl(argv0, leaf, out, out_sz);
  return 0;
}
int32_t link_abi_link_needs_heap_user_c(uint8_t * user_o, uint8_t * argv, int32_t la) {
  return link_abi_link_needs_heap_user_c_impl(user_o, argv, la);
  return 0;
}
int32_t link_abi_link_needs_std_heap_import(uint8_t * user_o, uint8_t * argv, int32_t la) {
  return link_abi_link_needs_std_heap_import_impl(user_o, argv, la);
  return 0;
}
int32_t link_abi_asm_ld_argv_has_obj(uint8_t * argv, int32_t la, uint8_t * path) {
  return link_abi_asm_ld_argv_has_obj_impl(argv, la, path);
  return 0;
}
void link_abi_asm_ld_argv_push_stable(uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, uint8_t * p) {
  (void)(link_abi_asm_ld_argv_push_stable_impl(bank, argv, la, max_la, p));
}
int32_t link_abi_asm_ld_push_obj(uint8_t * primary, uint8_t * link_argv0, uint8_t * rel, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la, int32_t * flag_out) {
  return link_abi_asm_ld_push_obj_impl(primary, link_argv0, rel, lib_roots, n_lib_roots, bank, argv, la, max_la, flag_out);
  return 0;
}
int32_t xlang_cc_compile_sync(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s) {
  return xlang_cc_compile_sync_impl(src, out_o, inc0, inc1, inc2, from_asm_s);
  return -1;
}
int32_t xlang_spawn_sync(uint8_t * prog, uint8_t * argv) {
  if ((prog ==0)) {
    return -1;
  }
  if (((prog)[0] ==0)) {
    return -1;
  }
  if ((argv ==0)) {
    return -1;
  }
  return xlang_spawn_sync_impl(prog, argv);
  return -1;
}
void xlang_link_perror(uint8_t * msg) {
  (void)(xlang_link_perror_impl(msg));
}
void ld_append_brew_lib_paths(uint8_t * argv, int32_t * la, int32_t max_la) {
  (void)(ld_append_brew_lib_paths_impl(argv, la, max_la));
}
int32_t link_abi_generated_c_contains_any_substr(uint8_t * c_path, uint8_t * needles, int32_t n_needles) {
  return link_abi_generated_c_contains_any_substr_impl(c_path, needles, n_needles);
  return 0;
}
void link_abi_asm_ld_push_glue_after_std(int32_t have_std, uint8_t * ensure_fn, uint8_t * glue_primary, uint8_t * link_argv0, uint8_t * glue_rel, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la) {
  (void)(link_abi_asm_ld_push_glue_after_std_impl(have_std, ensure_fn, glue_primary, link_argv0, glue_rel, lib_roots, n_lib_roots, bank, argv, la, max_la));
}
void link_abi_asm_ld_push_minimal_runtime_objs(uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots, uint8_t * bank, uint8_t * argv, int32_t * la, int32_t max_la) {
  (void)(link_abi_asm_ld_push_minimal_runtime_objs_impl(link_argv0, lib_roots, n_lib_roots, bank, argv, la, max_la));
}
int32_t xlang_cc_compile_sync_ex(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s, uint8_t * extra_flags) {
  return xlang_cc_compile_sync_ex_impl(src, out_o, inc0, inc1, inc2, from_asm_s, extra_flags);
  return -1;
}
int32_t xlang_asm_nostdlib_minimal_selfcontained_exe_link(uint8_t * o_path, uint8_t * exe_path, uint8_t * link_eff, uint8_t * lib_roots, int32_t n_lib_roots) {
  return xlang_asm_nostdlib_minimal_selfcontained_exe_link_impl(o_path, exe_path, link_eff, lib_roots, n_lib_roots);
  return -1;
}
int32_t link_abi_obj_exports_marker(uint8_t * obj_o, uint8_t * marker) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  if ((marker ==0)) {
    return 0;
  }
  if (((marker)[0] ==0)) {
    return 0;
  }
  return link_abi_obj_exports_marker_impl(obj_o, marker);
  return 0;
}
int32_t link_abi_obj_has_undef_sym(uint8_t * obj_o, uint8_t * sym) {
  if ((obj_o ==0)) {
    return 0;
  }
  if (((obj_o)[0] ==0)) {
    return 0;
  }
  if ((sym ==0)) {
    return 0;
  }
  if (((sym)[0] ==0)) {
    return 0;
  }
  return link_abi_obj_has_undef_sym_impl(obj_o, sym);
  return 0;
}
extern void xlang_debug_hello_stage1_report_impl(void);
void xlang_debug_hello_stage1_report(void) {
  (void)(xlang_debug_hello_stage1_report_impl());
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
int32_t driver_copy_cstr_n(uint8_t * src, uint8_t * buf, int32_t max) {
  if ((src ==0)) {
    return -1;
  }
  if ((buf ==0)) {
    return -1;
  }
  if ((max <=0)) {
    return -1;
  }
  int32_t n = (max - 1);
  int32_t j = 0;
  while ((j < n)) {
    uint8_t c = (src)[j];
    if ((c ==0)) {
      break;
    }
    (void)(((buf)[j] = c));
    (void)((j = (j + 1)));
  }
  (void)(((buf)[j] = 0));
  return j;
}
int32_t xlang_path_has_sep(uint8_t * s) {
  if ((s ==0)) {
    return 0;
  }
  int32_t i = 0;
  while ((i < 4096)) {
    uint8_t c = (s)[i];
    if ((c ==0)) {
      break;
    }
    if ((c ==47)) {
      return 1;
    }
    if ((c ==92)) {
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
  uint8_t * last = 0;
  int32_t i = 0;
  while ((i < 4096)) {
    uint8_t c = (s)[i];
    if ((c ==0)) {
      break;
    }
    if ((c ==47)) {
      (void)((last = (s + i)));
    }
    if ((c ==92)) {
      (void)((last = (s + i)));
    }
    (void)((i = (i + 1)));
  }
  return last;
}
uint8_t * link_diag_code_for_kind(uint8_t * kind) {
  if ((kind ==0)) {
    return ((uint8_t *)"\x50\x52\x43\x30\x30\x31");
  }
  if ((((((((((((((kind)[0] ==98) && ((kind)[1] ==117)) && ((kind)[2] ==105)) && ((kind)[3] ==108)) && ((kind)[4] ==100)) && ((kind)[5] ==32)) && ((kind)[6] ==101)) && ((kind)[7] ==114)) && ((kind)[8] ==114)) && ((kind)[9] ==111)) && ((kind)[10] ==114)) && ((kind)[11] ==0))) {
    return ((uint8_t *)"\x42\x4c\x44\x30\x30\x31");
  }
  if ((((((((((((((((kind)[0] ==112) && ((kind)[1] ==114)) && ((kind)[2] ==111)) && ((kind)[3] ==99)) && ((kind)[4] ==101)) && ((kind)[5] ==115)) && ((kind)[6] ==115)) && ((kind)[7] ==32)) && ((kind)[8] ==101)) && ((kind)[9] ==114)) && ((kind)[10] ==114)) && ((kind)[11] ==111)) && ((kind)[12] ==114)) && ((kind)[13] ==0))) {
    return ((uint8_t *)"\x50\x52\x43\x30\x30\x31");
  }
  return ((uint8_t *)(0));
}
