/* seeds/labi_invoke_ld_list.from_x.c — G-02f-275 P2 link_abi L6 invoke_ld list pure → R2 full
 * Logic source: src/runtime/labi_invoke_ld_list.x
 * Hybrid: SHUX_LABI_INVOKE_LD_LIST_FROM_X + ld -r into runtime_link_abi.o
 *
 * R2 full：公共业务符号由 full .x 提供：
 *   labi_ld_brew_lib_path_{count,at}
 *   labi_ld_compress_flag_{count,at} + labi_ld_flag_lz/zstd/brotli*
 *   labi_ld_flag_lm/sqlite3/pthread/ldl/lc/lSystem/lws2_32/lbcrypt
 *   labi_ld_driver_{clang,ld,gcc,cc} + labi_ld_mach_entry_main + labi_ld_flag_{e,o}
 *   labi_ld_common_tail_flag_{count,at}
 *   ld_append_brew_lib_paths (wave152 pure orch; Cap residual link_abi_host_is_apple)
 *   asm_ld_append_compress_libs (wave153 pure orch; Cap residual needs+ensure+path)
 *   invoke_cc_append_compress_ld (wave154 pure orch; Cap residual needs+ensure+path
 *     + pure push_existing for glue realpath/skip/dedup)
 *   shux_asm_ld_append_mach_tail_libs_impl (wave156 pure orch; flags i32 layout
 *     + pure flag_* + peer compress orch + peer needs_compress)
 *   shux_asm_ld_append_unix_gcc_tail_libs_impl (wave157 pure orch; host_is_linux
 *     + host_is_apple for -ldl / else -lc gates)
 *   invoke_cc_append_net_tls_ld (wave158 pure orch; Cap residual exports_marker +
 *     realpath_cap + rel_o_path + pure push_existing + host_is_apple for brew -L)
 *   invoke_cc_argv_push_existing (wave179 pure orch; Cap residual resolve pool)
 * Cap residual: host_is_apple; needs+ensure+path Cap;
 *   invoke_cc_argv_resolve_existing_path (skip+realpath pool);
 *   exports_marker / realpath_cap / shux_rel_o_path_from_argv0;
 *   spawn/ld/cc IO; contains_substr / undef_sym / path_io / wait / strerror / ld_debug_argv;
 *   ensure_std_net_o_auto_tls (system/make) stays mega Cap residual.
 * FROM_X 下本文件仅前向声明 + slice marker（产品 rest 业务 H=0）。
 * 冷启动/无 PREFER 时仍编译完整 C 体（可与 mega 并存）。
 *
 * Prove：seeds/labi_invoke_ld_list_surface.from_x.c（-E 同构）nm IDENTICAL。
 */
#include <stddef.h>
#include <string.h>
/* ShuAsmLdStdLinkFlags for wave156/157 cold twin (standalone seed cc + mega include). */
#include "runtime_link_abi.h"

/* Cap residual / peer pure always provided by mega (or other pure slices); cold twin calls them. */
int link_abi_host_is_apple(void);
int shux_host_is_linux(void);
int link_abi_obj_needs_zlib(const char *obj_o);
int link_abi_obj_needs_zstd(const char *obj_o);
int link_abi_obj_needs_brotli(const char *obj_o);
int link_abi_user_o_needs_compress_libs(const char *user_o);
int shux_ensure_runtime_compress_zlib_glue_o(const char *argv0);
const char *shux_runtime_compress_zlib_glue_o_path(const char *argv0);
/* Cap residual (wave179): skip_missing + realpath multi-slot pool. */
const char *invoke_cc_argv_resolve_existing_path(const char *path);
int link_abi_obj_exports_marker(const char *obj_o, const char *marker);
const char *link_abi_realpath_cap(const char *path, char *out);
const char *shux_rel_o_path_from_argv0(const char *argv0, const char *rel);

#ifndef SHUX_LABI_INVOKE_LD_LIST_FROM_X

/* wave179: pure orch invoke_cc_argv_push_existing (cold twin ≡ .x).
 * Cap residual resolve + pure gates/dedup/append. PLATFORM: SHARED.
 */
int invoke_cc_argv_push_existing(char *argv[], int *ia, int max_ia, const char *path) {
  const char *use;
  int k;
  int cur;
  if (!argv || !ia || !path || !path[0])
    return 0;
  cur = *ia;
  if (cur >= max_ia - 1)
    return 0;
  use = invoke_cc_argv_resolve_existing_path(path);
  if (!use)
    return 0;
  for (k = 0; k < cur; k++) {
    if (argv[k] && strcmp(argv[k], use) == 0)
      return 0;
  }
  argv[(*ia)++] = (char *)use;
  return 1;
}

