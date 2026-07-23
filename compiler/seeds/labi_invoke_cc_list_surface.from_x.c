/* seeds/labi_invoke_cc_list_surface.from_x.c
 * G-02f labi_invoke_cc_list R2 full surface — isomorphic with cold seed string tables
 *   + wave155 xlang_append_linux_link_harden_impl pure orch
 *   + wave198 invoke_cc_append_early_needs pure orch + wave199 std need scan
 *   + wave200 invoke_cc_append_std_ensure_push_front pure orch
 *   + wave201 invoke_cc_append_std_ensure_push_mid pure orch
 *   + wave202 invoke_cc_append_std_ensure_push_heavy_a pure orch
 *   + wave203 invoke_cc_append_std_ensure_push_heavy_b pure orch
 *   + wave204 invoke_cc_append_heap_f06_ondemand pure orch
 *   + wave205 invoke_cc_run_cc_argv + invoke_cc_maybe_strip_out pure orch
 *   + wave206 invoke_cc_append_argv_head_flags pure orch
 *   + wave207 invoke_cc_append_argv_tail_flags pure orch
 *   + wave208 invoke_cc_append_minimal_cc_link_tail pure orch.
 *
 * 【Why 根源】旧 surface 由 .x STRING_LIT 生成 `(uint8_t[]){...}; return p`：
 *   C 块作用域 compound literal 为自动存储，return 后悬空。
 *   labi_linux_harden_flag_at 被 invoke_cc 写入 argv → gcc 收到乱码路径。
 * 【Invariant】全部返回 C 字符串字面量（rodata），与 labi_invoke_cc_list.from_x.c 冷路径一致。
 * Prove: full.x vs this seed → nm IDENTICAL (harden/skip-native/icc rel pure table
 *   + wave155/198/199/200/201/202/203/204/205/206/207/208 pure orch).
 * wave260: product g05 L5 default PREFER full .x (cold seed = fallback only).
 * Cap residual: generated_c_needs_* + ensure/path/push peers + host_is_* + net_tls_ld
 *   + xlang_spawn_sync / setenv / invoke_cc_strip_out_x / link_diag_tool_status
 *   + asm_link_obj_skip_missing + link_abi_user_extra_o_{count,at}
 *   + process_argv path (MINIMAL Windows).
 * PLATFORM: SHARED - symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

/* Cap residual / peer pure (wave198 early needs + wave199 std need scan surface). */
extern int32_t link_abi_generated_c_contains_substr_use_line(uint8_t * c_path, uint8_t * needle);
extern int32_t link_abi_generated_c_contains_substr(uint8_t * c_path, uint8_t * needle);
extern int32_t link_abi_generated_c_needs_core_builtin(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_core_mem(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_core_slice(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_db_kv(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_db_arrow(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_fs(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_random(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_time(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_runtime(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_win32(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_win32_wsa(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_libc_heap(uint8_t * c_path);
extern int32_t invoke_cc_argv_push_existing(uint8_t * * argv, int32_t * ia, int32_t max_ia, uint8_t * path);
extern uint8_t * xlang_rel_o_path_from_argv0(uint8_t * argv0, uint8_t * rel);
extern uint8_t * xlang_runtime_kv_mmap_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_runtime_arrow_simd_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_random_fill_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_random_fill_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_time_os_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_time_os_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_panic_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_panic_o_path(uint8_t * argv0);
/* wave288 L4: residual face companion (never g05 host bag). */
extern int32_t xlang_ensure_runtime_link_abi_user_env_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_link_abi_user_env_o_path(uint8_t * argv0);
extern int32_t xlang_host_is_linux(void);
extern int32_t link_abi_host_is_apple(void);
extern int32_t link_abi_host_is_windows(void);
/* wave223 G.7: env lookup authority = public pure thin link_abi_getenv (labi_diag_pure). */
extern uint8_t *link_abi_getenv(uint8_t *name);
extern uint8_t * labi_ld_flag_lc(void);
extern uint8_t * labi_ld_flag_lbcrypt(void);
extern uint8_t * labi_ld_flag_lws2_32(void);
/* wave200 ensure-push front peers */
extern int32_t xlang_ensure_runtime_process_argv_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_process_argv_o_path(uint8_t * argv0);
extern int32_t invoke_cc_append_net_tls_ld(uint8_t * * argv, int32_t * ia, int32_t argv_cap, uint8_t * net_o, uint8_t * repo_root);
extern int32_t xlang_ensure_runtime_net_udp_batch_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_net_udp_batch_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_net_workers_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_net_workers_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_asm_io_stubs_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_asm_io_stubs_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_thread_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_thread_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_formal_std_make_o(uint8_t * repo_root, uint8_t * rel_from_repo, uint8_t * make_target);
extern int32_t xlang_ensure_runtime_env_os_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_env_os_o_path(uint8_t * argv0);
/* wave201 ensure-push mid peers */
extern int32_t xlang_ensure_runtime_sync_lock_diag_tls_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_sync_lock_diag_tls_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sync_os_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_sync_os_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_ed25519_ref10_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_ed25519_ref10_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_crypto_inc_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_crypto_inc_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_log_os_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_log_os_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_atomic_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_atomic_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_channel_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_channel_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_backtrace_platform_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_backtrace_platform_o_path(uint8_t * argv0);
/* wave202 ensure-push heavy_a peers */
extern int32_t xlang_ensure_runtime_math_libm_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_math_libm_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_sqlite_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_sqlite_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_compress_zlib_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_compress_zlib_glue_o_path(uint8_t * argv0);
extern int32_t link_abi_generated_c_provides_core_mem(uint8_t * c_path);
extern int32_t link_abi_generated_c_provides_std_heap(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_zlib(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_zstd(uint8_t * c_path);
extern int32_t link_abi_generated_c_needs_brotli(uint8_t * c_path);
extern void invoke_cc_append_compress_ld(uint8_t * * argv, int32_t * ia, int32_t argv_cap, uint8_t * compress_o, uint8_t * user_o);
extern void ld_append_brew_lib_paths(uint8_t * * argv, int32_t * la, int32_t max_la);
/* wave203 ensure-push heavy_b peers */
extern int32_t xlang_ensure_runtime_dynlib_os_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_dynlib_os_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_http_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_http_glue_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_test_fn_invoke_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_test_fn_invoke_o_path(uint8_t * argv0);
extern int32_t xlang_ensure_runtime_scheduler_glue_o(uint8_t * argv0);
extern uint8_t * xlang_runtime_scheduler_glue_o_path(uint8_t * argv0);
extern uint8_t * xlang_std_async_scheduler_o_path(uint8_t * argv0);
extern int32_t xlang_generated_c_needs_async_scheduler(uint8_t * c_path);
extern uint8_t * scheduler_o_for_task_link(uint8_t * task_o, uint8_t * explicit_scheduler);
extern int32_t xlang_link_obj_needs_undef_sym(uint8_t * user_o, uint8_t * sym);
/* wave204 heap F-06 peers */
extern int32_t link_abi_link_needs_std_heap_import(uint8_t * user_o, uint8_t * * argv, int32_t la);
extern uint8_t * labi_od_rel_page_mmap(void);
/* wave205 fork-exec shell peers */
extern int32_t xlang_spawn_sync(uint8_t * prog, uint8_t * * argv);
extern int32_t setenv(const char *name, const char *value, int overwrite);
extern void link_diag_tool_status(uint8_t * tool, int32_t status);
extern void invoke_cc_strip_out_x(uint8_t * out_path);
/* wave207 argv tail peers */
extern uint8_t * asm_link_obj_skip_missing(uint8_t * path);
extern int32_t link_abi_user_extra_o_count(void);
extern uint8_t * link_abi_user_extra_o_at(int32_t i);
/* labi_icc_rel_error_o / labi_icc_rel_socketio_o / provides_* defined in this surface file */

int32_t labi_linux_harden_flag_count(void) {
  return 5;
}

uint8_t *labi_linux_harden_flag_at(int32_t i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return (uint8_t *)"-pie";
  if (i == 1)
    return (uint8_t *)"-fpie";
  if (i == 2)
    return (uint8_t *)"-Wl,-z,noexecstack";
  if (i == 3)
    return (uint8_t *)"-Wl,-z,relro";
  if (i == 4)
    return (uint8_t *)"-Wl,--allow-multiple-definition";
  return NULL;
}

int32_t labi_invoke_cc_skip_native_env_count(void) {
  return 3;
}

uint8_t *labi_invoke_cc_skip_native_env_at(int32_t i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return (uint8_t *)"CI";
  if (i == 1)
    return (uint8_t *)"XLANG_CI_DOCKER";
  if (i == 2)
    return (uint8_t *)"XLANG_NO_MARCH_NATIVE";
  return NULL;
}

int32_t invoke_cc_skip_native_tuning(void) {
  int32_t n = labi_invoke_cc_skip_native_env_count();
  int32_t i;
  for (i = 0; i < n; i++) {
    uint8_t *name = labi_invoke_cc_skip_native_env_at(i);
    /* wave223 G.7: link_abi_getenv (not raw getenv). */
    if (name && name[0] && link_abi_getenv(name) != NULL)
      return 1;
  }
  return 0;
}

uint8_t *labi_icc_rel_core_builtin_o(void) {
  return (uint8_t *)"core/builtin/builtin.o";
}
uint8_t *labi_icc_rel_core_builtin_abi_h(void) {
  return (uint8_t *)"core/builtin/builtin_abi.h";
}
uint8_t *labi_icc_rel_core_mem_o(void) {
  return (uint8_t *)"core/mem/mem.o";
}
uint8_t *labi_icc_rel_core_slice_o(void) {
  return (uint8_t *)"core/slice/slice.o";
}
uint8_t *labi_icc_rel_db_kv_o(void) {
  return (uint8_t *)"std/db/kv/kv.o";
}
uint8_t *labi_icc_rel_db_arrow_o(void) {
  return (uint8_t *)"std/db/arrow/arrow.o";
}
uint8_t *labi_icc_rel_csv_o(void) {
  return (uint8_t *)"std/csv/csv.o";
}
uint8_t *labi_icc_rel_error_o(void) {
  return (uint8_t *)"std/error/error.o";
}
uint8_t *labi_icc_rel_heap_o(void) {
  return (uint8_t *)"std/heap/heap.o";
}
uint8_t *labi_icc_rel_json_o(void) {
  return (uint8_t *)"std/json/json.o";
}
uint8_t *labi_icc_rel_log_o(void) {
  return (uint8_t *)"std/log/log.o";
}
uint8_t *labi_icc_rel_socketio_o(void) {
  return (uint8_t *)"std/socketio/socketio.o";
}

int32_t labi_icc_needs_rel_count(void) {
  return 12;
}

uint8_t *labi_icc_needs_rel_at(int32_t i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return (uint8_t *)"core/builtin/builtin.o";
  if (i == 1)
    return (uint8_t *)"core/builtin/builtin_abi.h";
  if (i == 2)
    return (uint8_t *)"core/mem/mem.o";
  if (i == 3)
    return (uint8_t *)"core/slice/slice.o";
  if (i == 4)
    return (uint8_t *)"std/db/kv/kv.o";
  if (i == 5)
    return (uint8_t *)"std/db/arrow/arrow.o";
  if (i == 6)
    return (uint8_t *)"std/csv/csv.o";
  if (i == 7)
    return (uint8_t *)"std/error/error.o";
  if (i == 8)
    return (uint8_t *)"std/heap/heap.o";
  if (i == 9)
    return (uint8_t *)"std/json/json.o";
  if (i == 10)
    return (uint8_t *)"std/log/log.o";
  if (i == 11)
    return (uint8_t *)"std/socketio/socketio.o";
  return NULL;
}

/* wave155: xlang_append_linux_link_harden_impl pure orch (surface pin; pure harden table). */
void xlang_append_linux_link_harden_impl(uint8_t **argv, int32_t *la, int32_t cap) {
  int32_t n;
  int32_t k;
  if (!argv || !la || *la < 0)
    return;
  n = labi_linux_harden_flag_count();
  for (k = 0; k < n; k++) {
    uint8_t *f = labi_linux_harden_flag_at(k);
    if (!f || !f[0])
      continue;
    if (*la < cap - 1)
      argv[(*la)++] = f;
  }
}

/* wave198: labi_icc_argv_try_push_flag + invoke_cc_append_early_needs pure orch (surface pin ≡ .x). */
void labi_icc_argv_try_push_flag(uint8_t **argv, int32_t *ia, int32_t cap, uint8_t *flag) {
  if (!argv || !ia || *ia < 0 || !flag || !flag[0])
    return;
  if (*ia < cap - 1)
    argv[(*ia)++] = flag;
}

void invoke_cc_append_early_needs(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    uint8_t **c_paths, int32_t n, uint8_t *include_root,
    uint8_t *random_o, uint8_t *time_o, uint8_t *runtime_o, uint8_t *runtime_panic_o) {
  int32_t needs_core_builtin = 0, needs_core_mem = 0, needs_core_slice = 0;
  int32_t needs_db_kv = 0, needs_db_arrow = 0, needs_fs = 0;
  int32_t needs_random = 0, needs_time = 0, needs_runtime = 0;
  int32_t needs_win32 = 0, needs_win32_wsa = 0, needs_libc_heap = 0;
  int32_t j;
  if (!argv || !ia || *ia < 0)
    return;
  if (c_paths && n > 0) {
    for (j = 0; j < n; j++) {
      uint8_t *cp = c_paths[j];
      if (!cp)
        continue;
      if (link_abi_generated_c_needs_core_builtin(cp))
        needs_core_builtin = 1;
      if (link_abi_generated_c_needs_core_mem(cp))
        needs_core_mem = 1;
      if (link_abi_generated_c_needs_core_slice(cp))
        needs_core_slice = 1;
      if (link_abi_generated_c_needs_db_kv(cp))
        needs_db_kv = 1;
      if (link_abi_generated_c_needs_db_arrow(cp))
        needs_db_arrow = 1;
      if (link_abi_generated_c_needs_fs(cp))
        needs_fs = 1;
      if (link_abi_generated_c_needs_random(cp))
        needs_random = 1;
      if (link_abi_generated_c_needs_time(cp))
        needs_time = 1;
      if (link_abi_generated_c_needs_runtime(cp))
        needs_runtime = 1;
      if (link_abi_generated_c_needs_win32(cp))
        needs_win32 = 1;
      if (link_abi_generated_c_needs_win32_wsa(cp))
        needs_win32_wsa = 1;
      if (link_abi_generated_c_needs_libc_heap(cp))
        needs_libc_heap = 1;
    }
  }
  if (needs_core_builtin) {
    uint8_t *abi_h = xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_abi_h());
    if (abi_h && abi_h[0] && *ia < argv_cap - 2) {
      argv[(*ia)++] = (uint8_t *)"-include";
      argv[(*ia)++] = abi_h;
    }
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_o()));
  }
  if (needs_core_mem)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
  if (needs_core_slice)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_slice_o()));
  if (needs_db_kv) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_db_kv_o()));
    {
      uint8_t *rkv = xlang_runtime_kv_mmap_glue_o_path(NULL);
      if (rkv && rkv[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rkv);
    }
  }
  if (needs_db_arrow) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_db_arrow_o()));
    {
      uint8_t *rar = xlang_runtime_arrow_simd_glue_o_path(NULL);
      if (rar && rar[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rar);
    }
  }
  if (needs_fs) {
    if (xlang_host_is_linux() || link_abi_host_is_apple())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lc());
  }
  if (needs_random) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, random_o);
    (void)xlang_ensure_runtime_random_fill_o(NULL);
    {
      uint8_t *rrf = xlang_runtime_random_fill_o_path(NULL);
      if (rrf && rrf[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rrf);
    }
    if (link_abi_host_is_windows())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lbcrypt());
  }
  if (needs_time) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, time_o);
    (void)xlang_ensure_runtime_time_os_o(NULL);
    {
      uint8_t *rto = xlang_runtime_time_os_o_path(NULL);
      if (rto && rto[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rto);
    }
  }
  if (needs_runtime) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_o);
    (void)xlang_ensure_runtime_panic_o(NULL);
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_panic_o);
    {
      uint8_t *rp = xlang_runtime_panic_o_path(NULL);
      if (rp && rp[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rp);
    }
  }
  if (needs_win32 && link_abi_host_is_windows())
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lkernel32");
  if (needs_win32_wsa && link_abi_host_is_windows())
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lws2_32());
  if (needs_libc_heap) {
    if (xlang_host_is_linux() || link_abi_host_is_apple())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lc());
  }
}

