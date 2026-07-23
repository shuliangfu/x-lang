/* seeds/labi_ensure_list_surface.from_x.c
 * G-02f labi_ensure_list R2 full surface — isomorphic with src/runtime/labi_ensure_list.x
 * Product PREFER_X_O: g05_try_x_to_o(labi_ensure_list.x) + mega rest under FROM_X
 * Prove: full.x vs this seed → nm IDENTICAL (ensure catalog + wave173 ensure_from_catalog + wave174 catalog thin wraps + wave169 panic + wave170 heap_user + wave171 test_fn_invoke + wave172 tls_mbedtls_bio + wave182 ensure_bootstrap_nostdlib_stubs_o + wave186 prepare_for_exe_link)
 * Cap residual: resolve/access/cc/stat (+ one_extra for catalog PIE/SQLITE/HTTP -I pack / -fno-builtin);
 *   wave169 panic ensure: resolve/access/cc/stat + host linux_x86_64 / posix_aarch64;
 *   wave170 heap_user ensure: resolve/access/cc/stat + has_defined_sym + unlink stub;
 *   wave171 test_fn_invoke ensure: resolve/access/cc/stat (direct seed; no wrap.c);
 *   wave172 tls_mbedtls_bio ensure: resolve/access/cc_one_extra/stat (homebrew -I);
 *   wave182 bootstrap_nostdlib_stubs ensure: resolve/access/cc_one_extra(-fno-builtin)/stat;
 *   wave186 prepare_for_exe_link: freestanding peers + user_needs + debug report Cap;
 *   wave174 catalog thin wraps: peer *_o_path Cap residual only
 * Regen: ./xlang -E ... src/runtime/labi_ensure_list.x | filter DBG + polish prologue (wave186)
 */