int labi_ld_brew_lib_path_count(void) {
  return 2;
}

const char *labi_ld_brew_lib_path_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-L/opt/homebrew/lib";
  if (i == 1)
    return "-L/usr/local/lib";
  return NULL;
}

const char *labi_ld_flag_lz(void) { return "-lz"; }
const char *labi_ld_flag_lzstd(void) { return "-lzstd"; }
const char *labi_ld_flag_lbrotlienc(void) { return "-lbrotlienc"; }
const char *labi_ld_flag_lbrotlidec(void) { return "-lbrotlidec"; }

int labi_ld_compress_flag_count(void) {
  return 4;
}

const char *labi_ld_compress_flag_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-lz";
  if (i == 1)
    return "-lzstd";
  if (i == 2)
    return "-lbrotlienc";
  if (i == 3)
    return "-lbrotlidec";
  return NULL;
}

const char *labi_ld_flag_lm(void) { return "-lm"; }
const char *labi_ld_flag_lsqlite3(void) { return "-lsqlite3"; }
const char *labi_ld_flag_pthread(void) { return "-pthread"; }
const char *labi_ld_flag_lpthread(void) { return "-lpthread"; }
const char *labi_ld_flag_ldl(void) { return "-ldl"; }
const char *labi_ld_flag_lc(void) { return "-lc"; }
const char *labi_ld_flag_lSystem(void) { return "-lSystem"; }
const char *labi_ld_flag_lws2_32(void) { return "-lws2_32"; }
const char *labi_ld_flag_lbcrypt(void) { return "-lbcrypt"; }

/* wave158: net_tls pure flag/marker/rel catalog (cold twin ≡ .x). */
const char *labi_ld_flag_L_hb_openssl(void) { return "-L/opt/homebrew/opt/openssl/lib"; }
const char *labi_ld_flag_L_hb_mbedtls(void) { return "-L/opt/homebrew/opt/mbedtls/lib"; }
const char *labi_ld_flag_lssl(void) { return "-lssl"; }
const char *labi_ld_flag_lcrypto(void) { return "-lcrypto"; }
const char *labi_ld_flag_lmbedtls(void) { return "-lmbedtls"; }
const char *labi_ld_flag_lmbedx509(void) { return "-lmbedx509"; }
const char *labi_ld_flag_lmbedcrypto(void) { return "-lmbedcrypto"; }
const char *labi_net_tls_openssl_marker(void) { return "shu_net_tls_openssl_marker"; }
const char *labi_net_tls_mbedtls_marker(void) { return "shu_net_tls_mbedtls_marker"; }
const char *labi_rel_tls_openssl_o(void) { return "std/net/tls_openssl.o"; }
const char *labi_rel_tls_mbedtls_o(void) { return "std/net/tls_mbedtls.o"; }

void labi_append_openssl_ld_flags(char *argv[], int *i, int argv_cap) {
  if (!argv || !i)
    return;
  if (link_abi_host_is_apple() && *i < argv_cap - 1)
    argv[(*i)++] = (char *)labi_ld_flag_L_hb_openssl();
  if (*i < argv_cap - 1)
    argv[(*i)++] = (char *)labi_ld_flag_lssl();
  if (*i < argv_cap - 1)
    argv[(*i)++] = (char *)labi_ld_flag_lcrypto();
}

void labi_append_mbedtls_ld_flags(char *argv[], int *i, int argv_cap) {
  if (!argv || !i)
    return;
  if (link_abi_host_is_apple() && *i < argv_cap - 1)
    argv[(*i)++] = (char *)labi_ld_flag_L_hb_mbedtls();
  if (*i < argv_cap - 1)
    argv[(*i)++] = (char *)labi_ld_flag_lmbedtls();
  if (*i < argv_cap - 1)
    argv[(*i)++] = (char *)labi_ld_flag_lmbedx509();
  if (*i < argv_cap - 1)
    argv[(*i)++] = (char *)labi_ld_flag_lmbedcrypto();
}

const char *labi_ld_driver_clang(void) { return "clang"; }
const char *labi_ld_driver_ld(void) { return "ld"; }
const char *labi_ld_driver_gcc(void) { return "gcc"; }
const char *labi_ld_driver_cc(void) { return "cc"; }
const char *labi_ld_mach_entry_main(void) { return "_main"; }
const char *labi_ld_flag_e(void) { return "-e"; }
const char *labi_ld_flag_o(void) { return "-o"; }

