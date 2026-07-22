// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L6 invoke_ld pure tables + orch (G.9 English; body is authoritative).
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_invoke_ld_list.from_x.c.
// Hybrid macro SHUX_LABI_INVOKE_LD_LIST_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: .x owns brew/compress/tail/driver/entry pure tables + wave152 brew orch
// + wave153 asm compress-libs orch + wave154 invoke_cc compress-ld orch
// + wave156 mach tail_libs_impl pure orch + wave157 unix gcc tail + wave158 net_tls
// + wave179 invoke_cc_argv_push_existing pure orch
// + wave187 ensure_std_net_o_auto_tls pure orch:
//   - labi_ld_brew_lib_path_{count,at} + labi_ld_flag_* / drivers / common_tail
//   - ld_append_brew_lib_paths (wave152; pure table scan; Cap residual host_is_apple)
//   - asm_ld_append_compress_libs (wave153; pure orch; Cap residual needs+ensure+path)
//   - invoke_cc_append_compress_ld (wave154; pure orch; Cap residual needs+ensure+path
//     + pure push_existing for glue realpath/skip/dedup)
//   - shux_asm_ld_append_mach_tail_libs_impl (wave156; pure orch over flags i32 layout
//     + pure flag_* + peer compress orch + peer needs_compress)
//   - shux_asm_ld_append_unix_gcc_tail_libs_impl (wave157; pure orch; peer host_is_linux
//     + host_is_apple for -ldl / else -lc gates)
//   - invoke_cc_append_net_tls_ld (wave158; pure orch; Cap residual exports_marker +
//     realpath_cap + rel_o_path + pure push_existing + host_is_apple for brew -L)
//   - invoke_cc_argv_push_existing (wave179; pure gates/dedup/append; Cap residual resolve pool)
//   - ensure_std_net_o_auto_tls (wave187; pure mode/path orch; Cap residual getenv+system+
//     realpath_cap+exports_marker; shell make net-o-* stays Cap residual)
// Cap residual (mega): link_abi_host_is_apple; obj_needs_* Cap (marker/has_undef);
//   ensure/path for zlib glue; invoke_cc_argv_resolve_existing_path (skip+realpath pool);
//   exports_marker / realpath_cap / shux_rel_o_path_from_argv0;
//   spawn/ld/cc IO; contains_substr / undef_sym / path_io / wait / strerror / ld_debug_argv;
//   getenv / system for ensure_std_net_o_auto_tls shell make (wave187 Cap residual).
// PLATFORM: SHARED orch / MACOS brew+mach / LINUX unix gcc tail -l*.

// Cap residual: compile-time #if __APPLE__ (all arch: aarch64 + x86_64).
// Not the same as shux_host_is_apple_aarch64 (host_lit L2; arm64 only).
export extern "C" function link_abi_host_is_apple(): i32;

// Peer pure (host_lit L2 thin → Cap residual _impl #if __linux__).
// Used by wave157 unix gcc tail for -ldl and (with host_is_apple) else-branch -lc.
export extern "C" function shux_host_is_linux(): i32;

// Cap residual / peer pure (ondemand L8b): .o depends on zlib/zstd/brotli.
export extern "C" function link_abi_obj_needs_zlib(obj_o: *u8): i32;
export extern "C" function link_abi_obj_needs_zstd(obj_o: *u8): i32;
export extern "C" function link_abi_obj_needs_brotli(obj_o: *u8): i32;

// Peer pure (ondemand L8b): user.o needs any compress lib (zlib|zstd|brotli aggregate).
export extern "C" function link_abi_user_o_needs_compress_libs(user_o: *u8): i32;

// Cap residual: ensure zlib macro-wrapper glue .o + resolve its path for ld argv.
export extern "C" function shux_ensure_runtime_compress_zlib_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_compress_zlib_glue_o_path(argv0: *u8): *u8;

// Cap residual (wave179): skip_missing + POSIX realpath multi-slot pool → durable path ptr.
// Pure push_existing owns gates / strcmp dedup / argv append; pool stays mega (static slots).
// PLATFORM: SHARED resolve face; Windows skips realpath (returns skip_missing path).
export extern "C" function invoke_cc_argv_resolve_existing_path(path: *u8): *u8;

// Cap residual (wave158): nm/marker probe for TLS backend objects (openssl/mbedtls).
export extern "C" function link_abi_obj_exports_marker(obj_o: *u8, marker: *u8): i32;

// Cap residual (wave146/158): POSIX realpath into caller buffer; Windows/fail → null.
export extern "C" function link_abi_realpath_cap(path: *u8, out: *u8): *u8;

// Cap residual (wave158): resolve rel path under argv0/repo_root (tls_openssl.o etc.).
export extern "C" function shux_rel_o_path_from_argv0(argv0: *u8, rel: *u8): *u8;

// Cap residual (wave187 ensure_std_net_o_auto_tls): host getenv / system shell make.
// PLATFORM: SHARED — mode SHUX_NET_TLS + make -C compiler net-o-*.
export extern "C" function getenv(name: *u8): *u8;
export extern "C" function system(cmd: *u8): i32;
export extern "C" function strcmp(a: *u8, b: *u8): i32;

/**
 * Push an existing .o path onto invoke_cc argv when the file is present.
 * Pure orch: null/capacity gates + Cap residual resolve (skip_missing + realpath pool)
 * + pure cstr-eq dedup over argv[0..*ia) + pure append of the durable path pointer.
 * @param argv **u8 — cc linker argv table (char**); null → 0
 * @param ia *i32 — in/out argv length; null → 0
 * @param max_ia i32 — argv capacity; need *ia < max_ia - 1 (room for NUL terminator)
 * @param path *u8 — candidate .o path; null/empty → 0
 * @return i32 — 1 if appended, 0 if skipped (missing / capacity / duplicate)
 * Cap residual: invoke_cc_argv_resolve_existing_path only (skip + multi-slot realpath pool).
 * Why (wave179): hybrid still had always-mega C body for push_existing (pool + dedup + append).
 * Dedup matches mega strcmp on the resolved-or-original use pointer (EXC-002 ld duplicate).
 * Note: null-check argv via cast to *u8 (do not write argv == 0 as **u8).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED — hybrid L6 pure; mega cold twin under #ifndef INVOKE_LD_LIST_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function invoke_cc_argv_push_existing(argv: **u8, ia: *i32, max_ia: i32, path: *u8): i32 {
  // Guard argv null via *u8 cast (wave147/151–158: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return 0;
  }
  if (ia == 0 as *i32) {
    return 0;
  }
  if (path == 0 as *u8) {
    return 0;
  }
  if (path[0] == 0) {
    return 0;
  }
  // Capacity: leave one slot for argv NULL terminator (≡ mega *ia >= max_ia - 1).
  let cur: i32 = ia[0];
  if (cur >= max_ia - 1) {
    return 0;
  }
  // Cap residual: skip missing + realpath into multi-slot pool (durable ptr for argv).
  let use: *u8 = 0 as *u8;
  unsafe {
    use = invoke_cc_argv_resolve_existing_path(path);
  }
  if (use == 0 as *u8) {
    return 0;
  }
  // Pure dedup: skip if any argv[k] is cstr-equal to use (≡ mega strcmp).
  let k: i32 = 0;
  while (k < cur) {
    let exist: *u8 = argv[k];
    if (exist != 0 as *u8) {
      let eq: i32 = 1;
      let i0: i32 = 0;
      while (i0 < 1048576) {
        let ca: u8 = exist[i0];
        let cb: u8 = use[i0];
        if (ca != cb) {
          eq = 0;
          break;
        }
        if (ca == 0) {
          break;
        }
        i0 = i0 + 1;
      }
      if (eq != 0) {
        return 0;
      }
    }
    k = k + 1;
  }
  // Append durable path pointer (no copy; pool / skip path lifetime covers spawn).
  argv[cur] = use;
  ia[0] = cur + 1;
  return 1;
}

/**
 * Homebrew /usr/local -L path table size (fixed catalog).
 * @return i32 — always 2 (homebrew + /usr/local)
 * PLATFORM: SHARED table; consumers gate with host_is_apple.
 */