/* wave199: labi_icc_std_need_* + invoke_cc_scan_std_module_needs pure orch (surface pin ≡ .x). */
int32_t labi_icc_std_need_count(void) { return 52; }

int32_t labi_icc_std_need_needle_count(int32_t mid) {

  if (mid == 0) return 5;
  if (mid == 1) return 8;
  if (mid == 2) return 2;
  if (mid == 3) return 3;
  if (mid == 4) return 1;
  if (mid == 5) return 18;
  if (mid == 6) return 3;
  if (mid == 7) return 3;
  if (mid == 8) return 2;
  if (mid == 9) return 3;
  if (mid == 10) return 3;
  if (mid == 11) return 1;
  if (mid == 12) return 3;
  if (mid == 13) return 5;
  if (mid == 14) return 3;
  if (mid == 15) return 4;
  if (mid == 16) return 3;
  if (mid == 17) return 2;
  if (mid == 18) return 3;
  if (mid == 19) return 3;
  if (mid == 20) return 3;
  if (mid == 21) return 10;
  if (mid == 22) return 2;
  if (mid == 23) return 3;
  if (mid == 24) return 2;
  if (mid == 25) return 2;
  if (mid == 26) return 2;
  if (mid == 27) return 2;
  if (mid == 28) return 4;
  if (mid == 29) return 2;
  if (mid == 30) return 2;
  if (mid == 31) return 3;
  if (mid == 32) return 3;
  if (mid == 33) return 1;
  if (mid == 34) return 8;
  if (mid == 35) return 2;
  if (mid == 36) return 1;
  if (mid == 37) return 3;
  if (mid == 38) return 3;
  if (mid == 39) return 2;
  if (mid == 40) return 1;
  if (mid == 41) return 1;
  if (mid == 42) return 1;
  if (mid == 43) return 1;
  if (mid == 44) return 1;
  if (mid == 45) return 1;
  if (mid == 46) return 2;
  if (mid == 47) return 3;
  if (mid == 48) return 1;
  if (mid == 49) return 1;
  if (mid == 50) return 1;
  if (mid == 51) return 1;
  return 0;
}