int labi_ld_common_tail_flag_count(void) {
  return 7;
}

const char *labi_ld_common_tail_flag_at(int i) {
  if (i < 0)
    return NULL;
  if (i == 0)
    return "-lm";
  if (i == 1)
    return "-lsqlite3";
  if (i == 2)
    return "-pthread";
  if (i == 3)
    return "-lpthread";
  if (i == 4)
    return "-ldl";
  if (i == 5)
    return "-lc";
  if (i == 6)
    return "-lSystem";
  return NULL;
}

/* wave152: ld_append_brew_lib_paths pure orch (cold twin ≡ .x; Cap residual host_is_apple). */
void ld_append_brew_lib_paths(const char **argv, int *la, int max_la) {
  int n;
  int k;
  if (!link_abi_host_is_apple())
    return;
  if (!argv || !la)
    return;
  n = labi_ld_brew_lib_path_count();
  for (k = 0; k < n; k++) {
    const char *p;
    if (*la >= max_la - 1)
      break;
    p = labi_ld_brew_lib_path_at(k);
    if (!p || !p[0])
      continue;
    argv[(*la)++] = p;
  }
}

/* wave153: asm_ld_append_compress_libs pure orch (cold twin ≡ .x). */
void asm_ld_append_compress_libs(const char *compress_o, const char *user_o, const char **argv, int *la, int max_la) {
  if (!argv || !la)
    return;
  if (link_abi_obj_needs_zlib(compress_o) || link_abi_obj_needs_zlib(user_o)) {
    ld_append_brew_lib_paths(argv, la, max_la);
    if (*la < max_la - 1)
      argv[(*la)++] = labi_ld_flag_lz();
    (void)shux_ensure_runtime_compress_zlib_glue_o(NULL);
    {
      const char *glue = shux_runtime_compress_zlib_glue_o_path(NULL);
      if (glue && glue[0] && *la < max_la - 1)
        argv[(*la)++] = glue;
    }
  }
  if (link_abi_obj_needs_zstd(compress_o) || link_abi_obj_needs_zstd(user_o)) {
    ld_append_brew_lib_paths(argv, la, max_la);
    if (*la < max_la - 1)
      argv[(*la)++] = labi_ld_flag_lzstd();
  }
  if (link_abi_obj_needs_brotli(compress_o) || link_abi_obj_needs_brotli(user_o)) {
    ld_append_brew_lib_paths(argv, la, max_la);
    if (*la < max_la - 1)
      argv[(*la)++] = labi_ld_flag_lbrotlienc();
    if (*la < max_la - 1)
      argv[(*la)++] = labi_ld_flag_lbrotlidec();
  }
}

/* wave154: invoke_cc_append_compress_ld pure orch (cold twin ≡ .x; Cap residual push_existing). */
void invoke_cc_append_compress_ld(char *argv[], int *i, int argv_cap, const char *compress_o, const char *user_o) {
  if (!argv || !i || *i >= argv_cap - 1)
    return;
  if (link_abi_obj_needs_zlib(compress_o) || link_abi_obj_needs_zlib(user_o)) {
    ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
    if (*i < argv_cap - 1)
      argv[(*i)++] = (char *)labi_ld_flag_lz();
    (void)shux_ensure_runtime_compress_zlib_glue_o(NULL);
    (void)invoke_cc_argv_push_existing(argv, i, argv_cap,
        shux_runtime_compress_zlib_glue_o_path(NULL));
  }
  if (link_abi_obj_needs_zstd(compress_o) || link_abi_obj_needs_zstd(user_o)) {
    ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
    if (*i < argv_cap - 1)
      argv[(*i)++] = (char *)labi_ld_flag_lzstd();
  }
  if (link_abi_obj_needs_brotli(compress_o) || link_abi_obj_needs_brotli(user_o)) {
    ld_append_brew_lib_paths((const char **)argv, i, argv_cap);
    if (*i < argv_cap - 1)
      argv[(*i)++] = (char *)labi_ld_flag_lbrotlienc();
    if (*i < argv_cap - 1)
      argv[(*i)++] = (char *)labi_ld_flag_lbrotlidec();
  }
}

/* wave156: shux_asm_ld_append_mach_tail_libs_impl pure orch (cold twin ≡ .x).
 * Signature keeps ShuAsmLdStdLinkFlags* (mega ABI); pure .x reads same LP64 i32 layout. */