#[no_mangle]
export function labi_ld_brew_lib_path_count(): i32 {
  return 2;
}

/** Exported function `labi_ld_brew_lib_path_at`.
 * Implements `labi_ld_brew_lib_path_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ld_brew_lib_path_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-L/opt/homebrew/lib";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-L/usr/local/lib";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_ld_flag_lz`.
 * Implements `labi_ld_flag_lz`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lz(): *u8 {
  let p: *u8 = "-lz";
  return p;
}

/** Exported function `labi_ld_flag_lzstd`.
 * Implements `labi_ld_flag_lzstd`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lzstd(): *u8 {
  let p: *u8 = "-lzstd";
  return p;
}

/** Exported function `labi_ld_flag_lbrotlienc`.
 * Implements `labi_ld_flag_lbrotlienc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lbrotlienc(): *u8 {
  let p: *u8 = "-lbrotlienc";
  return p;
}

/** Exported function `labi_ld_flag_lbrotlidec`.
 * Implements `labi_ld_flag_lbrotlidec`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lbrotlidec(): *u8 {
  let p: *u8 = "-lbrotlidec";
  return p;
}

/** Exported function `labi_ld_compress_flag_count`.
 * Implements `labi_ld_compress_flag_count`.
 * @return i32
 */
#[no_mangle]
export function labi_ld_compress_flag_count(): i32 {
  return 4;
}