uint8_t *labi_icc_std_need_needle_at(int32_t mid, int32_t i) {
  if (i < 0) return NULL;

  if (mid == 0) {
    if (i == 0) return (uint8_t *)"std_process_";
    if (i == 1) return (uint8_t *)"xlang_process_spawn";
    if (i == 2) return (uint8_t *)"xlang_process_wait";
    if (i == 3) return (uint8_t *)"process_spawn";
    if (i == 4) return (uint8_t *)"process_exec";
    return NULL;
  }
  if (mid == 1) {
    if (i == 0) return (uint8_t *)"process_xlang_argc_get";
    if (i == 1) return (uint8_t *)"process_xlang_argv_get";
    if (i == 2) return (uint8_t *)"process_args_count_c";
    if (i == 3) return (uint8_t *)"process_arg_c";
    if (i == 4) return (uint8_t *)"args_iter_count_c";
    if (i == 5) return (uint8_t *)"args_iter_at_c";
    if (i == 6) return (uint8_t *)"std_process_args";
    if (i == 7) return (uint8_t *)"std_env_args_iter";
    return NULL;
  }
  if (mid == 2) {
    if (i == 0) return (uint8_t *)"std_string_";
    if (i == 1) return (uint8_t *)"xlang_string_";
    return NULL;
  }
  if (mid == 3) {
    if (i == 0) return (uint8_t *)"std_path_";
    if (i == 1) return (uint8_t *)"path_join";
    if (i == 2) return (uint8_t *)"path_dirname";
    return NULL;
  }
  if (mid == 4) {
    if (i == 0) return (uint8_t *)"std_runtime_";
    return NULL;
  }
  if (mid == 5) {
    if (i == 0) return (uint8_t *)"std_net_listen";
    if (i == 1) return (uint8_t *)"std_net_connect";
    if (i == 2) return (uint8_t *)"std_net_udp_bind";
    if (i == 3) return (uint8_t *)"std_net_udp_recv";
    if (i == 4) return (uint8_t *)"std_net_udp_send";
    if (i == 5) return (uint8_t *)"std_net_addr_to_u32";
    if (i == 6) return (uint8_t *)"std_net_close_udp";
    if (i == 7) return (uint8_t *)"net_tcp_connect_c";
    if (i == 8) return (uint8_t *)"net_tcp_listen_c";
    if (i == 9) return (uint8_t *)"net_udp_bind_c";
    if (i == 10) return (uint8_t *)"net_udp_recv_many_buf_c";
    if (i == 11) return (uint8_t *)"net_udp_send_many_buf_c";
    if (i == 12) return (uint8_t *)"net_udp_send_c";
    if (i == 13) return (uint8_t *)"net_dns_resolve_c";
    if (i == 14) return (uint8_t *)"net_sock_create_c";
    if (i == 15) return (uint8_t *)"net_stream_write_batch_c";
    if (i == 16) return (uint8_t *)"net_close_socket_c_real";
    if (i == 17) return (uint8_t *)"net_run_accept_workers_c_real";
    return NULL;
  }
  if (mid == 6) {
    if (i == 0) return (uint8_t *)"std_thread_";
    if (i == 1) return (uint8_t *)"thread_create_c";
    if (i == 2) return (uint8_t *)"thread_join_c";
    return NULL;
  }
  if (mid == 7) {
    if (i == 0) return (uint8_t *)"std_time_";
    if (i == 1) return (uint8_t *)"time_now_";
    if (i == 2) return (uint8_t *)"time_sleep_";
    return NULL;
  }
  if (mid == 8) {
    if (i == 0) return (uint8_t *)"std_random_";
    if (i == 1) return (uint8_t *)"random_fill_";
    return NULL;
  }
  if (mid == 9) {
    if (i == 0) return (uint8_t *)"std_env_";
    if (i == 1) return (uint8_t *)"env_get_";
    if (i == 2) return (uint8_t *)"env_set_";
    return NULL;
  }
  if (mid == 10) {
    if (i == 0) return (uint8_t *)"std_sync_";
    if (i == 1) return (uint8_t *)"sync_mutex_";
    if (i == 2) return (uint8_t *)"sync_rwlock_";
    return NULL;
  }
  if (mid == 11) {
    if (i == 0) return (uint8_t *)"std_encoding_";
    return NULL;
  }
  if (mid == 12) {
    if (i == 0) return (uint8_t *)"std_base64_";
    if (i == 1) return (uint8_t *)"base64_encode";
    if (i == 2) return (uint8_t *)"base64_decode";
    return NULL;
  }
  if (mid == 13) {
    if (i == 0) return (uint8_t *)"std_crypto_";
    if (i == 1) return (uint8_t *)"core_crypto_mem_eq";
    if (i == 2) return (uint8_t *)"core_crypto_sha";
    if (i == 3) return (uint8_t *)"crypto_sha";
    if (i == 4) return (uint8_t *)"ed25519_";
    return NULL;
  }
  if (mid == 14) {
    if (i == 0) return (uint8_t *)"std_log_";
    if (i == 1) return (uint8_t *)"log_write_c";
    if (i == 2) return (uint8_t *)"log_info_";
    return NULL;
  }
  if (mid == 15) {
    if (i == 0) return (uint8_t *)"std_atomic_";
    if (i == 1) return (uint8_t *)"atomic_load_i32_c";
    if (i == 2) return (uint8_t *)"atomic_store_i32_c";
    if (i == 3) return (uint8_t *)"atomic_fetch_";
    return NULL;
  }
  if (mid == 16) {
    if (i == 0) return (uint8_t *)"std_channel_";
    if (i == 1) return (uint8_t *)"channel_send";
    if (i == 2) return (uint8_t *)"channel_recv";
    return NULL;
  }
  if (mid == 17) {
    if (i == 0) return (uint8_t *)"std_backtrace_";
    if (i == 1) return (uint8_t *)"backtrace_capture";
    return NULL;
  }
  if (mid == 18) {
    if (i == 0) return (uint8_t *)"std_hash_";
    if (i == 1) return (uint8_t *)"hash_fnv";
    if (i == 2) return (uint8_t *)"hash_sip";
    return NULL;
  }
  if (mid == 19) {
    if (i == 0) return (uint8_t *)"std_math_";
    if (i == 1) return (uint8_t *)"math_sin";
    if (i == 2) return (uint8_t *)"math_cos";
    return NULL;
  }
  if (mid == 20) {
    if (i == 0) return (uint8_t *)"std_sort_";
    if (i == 1) return (uint8_t *)"sort_i32";
    if (i == 2) return (uint8_t *)"sort_stable";
    return NULL;
  }
  if (mid == 21) {
    if (i == 0) return (uint8_t *)"std_vec_new";
    if (i == 1) return (uint8_t *)"std_vec_push";
    if (i == 2) return (uint8_t *)"std_vec_len_Vec";
    if (i == 3) return (uint8_t *)"std_vec_len_ptr";
    if (i == 4) return (uint8_t *)"std_vec_with_capacity";
    if (i == 5) return (uint8_t *)"std_vec_from_slice";
    if (i == 6) return (uint8_t *)"std_vec_append";
    if (i == 7) return (uint8_t *)"std_vec_reserve";
    if (i == 8) return (uint8_t *)"std_vec_clear";
    if (i == 9) return (uint8_t *)"std_vec_free";
    return NULL;
  }
  if (mid == 22) {
    if (i == 0) return (uint8_t *)"std_ffi_";
    if (i == 1) return (uint8_t *)"ffi_call";
    return NULL;
  }
  if (mid == 23) {
    if (i == 0) return (uint8_t *)"std_db_";
    if (i == 1) return (uint8_t *)"sqlite3_";
    if (i == 2) return (uint8_t *)"db_sqlite_";
    return NULL;
  }
  if (mid == 24) {
    if (i == 0) return (uint8_t *)"std_elf_";
    if (i == 1) return (uint8_t *)"elf_parse";
    return NULL;
  }
  if (mid == 25) {
    if (i == 0) return (uint8_t *)"std_json_";
    if (i == 1) return (uint8_t *)"json_parse_";
    return NULL;
  }
  if (mid == 26) {
    if (i == 0) return (uint8_t *)"std_csv_";
    if (i == 1) return (uint8_t *)"csv_next_field";
    return NULL;
  }
  if (mid == 27) {
    if (i == 0) return (uint8_t *)"std_regex_";
    if (i == 1) return (uint8_t *)"regex_match";
    return NULL;
  }
  if (mid == 28) {
    if (i == 0) return (uint8_t *)"std_compress_";
    if (i == 1) return (uint8_t *)"compress_gzip";
    if (i == 2) return (uint8_t *)"compress_zstd";
    if (i == 3) return (uint8_t *)"compress_brotli";
    return NULL;
  }
  if (mid == 29) {
    if (i == 0) return (uint8_t *)"std_unicode_";
    if (i == 1) return (uint8_t *)"unicode_utf8";
    return NULL;
  }
  if (mid == 30) {
    if (i == 0) return (uint8_t *)"std_dynlib_";
    if (i == 1) return (uint8_t *)"dynlib_open";
    return NULL;
  }
  if (mid == 31) {
    if (i == 0) return (uint8_t *)"std_http_";
    if (i == 1) return (uint8_t *)"http_request";
    if (i == 2) return (uint8_t *)"http2_";
    return NULL;
  }
  if (mid == 32) {
    if (i == 0) return (uint8_t *)"std_tar_";
    if (i == 1) return (uint8_t *)"tar_open";
    if (i == 2) return (uint8_t *)"tar_extract";
    return NULL;
  }
  if (mid == 33) {
    if (i == 0) return (uint8_t *)"std_simd_";
    return NULL;
  }
  if (mid == 34) {
    if (i == 0) return (uint8_t *)"std_context_background(";
    if (i == 1) return (uint8_t *)"std_context_with_cancel(";
    if (i == 2) return (uint8_t *)"std_context_with_deadline(";
    if (i == 3) return (uint8_t *)"std_context_with_timeout(";
    if (i == 4) return (uint8_t *)"std_context_cancel(";
    if (i == 5) return (uint8_t *)"std_context_set_value(";
    if (i == 6) return (uint8_t *)"std_context_get_value(";
    if (i == 7) return (uint8_t *)"std_context_free(";
    return NULL;
  }
  if (mid == 35) {
    if (i == 0) return (uint8_t *)"std_error_";
    if (i == 1) return (uint8_t *)"error_wrap_";
    return NULL;
  }
  if (mid == 36) {
    if (i == 0) return (uint8_t *)"std_datetime_";
    return NULL;
  }
  if (mid == 37) {
    if (i == 0) return (uint8_t *)"std_uuid_";
    if (i == 1) return (uint8_t *)"uuid_v4";
    if (i == 2) return (uint8_t *)"uuid_parse";
    return NULL;
  }
  if (mid == 38) {
    if (i == 0) return (uint8_t *)"std_url_";
    if (i == 1) return (uint8_t *)"url_parse";
    if (i == 2) return (uint8_t *)"url_join";
    return NULL;
  }
  if (mid == 39) {
    if (i == 0) return (uint8_t *)"std_cli_";
    if (i == 1) return (uint8_t *)"cli_parse";
    return NULL;
  }
  if (mid == 40) {
    if (i == 0) return (uint8_t *)"std_security_";
    return NULL;
  }
  if (mid == 41) {
    if (i == 0) return (uint8_t *)"std_config_";
    return NULL;
  }
  if (mid == 42) {
    if (i == 0) return (uint8_t *)"std_cache_";
    return NULL;
  }
  if (mid == 43) {
    if (i == 0) return (uint8_t *)"std_trace_";
    return NULL;
  }
  if (mid == 44) {
    if (i == 0) return (uint8_t *)"std_task_";
    return NULL;
  }
  if (mid == 45) {
    if (i == 0) return (uint8_t *)"std_schema_";
    return NULL;
  }
  if (mid == 46) {
    if (i == 0) return (uint8_t *)"std_test_";
    if (i == 1) return (uint8_t *)"test_call_";
    return NULL;
  }
  if (mid == 47) {
    if (i == 0) return (uint8_t *)"std_socketio_";
    if (i == 1) return (uint8_t *)"socketio_emit";
    if (i == 2) return (uint8_t *)"socketio_on";
    return NULL;
  }
  if (mid == 48) {
    if (i == 0) return (uint8_t *)"std_set_";
    return NULL;
  }
  if (mid == 49) {
    if (i == 0) return (uint8_t *)"std_map_";
    return NULL;
  }
  if (mid == 50) {
    if (i == 0) return (uint8_t *)"std_queue_";
    return NULL;
  }
  if (mid == 51) {
    if (i == 0) return (uint8_t *)"xlang_panic_(";
    return NULL;
  }
  return NULL;
}