void shux_asm_ld_append_mach_tail_libs_impl(const char *compress_o, const char *user_o,
    const ShuAsmLdStdLinkFlags *flags, const char **argv, int *la, int max_la, int append_lsystem) {
  int need_pt;
  int need_comp;
  if (!flags || !argv || !la || *la < 0)
    return;
  need_pt = (flags->have_thread || flags->have_sync || flags->have_channel) ? 1 : 0;
  if (flags->have_math && *la < max_la - 1)
    argv[(*la)++] = labi_ld_flag_lm();
  need_comp = flags->have_compress;
  if (!need_comp)
    need_comp = link_abi_user_o_needs_compress_libs(user_o);
  if (need_comp)
    asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
  if (flags->have_sqlite && *la < max_la - 1)
    argv[(*la)++] = labi_ld_flag_lsqlite3();
  if (need_pt && *la < max_la - 1)
    argv[(*la)++] = labi_ld_flag_pthread();
  if (append_lsystem && *la < max_la - 1)
    argv[(*la)++] = labi_ld_flag_lSystem();
}

/* wave157: shux_asm_ld_append_unix_gcc_tail_libs_impl pure orch (cold twin ≡ .x).
 * Signature keeps ShuAsmLdStdLinkFlags* (mega ABI); pure .x reads same LP64 i32 layout.
 * -ldl gated by peer shux_host_is_linux; else-branch -lc by linux|apple. */
void shux_asm_ld_append_unix_gcc_tail_libs_impl(const char *compress_o, const char *user_o,
    const ShuAsmLdStdLinkFlags *flags, int need_pt, const char **argv, int *la, int max_la) {
  int need_comp;
  int always_lc;
  if (!flags || !argv || !la || *la < 0)
    return;
  /* pthread: have_io uses -pthread; !have_io && need_pt uses -lpthread (≡ mega). */
  if (flags->have_io) {
    if (need_pt && *la < max_la - 1)
      argv[(*la)++] = labi_ld_flag_pthread();
  } else if (need_pt && *la < max_la - 1) {
    argv[(*la)++] = labi_ld_flag_lpthread();
  }
  if (flags->have_math && *la < max_la - 1)
    argv[(*la)++] = labi_ld_flag_lm();
  need_comp = flags->have_compress;
  if (!need_comp)
    need_comp = link_abi_user_o_needs_compress_libs(user_o);
  if (need_comp)
    asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
  if (flags->have_sqlite && *la < max_la - 1)
    argv[(*la)++] = labi_ld_flag_lsqlite3();
  /* -ldl only on Linux when dynlib (mega #if __linux__). */
  if (flags->have_dynlib && shux_host_is_linux() && *la < max_la - 1)
    argv[(*la)++] = labi_ld_flag_ldl();
  always_lc = (flags->have_io || flags->have_net || need_pt) ? 1 : 0;
  if (always_lc) {
    if (*la < max_la - 1)
      argv[(*la)++] = labi_ld_flag_lc();
  } else {
    /* Final else: -lc only on linux|apple when any of heap/fs/math/compress/sqlite/dynlib. */
    if ((flags->have_libc_heap || flags->have_fs || flags->have_math || flags->have_compress
            || flags->have_sqlite || flags->have_dynlib)
        && (shux_host_is_linux() || link_abi_host_is_apple()) && *la < max_la - 1)
      argv[(*la)++] = labi_ld_flag_lc();
  }
}

/* wave158: invoke_cc_append_net_tls_ld pure orch (cold twin ≡ .x).
 * Cap residual: exports_marker + realpath_cap + rel_o_path + push_existing.
 * Apple brew -L gated by host_is_apple inside append_* helpers. */