/** Exported function `labi_ld_compress_flag_at`.
 * Implements `labi_ld_compress_flag_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ld_compress_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-lz";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-lzstd";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-lbrotlienc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-lbrotlidec";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_ld_flag_lm`.
 * Implements `labi_ld_flag_lm`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lm(): *u8 {
  let p: *u8 = "-lm";
  return p;
}

/** Exported function `labi_ld_flag_lsqlite3`.
 * Implements `labi_ld_flag_lsqlite3`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lsqlite3(): *u8 {
  let p: *u8 = "-lsqlite3";
  return p;
}

/** Exported function `labi_ld_flag_pthread`.
 * Read path helper `labi_ld_flag_pthread`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_pthread(): *u8 {
  let p: *u8 = "-pthread";
  return p;
}

/** Exported function `labi_ld_flag_lpthread`.
 * Read path helper `labi_ld_flag_lpthread`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lpthread(): *u8 {
  let p: *u8 = "-lpthread";
  return p;
}

/** Exported function `labi_ld_flag_ldl`.
 * Implements `labi_ld_flag_ldl`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_ldl(): *u8 {
  let p: *u8 = "-ldl";
  return p;
}

/** Exported function `labi_ld_flag_lc`.
 * Implements `labi_ld_flag_lc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lc(): *u8 {
  let p: *u8 = "-lc";
  return p;
}

/** Exported function `labi_ld_flag_lSystem`.
 * Implements `labi_ld_flag_lSystem`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lSystem(): *u8 {
  let p: *u8 = "-lSystem";
  return p;
}

/** Exported function `labi_ld_flag_lws2_32`.
 * Implements `labi_ld_flag_lws2_32`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lws2_32(): *u8 {
  let p: *u8 = "-lws2_32";
  return p;
}

/** Exported function `labi_ld_flag_lbcrypt`.
 * Implements `labi_ld_flag_lbcrypt`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_lbcrypt(): *u8 {
  let p: *u8 = "-lbcrypt";
  return p;
}

/**
 * Homebrew OpenSSL libdir -L flag (wave158 net_tls pure catalog).
 * @return *u8 — always "-L/opt/homebrew/opt/openssl/lib"
 * PLATFORM: SHARED string; consumers gate with link_abi_host_is_apple (≡ mega #if __APPLE__).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_ld_flag_L_hb_openssl(): *u8 {
  let p: *u8 = "-L/opt/homebrew/opt/openssl/lib";
  return p;
}

/**
 * Homebrew mbedTLS libdir -L flag (wave158 net_tls pure catalog).
 * @return *u8 — always "-L/opt/homebrew/opt/mbedtls/lib"
 * PLATFORM: SHARED string; consumers gate with link_abi_host_is_apple.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_ld_flag_L_hb_mbedtls(): *u8 {
  let p: *u8 = "-L/opt/homebrew/opt/mbedtls/lib";
  return p;
}

/**
 * OpenSSL link flag -lssl (wave158 net_tls pure catalog).
 * @return *u8 — always "-lssl"
 * PLATFORM: SHARED
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_ld_flag_lssl(): *u8 {
  let p: *u8 = "-lssl";
  return p;
}

/**
 * OpenSSL link flag -lcrypto (wave158 net_tls pure catalog).
 * @return *u8 — always "-lcrypto"
 * PLATFORM: SHARED
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_ld_flag_lcrypto(): *u8 {
  let p: *u8 = "-lcrypto";
  return p;
}

/**
 * mbedTLS link flag -lmbedtls (wave158 net_tls pure catalog).
 * @return *u8 — always "-lmbedtls"
 * PLATFORM: SHARED
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_ld_flag_lmbedtls(): *u8 {
  let p: *u8 = "-lmbedtls";
  return p;
}

/**
 * mbedTLS link flag -lmbedx509 (wave158 net_tls pure catalog).
 * @return *u8 — always "-lmbedx509"
 * PLATFORM: SHARED
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_ld_flag_lmbedx509(): *u8 {
  let p: *u8 = "-lmbedx509";
  return p;
}

/**
 * mbedTLS link flag -lmbedcrypto (wave158 net_tls pure catalog).
 * @return *u8 — always "-lmbedcrypto"
 * PLATFORM: SHARED
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_ld_flag_lmbedcrypto(): *u8 {
  let p: *u8 = "-lmbedcrypto";
  return p;
}

/**
 * TLS OpenSSL backend marker symbol name (wave158; Cap residual exports_marker needle).
 * @return *u8 — always "shu_net_tls_openssl_marker"
 * PLATFORM: SHARED — F-04 v8 marker in std/net/tls_openssl.o (not net.o).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_net_tls_openssl_marker(): *u8 {
  let p: *u8 = "shu_net_tls_openssl_marker";
  return p;
}

/**
 * TLS mbedTLS backend marker symbol name (wave158; Cap residual exports_marker needle).
 * @return *u8 — always "shu_net_tls_mbedtls_marker"
 * PLATFORM: SHARED — F-04 v9 marker in std/net/tls_mbedtls.o (not net.o).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_net_tls_mbedtls_marker(): *u8 {
  let p: *u8 = "shu_net_tls_mbedtls_marker";
  return p;
}

/**
 * Relative path for OpenSSL TLS .o under repo root (wave158 pure catalog).
 * @return *u8 — always "std/net/tls_openssl.o"
 * PLATFORM: SHARED
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_rel_tls_openssl_o(): *u8 {
  let p: *u8 = "std/net/tls_openssl.o";
  return p;
}

/**
 * Relative path for mbedTLS TLS .o under repo root (wave158 pure catalog).
 * @return *u8 — always "std/net/tls_mbedtls.o"
 * PLATFORM: SHARED
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_rel_tls_mbedtls_o(): *u8 {
  let p: *u8 = "std/net/tls_mbedtls.o";
  return p;
}

/**
 * Append OpenSSL -L (Apple homebrew only) + -lssl -lcrypto onto cc/ld argv.
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param i *i32 — in/out argv length; null → no-op
 * @param argv_cap i32 — capacity; leave one slot for NULL terminator
 * @return void — appends zero or more flags when capacity remains
 * Pure orch: pure flag_* + Cap residual link_abi_host_is_apple for -L gate (≡ mega #if __APPLE__).
 * Why (wave158): share openssl lib append between net_o and tls_openssl.o branches (G.7).
 * PLATFORM: SHARED orch / MACOS -L path only when host_is_apple.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_append_openssl_ld_flags(argv: **u8, i: *i32, argv_cap: i32): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (i == 0 as *i32) {
    return;
  }
  let is_apple: i32 = 0;
  unsafe {
    is_apple = link_abi_host_is_apple();
  }
  if (is_apple != 0) {
    let cur: i32 = i[0];
    if (cur < argv_cap - 1) {
      let fl: *u8 = labi_ld_flag_L_hb_openssl();
      argv[cur] = fl;
      i[0] = cur + 1;
    }
  }
  let cur2: i32 = i[0];
  if (cur2 < argv_cap - 1) {
    let fssl: *u8 = labi_ld_flag_lssl();
    argv[cur2] = fssl;
    i[0] = cur2 + 1;
  }
  let cur3: i32 = i[0];
  if (cur3 < argv_cap - 1) {
    let fcr: *u8 = labi_ld_flag_lcrypto();
    argv[cur3] = fcr;
    i[0] = cur3 + 1;
  }
}

/**
 * Append mbedTLS -L (Apple homebrew only) + -lmbedtls -lmbedx509 -lmbedcrypto onto cc/ld argv.
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param i *i32 — in/out argv length; null → no-op
 * @param argv_cap i32 — capacity; leave one slot for NULL terminator
 * @return void — appends zero or more flags when capacity remains
 * Pure orch: pure flag_* + Cap residual link_abi_host_is_apple for -L gate (≡ mega #if __APPLE__).
 * Why (wave158): share mbedtls lib append between net_o and tls_mbedtls.o branches (G.7).
 * PLATFORM: SHARED orch / MACOS -L path only when host_is_apple.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function labi_append_mbedtls_ld_flags(argv: **u8, i: *i32, argv_cap: i32): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (i == 0 as *i32) {
    return;
  }
  let is_apple: i32 = 0;
  unsafe {
    is_apple = link_abi_host_is_apple();
  }
  if (is_apple != 0) {
    let cur: i32 = i[0];
    if (cur < argv_cap - 1) {
      let fl: *u8 = labi_ld_flag_L_hb_mbedtls();
      argv[cur] = fl;
      i[0] = cur + 1;
    }
  }
  let cur2: i32 = i[0];
  if (cur2 < argv_cap - 1) {
    let fmb: *u8 = labi_ld_flag_lmbedtls();
    argv[cur2] = fmb;
    i[0] = cur2 + 1;
  }
  let cur3: i32 = i[0];
  if (cur3 < argv_cap - 1) {
    let fx: *u8 = labi_ld_flag_lmbedx509();
    argv[cur3] = fx;
    i[0] = cur3 + 1;
  }
  let cur4: i32 = i[0];
  if (cur4 < argv_cap - 1) {
    let fc: *u8 = labi_ld_flag_lmbedcrypto();
    argv[cur4] = fc;
    i[0] = cur4 + 1;
  }
}

/** Exported function `labi_ld_driver_clang`.
 * Implements `labi_ld_driver_clang`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_clang(): *u8 {
  let p: *u8 = "clang";
  return p;
}

/** Exported function `labi_ld_driver_ld`.
 * Implements `labi_ld_driver_ld`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_ld(): *u8 {
  let p: *u8 = "ld";
  return p;
}

/** Exported function `labi_ld_driver_gcc`.
 * Implements `labi_ld_driver_gcc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_gcc(): *u8 {
  let p: *u8 = "gcc";
  return p;
}

/** Exported function `labi_ld_driver_cc`.
 * Implements `labi_ld_driver_cc`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_driver_cc(): *u8 {
  let p: *u8 = "cc";
  return p;
}

/** Exported function `labi_ld_mach_entry_main`.
 * Implements `labi_ld_mach_entry_main`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_mach_entry_main(): *u8 {
  let p: *u8 = "_main";
  return p;
}

/** Exported function `labi_ld_flag_e`.
 * Implements `labi_ld_flag_e`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_e(): *u8 {
  let p: *u8 = "-e";
  return p;
}

/** Exported function `labi_ld_flag_o`.
 * Implements `labi_ld_flag_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_ld_flag_o(): *u8 {
  let p: *u8 = "-o";
  return p;
}

/** Exported function `labi_ld_common_tail_flag_count`.
 * Implements `labi_ld_common_tail_flag_count`.
 * @return i32
 */
#[no_mangle]
export function labi_ld_common_tail_flag_count(): i32 {
  return 7;
}

