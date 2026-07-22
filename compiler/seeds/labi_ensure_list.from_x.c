/* seeds/labi_ensure_list.from_x.c — G-02f-273 P2 link_abi L4 ensure list pure → R2 full
 * Logic source: src/runtime/labi_ensure_list.x
 * Hybrid: SHUX_LABI_ENSURE_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14）：公共业务符号由 full .x 提供：
 *   labi_ensure_catalog_count
 *   labi_ensure_catalog_{stem,out_base,seed_base,flags}
 *   labi_ensure_catalog_step_at
 *   + wave169 shux_ensure_runtime_panic_o pure orch
 * Cap residual：spawn/cc IO 仍在 mega link_abi_ensure_from_catalog；
 *   wave169 panic ensure：resolve/access/cc/stat + host linux_x86_64 / posix_aarch64。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_ensure_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>

#ifndef SHUX_LABI_ENSURE_LIST_FROM_X

/* Cap residual peers used by wave169 ensure_runtime_panic pure orch (cold twin). */
int shu_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz);
int link_abi_path_readable(const char *path);
int shux_cc_compile_sync(const char *src, const char *out_o, const char *inc0, const char *inc1,
                         const char *inc2, int from_asm_s);
const char *asm_link_obj_skip_missing(const char *path);
int link_abi_host_is_linux_x86_64(void);
int link_abi_host_is_posix_aarch64(void);
const char *shux_runtime_panic_o_path(const char *argv0);
void link_diag_runtime_obj_resolve_fail(const char *obj_name, const char *hint);
void link_diag_runtime_source_missing_under(const char *obj_name, const char *base_dir,
                                            const char *suffix);
void link_diag_runtime_obj_build_status(const char *obj_name, int status);
void link_diag_runtime_obj_missing(const char *obj_name, const char *out_o);

/* flags: 0=NONE, 1=PIE (-fPIE), 2=SQLITE (-DSHUX_DB_USE_SQLITE3) */

int labi_ensure_catalog_count(void) {
  return 26;
}

const char *labi_ensure_catalog_stem(int i) {
  if (i < 0)
    return NULL;

  if (i == 0)
    return "runtime_asm_io_stubs";
  if (i == 1)
    return "runtime_process_argv";
  if (i == 2)
    return "runtime_process_os_glue";
  if (i == 3)
    return "runtime_random_fill";
  if (i == 4)
    return "runtime_compress_zlib_glue";
  if (i == 5)
    return "runtime_time_os";
  if (i == 6)
    return "runtime_queue_contention";
  if (i == 7)
    return "runtime_dynlib_os";
  if (i == 8)
    return "runtime_env_os";
  if (i == 9)
    return "runtime_backtrace_platform";
  if (i == 10)
    return "runtime_log_os";
  if (i == 11)
    return "runtime_math_libm";
  if (i == 12)
    return "runtime_atomic_glue";
  if (i == 13)
    return "runtime_channel_glue";
  if (i == 14)
    return "runtime_net_udp_batch";
  if (i == 15)
    return "runtime_net_workers";
  if (i == 16)
    return "runtime_sync_os";
  if (i == 17)
    return "runtime_sync_lock_diag_tls";
  if (i == 18)
    return "runtime_thread_glue";
  if (i == 19)
    return "runtime_scheduler_glue";
  if (i == 20)
    return "runtime_http_glue";
  if (i == 21)
    return "runtime_kv_mmap_glue";
  if (i == 22)
    return "runtime_arrow_simd_glue";
  if (i == 23)
    return "runtime_sqlite_glue";
  if (i == 24)
    return "runtime_crypto_inc_glue";
  if (i == 25)
    return "runtime_ed25519_ref10_glue";
  return NULL;
}

const char *labi_ensure_catalog_out_base(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "runtime_asm_io_stubs.o";
  if (i == 1)
    return "runtime_process_argv.o";
  if (i == 2)
    return "runtime_process_os_glue.o";
  if (i == 3)
    return "runtime_random_fill.o";
  if (i == 4)
    return "runtime_compress_zlib_glue.o";
  if (i == 5)
    return "runtime_time_os.o";
  if (i == 6)
    return "runtime_queue_contention.o";
  if (i == 7)
    return "runtime_dynlib_os.o";
  if (i == 8)
    return "runtime_env_os.o";
  if (i == 9)
    return "runtime_backtrace_platform.o";
  if (i == 10)
    return "runtime_log_os.o";
  if (i == 11)
    return "runtime_math_libm.o";
  if (i == 12)
    return "runtime_atomic_glue.o";
  if (i == 13)
    return "runtime_channel_glue.o";
  if (i == 14)
    return "runtime_net_udp_batch.o";
  if (i == 15)
    return "runtime_net_workers.o";
  if (i == 16)
    return "runtime_sync_os.o";
  if (i == 17)
    return "runtime_sync_lock_diag_tls.o";
  if (i == 18)
    return "runtime_thread_glue.o";
  if (i == 19)
    return "runtime_scheduler_glue.o";
  if (i == 20)
    return "runtime_http_glue.o";
  if (i == 21)
    return "runtime_kv_mmap_glue.o";
  if (i == 22)
    return "runtime_arrow_simd_glue.o";
  if (i == 23)
    return "runtime_sqlite_glue.o";
  if (i == 24)
    return "runtime_crypto_inc_glue.o";
  if (i == 25)
    return "runtime_ed25519_ref10_glue.o";
  return NULL;
}

