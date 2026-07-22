/* seeds/labi_invoke_cc_list_surface.from_x.c
 * G-02f labi_invoke_cc_list R2 full surface — isomorphic with cold seed string tables
 *   + wave155 shux_append_linux_link_harden_impl pure orch
 *   + wave198 invoke_cc_append_early_needs pure orch.
 *
 * 【Why 根源】旧 surface 由 .x STRING_LIT 生成 `(uint8_t[]){...}; return p`：
 *   C 块作用域 compound literal 为自动存储，return 后悬空。
 *   labi_linux_harden_flag_at 被 invoke_cc 写入 argv → gcc 收到乱码路径。
 * 【Invariant】全部返回 C 字符串字面量（rodata），与 labi_invoke_cc_list.from_x.c 冷路径一致。
 * Prove: full.x vs this seed → nm IDENTICAL (harden/skip-native/icc rel pure table
 *   + wave155 shux_append_linux_link_harden_impl pure orch
 *   + wave198 invoke_cc_append_early_needs pure orch).
 * Cap residual (wave198): generated_c_needs_* + ensure/path/push peers + host_is_*.
 * PLATFORM: SHARED - symbol contract; Ubuntu gold + mac prove.
 */
#include <stdint.h>
#include <stddef.h>
#include <stdlib.h>
#include <sys/types.h>

/* Cap residual / peer pure (wave198 early needs orch surface). */
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