/** Exported function `labi_ld_common_tail_flag_at`.
 * Implements `labi_ld_common_tail_flag_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ld_common_tail_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-lm";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-lsqlite3";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-pthread";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-lpthread";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "-ldl";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "-lc";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "-lSystem";
    return p;
  }
  return 0 as *u8;
}

/**
 * Append Homebrew /usr/local -L paths onto an ld/cc argv (Apple hosts only).
 * Enables -lz / -lzstd / -lbrotli* resolution under brew prefixes without hardcoding
 * at each compress-lib append site.
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op
 * @param max_la i32 — argv capacity; need *la < max_la - 1 (room for NUL terminator)
 * @return void — no-op on non-Apple; skips null/empty table entries; stops when capacity full
 * Pure orch: Cap residual link_abi_host_is_apple + pure brew table count/at + append loop.
 * Cap residual: link_abi_host_is_apple (#if __APPLE__; all arch — not aarch64-only host_lit).
 * Why (wave152): hybrid still had always-mega C body for brew -L append (#if APPLE loop).
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch / MACOS consumers (Linux/Windows host_is_apple → 0 no-op).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function ld_append_brew_lib_paths(argv: **u8, la: *i32, max_la: i32): void {
  // Cap residual: only Apple hosts append -L brew paths (≡ mega #if defined(__APPLE__)).
  let apple: i32 = 0;
  unsafe {
    apple = link_abi_host_is_apple();
  }
  if (apple == 0) {
    return;
  }
  // Guard argv null via *u8 cast (wave147/151: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  let n: i32 = labi_ld_brew_lib_path_count();
  let k: i32 = 0;
  while (k < n) {
    // Capacity guard: leave one slot for argv NULL terminator (≡ mega max_la - 1).
    let cur: i32 = la[0];
    if (cur >= max_la - 1) {
      break;
    }
    let p: *u8 = labi_ld_brew_lib_path_at(k);
    k = k + 1;
    if (p == 0 as *u8) {
      continue;
    }
    if (p[0] == 0) {
      continue;
    }
    // Store table pointer (static string lifetime; no copy).
    argv[cur] = p;
    la[0] = cur + 1;
  }
}

/**
 * ASM ld: append -lz / -lzstd / -lbrotli* (and zlib glue .o) when compress_o or user_o needs them.
 * Gates each format via Cap residual / peer pure link_abi_obj_needs_*; brew -L via pure peer
 * ld_append_brew_lib_paths; flag strings via pure labi_ld_flag_*; zlib glue via Cap residual
 * ensure + path then direct argv append (asm path does not use invoke_cc_argv_push_existing).
 * @param compress_o *u8 — path to std/compress .o (nullable/empty → ignored by needs_*)
 * @param user_o *u8 — path to user main .o (nullable/empty → ignored by needs_*)
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op
 * @param max_la i32 — argv capacity; leave one slot for NULL terminator (max_la - 1)
 * @return void — appends only when a needs_* hits and capacity remains
 * Pure orch: needs_* Cap/peer + brew pure + flag pure + ensure/path Cap residual.
 * Cap residual: shux_ensure_runtime_compress_zlib_glue_o + shux_runtime_compress_zlib_glue_o_path;
 *   needs_* Cap (marker/has_undef) live under ondemand hybrid pure.
 * Why (wave153): hybrid still had always-mega C body for asm compress -l* append.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Sibling invoke_cc_append_compress_ld: wave154 pure orch (push_existing Cap residual for glue).
 * PLATFORM: SHARED — verify mac + Ubuntu compress neighborhood + prove IDENTICAL.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function asm_ld_append_compress_libs(compress_o: *u8, user_o: *u8, argv: **u8, la: *i32, max_la: i32): void {
  // Guard argv null via *u8 cast (wave147/151/152: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  let need_z: i32 = 0;
  let need_zs: i32 = 0;
  let need_br: i32 = 0;
  unsafe {
    need_z = link_abi_obj_needs_zlib(compress_o);
    if (need_z == 0) {
      need_z = link_abi_obj_needs_zlib(user_o);
    }
    need_zs = link_abi_obj_needs_zstd(compress_o);
    if (need_zs == 0) {
      need_zs = link_abi_obj_needs_zstd(user_o);
    }
    need_br = link_abi_obj_needs_brotli(compress_o);
    if (need_br == 0) {
      need_br = link_abi_obj_needs_brotli(user_o);
    }
  }
  if (need_z != 0) {
    // brew -L then -lz; ensure zlib macro-wrapper glue .o and append its path.
    ld_append_brew_lib_paths(argv, la, max_la);
    let cur: i32 = la[0];
    if (cur < max_la - 1) {
      let fl: *u8 = labi_ld_flag_lz();
      argv[cur] = fl;
      la[0] = cur + 1;
    }
    // Cap residual: build/ensure glue then resolve path (argv0 null ≡ mega NULL).
    unsafe {
      let _e: i32 = shux_ensure_runtime_compress_zlib_glue_o(0 as *u8);
    }
    let glue: *u8 = 0 as *u8;
    unsafe {
      glue = shux_runtime_compress_zlib_glue_o_path(0 as *u8);
    }
    if (glue != 0 as *u8) {
      if (glue[0] != 0) {
        let cur2: i32 = la[0];
        if (cur2 < max_la - 1) {
          argv[cur2] = glue;
          la[0] = cur2 + 1;
        }
      }
    }
  }
  if (need_zs != 0) {
    ld_append_brew_lib_paths(argv, la, max_la);
    let curz: i32 = la[0];
    if (curz < max_la - 1) {
      let flz: *u8 = labi_ld_flag_lzstd();
      argv[curz] = flz;
      la[0] = curz + 1;
    }
  }
  if (need_br != 0) {
    ld_append_brew_lib_paths(argv, la, max_la);
    let curb: i32 = la[0];
    if (curb < max_la - 1) {
      let fle: *u8 = labi_ld_flag_lbrotlienc();
      argv[curb] = fle;
      la[0] = curb + 1;
    }
    let curb2: i32 = la[0];
    if (curb2 < max_la - 1) {
      let fld: *u8 = labi_ld_flag_lbrotlidec();
      argv[curb2] = fld;
      la[0] = curb2 + 1;
    }
  }
}

/**
 * invoke_cc link: append -lz / -lzstd / -lbrotli* (and zlib glue .o) when compress_o or user_o needs them.
 * Same needs/brew/flag structure as asm_ld_append_compress_libs, but glue goes through Cap residual
 * invoke_cc_argv_push_existing (skip missing, realpath on POSIX, dedup) rather than direct argv store.
 * @param argv **u8 — cc linker argv table (char**); null → no-op
 * @param i *i32 — in/out argv length; null → no-op
 * @param argv_cap i32 — argv capacity; early exit if *i >= argv_cap - 1 (room for NUL terminator)
 * @param compress_o *u8 — path to std/compress .o (nullable/empty → ignored by needs_*)
 * @param user_o *u8 — path to user main .o (nullable/empty → ignored by needs_*)
 * @return void — appends only when a needs_* hits and capacity remains
 * Pure orch: needs_* Cap/peer + brew pure + flag pure + ensure/path Cap + pure push_existing.
 * Cap residual: push_existing resolve pool (wave179 Cap); ensure + path for glue;
 *   needs_* Cap (marker/has_undef) live under ondemand hybrid pure.
 * Why (wave154): hybrid still had always-mega C body for invoke_cc compress -l* append.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED — verify mac + Ubuntu compress neighborhood + prove IDENTICAL.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function invoke_cc_append_compress_ld(argv: **u8, i: *i32, argv_cap: i32, compress_o: *u8, user_o: *u8): void {
  // Guard argv null via *u8 cast (wave147/151–153: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (i == 0 as *i32) {
    return;
  }
  // Early capacity guard (≡ mega *i >= argv_cap - 1 at entry).
  if (i[0] >= argv_cap - 1) {
    return;
  }
  let need_z: i32 = 0;
  let need_zs: i32 = 0;
  let need_br: i32 = 0;
  unsafe {
    need_z = link_abi_obj_needs_zlib(compress_o);
    if (need_z == 0) {
      need_z = link_abi_obj_needs_zlib(user_o);
    }
    need_zs = link_abi_obj_needs_zstd(compress_o);
    if (need_zs == 0) {
      need_zs = link_abi_obj_needs_zstd(user_o);
    }
    need_br = link_abi_obj_needs_brotli(compress_o);
    if (need_br == 0) {
      need_br = link_abi_obj_needs_brotli(user_o);
    }
  }
  if (need_z != 0) {
    // brew -L then -lz; ensure zlib glue .o and push via pure push_existing (wave179).
    ld_append_brew_lib_paths(argv, i, argv_cap);
    let cur: i32 = i[0];
    if (cur < argv_cap - 1) {
      let fl: *u8 = labi_ld_flag_lz();
      argv[cur] = fl;
      i[0] = cur + 1;
    }
    // Cap residual: build/ensure glue then push path (argv0 null ≡ mega NULL).
    unsafe {
      let _e: i32 = shux_ensure_runtime_compress_zlib_glue_o(0 as *u8);
    }
    let glue: *u8 = 0 as *u8;
    unsafe {
      glue = shux_runtime_compress_zlib_glue_o_path(0 as *u8);
    }
    // Pure peer wave179: skip-missing / realpath / dedup (asm path stores path bytes directly).
    let _p: i32 = invoke_cc_argv_push_existing(argv, i, argv_cap, glue);
  }
  if (need_zs != 0) {
    ld_append_brew_lib_paths(argv, i, argv_cap);
    let curz: i32 = i[0];
    if (curz < argv_cap - 1) {
      let flz: *u8 = labi_ld_flag_lzstd();
      argv[curz] = flz;
      i[0] = curz + 1;
    }
  }
  if (need_br != 0) {
    ld_append_brew_lib_paths(argv, i, argv_cap);
    let curb: i32 = i[0];
    if (curb < argv_cap - 1) {
      let fle: *u8 = labi_ld_flag_lbrotlienc();
      argv[curb] = fle;
      i[0] = curb + 1;
    }
    let curb2: i32 = i[0];
    if (curb2 < argv_cap - 1) {
      let fld: *u8 = labi_ld_flag_lbrotlidec();
      argv[curb2] = fld;
      i[0] = curb2 + 1;
    }
  }
}

/**
 * macOS asm ld/clang: append tail -l* from ShuAsmLdStdLinkFlags (math/compress/sqlite/pthread/System).
 * Pure orch over LP64 i32 flag layout + pure labi_ld_flag_* + peer asm_ld_append_compress_libs
 * + peer link_abi_user_o_needs_compress_libs. Gate shux_asm_ld_append_mach_tail_libs stays L9 thin.
 * @param compress_o *u8 — path to std/compress .o (nullable/empty → ignored by needs_*)
 * @param user_o *u8 — path to user main .o (nullable/empty → ignored by needs_*)
 * @param flags *u8 — ShuAsmLdStdLinkFlags* as opaque bytes; null → no-op
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op; *la < 0 → no-op
 * @param max_la i32 — argv capacity; leave one slot for NULL terminator (max_la - 1)
 * @param append_lsystem i32 — non-zero → also append -lSystem (clang driver path often skips)
 * @return void — appends zero or more tail flags; compress may expand multi -l* via peer orch
 * Flag layout (PLATFORM: SHARED LP64 int fields, declaration order ≡ runtime_link_abi.h):
 *   0=have_io 1=have_net 2=have_thread 3=have_sync 4=have_channel
 *   5=have_math 6=have_compress 7=have_dynlib 8=have_sqlite
 *   9=have_elf 10=have_libc_heap 11=have_fs
 * need_pt = have_thread || have_sync || have_channel (≡ mega).
 * Why (wave156): hybrid still had always-mega C body for mach tail -l* over pure flag tables.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Callers: pure gate shux_asm_ld_append_mach_tail_libs (labi_gates) + product asm ld paths.
 * PLATFORM: SHARED orch / MACOS consumers (flags semantics shared; -lSystem is Darwin).
 * Track-L: #[no_mangle] keeps surface short name matching mega / gates Cap residual extern.
 */
