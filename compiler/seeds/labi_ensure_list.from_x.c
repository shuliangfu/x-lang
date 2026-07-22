/* seeds/labi_ensure_list.from_x.c — G-02f-273 P2 link_abi L4 ensure list pure → R2 full
 * Logic source: src/runtime/labi_ensure_list.x
 * Hybrid: SHUX_LABI_ENSURE_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full（2026-07-14）：公共业务符号由 full .x 提供：
 *   labi_ensure_catalog_count
 *   labi_ensure_catalog_{stem,out_base,seed_base,flags}
 *   labi_ensure_catalog_step_at
 *   + wave173 link_abi_ensure_from_catalog pure orch
 *   + wave174 catalog thin ensure wraps pure (26× shux_ensure_runtime_*_o)
 *   + wave169 shux_ensure_runtime_panic_o pure orch
 *   + wave170 shux_ensure_runtime_heap_user_o pure orch
 *   + wave171 shux_ensure_runtime_test_fn_invoke_o pure orch
 *   + wave172 shux_ensure_runtime_tls_mbedtls_bio_o pure orch
 * Cap residual：resolve/access/cc/stat (+ one_extra for catalog PIE/SQLITE/HTTP -I pack)；
 *   wave169 panic ensure：resolve/access/cc/stat + host linux_x86_64 / posix_aarch64；
 *   wave170 heap_user ensure：resolve/access/cc/stat + has_defined_sym + unlink stub；
 *   wave171 test_fn_invoke ensure：resolve/access/cc/stat（direct seed；无 wrap.c）；
 *   wave172 tls_mbedtls_bio ensure：resolve/access/cc_one_extra/stat（homebrew -I）；
 *   wave174 catalog thin wraps：peer *_o_path Cap residual only。
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_ensure_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>

#ifndef SHUX_LABI_ENSURE_LIST_FROM_X

/* Cap residual peers used by wave173 catalog ensure + wave169/170/171/172 special ensure pure orch (cold twin). */
int shu_resolve_compiler_dir(const char *argv0, char *out_dir, size_t out_dir_sz);
int link_abi_path_readable(const char *path);
int shux_cc_compile_sync(const char *src, const char *out_o, const char *inc0, const char *inc1,
                         const char *inc2, int from_asm_s);
int shux_cc_compile_sync_one_extra(const char *src, const char *out_o, const char *inc0,
                                   const char *inc1, const char *inc2, int from_asm_s,
                                   const char *extra0);
const char *asm_link_obj_skip_missing(const char *path);
int link_abi_host_is_linux_x86_64(void);
int link_abi_host_is_posix_aarch64(void);
int shux_link_obj_has_defined_sym(const char *o_path, const char *sym);
int unlink(const char *path);
const char *shux_runtime_panic_o_path(const char *argv0);
const char *shux_runtime_heap_user_o_path(const char *argv0);
const char *shux_runtime_test_fn_invoke_o_path(const char *argv0);
const char *shux_runtime_tls_mbedtls_bio_o_path(const char *argv0);
/* Cap residual path peers for wave174 catalog thin ensure wraps. */
const char *shux_runtime_asm_io_stubs_o_path(const char *argv0);
const char *shux_runtime_process_argv_o_path(const char *argv0);
const char *shux_runtime_process_os_glue_o_path(const char *argv0);
const char *shux_runtime_random_fill_o_path(const char *argv0);
const char *shux_runtime_compress_zlib_glue_o_path(const char *argv0);
const char *shux_runtime_time_os_o_path(const char *argv0);
const char *shux_runtime_queue_contention_o_path(const char *argv0);
const char *shux_runtime_dynlib_os_o_path(const char *argv0);
const char *shux_runtime_env_os_o_path(const char *argv0);
const char *shux_runtime_backtrace_platform_o_path(const char *argv0);
const char *shux_runtime_log_os_o_path(const char *argv0);
const char *shux_runtime_math_libm_o_path(const char *argv0);
const char *shux_runtime_atomic_glue_o_path(const char *argv0);
const char *shux_runtime_channel_glue_o_path(const char *argv0);
const char *shux_runtime_net_udp_batch_o_path(const char *argv0);
const char *shux_runtime_net_workers_o_path(const char *argv0);
const char *shux_runtime_sync_os_o_path(const char *argv0);
const char *shux_runtime_sync_lock_diag_tls_o_path(const char *argv0);
const char *shux_runtime_thread_glue_o_path(const char *argv0);
const char *shux_runtime_scheduler_glue_o_path(const char *argv0);
const char *shux_runtime_http_glue_o_path(const char *argv0);
const char *shux_runtime_kv_mmap_glue_o_path(const char *argv0);
const char *shux_runtime_arrow_simd_glue_o_path(const char *argv0);
const char *shux_runtime_sqlite_glue_o_path(const char *argv0);
const char *shux_runtime_crypto_inc_glue_o_path(const char *argv0);
const char *shux_runtime_ed25519_ref10_glue_o_path(const char *argv0);
void link_diag_runtime_obj_resolve_fail(const char *obj_name, const char *hint);
void link_diag_runtime_source_missing(const char *obj_name, const char *source_path);
void link_diag_runtime_source_missing_under(const char *obj_name, const char *base_dir,
                                            const char *suffix);
