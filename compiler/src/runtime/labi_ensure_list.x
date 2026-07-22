// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-273 / P2 link_abi L4 ensure catalog pure table + special ensure orch.
// Product: PREFER_X_O → g05_try_x_to_o; cold-start seeds/labi_ensure_list.from_x.c.
// Hybrid macro SHUX_LABI_ENSURE_LIST_FROM_X (FROM_X rest business H=0, marker only).
//
// R2 full: ensure catalog tables (stem/out_base/seed_base/flags/step_at) +
//   wave173 link_abi_ensure_from_catalog pure orch
//     (catalog tables + pure byte joins + Cap residual resolve/access/cc/one_extra/stat).
//   wave174 catalog thin ensure wraps pure (26× shux_ensure_runtime_*_o)
//     (peer *_o_path Cap residual + pure ensure_from_catalog; zero extra business logic).
//   wave169 shux_ensure_runtime_panic_o pure orch
//     (peer panic_o_path + Cap residual resolve/access/cc/stat + host #if prefer).
//   wave170 shux_ensure_runtime_heap_user_o pure orch
//     (peer heap_user_o_path + stub-defined-sym gate + pure byte joins + Cap residual).
//   wave171 shux_ensure_runtime_test_fn_invoke_o pure orch
//     (peer test_fn_invoke_o_path + pure byte joins + Cap residual resolve/access/cc/stat).
//   wave172 shux_ensure_runtime_tls_mbedtls_bio_o pure orch
//     (peer tls_mbedtls_bio_o_path + pure byte joins + Cap residual resolve/access/cc_one_extra/stat).
//   wave182 shux_ensure_bootstrap_nostdlib_stubs_o pure orch
//     (peer bootstrap_nostdlib_stubs_o_path + pure byte joins + Cap residual resolve/access/
//      compile_sync_one_extra -fno-builtin + stat; freestanding mmap malloc face).
//   wave186 shux_asm_ld_prepare_for_exe_link pure orch
//     (peer freestanding_enabled/needs + peer ensure_* + peer user_needs + Cap residual
//      debug report + freestanding_unsupported; pure gate/order ≡ mega).
// Cap residual: resolve/access/cc/stat (+ one_extra for PIE/SQLITE/HTTP -I pack / -fno-builtin);
//   + host linux_x86_64 / posix_aarch64 for panic ensure leaf (wave169);
//   + has_defined_sym / unlink for heap_user stub reject (wave170);
//   + test_fn_invoke special ensure pure (wave171; no wrap.c / no fopen Cap);
//   + tls_mbedtls_bio special ensure pure (wave172; compile_sync_one_extra homebrew -I);
//   + bootstrap_nostdlib_stubs special ensure pure (wave182; compile_sync_one_extra -fno-builtin);
//   + prepare_for_exe_link pure (wave186; freestanding peers + user_needs + debug report Cap);
//   + catalog thin wrap path peers *_o_path (static PATH_MAX / compiler_o_path_copy).
// PLATFORM: SHARED tables / orch; LINUX x86_64 asm prefer; POSIX aarch64 arm64 seed.