#[no_mangle]
export function shux_asm_ld_append_mach_tail_libs_impl(compress_o: *u8, user_o: *u8, flags: *u8, argv: **u8, la: *i32, max_la: i32, append_lsystem: i32): void {
  // Guard nulls via *u8 cast (wave147/151–155: avoid **u8 null compare codegen drop).
  if (flags == 0 as *u8) {
    return;
  }
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  if (la[0] < 0) {
    return;
  }
  // LP64 shared: flags is contiguous i32 fields (ShuAsmLdStdLinkFlags).
  let f: *i32 = flags as *i32;
  let have_thread: i32 = f[2];
  let have_sync: i32 = f[3];
  let have_channel: i32 = f[4];
  let have_math: i32 = f[5];
  let have_compress: i32 = f[6];
  let have_sqlite: i32 = f[8];
  // need_pt ≡ mega: thread | sync | channel.
  let need_pt: i32 = 0;
  if (have_thread != 0) {
    need_pt = 1;
  }
  if (have_sync != 0) {
    need_pt = 1;
  }
  if (have_channel != 0) {
    need_pt = 1;
  }
  // -lm when math std linked.
  if (have_math != 0) {
    let cur: i32 = la[0];
    if (cur < max_la - 1) {
      let fl: *u8 = labi_ld_flag_lm();
      argv[cur] = fl;
      la[0] = cur + 1;
    }
  }
  // compress -l* when flag set or user.o UNDEF needs compress (peer pure aggregate).
  let need_comp: i32 = have_compress;
  if (need_comp == 0) {
    unsafe {
      need_comp = link_abi_user_o_needs_compress_libs(user_o);
    }
  }
  if (need_comp != 0) {
    asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
  }
  // -lsqlite3 when sqlite std linked.
  if (have_sqlite != 0) {
    let curs: i32 = la[0];
    if (curs < max_la - 1) {
      let fs: *u8 = labi_ld_flag_lsqlite3();
      argv[curs] = fs;
      la[0] = curs + 1;
    }
  }
  // -pthread when thread/sync/channel.
  if (need_pt != 0) {
    let curp: i32 = la[0];
    if (curp < max_la - 1) {
      let fp: *u8 = labi_ld_flag_pthread();
      argv[curp] = fp;
      la[0] = curp + 1;
    }
  }
  // -lSystem optional (clang as driver often pulls System; bare ld may need it).
  if (append_lsystem != 0) {
    let curl: i32 = la[0];
    if (curl < max_la - 1) {
      let fsys: *u8 = labi_ld_flag_lSystem();
      argv[curl] = fsys;
      la[0] = curl + 1;
    }
  }
}

/**
 * Linux/Unix gcc or bare ld: append tail -l* from ShuAsmLdStdLinkFlags + need_pt.
 * Pure orch over LP64 i32 flag layout + pure labi_ld_flag_* + peer compress orch
 * + peer needs_compress + peer shux_host_is_linux + Cap residual host_is_apple.
 * Gate shux_asm_ld_append_unix_gcc_tail_libs stays L9 thin.
 * @param compress_o *u8 — path to std/compress .o (nullable/empty → ignored by needs_*)
 * @param user_o *u8 — path to user main .o (nullable/empty → ignored by needs_*)
 * @param flags *u8 — ShuAsmLdStdLinkFlags* as opaque bytes; null → no-op
 * @param need_pt i32 — non-zero when thread|sync|channel (caller-derived; ≡ mega)
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op; *la < 0 → no-op
 * @param max_la i32 — argv capacity; leave one slot for NULL terminator (max_la - 1)
 * @return void — appends zero or more tail flags; compress may expand multi -l*
 * Flag layout (PLATFORM: SHARED LP64 int fields ≡ runtime_link_abi.h):
 *   0=have_io 1=have_net 2=have_thread 3=have_sync 4=have_channel
 *   5=have_math 6=have_compress 7=have_dynlib 8=have_sqlite
 *   9=have_elf 10=have_libc_heap 11=have_fs
 * pthread selection (≡ mega branches):
 *   have_io && need_pt → -pthread; !have_io && need_pt → -lpthread; else no pthread flag
 * -ldl only when host linux && have_dynlib (mega #if __linux__).
 * -lc always when have_io || have_net || need_pt; else only on linux|apple when any of
 *   heap|fs|math|compress|sqlite|dynlib (mega #if linux||apple in final else).
 * Why (wave157): hybrid still had always-mega C body for unix gcc tail -l* over pure tables.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Callers: pure gate shux_asm_ld_append_unix_gcc_tail_libs (labi_gates) + product asm ld paths.
 * PLATFORM: SHARED orch / LINUX primary consumers (Unix gcc/ld; -ldl Linux-only).
 * Track-L: #[no_mangle] keeps surface short name matching mega / gates Cap residual extern.
 */