const char *labi_ensure_catalog_seed_base(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "runtime_asm_io_stubs.from_x.c";
  if (i == 1)
    return "runtime_process_argv.from_x.c";
  if (i == 2)
    return "runtime_process_os_glue.from_x.c";
  if (i == 3)
    return "runtime_random_fill.from_x.c";
  if (i == 4)
    return "runtime_compress_zlib_glue.from_x.c";
  if (i == 5)
    return "runtime_time_os.from_x.c";
  if (i == 6)
    return "runtime_queue_contention.from_x.c";
  if (i == 7)
    return "runtime_dynlib_os.from_x.c";
  if (i == 8)
    return "runtime_env_os.from_x.c";
  if (i == 9)
    return "runtime_backtrace_platform.from_x.c";
  if (i == 10)
    return "runtime_log_os.from_x.c";
  if (i == 11)
    return "runtime_math_libm.from_x.c";
  if (i == 12)
    return "runtime_atomic_glue.from_x.c";
  if (i == 13)
    return "runtime_channel_glue.from_x.c";
  if (i == 14)
    return "runtime_net_udp_batch.from_x.c";
  if (i == 15)
    return "runtime_net_workers.from_x.c";
  if (i == 16)
    return "runtime_sync_os.from_x.c";
  if (i == 17)
    return "runtime_sync_lock_diag_tls.from_x.c";
  if (i == 18)
    return "runtime_thread_glue.from_x.c";
  if (i == 19)
    return "runtime_scheduler_glue.from_x.c";
  if (i == 20)
    return "runtime_http_glue.from_x.c";
  if (i == 21)
    return "runtime_kv_mmap_glue.from_x.c";
  if (i == 22)
    return "runtime_arrow_simd_glue.from_x.c";
  if (i == 23)
    return "runtime_sqlite_glue.from_x.c";
  if (i == 24)
    return "runtime_crypto_inc_glue.from_x.c";
  if (i == 25)
    return "runtime_ed25519_ref10_glue.from_x.c";
  return NULL;
}

int labi_ensure_catalog_flags(int i) {
  if (i < 0)
    return 0;
  if (i == 0)
    return 1; /* LABI_ENS_FLAG_PIE */
  if (i == 20)
    return 3; /* LABI_ENS_HTTP_GLUE → LABI_ENS_FLAG_HTTP_SEEDS (-I seeds/http) */
  if (i == 23)
    return 2; /* LABI_ENS_FLAG_SQLITE */
  if (i >= 26)
    return 0;
  return 0;
}

int labi_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                const char **seed_base_out, int *flags_out,
                                const char **hint_out) {
  const char *s;
  if (i < 0 || i >= 26)
    return 0;
  s = labi_ensure_catalog_stem(i);
  if (!s)
    return 0;
  if (stem_out)
    *stem_out = s;
  if (out_base_out)
    *out_base_out = labi_ensure_catalog_out_base(i);
  if (seed_base_out)
    *seed_base_out = labi_ensure_catalog_seed_base(i);
  if (flags_out)
    *flags_out = labi_ensure_catalog_flags(i);
  if (hint_out) {
    if (i == 0)
      *hint_out = "try: make -C compiler runtime_asm_io_stubs.o";
    else if (i == 1)
      *hint_out = "try: make -C compiler runtime_process_argv.o";
    else
      *hint_out = NULL;
  }
  return 1;
}

/* wave169: ensure_runtime_panic_o pure orch (cold twin ≡ .x).
 * Peer panic_o_path; Cap residual resolve/access/cc/stat + host linux_x86_64 / posix_aarch64.
 * Pure byte join (no snprintf). PLATFORM: SHARED orch; LINUX x86_64 asm; POSIX aarch64 seed.
 */
