/* seeds/labi_invoke_cc_list.from_x.c — G-02f-274/L P2 link_abi L5 invoke_cc list pure → R2 full
 * Logic source: src/runtime/labi_invoke_cc_list.x
 * Hybrid: SHUX_LABI_INVOKE_CC_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full：公共业务符号由 full .x 提供：
 *   labi_linux_harden_flag_{count,at}
 *   labi_invoke_cc_skip_native_env_{count,at} + invoke_cc_skip_native_tuning
 *   labi_icc_rel_* (12) + labi_icc_needs_rel_{count,at}
 *   shux_append_linux_link_harden_impl (wave155 pure orch over harden table)
 *   invoke_cc_append_early_needs (wave198 pure orch early needs scan+push)
 *   invoke_cc_scan_std_module_needs (wave199 pure table scan std need flags)
 * Cap residual：getenv 🔒；host_is_*；needs/ensure/path/push peers；
 *   fork/exec 仍在 mega shux_invoke_cc_impl（大叶其余）。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_invoke_cc_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>
#include <stdlib.h>

#ifndef SHUX_LABI_INVOKE_CC_LIST_FROM_X

/* Peer pure / Cap residual for wave198 early needs (provided by other labi_* / mega). */
int link_abi_generated_c_needs_core_builtin(const char *c_path);
int link_abi_generated_c_needs_core_mem(const char *c_path);
int link_abi_generated_c_needs_core_slice(const char *c_path);
int link_abi_generated_c_needs_db_kv(const char *c_path);
int link_abi_generated_c_needs_db_arrow(const char *c_path);
int link_abi_generated_c_needs_fs(const char *c_path);
int link_abi_generated_c_needs_random(const char *c_path);
int link_abi_generated_c_needs_time(const char *c_path);
int link_abi_generated_c_needs_runtime(const char *c_path);
int link_abi_generated_c_needs_win32(const char *c_path);
int link_abi_generated_c_needs_win32_wsa(const char *c_path);
int link_abi_generated_c_needs_libc_heap(const char *c_path);
int invoke_cc_argv_push_existing(char **argv, int *ia, int max_ia, const char *path);
const char *shux_rel_o_path_from_argv0(const char *argv0, const char *rel);
const char *shux_runtime_kv_mmap_glue_o_path(const char *argv0);
const char *shux_runtime_arrow_simd_glue_o_path(const char *argv0);
int shux_ensure_runtime_random_fill_o(const char *argv0);
const char *shux_runtime_random_fill_o_path(const char *argv0);
int shux_ensure_runtime_time_os_o(const char *argv0);
const char *shux_runtime_time_os_o_path(const char *argv0);
int shux_ensure_runtime_panic_o(const char *argv0);
const char *shux_runtime_panic_o_path(const char *argv0);
int shux_host_is_linux(void);
int link_abi_host_is_apple(void);
int link_abi_host_is_windows(void);
const char *labi_ld_flag_lc(void);
const char *labi_ld_flag_lbcrypt(void);
const char *labi_ld_flag_lws2_32(void);

int labi_linux_harden_flag_count(void) {
  return 5;
}

const char *labi_linux_harden_flag_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-pie";
  if (i == 1)
    return "-fpie";
  if (i == 2)
    return "-Wl,-z,noexecstack";
  if (i == 3)
    return "-Wl,-z,relro";
  if (i == 4)
    return "-Wl,--allow-multiple-definition";
  return NULL;
}

int labi_invoke_cc_skip_native_env_count(void) {
  return 3;
}

const char *labi_invoke_cc_skip_native_env_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "CI";
  if (i == 1)
    return "SHUX_CI_DOCKER";
  if (i == 2)
    return "SHUX_NO_MARCH_NATIVE";
  return NULL;
}

int invoke_cc_skip_native_tuning(void) {
  int n = labi_invoke_cc_skip_native_env_count();
  int i;
  for (i = 0; i < n; i++) {
    const char *name = labi_invoke_cc_skip_native_env_at(i);
    if (name && name[0] && getenv(name) != NULL)
      return 1;
  }
  return 0;
}