#[no_mangle]
export function shux_asm_ld_append_unix_gcc_tail_libs_impl(compress_o: *u8, user_o: *u8, flags: *u8, need_pt: i32, argv: **u8, la: *i32, max_la: i32): void {
  // Guard nulls via *u8 cast (wave147/151–156: avoid **u8 null compare codegen drop).
  if (flags == 0 as *u8) {
    return;
  }
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  if (la[0] < 0) {
    return;
  }
  // LP64 shared: flags is contiguous i32 fields (ShuAsmLdStdLinkFlags).
  let f: *i32 = flags as *i32;
  let have_io: i32 = f[0];
  let have_net: i32 = f[1];
  let have_math: i32 = f[5];
  let have_compress: i32 = f[6];
  let have_dynlib: i32 = f[7];
  let have_sqlite: i32 = f[8];
  let have_libc_heap: i32 = f[10];
  let have_fs: i32 = f[11];
  // pthread: have_io uses -pthread; net/need_pt alone uses -lpthread (≡ mega).
  if (have_io != 0) {
    if (need_pt != 0) {
      let cur0: i32 = la[0];
      if (cur0 < max_la - 1) {
        let fp0: *u8 = labi_ld_flag_pthread();
        argv[cur0] = fp0;
        la[0] = cur0 + 1;
      }
    }
  } else {
    if (need_pt != 0) {
      let cur1: i32 = la[0];
      if (cur1 < max_la - 1) {
        let fp1: *u8 = labi_ld_flag_lpthread();
        argv[cur1] = fp1;
        la[0] = cur1 + 1;
      }
    }
  }
  // -lm when math std linked (all branches).
  if (have_math != 0) {
    let curm: i32 = la[0];
    if (curm < max_la - 1) {
      let fm: *u8 = labi_ld_flag_lm();
      argv[curm] = fm;
      la[0] = curm + 1;
    }
  }
  // compress -l* when flag set or user.o UNDEF needs compress (peer pure aggregate).
  let need_comp: i32 = have_compress;
  if (need_comp == 0) {
    unsafe {
      need_comp = link_abi_user_o_needs_compress_libs(user_o);
    }
  }
  if (need_comp != 0) {
    asm_ld_append_compress_libs(compress_o, user_o, argv, la, max_la);
  }
  // -lsqlite3 when sqlite std linked.
  if (have_sqlite != 0) {
    let curs: i32 = la[0];
    if (curs < max_la - 1) {
      let fs: *u8 = labi_ld_flag_lsqlite3();
      argv[curs] = fs;
      la[0] = curs + 1;
    }
  }
  // -ldl only on Linux when dynlib (mega #if __linux__; peer pure host_is_linux).
  if (have_dynlib != 0) {
    let is_linux: i32 = 0;
    unsafe {
      is_linux = shux_host_is_linux();
    }
    if (is_linux != 0) {
      let curd: i32 = la[0];
      if (curd < max_la - 1) {
        let fd: *u8 = labi_ld_flag_ldl();
        argv[curd] = fd;
        la[0] = curd + 1;
      }
    }
  }
  // -lc: always when io/net/need_pt (mega branches 1–4); else conditional (branch 5).
  let always_lc: i32 = 0;
  if (have_io != 0) {
    always_lc = 1;
  }
  if (have_net != 0) {
    always_lc = 1;
  }
  if (need_pt != 0) {
    always_lc = 1;
  }
  if (always_lc != 0) {
    let curc: i32 = la[0];
    if (curc < max_la - 1) {
      let fc: *u8 = labi_ld_flag_lc();
      argv[curc] = fc;
      la[0] = curc + 1;
    }
  } else {
    // Final else: -lc only on linux|apple when any of heap/fs/math/compress/sqlite/dynlib.
    let want_lc: i32 = 0;
    if (have_libc_heap != 0) {
      want_lc = 1;
    }
    if (have_fs != 0) {
      want_lc = 1;
    }
    if (have_math != 0) {
      want_lc = 1;
    }
    if (have_compress != 0) {
      want_lc = 1;
    }
    if (have_sqlite != 0) {
      want_lc = 1;
    }
    if (have_dynlib != 0) {
      want_lc = 1;
    }
    if (want_lc != 0) {
      let is_linux2: i32 = 0;
      let is_apple: i32 = 0;
      unsafe {
        is_linux2 = shux_host_is_linux();
        is_apple = link_abi_host_is_apple();
      }
      if (is_linux2 != 0 || is_apple != 0) {
        let curc2: i32 = la[0];
        if (curc2 < max_la - 1) {
          let fc2: *u8 = labi_ld_flag_lc();
          argv[curc2] = fc2;
          la[0] = curc2 + 1;
        }
      }
    }
  }
}

/**
 * invoke_cc link: append OpenSSL or mbedTLS -L/-l when net.o or std/net/tls_*.o exports TLS markers.
 * F-04 v8/v9: markers live in tls_openssl.o / tls_mbedtls.o (not compiled into net.o).
 * @param argv **u8 — cc linker argv table (char**); null → return 0
 * @param i *i32 — in/out argv length; null → return 0
 * @param argv_cap i32 — capacity; early exit if *i >= argv_cap - 1
 * @param net_o *u8 — path to std/net .o (nullable/empty → skip net_o marker phase)
 * @param repo_root *u8 — repo root for rel resolve of tls_*.o (nullable/empty → skip phase 2)
 * @return i32 — 1 if TLS libs were appended, 0 otherwise
 * Pure orch: pure marker/rel/flag catalogs + peer labi_append_{openssl,mbedtls}_ld_flags.
 * Cap residual: link_abi_obj_exports_marker; link_abi_realpath_cap (POSIX; Windows null ≡ mega);
 *   shux_rel_o_path_from_argv0; invoke_cc_argv_push_existing (tls_*.o only, not net_o).
 * Why (wave158): hybrid still had always-mega C body for net_tls -L/-l append.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Sibling ensure_std_net_o_auto_tls pure at wave187 (Cap residual getenv+system still).
 * PLATFORM: SHARED orch / MACOS brew -L gated by host_is_apple inside append_* helpers.
 * Track-L: #[no_mangle] keeps surface short name matching mega / thin callers.
 */