int shux_ensure_runtime_panic_o(const char *argv0) {
  char comp[4096];
  char out_o[4096];
  char src_s[4096];
  char src_arm[4096];
  char src_c[4096];
  char inc0[4096];
  char inc1[4096];
  char inc2[4096];
  const char *o_path;
  const char *have;
  const char *src = NULL;
  const char *leaf_o = "runtime_panic.o";
  int dn, ln_o, i, k, rc, crc, from_asm_s = 0;
  o_path = shux_runtime_panic_o_path(argv0);
  have = asm_link_obj_skip_missing(o_path);
  if (have != NULL)
    return 0;
  rc = shu_resolve_compiler_dir(argv0, comp, sizeof comp);
  if (rc != 0) {
    link_diag_runtime_obj_resolve_fail("runtime_panic.o", "try: make -C compiler runtime_panic.o");
    return -1;
  }
  dn = 0;
  while (comp[dn] != 0)
    dn++;
  ln_o = 0;
  while (leaf_o[ln_o] != 0)
    ln_o++;
  if (dn + 1 + ln_o >= 4096)
    return -1;
  for (i = 0; i < dn; i++)
    out_o[i] = comp[i];
  out_o[dn] = '/';
  for (k = 0; k <= ln_o; k++)
    out_o[dn + 1 + k] = leaf_o[k];
  if (link_abi_host_is_linux_x86_64() != 0) {
    const char *leaf_s = "src/asm/runtime_panic_x86_64.s";
    int ln_s = 0;
    while (leaf_s[ln_s] != 0)
      ln_s++;
    if (dn + 1 + ln_s < 4096) {
      for (i = 0; i < dn; i++)
        src_s[i] = comp[i];
      src_s[dn] = '/';
      for (k = 0; k <= ln_s; k++)
        src_s[dn + 1 + k] = leaf_s[k];
      if (link_abi_path_readable(src_s) != 0) {
        src = src_s;
        from_asm_s = 1;
      }
    }
  }
  if (src == NULL && link_abi_host_is_posix_aarch64() != 0) {
    const char *leaf_a = "seeds/runtime_panic_arm64.from_x.c";
    int ln_a = 0;
    while (leaf_a[ln_a] != 0)
      ln_a++;
    if (dn + 1 + ln_a < 4096) {
      for (i = 0; i < dn; i++)
        src_arm[i] = comp[i];
      src_arm[dn] = '/';
      for (k = 0; k <= ln_a; k++)
        src_arm[dn + 1 + k] = leaf_a[k];
      if (link_abi_path_readable(src_arm) != 0)
        src = src_arm;
    }
  }
  if (src == NULL) {
    const char *leaf_c = "seeds/runtime_panic.from_x.c";
    int ln_c = 0;
    while (leaf_c[ln_c] != 0)
      ln_c++;
    if (dn + 1 + ln_c >= 4096)
      return -1;
    for (i = 0; i < dn; i++)
      src_c[i] = comp[i];
    src_c[dn] = '/';
    for (k = 0; k <= ln_c; k++)
      src_c[dn + 1 + k] = leaf_c[k];
    if (link_abi_path_readable(src_c) == 0) {
      link_diag_runtime_source_missing_under("runtime_panic", comp, "/seeds/");
      return -1;
    }
    src = src_c;
  }
  for (i = 0; i <= dn; i++)
    inc0[i] = comp[i];
  {
    const char *leaf_inc = "include";
    int ln_inc = 0;
    while (leaf_inc[ln_inc] != 0)
      ln_inc++;
    if (dn + 1 + ln_inc >= 4096)
      return -1;
    for (i = 0; i < dn; i++)
      inc1[i] = comp[i];
    inc1[dn] = '/';
    for (k = 0; k <= ln_inc; k++)
      inc1[dn + 1 + k] = leaf_inc[k];
  }
  {
    const char *leaf_src = "src";
    int ln_src = 0;
    while (leaf_src[ln_src] != 0)
      ln_src++;
    if (dn + 1 + ln_src >= 4096)
      return -1;
    for (i = 0; i < dn; i++)
      inc2[i] = comp[i];
    inc2[dn] = '/';
    for (k = 0; k <= ln_src; k++)
      inc2[dn + 1 + k] = leaf_src[k];
  }
  crc = shux_cc_compile_sync(src, out_o, inc0, inc1, inc2, from_asm_s);
  if (crc != 0) {
    link_diag_runtime_obj_build_status("runtime_panic.o", crc);
    return -1;
  }
  o_path = shux_runtime_panic_o_path(argv0);
  have = asm_link_obj_skip_missing(o_path);
  if (have == NULL) {
    link_diag_runtime_obj_missing("runtime_panic.o", out_o);
    return -1;
  }
  return 0;
}

#else
int labi_ensure_catalog_count(void);
const char *labi_ensure_catalog_stem(int i);
const char *labi_ensure_catalog_out_base(int i);
const char *labi_ensure_catalog_seed_base(int i);
int labi_ensure_catalog_flags(int i);
int labi_ensure_catalog_step_at(int i, const char **stem_out, const char **out_base_out,
                                const char **seed_base_out, int *flags_out,
                                const char **hint_out);
/* wave169: ensure_runtime_panic_o pure orch (L4). */
int shux_ensure_runtime_panic_o(const char *argv0);
#endif

int labi_ensure_list_slice_marker(void) {
  return 1;
}