const char *labi_icc_rel_core_builtin_o(void) { return "core/builtin/builtin.o"; }
const char *labi_icc_rel_core_builtin_abi_h(void) { return "core/builtin/builtin_abi.h"; }
const char *labi_icc_rel_core_mem_o(void) { return "core/mem/mem.o"; }
const char *labi_icc_rel_core_slice_o(void) { return "core/slice/slice.o"; }
const char *labi_icc_rel_db_kv_o(void) { return "std/db/kv/kv.o"; }
const char *labi_icc_rel_db_arrow_o(void) { return "std/db/arrow/arrow.o"; }
const char *labi_icc_rel_csv_o(void) { return "std/csv/csv.o"; }
const char *labi_icc_rel_error_o(void) { return "std/error/error.o"; }
const char *labi_icc_rel_heap_o(void) { return "std/heap/heap.o"; }
const char *labi_icc_rel_json_o(void) { return "std/json/json.o"; }
const char *labi_icc_rel_log_o(void) { return "std/log/log.o"; }
const char *labi_icc_rel_socketio_o(void) { return "std/socketio/socketio.o"; }

int labi_icc_needs_rel_count(void) {
  return 12;
}

const char *labi_icc_needs_rel_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "core/builtin/builtin.o";
  if (i == 1)
    return "core/builtin/builtin_abi.h";
  if (i == 2)
    return "core/mem/mem.o";
  if (i == 3)
    return "core/slice/slice.o";
  if (i == 4)
    return "std/db/kv/kv.o";
  if (i == 5)
    return "std/db/arrow/arrow.o";
  if (i == 6)
    return "std/csv/csv.o";
  if (i == 7)
    return "std/error/error.o";
  if (i == 8)
    return "std/heap/heap.o";
  if (i == 9)
    return "std/json/json.o";
  if (i == 10)
    return "std/log/log.o";
  if (i == 11)
    return "std/socketio/socketio.o";
  return NULL;
}

/* wave155: shux_append_linux_link_harden_impl pure orch (cold twin ≡ .x). */
void shux_append_linux_link_harden_impl(char *argv[], int *la, int cap) {
  int n;
  int k;
  if (!argv || !la || *la < 0)
    return;
  n = labi_linux_harden_flag_count();
  for (k = 0; k < n; k++) {
    const char *f = labi_linux_harden_flag_at(k);
    if (!f || !f[0])
      continue;
    if (*la < cap - 1)
      argv[(*la)++] = (char *)f;
  }
}

/* wave198: labi_icc_argv_try_push_flag + invoke_cc_append_early_needs pure orch (cold twin ≡ .x). */
void labi_icc_argv_try_push_flag(char **argv, int *ia, int cap, const char *flag) {
  if (!argv || !ia || *ia < 0 || !flag || !flag[0])
    return;
  if (*ia < cap - 1)
    argv[(*ia)++] = (char *)flag;
}

void invoke_cc_append_early_needs(char **argv, int *ia, int argv_cap,
    const char **c_paths, int n, const char *include_root,
    const char *random_o, const char *time_o, const char *runtime_o, const char *runtime_panic_o) {
  int needs_core_builtin = 0, needs_core_mem = 0, needs_core_slice = 0;
  int needs_db_kv = 0, needs_db_arrow = 0, needs_fs = 0;
  int needs_random = 0, needs_time = 0, needs_runtime = 0;
  int needs_win32 = 0, needs_win32_wsa = 0, needs_libc_heap = 0;
  int j;
  if (!argv || !ia || *ia < 0)
    return;
  if (c_paths && n > 0) {
    for (j = 0; j < n; j++) {
      const char *cp = c_paths[j];
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
    const char *abi_h = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_abi_h());
    if (abi_h && abi_h[0] && *ia < argv_cap - 2) {
      argv[(*ia)++] = (char *)"-include";
      argv[(*ia)++] = (char *)abi_h;
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
      const char *rkv = shux_runtime_kv_mmap_glue_o_path(NULL);
      if (rkv && rkv[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rkv);
    }
  }
  if (needs_db_arrow) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap,
        shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_arrow_o()));
    {
      const char *rar = shux_runtime_arrow_simd_glue_o_path(NULL);
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
      const char *rrf = shux_runtime_random_fill_o_path(NULL);
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
      const char *rto = shux_runtime_time_os_o_path(NULL);
      if (rto && rto[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rto);
    }
  }
  if (needs_runtime) {
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_o);
    (void)shux_ensure_runtime_panic_o(NULL);
    (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_panic_o);
    {
      const char *rp = shux_runtime_panic_o_path(NULL);
      if (rp && rp[0])
        (void)invoke_cc_argv_push_existing(argv, ia, argv_cap, rp);
    }
  }
  if (needs_win32 && link_abi_host_is_windows())
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-lkernel32");
  if (needs_win32_wsa && link_abi_host_is_windows())
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lws2_32());
  if (needs_libc_heap) {
    if (shux_host_is_linux() || link_abi_host_is_apple())
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, labi_ld_flag_lc());
  }
}