void invoke_cc_scan_std_module_needs(uint8_t **c_paths, int32_t n, int32_t *flags, int32_t flags_cap) {
  int32_t k, j, mid, ni, nc;
  uint8_t *cp;
  uint8_t *nd;
  if (!flags || flags_cap < 52)
    return;
  for (k = 0; k < 52; k++)
    flags[k] = 0;
  if (!c_paths || n < 1)
    return;
  for (j = 0; j < n; j++) {
    cp = c_paths[j];
    if (!cp)
      continue;
    for (mid = 0; mid < 52; mid++) {
      if (mid == 51) {
        if (link_abi_generated_c_contains_substr_use_line(cp, (uint8_t *)"xlang_panic_(")
            && !link_abi_generated_c_contains_substr(cp, (uint8_t *)"void xlang_panic_(int has_msg, int msg_val) {")
            && !link_abi_generated_c_contains_substr(cp, (uint8_t *)"void xlang_panic_(int has_msg, int msg_val){"))
          flags[51] = 1;
        continue;
      }
      nc = labi_icc_std_need_needle_count(mid);
      for (ni = 0; ni < nc; ni++) {
        nd = labi_icc_std_need_needle_at(mid, ni);
        if (!nd)
          continue;
        if (link_abi_generated_c_contains_substr_use_line(cp, nd)) {
          flags[mid] = 1;
          break;
        }
      }
    }
  }
}