int invoke_cc_append_net_tls_ld(char *argv[], int *i, int argv_cap, const char *net_o, const char *repo_root) {
  char abs_buf[4096];
  const char *use;
  const char *rn;
  const char *tls_o;
  const char *mk_ssl;
  const char *mk_mb;
  if (!argv || !i || *i >= argv_cap - 1)
    return 0;
  mk_ssl = labi_net_tls_openssl_marker();
  mk_mb = labi_net_tls_mbedtls_marker();
  /* Phase 1: net_o markers (legacy co-located; rare post F-04 v8). */
  if (net_o && net_o[0]) {
    use = net_o;
    rn = link_abi_realpath_cap(net_o, abs_buf);
    if (rn && rn[0])
      use = rn;
    if (link_abi_obj_exports_marker(use, mk_ssl)) {
      labi_append_openssl_ld_flags(argv, i, argv_cap);
      return 1;
    }
    if (link_abi_obj_exports_marker(use, mk_mb)) {
      labi_append_mbedtls_ld_flags(argv, i, argv_cap);
      return 1;
    }
  }
  if (!repo_root || !repo_root[0])
    return 0;
  /* Phase 2: std/net/tls_openssl.o */
  tls_o = shux_rel_o_path_from_argv0(repo_root, labi_rel_tls_openssl_o());
  if (tls_o && tls_o[0]) {
    use = tls_o;
    rn = link_abi_realpath_cap(tls_o, abs_buf);
    if (rn && rn[0])
      use = rn;
    if (link_abi_obj_exports_marker(use, mk_ssl)) {
      (void)invoke_cc_argv_push_existing(argv, i, argv_cap, tls_o);
      labi_append_openssl_ld_flags(argv, i, argv_cap);
      return 1;
    }
  }
  /* Phase 2b: std/net/tls_mbedtls.o */
  tls_o = shux_rel_o_path_from_argv0(repo_root, labi_rel_tls_mbedtls_o());
  if (tls_o && tls_o[0]) {
    use = tls_o;
    rn = link_abi_realpath_cap(tls_o, abs_buf);
    if (rn && rn[0])
      use = rn;
    if (link_abi_obj_exports_marker(use, mk_mb)) {
      (void)invoke_cc_argv_push_existing(argv, i, argv_cap, tls_o);
      labi_append_mbedtls_ld_flags(argv, i, argv_cap);
      return 1;
    }
  }
  return 0;
}

#else
int invoke_cc_argv_push_existing(char *argv[], int *ia, int max_ia, const char *path);
int labi_ld_brew_lib_path_count(void);
const char *labi_ld_brew_lib_path_at(int i);
const char *labi_ld_flag_lz(void);
const char *labi_ld_flag_lzstd(void);
const char *labi_ld_flag_lbrotlienc(void);
const char *labi_ld_flag_lbrotlidec(void);
int labi_ld_compress_flag_count(void);
const char *labi_ld_compress_flag_at(int i);
const char *labi_ld_flag_lm(void);
const char *labi_ld_flag_lsqlite3(void);
const char *labi_ld_flag_pthread(void);
const char *labi_ld_flag_lpthread(void);
const char *labi_ld_flag_ldl(void);
const char *labi_ld_flag_lc(void);
const char *labi_ld_flag_lSystem(void);
const char *labi_ld_flag_lws2_32(void);
const char *labi_ld_flag_lbcrypt(void);
const char *labi_ld_flag_L_hb_openssl(void);
const char *labi_ld_flag_L_hb_mbedtls(void);
const char *labi_ld_flag_lssl(void);
const char *labi_ld_flag_lcrypto(void);
const char *labi_ld_flag_lmbedtls(void);
const char *labi_ld_flag_lmbedx509(void);
const char *labi_ld_flag_lmbedcrypto(void);
const char *labi_net_tls_openssl_marker(void);
const char *labi_net_tls_mbedtls_marker(void);
const char *labi_rel_tls_openssl_o(void);
const char *labi_rel_tls_mbedtls_o(void);
void labi_append_openssl_ld_flags(char *argv[], int *i, int argv_cap);
void labi_append_mbedtls_ld_flags(char *argv[], int *i, int argv_cap);
const char *labi_ld_driver_clang(void);
const char *labi_ld_driver_ld(void);
const char *labi_ld_driver_gcc(void);
const char *labi_ld_driver_cc(void);
const char *labi_ld_mach_entry_main(void);
const char *labi_ld_flag_e(void);
const char *labi_ld_flag_o(void);
int labi_ld_common_tail_flag_count(void);
const char *labi_ld_common_tail_flag_at(int i);
void ld_append_brew_lib_paths(const char **argv, int *la, int max_la);
void asm_ld_append_compress_libs(const char *compress_o, const char *user_o, const char **argv, int *la, int max_la);
void invoke_cc_append_compress_ld(char *argv[], int *i, int argv_cap, const char *compress_o, const char *user_o);
void shux_asm_ld_append_mach_tail_libs_impl(const char *compress_o, const char *user_o,
    const ShuAsmLdStdLinkFlags *flags, const char **argv, int *la, int max_la, int append_lsystem);
void shux_asm_ld_append_unix_gcc_tail_libs_impl(const char *compress_o, const char *user_o,
    const ShuAsmLdStdLinkFlags *flags, int need_pt, const char **argv, int *la, int max_la);
int invoke_cc_append_net_tls_ld(char *argv[], int *i, int argv_cap, const char *net_o, const char *repo_root);
#endif

int labi_invoke_ld_list_slice_marker(void) {
  return 1;
}