void link_diag_runtime_obj_build_status(const char *obj_name, int status);
void link_diag_runtime_obj_missing(const char *obj_name, const char *out_o);

/* flags: 0=NONE, 1=PIE (-fPIE), 2=SQLITE (-DSHUX_DB_USE_SQLITE3), 3=HTTP_SEEDS */

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

/* wave173: link_abi_ensure_from_catalog pure orch (cold twin ≡ .x).
 * Catalog tables + pure byte joins; Cap residual resolve/access/cc/one_extra/stat.
 * product_path from thin mega wrap (peer *_o_path); no path_fn in pure.
 * Flags: 0 NONE, 1 PIE, 2 SQLITE, 3 HTTP pack -I{comp}/seeds/http.
 * PLATFORM: SHARED orch.
 */
int link_abi_ensure_from_catalog(const char *argv0, int catalog_idx, const char *product_path) {
  char comp[4096];
  char out_o[4096];
  char src_c[4096];
  char inc0[4096], inc1[4096], inc2[4096];
  const char *stem;
  const char *out_base;
  const char *seed_base;
  const char *have;
  int flags;
  int dn;
  int ln_o, ln_pfx, ln_seed, ln_inc, ln_src;
  int i, k, off;
  int rc, crc;
  const char *seeds_pfx = "seeds/";
  const char *leaf_inc = "include";
  const char *leaf_src = "src";

  if (product_path == NULL)
    return -1;
  stem = labi_ensure_catalog_stem(catalog_idx);
  out_base = labi_ensure_catalog_out_base(catalog_idx);
  seed_base = labi_ensure_catalog_seed_base(catalog_idx);
  if (stem == NULL || out_base == NULL || seed_base == NULL)
    return -1;
  flags = labi_ensure_catalog_flags(catalog_idx);
  have = asm_link_obj_skip_missing(product_path);
  if (have != NULL)
    return 0;
  rc = shu_resolve_compiler_dir(argv0, comp, sizeof comp);
  if (rc != 0) {
    const char *hint = NULL;
    if (catalog_idx == 0)
      hint = "try: make -C compiler runtime_asm_io_stubs.o";
    else if (catalog_idx == 1)
      hint = "try: make -C compiler runtime_process_argv.o";
    link_diag_runtime_obj_resolve_fail(out_base, hint);
    return -1;
  }
  dn = 0;
  while (comp[dn] != 0)
    dn++;
  ln_o = 0;
  while (out_base[ln_o] != 0)
    ln_o++;
  if (dn + 1 + ln_o >= 4096)
    return -1;
  for (i = 0; i < dn; i++)
    out_o[i] = comp[i];
  out_o[dn] = '/';
  for (k = 0; k <= ln_o; k++)
    out_o[dn + 1 + k] = out_base[k];
  ln_pfx = 0;
  while (seeds_pfx[ln_pfx] != 0)
    ln_pfx++;
  ln_seed = 0;
  while (seed_base[ln_seed] != 0)
    ln_seed++;
  if (dn + 1 + ln_pfx + ln_seed >= 4096)
    return -1;
  for (i = 0; i < dn; i++)
    src_c[i] = comp[i];
  src_c[dn] = '/';
  for (k = 0; k < ln_pfx; k++)
    src_c[dn + 1 + k] = seeds_pfx[k];
  off = dn + 1 + ln_pfx;
  for (k = 0; k <= ln_seed; k++)
    src_c[off + k] = seed_base[k];
  if (link_abi_path_readable(src_c) == 0) {
    link_diag_runtime_source_missing(stem, src_c);
    return -1;
  }
  for (i = 0; i <= dn; i++)
    inc0[i] = comp[i];
  ln_inc = 0;
  while (leaf_inc[ln_inc] != 0)
    ln_inc++;
  if (dn + 1 + ln_inc >= 4096)
    return -1;
  for (i = 0; i < dn; i++)
    inc1[i] = comp[i];
  inc1[dn] = '/';
  for (k = 0; k <= ln_inc; k++)
    inc1[dn + 1 + k] = leaf_inc[k];
  ln_src = 0;
  while (leaf_src[ln_src] != 0)
    ln_src++;
  if (dn + 1 + ln_src >= 4096)
    return -1;
  for (i = 0; i < dn; i++)
    inc2[i] = comp[i];
  inc2[dn] = '/';
  for (k = 0; k <= ln_src; k++)
    inc2[dn + 1 + k] = leaf_src[k];
  if (flags == 1) {
    crc = shux_cc_compile_sync_one_extra(src_c, out_o, inc0, inc1, inc2, 0, "-fPIE");
  } else if (flags == 2) {
    crc = shux_cc_compile_sync_one_extra(src_c, out_o, inc0, inc1, inc2, 0, "-DSHUX_DB_USE_SQLITE3");
  } else if (flags == 3) {
    char http_inc[4096];
    char flag_I[4096];
    const char *http_leaf = "seeds/http";
    int ln_http = 0;
    int ln_http_abs;
    while (http_leaf[ln_http] != 0)
      ln_http++;
    if (dn + 1 + ln_http >= 4096)
      return -1;
    for (i = 0; i < dn; i++)
      http_inc[i] = comp[i];
    http_inc[dn] = '/';
    for (k = 0; k <= ln_http; k++)
      http_inc[dn + 1 + k] = http_leaf[k];
    ln_http_abs = dn + 1 + ln_http;
    if (2 + ln_http_abs >= 4096)
      return -1;
    flag_I[0] = '-';
    flag_I[1] = 'I';
    for (k = 0; k <= ln_http_abs; k++)
      flag_I[2 + k] = http_inc[k];
    crc = shux_cc_compile_sync_one_extra(src_c, out_o, inc0, inc1, inc2, 0, flag_I);
  } else {
    crc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
  }
  if (crc != 0) {
    link_diag_runtime_obj_build_status(out_base, crc);
    return -1;
  }
  have = asm_link_obj_skip_missing(product_path);
  if (have == NULL) {
    link_diag_runtime_obj_missing(out_base, out_o);
    return -1;
  }
  return 0;
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

/* wave170: ensure_runtime_heap_user_o pure orch (cold twin ≡ .x).
 * Peer heap_user_o_path; Cap residual has_defined_sym/unlink stub + resolve/access/cc/stat.
 * Pure byte join (no snprintf). PLATFORM: SHARED orch (direct seed compile).
 */
int shux_ensure_runtime_heap_user_o(const char *argv0) {
  char comp[4096];
  char out_o[4096];
  char src_c[4096];
  char inc0[4096];
  char inc1[4096];
  char inc2[4096];
  const char *existing;
  const char *have;
  const char *o_path;
  const char *leaf_o = "runtime_heap_user.o";
  const char *leaf_c = "seeds/runtime_heap_user.from_x.c";
  int dn, ln_o, ln_c, i, k, rc, crc;
  existing = shux_runtime_heap_user_o_path(argv0);
  have = asm_link_obj_skip_missing(existing);
  if (have != NULL) {
    if (shux_link_obj_has_defined_sym(existing, "heap_arena_init_c") != 0
        || shux_link_obj_has_defined_sym(existing, "heap_alloc_c") != 0)
      return 0;
    (void)unlink(existing);
  }
  rc = shu_resolve_compiler_dir(argv0, comp, sizeof comp);
  if (rc != 0) {
    link_diag_runtime_obj_resolve_fail("runtime_heap_user.o", NULL);
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
  ln_c = 0;
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
    link_diag_runtime_source_missing("runtime_heap_user", src_c);
    return -1;
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
  crc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
  if (crc != 0) {
    link_diag_runtime_obj_build_status("runtime_heap_user.o", crc);
    return -1;
  }
  o_path = shux_runtime_heap_user_o_path(argv0);
  have = asm_link_obj_skip_missing(o_path);
  if (have == NULL) {
    link_diag_runtime_obj_missing("runtime_heap_user.o", out_o);
    return -1;
  }
  return 0;
}

/* wave171: ensure_runtime_test_fn_invoke_o pure orch (cold twin ≡ .x).
 * Peer test_fn_invoke_o_path; Cap residual resolve/access/cc/stat.
 * Pure byte join (no snprintf). Direct seed compile (no wrap.c).
 * PLATFORM: SHARED orch.
 */
int shux_ensure_runtime_test_fn_invoke_o(const char *argv0) {
  char comp[4096];
  char out_o[4096];
  char src_c[4096];
  char inc0[4096];
  char inc1[4096];
  char inc2[4096];
  const char *existing;
  const char *have;
  const char *o_path;
  const char *leaf_o = "runtime_test_fn_invoke.o";
  const char *leaf_c = "seeds/runtime_test_fn_invoke.from_x.c";
  int dn, ln_o, ln_c, i, k, rc, crc;
  existing = shux_runtime_test_fn_invoke_o_path(argv0);
  have = asm_link_obj_skip_missing(existing);
  if (have != NULL)
    return 0;
  rc = shu_resolve_compiler_dir(argv0, comp, sizeof comp);
  if (rc != 0) {
    link_diag_runtime_obj_resolve_fail("runtime_test_fn_invoke.o",
                                       "try: make -C compiler runtime_test_fn_invoke.o");
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
  ln_c = 0;
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
    link_diag_runtime_source_missing("runtime_test_fn_invoke", src_c);
    return -1;
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
  crc = shux_cc_compile_sync(src_c, out_o, inc0, inc1, inc2, 0);
  if (crc != 0) {
    link_diag_runtime_obj_build_status("runtime_test_fn_invoke.o", crc);
    return -1;
  }
  o_path = shux_runtime_test_fn_invoke_o_path(argv0);
  have = asm_link_obj_skip_missing(o_path);
  if (have == NULL) {
    link_diag_runtime_obj_missing("runtime_test_fn_invoke.o", out_o);
    return -1;
  }
  return 0;
}

/* wave172: ensure_runtime_tls_mbedtls_bio_o pure orch (cold twin ≡ .x).
 * Peer tls_mbedtls_bio_o_path; Cap residual resolve/access/cc_one_extra/stat.
 * Pure byte join (no snprintf). Direct seed compile + homebrew -I (≡ mega).
 * PLATFORM: SHARED orch; MACOS homebrew -I always best-effort.
 */
int shux_ensure_runtime_tls_mbedtls_bio_o(const char *argv0) {
  char comp[4096];
  char out_o[4096];
  char src_c[4096];
  char inc0[4096];
  char inc1[4096];
  char inc2[4096];
  const char *existing;
  const char *have;
  const char *o_path;
  const char *leaf_o = "runtime_tls_mbedtls_bio.o";
  const char *leaf_c = "seeds/runtime_tls_mbedtls_bio.from_x.c";
  const char *flag_I = "-I/opt/homebrew/opt/mbedtls/include";
  int dn, ln_o, ln_c, i, k, rc, crc;
  existing = shux_runtime_tls_mbedtls_bio_o_path(argv0);
  have = asm_link_obj_skip_missing(existing);
  if (have != NULL)
    return 0;
  rc = shu_resolve_compiler_dir(argv0, comp, sizeof comp);
  if (rc != 0) {
    link_diag_runtime_obj_resolve_fail("runtime_tls_mbedtls_bio.o", NULL);
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
  ln_c = 0;
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
    link_diag_runtime_source_missing("runtime_tls_mbedtls_bio", src_c);
    return -1;
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
  crc = shux_cc_compile_sync_one_extra(src_c, out_o, inc0, inc1, inc2, 0, flag_I);
  if (crc != 0) {
    link_diag_runtime_obj_build_status("runtime_tls_mbedtls_bio.o", crc);
    return -1;
  }
  o_path = shux_runtime_tls_mbedtls_bio_o_path(argv0);
  have = asm_link_obj_skip_missing(o_path);
  if (have == NULL) {
    link_diag_runtime_obj_missing("runtime_tls_mbedtls_bio.o", out_o);
    return -1;
  }
  return 0;
}

/* wave174: 26 catalog thin ensure wraps pure (cold twin ≡ labi_ensure_list.x). */
/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_asm_io_stubs_o(const char *argv0) {
  const char *p = shux_runtime_asm_io_stubs_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 0, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_process_argv_o(const char *argv0) {
  const char *p = shux_runtime_process_argv_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 1, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_process_os_glue_o(const char *argv0) {
  const char *p = shux_runtime_process_os_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 2, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_random_fill_o(const char *argv0) {
  const char *p = shux_runtime_random_fill_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 3, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_compress_zlib_glue_o(const char *argv0) {
  const char *p = shux_runtime_compress_zlib_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 4, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_time_os_o(const char *argv0) {
  const char *p = shux_runtime_time_os_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 5, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_queue_contention_o(const char *argv0) {
  const char *p = shux_runtime_queue_contention_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 6, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_dynlib_os_o(const char *argv0) {
  const char *p = shux_runtime_dynlib_os_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 7, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_env_os_o(const char *argv0) {
  const char *p = shux_runtime_env_os_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 8, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_backtrace_platform_o(const char *argv0) {
  const char *p = shux_runtime_backtrace_platform_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 9, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_log_os_o(const char *argv0) {
  const char *p = shux_runtime_log_os_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 10, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_math_libm_o(const char *argv0) {
  const char *p = shux_runtime_math_libm_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 11, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_atomic_glue_o(const char *argv0) {
  const char *p = shux_runtime_atomic_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 12, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_channel_glue_o(const char *argv0) {
  const char *p = shux_runtime_channel_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 13, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_net_udp_batch_o(const char *argv0) {
  const char *p = shux_runtime_net_udp_batch_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 14, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_net_workers_o(const char *argv0) {
  const char *p = shux_runtime_net_workers_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 15, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_sync_os_o(const char *argv0) {
  const char *p = shux_runtime_sync_os_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 16, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_sync_lock_diag_tls_o(const char *argv0) {
  const char *p = shux_runtime_sync_lock_diag_tls_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 17, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_thread_glue_o(const char *argv0) {
  const char *p = shux_runtime_thread_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 18, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_scheduler_glue_o(const char *argv0) {
  const char *p = shux_runtime_scheduler_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 19, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_http_glue_o(const char *argv0) {
  const char *p = shux_runtime_http_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 20, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_kv_mmap_glue_o(const char *argv0) {
  const char *p = shux_runtime_kv_mmap_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 21, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_arrow_simd_glue_o(const char *argv0) {
  const char *p = shux_runtime_arrow_simd_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 22, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_sqlite_glue_o(const char *argv0) {
  const char *p = shux_runtime_sqlite_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 23, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_crypto_inc_glue_o(const char *argv0) {
  const char *p = shux_runtime_crypto_inc_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 24, p);
}

/* wave174: catalog thin ensure wrap pure (cold twin ≡ labi_ensure_list.x). */
int shux_ensure_runtime_ed25519_ref10_glue_o(const char *argv0) {
  const char *p = shux_runtime_ed25519_ref10_glue_o_path(argv0);
  return link_abi_ensure_from_catalog(argv0, 25, p);
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
/* wave173: link_abi_ensure_from_catalog pure orch (L4). */
int link_abi_ensure_from_catalog(const char *argv0, int catalog_idx, const char *product_path);
/* wave174: catalog thin ensure wraps pure (L4). */
int shux_ensure_runtime_asm_io_stubs_o(const char *argv0);
int shux_ensure_runtime_process_argv_o(const char *argv0);
int shux_ensure_runtime_process_os_glue_o(const char *argv0);
int shux_ensure_runtime_random_fill_o(const char *argv0);
int shux_ensure_runtime_compress_zlib_glue_o(const char *argv0);
int shux_ensure_runtime_time_os_o(const char *argv0);
int shux_ensure_runtime_queue_contention_o(const char *argv0);
int shux_ensure_runtime_dynlib_os_o(const char *argv0);
int shux_ensure_runtime_env_os_o(const char *argv0);
int shux_ensure_runtime_backtrace_platform_o(const char *argv0);
int shux_ensure_runtime_log_os_o(const char *argv0);
int shux_ensure_runtime_math_libm_o(const char *argv0);
int shux_ensure_runtime_atomic_glue_o(const char *argv0);
int shux_ensure_runtime_channel_glue_o(const char *argv0);
int shux_ensure_runtime_net_udp_batch_o(const char *argv0);
int shux_ensure_runtime_net_workers_o(const char *argv0);
int shux_ensure_runtime_sync_os_o(const char *argv0);
int shux_ensure_runtime_sync_lock_diag_tls_o(const char *argv0);
int shux_ensure_runtime_thread_glue_o(const char *argv0);
int shux_ensure_runtime_scheduler_glue_o(const char *argv0);
int shux_ensure_runtime_http_glue_o(const char *argv0);
int shux_ensure_runtime_kv_mmap_glue_o(const char *argv0);
int shux_ensure_runtime_arrow_simd_glue_o(const char *argv0);
int shux_ensure_runtime_sqlite_glue_o(const char *argv0);
int shux_ensure_runtime_crypto_inc_glue_o(const char *argv0);
int shux_ensure_runtime_ed25519_ref10_glue_o(const char *argv0);
/* wave169: ensure_runtime_panic_o pure orch (L4). */
int shux_ensure_runtime_panic_o(const char *argv0);
/* wave170: ensure_runtime_heap_user_o pure orch (L4). */
int shux_ensure_runtime_heap_user_o(const char *argv0);
/* wave171: ensure_runtime_test_fn_invoke_o pure orch (L4). */
int shux_ensure_runtime_test_fn_invoke_o(const char *argv0);
/* wave172: ensure_runtime_tls_mbedtls_bio_o pure orch (L4). */
int shux_ensure_runtime_tls_mbedtls_bio_o(const char *argv0);
#endif

int labi_ensure_list_slice_marker(void) {
  return 1;
}