#include <stdint.h>
#include <stddef.h>
#include <sys/types.h>
extern int32_t labi_ensure_catalog_count(void);
extern uint8_t * labi_ensure_catalog_stem(int32_t i);
extern uint8_t * labi_ensure_catalog_out_base(int32_t i);
extern uint8_t * labi_ensure_catalog_seed_base(int32_t i);
extern int32_t labi_ensure_catalog_flags(int32_t i);
extern int32_t labi_ensure_catalog_step_at(int32_t i, size_t * stem_out, size_t * out_base_out, size_t * seed_base_out, int32_t * flags_out, size_t * hint_out);
extern int32_t link_abi_ensure_from_catalog(uint8_t * argv0, int32_t catalog_idx, uint8_t * product_path);
extern int32_t xlang_ensure_runtime_panic_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_heap_user_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_test_fn_invoke_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_tls_mbedtls_bio_o(uint8_t * argv0);
extern int32_t xlang_ensure_bootstrap_nostdlib_stubs_o(uint8_t * argv0);
extern int32_t xlang_asm_ld_prepare_for_exe_link(uint8_t * link_eff, uint8_t * user_o, int32_t driver_freestanding, int32_t use_macho_o, int32_t use_coff_o);
extern int32_t xlang_ensure_runtime_asm_io_stubs_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_process_argv_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_process_os_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_random_fill_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_compress_zlib_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_time_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_queue_contention_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_dynlib_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_env_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_backtrace_platform_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_log_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_math_libm_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_atomic_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_channel_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_net_udp_batch_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_net_workers_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sync_os_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sync_lock_diag_tls_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_thread_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_scheduler_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_http_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_kv_mmap_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_arrow_simd_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sqlite_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_crypto_inc_glue_o(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_ed25519_ref10_glue_o(uint8_t * argv0);
extern int32_t shu_resolve_compiler_dir(uint8_t * argv0, uint8_t * out_dir, int64_t out_dir_sz);
extern int32_t link_abi_path_readable(uint8_t * path);
extern int32_t xlang_cc_compile_sync(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s);
extern int32_t xlang_cc_compile_sync_one_extra(uint8_t * src, uint8_t * out_o, uint8_t * inc0, uint8_t * inc1, uint8_t * inc2, int32_t from_asm_s, uint8_t * extra0);
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern int32_t link_abi_host_is_linux_x86_64(void);
extern int32_t link_abi_host_is_posix_aarch64(void);
extern int32_t xlang_link_obj_has_defined_sym(uint8_t * o_path, uint8_t * sym);
extern int32_t unlink(uint8_t * path);
extern uint8_t * xlang_runtime_panic_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_heap_user_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_test_fn_invoke_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_tls_mbedtls_bio_o_path(uint8_t * argv0);
extern uint8_t * xlang_bootstrap_nostdlib_stubs_o_path(uint8_t * argv0);
/* Cap residual / peer pure (wave186 prepare_for_exe_link surface). */
extern int32_t xlang_link_freestanding_enabled(int32_t driver_freestanding);
extern int32_t xlang_freestanding_user_o_needs_panic(uint8_t * user_o);
extern int32_t xlang_freestanding_user_o_needs_io(uint8_t * user_o);
extern int32_t xlang_ensure_crt0_user_o(uint8_t * argv0, int32_t driver_freestanding);
extern int32_t xlang_ensure_freestanding_io_o(uint8_t * argv0, int32_t driver_freestanding);
extern int32_t labi_user_needs_runtime_process_argv(uint8_t * user_o);
extern int32_t labi_user_needs_runtime_random_fill(uint8_t * user_o);
extern int32_t labi_user_needs_runtime_time_os(uint8_t * user_o);
extern int32_t labi_user_needs_runtime_env_os(uint8_t * user_o);
extern void link_diag_freestanding_unsupported(void);
extern void xlang_debug_hello_stage1_report(uint8_t * hypothesis_id, uint8_t * location, uint8_t * msg, int32_t v1, int32_t v2, int32_t v3);
extern uint8_t * xlang_runtime_asm_io_stubs_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_process_argv_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_process_os_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_random_fill_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_compress_zlib_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_time_os_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_queue_contention_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_dynlib_os_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_env_os_o_path(uint8_t * argv0);
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
extern uint8_t * xlang_runtime_kv_mmap_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_arrow_simd_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_sqlite_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_crypto_inc_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_ed25519_ref10_glue_o_path(uint8_t * argv0);
extern void link_diag_runtime_obj_resolve_fail(uint8_t * obj_name, uint8_t * hint);
extern void link_diag_runtime_source_missing(uint8_t * obj_name, uint8_t * source_path);
extern void link_diag_runtime_source_missing_under(uint8_t * obj_name, uint8_t * base_dir, uint8_t * suffix);
extern void link_diag_runtime_obj_build_status(uint8_t * obj_name, int32_t status);
extern void link_diag_runtime_obj_missing(uint8_t * obj_name, uint8_t * out_o);
int32_t labi_ensure_catalog_count(void) {
  return 26;
}
uint8_t * labi_ensure_catalog_stem(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x6f\x73\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x6c\x69\x62\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x5f\x6f\x73");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x71\x75\x65\x75\x65\x5f\x63\x6f\x6e\x74\x65\x6e\x74\x69\x6f\x6e");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x64\x79\x6e\x6c\x69\x62\x5f\x6f\x73");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x6e\x76\x5f\x6f\x73");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x62\x61\x63\x6b\x74\x72\x61\x63\x65\x5f\x70\x6c\x61\x74\x66\x6f\x72\x6d");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6c\x6f\x67\x5f\x6f\x73");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6d\x61\x74\x68\x5f\x6c\x69\x62\x6d");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x61\x74\x63\x68");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x77\x6f\x72\x6b\x65\x72\x73");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6f\x73");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6c\x6f\x63\x6b\x5f\x64\x69\x61\x67\x5f\x74\x6c\x73");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x68\x72\x65\x61\x64\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==20)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x74\x74\x70\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==21)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6b\x76\x5f\x6d\x6d\x61\x70\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==22)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x72\x72\x6f\x77\x5f\x73\x69\x6d\x64\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==23)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x71\x6c\x69\x74\x65\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==24)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x72\x79\x70\x74\x6f\x5f\x69\x6e\x63\x5f\x67\x6c\x75\x65");
    return p;
  }
  if ((i ==25)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x64\x32\x35\x35\x31\x39\x5f\x72\x65\x66\x31\x30\x5f\x67\x6c\x75\x65");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_ensure_catalog_out_base(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73\x2e\x6f");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x6f\x73\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x2e\x6f");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x6c\x69\x62\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x5f\x6f\x73\x2e\x6f");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x71\x75\x65\x75\x65\x5f\x63\x6f\x6e\x74\x65\x6e\x74\x69\x6f\x6e\x2e\x6f");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x64\x79\x6e\x6c\x69\x62\x5f\x6f\x73\x2e\x6f");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x6e\x76\x5f\x6f\x73\x2e\x6f");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x62\x61\x63\x6b\x74\x72\x61\x63\x65\x5f\x70\x6c\x61\x74\x66\x6f\x72\x6d\x2e\x6f");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6c\x6f\x67\x5f\x6f\x73\x2e\x6f");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6d\x61\x74\x68\x5f\x6c\x69\x62\x6d\x2e\x6f");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x61\x74\x63\x68\x2e\x6f");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x77\x6f\x72\x6b\x65\x72\x73\x2e\x6f");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6f\x73\x2e\x6f");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6c\x6f\x63\x6b\x5f\x64\x69\x61\x67\x5f\x74\x6c\x73\x2e\x6f");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x68\x72\x65\x61\x64\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==20)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x74\x74\x70\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==21)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6b\x76\x5f\x6d\x6d\x61\x70\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==22)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x72\x72\x6f\x77\x5f\x73\x69\x6d\x64\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==23)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x71\x6c\x69\x74\x65\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==24)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x72\x79\x70\x74\x6f\x5f\x69\x6e\x63\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  if ((i ==25)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x64\x32\x35\x35\x31\x39\x5f\x72\x65\x66\x31\x30\x5f\x67\x6c\x75\x65\x2e\x6f");
    return p;
  }
  return ((uint8_t *)(0));
}
uint8_t * labi_ensure_catalog_seed_base(int32_t i) {
  if ((i < 0)) {
    return ((uint8_t *)(0));
  }
  if ((i ==0)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==1)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==2)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x6f\x73\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==3)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x72\x61\x6e\x64\x6f\x6d\x5f\x66\x69\x6c\x6c\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==4)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x6f\x6d\x70\x72\x65\x73\x73\x5f\x7a\x6c\x69\x62\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==5)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x69\x6d\x65\x5f\x6f\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==6)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x71\x75\x65\x75\x65\x5f\x63\x6f\x6e\x74\x65\x6e\x74\x69\x6f\x6e\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==7)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x64\x79\x6e\x6c\x69\x62\x5f\x6f\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==8)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x6e\x76\x5f\x6f\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==9)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x62\x61\x63\x6b\x74\x72\x61\x63\x65\x5f\x70\x6c\x61\x74\x66\x6f\x72\x6d\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==10)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6c\x6f\x67\x5f\x6f\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==11)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6d\x61\x74\x68\x5f\x6c\x69\x62\x6d\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==12)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x74\x6f\x6d\x69\x63\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==13)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x68\x61\x6e\x6e\x65\x6c\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==14)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x75\x64\x70\x5f\x62\x61\x74\x63\x68\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==15)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6e\x65\x74\x5f\x77\x6f\x72\x6b\x65\x72\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==16)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6f\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==17)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x79\x6e\x63\x5f\x6c\x6f\x63\x6b\x5f\x64\x69\x61\x67\x5f\x74\x6c\x73\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==18)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x68\x72\x65\x61\x64\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==19)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x63\x68\x65\x64\x75\x6c\x65\x72\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==20)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x74\x74\x70\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==21)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x6b\x76\x5f\x6d\x6d\x61\x70\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==22)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x72\x72\x6f\x77\x5f\x73\x69\x6d\x64\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==23)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x73\x71\x6c\x69\x74\x65\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==24)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x63\x72\x79\x70\x74\x6f\x5f\x69\x6e\x63\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  if ((i ==25)) {
    uint8_t * p = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x65\x64\x32\x35\x35\x31\x39\x5f\x72\x65\x66\x31\x30\x5f\x67\x6c\x75\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    return p;
  }
  return ((uint8_t *)(0));
}
int32_t labi_ensure_catalog_flags(int32_t i) {
  if ((i < 0)) {
    return 0;
  }
  if ((i ==0)) {
    return 1;
  }
  if ((i ==20)) {
    return 3;
  }
  if ((i ==23)) {
    return 2;
  }
  if ((i >=26)) {
    return 0;
  }
  return 0;
}
int32_t labi_ensure_catalog_step_at(int32_t i, size_t * stem_out, size_t * out_base_out, size_t * seed_base_out, int32_t * flags_out, size_t * hint_out) {
  if ((i < 0)) {
    return 0;
  }
  if ((i >=26)) {
    return 0;
  }
  uint8_t * s = labi_ensure_catalog_stem(i);
  if ((s ==0)) {
    return 0;
  }
  if ((stem_out !=0)) {
    (void)(((stem_out)[0] = ((size_t)(s))));
  }
  if ((out_base_out !=0)) {
    uint8_t * p = labi_ensure_catalog_out_base(i);
    (void)(((out_base_out)[0] = ((size_t)(p))));
  }
  if ((seed_base_out !=0)) {
    uint8_t * p = labi_ensure_catalog_seed_base(i);
    (void)(((seed_base_out)[0] = ((size_t)(p))));
  }
  if ((flags_out !=0)) {
    int32_t f = labi_ensure_catalog_flags(i);
    (void)(((flags_out)[0] = f));
  }
  if ((hint_out !=0)) {
    if ((i ==0)) {
      uint8_t * p = ((uint8_t *)"\x74\x72\x79\x3a\x20\x6d\x61\x6b\x65\x20\x2d\x43\x20\x63\x6f\x6d\x70\x69\x6c\x65\x72\x20\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73\x2e\x6f");
      (void)(((hint_out)[0] = ((size_t)(p))));
    } else {
      if ((i ==1)) {
        uint8_t * p = ((uint8_t *)"\x74\x72\x79\x3a\x20\x6d\x61\x6b\x65\x20\x2d\x43\x20\x63\x6f\x6d\x70\x69\x6c\x65\x72\x20\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f");
        (void)(((hint_out)[0] = ((size_t)(p))));
      } else {
        (void)(((hint_out)[0] = ((size_t)(0))));
      }
    }
  }
  return 1;
}
int32_t link_abi_ensure_from_catalog(uint8_t * argv0, int32_t catalog_idx, uint8_t * product_path) {
  if ((product_path ==0)) {
    return -1;
  }
  uint8_t * stem = labi_ensure_catalog_stem(catalog_idx);
  uint8_t * out_base = labi_ensure_catalog_out_base(catalog_idx);
  uint8_t * seed_base = labi_ensure_catalog_seed_base(catalog_idx);
  if ((stem ==0)) {
    return -1;
  }
  if ((out_base ==0)) {
    return -1;
  }
  if ((seed_base ==0)) {
    return -1;
  }
  int32_t flags = labi_ensure_catalog_flags(catalog_idx);
  uint8_t * have = 0;
  (void)((have = asm_link_obj_skip_missing(product_path)));
  if ((have !=0)) {
    return 0;
  }
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = shu_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc !=0)) {
    uint8_t * hint = 0;
    if ((catalog_idx ==0)) {
      (void)((hint = ((uint8_t *)"\x74\x72\x79\x3a\x20\x6d\x61\x6b\x65\x20\x2d\x43\x20\x63\x6f\x6d\x70\x69\x6c\x65\x72\x20\x72\x75\x6e\x74\x69\x6d\x65\x5f\x61\x73\x6d\x5f\x69\x6f\x5f\x73\x74\x75\x62\x73\x2e\x6f")));
    } else {
      if ((catalog_idx ==1)) {
        (void)((hint = ((uint8_t *)"\x74\x72\x79\x3a\x20\x6d\x61\x6b\x65\x20\x2d\x43\x20\x63\x6f\x6d\x70\x69\x6c\x65\x72\x20\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x72\x6f\x63\x65\x73\x73\x5f\x61\x72\x67\x76\x2e\x6f")));
      }
    }
    (void)(link_diag_runtime_obj_resolve_fail(out_base, hint));
    return -1;
  }
  int32_t dn = 0;
  while (((comp)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  int32_t ln_o = 0;
  while (((out_base)[ln_o] !=0)) {
    (void)((ln_o = (ln_o + 1)));
  }
  if ((((dn + 1) + ln_o) >=4096)) {
    return -1;
  }
  uint8_t out_o[4096] = {};
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out_o)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out_o)[dn] = 47));
  int32_t k = 0;
  while ((k <=ln_o)) {
    (void)(((out_o)[((dn + 1) + k)] = (out_base)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * seeds_pfx = ((uint8_t *)"\x73\x65\x65\x64\x73\x2f");
  int32_t ln_pfx = 0;
  while (((seeds_pfx)[ln_pfx] !=0)) {
    (void)((ln_pfx = (ln_pfx + 1)));
  }
  int32_t ln_seed = 0;
  while (((seed_base)[ln_seed] !=0)) {
    (void)((ln_seed = (ln_seed + 1)));
  }
  if (((((dn + 1) + ln_pfx) + ln_seed) >=4096)) {
    return -1;
  }
  uint8_t src_c[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((src_c)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((src_c)[dn] = 47));
  (void)((k = 0));
  while ((k < ln_pfx)) {
    (void)(((src_c)[((dn + 1) + k)] = (seeds_pfx)[k]));
    (void)((k = (k + 1)));
  }
  int32_t off = ((dn + 1) + ln_pfx);
  (void)((k = 0));
  while ((k <=ln_seed)) {
    (void)(((src_c)[(off + k)] = (seed_base)[k]));
    (void)((k = (k + 1)));
  }
  int32_t readable = 0;
  (void)((readable = link_abi_path_readable(&((src_c)[0]))));
  if ((readable ==0)) {
    (void)(link_diag_runtime_source_missing(stem, &((src_c)[0])));
    return -1;
  }
  uint8_t inc0[4096] = {};
  (void)((i = 0));
  while ((i <=dn)) {
    (void)(((inc0)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  uint8_t * leaf_inc = ((uint8_t *)"\x69\x6e\x63\x6c\x75\x64\x65");
  int32_t ln_inc = 0;
  while (((leaf_inc)[ln_inc] !=0)) {
    (void)((ln_inc = (ln_inc + 1)));
  }
  if ((((dn + 1) + ln_inc) >=4096)) {
    return -1;
  }
  uint8_t inc1[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc1)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc1)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_inc)) {
    (void)(((inc1)[((dn + 1) + k)] = (leaf_inc)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_src = ((uint8_t *)"\x73\x72\x63");
  int32_t ln_src = 0;
  while (((leaf_src)[ln_src] !=0)) {
    (void)((ln_src = (ln_src + 1)));
  }
  if ((((dn + 1) + ln_src) >=4096)) {
    return -1;
  }
  uint8_t inc2[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc2)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc2)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_src)) {
    (void)(((inc2)[((dn + 1) + k)] = (leaf_src)[k]));
    (void)((k = (k + 1)));
  }
  int32_t crc = 0;
  if ((flags ==1)) {
    uint8_t * flag_pie = ((uint8_t *)"\x2d\x66\x50\x49\x45");
    (void)((crc = xlang_cc_compile_sync_one_extra(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0, flag_pie)));
  } else {
    if ((flags ==2)) {
      uint8_t * flag_sql = ((uint8_t *)"\x2d\x44\x53\x48\x55\x58\x5f\x44\x42\x5f\x55\x53\x45\x5f\x53\x51\x4c\x49\x54\x45\x33");
      (void)((crc = xlang_cc_compile_sync_one_extra(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0, flag_sql)));
    } else {
      if ((flags ==3)) {
        uint8_t * http_leaf = ((uint8_t *)"\x73\x65\x65\x64\x73\x2f\x68\x74\x74\x70");
        int32_t ln_http = 0;
        while (((http_leaf)[ln_http] !=0)) {
          (void)((ln_http = (ln_http + 1)));
        }
        if ((((dn + 1) + ln_http) >=4096)) {
          return -1;
        }
        uint8_t http_inc[4096] = {};
        (void)((i = 0));
        while ((i < dn)) {
          (void)(((http_inc)[i] = (comp)[i]));
          (void)((i = (i + 1)));
        }
        (void)(((http_inc)[dn] = 47));
        (void)((k = 0));
        while ((k <=ln_http)) {
          (void)(((http_inc)[((dn + 1) + k)] = (http_leaf)[k]));
          (void)((k = (k + 1)));
        }
        uint8_t * dash_I = ((uint8_t *)"\x2d\x49");
        int32_t ln_I = 2;
        int32_t ln_http_abs = ((dn + 1) + ln_http);
        if (((ln_I + ln_http_abs) >=4096)) {
          return -1;
        }
        uint8_t flag_I[4096] = {};
        (void)(((flag_I)[0] = 45));
        (void)(((flag_I)[1] = 73));
        (void)((k = 0));
        while ((k <=ln_http_abs)) {
          (void)(((flag_I)[(ln_I + k)] = (http_inc)[k]));
          (void)((k = (k + 1)));
        }
        (void)((crc = xlang_cc_compile_sync_one_extra(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0, &((flag_I)[0]))));
      } else {
        (void)((crc = xlang_cc_compile_sync(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0)));
      }
    }
  }
  if ((crc !=0)) {
    (void)(link_diag_runtime_obj_build_status(out_base, crc));
    return -1;
  }
  (void)((have = asm_link_obj_skip_missing(product_path)));
  if ((have ==0)) {
    (void)(link_diag_runtime_obj_missing(out_base, &((out_o)[0])));
    return -1;
  }
  return 0;
}
int32_t xlang_ensure_runtime_panic_o(uint8_t * argv0) {
  uint8_t * o_path = 0;
  uint8_t * have = 0;
  (void)((o_path = xlang_runtime_panic_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(o_path)));
  if ((have !=0)) {
    return 0;
  }
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = shu_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc !=0)) {
    uint8_t * hint = ((uint8_t *)"\x74\x72\x79\x3a\x20\x6d\x61\x6b\x65\x20\x2d\x43\x20\x63\x6f\x6d\x70\x69\x6c\x65\x72\x20\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f");
    (void)(link_diag_runtime_obj_resolve_fail(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f"), hint));
    return -1;
  }
  int32_t dn = 0;
  while (((comp)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  uint8_t * leaf_o = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f");
  int32_t ln_o = 0;
  while (((leaf_o)[ln_o] !=0)) {
    (void)((ln_o = (ln_o + 1)));
  }
  if ((((dn + 1) + ln_o) >=4096)) {
    return -1;
  }
  uint8_t out_o[4096] = {};
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out_o)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out_o)[dn] = 47));
  int32_t k = 0;
  while ((k <=ln_o)) {
    (void)(((out_o)[((dn + 1) + k)] = (leaf_o)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * src = 0;
  int32_t from_asm_s = 0;
  uint8_t src_s[4096] = {};
  uint8_t src_arm[4096] = {};
  uint8_t src_c[4096] = {};
  int32_t is_linux_x86 = 0;
  (void)((is_linux_x86 = link_abi_host_is_linux_x86_64()));
  if ((is_linux_x86 !=0)) {
    uint8_t * leaf_s = ((uint8_t *)"\x73\x72\x63\x2f\x61\x73\x6d\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x5f\x78\x38\x36\x5f\x36\x34\x2e\x73");
    int32_t ln_s = 0;
    while (((leaf_s)[ln_s] !=0)) {
      (void)((ln_s = (ln_s + 1)));
    }
    if ((((dn + 1) + ln_s) < 4096)) {
      (void)((i = 0));
      while ((i < dn)) {
        (void)(((src_s)[i] = (comp)[i]));
        (void)((i = (i + 1)));
      }
      (void)(((src_s)[dn] = 47));
      (void)((k = 0));
      while ((k <=ln_s)) {
        (void)(((src_s)[((dn + 1) + k)] = (leaf_s)[k]));
        (void)((k = (k + 1)));
      }
      int32_t readable = 0;
      (void)((readable = link_abi_path_readable(&((src_s)[0]))));
      if ((readable !=0)) {
        (void)((src = &((src_s)[0])));
        (void)((from_asm_s = 1));
      }
    }
  }
  if ((src ==0)) {
    int32_t is_posix_a64 = 0;
    (void)((is_posix_a64 = link_abi_host_is_posix_aarch64()));
    if ((is_posix_a64 !=0)) {
      uint8_t * leaf_a = ((uint8_t *)"\x73\x65\x65\x64\x73\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x5f\x61\x72\x6d\x36\x34\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
      int32_t ln_a = 0;
      while (((leaf_a)[ln_a] !=0)) {
        (void)((ln_a = (ln_a + 1)));
      }
      if ((((dn + 1) + ln_a) < 4096)) {
        (void)((i = 0));
        while ((i < dn)) {
          (void)(((src_arm)[i] = (comp)[i]));
          (void)((i = (i + 1)));
        }
        (void)(((src_arm)[dn] = 47));
        (void)((k = 0));
        while ((k <=ln_a)) {
          (void)(((src_arm)[((dn + 1) + k)] = (leaf_a)[k]));
          (void)((k = (k + 1)));
        }
        int32_t readable2 = 0;
        (void)((readable2 = link_abi_path_readable(&((src_arm)[0]))));
        if ((readable2 !=0)) {
          (void)((src = &((src_arm)[0])));
        }
      }
    }
  }
  if ((src ==0)) {
    uint8_t * leaf_c = ((uint8_t *)"\x73\x65\x65\x64\x73\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
    int32_t ln_c = 0;
    while (((leaf_c)[ln_c] !=0)) {
      (void)((ln_c = (ln_c + 1)));
    }
    if ((((dn + 1) + ln_c) >=4096)) {
      return -1;
    }
    (void)((i = 0));
    while ((i < dn)) {
      (void)(((src_c)[i] = (comp)[i]));
      (void)((i = (i + 1)));
    }
    (void)(((src_c)[dn] = 47));
    (void)((k = 0));
    while ((k <=ln_c)) {
      (void)(((src_c)[((dn + 1) + k)] = (leaf_c)[k]));
      (void)((k = (k + 1)));
    }
    int32_t readable3 = 0;
    (void)((readable3 = link_abi_path_readable(&((src_c)[0]))));
    if ((readable3 ==0)) {
      (void)(link_diag_runtime_source_missing_under(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63"), &((comp)[0]), ((uint8_t *)"\x2f\x73\x65\x65\x64\x73\x2f")));
      return -1;
    }
    (void)((src = &((src_c)[0])));
  }
  uint8_t inc0[4096] = {};
  (void)((i = 0));
  while ((i <=dn)) {
    (void)(((inc0)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  uint8_t * leaf_inc = ((uint8_t *)"\x69\x6e\x63\x6c\x75\x64\x65");
  int32_t ln_inc = 0;
  while (((leaf_inc)[ln_inc] !=0)) {
    (void)((ln_inc = (ln_inc + 1)));
  }
  if ((((dn + 1) + ln_inc) >=4096)) {
    return -1;
  }
  uint8_t inc1[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc1)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc1)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_inc)) {
    (void)(((inc1)[((dn + 1) + k)] = (leaf_inc)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_src = ((uint8_t *)"\x73\x72\x63");
  int32_t ln_src = 0;
  while (((leaf_src)[ln_src] !=0)) {
    (void)((ln_src = (ln_src + 1)));
  }
  if ((((dn + 1) + ln_src) >=4096)) {
    return -1;
  }
  uint8_t inc2[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc2)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc2)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_src)) {
    (void)(((inc2)[((dn + 1) + k)] = (leaf_src)[k]));
    (void)((k = (k + 1)));
  }
  int32_t crc = 0;
  (void)((crc = xlang_cc_compile_sync(src, &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), from_asm_s)));
  if ((crc !=0)) {
    (void)(link_diag_runtime_obj_build_status(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f"), crc));
    return -1;
  }
  (void)((o_path = xlang_runtime_panic_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(o_path)));
  if ((have ==0)) {
    (void)(link_diag_runtime_obj_missing(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x70\x61\x6e\x69\x63\x2e\x6f"), &((out_o)[0])));
    return -1;
  }
  return 0;
}
int32_t xlang_ensure_runtime_heap_user_o(uint8_t * argv0) {
  uint8_t * existing = 0;
  uint8_t * have = 0;
  (void)((existing = xlang_runtime_heap_user_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(existing)));
  if ((have !=0)) {
    int32_t has_arena = 0;
    int32_t has_alloc = 0;
    (void)((has_arena = xlang_link_obj_has_defined_sym(existing, ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x72\x65\x6e\x61\x5f\x69\x6e\x69\x74\x5f\x63"))));
    (void)((has_alloc = xlang_link_obj_has_defined_sym(existing, ((uint8_t *)"\x68\x65\x61\x70\x5f\x61\x6c\x6c\x6f\x63\x5f\x63"))));
    if ((has_arena !=0)) {
      return 0;
    }
    if ((has_alloc !=0)) {
      return 0;
    }
    (void)(unlink(existing));
  }
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = shu_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc !=0)) {
    (void)(link_diag_runtime_obj_resolve_fail(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72\x2e\x6f"), 0));
    return -1;
  }
  int32_t dn = 0;
  while (((comp)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  uint8_t * leaf_o = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72\x2e\x6f");
  int32_t ln_o = 0;
  while (((leaf_o)[ln_o] !=0)) {
    (void)((ln_o = (ln_o + 1)));
  }
  if ((((dn + 1) + ln_o) >=4096)) {
    return -1;
  }
  uint8_t out_o[4096] = {};
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out_o)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out_o)[dn] = 47));
  int32_t k = 0;
  while ((k <=ln_o)) {
    (void)(((out_o)[((dn + 1) + k)] = (leaf_o)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_c = ((uint8_t *)"\x73\x65\x65\x64\x73\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
  int32_t ln_c = 0;
  while (((leaf_c)[ln_c] !=0)) {
    (void)((ln_c = (ln_c + 1)));
  }
  if ((((dn + 1) + ln_c) >=4096)) {
    return -1;
  }
  uint8_t src_c[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((src_c)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((src_c)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_c)) {
    (void)(((src_c)[((dn + 1) + k)] = (leaf_c)[k]));
    (void)((k = (k + 1)));
  }
  int32_t readable = 0;
  (void)((readable = link_abi_path_readable(&((src_c)[0]))));
  if ((readable ==0)) {
    (void)(link_diag_runtime_source_missing(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72"), &((src_c)[0])));
    return -1;
  }
  uint8_t inc0[4096] = {};
  (void)((i = 0));
  while ((i <=dn)) {
    (void)(((inc0)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  uint8_t * leaf_inc = ((uint8_t *)"\x69\x6e\x63\x6c\x75\x64\x65");
  int32_t ln_inc = 0;
  while (((leaf_inc)[ln_inc] !=0)) {
    (void)((ln_inc = (ln_inc + 1)));
  }
  if ((((dn + 1) + ln_inc) >=4096)) {
    return -1;
  }
  uint8_t inc1[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc1)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc1)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_inc)) {
    (void)(((inc1)[((dn + 1) + k)] = (leaf_inc)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_src = ((uint8_t *)"\x73\x72\x63");
  int32_t ln_src = 0;
  while (((leaf_src)[ln_src] !=0)) {
    (void)((ln_src = (ln_src + 1)));
  }
  if ((((dn + 1) + ln_src) >=4096)) {
    return -1;
  }
  uint8_t inc2[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc2)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc2)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_src)) {
    (void)(((inc2)[((dn + 1) + k)] = (leaf_src)[k]));
    (void)((k = (k + 1)));
  }
  int32_t crc = 0;
  (void)((crc = xlang_cc_compile_sync(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0)));
  if ((crc !=0)) {
    (void)(link_diag_runtime_obj_build_status(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72\x2e\x6f"), crc));
    return -1;
  }
  uint8_t * o_path = 0;
  (void)((o_path = xlang_runtime_heap_user_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(o_path)));
  if ((have ==0)) {
    (void)(link_diag_runtime_obj_missing(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x68\x65\x61\x70\x5f\x75\x73\x65\x72\x2e\x6f"), &((out_o)[0])));
    return -1;
  }
  return 0;
}
int32_t xlang_ensure_runtime_test_fn_invoke_o(uint8_t * argv0) {
  uint8_t * existing = 0;
  uint8_t * have = 0;
  (void)((existing = xlang_runtime_test_fn_invoke_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(existing)));
  if ((have !=0)) {
    return 0;
  }
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = shu_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc !=0)) {
    (void)(link_diag_runtime_obj_resolve_fail(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x6f"), ((uint8_t *)"\x74\x72\x79\x3a\x20\x6d\x61\x6b\x65\x20\x2d\x43\x20\x63\x6f\x6d\x70\x69\x6c\x65\x72\x20\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x6f")));
    return -1;
  }
  int32_t dn = 0;
  while (((comp)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  uint8_t * leaf_o = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x6f");
  int32_t ln_o = 0;
  while (((leaf_o)[ln_o] !=0)) {
    (void)((ln_o = (ln_o + 1)));
  }
  if ((((dn + 1) + ln_o) >=4096)) {
    return -1;
  }
  uint8_t out_o[4096] = {};
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out_o)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out_o)[dn] = 47));
  int32_t k = 0;
  while ((k <=ln_o)) {
    (void)(((out_o)[((dn + 1) + k)] = (leaf_o)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_c = ((uint8_t *)"\x73\x65\x65\x64\x73\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
  int32_t ln_c = 0;
  while (((leaf_c)[ln_c] !=0)) {
    (void)((ln_c = (ln_c + 1)));
  }
  if ((((dn + 1) + ln_c) >=4096)) {
    return -1;
  }
  uint8_t src_c[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((src_c)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((src_c)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_c)) {
    (void)(((src_c)[((dn + 1) + k)] = (leaf_c)[k]));
    (void)((k = (k + 1)));
  }
  int32_t readable = 0;
  (void)((readable = link_abi_path_readable(&((src_c)[0]))));
  if ((readable ==0)) {
    (void)(link_diag_runtime_source_missing(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65"), &((src_c)[0])));
    return -1;
  }
  uint8_t inc0[4096] = {};
  (void)((i = 0));
  while ((i <=dn)) {
    (void)(((inc0)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  uint8_t * leaf_inc = ((uint8_t *)"\x69\x6e\x63\x6c\x75\x64\x65");
  int32_t ln_inc = 0;
  while (((leaf_inc)[ln_inc] !=0)) {
    (void)((ln_inc = (ln_inc + 1)));
  }
  if ((((dn + 1) + ln_inc) >=4096)) {
    return -1;
  }
  uint8_t inc1[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc1)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc1)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_inc)) {
    (void)(((inc1)[((dn + 1) + k)] = (leaf_inc)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_src = ((uint8_t *)"\x73\x72\x63");
  int32_t ln_src = 0;
  while (((leaf_src)[ln_src] !=0)) {
    (void)((ln_src = (ln_src + 1)));
  }
  if ((((dn + 1) + ln_src) >=4096)) {
    return -1;
  }
  uint8_t inc2[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc2)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc2)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_src)) {
    (void)(((inc2)[((dn + 1) + k)] = (leaf_src)[k]));
    (void)((k = (k + 1)));
  }
  int32_t crc = 0;
  (void)((crc = xlang_cc_compile_sync(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0)));
  if ((crc !=0)) {
    (void)(link_diag_runtime_obj_build_status(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x6f"), crc));
    return -1;
  }
  uint8_t * o_path = 0;
  (void)((o_path = xlang_runtime_test_fn_invoke_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(o_path)));
  if ((have ==0)) {
    (void)(link_diag_runtime_obj_missing(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x65\x73\x74\x5f\x66\x6e\x5f\x69\x6e\x76\x6f\x6b\x65\x2e\x6f"), &((out_o)[0])));
    return -1;
  }
  return 0;
}
int32_t xlang_ensure_runtime_tls_mbedtls_bio_o(uint8_t * argv0) {
  uint8_t * existing = 0;
  uint8_t * have = 0;
  (void)((existing = xlang_runtime_tls_mbedtls_bio_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(existing)));
  if ((have !=0)) {
    return 0;
  }
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = shu_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc !=0)) {
    (void)(link_diag_runtime_obj_resolve_fail(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x6c\x73\x5f\x6d\x62\x65\x64\x74\x6c\x73\x5f\x62\x69\x6f\x2e\x6f"), 0));
    return -1;
  }
  int32_t dn = 0;
  while (((comp)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  uint8_t * leaf_o = ((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x6c\x73\x5f\x6d\x62\x65\x64\x74\x6c\x73\x5f\x62\x69\x6f\x2e\x6f");
  int32_t ln_o = 0;
  while (((leaf_o)[ln_o] !=0)) {
    (void)((ln_o = (ln_o + 1)));
  }
  if ((((dn + 1) + ln_o) >=4096)) {
    return -1;
  }
  uint8_t out_o[4096] = {};
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out_o)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out_o)[dn] = 47));
  int32_t k = 0;
  while ((k <=ln_o)) {
    (void)(((out_o)[((dn + 1) + k)] = (leaf_o)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_c = ((uint8_t *)"\x73\x65\x65\x64\x73\x2f\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x6c\x73\x5f\x6d\x62\x65\x64\x74\x6c\x73\x5f\x62\x69\x6f\x2e\x66\x72\x6f\x6d\x5f\x78\x2e\x63");
  int32_t ln_c = 0;
  while (((leaf_c)[ln_c] !=0)) {
    (void)((ln_c = (ln_c + 1)));
  }
  if ((((dn + 1) + ln_c) >=4096)) {
    return -1;
  }
  uint8_t src_c[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((src_c)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((src_c)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_c)) {
    (void)(((src_c)[((dn + 1) + k)] = (leaf_c)[k]));
    (void)((k = (k + 1)));
  }
  int32_t readable = 0;
  (void)((readable = link_abi_path_readable(&((src_c)[0]))));
  if ((readable ==0)) {
    (void)(link_diag_runtime_source_missing(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x6c\x73\x5f\x6d\x62\x65\x64\x74\x6c\x73\x5f\x62\x69\x6f"), &((src_c)[0])));
    return -1;
  }
  uint8_t inc0[4096] = {};
  (void)((i = 0));
  while ((i <=dn)) {
    (void)(((inc0)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  uint8_t * leaf_inc = ((uint8_t *)"\x69\x6e\x63\x6c\x75\x64\x65");
  int32_t ln_inc = 0;
  while (((leaf_inc)[ln_inc] !=0)) {
    (void)((ln_inc = (ln_inc + 1)));
  }
  if ((((dn + 1) + ln_inc) >=4096)) {
    return -1;
  }
  uint8_t inc1[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc1)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc1)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_inc)) {
    (void)(((inc1)[((dn + 1) + k)] = (leaf_inc)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_src = ((uint8_t *)"\x73\x72\x63");
  int32_t ln_src = 0;
  while (((leaf_src)[ln_src] !=0)) {
    (void)((ln_src = (ln_src + 1)));
  }
  if ((((dn + 1) + ln_src) >=4096)) {
    return -1;
  }
  uint8_t inc2[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc2)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc2)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_src)) {
    (void)(((inc2)[((dn + 1) + k)] = (leaf_src)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * flag_I = ((uint8_t *)"\x2d\x49\x2f\x6f\x70\x74\x2f\x68\x6f\x6d\x65\x62\x72\x65\x77\x2f\x6f\x70\x74\x2f\x6d\x62\x65\x64\x74\x6c\x73\x2f\x69\x6e\x63\x6c\x75\x64\x65");
  int32_t crc = 0;
  (void)((crc = xlang_cc_compile_sync_one_extra(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0, flag_I)));
  if ((crc !=0)) {
    (void)(link_diag_runtime_obj_build_status(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x6c\x73\x5f\x6d\x62\x65\x64\x74\x6c\x73\x5f\x62\x69\x6f\x2e\x6f"), crc));
    return -1;
  }
  uint8_t * o_path = 0;
  (void)((o_path = xlang_runtime_tls_mbedtls_bio_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(o_path)));
  if ((have ==0)) {
    (void)(link_diag_runtime_obj_missing(((uint8_t *)"\x72\x75\x6e\x74\x69\x6d\x65\x5f\x74\x6c\x73\x5f\x6d\x62\x65\x64\x74\x6c\x73\x5f\x62\x69\x6f\x2e\x6f"), &((out_o)[0])));
    return -1;
  }
  return 0;
}
/* wave182: ensure_bootstrap_nostdlib_stubs_o pure orch (surface pin). */
int32_t xlang_ensure_bootstrap_nostdlib_stubs_o(uint8_t * argv0) {
  uint8_t * existing = 0;
  uint8_t * have = 0;
  (void)((existing = xlang_bootstrap_nostdlib_stubs_o_path(argv0)));
  if ((existing !=0)) {
    if ((((uint8_t *)existing)[0] !=0)) {
      (void)((have = asm_link_obj_skip_missing(existing)));
      if ((have !=0)) {
        return 0;
      }
    }
  }
  uint8_t comp[4096] = {};
  int32_t rc = 0;
  (void)((rc = shu_resolve_compiler_dir(argv0, &((comp)[0]), 4096)));
  if ((rc !=0)) {
    (void)(link_diag_runtime_obj_resolve_fail(((uint8_t *)"bootstrap_nostdlib_stubs.o"), 0));
    return -1;
  }
  int32_t dn = 0;
  while (((comp)[dn] !=0)) {
    (void)((dn = (dn + 1)));
  }
  uint8_t * leaf_o = ((uint8_t *)"src/asm/bootstrap_nostdlib_stubs.o");
  int32_t ln_o = 0;
  while (((leaf_o)[ln_o] !=0)) {
    (void)((ln_o = (ln_o + 1)));
  }
  if ((((dn + 1) + ln_o) >=4096)) {
    return -1;
  }
  uint8_t out_o[4096] = {};
  int32_t i = 0;
  while ((i < dn)) {
    (void)(((out_o)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((out_o)[dn] = 47));
  int32_t k = 0;
  while ((k <=ln_o)) {
    (void)(((out_o)[((dn + 1) + k)] = (leaf_o)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_c = ((uint8_t *)"seeds/bootstrap_nostdlib_stubs.from_x.c");
  int32_t ln_c = 0;
  while (((leaf_c)[ln_c] !=0)) {
    (void)((ln_c = (ln_c + 1)));
  }
  if ((((dn + 1) + ln_c) >=4096)) {
    return -1;
  }
  uint8_t src_c[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((src_c)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((src_c)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_c)) {
    (void)(((src_c)[((dn + 1) + k)] = (leaf_c)[k]));
    (void)((k = (k + 1)));
  }
  int32_t readable = 0;
  (void)((readable = link_abi_path_readable(&((src_c)[0]))));
  if ((readable ==0)) {
    (void)(link_diag_runtime_source_missing(((uint8_t *)"bootstrap_nostdlib_stubs"), &((src_c)[0])));
    return -1;
  }
  uint8_t inc0[4096] = {};
  (void)((i = 0));
  while ((i <=dn)) {
    (void)(((inc0)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  uint8_t * leaf_inc = ((uint8_t *)"include");
  int32_t ln_inc = 0;
  while (((leaf_inc)[ln_inc] !=0)) {
    (void)((ln_inc = (ln_inc + 1)));
  }
  if ((((dn + 1) + ln_inc) >=4096)) {
    return -1;
  }
  uint8_t inc1[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc1)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc1)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_inc)) {
    (void)(((inc1)[((dn + 1) + k)] = (leaf_inc)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * leaf_src = ((uint8_t *)"src");
  int32_t ln_src = 0;
  while (((leaf_src)[ln_src] !=0)) {
    (void)((ln_src = (ln_src + 1)));
  }
  if ((((dn + 1) + ln_src) >=4096)) {
    return -1;
  }
  uint8_t inc2[4096] = {};
  (void)((i = 0));
  while ((i < dn)) {
    (void)(((inc2)[i] = (comp)[i]));
    (void)((i = (i + 1)));
  }
  (void)(((inc2)[dn] = 47));
  (void)((k = 0));
  while ((k <=ln_src)) {
    (void)(((inc2)[((dn + 1) + k)] = (leaf_src)[k]));
    (void)((k = (k + 1)));
  }
  uint8_t * flag_nb = ((uint8_t *)"-fno-builtin");
  int32_t crc = 0;
  (void)((crc = xlang_cc_compile_sync_one_extra(&((src_c)[0]), &((out_o)[0]), &((inc0)[0]), &((inc1)[0]), &((inc2)[0]), 0, flag_nb)));
  if ((crc !=0)) {
    (void)(link_diag_runtime_obj_build_status(((uint8_t *)"bootstrap_nostdlib_stubs.o"), crc));
    return -1;
  }
  uint8_t * o_path = 0;
  (void)((o_path = xlang_bootstrap_nostdlib_stubs_o_path(argv0)));
  (void)((have = asm_link_obj_skip_missing(o_path)));
  if ((have ==0)) {
    (void)(link_diag_runtime_obj_missing(((uint8_t *)"bootstrap_nostdlib_stubs.o"), &((out_o)[0])));
    return -1;
  }
  return 0;
}
int32_t xlang_ensure_runtime_asm_io_stubs_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_asm_io_stubs_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 0, p);
}
int32_t xlang_ensure_runtime_process_argv_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_process_argv_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 1, p);
}
int32_t xlang_ensure_runtime_process_os_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_process_os_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 2, p);
}
int32_t xlang_ensure_runtime_random_fill_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_random_fill_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 3, p);
}
int32_t xlang_ensure_runtime_compress_zlib_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_compress_zlib_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 4, p);
}
int32_t xlang_ensure_runtime_time_os_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_time_os_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 5, p);
}
int32_t xlang_ensure_runtime_queue_contention_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_queue_contention_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 6, p);
}
int32_t xlang_ensure_runtime_dynlib_os_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_dynlib_os_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 7, p);
}
int32_t xlang_ensure_runtime_env_os_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_env_os_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 8, p);
}
int32_t xlang_ensure_runtime_backtrace_platform_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_backtrace_platform_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 9, p);
}
int32_t xlang_ensure_runtime_log_os_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_log_os_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 10, p);
}
int32_t xlang_ensure_runtime_math_libm_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_math_libm_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 11, p);
}
int32_t xlang_ensure_runtime_atomic_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_atomic_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 12, p);
}
int32_t xlang_ensure_runtime_channel_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_channel_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 13, p);
}
int32_t xlang_ensure_runtime_net_udp_batch_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_net_udp_batch_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 14, p);
}
int32_t xlang_ensure_runtime_net_workers_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_net_workers_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 15, p);
}
int32_t xlang_ensure_runtime_sync_os_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_sync_os_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 16, p);
}
int32_t xlang_ensure_runtime_sync_lock_diag_tls_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_sync_lock_diag_tls_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 17, p);
}
int32_t xlang_ensure_runtime_thread_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_thread_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 18, p);
}
int32_t xlang_ensure_runtime_scheduler_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_scheduler_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 19, p);
}
int32_t xlang_ensure_runtime_http_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_http_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 20, p);
}
int32_t xlang_ensure_runtime_kv_mmap_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_kv_mmap_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 21, p);
}
int32_t xlang_ensure_runtime_arrow_simd_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_arrow_simd_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 22, p);
}
int32_t xlang_ensure_runtime_sqlite_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_sqlite_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 23, p);
}
int32_t xlang_ensure_runtime_crypto_inc_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_crypto_inc_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 24, p);
}
int32_t xlang_ensure_runtime_ed25519_ref10_glue_o(uint8_t * argv0) {
  uint8_t * p = 0;
  (void)((p = xlang_runtime_ed25519_ref10_glue_o_path(argv0)));
  return link_abi_ensure_from_catalog(argv0, 25, p);
}
/* wave186: prepare_for_exe_link pure orch (surface pin ≡ .x). */
int32_t xlang_asm_ld_prepare_for_exe_link(uint8_t * link_eff, uint8_t * user_o, int32_t driver_freestanding, int32_t use_macho_o, int32_t use_coff_o) {
  int32_t fs = 0;
  int32_t need = 0;
  int32_t rc = 0;
  (void)(xlang_debug_hello_stage1_report(((uint8_t *)"A"), ((uint8_t *)"runtime_link_abi.c:prepare_for_exe_link_enter"), ((uint8_t *)"prepare_for_exe_link_enter"), driver_freestanding, use_macho_o, use_coff_o));
  if ((link_eff == 0)) {
    return -1;
  }
  if ((user_o == 0)) {
    return -1;
  }
  (void)((fs = xlang_link_freestanding_enabled(driver_freestanding)));
  if ((fs != 0)) {
    (void)((need = xlang_freestanding_user_o_needs_panic(user_o)));
    if ((need != 0)) {
      (void)((rc = xlang_ensure_runtime_panic_o(link_eff)));
      if ((rc != 0)) {
        return -1;
      }
    }
  } else {
    (void)((rc = xlang_ensure_runtime_panic_o(link_eff)));
    if ((rc != 0)) {
      return -1;
    }
  }
  if ((fs == 0)) {
    (void)((rc = xlang_ensure_runtime_asm_io_stubs_o(link_eff)));
    if ((rc != 0)) {
      return -1;
    }
    (void)((need = labi_user_needs_runtime_process_argv(user_o)));
    if ((need != 0)) {
      (void)((rc = xlang_ensure_runtime_process_argv_o(link_eff)));
      if ((rc != 0)) {
        return -1;
      }
    }
    (void)((need = labi_user_needs_runtime_random_fill(user_o)));
    if ((need != 0)) {
      (void)((rc = xlang_ensure_runtime_random_fill_o(link_eff)));
      if ((rc != 0)) {
        return -1;
      }
    }
    (void)((need = labi_user_needs_runtime_time_os(user_o)));
    if ((need != 0)) {
      (void)((rc = xlang_ensure_runtime_time_os_o(link_eff)));
      if ((rc != 0)) {
        return -1;
      }
    }
    (void)((need = labi_user_needs_runtime_env_os(user_o)));
    if ((need != 0)) {
      (void)((rc = xlang_ensure_runtime_env_os_o(link_eff)));
      if ((rc != 0)) {
        return -1;
      }
    }
  }
  (void)((rc = xlang_ensure_crt0_user_o(link_eff, driver_freestanding)));
  if ((rc != 0)) {
    return -1;
  }
  if ((fs != 0)) {
    (void)((need = xlang_freestanding_user_o_needs_io(user_o)));
    if ((need != 0)) {
      (void)((rc = xlang_ensure_freestanding_io_o(link_eff, driver_freestanding)));
      if ((rc != 0)) {
        return -1;
      }
    }
  }
  if ((fs != 0)) {
    if (((use_macho_o != 0) || (use_coff_o != 0))) {
      (void)(link_diag_freestanding_unsupported());
      return -1;
    }
  }
  (void)(xlang_debug_hello_stage1_report(((uint8_t *)"A"), ((uint8_t *)"runtime_link_abi.c:prepare_for_exe_link_exit"), ((uint8_t *)"prepare_for_exe_link_exit"), 0, 0, 0));
  return 0;
}