#[no_mangle]
export function invoke_cc_append_net_tls_ld(argv: **u8, i: *i32, argv_cap: i32, net_o: *u8, repo_root: *u8): i32 {
  // Guard argv null via *u8 cast (wave147/151–157: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return 0;
  }
  if (i == 0 as *i32) {
    return 0;
  }
  // Early capacity guard (≡ mega *i >= argv_cap - 1 at entry).
  if (i[0] >= argv_cap - 1) {
    return 0;
  }
  let mk_ssl: *u8 = labi_net_tls_openssl_marker();
  let mk_mb: *u8 = labi_net_tls_mbedtls_marker();
  // Phase 1: probe net_o for legacy co-located markers (rare post F-04 v8).
  if (net_o != 0 as *u8) {
    if (net_o[0] != 0) {
      let use: *u8 = net_o;
      // Cap residual realpath; on fail keep original path (≡ mega #if !WIN32 realpath).
      let abs_n: u8[4096] = [];
      let rn: *u8 = 0 as *u8;
      unsafe {
        rn = link_abi_realpath_cap(net_o, &abs_n[0]);
      }
      if (rn != 0 as *u8) {
        use = rn;
      }
      let hit_ssl: i32 = 0;
      unsafe {
        hit_ssl = link_abi_obj_exports_marker(use, mk_ssl);
      }
      if (hit_ssl != 0) {
        labi_append_openssl_ld_flags(argv, i, argv_cap);
        return 1;
      }
      let hit_mb: i32 = 0;
      unsafe {
        hit_mb = link_abi_obj_exports_marker(use, mk_mb);
      }
      if (hit_mb != 0) {
        labi_append_mbedtls_ld_flags(argv, i, argv_cap);
        return 1;
      }
    }
  }
  // Phase 2: resolve std/net/tls_*.o under repo_root and push .o + libs on marker.
  if (repo_root == 0 as *u8) {
    return 0;
  }
  if (repo_root[0] == 0) {
    return 0;
  }
  let rel_ssl: *u8 = labi_rel_tls_openssl_o();
  let tls_ssl: *u8 = 0 as *u8;
  unsafe {
    tls_ssl = shux_rel_o_path_from_argv0(repo_root, rel_ssl);
  }
  if (tls_ssl != 0 as *u8) {
    if (tls_ssl[0] != 0) {
      let use2: *u8 = tls_ssl;
      let abs_s: u8[4096] = [];
      let rs: *u8 = 0 as *u8;
      unsafe {
        rs = link_abi_realpath_cap(tls_ssl, &abs_s[0]);
      }
      if (rs != 0 as *u8) {
        use2 = rs;
      }
      let hit2: i32 = 0;
      unsafe {
        hit2 = link_abi_obj_exports_marker(use2, mk_ssl);
      }
      if (hit2 != 0) {
        // Pure peer wave179: skip-missing / realpath / dedup for the .o path itself.
        let _p: i32 = invoke_cc_argv_push_existing(argv, i, argv_cap, tls_ssl);
        labi_append_openssl_ld_flags(argv, i, argv_cap);
        return 1;
      }
    }
  }
  let rel_mb: *u8 = labi_rel_tls_mbedtls_o();
  let tls_mb: *u8 = 0 as *u8;
  unsafe {
    tls_mb = shux_rel_o_path_from_argv0(repo_root, rel_mb);
  }
  if (tls_mb != 0 as *u8) {
    if (tls_mb[0] != 0) {
      let use3: *u8 = tls_mb;
      let abs_m: u8[4096] = [];
      let rm: *u8 = 0 as *u8;
      unsafe {
        rm = link_abi_realpath_cap(tls_mb, &abs_m[0]);
      }
      if (rm != 0 as *u8) {
        use3 = rm;
      }
      let hit3: i32 = 0;
      unsafe {
        hit3 = link_abi_obj_exports_marker(use3, mk_mb);
      }
      if (hit3 != 0) {
        // Pure peer wave179: skip-missing / realpath / dedup for the .o path itself.
        let _p2: i32 = invoke_cc_argv_push_existing(argv, i, argv_cap, tls_mb);
        labi_append_mbedtls_ld_flags(argv, i, argv_cap);
        return 1;
      }
    }
  }
  return 0;
}

/**
 * Append bytes of `src` onto `dst` starting at `pos` (NUL-terminated result).
 * Pure helper for ensure_std_net_o_auto_tls shell/path buffers (wave187).
 * @param dst *u8 — destination buffer
 * @param cap i32 — capacity including trailing NUL
 * @param pos i32 — current write index (0..cap-1)
 * @param src *u8 — source C string; null treated as empty
 * @return i32 — new pos after append, or -1 if capacity would overflow
 * Track-L: #[no_mangle] keeps surface short name for prove IDENTICAL.
 */
#[no_mangle]
export function labi_net_tls_buf_append(dst: *u8, cap: i32, pos: i32, src: *u8): i32 {
  if (dst == 0 as *u8) {
    return 0 - 1;
  }
  if (pos < 0) {
    return 0 - 1;
  }
  if (pos >= cap) {
    return 0 - 1;
  }
  let i: i32 = 0;
  if (src == 0 as *u8) {
    dst[pos as usize] = 0;
    return pos;
  }
  while (1 == 1) {
    let c: u8 = src[i as usize];
    if (c == 0) {
      break;
    }
    if (pos + 1 >= cap) {
      dst[pos as usize] = 0;
      return 0 - 1;
    }
    dst[pos as usize] = c;
    pos = pos + 1;
    i = i + 1;
  }
  dst[pos as usize] = 0;
  return pos;
}

/**
 * Build `make -C '<repo>/compiler' <target> >/dev/null 2>&1` into `cmd` (cap 640).
 * @param cmd *u8 — destination shell buffer
 * @param cap i32 — capacity (use 640 ≡ mega)
 * @param repo_root *u8 — absolute repo root (already non-empty)
 * @param target *u8 — make target (e.g. net-o-openssl)
 * @return i32 — 1 on success, 0 on overflow
 * Track-L: #[no_mangle] keeps surface short name for prove IDENTICAL.
 */
#[no_mangle]
export function labi_net_tls_build_make_cmd(cmd: *u8, cap: i32, repo_root: *u8, target: *u8): i32 {
  let pos: i32 = 0;
  // Prefix: make -C '
  pos = labi_net_tls_buf_append(cmd, cap, pos, "make -C '");
  if (pos < 0) {
    return 0;
  }
  pos = labi_net_tls_buf_append(cmd, cap, pos, repo_root);
  if (pos < 0) {
    return 0;
  }
  // '/compiler' <target> >/dev/null 2>&1
  pos = labi_net_tls_buf_append(cmd, cap, pos, "'/compiler' ");
  if (pos < 0) {
    return 0;
  }
  pos = labi_net_tls_buf_append(cmd, cap, pos, target);
  if (pos < 0) {
    return 0;
  }
  pos = labi_net_tls_buf_append(cmd, cap, pos, " >/dev/null 2>&1");
  if (pos < 0) {
    return 0;
  }
  return 1;
}

/**
 * Join repo_root + '/' + rel into path_buf (pure byte join; no realpath).
 * @param path_buf *u8 — destination
 * @param cap i32 — capacity
 * @param repo_root *u8 — absolute root
 * @param rel *u8 — relative under root (e.g. std/net/tls_openssl.o)
 * @return i32 — 1 success, 0 overflow/null
 * Track-L: #[no_mangle] keeps surface short name for prove IDENTICAL.
 */
