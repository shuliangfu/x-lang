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
#endif

int labi_invoke_cc_list_slice_marker(void) {
  return 1;
}
