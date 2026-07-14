/* seeds/labi_gates_surface.from_x.c
 * G-02f labi_gates R2 full surface — isomorphic with src/runtime/labi_gates.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_gates.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (6 thin gates + count)
 * Cap residual: *_impl bodies in mega runtime_link_abi.from_x.c rest
 * Regen: ./shux -E ... src/runtime/labi_gates.x | tail -n +4 (skip -E includes)
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern uint8_t * shux_asm_ld_bank_push(uint8_t * b, uint8_t * path);
extern int32_t shux_invoke_cc(uint8_t * c_paths, int32_t n, uint8_t * out_path, uint8_t * target, uint8_t * opt_level, int32_t use_lto, uint8_t * io_o, uint8_t * fs_o, uint8_t * process_o, uint8_t * string_o, uint8_t * heap_o, uint8_t * path_o, uint8_t * runtime_o, uint8_t * runtime_panic_o, uint8_t * net_o, uint8_t * thread_o, uint8_t * time_o, uint8_t * random_o, uint8_t * env_o, uint8_t * sync_o, uint8_t * encoding_o, uint8_t * base64_o, uint8_t * crypto_o, uint8_t * log_o, uint8_t * atomic_o, uint8_t * channel_o, uint8_t * backtrace_o, uint8_t * hash_o, uint8_t * math_o, uint8_t * sort_o, uint8_t * ffi_o, uint8_t * db_o, uint8_t * elf_o, uint8_t * json_o, uint8_t * csv_o, uint8_t * regex_o, uint8_t * compress_o, uint8_t * unicode_o, uint8_t * dynlib_o, uint8_t * http_o, uint8_t * tar_o, uint8_t * simd_o, uint8_t * context_o, uint8_t * datetime_o, uint8_t * uuid_o, uint8_t * url_o, uint8_t * cli_o, uint8_t * security_o, uint8_t * config_o, uint8_t * cache_o, uint8_t * trace_o, uint8_t * task_o, uint8_t * schema_o, uint8_t * test_o, uint8_t * include_root, uint8_t * async_scheduler_o);
extern void shux_asm_ld_append_mach_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, uint8_t * argv, int32_t * la, int32_t max_la, int32_t append_lsystem);
extern void shux_asm_ld_append_unix_gcc_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, int32_t need_pt, uint8_t * argv, int32_t * la, int32_t max_la);
extern void shux_append_linux_link_harden(uint8_t * argv, int32_t * la, int32_t cap);
extern int32_t shux_invoke_ld_for_exe(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots);
extern int32_t labi_gates_count(void);
extern uint8_t * shux_asm_ld_bank_push_impl(uint8_t * b, uint8_t * path);
extern void shux_append_linux_link_harden_impl(uint8_t * argv, int32_t * la, int32_t cap);
extern int32_t shux_invoke_ld_for_exe_impl(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots);
extern int32_t shux_invoke_cc_impl(uint8_t * c_paths, int32_t n, uint8_t * out_path, uint8_t * target, uint8_t * opt_level, int32_t use_lto, uint8_t * io_o, uint8_t * fs_o, uint8_t * process_o, uint8_t * string_o, uint8_t * heap_o, uint8_t * path_o, uint8_t * runtime_o, uint8_t * runtime_panic_o, uint8_t * net_o, uint8_t * thread_o, uint8_t * time_o, uint8_t * random_o, uint8_t * env_o, uint8_t * sync_o, uint8_t * encoding_o, uint8_t * base64_o, uint8_t * crypto_o, uint8_t * log_o, uint8_t * atomic_o, uint8_t * channel_o, uint8_t * backtrace_o, uint8_t * hash_o, uint8_t * math_o, uint8_t * sort_o, uint8_t * ffi_o, uint8_t * db_o, uint8_t * elf_o, uint8_t * json_o, uint8_t * csv_o, uint8_t * regex_o, uint8_t * compress_o, uint8_t * unicode_o, uint8_t * dynlib_o, uint8_t * http_o, uint8_t * tar_o, uint8_t * simd_o, uint8_t * context_o, uint8_t * datetime_o, uint8_t * uuid_o, uint8_t * url_o, uint8_t * cli_o, uint8_t * security_o, uint8_t * config_o, uint8_t * cache_o, uint8_t * trace_o, uint8_t * task_o, uint8_t * schema_o, uint8_t * test_o, uint8_t * include_root, uint8_t * async_scheduler_o);
extern void shux_asm_ld_append_mach_tail_libs_impl(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, uint8_t * argv, int32_t * la, int32_t max_la, int32_t append_lsystem);
extern void shux_asm_ld_append_unix_gcc_tail_libs_impl(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, int32_t need_pt, uint8_t * argv, int32_t * la, int32_t max_la);
uint8_t * shux_asm_ld_bank_push(uint8_t * b, uint8_t * path) {
  if ((b ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  if ((path ==((uint8_t *)(0)))) {
    return ((uint8_t *)(0));
  }
  if (((path)[0] ==0)) {
    return ((uint8_t *)(0));
  }
  {
    return shux_asm_ld_bank_push_impl(b, path);
  }
  return ((uint8_t *)(0));
}
int32_t shux_invoke_cc(uint8_t * c_paths, int32_t n, uint8_t * out_path, uint8_t * target, uint8_t * opt_level, int32_t use_lto, uint8_t * io_o, uint8_t * fs_o, uint8_t * process_o, uint8_t * string_o, uint8_t * heap_o, uint8_t * path_o, uint8_t * runtime_o, uint8_t * runtime_panic_o, uint8_t * net_o, uint8_t * thread_o, uint8_t * time_o, uint8_t * random_o, uint8_t * env_o, uint8_t * sync_o, uint8_t * encoding_o, uint8_t * base64_o, uint8_t * crypto_o, uint8_t * log_o, uint8_t * atomic_o, uint8_t * channel_o, uint8_t * backtrace_o, uint8_t * hash_o, uint8_t * math_o, uint8_t * sort_o, uint8_t * ffi_o, uint8_t * db_o, uint8_t * elf_o, uint8_t * json_o, uint8_t * csv_o, uint8_t * regex_o, uint8_t * compress_o, uint8_t * unicode_o, uint8_t * dynlib_o, uint8_t * http_o, uint8_t * tar_o, uint8_t * simd_o, uint8_t * context_o, uint8_t * datetime_o, uint8_t * uuid_o, uint8_t * url_o, uint8_t * cli_o, uint8_t * security_o, uint8_t * config_o, uint8_t * cache_o, uint8_t * trace_o, uint8_t * task_o, uint8_t * schema_o, uint8_t * test_o, uint8_t * include_root, uint8_t * async_scheduler_o) {
  if ((c_paths ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  if ((out_path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  {
    return shux_invoke_cc_impl(c_paths, n, out_path, target, opt_level, use_lto, io_o, fs_o, process_o, string_o, heap_o, path_o, runtime_o, runtime_panic_o, net_o, thread_o, time_o, random_o, env_o, sync_o, encoding_o, base64_o, crypto_o, log_o, atomic_o, channel_o, backtrace_o, hash_o, math_o, sort_o, ffi_o, db_o, elf_o, json_o, csv_o, regex_o, compress_o, unicode_o, dynlib_o, http_o, tar_o, simd_o, context_o, datetime_o, uuid_o, url_o, cli_o, security_o, config_o, cache_o, trace_o, task_o, schema_o, test_o, include_root, async_scheduler_o);
  }
  return (0 - 1);
}
void shux_asm_ld_append_mach_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, uint8_t * argv, int32_t * la, int32_t max_la, int32_t append_lsystem) {
  if ((flags ==((uint8_t *)(0)))) {
    return;
  }
  if ((argv ==((uint8_t *)(0)))) {
    return;
  }
  if ((la ==((int32_t *)(0)))) {
    return;
  }
  if (((la)[0] < 0)) {
    return;
  }
  {
    (void)(shux_asm_ld_append_mach_tail_libs_impl(compress_o, user_o, flags, argv, la, max_la, append_lsystem));
  }
  (void)(0);
  return;
}
void shux_asm_ld_append_unix_gcc_tail_libs(uint8_t * compress_o, uint8_t * user_o, uint8_t * flags, int32_t need_pt, uint8_t * argv, int32_t * la, int32_t max_la) {
  if ((flags ==((uint8_t *)(0)))) {
    return;
  }
  if ((argv ==((uint8_t *)(0)))) {
    return;
  }
  if ((la ==((int32_t *)(0)))) {
    return;
  }
  if (((la)[0] < 0)) {
    return;
  }
  {
    (void)(shux_asm_ld_append_unix_gcc_tail_libs_impl(compress_o, user_o, flags, need_pt, argv, la, max_la));
  }
  (void)(0);
  return;
}
void shux_append_linux_link_harden(uint8_t * argv, int32_t * la, int32_t cap) {
  if ((argv ==((uint8_t *)(0)))) {
    return;
  }
  if ((la ==((int32_t *)(0)))) {
    return;
  }
  {
    (void)(shux_append_linux_link_harden_impl(argv, la, cap));
  }
  (void)(0);
  return;
}
int32_t shux_invoke_ld_for_exe(uint8_t * o_path, uint8_t * exe_path, uint8_t * target, int32_t use_macho_o, int32_t use_coff_o, uint8_t * link_argv0, uint8_t * lib_roots, int32_t n_lib_roots) {
  if ((o_path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  if ((exe_path ==((uint8_t *)(0)))) {
    return (0 - 1);
  }
  {
    return shux_invoke_ld_for_exe_impl(o_path, exe_path, target, use_macho_o, use_coff_o, link_argv0, lib_roots, n_lib_roots);
  }
  return (0 - 1);
}
int32_t labi_gates_count(void) {
  return 6;
}