/* wave200: invoke_cc_append_std_ensure_push_front pure orch (surface pin ≡ .x). */
void invoke_cc_append_std_ensure_push_front(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    int32_t *need_flags, int32_t flags_cap, uint8_t *include_root,
    uint8_t *process_o, uint8_t *string_o, uint8_t *heap_o, uint8_t *path_o,
    uint8_t *runtime_o, uint8_t *runtime_panic_o, uint8_t *net_o, uint8_t *thread_o,
    uint8_t *time_o, uint8_t *random_o, uint8_t *env_o) {
  int32_t need_process, need_process_argv_glue, need_string, need_path, need_runtime;
  int32_t need_net, need_thread, need_time, need_random, need_env, need_panic;
  int32_t pushed_process_o = 0;
  if (!argv || !ia || *ia < 0 || !need_flags || flags_cap < 52)
    return;
  need_process = need_flags[0];
  need_process_argv_glue = need_flags[1];
  need_string = need_flags[2];
  need_path = need_flags[3];
  need_runtime = need_flags[4];
  need_net = need_flags[5];
  need_thread = need_flags[6];
  need_time = need_flags[7];
  need_random = need_flags[8];
  need_env = need_flags[9];
  need_panic = need_flags[51];

  if (need_string)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, string_o);

  if (need_process && invoke_cc_argv_push_existing(argv, ia, argv_cap, process_o)) {
    pushed_process_o = 1;
    if (xlang_host_is_linux())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-pthread");
  }
  if (!pushed_process_o && (need_process || need_env || need_process_argv_glue)) {
    (void)xlang_ensure_runtime_process_argv_o(NULL);
    {
      uint8_t *rpa = xlang_runtime_process_argv_o_path(NULL);
      if (rpa && rpa[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rpa);
    }
  }

  if (heap_o && heap_o[0])
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, heap_o);
  if (need_path)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, path_o);
  if (need_runtime)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_o);
  if (need_panic || need_runtime) {
    (void)xlang_ensure_runtime_panic_o(NULL);
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_panic_o);
    {
      uint8_t *rp = xlang_runtime_panic_o_path(NULL);
      if (rp && rp[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rp);
    }
  }
  /* wave288 L4 G.7: residual face companion — process/env/panic U link_abi_getenv.
   * PLATFORM: SHARED — ≡ PRIMARY_PANIC user_env on asm ld; invoke_cc was lagging. */
  if (need_process || need_env || need_panic || need_runtime) {
    (void)xlang_ensure_runtime_link_abi_user_env_o(NULL);
    {
      uint8_t *rue = xlang_runtime_link_abi_user_env_o_path(NULL);
      if (rue && rue[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rue);
    }
  }

  if (need_net && invoke_cc_argv_push_existing(argv, ia, argv_cap, net_o)) {
    (void)invoke_cc_append_net_tls_ld(argv, ia, argv_cap, net_o, include_root);
    (void)xlang_ensure_runtime_net_udp_batch_o(NULL);
    {
      uint8_t *rnub = xlang_runtime_net_udp_batch_o_path(NULL);
      if (rnub && rnub[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rnub);
    }
    (void)xlang_ensure_runtime_net_workers_o(NULL);
    {
      uint8_t *rnw = xlang_runtime_net_workers_o_path(NULL);
      if (rnw && rnw[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rnw);
    }
    need_thread = 1;
    need_flags[6] = 1;
    if (xlang_host_is_linux()) {
      (void)xlang_ensure_runtime_asm_io_stubs_o(NULL);
      {
        uint8_t *ris = xlang_runtime_asm_io_stubs_o_path(NULL);
        if (ris && ris[0])
          (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, ris);
      }
    }
    if (link_abi_host_is_windows())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lws2_32());
  }

  if (need_thread && invoke_cc_argv_push_existing(argv, ia, argv_cap, thread_o)) {
    (void)xlang_ensure_runtime_thread_glue_o(NULL);
    {
      uint8_t *rtg = xlang_runtime_thread_glue_o_path(NULL);
      if (rtg && rtg[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rtg);
    }
  }

  if (need_time) {
    if (include_root && include_root[0])
      (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/time/time.o", (uint8_t *)"../std/time/time.o");
    {
      uint8_t *time_push = xlang_rel_o_path_from_argv0(include_root, (uint8_t *)"std/time/time.o");
      if ((!time_push || !time_push[0]) && time_o && time_o[0])
        time_push = time_o;
      (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, time_push);
    }
    (void)xlang_ensure_runtime_time_os_o(NULL);
    {
      uint8_t *rto = xlang_runtime_time_os_o_path(NULL);
      if (rto && rto[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rto);
    }
  }

  if (need_random) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, random_o);
    (void)xlang_ensure_runtime_random_fill_o(NULL);
    {
      uint8_t *rrf = xlang_runtime_random_fill_o_path(NULL);
      if (rrf && rrf[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rrf);
    }
    if (link_abi_host_is_windows())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lbcrypt());
  }

  if (need_env) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, env_o);
    (void)xlang_ensure_runtime_env_os_o(NULL);
    {
      uint8_t *reo = xlang_runtime_env_os_o_path(NULL);
      if (reo && reo[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, reo);
    }
  }
}

/* wave201: invoke_cc_append_std_ensure_push_mid pure orch (surface pin ≡ .x). */
void invoke_cc_append_std_ensure_push_mid(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    int32_t *need_flags, int32_t flags_cap, uint8_t *include_root,
    uint8_t *sync_o, uint8_t *encoding_o, uint8_t *base64_o, uint8_t *crypto_o,
    uint8_t *atomic_o, uint8_t *channel_o, uint8_t *backtrace_o, uint8_t *hash_o) {
  int32_t need_sync, need_encoding, need_base64, need_crypto, need_log;
  int32_t need_atomic, need_channel, need_backtrace, need_hash;
  if (!argv || !ia || *ia < 0 || !need_flags || flags_cap < 52)
    return;
  need_sync = need_flags[10];
  need_encoding = need_flags[11];
  need_base64 = need_flags[12];
  need_crypto = need_flags[13];
  need_log = need_flags[14];
  need_atomic = need_flags[15];
  need_channel = need_flags[16];
  need_backtrace = need_flags[17];
  need_hash = need_flags[18];

  if (need_sync && invoke_cc_argv_push_existing(argv, ia, argv_cap, sync_o)) {
    (void)xlang_ensure_runtime_sync_lock_diag_tls_o(NULL);
    {
      uint8_t *rsld = xlang_runtime_sync_lock_diag_tls_o_path(NULL);
      if (rsld && rsld[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rsld);
    }
    (void)xlang_ensure_runtime_sync_os_o(NULL);
    {
      uint8_t *rso = xlang_runtime_sync_os_o_path(NULL);
      if (rso && rso[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rso);
    }
  }
  if (need_encoding)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, encoding_o);
  if (need_base64)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, base64_o);
  if (need_crypto) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, crypto_o);
    (void)xlang_ensure_runtime_ed25519_ref10_glue_o(NULL);
    {
      uint8_t *red = xlang_runtime_ed25519_ref10_glue_o_path(NULL);
      if (red && red[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, red);
    }
    (void)xlang_ensure_runtime_crypto_inc_glue_o(NULL);
    {
      uint8_t *rci = xlang_runtime_crypto_inc_glue_o_path(NULL);
      if (rci && rci[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rci);
    }
  }
  if (need_log && invoke_cc_argv_push_existing(argv, ia, argv_cap,
      xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_log_o()))) {
    (void)xlang_ensure_runtime_log_os_o(NULL);
    {
      uint8_t *rlo = xlang_runtime_log_os_o_path(NULL);
      if (rlo && rlo[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rlo);
    }
    /* wave288 L4: log_os residual U link_abi_getenv → user_env face. */
    (void)xlang_ensure_runtime_link_abi_user_env_o(NULL);
    {
      uint8_t *rue = xlang_runtime_link_abi_user_env_o_path(NULL);
      if (rue && rue[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rue);
    }
  }
  if (need_atomic && invoke_cc_argv_push_existing(argv, ia, argv_cap, atomic_o)) {
    (void)xlang_ensure_runtime_atomic_glue_o(NULL);
    {
      uint8_t *rag = xlang_runtime_atomic_glue_o_path(NULL);
      if (rag && rag[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rag);
    }
  }
  if (need_channel) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, channel_o);
    (void)xlang_ensure_runtime_channel_glue_o(NULL);
    {
      uint8_t *rcg = xlang_runtime_channel_glue_o_path(NULL);
      if (rcg && rcg[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rcg);
    }
  }
  if (need_backtrace) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, backtrace_o);
    (void)xlang_ensure_runtime_backtrace_platform_o(NULL);
    {
      uint8_t *rbp = xlang_runtime_backtrace_platform_o_path(NULL);
      if (rbp && rbp[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rbp);
    }
    /* wave288 L4: backtrace residual U link_abi_getenv → user_env face. */
    (void)xlang_ensure_runtime_link_abi_user_env_o(NULL);
    {
      uint8_t *rue = xlang_runtime_link_abi_user_env_o_path(NULL);
      if (rue && rue[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rue);
    }
    if (xlang_host_is_linux()) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-rdynamic");
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-ldl");
    } else if (link_abi_host_is_apple()) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-Wl,-export_dynamic");
    } else if (link_abi_host_is_windows()) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-ldbghelp");
    }
  }
  if (need_hash)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, hash_o);
}