// Cap residual (wave169/170/171/172 special ensure pure orch): resolve / access / cc / skip-stat.
export extern "C" function shu_resolve_compiler_dir(argv0: *u8, out_dir: *u8, out_dir_sz: i64): i32;
export extern "C" function link_abi_path_readable(path: *u8): i32;
export extern "C" function shux_cc_compile_sync(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32): i32;
// Cap residual (wave172 mbedtls_bio): pack one pure flag string into compile_sync_ex table.
export extern "C" function shux_cc_compile_sync_one_extra(src: *u8, out_o: *u8, inc0: *u8, inc1: *u8, inc2: *u8, from_asm_s: i32, extra0: *u8): i32;
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
// Cap residual host #if (mega; ≡ ensure_runtime_panic source gates).
export extern "C" function link_abi_host_is_linux_x86_64(): i32;
export extern "C" function link_abi_host_is_posix_aarch64(): i32;
// Cap residual (wave170 heap_user): nm/defined-sym probe + unlink incomplete stub .o.
export extern "C" function shux_link_obj_has_defined_sym(o_path: *u8, sym: *u8): i32;
export extern "C" function unlink(path: *u8): i32;
// Peer pure path ladder (labi_path_pure L0 / wave160-163 compiler_o_path_copy joins).
export extern "C" function shux_runtime_panic_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_heap_user_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_test_fn_invoke_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_tls_mbedtls_bio_o_path(argv0: *u8): *u8;
// Peer pure path ladder (labi_path_pure L0 / wave181 bootstrap_nostdlib_stubs_o_path).
export extern "C" function shux_bootstrap_nostdlib_stubs_o_path(argv0: *u8): *u8;
// Cap residual path peers for wave174 catalog thin ensure wraps (mega / path pure).
export extern "C" function shux_runtime_asm_io_stubs_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_process_argv_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_process_os_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_random_fill_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_compress_zlib_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_time_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_queue_contention_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_dynlib_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_env_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_backtrace_platform_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_log_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_math_libm_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_atomic_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_channel_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_net_udp_batch_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_net_workers_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_sync_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_sync_lock_diag_tls_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_thread_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_scheduler_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_http_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_kv_mmap_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_arrow_simd_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_sqlite_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_crypto_inc_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_ed25519_ref10_glue_o_path(argv0: *u8): *u8;
// Peer pure diags (labi_diag_pure L1).
export extern "C" function link_diag_runtime_obj_resolve_fail(obj_name: *u8, hint: *u8): void;
export extern "C" function link_diag_runtime_source_missing(obj_name: *u8, source_path: *u8): void;
export extern "C" function link_diag_runtime_source_missing_under(obj_name: *u8, base_dir: *u8, suffix: *u8): void;
export extern "C" function link_diag_runtime_obj_build_status(obj_name: *u8, status: i32): void;
export extern "C" function link_diag_runtime_obj_missing(obj_name: *u8, out_o: *u8): void;
// Cap residual / peer pure (wave186 prepare_for_exe_link): freestanding L7 + ondemand L8b + debug Cap.
// freestanding_enabled already returns 0 on non-Linux (≡ mega #if __linux__ freestanding branches).
export extern "C" function shux_link_freestanding_enabled(driver_freestanding: i32): i32;
export extern "C" function shux_freestanding_user_o_needs_panic(user_o: *u8): i32;
export extern "C" function shux_freestanding_user_o_needs_io(user_o: *u8): i32;
export extern "C" function shux_ensure_crt0_user_o(argv0: *u8, driver_freestanding: i32): i32;
export extern "C" function shux_ensure_freestanding_io_o(argv0: *u8, driver_freestanding: i32): i32;
export extern "C" function labi_user_needs_runtime_process_argv(user_o: *u8): i32;
export extern "C" function labi_user_needs_runtime_random_fill(user_o: *u8): i32;
export extern "C" function labi_user_needs_runtime_time_os(user_o: *u8): i32;
export extern "C" function labi_user_needs_runtime_env_os(user_o: *u8): i32;
export extern "C" function link_diag_freestanding_unsupported(): void;
// Cap residual: optional hello-stage1 debug probe (fopen/fork/http; no-op when unset).
export extern "C" function shux_debug_hello_stage1_report(hypothesis_id: *u8, location: *u8, msg: *u8, v1: i32, v2: i32, v3: i32): void;

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
 * Generic L4 ensure from pure catalog tables: if product .o is missing, compile
 * seeds/<seed_base> → compiler_dir/<out_base> with catalog flags.
 * @param argv0 *u8 — optional product host path for compiler-dir resolve; may be null
 * @param catalog_idx i32 — row in labi_ensure_catalog_* (0..25); invalid → -1
 * @param product_path *u8 — pre-resolved product .o path from peer shux_runtime_*_o_path;
 *   null → -1. Caller passes path once (no .x function-pointer call ABI; Cap residual
 *   path peers stay C / pure path ladder).
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure orch: labi_ensure_catalog_* tables + pure byte joins (no snprintf Cap) after Cap
 *   residual resolve; Cap residual path_readable + compile_sync / one_extra + skip_missing
 *   + peer diags (resolve_fail / source_missing / build_status / missing).
 * Flags (≡ mega LABI_ENS_FLAG_*): 0 NONE → compile_sync; 1 PIE → one_extra "-fPIE";
 *   2 SQLITE → one_extra "-DSHUX_DB_USE_SQLITE3"; 3 HTTP_SEEDS → pack single
 *   "-I{comp}/seeds/http" via one_extra (≡ mega separate -I + path argv entries).
 * Cap residual: shu_resolve_compiler_dir; link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync / shux_cc_compile_sync_one_extra (spawn/cc); asm_link_obj_skip_missing.
 * Why (wave173): hybrid still had always-mega C body for generic catalog ensure after special
 *   ensure leaves pure (wave169–172). Tables were pure; orch/spawn/cc stayed mega.
 * wave174: catalog thin wraps pure (ensure_*(argv0) → path peer + ensure_from_catalog).
 * PLATFORM: SHARED orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function link_abi_ensure_from_catalog(argv0: *u8, catalog_idx: i32, product_path: *u8): i32 {
  // Reject null path (≡ mega path_fn null).
  if (product_path == 0 as *u8) {
    return -1;
  }
  // Catalog row: tables are pure authority (G.7); invalid idx / null stem → fail.
  let stem: *u8 = labi_ensure_catalog_stem(catalog_idx);
  let out_base: *u8 = labi_ensure_catalog_out_base(catalog_idx);
  let seed_base: *u8 = labi_ensure_catalog_seed_base(catalog_idx);
  if (stem == 0 as *u8) {
    return -1;
  }
  if (out_base == 0 as *u8) {
    return -1;
  }
  if (seed_base == 0 as *u8) {
    return -1;
  }
  let flags: i32 = labi_ensure_catalog_flags(catalog_idx);
  // Cap residual: skip if product path already has the .o.
  let have: *u8 = 0 as *u8;
  unsafe {
    have = asm_link_obj_skip_missing(product_path);
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
    // Hints only for catalog 0/1 (≡ mega step_at / thin historic make tips).
    let hint: *u8 = 0 as *u8;
    if (catalog_idx == 0) {
      hint = "try: make -C compiler runtime_asm_io_stubs.o";
    } else {
      if (catalog_idx == 1) {
        hint = "try: make -C compiler runtime_process_argv.o";
      }
    }
    unsafe {
      link_diag_runtime_obj_resolve_fail(out_base, hint);
    }
    return -1;
  }
  // Pure strlen(comp) once for joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + out_base + NUL (no snprintf Cap).
  let ln_o: i32 = 0;
  while (out_base[ln_o] != 0) {
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
    out_o[dn + 1 + k] = out_base[k];
    k = k + 1;
  }
  // Pure join src_c = comp + '/' + "seeds/" + seed_base + NUL.
  let seeds_pfx: *u8 = "seeds/";
  let ln_pfx: i32 = 0;
  while (seeds_pfx[ln_pfx] != 0) {
    ln_pfx = ln_pfx + 1;
  }
  let ln_seed: i32 = 0;
  while (seed_base[ln_seed] != 0) {
    ln_seed = ln_seed + 1;
  }
  if (dn + 1 + ln_pfx + ln_seed >= 4096) {
    return -1;
  }
  let src_c: u8[4096] = [];
  i = 0;
  while (i < dn) {
    src_c[i] = comp[i];
    i = i + 1;
  }
  src_c[dn] = 47;
  k = 0;
  while (k < ln_pfx) {
    src_c[dn + 1 + k] = seeds_pfx[k];
    k = k + 1;
  }
  let off: i32 = dn + 1 + ln_pfx;
  k = 0;
  while (k <= ln_seed) {
    src_c[off + k] = seed_base[k];
    k = k + 1;
  }
  let readable: i32 = 0;
  unsafe {
    readable = link_abi_path_readable(&src_c[0]);
  }
  if (readable == 0) {
    unsafe {
      link_diag_runtime_source_missing(stem, &src_c[0]);
    }
    return -1;
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
  // Cap residual: cc -c with catalog flag family (PIE / SQLITE / HTTP -I pack / none).
  let crc: i32 = 0;
  if (flags == 1) {
    // LABI_ENS_FLAG_PIE
    let flag_pie: *u8 = "-fPIE";
    unsafe {
      crc = shux_cc_compile_sync_one_extra(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0, flag_pie);
    }
  } else {
    if (flags == 2) {
      // LABI_ENS_FLAG_SQLITE
      let flag_sql: *u8 = "-DSHUX_DB_USE_SQLITE3";
      unsafe {
        crc = shux_cc_compile_sync_one_extra(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0, flag_sql);
      }
    } else {
      if (flags == 3) {
        // LABI_ENS_FLAG_HTTP_SEEDS: pack "-I" + comp + "/seeds/http" (≡ mega -I + path).
        let http_leaf: *u8 = "seeds/http";
        let ln_http: i32 = 0;
        while (http_leaf[ln_http] != 0) {
          ln_http = ln_http + 1;
        }
        if (dn + 1 + ln_http >= 4096) {
          return -1;
        }
        let http_inc: u8[4096] = [];
        i = 0;
        while (i < dn) {
          http_inc[i] = comp[i];
          i = i + 1;
        }
        http_inc[dn] = 47;
        k = 0;
        while (k <= ln_http) {
          http_inc[dn + 1 + k] = http_leaf[k];
          k = k + 1;
        }
        // flag_I = "-I" + http_inc + NUL (single extra string for one_extra Cap).
        let dash_I: *u8 = "-I";
        let ln_I: i32 = 2;
        let ln_http_abs: i32 = dn + 1 + ln_http;
        if (ln_I + ln_http_abs >= 4096) {
          return -1;
        }
        let flag_I: u8[4096] = [];
        flag_I[0] = 45; // '-'
        flag_I[1] = 73; // 'I'
        k = 0;
        while (k <= ln_http_abs) {
          flag_I[ln_I + k] = http_inc[k];
          k = k + 1;
        }
        unsafe {
          crc = shux_cc_compile_sync_one_extra(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0, &flag_I[0]);
        }
      } else {
        // LABI_ENS_FLAG_NONE
        unsafe {
          crc = shux_cc_compile_sync(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0);
        }
      }
    }
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status(out_base, crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  unsafe {
    have = asm_link_obj_skip_missing(product_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing(out_base, &out_o[0]);
    }
    return -1;
  }
  return 0;
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

/**
 * Ensure runtime_heap_user.o exists next to the product host (compile seed if missing/stub).
 * Special ensure (not catalog): co-emits std.heap redirect heap_*_c symbols. Rejects
 * incomplete stub/empty .o that only passes skip_missing but lacks arena/alloc API
 * (with_arena residual: early ensure on 944B empty .o → U heap_arena_init_c).
 * @param argv0 *u8 — optional product host path for compiler-dir resolve / path ladder; may be null
 * @return i32 — 0 success / already present with defined API; -1 on resolve/source/cc/missing
 * Pure orch: peer heap_user_o_path + pure byte joins (no snprintf Cap) after Cap residual
 *   resolve; Cap residual has_defined_sym (nm) + unlink stub + path_readable + cc_compile_sync
 *   + skip_missing (stat) + peer diags (resolve_fail / source_missing / build_status / missing).
 * Cap residual: shu_resolve_compiler_dir; link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync (spawn/cc); asm_link_obj_skip_missing (stat);
 *   shux_link_obj_has_defined_sym (popen/nm); unlink (POSIX remove stub).
 * Why (wave170): hybrid still had always-mega C body for special heap_user ensure after
 *   panic ensure pure (wave169) and freestanding ensure pair (wave167/168). Catalog thin
 *   wraps stay via link_abi_ensure_from_catalog Cap residual.
 * PLATFORM: SHARED orch (seed compile absolute path; no wrap.c include race).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_ensure_runtime_heap_user_o(argv0: *u8): i32 {
  // Cap residual: product path + skip if .o exists AND exports arena/alloc API.
  // Incomplete stub .o (skip_missing only) is unlinked and rebuilt (≡ mega remove).
  let existing: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    existing = shux_runtime_heap_user_o_path(argv0);
    have = asm_link_obj_skip_missing(existing);
  }
  if (have != 0 as *u8) {
    let has_arena: i32 = 0;
    let has_alloc: i32 = 0;
    unsafe {
      has_arena = shux_link_obj_has_defined_sym(existing, "heap_arena_init_c");
      has_alloc = shux_link_obj_has_defined_sym(existing, "heap_alloc_c");
    }
    if (has_arena != 0) {
      return 0;
    }
    if (has_alloc != 0) {
      return 0;
    }
    // Stub/empty: drop and rebuild from seed.
    unsafe {
      unlink(existing);
    }
  }
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp[0], 4096);
  }
  if (rc != 0) {
    // Match mega: resolve_fail with null hint for heap_user.
    unsafe {
      link_diag_runtime_obj_resolve_fail("runtime_heap_user.o", 0 as *u8);
    }
    return -1;
  }
  // Pure strlen(comp) once for joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + "runtime_heap_user.o" + NUL (no snprintf Cap).
  let leaf_o: *u8 = "runtime_heap_user.o";
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
  // Single source: seeds/runtime_heap_user.from_x.c (direct compile; no wrap.c).
  let leaf_c: *u8 = "seeds/runtime_heap_user.from_x.c";
  let ln_c: i32 = 0;
  while (leaf_c[ln_c] != 0) {
    ln_c = ln_c + 1;
  }
  if (dn + 1 + ln_c >= 4096) {
    return -1;
  }
  let src_c: u8[4096] = [];
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
  let readable: i32 = 0;
  unsafe {
    readable = link_abi_path_readable(&src_c[0]);
  }
  if (readable == 0) {
    // Match mega: source_missing(stem, full seed path) when seed absent.
    unsafe {
      link_diag_runtime_source_missing("runtime_heap_user", &src_c[0]);
    }
    return -1;
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
  // Cap residual: cc -c seed → out_o (from_asm_s=0; C seed only).
  let crc: i32 = 0;
  unsafe {
    crc = shux_cc_compile_sync(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status("runtime_heap_user.o", crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  let o_path: *u8 = 0 as *u8;
  unsafe {
    o_path = shux_runtime_heap_user_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing("runtime_heap_user.o", &out_o[0]);
    }
    return -1;
  }
  return 0;
}

/**
 * Ensure runtime_test_fn_invoke.o exists next to the product host (compile seed if missing).
 * Special ensure (not catalog): std.test fn-ptr invoke C TU (test_call_i32_void_c).
 * @param argv0 *u8 — optional product host path for compiler-dir resolve / path ladder; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing
 * Pure orch: peer test_fn_invoke_o_path + pure byte joins (no snprintf Cap) after Cap residual
 *   resolve; Cap residual path_readable + cc_compile_sync + skip_missing (stat) + peer diags
 *   (resolve_fail / source_missing / build_status / missing).
 * Cap residual: shu_resolve_compiler_dir; link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync (spawn/cc); asm_link_obj_skip_missing (stat).
 * Why (wave171): hybrid still had always-mega C body for special test_fn_invoke ensure after
 *   heap_user pure (wave170). Mega used wrap.c+#include seed; pure uses direct seed compile
 *   (≡ wave169/170 heap/panic style; no fopen/fprintf Cap residual).
 * PLATFORM: SHARED orch (seed compile absolute path; no wrap.c include race).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_ensure_runtime_test_fn_invoke_o(argv0: *u8): i32 {
  // Cap residual: product path; skip if .o already present (no stub-sym gate; simple special).
  let existing: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    existing = shux_runtime_test_fn_invoke_o_path(argv0);
    have = asm_link_obj_skip_missing(existing);
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
    // Match mega: resolve_fail with make hint for test_fn_invoke.
    unsafe {
      link_diag_runtime_obj_resolve_fail("runtime_test_fn_invoke.o", "try: make -C compiler runtime_test_fn_invoke.o");
    }
    return -1;
  }
  // Pure strlen(comp) once for joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + "runtime_test_fn_invoke.o" + NUL (no snprintf Cap).
  let leaf_o: *u8 = "runtime_test_fn_invoke.o";
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
  // Single source: seeds/runtime_test_fn_invoke.from_x.c (direct compile; no wrap.c).
  let leaf_c: *u8 = "seeds/runtime_test_fn_invoke.from_x.c";
  let ln_c: i32 = 0;
  while (leaf_c[ln_c] != 0) {
    ln_c = ln_c + 1;
  }
  if (dn + 1 + ln_c >= 4096) {
    return -1;
  }
  let src_c: u8[4096] = [];
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
  let readable: i32 = 0;
  unsafe {
    readable = link_abi_path_readable(&src_c[0]);
  }
  if (readable == 0) {
    // Match mega: source_missing(stem, full seed path) when seed absent.
    unsafe {
      link_diag_runtime_source_missing("runtime_test_fn_invoke", &src_c[0]);
    }
    return -1;
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
  // Cap residual: cc -c seed → out_o (from_asm_s=0; C seed only).
  let crc: i32 = 0;
  unsafe {
    crc = shux_cc_compile_sync(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status("runtime_test_fn_invoke.o", crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  let o_path: *u8 = 0 as *u8;
  unsafe {
    o_path = shux_runtime_test_fn_invoke_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing("runtime_test_fn_invoke.o", &out_o[0]);
    }
    return -1;
  }
  return 0;
}

/**
 * Ensure runtime_tls_mbedtls_bio.o exists next to the product host (compile seed if missing).
 * Special ensure (not catalog): mbedTLS BIO glue for net-o-mbedtls (ld -r into tls_mbedtls.o).
 * @param argv0 *u8 — optional product host path for compiler-dir resolve / path ladder; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing
 * Pure orch: peer tls_mbedtls_bio_o_path + pure byte joins (no snprintf Cap) after Cap residual
 *   resolve; Cap residual path_readable + cc_compile_sync_one_extra + skip_missing (stat) + peer diags
 *   (resolve_fail with null hint / source_missing / build_status / missing).
 * Cap residual: shu_resolve_compiler_dir; link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync_one_extra (spawn/cc + homebrew -I pack); asm_link_obj_skip_missing (stat).
 * Why (wave172): hybrid still had always-mega C body for special tls_mbedtls_bio ensure after
 *   test_fn_invoke pure (wave171). Mega used snprintf + compile_sync_ex(extra_flags homebrew -I);
 *   pure uses direct seed compile + Cap residual one_extra (no local **u8 flag table in .x).
 * PLATFORM: SHARED orch; MACOS homebrew -I always best-effort (≡ mega; Linux ignores missing dir).
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_ensure_runtime_tls_mbedtls_bio_o(argv0: *u8): i32 {
  // Cap residual: product path; skip if .o already present.
  let existing: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    existing = shux_runtime_tls_mbedtls_bio_o_path(argv0);
    have = asm_link_obj_skip_missing(existing);
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
    // Match mega: resolve_fail with null hint (Makefile best-effort fallback elsewhere).
    unsafe {
      link_diag_runtime_obj_resolve_fail("runtime_tls_mbedtls_bio.o", 0 as *u8);
    }
    return -1;
  }
  // Pure strlen(comp) once for joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + "runtime_tls_mbedtls_bio.o" + NUL (no snprintf Cap).
  let leaf_o: *u8 = "runtime_tls_mbedtls_bio.o";
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
  // Single source: seeds/runtime_tls_mbedtls_bio.from_x.c (direct compile).
  let leaf_c: *u8 = "seeds/runtime_tls_mbedtls_bio.from_x.c";
  let ln_c: i32 = 0;
  while (leaf_c[ln_c] != 0) {
    ln_c = ln_c + 1;
  }
  if (dn + 1 + ln_c >= 4096) {
    return -1;
  }
  let src_c: u8[4096] = [];
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
  let readable: i32 = 0;
  unsafe {
    readable = link_abi_path_readable(&src_c[0]);
  }
  if (readable == 0) {
    unsafe {
      link_diag_runtime_source_missing("runtime_tls_mbedtls_bio", &src_c[0]);
    }
    return -1;
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
  // Cap residual: cc -c seed with homebrew mbedTLS -I (best-effort; ≡ mega extra_flags).
  // PLATFORM: MACOS path always passed; Linux ignores missing include dir.
  let flag_I: *u8 = "-I/opt/homebrew/opt/mbedtls/include";
  let crc: i32 = 0;
  unsafe {
    crc = shux_cc_compile_sync_one_extra(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0, flag_I);
  }
  if (crc != 0) {
    // Match mega: build_status on failure; Makefile may still build offline.
    unsafe {
      link_diag_runtime_obj_build_status("runtime_tls_mbedtls_bio.o", crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  let o_path: *u8 = 0 as *u8;
  unsafe {
    o_path = shux_runtime_tls_mbedtls_bio_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing("runtime_tls_mbedtls_bio.o", &out_o[0]);
    }
    return -1;
  }
  return 0;
}

/**
 * Ensure bootstrap_nostdlib_stubs.o exists (compile seed if missing).
 * Special ensure (not catalog): freestanding mmap bump malloc/free face shared with
 *   compiler nostdlib bag (PLATFORM: LINUX freestanding consumers primary).
 * @param argv0 *u8 — optional product host path for compiler-dir resolve / path ladder; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing
 * Pure orch: peer bootstrap_nostdlib_stubs_o_path + pure byte joins (no snprintf Cap) after
 *   Cap residual resolve; Cap residual path_readable + cc_compile_sync_one_extra(-fno-builtin)
 *   + skip_missing (stat) + peer diags (resolve_fail / source_missing / build_status / missing).
 * Cap residual: shu_resolve_compiler_dir; link_abi_path_readable (access R_OK);
 *   shux_cc_compile_sync_one_extra (spawn/cc + -fno-builtin); asm_link_obj_skip_missing (stat).
 * Why (wave182): hybrid still had always-mega C body for ensure_bootstrap after path pure
 *   (wave181). Mega used system("cc -c -O2 -fno-builtin -I…"); pure uses Cap residual
 *   one_extra("-fno-builtin") over the shared compile_sync face (G.7; no second system path).
 * Note: -O2 dropped vs mega system line (optimization only; correctness = -fno-builtin + -I).
 * PLATFORM: SHARED orch / LINUX freestanding consumers — hybrid L4 pure; mega cold twin under
 *   #ifndef ENSURE_LIST_FROM_X.
 * Track-L: #[no_mangle] keeps surface short name.
 */
#[no_mangle]
export function shux_ensure_bootstrap_nostdlib_stubs_o(argv0: *u8): i32 {
  // Cap residual: product path; skip if .o already present (match mega: empty path is not ready).
  let existing: *u8 = 0 as *u8;
  let have: *u8 = 0 as *u8;
  unsafe {
    existing = shux_bootstrap_nostdlib_stubs_o_path(argv0);
  }
  if (existing != 0 as *u8) {
    if (existing[0] != 0) {
      unsafe {
        have = asm_link_obj_skip_missing(existing);
      }
      if (have != 0 as *u8) {
        return 0;
      }
    }
  }
  // Cap residual: platform compiler-dir resolve into 4096 stack (PATH_MAX upper).
  let comp: u8[4096] = [];
  let rc: i32 = 0;
  unsafe {
    rc = shu_resolve_compiler_dir(argv0, &comp[0], 4096);
  }
  if (rc != 0) {
    unsafe {
      link_diag_runtime_obj_resolve_fail("bootstrap_nostdlib_stubs.o", 0 as *u8);
    }
    return -1;
  }
  // Pure strlen(comp) once for joins.
  let dn: i32 = 0;
  while (comp[dn] != 0) {
    dn = dn + 1;
  }
  // Pure join out_o = comp + '/' + "src/asm/bootstrap_nostdlib_stubs.o" + NUL (≡ mega snprintf).
  let leaf_o: *u8 = "src/asm/bootstrap_nostdlib_stubs.o";
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
  // Single source: seeds/bootstrap_nostdlib_stubs.from_x.c (direct compile; ≡ mega).
  let leaf_c: *u8 = "seeds/bootstrap_nostdlib_stubs.from_x.c";
  let ln_c: i32 = 0;
  while (leaf_c[ln_c] != 0) {
    ln_c = ln_c + 1;
  }
  if (dn + 1 + ln_c >= 4096) {
    return -1;
  }
  let src_c: u8[4096] = [];
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
  // Cap residual: access(src, R_OK) via path_readable (wave151 Cap; ≡ mega skip_missing on src).
  let readable: i32 = 0;
  unsafe {
    readable = link_abi_path_readable(&src_c[0]);
  }
  if (readable == 0) {
    unsafe {
      link_diag_runtime_source_missing("bootstrap_nostdlib_stubs", &src_c[0]);
    }
    return -1;
  }
  // Pure join include paths: inc0=comp, inc1=comp/include, inc2=comp/src (≡ mega -I triple).
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
  // Cap residual: cc -c seed with -fno-builtin (malloc/free face must not call libc builtins).
  // PLATFORM: LINUX freestanding primary; SHARED orch over compile_sync_one_extra Cap.
  let flag_nb: *u8 = "-fno-builtin";
  let crc: i32 = 0;
  unsafe {
    crc = shux_cc_compile_sync_one_extra(&src_c[0], &out_o[0], &inc0[0], &inc1[0], &inc2[0], 0, flag_nb);
  }
  if (crc != 0) {
    unsafe {
      link_diag_runtime_obj_build_status("bootstrap_nostdlib_stubs.o", crc);
    }
    return -1;
  }
  // Cap residual: re-stat product path; missing after cc → diag fail.
  let o_path: *u8 = 0 as *u8;
  unsafe {
    o_path = shux_bootstrap_nostdlib_stubs_o_path(argv0);
    have = asm_link_obj_skip_missing(o_path);
  }
  if (have == 0 as *u8) {
    unsafe {
      link_diag_runtime_obj_missing("bootstrap_nostdlib_stubs.o", &out_o[0]);
    }
    return -1;
  }
  return 0;
}

// wave174: 26 catalog thin ensure wraps pure (peer path + ensure_from_catalog).
/**
 * Catalog thin ensure wrap: ensure `runtime_asm_io_stubs.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_asm_io_stubs_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 0, product_path)` (LABI_ENS_ASM_IO_STUBS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_asm_io_stubs_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_asm_io_stubs_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 0, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_process_argv.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_process_argv_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 1, product_path)` (LABI_ENS_PROCESS_ARGV).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_process_argv_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_process_argv_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 1, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_process_os_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_process_os_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 2, product_path)` (LABI_ENS_PROCESS_OS_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_process_os_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_process_os_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 2, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_random_fill.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_random_fill_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 3, product_path)` (LABI_ENS_RANDOM_FILL).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_random_fill_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_random_fill_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 3, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_compress_zlib_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_compress_zlib_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 4, product_path)` (LABI_ENS_COMPRESS_ZLIB_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_compress_zlib_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_compress_zlib_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 4, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_time_os.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_time_os_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 5, product_path)` (LABI_ENS_TIME_OS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_time_os_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_time_os_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 5, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_queue_contention.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_queue_contention_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 6, product_path)` (LABI_ENS_QUEUE_CONTENTION).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_queue_contention_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_queue_contention_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 6, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_dynlib_os.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_dynlib_os_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 7, product_path)` (LABI_ENS_DYNLIB_OS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_dynlib_os_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_dynlib_os_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 7, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_env_os.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_env_os_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 8, product_path)` (LABI_ENS_ENV_OS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_env_os_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_env_os_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 8, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_backtrace_platform.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_backtrace_platform_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 9, product_path)` (LABI_ENS_BACKTRACE_PLATFORM).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_backtrace_platform_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_backtrace_platform_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 9, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_log_os.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_log_os_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 10, product_path)` (LABI_ENS_LOG_OS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_log_os_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_log_os_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 10, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_math_libm.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_math_libm_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 11, product_path)` (LABI_ENS_MATH_LIBM).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_math_libm_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_math_libm_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 11, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_atomic_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_atomic_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 12, product_path)` (LABI_ENS_ATOMIC_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_atomic_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_atomic_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 12, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_channel_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_channel_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 13, product_path)` (LABI_ENS_CHANNEL_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_channel_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_channel_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 13, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_net_udp_batch.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_net_udp_batch_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 14, product_path)` (LABI_ENS_NET_UDP_BATCH).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_net_udp_batch_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_net_udp_batch_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 14, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_net_workers.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_net_workers_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 15, product_path)` (LABI_ENS_NET_WORKERS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_net_workers_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_net_workers_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 15, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_sync_os.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_sync_os_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 16, product_path)` (LABI_ENS_SYNC_OS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_sync_os_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_sync_os_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 16, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_sync_lock_diag_tls.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_sync_lock_diag_tls_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 17, product_path)` (LABI_ENS_SYNC_LOCK_DIAG_TLS).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_sync_lock_diag_tls_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_sync_lock_diag_tls_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 17, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_thread_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_thread_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 18, product_path)` (LABI_ENS_THREAD_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_thread_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_thread_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 18, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_scheduler_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_scheduler_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 19, product_path)` (LABI_ENS_SCHEDULER_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_scheduler_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_scheduler_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 19, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_http_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_http_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 20, product_path)` (LABI_ENS_HTTP_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_http_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_http_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 20, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_kv_mmap_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_kv_mmap_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 21, product_path)` (LABI_ENS_KV_MMAP_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_kv_mmap_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_kv_mmap_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 21, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_arrow_simd_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_arrow_simd_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 22, product_path)` (LABI_ENS_ARROW_SIMD_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_arrow_simd_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_arrow_simd_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 22, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_sqlite_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_sqlite_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 23, product_path)` (LABI_ENS_SQLITE_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_sqlite_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_sqlite_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 23, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_crypto_inc_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_crypto_inc_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 24, product_path)` (LABI_ENS_CRYPTO_INC_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_crypto_inc_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_crypto_inc_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 24, p);
}

/**
 * Catalog thin ensure wrap: ensure `runtime_ed25519_ref10_glue.o` via pure catalog orch.
 * @param argv0 *u8 — optional product host path for peer path resolve; may be null
 * @return i32 — 0 success / already present; -1 on resolve/source/cc/missing (diag written)
 * Pure thin wrap (wave174): Cap residual path peer `shux_runtime_ed25519_ref10_glue_o_path` then
 *   pure `link_abi_ensure_from_catalog(argv0, 25, product_path)` (LABI_ENS_ED25519_REF10_GLUE).
 * Zero business logic beyond path peer + catalog_idx — G.7 single authority is
 *   ensure_from_catalog (wave173) + path peers (wave160/161).
 * Why: hybrid still had always-mega C bodies for 26 catalog ensure thin wraps after
 *   ensure_from_catalog pure (wave173). Soft residual closed: hybrid ensure_* thin = pure.
 * Cap residual: only peer *_o_path (static PATH_MAX buffer / compiler_o_path_copy).
 * PLATFORM: SHARED thin orch — dual-end L2 prove IDENTICAL + product matrix.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_ensure_runtime_ed25519_ref10_glue_o(argv0: *u8): i32 {
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_runtime_ed25519_ref10_glue_o_path(argv0);
  }
  return link_abi_ensure_from_catalog(argv0, 25, p);
}

/**
 * Prepare runtime objects and freestanding gates before asm -o exe link (invoke_ld path).
 * Pure orch over peer ensure_* / freestanding / user_needs; Cap residual debug report +
 * freestanding_unsupported only. Order and gates ≡ historical mega C body.
 * @param link_eff *u8 — effective product host path for ensure path ladders; null → -1
 * @param user_o *u8 — user .o path for UNDEF/need probes; null → -1
 * @param driver_freestanding i32 — CLI/driver freestanding flag (0 = off, nonzero = force)
 * @param use_macho_o i32 — 1 if target is Mach-O object style; freestanding+macho → BLD001
 * @param use_coff_o i32 — 1 if target is COFF object style; freestanding+coff → BLD001
 * @return i32 — 0 success; -1 on null args / ensure failure / freestanding unsupported
 * Cap residual: shux_debug_hello_stage1_report (enter/exit probes); peer freestanding_enabled
 *   (already 0 on non-Linux ≡ mega #if __linux__ freestanding panic/io branches);
 *   peer needs_panic / needs_io; peer user_needs_runtime_*; peer ensure_* (L4/L7 pure);
 *   peer link_diag_freestanding_unsupported.
 * Why (wave186): hybrid still had always-mega C body for prepare_for_exe_link after ensure
 *   pure leaves closed. Soft residual: multi-ensure prep orch still only in mega C.
 * PLATFORM: SHARED orch / LINUX freestanding panic+io gates via freestanding_enabled.
 * Track-L: #[no_mangle] keeps surface short name for hybrid ld -r / cold twin.
 */
#[no_mangle]
export function shux_asm_ld_prepare_for_exe_link(link_eff: *u8, user_o: *u8, driver_freestanding: i32, use_macho_o: i32, use_coff_o: i32): i32 {
  // Cap residual: enter probe (no-op when .dbg env unset).
  let loc_enter: *u8 = "runtime_link_abi.c:prepare_for_exe_link_enter";
  let msg_enter: *u8 = "prepare_for_exe_link_enter";
  let hyp: *u8 = "A";
  unsafe {
    shux_debug_hello_stage1_report(hyp, loc_enter, msg_enter, driver_freestanding, use_macho_o, use_coff_o);
  }
  if (link_eff == 0 as *u8) {
    return 0 - 1;
  }
  if (user_o == 0 as *u8) {
    return 0 - 1;
  }
  // Freestanding (Linux only via freestanding_enabled): panic only when user.o needs it.
  // Hosted / non-Linux: always ensure panic (≡ mega #if __linux__ if/else structure).
  let fs: i32 = 0;
  unsafe {
    fs = shux_link_freestanding_enabled(driver_freestanding);
  }
  if (fs != 0) {
    let need_panic: i32 = 0;
    unsafe {
      need_panic = shux_freestanding_user_o_needs_panic(user_o);
    }
    if (need_panic != 0) {
      let prc: i32 = 0;
      unsafe {
        prc = shux_ensure_runtime_panic_o(link_eff);
      }
      if (prc != 0) {
        return 0 - 1;
      }
    }
  } else {
    let prc2: i32 = 0;
    unsafe {
      prc2 = shux_ensure_runtime_panic_o(link_eff);
    }
    if (prc2 != 0) {
      return 0 - 1;
    }
  }
  // Hosted asm links: always io stubs; process/random/time/env only on UNDEF need.
  // Freestanding: skip this block (crt0/io handled below).
  if (fs == 0) {
    let erc: i32 = 0;
    unsafe {
      erc = shux_ensure_runtime_asm_io_stubs_o(link_eff);
    }
    if (erc != 0) {
      return 0 - 1;
    }
    let need_pa: i32 = 0;
    unsafe {
      need_pa = labi_user_needs_runtime_process_argv(user_o);
    }
    if (need_pa != 0) {
      unsafe {
        erc = shux_ensure_runtime_process_argv_o(link_eff);
      }
      if (erc != 0) {
        return 0 - 1;
      }
    }
    let need_rf: i32 = 0;
    unsafe {
      need_rf = labi_user_needs_runtime_random_fill(user_o);
    }
    if (need_rf != 0) {
      unsafe {
        erc = shux_ensure_runtime_random_fill_o(link_eff);
      }
      if (erc != 0) {
        return 0 - 1;
      }
    }
    let need_to: i32 = 0;
    unsafe {
      need_to = labi_user_needs_runtime_time_os(user_o);
    }
    if (need_to != 0) {
      unsafe {
        erc = shux_ensure_runtime_time_os_o(link_eff);
      }
      if (erc != 0) {
        return 0 - 1;
      }
    }
    let need_eo: i32 = 0;
    unsafe {
      need_eo = labi_user_needs_runtime_env_os(user_o);
    }
    if (need_eo != 0) {
      unsafe {
        erc = shux_ensure_runtime_env_os_o(link_eff);
      }
      if (erc != 0) {
        return 0 - 1;
      }
    }
  }
  // Peer freestanding L7: crt0 ensure (no-op when freestanding off).
  let crc: i32 = 0;
  unsafe {
    crc = shux_ensure_crt0_user_o(link_eff, driver_freestanding);
  }
  if (crc != 0) {
    return 0 - 1;
  }
  // Freestanding + needs_io → freestanding_io ensure (non-Linux fs==0 skips).
  if (fs != 0) {
    let need_io: i32 = 0;
    unsafe {
      need_io = shux_freestanding_user_o_needs_io(user_o);
    }
    if (need_io != 0) {
      let irc: i32 = 0;
      unsafe {
        irc = shux_ensure_freestanding_io_o(link_eff, driver_freestanding);
      }
      if (irc != 0) {
        return 0 - 1;
      }
    }
  }
  // Freestanding is Linux ELF only — reject Mach-O / COFF object styles.
  if (fs != 0) {
    if (use_macho_o != 0) {
      unsafe {
        link_diag_freestanding_unsupported();
      }
      return 0 - 1;
    }
    if (use_coff_o != 0) {
      unsafe {
        link_diag_freestanding_unsupported();
      }
      return 0 - 1;
    }
  }
  // Cap residual: exit probe.
  let loc_exit: *u8 = "runtime_link_abi.c:prepare_for_exe_link_exit";
  let msg_exit: *u8 = "prepare_for_exe_link_exit";
  unsafe {
    shux_debug_hello_stage1_report(hyp, loc_exit, msg_exit, 0, 0, 0);
  }
  return 0;
}