#[no_mangle]
export function labi_net_tls_join_repo_rel(path_buf: *u8, cap: i32, repo_root: *u8, rel: *u8): i32 {
  let pos: i32 = 0;
  pos = labi_net_tls_buf_append(path_buf, cap, pos, repo_root);
  if (pos < 0) {
    return 0;
  }
  pos = labi_net_tls_buf_append(path_buf, cap, pos, "/");
  if (pos < 0) {
    return 0;
  }
  pos = labi_net_tls_buf_append(path_buf, cap, pos, rel);
  if (pos < 0) {
    return 0;
  }
  return 1;
}

/**
 * If SHUX_NET_TLS is set and net/tls objects still lack real TLS markers, run
 * `make -C <repo>/compiler net-o-{stub,openssl,mbedtls}` (system shell Cap residual).
 * F-04 v8: OpenSSL/mbedTLS markers live in std/net/tls_*.o (not compiled into net.o).
 * Modes: stub | openssl | mbedtls | auto (default when mode string is "auto").
 * Empty/unset SHUX_NET_TLS → no-op (≡ mega).
 * @param repo_root *u8 — absolute repository root; null/empty → no-op
 * @return void — best-effort make; marker short-circuit when already built
 * Pure orch: mode strcmp + pure path join + pure make-cmd join.
 * Cap residual: getenv (SHUX_NET_TLS); system(make); link_abi_realpath_cap;
 *   link_abi_obj_exports_marker (nm/marker probe).
 * Why (wave187): hybrid still had always-mega C body for auto TLS ensure orch
 *   (getenv + marker probe + system make). Soft residual after wave158 net_tls ld append.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * PLATFORM: SHARED orch — system/make is host shell (LINUX/MACOS product hosts).
 * Track-L: #[no_mangle] keeps surface short name for invoke_cc_impl call sites.
 */
#[no_mangle]
export function ensure_std_net_o_auto_tls(repo_root: *u8): void {
  if (repo_root == 0 as *u8) {
    return;
  }
  if (repo_root[0] == 0) {
    return;
  }
  // Cap residual: mode from env; empty/unset → no rebuild.
  let mode: *u8 = 0 as *u8;
  unsafe {
    mode = getenv("SHUX_NET_TLS");
  }
  if (mode == 0 as *u8) {
    return;
  }
  if (mode[0] == 0) {
    return;
  }
  let cmd: u8[640] = [];
  let path_buf: u8[4096] = [];
  let resolved: u8[4096] = [];
  let mk_ssl: *u8 = labi_net_tls_openssl_marker();
  let mk_mb: *u8 = labi_net_tls_mbedtls_marker();
  // stub: always force make net-o-stub (≡ mega).
  let eq_stub: i32 = 0;
  unsafe {
    eq_stub = strcmp(mode, "stub");
  }
  if (eq_stub == 0) {
    let ok: i32 = labi_net_tls_build_make_cmd(&cmd[0], 640, repo_root, "net-o-stub");
    if (ok != 0) {
      unsafe {
        let _s: i32 = system(&cmd[0]);
      }
    }
    return;
  }
  // Already have OpenSSL marker object under repo? short-circuit.
  let j1: i32 = labi_net_tls_join_repo_rel(&path_buf[0], 4096, repo_root, "std/net/tls_openssl.o");
  if (j1 != 0) {
    let rp1: *u8 = 0 as *u8;
    unsafe {
      rp1 = link_abi_realpath_cap(&path_buf[0], &resolved[0]);
    }
    if (rp1 != 0 as *u8) {
      let hit1: i32 = 0;
      unsafe {
        hit1 = link_abi_obj_exports_marker(rp1, mk_ssl);
      }
      if (hit1 != 0) {
        return;
      }
    }
  }
  // Already have mbedTLS marker object?
  let j2: i32 = labi_net_tls_join_repo_rel(&path_buf[0], 4096, repo_root, "std/net/tls_mbedtls.o");
  if (j2 != 0) {
    let rp2: *u8 = 0 as *u8;
    unsafe {
      rp2 = link_abi_realpath_cap(&path_buf[0], &resolved[0]);
    }
    if (rp2 != 0 as *u8) {
      let hit2: i32 = 0;
      unsafe {
        hit2 = link_abi_obj_exports_marker(rp2, mk_mb);
      }
      if (hit2 != 0) {
        return;
      }
    }
  }
  // Legacy: markers co-located in net.o (pre F-04 v8 rare path).
  // Try repo/std/net/net.o then cwd std/net/net.o (≡ mega realpath pair).
  resolved[0] = 0;
  let j3: i32 = labi_net_tls_join_repo_rel(&path_buf[0], 4096, repo_root, "std/net/net.o");
  if (j3 != 0) {
    let rp3: *u8 = 0 as *u8;
    unsafe {
      rp3 = link_abi_realpath_cap(&path_buf[0], &resolved[0]);
    }
    if (rp3 == 0 as *u8) {
      // Fallback: cwd-relative std/net/net.o
      unsafe {
        rp3 = link_abi_realpath_cap("std/net/net.o", &resolved[0]);
      }
    }
    if (rp3 != 0 as *u8) {
      let hit_s: i32 = 0;
      let hit_m: i32 = 0;
      unsafe {
        hit_s = link_abi_obj_exports_marker(rp3, mk_ssl);
        hit_m = link_abi_obj_exports_marker(rp3, mk_mb);
      }
      if (hit_s != 0) {
        return;
      }
      if (hit_m != 0) {
        return;
      }
    }
  }
  // Mode openssl: only openssl make.
  let eq_ssl: i32 = 0;
  unsafe {
    eq_ssl = strcmp(mode, "openssl");
  }
  if (eq_ssl == 0) {
    let ok2: i32 = labi_net_tls_build_make_cmd(&cmd[0], 640, repo_root, "net-o-openssl");
    if (ok2 != 0) {
      unsafe {
        let _s2: i32 = system(&cmd[0]);
      }
    }
    return;
  }
  // Mode mbedtls: only mbedtls make.
  let eq_mb: i32 = 0;
  unsafe {
    eq_mb = strcmp(mode, "mbedtls");
  }
  if (eq_mb == 0) {
    let ok3: i32 = labi_net_tls_build_make_cmd(&cmd[0], 640, repo_root, "net-o-mbedtls");
    if (ok3 != 0) {
      unsafe {
        let _s3: i32 = system(&cmd[0]);
      }
    }
    return;
  }
  // auto: try openssl then mbedtls on failure (≡ mega system != 0).
  let eq_auto: i32 = 0;
  unsafe {
    eq_auto = strcmp(mode, "auto");
  }
  if (eq_auto != 0) {
    return;
  }
  let ok4: i32 = labi_net_tls_build_make_cmd(&cmd[0], 640, repo_root, "net-o-openssl");
  if (ok4 != 0) {
    let rc: i32 = 0;
    unsafe {
      rc = system(&cmd[0]);
    }
    if (rc != 0) {
      let ok5: i32 = labi_net_tls_build_make_cmd(&cmd[0], 640, repo_root, "net-o-mbedtls");
      if (ok5 != 0) {
        unsafe {
          let _s5: i32 = system(&cmd[0]);
        }
      }
    }
  }
}