/* wave202: invoke_cc_append_std_ensure_push_heavy_a pure orch (surface pin ≡ .x). */
void invoke_cc_append_std_ensure_push_heavy_a(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    int32_t *need_flags, int32_t flags_cap, uint8_t *include_root,
    uint8_t **c_paths, int32_t n,
    uint8_t *math_o, uint8_t *sort_o, uint8_t *ffi_o, uint8_t *db_o,
    uint8_t *elf_o, uint8_t *regex_o, uint8_t *compress_o, uint8_t *hash_o) {
  int32_t need_math, need_sort, need_vec, need_ffi, need_db, need_elf;
  int32_t need_json, need_csv, need_regex, need_compress;
  int32_t need_set, need_map, need_queue;
  int32_t jscan;
  if (!argv || !ia || *ia < 0 || !need_flags || flags_cap < 52)
    return;
  need_math = need_flags[19];
  need_sort = need_flags[20];
  need_vec = need_flags[21];
  need_ffi = need_flags[22];
  need_db = need_flags[23];
  need_elf = need_flags[24];
  need_json = need_flags[25];
  need_csv = need_flags[26];
  need_regex = need_flags[27];
  need_compress = need_flags[28];
  need_set = need_flags[48];
  need_map = need_flags[49];
  need_queue = need_flags[50];

  if (need_math) {
    if (include_root && include_root[0])
      (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/math/math.o", (uint8_t *)"../std/math/math.o");
    {
      uint8_t *math_push = xlang_rel_o_path_from_argv0(include_root, (uint8_t *)"std/math/math.o");
      if ((!math_push || !math_push[0]) && math_o && math_o[0])
        math_push = math_o;
      if (invoke_cc_argv_push_existing(argv, ia, argv_cap, math_push)) {
        (void)xlang_ensure_runtime_math_libm_o(NULL);
        {
          uint8_t *rml = xlang_runtime_math_libm_o_path(NULL);
          if (rml && rml[0])
            (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rml);
        }
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lm");
      }
    }
  }
  if (need_sort) {
    int32_t have_sort_body = 0;
    for (jscan = 0; jscan < n; jscan++) {
      uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
      if (!cp)
        continue;
      if (link_abi_generated_c_contains_substr(cp, (uint8_t *)"void std_sort_sort_") != 0 ||
          link_abi_generated_c_contains_substr(cp, (uint8_t *)"void std_sort_sort(") != 0) {
        have_sort_body = 1;
        break;
      }
    }
    if (!have_sort_body)
      (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, sort_o);
  }
  if (need_vec) {
    int32_t have_vec_body = 0;
    for (jscan = 0; jscan < n; jscan++) {
      uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
      if (!cp)
        continue;
      if (link_abi_generated_c_contains_substr(cp, (uint8_t *)"std_vec_new_retVec_u8(void) {") != 0 ||
          link_abi_generated_c_contains_substr(cp, (uint8_t *)"std_vec_new_retVec_u8(void){") != 0 ||
          link_abi_generated_c_contains_substr(cp, (uint8_t *)"std_vec_push_Vec_u8_ptr_u8(struct std_vec_Vec_u8 * v, uint8_t x) {") != 0 ||
          link_abi_generated_c_contains_substr(cp, (uint8_t *)"std_vec_push_Vec_u8_ptr_u8(struct std_vec_Vec_u8 *v, uint8_t x){") != 0) {
        have_vec_body = 1;
        break;
      }
    }
    if (!have_vec_body) {
      int32_t c_prov_cm_v = 0;
      int32_t c_prov_sh_v = 0;
      for (jscan = 0; jscan < n; jscan++) {
        uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
        if (!cp) continue;
        if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_v = 1;
        if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_v = 1;
      }
      if (include_root && include_root[0]) {
        (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/vec/vec.o", (uint8_t *)"../std/vec/vec.o");
        if (!c_prov_sh_v) (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/heap/heap.o", (uint8_t *)"../std/heap/heap.o");
        if (!c_prov_cm_v) (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"core/mem/mem.o", (uint8_t *)"../core/mem/mem.o");
      }
      if (invoke_cc_argv_push_existing(argv, ia, argv_cap,
          xlang_rel_o_path_from_argv0(include_root, (uint8_t *)"std/vec/vec.o"))) {
        if (!c_prov_sh_v) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
            xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
        if (!c_prov_cm_v) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
            xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
      }
    }
  }
  if (need_ffi)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, ffi_o);
  if (need_db && invoke_cc_argv_push_existing(argv, ia, argv_cap, db_o)) {
    (void)xlang_ensure_runtime_sqlite_glue_o(NULL);
    {
      uint8_t *rsg = xlang_runtime_sqlite_glue_o_path(NULL);
      if (rsg && rsg[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rsg);
    }
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lsqlite3");
  }
  if (need_elf)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, elf_o);
  if (need_json)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_json_o()));
  if (need_csv)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_csv_o()));
  if (need_set) {
    int32_t c_prov_cm_s = 0, c_prov_sh_s = 0;
    for (jscan = 0; jscan < n; jscan++) {
      uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
      if (!cp) continue;
      if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_s = 1;
      if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_s = 1;
    }
    if (include_root && include_root[0]) {
      (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/set/set.o", (uint8_t *)"../std/set/set.o");
      if (!c_prov_sh_s) (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/heap/heap.o", (uint8_t *)"../std/heap/heap.o");
      if (!c_prov_cm_s) (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"core/mem/mem.o", (uint8_t *)"../core/mem/mem.o");
    }
    if (invoke_cc_argv_push_existing(argv, ia, argv_cap,
            xlang_rel_o_path_from_argv0(include_root, (uint8_t *)"std/set/set.o"))) {
      if (!c_prov_sh_s) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
          xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
      if (!c_prov_cm_s) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
          xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
      (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, hash_o);
    }
  }
  if (need_map) {
    int32_t c_prov_cm_m = 0, c_prov_sh_m = 0;
    for (jscan = 0; jscan < n; jscan++) {
      uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
      if (!cp) continue;
      if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_m = 1;
      if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_m = 1;
    }
    if (include_root && include_root[0]) {
      (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/map/map.o", (uint8_t *)"../std/map/map.o");
      if (!c_prov_sh_m) (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"std/heap/heap.o", (uint8_t *)"../std/heap/heap.o");
      if (!c_prov_cm_m) (void)xlang_ensure_formal_std_make_o(include_root, (uint8_t *)"core/mem/mem.o", (uint8_t *)"../core/mem/mem.o");
    }
    if (invoke_cc_argv_push_existing(argv, ia, argv_cap,
            xlang_rel_o_path_from_argv0(include_root, (uint8_t *)"std/map/map.o"))) {
      if (!c_prov_sh_m) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
          xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
      if (!c_prov_cm_m) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
          xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
    }
  }
  if (need_queue && invoke_cc_argv_push_existing(argv, ia, argv_cap,
          xlang_rel_o_path_from_argv0(include_root, (uint8_t *)"std/queue/queue.o"))) {
    int32_t c_prov_cm_q = 0, c_prov_sh_q = 0;
    for (jscan = 0; jscan < n; jscan++) {
      uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
      if (!cp) continue;
      if (link_abi_generated_c_provides_core_mem(cp)) c_prov_cm_q = 1;
      if (link_abi_generated_c_provides_std_heap(cp)) c_prov_sh_q = 1;
    }
    if (!c_prov_sh_q) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
    if (!c_prov_cm_q) (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
  }
  if (need_regex)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, regex_o);
  if (need_compress && invoke_cc_argv_push_existing(argv, ia, argv_cap, compress_o))
    invoke_cc_append_compress_ld(argv, ia, argv_cap, compress_o, NULL);
  else {
    int32_t needs_zlib = 0, needs_zstd = 0, needs_brotli = 0, j;
    for (j = 0; j < n; j++) {
      uint8_t *cp = c_paths ? c_paths[j] : NULL;
      if (!cp) continue;
      if (link_abi_generated_c_needs_zlib(cp))
        needs_zlib = 1;
      if (link_abi_generated_c_needs_zstd(cp))
        needs_zstd = 1;
      if (link_abi_generated_c_needs_brotli(cp))
        needs_brotli = 1;
    }
    if (needs_zlib || needs_zstd || needs_brotli) {
      ld_append_brew_lib_paths(argv, ia, argv_cap);
      if (needs_zlib) {
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lz");
        (void)xlang_ensure_runtime_compress_zlib_glue_o(NULL);
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
            xlang_runtime_compress_zlib_glue_o_path(NULL));
      }
      if (needs_zstd)
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lzstd");
      if (needs_brotli) {
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lbrotlienc");
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lbrotlidec");
      }
    }
  }
}

/* wave203: invoke_cc_append_std_ensure_push_heavy_b pure orch (surface pin ≡ .x). */
void invoke_cc_append_std_ensure_push_heavy_b(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    int32_t *need_flags, int32_t flags_cap, uint8_t *include_root,
    uint8_t **c_paths, int32_t n,
    uint8_t *unicode_o, uint8_t *dynlib_o, uint8_t *http_o, uint8_t *tar_o,
    uint8_t *simd_o, uint8_t *context_o, uint8_t *datetime_o, uint8_t *uuid_o,
    uint8_t *url_o, uint8_t *cli_o, uint8_t *security_o, uint8_t *config_o,
    uint8_t *cache_o, uint8_t *trace_o, uint8_t *task_o, uint8_t *schema_o,
    uint8_t *test_o, uint8_t *async_scheduler_o) {
  int32_t need_unicode, need_dynlib, need_http, need_tar, need_simd, need_context;
  int32_t need_error, need_datetime, need_uuid, need_url, need_cli, need_security;
  int32_t need_config, need_cache, need_trace, need_task, need_schema, need_test, need_socketio;
  int32_t jscan;
  uint8_t *sched_link;
  int32_t task_linked = 0;
  if (!argv || !ia || *ia < 0 || !need_flags || flags_cap < 52)
    return;
  need_unicode = need_flags[29];
  need_dynlib = need_flags[30];
  need_http = need_flags[31];
  need_tar = need_flags[32];
  need_simd = need_flags[33];
  need_context = need_flags[34];
  need_error = need_flags[35];
  need_datetime = need_flags[36];
  need_uuid = need_flags[37];
  need_url = need_flags[38];
  need_cli = need_flags[39];
  need_security = need_flags[40];
  need_config = need_flags[41];
  need_cache = need_flags[42];
  need_trace = need_flags[43];
  need_task = need_flags[44];
  need_schema = need_flags[45];
  need_test = need_flags[46];
  need_socketio = need_flags[47];
  sched_link = async_scheduler_o;

  if (need_unicode) {
    int32_t have_unicode_body = 0;
    for (jscan = 0; jscan < n; jscan++) {
      uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
      if (!cp)
        continue;
      if (link_abi_generated_c_contains_substr(cp, (uint8_t *)"int32_t std_unicode_category(") != 0 ||
          link_abi_generated_c_contains_substr(cp, (uint8_t *)"int32_t std_unicode_unicode_category(") != 0) {
        have_unicode_body = 1;
        break;
      }
    }
    if (!have_unicode_body)
      (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, unicode_o);
  }
  if (need_dynlib && invoke_cc_argv_push_existing(argv, ia, argv_cap, dynlib_o)) {
    (void)xlang_ensure_runtime_dynlib_os_o(NULL);
    {
      uint8_t *rdo = xlang_runtime_dynlib_os_o_path(NULL);
      if (rdo && rdo[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rdo);
    }
    if (xlang_host_is_linux())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-ldl");
  }
  if (need_http && invoke_cc_argv_push_existing(argv, ia, argv_cap, http_o)) {
    (void)xlang_ensure_runtime_http_glue_o(NULL);
    {
      uint8_t *rhg = xlang_runtime_http_glue_o_path(NULL);
      if (rhg && rhg[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rhg);
    }
    /* wave288 L4: http_glue residual U link_abi_getenv → user_env face. */
    (void)xlang_ensure_runtime_link_abi_user_env_o(NULL);
    {
      uint8_t *rue = xlang_runtime_link_abi_user_env_o_path(NULL);
      if (rue && rue[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rue);
    }
    if (link_abi_host_is_windows())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lws2_32());
    need_error = 1;
  }
  if (need_socketio)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_socketio_o()));
  if (need_tar)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, tar_o);
  if (need_simd)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, simd_o);
  if (need_context)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, context_o);
  if (need_error)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_error_o()));
  if (need_datetime)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, datetime_o);
  if (need_uuid)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, uuid_o);
  if (need_url)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, url_o);
  if (need_cli)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, cli_o);
  if (need_security)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, security_o);
  if (need_config)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, config_o);
  if (need_cache)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, cache_o);
  if (need_trace)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, trace_o);
  if (need_task)
    task_linked = invoke_cc_argv_push_existing(argv, ia, argv_cap, task_o);
  if (need_schema)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, schema_o);
  if (need_test && invoke_cc_argv_push_existing(argv, ia, argv_cap, test_o)) {
    (void)xlang_ensure_runtime_test_fn_invoke_o(NULL);
    {
      uint8_t *rtfi = xlang_runtime_test_fn_invoke_o_path(NULL);
      if (rtfi && rtfi[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rtfi);
    }
  }
  if (!(sched_link && sched_link[0])) {
    for (jscan = 0; jscan < n; jscan++) {
      uint8_t *cp = c_paths ? c_paths[jscan] : NULL;
      if (!cp)
        continue;
      if (xlang_generated_c_needs_async_scheduler(cp)) {
        sched_link = xlang_std_async_scheduler_o_path(include_root);
        break;
      }
    }
  }
  if (task_linked) {
    uint8_t *sched = scheduler_o_for_task_link(task_o, sched_link);
    if (invoke_cc_argv_push_existing(argv, ia, argv_cap, sched)) {
      if (xlang_host_is_linux())
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-pthread");
      (void)xlang_ensure_runtime_scheduler_glue_o(NULL);
      {
        uint8_t *rsg = xlang_runtime_scheduler_glue_o_path(NULL);
        if (rsg && rsg[0])
          (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rsg);
      }
    }
  } else if (sched_link && sched_link[0] &&
             invoke_cc_argv_push_existing(argv, ia, argv_cap, sched_link)) {
    if (xlang_host_is_linux())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-pthread");
    (void)xlang_ensure_runtime_scheduler_glue_o(NULL);
    {
      uint8_t *rsg = xlang_runtime_scheduler_glue_o_path(NULL);
      if (rsg && rsg[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rsg);
    }
  }
  {
    int32_t need_pav = 0;
    int32_t have_process_o = 0;
    int32_t have_pav = 0;
    int32_t ai;
    for (ai = 0; ai < *ia && argv[ai]; ai++) {
      uint8_t *e = argv[ai];
      if (!e || e[0] == '-')
        continue;
      if (strstr((const char *)e, "process.o") && !strstr((const char *)e, "process_argv"))
        have_process_o = 1;
      if (strstr((const char *)e, "runtime_process_argv.o") || strstr((const char *)e, "process_argv.o"))
        have_pav = 1;
      if (xlang_link_obj_needs_undef_sym(e, (uint8_t *)"process_xlang_argc_get") ||
          xlang_link_obj_needs_undef_sym(e, (uint8_t *)"process_xlang_argv_get"))
        need_pav = 1;
    }
    if (need_pav && !have_process_o && !have_pav) {
      (void)xlang_ensure_runtime_process_argv_o(NULL);
      {
        uint8_t *rpa = xlang_runtime_process_argv_o_path(NULL);
        if (rpa && rpa[0])
          (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rpa);
      }
    }
  }
}

/* wave204: heap F-06 use_line needle table (surface pin ≡ .x). */
int32_t labi_icc_heap_f06_needle_count(void) {
  return 11;
}

uint8_t *labi_icc_heap_f06_needle_at(int32_t i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return (uint8_t *)"std_heap_alloc_size_zero";
  if (i == 1)
    return (uint8_t *)"std_heap_alloc_usize";
  if (i == 2)
    return (uint8_t *)"std_heap_default_alloc";
  if (i == 3)
    return (uint8_t *)"std_heap_kind_arena";
  if (i == 4)
    return (uint8_t *)"std_heap_heap_alloc";
  if (i == 5)
    return (uint8_t *)"std_heap_alloc_Allocator";
  if (i == 6)
    return (uint8_t *)"std_heap_realloc_Allocator";
  if (i == 7)
    return (uint8_t *)"std_heap_free_Allocator";
  if (i == 8)
    return (uint8_t *)"std_heap_arena64_alloc";
  if (i == 9)
    return (uint8_t *)"std_heap_map_find";
  if (i == 10)
    return (uint8_t *)"std_heap_libc_heap_alloc";
  return NULL;
}

/* wave204: invoke_cc_append_heap_f06_ondemand pure orch (surface pin ≡ .x). */
void invoke_cc_append_heap_f06_ondemand(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    uint8_t **c_paths, int32_t n, uint8_t *include_root) {
  int32_t need_heap = 0;
  int32_t c_provides_core_mem = 0;
  int32_t c_provides_std_heap = 0;
  int32_t cj;
  int32_t has_c_paths = (c_paths != NULL && n > 0);
  if (!argv || !ia || *ia < 0)
    return;
  if (link_abi_link_needs_std_heap_import(NULL, argv, *ia))
    need_heap = 1;
  if (!need_heap && has_c_paths) {
    int32_t nc = labi_icc_heap_f06_needle_count();
    for (cj = 0; cj < n && !need_heap; cj++) {
      uint8_t *cp = c_paths[cj];
      int32_t ki;
      if (!cp)
        continue;
      for (ki = 0; ki < nc; ki++) {
        uint8_t *nd = labi_icc_heap_f06_needle_at(ki);
        if (!nd)
          continue;
        if (link_abi_generated_c_contains_substr_use_line(cp, nd)) {
          need_heap = 1;
          break;
        }
      }
    }
  }
  if (!need_heap)
    return;
  if (has_c_paths) {
    for (cj = 0; cj < n; cj++) {
      if (link_abi_generated_c_provides_core_mem(c_paths[cj]))
        c_provides_core_mem = 1;
      if (link_abi_generated_c_provides_std_heap(c_paths[cj]))
        c_provides_std_heap = 1;
    }
  }
  if (!c_provides_core_mem) {
    uint8_t *mem_o = xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o());
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, mem_o);
  }
  if (!c_provides_std_heap) {
    uint8_t *heap_o = xlang_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o());
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, heap_o);
  }
  {
    uint8_t *pm_o = xlang_rel_o_path_from_argv0(include_root, labi_od_rel_page_mmap());
    if (invoke_cc_argv_push_existing(argv, ia, argv_cap, pm_o)) {
      (void)xlang_ensure_runtime_asm_io_stubs_o(NULL);
      {
        uint8_t *ris = xlang_runtime_asm_io_stubs_o_path(NULL);
        if (ris && ris[0])
          (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, ris);
      }
    }
  }
}

