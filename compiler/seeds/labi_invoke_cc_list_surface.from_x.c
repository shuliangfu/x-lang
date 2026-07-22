/* seeds/labi_invoke_cc_list_surface.from_x.c
 * G-02f labi_invoke_cc_list R2 full surface — isomorphic with cold seed string tables
 *   + wave155 shux_append_linux_link_harden_impl pure orch
 *   + wave198 invoke_cc_append_early_needs pure orch + wave199 std need scan.
 *
 * 【Why 根源】旧 surface 由 .x STRING_LIT 生成 `(uint8_t[]){...}; return p`：
 *   C 块作用域 compound literal 为自动存储，return 后悬空。
 *   labi_linux_harden_flag_at 被 invoke_cc 写入 argv → gcc 收到乱码路径。
 * 【Invariant】全部返回 C 字符串字面量（rodata），与 labi_invoke_cc_list.from_x.c 冷路径一致。
 * Prove: full.x vs this seed → nm IDENTICAL (harden/skip-native/icc rel pure table
 *   + wave155 shux_append_linux_link_harden_impl pure orch
 *   + wave198 invoke_cc_append_early_needs pure orch + wave199 std need scan).
 * Cap residual (wave198): generated_c_needs_* + ensure/path/push peers + host_is_*.
 * PLATFORM: SHARED - symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
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
extern uint8_t * shux_rel_o_path_from_argv0(uint8_t * argv0, uint8_t * rel);
extern uint8_t * shux_runtime_kv_mmap_glue_o_path(uint8_t * argv0);
extern uint8_t * shux_runtime_arrow_simd_glue_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_random_fill_o(uint8_t * argv0);
extern uint8_t * shux_runtime_random_fill_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_time_os_o(uint8_t * argv0);
extern uint8_t * shux_runtime_time_os_o_path(uint8_t * argv0);
extern int32_t shux_ensure_runtime_panic_o(uint8_t * argv0);
extern uint8_t * shux_runtime_panic_o_path(uint8_t * argv0);
extern int32_t shux_host_is_linux(void);
extern int32_t link_abi_host_is_apple(void);
extern int32_t link_abi_host_is_windows(void);
extern uint8_t * labi_ld_flag_lc(void);
extern uint8_t * labi_ld_flag_lbcrypt(void);
extern uint8_t * labi_ld_flag_lws2_32(void);

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
    return (uint8_t *)"SHUX_CI_DOCKER";
  if (i == 2)
    return (uint8_t *)"SHUX_NO_MARCH_NATIVE";
  return NULL;
}

int32_t invoke_cc_skip_native_tuning(void) {
  int32_t n = labi_invoke_cc_skip_native_env_count();
  int32_t i;
  for (i = 0; i < n; i++) {
    uint8_t *name = labi_invoke_cc_skip_native_env_at(i);
    if (name && name[0] && getenv((const char *)name) != NULL)
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

/* wave155: shux_append_linux_link_harden_impl pure orch (surface pin; pure harden table). */
void shux_append_linux_link_harden_impl(uint8_t **argv, int32_t *la, int32_t cap) {
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
    uint8_t *abi_h = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_abi_h());
    if (abi_h && abi_h[0] && *ia < argv_cap - 2) {
      argv[(*ia)++] = (uint8_t *)"-include";
      argv[(*ia)++] = abi_h;
    }
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_o()));
  }
  if (needs_core_mem)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
  if (needs_core_slice)
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_slice_o()));
  if (needs_db_kv) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_kv_o()));
    {
      uint8_t *rkv = shux_runtime_kv_mmap_glue_o_path(NULL);
      if (rkv && rkv[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rkv);
    }
  }
  if (needs_db_arrow) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_arrow_o()));
    {
      uint8_t *rar = shux_runtime_arrow_simd_glue_o_path(NULL);
      if (rar && rar[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rar);
    }
  }
  if (needs_fs) {
    if (shux_host_is_linux() || link_abi_host_is_apple())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lc());
  }
  if (needs_random) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, random_o);
    (void)shux_ensure_runtime_random_fill_o(NULL);
    {
      uint8_t *rrf = shux_runtime_random_fill_o_path(NULL);
      if (rrf && rrf[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rrf);
    }
    if (link_abi_host_is_windows())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lbcrypt());
  }
  if (needs_time) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, time_o);
    (void)shux_ensure_runtime_time_os_o(NULL);
    {
      uint8_t *rto = shux_runtime_time_os_o_path(NULL);
      if (rto && rto[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rto);
    }
  }
  if (needs_runtime) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_o);
    (void)shux_ensure_runtime_panic_o(NULL);
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_panic_o);
    {
      uint8_t *rp = shux_runtime_panic_o_path(NULL);
      if (rp && rp[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rp);
    }
  }
  if (needs_win32 && link_abi_host_is_windows())
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, (uint8_t *)"-lkernel32");
  if (needs_win32_wsa && link_abi_host_is_windows())
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lws2_32());
  if (needs_libc_heap) {
    if (shux_host_is_linux() || link_abi_host_is_apple())
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
    if (i == 1) return (uint8_t *)"shux_process_spawn";
    if (i == 2) return (uint8_t *)"shux_process_wait";
    if (i == 3) return (uint8_t *)"process_spawn";
    if (i == 4) return (uint8_t *)"process_exec";
    return NULL;
  }
  if (mid == 1) {
    if (i == 0) return (uint8_t *)"process_shux_argc_get";
    if (i == 1) return (uint8_t *)"process_shux_argv_get";
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
    if (i == 1) return (uint8_t *)"shux_string_";
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
    if (i == 0) return (uint8_t *)"shux_panic_(";
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
        if (link_abi_generated_c_contains_substr_use_line(cp, (uint8_t *)"shux_panic_(")
            && !link_abi_generated_c_contains_substr(cp, (uint8_t *)"void shux_panic_(int has_msg, int msg_val) {")
            && !link_abi_generated_c_contains_substr(cp, (uint8_t *)"void shux_panic_(int has_msg, int msg_val){"))
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