/* wave199: labi_icc_std_need_* tables + invoke_cc_scan_std_module_needs pure orch (cold twin ≡ .x). */
int labi_icc_std_need_count(void) { return 52; }

int labi_icc_std_need_needle_count(int mid) {

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

const char *labi_icc_std_need_needle_at(int mid, int i) {
  if (i < 0) return NULL;

  if (mid == 0) {
    if (i == 0) return "std_process_";
    if (i == 1) return "shux_process_spawn";
    if (i == 2) return "shux_process_wait";
    if (i == 3) return "process_spawn";
    if (i == 4) return "process_exec";
    return NULL;
  }
  if (mid == 1) {
    if (i == 0) return "process_shux_argc_get";
    if (i == 1) return "process_shux_argv_get";
    if (i == 2) return "process_args_count_c";
    if (i == 3) return "process_arg_c";
    if (i == 4) return "args_iter_count_c";
    if (i == 5) return "args_iter_at_c";
    if (i == 6) return "std_process_args";
    if (i == 7) return "std_env_args_iter";
    return NULL;
  }
  if (mid == 2) {
    if (i == 0) return "std_string_";
    if (i == 1) return "shux_string_";
    return NULL;
  }
  if (mid == 3) {
    if (i == 0) return "std_path_";
    if (i == 1) return "path_join";
    if (i == 2) return "path_dirname";
    return NULL;
  }
  if (mid == 4) {
    if (i == 0) return "std_runtime_";
    return NULL;
  }
  if (mid == 5) {
    if (i == 0) return "std_net_listen";
    if (i == 1) return "std_net_connect";
    if (i == 2) return "std_net_udp_bind";
    if (i == 3) return "std_net_udp_recv";
    if (i == 4) return "std_net_udp_send";
    if (i == 5) return "std_net_addr_to_u32";
    if (i == 6) return "std_net_close_udp";
    if (i == 7) return "net_tcp_connect_c";
    if (i == 8) return "net_tcp_listen_c";
    if (i == 9) return "net_udp_bind_c";
    if (i == 10) return "net_udp_recv_many_buf_c";
    if (i == 11) return "net_udp_send_many_buf_c";
    if (i == 12) return "net_udp_send_c";
    if (i == 13) return "net_dns_resolve_c";
    if (i == 14) return "net_sock_create_c";
    if (i == 15) return "net_stream_write_batch_c";
    if (i == 16) return "net_close_socket_c_real";
    if (i == 17) return "net_run_accept_workers_c_real";
    return NULL;
  }
  if (mid == 6) {
    if (i == 0) return "std_thread_";
    if (i == 1) return "thread_create_c";
    if (i == 2) return "thread_join_c";
    return NULL;
  }
  if (mid == 7) {
    if (i == 0) return "std_time_";
    if (i == 1) return "time_now_";
    if (i == 2) return "time_sleep_";
    return NULL;
  }
  if (mid == 8) {
    if (i == 0) return "std_random_";
    if (i == 1) return "random_fill_";
    return NULL;
  }
  if (mid == 9) {
    if (i == 0) return "std_env_";
    if (i == 1) return "env_get_";
    if (i == 2) return "env_set_";
    return NULL;
  }
  if (mid == 10) {
    if (i == 0) return "std_sync_";
    if (i == 1) return "sync_mutex_";
    if (i == 2) return "sync_rwlock_";
    return NULL;
  }
  if (mid == 11) {
    if (i == 0) return "std_encoding_";
    return NULL;
  }
  if (mid == 12) {
    if (i == 0) return "std_base64_";
    if (i == 1) return "base64_encode";
    if (i == 2) return "base64_decode";
    return NULL;
  }
  if (mid == 13) {
    if (i == 0) return "std_crypto_";
    if (i == 1) return "core_crypto_mem_eq";
    if (i == 2) return "core_crypto_sha";
    if (i == 3) return "crypto_sha";
    if (i == 4) return "ed25519_";
    return NULL;
  }
  if (mid == 14) {
    if (i == 0) return "std_log_";
    if (i == 1) return "log_write_c";
    if (i == 2) return "log_info_";
    return NULL;
  }
  if (mid == 15) {
    if (i == 0) return "std_atomic_";
    if (i == 1) return "atomic_load_i32_c";
    if (i == 2) return "atomic_store_i32_c";
    if (i == 3) return "atomic_fetch_";
    return NULL;
  }
  if (mid == 16) {
    if (i == 0) return "std_channel_";
    if (i == 1) return "channel_send";
    if (i == 2) return "channel_recv";
    return NULL;
  }
  if (mid == 17) {
    if (i == 0) return "std_backtrace_";
    if (i == 1) return "backtrace_capture";
    return NULL;
  }
  if (mid == 18) {
    if (i == 0) return "std_hash_";
    if (i == 1) return "hash_fnv";
    if (i == 2) return "hash_sip";
    return NULL;
  }
  if (mid == 19) {
    if (i == 0) return "std_math_";
    if (i == 1) return "math_sin";
    if (i == 2) return "math_cos";
    return NULL;
  }
  if (mid == 20) {
    if (i == 0) return "std_sort_";
    if (i == 1) return "sort_i32";
    if (i == 2) return "sort_stable";
    return NULL;
  }
  if (mid == 21) {
    if (i == 0) return "std_vec_new";
    if (i == 1) return "std_vec_push";
    if (i == 2) return "std_vec_len_Vec";
    if (i == 3) return "std_vec_len_ptr";
    if (i == 4) return "std_vec_with_capacity";
    if (i == 5) return "std_vec_from_slice";
    if (i == 6) return "std_vec_append";
    if (i == 7) return "std_vec_reserve";
    if (i == 8) return "std_vec_clear";
    if (i == 9) return "std_vec_free";
    return NULL;
  }
  if (mid == 22) {
    if (i == 0) return "std_ffi_";
    if (i == 1) return "ffi_call";
    return NULL;
  }
  if (mid == 23) {
    if (i == 0) return "std_db_";
    if (i == 1) return "sqlite3_";
    if (i == 2) return "db_sqlite_";
    return NULL;
  }
  if (mid == 24) {
    if (i == 0) return "std_elf_";
    if (i == 1) return "elf_parse";
    return NULL;
  }
  if (mid == 25) {
    if (i == 0) return "std_json_";
    if (i == 1) return "json_parse_";
    return NULL;
  }
  if (mid == 26) {
    if (i == 0) return "std_csv_";
    if (i == 1) return "csv_next_field";
    return NULL;
  }
  if (mid == 27) {
    if (i == 0) return "std_regex_";
    if (i == 1) return "regex_match";
    return NULL;
  }
  if (mid == 28) {
    if (i == 0) return "std_compress_";
    if (i == 1) return "compress_gzip";
    if (i == 2) return "compress_zstd";
    if (i == 3) return "compress_brotli";
    return NULL;
  }
  if (mid == 29) {
    if (i == 0) return "std_unicode_";
    if (i == 1) return "unicode_utf8";
    return NULL;
  }
  if (mid == 30) {
    if (i == 0) return "std_dynlib_";
    if (i == 1) return "dynlib_open";
    return NULL;
  }
  if (mid == 31) {
    if (i == 0) return "std_http_";
    if (i == 1) return "http_request";
    if (i == 2) return "http2_";
    return NULL;
  }
  if (mid == 32) {
    if (i == 0) return "std_tar_";
    if (i == 1) return "tar_open";
    if (i == 2) return "tar_extract";
    return NULL;
  }
  if (mid == 33) {
    if (i == 0) return "std_simd_";
    return NULL;
  }
  if (mid == 34) {
    if (i == 0) return "std_context_background(";
    if (i == 1) return "std_context_with_cancel(";
    if (i == 2) return "std_context_with_deadline(";
    if (i == 3) return "std_context_with_timeout(";
    if (i == 4) return "std_context_cancel(";
    if (i == 5) return "std_context_set_value(";
    if (i == 6) return "std_context_get_value(";
    if (i == 7) return "std_context_free(";
    return NULL;
  }
  if (mid == 35) {
    if (i == 0) return "std_error_";
    if (i == 1) return "error_wrap_";
    return NULL;
  }
  if (mid == 36) {
    if (i == 0) return "std_datetime_";
    return NULL;
  }
  if (mid == 37) {
    if (i == 0) return "std_uuid_";
    if (i == 1) return "uuid_v4";
    if (i == 2) return "uuid_parse";
    return NULL;
  }
  if (mid == 38) {
    if (i == 0) return "std_url_";
    if (i == 1) return "url_parse";
    if (i == 2) return "url_join";
    return NULL;
  }
  if (mid == 39) {
    if (i == 0) return "std_cli_";
    if (i == 1) return "cli_parse";
    return NULL;
  }
  if (mid == 40) {
    if (i == 0) return "std_security_";
    return NULL;
  }
  if (mid == 41) {
    if (i == 0) return "std_config_";
    return NULL;
  }
  if (mid == 42) {
    if (i == 0) return "std_cache_";
    return NULL;
  }
  if (mid == 43) {
    if (i == 0) return "std_trace_";
    return NULL;
  }
  if (mid == 44) {
    if (i == 0) return "std_task_";
    return NULL;
  }
  if (mid == 45) {
    if (i == 0) return "std_schema_";
    return NULL;
  }
  if (mid == 46) {
    if (i == 0) return "std_test_";
    if (i == 1) return "test_call_";
    return NULL;
  }
  if (mid == 47) {
    if (i == 0) return "std_socketio_";
    if (i == 1) return "socketio_emit";
    if (i == 2) return "socketio_on";
    return NULL;
  }
  if (mid == 48) {
    if (i == 0) return "std_set_";
    return NULL;
  }
  if (mid == 49) {
    if (i == 0) return "std_map_";
    return NULL;
  }
  if (mid == 50) {
    if (i == 0) return "std_queue_";
    return NULL;
  }
  if (mid == 51) {
    if (i == 0) return "shux_panic_(";
    return NULL;
  }
  return NULL;
}


void invoke_cc_scan_std_module_needs(const char **c_paths, int n, int *flags, int flags_cap) {
  int k, j, mid, ni, nc;
  const char *cp;
  const char *nd;
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
        if (link_abi_generated_c_contains_substr_use_line(cp, "shux_panic_(")
            && !link_abi_generated_c_contains_substr(cp, "void shux_panic_(int has_msg, int msg_val) {")
            && !link_abi_generated_c_contains_substr(cp, "void shux_panic_(int has_msg, int msg_val){"))
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


#else
int labi_linux_harden_flag_count(void);
const char *labi_linux_harden_flag_at(int i);
int labi_invoke_cc_skip_native_env_count(void);
const char *labi_invoke_cc_skip_native_env_at(int i);
int invoke_cc_skip_native_tuning(void);
const char *labi_icc_rel_core_builtin_o(void);
const char *labi_icc_rel_core_builtin_abi_h(void);
const char *labi_icc_rel_core_mem_o(void);
const char *labi_icc_rel_core_slice_o(void);
const char *labi_icc_rel_db_kv_o(void);
const char *labi_icc_rel_db_arrow_o(void);
const char *labi_icc_rel_csv_o(void);
const char *labi_icc_rel_error_o(void);
const char *labi_icc_rel_heap_o(void);
const char *labi_icc_rel_json_o(void);
const char *labi_icc_rel_log_o(void);
const char *labi_icc_rel_socketio_o(void);
int labi_icc_needs_rel_count(void);
const char *labi_icc_needs_rel_at(int i);
void shux_append_linux_link_harden_impl(char *argv[], int *la, int cap);
void labi_icc_argv_try_push_flag(char **argv, int *ia, int cap, const char *flag);
void invoke_cc_append_early_needs(char **argv, int *ia, int argv_cap,
    const char **c_paths, int n, const char *include_root,
    const char *random_o, const char *time_o, const char *runtime_o, const char *runtime_panic_o);
int labi_icc_std_need_count(void);
int labi_icc_std_need_needle_count(int mid);
const char *labi_icc_std_need_needle_at(int mid, int i);
void invoke_cc_scan_std_module_needs(const char **c_paths, int n, int *flags, int flags_cap);
#endif

int labi_invoke_cc_list_slice_marker(void) {
  return 1;
}