/* wave206: durable -O{level} slot (≡ .x g_labi_icc_oopt_buf). */
static uint8_t g_labi_icc_oopt_buf[8];

/* wave206: invoke_cc_append_argv_head_flags pure orch (surface pin ≡ .x). */
void invoke_cc_append_argv_head_flags(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    uint8_t *out_path, uint8_t *opt_level, int32_t use_lto, uint8_t *include_root) {
  const char *ol;
  int32_t is_linux;
  int32_t is_apple;
  int32_t skip_nat;
  int32_t is0, is2, is3;
  int k;
  if (!argv || !ia || *ia < 0)
    return;
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"cc");
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-std=gnu11");
  /* wave223 G.7: link_abi_getenv (not raw getenv). */
  if (link_abi_getenv((uint8_t *)"XLANG_RUN_QUIET")) {
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-w");
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-Wl,-w");
  }
  is_linux = xlang_host_is_linux();
  if (is_linux)
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-B/usr/bin");
  ol = (const char *)opt_level;
  if (!ol || !ol[0])
    ol = "2";
  g_labi_icc_oopt_buf[0] = (uint8_t)'-';
  g_labi_icc_oopt_buf[1] = (uint8_t)'O';
  for (k = 0; k < 5 && ol[k]; k++)
    g_labi_icc_oopt_buf[2 + k] = (uint8_t)ol[k];
  g_labi_icc_oopt_buf[2 + k] = 0;
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, g_labi_icc_oopt_buf);
  skip_nat = invoke_cc_skip_native_tuning();
  is2 = strcmp(ol, "2");
  is3 = strcmp(ol, "3");
  if (!skip_nat && (is2 == 0 || is3 == 0)) {
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-march=native");
    if (is3 == 0)
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-mtune=native");
  }
  is0 = strcmp(ol, "0");
  if (is0 != 0)
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-DNDEBUG");
  if (use_lto && is0 != 0 && !skip_nat)
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-flto");
  if (is_linux && is0 != 0)
    xlang_append_linux_link_harden_impl(argv, ia, argv_cap);
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-o");
  if (out_path && out_path[0])
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, out_path);
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-ffunction-sections");
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-fdata-sections");
  is_apple = link_abi_host_is_apple();
  if (is_apple)
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-Wl,-dead_strip");
  else if (is_linux)
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-Wl,--gc-sections");
  if (include_root && include_root[0]) {
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-I");
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, include_root);
  }
}

