// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-273 / P2 link_abi L4 ensure catalog pure table + special ensure orch.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_ensure_list.from_x.c.
// Hybrid macro SHUX_LABI_ENSURE_LIST_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: ensure catalog tables (stem/out_base/seed_base/flags/step_at) +
//   wave169 shux_ensure_runtime_panic_o pure orch
//     (peer panic_o_path + Cap residual resolve/access/cc/stat + host #if prefer).
// Cap residual: link_abi_ensure_from_catalog spawn/cc still mega; resolve/access/cc/stat
//   + host linux_x86_64 / posix_aarch64 for panic ensure leaf (wave169).
// PLATFORM: SHARED tables / orch; LINUX x86_64 asm prefer; POSIX aarch64 arm64 seed.

// Cap residual (wave169 ensure_runtime_panic pure orch): resolve / access / cc / skip-stat.
export extern "C" function shu_resolve_compiler_dir(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32;
export extern "C" function link_abi_path_readable(path: *u8): i32;
export extern "C" function shux_cc_compile_sync(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32): i32;
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
// Cap residual host #if (mega; ≡ ensure_runtime_panic source gates).
export extern "C" function link_abi_host_is_linux_x86_64(): i32;
export extern "C" function link_abi_host_is_posix_aarch64(): i32;
// Peer pure path ladder (labi_path_pure L0; wave163).
export extern "C" function shux_runtime_panic_o_path(argv0: *u8): *u8;
// Peer pure diags (labi_diag_pure L1).
export extern "C" function link_diag_runtime_obj_resolve_fail(obj_name: *u8, hint: *u8): void;
export extern "C" function link_diag_runtime_source_missing_under(obj_name: *u8, base_dir: *u8, suffix: *u8): void;
export extern "C" function link_diag_runtime_obj_build_status(obj_name: *u8, status: i32): void;
export extern "C" function link_diag_runtime_obj_missing(obj_name: *u8, out_o: *u8): void;

// labi_ensure_catalog_count: see function docblock below.

/** Exported function `labi_ensure_catalog_count`.
 * Implements `labi_ensure_catalog_count`.
 * @return i32
 */
#[no_mangle]
export function labi_ensure_catalog_count(): i32 {
  return 26;
}

/** Exported function `labi_ensure_catalog_stem`.
 * Implements `labi_ensure_catalog_stem`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ensure_catalog_stem(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "runtime_asm_io_stubs";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "runtime_process_argv";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "runtime_process_os_glue";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "runtime_random_fill";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "runtime_compress_zlib_glue";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "runtime_time_os";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "runtime_queue_contention";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "runtime_dynlib_os";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "runtime_env_os";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "runtime_backtrace_platform";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "runtime_log_os";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "runtime_math_libm";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "runtime_atomic_glue";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "runtime_channel_glue";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "runtime_net_udp_batch";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "runtime_net_workers";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "runtime_sync_os";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "runtime_sync_lock_diag_tls";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "runtime_thread_glue";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "runtime_scheduler_glue";
    return p;
  }
  if (i == 20) {
    let p: *u8 = "runtime_http_glue";
    return p;
  }
  if (i == 21) {
    let p: *u8 = "runtime_kv_mmap_glue";
    return p;
  }
  if (i == 22) {
    let p: *u8 = "runtime_arrow_simd_glue";
    return p;
  }
  if (i == 23) {
    let p: *u8 = "runtime_sqlite_glue";
    return p;
  }
  if (i == 24) {
    let p: *u8 = "runtime_crypto_inc_glue";
    return p;
  }
  if (i == 25) {
    let p: *u8 = "runtime_ed25519_ref10_glue";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_ensure_catalog_out_base`.
 * Implements `labi_ensure_catalog_out_base`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ensure_catalog_out_base(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "runtime_asm_io_stubs.o";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "runtime_process_argv.o";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "runtime_process_os_glue.o";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "runtime_random_fill.o";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "runtime_compress_zlib_glue.o";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "runtime_time_os.o";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "runtime_queue_contention.o";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "runtime_dynlib_os.o";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "runtime_env_os.o";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "runtime_backtrace_platform.o";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "runtime_log_os.o";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "runtime_math_libm.o";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "runtime_atomic_glue.o";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "runtime_channel_glue.o";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "runtime_net_udp_batch.o";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "runtime_net_workers.o";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "runtime_sync_os.o";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "runtime_sync_lock_diag_tls.o";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "runtime_thread_glue.o";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "runtime_scheduler_glue.o";
    return p;
  }
  if (i == 20) {
    let p: *u8 = "runtime_http_glue.o";
    return p;
  }
  if (i == 21) {
    let p: *u8 = "runtime_kv_mmap_glue.o";
    return p;
  }
  if (i == 22) {
    let p: *u8 = "runtime_arrow_simd_glue.o";
    return p;
  }
  if (i == 23) {
    let p: *u8 = "runtime_sqlite_glue.o";
    return p;
  }
  if (i == 24) {
    let p: *u8 = "runtime_crypto_inc_glue.o";
    return p;
  }
  if (i == 25) {
    let p: *u8 = "runtime_ed25519_ref10_glue.o";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_ensure_catalog_seed_base`.
 * Implements `labi_ensure_catalog_seed_base`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_ensure_catalog_seed_base(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "runtime_asm_io_stubs.from_x.c";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "runtime_process_argv.from_x.c";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "runtime_process_os_glue.from_x.c";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "runtime_random_fill.from_x.c";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "runtime_compress_zlib_glue.from_x.c";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "runtime_time_os.from_x.c";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "runtime_queue_contention.from_x.c";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "runtime_dynlib_os.from_x.c";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "runtime_env_os.from_x.c";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "runtime_backtrace_platform.from_x.c";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "runtime_log_os.from_x.c";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "runtime_math_libm.from_x.c";
    return p;
  }
  if (i == 12) {
    let p: *u8 = "runtime_atomic_glue.from_x.c";
    return p;
  }
  if (i == 13) {
    let p: *u8 = "runtime_channel_glue.from_x.c";
    return p;
  }
  if (i == 14) {
    let p: *u8 = "runtime_net_udp_batch.from_x.c";
    return p;
  }
  if (i == 15) {
    let p: *u8 = "runtime_net_workers.from_x.c";
    return p;
  }
  if (i == 16) {
    let p: *u8 = "runtime_sync_os.from_x.c";
    return p;
  }
  if (i == 17) {
    let p: *u8 = "runtime_sync_lock_diag_tls.from_x.c";
    return p;
  }
  if (i == 18) {
    let p: *u8 = "runtime_thread_glue.from_x.c";
    return p;
  }
  if (i == 19) {
    let p: *u8 = "runtime_scheduler_glue.from_x.c";
    return p;
  }
  if (i == 20) {
    let p: *u8 = "runtime_http_glue.from_x.c";
    return p;
  }
  if (i == 21) {
    let p: *u8 = "runtime_kv_mmap_glue.from_x.c";
    return p;
  }
  if (i == 22) {
    let p: *u8 = "runtime_arrow_simd_glue.from_x.c";
    return p;
  }
  if (i == 23) {
    let p: *u8 = "runtime_sqlite_glue.from_x.c";
    return p;
  }
  if (i == 24) {
    let p: *u8 = "runtime_crypto_inc_glue.from_x.c";
    return p;
  }
  if (i == 25) {
    let p: *u8 = "runtime_ed25519_ref10_glue.from_x.c";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_ensure_catalog_flags`.
 * Implements `labi_ensure_catalog_flags`.
 * @param i i32
 * @return i32
 */
#[no_mangle]
export function labi_ensure_catalog_flags(i: i32): i32 {
  if (i < 0) {
    return 0;
  }
  if (i == 0) {
    return 1; // LABI_ENS_FLAG_PIE
  }
  if (i == 20) {
    return 3; // LABI_ENS_HTTP_GLUE → LABI_ENS_FLAG_HTTP_SEEDS (-I seeds/http)
  }
  if (i == 23) {
    return 2; // LABI_ENS_FLAG_SQLITE
  }
  if (i >= 26) {
    return 0;
  }
  return 0;
}

// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).

/** Function `labi_ensure_catalog_step_at`.
 * Purpose: implements `labi_ensure_catalog_step_at`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
#[no_mangle]
export function labi_ensure_catalog_step_at(
  i: i32, stem_out: *usize, out_base_out: *usize, seed_base_out: *usize,
  flags_out: *i32, hint_out: *usize
): i32 {
  if (i < 0) {
    return 0;
  }
  if (i >= 26) {
    return 0;
  }
  let s: *u8 = labi_ensure_catalog_stem(i);
  if (s == 0 as *u8) {
    return 0;
  }
  if (stem_out != 0 as *usize) {
    stem_out[0] = s as usize;
  }
  if (out_base_out != 0 as *usize) {
    let p: *u8 = labi_ensure_catalog_out_base(i);
    out_base_out[0] = p as usize;
  }
  if (seed_base_out != 0 as *usize) {
    let p: *u8 = labi_ensure_catalog_seed_base(i);
    seed_base_out[0] = p as usize;
  }
  if (flags_out != 0 as *i32) {
    let f: i32 = labi_ensure_catalog_flags(i);
    flags_out[0] = f;
  }
  if (hint_out != 0 as *usize) {
    // empty hints: only i==0 and i==1 have non-null
    if (i == 0) {
      let p: *u8 = "try: make -C compiler runtime_asm_io_stubs.o";
      hint_out[0] = p as usize;
    } else {
      if (i == 1) {
        let p: *u8 = "try: make -C compiler runtime_process_argv.o";
        hint_out[0] = p as usize;
      } else {
        hint_out[0] = 0 as usize;
      }
    }
  }
  return 1;
}

/**
 * Ensure runtime_panic.o exists next to the product host (compile from asm/C if missing).
 * Special ensure (not catalog): multi-source prefer — Linux x86_64 .s, then POSIX aarch64
 * arm64 seed C, else default seeds/runtime_panic.from_x.c.
 * @param argv0 *u8 — optional product host path for compiler-dir resolve / path ladder; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing failure (diag written)
 * Pure orch: peer panic_o_path (wave163) + pure byte joins (no snprintf Cap) after Cap residual
 *   resolve; Cap residual host #if prefer + path_readable + cc_compile_sync + skip_missing (stat)
 *   + peer diags (resolve_fail / missing_under / build_status / missing).
 * Cap residual: shu_resolve_compiler_dir; link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync (spawn/cc); asm_link_obj_skip_missing (stat);
 *   link_abi_host_is_linux_x86_64 / link_abi_host_is_posix_aarch64 (PLATFORM #if body).
 * Why (wave169): hybrid still had always-mega C body for special panic ensure after panic
 *   path pure (wave163) and freestanding ensure pair (wave167/168). Catalog thin wraps stay
 *   via link_abi_ensure_from_catalog Cap residual.
 * PLATFORM: SHARED orch; LINUX x86_64 asm prefer; LINUX|MACOS aarch64 arm64 seed prefer.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_ensure_runtime_panic_o(argv0: *u8): i32 {
  // Cap residual: skip if product path already has runtime_panic.o (stat via path pure peer).
  let o_path: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    o_path = shux_runtime_panic_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have != 0 as *u8) {
    return 0;
  }
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp[0], 4096);
  }
  if (rc != 0) {
    let hint: *u8 = "try: make -C compiler runtime_panic.o";
    unsafe {
      link_diag_runtime_obj_resolve_fail("runtime_panic.o", hint);
    }
    return -1;
  }
  // Pure strlen(comp) once for joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + "runtime_panic.o" + NUL (no snprintf Cap).
  let leaf_o: *u8 = "runtime_panic.o";
  let ln_o: i32 = 0;
  while (leaf_o[ln_o] != 0) {
    ln_o = ln_o + 1;
  }
  if (dn + 1 + ln_o >= 4096) {
    return -1;
  }
  let out_o: u8[4096] = [];
  let i: i32 = 0;
  while (i < dn) {
    out_o[i] = comp[i];
    i = i + 1;
  }
  out_o[dn] = 47;
  let k: i32 = 0;
  while (k <= ln_o) {
    out_o[dn + 1 + k] = leaf_o[k];
    k = k + 1;
  }
  // Source selection ≡ mega: prefer .s on linux x86_64; arm64 seed on posix aarch64; else default C.
  let src: *u8 = 0 as *u8;
  let from_asm_s: i32 = 0;
  let src_s: u8[4096] = [];
  let src_arm: u8[4096] = [];
  let src_c: u8[4096] = [];
  let is_linux_x86: i32 = 0;
  unsafe {
    is_linux_x86 = link_abi_host_is_linux_x86_64();
  }
  if (is_linux_x86 != 0) {
    let leaf_s: *u8 = "src/asm/runtime_panic_x86_64.s";
    let ln_s: i32 = 0;
    while (leaf_s[ln_s] != 0) {
      ln_s = ln_s + 1;
    }
    if (dn + 1 + ln_s < 4096) {
      i = 0;
      while (i < dn) {
        src_s[i] = comp[i];
        i = i + 1;
      }
      src_s[dn] = 47;
      k = 0;
      while (k <= ln_s) {
        src_s[dn + 1 + k] = leaf_s[k];
        k = k + 1;
      }
      let readable: i32 = 0;
      unsafe {
        readable = link_abi_path_readable(&src_s[0]);
      }
      if (readable != 0) {
        src = &src_s[0];
        from_asm_s = 1;
      }
    }
  }
  if (src == 0 as *u8) {
    let is_posix_a64: i32 = 0;
    unsafe {
      is_posix_a64 = link_abi_host_is_posix_aarch64();
    }
    if (is_posix_a64 != 0) {
      let leaf_a: *u8 = "seeds/runtime_panic_arm64.from_x.c";
      let ln_a: i32 = 0;
      while (leaf_a[ln_a] != 0) {
        ln_a = ln_a + 1;
      }
      if (dn + 1 + ln_a < 4096) {
        i = 0;
        while (i < dn) {
          src_arm[i] = comp[i];
          i = i + 1;
        }
        src_arm[dn] = 47;
        k = 0;
        while (k <= ln_a) {
          src_arm[dn + 1 + k] = leaf_a[k];
          k = k + 1;
        }
        let readable2: i32 = 0;
        unsafe {
          readable2 = link_abi_path_readable(&src_arm[0]);
        }
        if (readable2 != 0) {
          src = &src_arm[0];
        }
      }
    }
  }
  if (src == 0 as *u8) {
    let leaf_c: *u8 = "seeds/runtime_panic.from_x.c";
    let ln_c: i32 = 0;
    while (leaf_c[ln_c] != 0) {
      ln_c = ln_c + 1;
    }
    if (dn + 1 + ln_c >= 4096) {
      return -1;
    }
    i = 0;
    while (i < dn) {
      src_c[i] = comp[i];
      i = i + 1;
    }
    src_c[dn] = 47;
    k = 0;
    while (k <= ln_c) {
      src_c[dn + 1 + k] = leaf_c[k];
      k = k + 1;
    }
    let readable3: i32 = 0;
    unsafe {
      readable3 = link_abi_path_readable(&src_c[0]);
    }
    if (readable3 == 0) {
      // Match mega: missing_under(stem, comp, "/seeds/") when default C absent.
      unsafe {
        link_diag_runtime_source_missing_under("runtime_panic", &comp[0], "/seeds/");
      }
      return -1;
    }
    src = &src_c[0];
  }
  // Pure join include paths: inc0=comp, inc1=comp/include, inc2=comp/src (≡ mega).
  let inc0: u8[4096] = [];
  i = 0;
  while (i <= dn) {
    inc0[i] = comp[i];
    i = i + 1;
  }
  let leaf_inc: *u8 = "include";
  let ln_inc: i32 = 0;
  while (leaf_inc[ln_inc] != 0) {
    ln_inc = ln_inc + 1;
  }
  if (dn + 1 + ln_inc >= 4096) {
    return -1;
  }
  let inc1: u8[4096] = [];
  i = 0;
  while (i < dn) {
    inc1[i] = comp[i];
    i = i + 1;
  }
  inc1[dn] = 47;
  k = 0;
  while (k <= ln_inc) {
    inc1[dn + 1 + k] = leaf_inc[k];
    k = k + 1;
  }
  let leaf_src: *u8 = "src";
  let ln_src: i32 = 0;
  while (leaf_src[ln_src] != 0) {
    ln_src = ln_src + 1;
  }
  if (dn + 1 + ln_src >= 4096) {
    return -1;
  }
  let inc2: u8[4096] = [];
  i = 0;
  while (i < dn) {
    inc2[i] = comp[i];
    i = i + 1;
  }
  inc2[dn] = 47;
  k = 0;
  while (k <= ln_src) {
    inc2[dn + 1 + k] = leaf_src[k];
    k = k + 1;
  }
  // Cap residual: cc -c src → out_o (from_asm_s when Linux x86_64 .s selected).
  let crc: i32 = 0;
  unsafe {
    crc = shux_cc_compile_sync(src, &out_o[0], &inc0[0], &inc1[0], &inc2[0], from_asm_s);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status("runtime_panic.o", crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  unsafe {
    o_path = shux_runtime_panic_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing("runtime_panic.o", &out_o[0]);
    }
    return -1;
  }
  return 0;
}
