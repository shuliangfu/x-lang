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
 *   ensure_std_net_o_auto_tls (wave187 pure orch; Cap residual getenv+system+
 *     realpath_cap+exports_marker; shell make net-o-* Cap residual)
 *   shux_ensure_formal_std_make_o (wave188 pure orch; Cap residual getenv+access+
 *     realpath_cap+system+asm_link_obj_skip_missing; shell make formal std Cap residual)
 * Cap residual: host_is_apple; needs+ensure+path Cap;
 *   invoke_cc_argv_resolve_existing_path (skip+realpath pool);
 *   exports_marker / realpath_cap / shux_rel_o_path_from_argv0;
 *   spawn/ld/cc IO; contains_substr / undef_sym / path_io / wait / strerror / ld_debug_argv;
 *   getenv / system / access for ensure_std_net + formal_std_make (wave187/188 Cap residual).
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
/* Cap residual (wave187/188 ensure shell make): getenv / system / access / skip_missing. */
char *getenv(const char *name);
int system(const char *cmd);
int access(const char *path, int mode);
const char *asm_link_obj_skip_missing(const char *path);

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

/* wave187: ensure_std_net_o_auto_tls pure orch (cold twin ≡ .x).
 * Cap residual: getenv + system + realpath_cap + exports_marker.
 * Pure helpers + mode orch. PLATFORM: SHARED.
 */
int labi_net_tls_buf_append(char *dst, int cap, int pos, const char *src) {
  int i = 0;
  if (!dst || pos < 0 || pos >= cap)
    return -1;
  if (!src) {
    dst[pos] = '\0';
    return pos;
  }
  while (src[i]) {
    if (pos + 1 >= cap) {
      dst[pos] = '\0';
      return -1;
    }
    dst[pos++] = src[i++];
  }
  dst[pos] = '\0';
  return pos;
}

int labi_net_tls_build_make_cmd(char *cmd, int cap, const char *repo_root, const char *target) {
  int pos = 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, "make -C '");
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, repo_root);
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, "'/compiler' ");
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, target);
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, " >/dev/null 2>&1");
  if (pos < 0)
    return 0;
  return 1;
}

int labi_net_tls_join_repo_rel(char *path_buf, int cap, const char *repo_root, const char *rel) {
  int pos = 0;
  pos = labi_net_tls_buf_append(path_buf, cap, pos, repo_root);
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(path_buf, cap, pos, "/");
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(path_buf, cap, pos, rel);
  if (pos < 0)
    return 0;
  return 1;
}

void ensure_std_net_o_auto_tls(const char *repo_root) {
  char cmd[640];
  char path_buf[4096];
  char resolved[4096];
  const char *mode;
  const char *mk_ssl;
  const char *mk_mb;
  const char *rp;
  if (!repo_root || !repo_root[0])
    return;
  mode = getenv("SHUX_NET_TLS");
  if (!mode || !mode[0])
    return;
  mk_ssl = labi_net_tls_openssl_marker();
  mk_mb = labi_net_tls_mbedtls_marker();
  if (strcmp(mode, "stub") == 0) {
    if (labi_net_tls_build_make_cmd(cmd, 640, repo_root, "net-o-stub"))
      (void)system(cmd);
    return;
  }
  if (labi_net_tls_join_repo_rel(path_buf, 4096, repo_root, "std/net/tls_openssl.o")) {
    rp = link_abi_realpath_cap(path_buf, resolved);
    if (rp && link_abi_obj_exports_marker(rp, mk_ssl))
      return;
  }
  if (labi_net_tls_join_repo_rel(path_buf, 4096, repo_root, "std/net/tls_mbedtls.o")) {
    rp = link_abi_realpath_cap(path_buf, resolved);
    if (rp && link_abi_obj_exports_marker(rp, mk_mb))
      return;
  }
  resolved[0] = '\0';
  if (labi_net_tls_join_repo_rel(path_buf, 4096, repo_root, "std/net/net.o")) {
    rp = link_abi_realpath_cap(path_buf, resolved);
    if (!rp)
      rp = link_abi_realpath_cap("std/net/net.o", resolved);
    if (rp && (link_abi_obj_exports_marker(rp, mk_ssl) || link_abi_obj_exports_marker(rp, mk_mb)))
      return;
  }
  if (strcmp(mode, "openssl") == 0) {
    if (labi_net_tls_build_make_cmd(cmd, 640, repo_root, "net-o-openssl"))
      (void)system(cmd);
    return;
  }
  if (strcmp(mode, "mbedtls") == 0) {
    if (labi_net_tls_build_make_cmd(cmd, 640, repo_root, "net-o-mbedtls"))
      (void)system(cmd);
    return;
  }
  if (strcmp(mode, "auto") != 0)
    return;
  if (labi_net_tls_build_make_cmd(cmd, 640, repo_root, "net-o-openssl")) {
    if (system(cmd) != 0) {
      if (labi_net_tls_build_make_cmd(cmd, 640, repo_root, "net-o-mbedtls"))
        (void)system(cmd);
    }
  }
}