/* wave207: invoke_cc_append_argv_tail_flags pure orch (surface pin ≡ .x). */
void invoke_cc_append_argv_tail_flags(uint8_t **argv, int32_t *ia, int32_t argv_cap,
    uint8_t *thread_o, uint8_t *sync_o, uint8_t *channel_o) {
  int32_t is_linux;
  int32_t is_apple;
  int32_t is_win;
  int32_t need_pth;
  int32_t n_extra;
  int32_t ui;
  int32_t cur;
  uint8_t *ht;
  uint8_t *hs;
  uint8_t *hc;
  uint8_t *flc;
  uint8_t *p;
  if (!argv || !ia || *ia < 0)
    return;
  is_linux = xlang_host_is_linux();
  is_apple = link_abi_host_is_apple();
  is_win = link_abi_host_is_windows();
  if (is_linux || is_apple) {
    need_pth = 0;
    ht = asm_link_obj_skip_missing(thread_o);
    hs = asm_link_obj_skip_missing(sync_o);
    hc = asm_link_obj_skip_missing(channel_o);
    if (ht)
      need_pth = 1;
    if (hs)
      need_pth = 1;
    if (hc)
      need_pth = 1;
    if (need_pth)
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-pthread");
    flc = labi_ld_flag_lc();
    if (flc)
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc);
    else
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lc");
  }
  if (is_win)
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-Wl,--allow-multiple-definition");
  n_extra = link_abi_user_extra_o_count();
  for (ui = 0; ui < n_extra; ui++) {
    p = link_abi_user_extra_o_at(ui);
    if (p)
      (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
  }
  cur = *ia;
  if (cur < argv_cap) {
    argv[cur] = NULL;
    *ia = cur + 1;
  }
}

/* wave208: invoke_cc_append_minimal_cc_link_tail pure orch (surface pin ≡ .x). */
void invoke_cc_append_minimal_cc_link_tail(uint8_t **argv, int32_t *ia, int32_t argv_cap) {
  int32_t is_linux;
  int32_t is_apple;
  int32_t is_win;
  int32_t cur;
  uint8_t *rpav;
  uint8_t *flc;
  if (!argv || !ia || *ia < 0)
    return;
  is_linux = xlang_host_is_linux();
  is_apple = link_abi_host_is_apple();
  is_win = link_abi_host_is_windows();
  /* PLATFORM: WINDOWS — process_argv.o for xlang_process_argc/argv (extern not weak). */
  if (is_win) {
    rpav = xlang_runtime_process_argv_o_path(NULL);
    if (rpav && rpav[0])
      (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rpav);
  }
  /* PLATFORM: POSIX (linux|apple) — only -lc on minimal path. */
  if (is_linux || is_apple) {
    flc = labi_ld_flag_lc();
    if (flc)
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc);
    else
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lc");
  }
  /* NULL-terminate for spawn. */
  cur = *ia;
  if (cur < argv_cap) {
    argv[cur] = NULL;
    *ia = cur + 1;
  }
}

/* wave205: invoke_cc_run_cc_argv pure orch (surface pin ≡ .x). */
int32_t invoke_cc_run_cc_argv(uint8_t **argv) {
  int32_t is_win;
  int32_t is_linux;
  int32_t rc;
  if (!argv)
    return -1;
  (void)setenv("PATH", "/usr/local/bin:/usr/bin:/bin", 1);
  is_win = link_abi_host_is_windows();
  if (is_win) {
    argv[0] = (uint8_t *)"gcc";
    rc = xlang_spawn_sync((uint8_t *)"gcc", argv);
    if (rc == 0)
      return 0;
    link_diag_tool_status((uint8_t *)"cc", rc);
    return -1;
  }
  is_linux = xlang_host_is_linux();
  if (is_linux) {
    static const char *cands[6] = {
      "gcc", "cc", "/usr/bin/gcc", "/usr/bin/cc",
      "/usr/local/bin/gcc", "/usr/local/bin/cc"
    };
    int i;
    for (i = 0; i < 6; i++) {
      argv[0] = (uint8_t *)cands[i];
      rc = xlang_spawn_sync((uint8_t *)cands[i], argv);
      if (rc == 0)
        return 0;
    }
    link_diag_tool_status((uint8_t *)"cc", -1);
    return -1;
  }
  argv[0] = (uint8_t *)"cc";
  rc = xlang_spawn_sync((uint8_t *)"cc", argv);
  if (rc == 0)
    return 0;
  argv[0] = (uint8_t *)"gcc";
  rc = xlang_spawn_sync((uint8_t *)"gcc", argv);
  if (rc == 0)
    return 0;
  link_diag_tool_status((uint8_t *)"cc", -1);
  return -1;
}

/* wave205: invoke_cc_maybe_strip_out pure orch (surface pin ≡ .x). */
void invoke_cc_maybe_strip_out(uint8_t *out_path, uint8_t *opt_level) {
  if (!out_path || !out_path[0])
    return;
  if (!opt_level || !opt_level[0])
    return;
  if (strcmp((const char *)opt_level, "0") == 0)
    return;
  if (link_abi_host_is_windows())
    return;
  invoke_cc_strip_out_x(out_path);
}
