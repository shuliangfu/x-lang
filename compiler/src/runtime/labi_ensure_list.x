// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).
// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).
// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).
//
// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).
// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).
// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).
// link_abi L4 ensure catalog pure table (G.9 English; body is authoritative).
// labi_ensure_catalog_count: see function docblock below.

#[no_mangle]
/** Exported function `labi_ensure_catalog_count`.
 * Implements `labi_ensure_catalog_count`.
 * @return i32
 */
export function labi_ensure_catalog_count(): i32 {
  return 26;
}

#[no_mangle]
/** Exported function `labi_ensure_catalog_stem`.
 * Implements `labi_ensure_catalog_stem`.
 * @param i i32
 * @return *u8
 */
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

#[no_mangle]
/** Exported function `labi_ensure_catalog_out_base`.
 * Implements `labi_ensure_catalog_out_base`.
 * @param i i32
 * @return *u8
 */
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

#[no_mangle]
/** Exported function `labi_ensure_catalog_seed_base`.
 * Implements `labi_ensure_catalog_seed_base`.
 * @param i i32
 * @return *u8
 */
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

#[no_mangle]
/** Exported function `labi_ensure_catalog_flags`.
 * Implements `labi_ensure_catalog_flags`.
 * @param i i32
 * @return i32
 */
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

#[no_mangle]
/** Function `labi_ensure_catalog_step_at`.
 * Purpose: implements `labi_ensure_catalog_step_at`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
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