/* wave188: shux_ensure_formal_std_make_o pure orch (cold twin ≡ .x).
 * Cap residual: getenv + access + realpath_cap + system + asm_link_obj_skip_missing.
 * Pure path/SHUX/make-cmd join. PLATFORM: SHARED.
 */
int labi_formal_std_build_make_cmd(char *cmd, int cap, const char *shux_bin,
                                   const char *repo_root, const char *make_target) {
  int pos = 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, "SHUX_FORMAL_STD_ENSURE=1 SHUX='");
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, shux_bin);
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, "' make -C '");
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, repo_root);
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, "/compiler' '");
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, make_target);
  if (pos < 0)
    return 0;
  pos = labi_net_tls_buf_append(cmd, cap, pos, "'");
  if (pos < 0)
    return 0;
  return 1;
}

int shux_ensure_formal_std_make_o(const char *repo_root, const char *rel_from_repo,
                                  const char *make_target) {
  char abs[4096];
  char cmd[768];
  char shux_bin[4096];
  char cand[4096];
  const char *env_shux;
  const char *ensuring;
  const char *have;
  const char *rp;
  const char *names[3];
  int i;
  int ax;
  int pos;
  if (!repo_root || !repo_root[0] || !rel_from_repo || !rel_from_repo[0] ||
      !make_target || !make_target[0])
    return 0;
  if (!labi_net_tls_join_repo_rel(abs, 4096, repo_root, rel_from_repo))
    return 0;
  have = asm_link_obj_skip_missing(abs);
  if (have)
    return 1;
  ensuring = getenv("SHUX_FORMAL_STD_ENSURE");
  if (ensuring && ensuring[0] && ensuring[0] != '0')
    return 0;
  shux_bin[0] = '\0';
  env_shux = getenv("SHUX");
  if (env_shux && env_shux[0] && access(env_shux, 1 /* X_OK */) == 0) {
    rp = link_abi_realpath_cap(env_shux, shux_bin);
    if (!rp) {
      if (labi_net_tls_buf_append(shux_bin, 4096, 0, env_shux) < 0)
        return 0;
    }
  } else {
    names[0] = "shux_asm";
    names[1] = "shux";
    names[2] = "shux-c";
    for (i = 0; i < 3; i++) {
      pos = 0;
      pos = labi_net_tls_buf_append(cand, 4096, pos, repo_root);
      if (pos < 0)
        continue;
      pos = labi_net_tls_buf_append(cand, 4096, pos, "/compiler/");
      if (pos < 0)
        continue;
      pos = labi_net_tls_buf_append(cand, 4096, pos, names[i]);
      if (pos < 0)
        continue;
      ax = access(cand, 1 /* X_OK */);
      if (ax != 0)
        continue;
      rp = link_abi_realpath_cap(cand, shux_bin);
      if (!rp) {
        if (labi_net_tls_buf_append(shux_bin, 4096, 0, cand) < 0)
          return 0;
      }
      break;
    }
  }
  if (!shux_bin[0])
    return 0;
  if (!labi_formal_std_build_make_cmd(cmd, 768, shux_bin, repo_root, make_target))
    return 0;
  (void)system(cmd);
  return asm_link_obj_skip_missing(abs) ? 1 : 0;
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
/* wave187: ensure_std_net_o_auto_tls pure orch + helpers (L6). */
int labi_net_tls_buf_append(char *dst, int cap, int pos, const char *src);
int labi_net_tls_build_make_cmd(char *cmd, int cap, const char *repo_root, const char *target);
int labi_net_tls_join_repo_rel(char *path_buf, int cap, const char *repo_root, const char *rel);
void ensure_std_net_o_auto_tls(const char *repo_root);
/* wave188: shux_ensure_formal_std_make_o pure orch + helper (L6). */
int labi_formal_std_build_make_cmd(char *cmd, int cap, const char *shux_bin,
                                   const char *repo_root, const char *make_target);
int shux_ensure_formal_std_make_o(const char *repo_root, const char *rel_from_repo,
                                  const char *make_target);
#endif

int labi_invoke_ld_list_slice_marker(void) {
  return 1;
}