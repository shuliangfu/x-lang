// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L5 invoke_cc pure table + orch (G.9 English; body is authoritative).
// Hybrid macro SHUX_LABI_INVOKE_CC_LIST_FROM_X (FROM_X rest business H=0, marker only).
// R2 full pure:
//   - labi_linux_harden_flag_{count,at}
//   - labi_invoke_cc_skip_native_env_{count,at} + invoke_cc_skip_native_tuning
//   - labi_icc_rel_* (12) + labi_icc_needs_rel_{count,at}
//   - shux_append_linux_link_harden_impl (wave155; pure orch over harden table)
//   - invoke_cc_append_early_needs (wave198; pure orch early needs scan+push)
//   - invoke_cc_scan_std_module_needs (wave199; pure table scan std need flags)
//   - invoke_cc_append_std_ensure_push_front (wave200; pure ensure-push front string→env)
//   - invoke_cc_append_std_ensure_push_mid (wave201; pure ensure-push mid sync→hash)
//   - invoke_cc_append_std_ensure_push_heavy_a (wave202; pure ensure-push heavy_a math…compress)
//   - invoke_cc_append_std_ensure_push_heavy_b (wave203; pure ensure-push heavy_b unicode…process_argv)
//   - invoke_cc_append_heap_f06_ondemand (wave204; pure heap F-06 on-demand + page_mmap companions)
//   - invoke_cc_run_cc_argv + invoke_cc_maybe_strip_out (wave205; pure fork-exec shell + strip)
//   - invoke_cc_append_argv_head_flags (wave206; pure argv head: quiet/O/native/NDEBUG/flto/harden/gc/-I)
//   - invoke_cc_append_argv_tail_flags (wave207; pure argv tail: -pthread/-lc/allow-multiple/user_extra+NULL)
//   - invoke_cc_append_minimal_cc_link_tail (wave208; pure MINIMAL_CC_LINK: Win process_argv + POSIX -lc + NULL)
// Cap residual: getenv (libc); host_is_* #if probes; ensure/path/needs peers;
//   contains_substr(_use_line) peers for scan; shux_spawn_sync / setenv / strip_out_x / tool_status;
//   asm_link_obj_skip_missing; link_abi_user_extra_o_{count,at}; process_argv path (MINIMAL Windows).
// PLATFORM: SHARED tables/orch; LINUX consumers for harden -pie/-z flags.

// wave206: durable -O{level} argv slot (≡ mega static char oopt_buf[8]; durable pointer into argv).
let g_labi_icc_oopt_buf: u8[8] = [];

export extern "C" function getenv(name: *u8): *u8;

/* ===== wave198 Cap residual / peer pure for invoke_cc early needs ===== */
export extern "C" function link_abi_generated_c_needs_core_builtin(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_core_mem(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_core_slice(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_db_kv(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_db_arrow(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_fs(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_random(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_time(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_runtime(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_win32(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_win32_wsa(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_libc_heap(c_path: *u8): i32;
export extern "C" function invoke_cc_argv_push_existing(argv: **u8, ia: *i32, max_ia: i32, path: *u8): i32;
export extern "C" function shux_rel_o_path_from_argv0(argv0: *u8, rel: *u8): *u8;
export extern "C" function shux_runtime_kv_mmap_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_runtime_arrow_simd_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_random_fill_o(argv0: *u8): i32;
export extern "C" function shux_runtime_random_fill_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_time_os_o(argv0: *u8): i32;
export extern "C" function shux_runtime_time_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_panic_o(argv0: *u8): i32;
export extern "C" function shux_runtime_panic_o_path(argv0: *u8): *u8;
export extern "C" function shux_host_is_linux(): i32;
export extern "C" function link_abi_host_is_apple(): i32;
export extern "C" function link_abi_host_is_windows(): i32;
export extern "C" function labi_ld_flag_lc(): *u8;
export extern "C" function labi_ld_flag_lbcrypt(): *u8;
export extern "C" function labi_ld_flag_lws2_32(): *u8;

/* ===== wave200 Cap residual / peer pure for ensure-push front (string→env) ===== */
export extern "C" function shux_ensure_runtime_process_argv_o(argv0: *u8): i32;
export extern "C" function shux_runtime_process_argv_o_path(argv0: *u8): *u8;
export extern "C" function invoke_cc_append_net_tls_ld(argv: **u8, ia: *i32, argv_cap: i32, net_o: *u8, repo_root: *u8): i32;
export extern "C" function shux_ensure_runtime_net_udp_batch_o(argv0: *u8): i32;
export extern "C" function shux_runtime_net_udp_batch_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_net_workers_o(argv0: *u8): i32;
export extern "C" function shux_runtime_net_workers_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_asm_io_stubs_o(argv0: *u8): i32;
export extern "C" function shux_runtime_asm_io_stubs_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_thread_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_thread_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_formal_std_make_o(repo_root: *u8, rel_from_repo: *u8, make_target: *u8): i32;
export extern "C" function shux_ensure_runtime_env_os_o(argv0: *u8): i32;
export extern "C" function shux_runtime_env_os_o_path(argv0: *u8): *u8;

/* ===== wave201 Cap residual / peer pure for ensure-push mid (sync→hash) ===== */
export extern "C" function shux_ensure_runtime_sync_lock_diag_tls_o(argv0: *u8): i32;
export extern "C" function shux_runtime_sync_lock_diag_tls_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_sync_os_o(argv0: *u8): i32;
export extern "C" function shux_runtime_sync_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_ed25519_ref10_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_ed25519_ref10_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_crypto_inc_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_crypto_inc_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_log_os_o(argv0: *u8): i32;
export extern "C" function shux_runtime_log_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_atomic_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_atomic_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_channel_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_channel_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_backtrace_platform_o(argv0: *u8): i32;
export extern "C" function shux_runtime_backtrace_platform_o_path(argv0: *u8): *u8;

/* ===== wave202 Cap residual / peer pure for ensure-push heavy_a (math…compress) ===== */
export extern "C" function shux_ensure_runtime_math_libm_o(argv0: *u8): i32;
export extern "C" function shux_runtime_math_libm_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_sqlite_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_sqlite_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_compress_zlib_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_compress_zlib_glue_o_path(argv0: *u8): *u8;
export extern "C" function link_abi_generated_c_provides_core_mem(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_provides_std_heap(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_zlib(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_zstd(c_path: *u8): i32;
export extern "C" function link_abi_generated_c_needs_brotli(c_path: *u8): i32;
export extern "C" function invoke_cc_append_compress_ld(argv: **u8, ia: *i32, argv_cap: i32, compress_o: *u8, user_o: *u8): void;
export extern "C" function ld_append_brew_lib_paths(argv: **u8, la: *i32, max_la: i32): void;

/* ===== wave203 Cap residual / peer pure for ensure-push heavy_b (unicode…process_argv) ===== */
export extern "C" function shux_ensure_runtime_dynlib_os_o(argv0: *u8): i32;
export extern "C" function shux_runtime_dynlib_os_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_http_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_http_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_test_fn_invoke_o(argv0: *u8): i32;
export extern "C" function shux_runtime_test_fn_invoke_o_path(argv0: *u8): *u8;
export extern "C" function shux_ensure_runtime_scheduler_glue_o(argv0: *u8): i32;
export extern "C" function shux_runtime_scheduler_glue_o_path(argv0: *u8): *u8;
export extern "C" function shux_std_async_scheduler_o_path(argv0: *u8): *u8;
export extern "C" function shux_generated_c_needs_async_scheduler(c_path: *u8): i32;
export extern "C" function scheduler_o_for_task_link(task_o: *u8, explicit_scheduler: *u8): *u8;
export extern "C" function shux_link_obj_needs_undef_sym(user_o: *u8, sym: *u8): i32;
export extern "C" function strstr(hay: *u8, needle: *u8): *u8;

/* ===== wave204 Cap residual / peer pure for heap F-06 on-demand ===== */
/* nm-based heap U scan over argv (peer pure in labi_ondemand_list). */
export extern "C" function link_abi_link_needs_std_heap_import(user_o: *u8, argv: **u8, la: i32): i32;
/* page_mmap.o rel path peer pure (labi_ondemand_list); heap.o always imports freestanding mmap path. */
export extern "C" function labi_od_rel_page_mmap(): *u8;

/* ===== wave205 Cap residual / peer pure for fork-exec shell + strip ===== */
/* Authority spawn public (wave219 pure thin under labi_diag_pure L1 hybrid;
 * Cap residual shux_spawn_sync_impl = fork/exec/wait or _spawnvp always mega).
 * G.7 complete; no second fork path in invoke_cc pure. */
export extern "C" function shux_spawn_sync(prog: *u8, argv: **u8): i32;
/* Freestanding / empty PATH: set before spawn so gcc/ld resolve (was child-only setenv). */
export extern "C" function setenv(name: *u8, value: *u8, overwrite: i32): i32;
export extern "C" function strcmp(a: *u8, b: *u8): i32;
/* Diag on all-cc-candidates fail (status often -1 after spawn_sync collapses wait bits). */
export extern "C" function link_diag_tool_status(tool: *u8, status: i32): void;
/* Cap residual: best-effort `strip -x out` (local argv pack; pure cannot safely build **u8 table). */
export extern "C" function invoke_cc_strip_out_x(out_path: *u8): void;

/* ===== wave206 Cap residual / peer pure for argv head flags ===== */
/* getenv already exported at file top (SHUX_RUN_QUIET); host_is_linux / host_is_apple / skip_native / harden_impl are pure peers. */

/* ===== wave207 Cap residual / peer pure for argv tail flags ===== */
/* Return path if .o exists (non-null → linkable); used for optional -pthread gate. */
export extern "C" function asm_link_obj_skip_missing(path: *u8): *u8;
/* CLI user .o table authority (mega g_shux_user_extra_o_files via count/at). */
export extern "C" function link_abi_user_extra_o_count(): i32;
export extern "C" function link_abi_user_extra_o_at(i: i32): *u8;

/** Exported function `labi_linux_harden_flag_count`.
 * Implements `labi_linux_harden_flag_count`.
 * @return i32
 */
#[no_mangle]
export function labi_linux_harden_flag_count(): i32 {
  return 5;
}

/** Exported function `labi_linux_harden_flag_at`.
 * Implements `labi_linux_harden_flag_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_linux_harden_flag_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "-pie";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "-fpie";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "-Wl,-z,noexecstack";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "-Wl,-z,relro";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "-Wl,--allow-multiple-definition";
    return p;
  }
  return 0 as *u8;
}

/** Exported function `labi_invoke_cc_skip_native_env_count`.
 * Implements `labi_invoke_cc_skip_native_env_count`.
 * @return i32
 */
#[no_mangle]
export function labi_invoke_cc_skip_native_env_count(): i32 {
  return 3;
}

/** Exported function `labi_invoke_cc_skip_native_env_at`.
 * Implements `labi_invoke_cc_skip_native_env_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_invoke_cc_skip_native_env_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "CI";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "SHUX_CI_DOCKER";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "SHUX_NO_MARCH_NATIVE";
    return p;
  }
  return 0 as *u8;
}

// invoke_cc_skip_native_tuning: see function docblock below.
/** Exported function `invoke_cc_skip_native_tuning`.
 * Implements `invoke_cc_skip_native_tuning`.
 * @return i32
 */
#[no_mangle]
export function invoke_cc_skip_native_tuning(): i32 {
  let n: i32 = labi_invoke_cc_skip_native_env_count();
  let i: i32 = 0;
  while (i < n) {
    let name: *u8 = labi_invoke_cc_skip_native_env_at(i);
    if (name != 0 as *u8) {
      if (name[0] != 0) {
        let v: *u8 = 0 as *u8;
        unsafe {
          v = getenv(name);
        }
        if (v != 0 as *u8) {
          return 1;
        }
      }
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `labi_icc_rel_core_builtin_o`.
 * Implements `labi_icc_rel_core_builtin_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_builtin_o(): *u8 {
  let p: *u8 = "core/builtin/builtin.o";
  return p;
}

/** Exported function `labi_icc_rel_core_builtin_abi_h`.
 * Implements `labi_icc_rel_core_builtin_abi_h`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_builtin_abi_h(): *u8 {
  let p: *u8 = "core/builtin/builtin_abi.h";
  return p;
}

/** Exported function `labi_icc_rel_core_mem_o`.
 * Implements `labi_icc_rel_core_mem_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_mem_o(): *u8 {
  let p: *u8 = "core/mem/mem.o";
  return p;
}

/** Exported function `labi_icc_rel_core_slice_o`.
 * Implements `labi_icc_rel_core_slice_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_core_slice_o(): *u8 {
  let p: *u8 = "core/slice/slice.o";
  return p;
}

/** Exported function `labi_icc_rel_db_kv_o`.
 * Implements `labi_icc_rel_db_kv_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_db_kv_o(): *u8 {
  let p: *u8 = "std/db/kv/kv.o";
  return p;
}

/** Exported function `labi_icc_rel_db_arrow_o`.
 * Implements `labi_icc_rel_db_arrow_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_db_arrow_o(): *u8 {
  let p: *u8 = "std/db/arrow/arrow.o";
  return p;
}

/** Exported function `labi_icc_rel_csv_o`.
 * Implements `labi_icc_rel_csv_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_csv_o(): *u8 {
  let p: *u8 = "std/csv/csv.o";
  return p;
}

/** Exported function `labi_icc_rel_error_o`.
 * Implements `labi_icc_rel_error_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_error_o(): *u8 {
  let p: *u8 = "std/error/error.o";
  return p;
}

/** Exported function `labi_icc_rel_heap_o`.
 * Implements `labi_icc_rel_heap_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_heap_o(): *u8 {
  let p: *u8 = "std/heap/heap.o";
  return p;
}

/** Exported function `labi_icc_rel_json_o`.
 * Implements `labi_icc_rel_json_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_json_o(): *u8 {
  let p: *u8 = "std/json/json.o";
  return p;
}

/** Exported function `labi_icc_rel_log_o`.
 * Implements `labi_icc_rel_log_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_log_o(): *u8 {
  let p: *u8 = "std/log/log.o";
  return p;
}

/** Exported function `labi_icc_rel_socketio_o`.
 * Implements `labi_icc_rel_socketio_o`.
 * @return *u8
 */
#[no_mangle]
export function labi_icc_rel_socketio_o(): *u8 {
  let p: *u8 = "std/socketio/socketio.o";
  return p;
}

/** Exported function `labi_icc_needs_rel_count`.
 * Implements `labi_icc_needs_rel_count`.
 * @return i32
 */
#[no_mangle]
export function labi_icc_needs_rel_count(): i32 {
  return 12;
}

/** Exported function `labi_icc_needs_rel_at`.
 * Implements `labi_icc_needs_rel_at`.
 * @param i i32
 * @return *u8
 */
#[no_mangle]
export function labi_icc_needs_rel_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "core/builtin/builtin.o";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "core/builtin/builtin_abi.h";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "core/mem/mem.o";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "core/slice/slice.o";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std/db/kv/kv.o";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std/db/arrow/arrow.o";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std/csv/csv.o";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std/error/error.o";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std/heap/heap.o";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std/json/json.o";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std/log/log.o";
    return p;
  }
  if (i == 11) {
    let p: *u8 = "std/socketio/socketio.o";
    return p;
  }
  return 0 as *u8;
}

/**
 * Append Linux release link-hardening flags onto a cc/ld argv (PIE + NX stack + partial RELRO).
 * Scans pure labi_linux_harden_flag_count/at and appends each non-empty flag while capacity remains.
 * @param argv **u8 — linker argv table (char**); null → no-op
 * @param la *i32 — in/out argv length; null → no-op; *la < 0 → no-op
 * @param cap i32 — argv capacity; leave one slot for NULL terminator (cap - 1)
 * @return void — appends zero or more harden flags; skips null/empty table entries
 * Pure orch: pure harden table count/at + capacity-guarded append loop (≡ mega cold twin).
 * Why (wave155): hybrid still had always-mega C body for Linux harden flag append over pure table.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Callers: pure gate shux_append_linux_link_harden (labi_gates) + product invoke_cc/ld paths.
 * PLATFORM: SHARED orch / LINUX consumers (flags are Linux ld/gcc -Wl,-z*; mac no-op if not called).
 * Track-L: #[no_mangle] keeps surface short name matching mega / gates Cap residual extern.
 */
#[no_mangle]
export function shux_append_linux_link_harden_impl(argv: **u8, la: *i32, cap: i32): void {
  // Guard argv null via *u8 cast (wave147/151–154: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (la == 0 as *i32) {
    return;
  }
  // Mega rejects negative length; leave one slot for argv NULL terminator.
  if (la[0] < 0) {
    return;
  }
  let n: i32 = labi_linux_harden_flag_count();
  let k: i32 = 0;
  while (k < n) {
    let cur: i32 = la[0];
    if (cur >= cap - 1) {
      break;
    }
    let f: *u8 = labi_linux_harden_flag_at(k);
    k = k + 1;
    if (f == 0 as *u8) {
      continue;
    }
    if (f[0] == 0) {
      continue;
    }
    // Store table pointer (static string lifetime from pure flag_at; no copy).
    argv[cur] = f;
    la[0] = cur + 1;
  }
}

/**
 * Capacity-guarded push of one non-empty flag onto invoke_cc argv.
 * @param argv **u8 — argv table; null → no-op
 * @param ia *i32 — in/out length; null or *ia < 0 → no-op
 * @param cap i32 — capacity; leave one slot for NULL terminator
 * @param flag *u8 — flag string; null/empty skipped
 * @return void
 * PLATFORM: SHARED helper for wave198 early needs flag appends (-lc / -lbcrypt / …).
 * Track-L: #[no_mangle] keeps surface short name for prove IDENTICAL (no module mangle).
 */
#[no_mangle]
export function labi_icc_argv_try_push_flag(argv: **u8, ia: *i32, cap: i32, flag: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  if (flag == 0 as *u8) {
    return;
  }
  if (flag[0] == 0) {
    return;
  }
  let cur: i32 = ia[0];
  if (cur >= cap - 1) {
    return;
  }
  argv[cur] = flag;
  ia[0] = cur + 1;
}

/**
 * invoke_cc early needs: scan generated C paths then ensure/push core|db|fs|random|time|runtime|win32|heap.
 * Composes peer pure needs_* / rel_o / push_existing / path / ensure + host_is_* platform gates.
 * @param argv **u8 — cc argv table (char**); null → no-op
 * @param ia *i32 — in/out argv length; null → no-op; *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity; leave one slot for NULL terminator
 * @param c_paths **u8 — generated C path table; null or n < 1 → no-op scan
 * @param n i32 — number of c_paths entries
 * @param include_root *u8 — repo/include root for rel_o_path (nullable)
 * @param random_o *u8 — product random.o path (nullable; push_existing skips missing)
 * @param time_o *u8 — product time.o path (nullable)
 * @param runtime_o *u8 — product runtime.o path (nullable)
 * @param runtime_panic_o *u8 — product runtime_panic.o path (nullable)
 * @return void — may append -include / .o paths / -l* flags; mutates *ia
 * Pure orch: ≡ mega early block inside shux_invoke_cc_impl (pre-MINIMAL_CC_LINK).
 * Cap residual: generated_c_needs_* (file view peers) + ensure_runtime_* + host_is_windows
 *   + peer push_existing resolve pool; host_is_linux / host_is_apple for -lc POSIX gate.
 * Why (wave198): hybrid still had early needs scan+push always-mega inside invoke_cc_impl.
 * Note: export signature must stay single-line (multi-line export drops the function).
 * Callers: mega shux_invoke_cc_impl child argv build (SHARED product C link path).
 * PLATFORM: SHARED orch / POSIX -lc (linux|apple) / WINDOWS -lbcrypt -lkernel32 -lws2_32.
 * Track-L: #[no_mangle] keeps surface short name for mega call sites.
 */
#[no_mangle]
export function invoke_cc_append_early_needs(argv: **u8, ia: *i32, argv_cap: i32, c_paths: **u8, n: i32, include_root: *u8, random_o: *u8, time_o: *u8, runtime_o: *u8, runtime_panic_o: *u8): void {
  // Guard argv/ia null via *u8 cast (wave147/151–197: avoid **u8 null compare codegen drop).
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  let needs_core_builtin: i32 = 0;
  let needs_core_mem: i32 = 0;
  let needs_core_slice: i32 = 0;
  let needs_db_kv: i32 = 0;
  let needs_db_arrow: i32 = 0;
  let needs_fs: i32 = 0;
  let needs_random: i32 = 0;
  let needs_time: i32 = 0;
  let needs_runtime: i32 = 0;
  let needs_win32: i32 = 0;
  let needs_win32_wsa: i32 = 0;
  let needs_libc_heap: i32 = 0;
  // Scan all generated C paths (peer pure needs_* use_line / marker gates).
  if (n > 0) {
    let cpb: *u8 = c_paths as *u8;
    if (cpb != 0 as *u8) {
      let j: i32 = 0;
      while (j < n) {
        let cp: *u8 = c_paths[j];
        j = j + 1;
        if (cp == 0 as *u8) {
          continue;
        }
        unsafe {
          if (link_abi_generated_c_needs_core_builtin(cp) != 0) {
            needs_core_builtin = 1;
          }
          if (link_abi_generated_c_needs_core_mem(cp) != 0) {
            needs_core_mem = 1;
          }
          if (link_abi_generated_c_needs_core_slice(cp) != 0) {
            needs_core_slice = 1;
          }
          if (link_abi_generated_c_needs_db_kv(cp) != 0) {
            needs_db_kv = 1;
          }
          if (link_abi_generated_c_needs_db_arrow(cp) != 0) {
            needs_db_arrow = 1;
          }
          if (link_abi_generated_c_needs_fs(cp) != 0) {
            needs_fs = 1;
          }
          if (link_abi_generated_c_needs_random(cp) != 0) {
            needs_random = 1;
          }
          if (link_abi_generated_c_needs_time(cp) != 0) {
            needs_time = 1;
          }
          if (link_abi_generated_c_needs_runtime(cp) != 0) {
            needs_runtime = 1;
          }
          if (link_abi_generated_c_needs_win32(cp) != 0) {
            needs_win32 = 1;
          }
          if (link_abi_generated_c_needs_win32_wsa(cp) != 0) {
            needs_win32_wsa = 1;
          }
          if (link_abi_generated_c_needs_libc_heap(cp) != 0) {
            needs_libc_heap = 1;
          }
        }
      }
    }
  }
  // core.builtin: -include abi.h then push builtin.o when present.
  if (needs_core_builtin != 0) {
    let abi_h: *u8 = 0 as *u8;
    unsafe {
      abi_h = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_abi_h());
    }
    if (abi_h != 0 as *u8) {
      if (abi_h[0] != 0) {
        let cur: i32 = ia[0];
        if (cur < argv_cap - 2) {
          let inc: *u8 = "-include";
          argv[cur] = inc;
          ia[0] = cur + 1;
          argv[ia[0]] = abi_h;
          ia[0] = ia[0] + 1;
        }
      }
    }
    let bpath: *u8 = 0 as *u8;
    unsafe {
      bpath = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_builtin_o());
      let _p0: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, bpath);
    }
  }
  if (needs_core_mem != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o());
      let _pm: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
    }
  }
  if (needs_core_slice != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_slice_o());
      let _ps: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
    }
  }
  if (needs_db_kv != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_kv_o());
      let _pk: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
      let rkv: *u8 = shux_runtime_kv_mmap_glue_o_path(0 as *u8);
      if (rkv != 0 as *u8) {
        if (rkv[0] != 0) {
          let _pk2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rkv);
        }
      }
    }
  }
  if (needs_db_arrow != 0) {
    unsafe {
      let p: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_db_arrow_o());
      let _pa: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
      let rar: *u8 = shux_runtime_arrow_simd_glue_o_path(0 as *u8);
      if (rar != 0 as *u8) {
        if (rar[0] != 0) {
          let _pa2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rar);
        }
      }
    }
  }
  // -lc on POSIX when fs needs libc (mega #if linux||apple).
  if (needs_fs != 0) {
    let is_posix: i32 = 0;
    unsafe {
      is_posix = shux_host_is_linux();
      if (is_posix == 0) {
        is_posix = link_abi_host_is_apple();
      }
    }
    if (is_posix != 0) {
      let flc: *u8 = 0 as *u8;
      unsafe {
        flc = labi_ld_flag_lc();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc);
    }
  }
  // random.o + ensure random_fill before push (L4 cold tree; G.7 ensure-then-push).
  if (needs_random != 0) {
    unsafe {
      let _pr: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, random_o);
      let _er: i32 = shux_ensure_runtime_random_fill_o(0 as *u8);
      let rrf: *u8 = shux_runtime_random_fill_o_path(0 as *u8);
      if (rrf != 0 as *u8) {
        if (rrf[0] != 0) {
          let _pr2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rrf);
        }
      }
    }
    // PLATFORM: WINDOWS — BCrypt needs -lbcrypt; Linux/macOS use getrandom/getentropy.
    let is_win: i32 = 0;
    unsafe {
      is_win = link_abi_host_is_windows();
    }
    if (is_win != 0) {
      let fbc: *u8 = 0 as *u8;
      unsafe {
        fbc = labi_ld_flag_lbcrypt();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fbc);
    }
  }
  if (needs_time != 0) {
    unsafe {
      let _pt: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, time_o);
      let _et: i32 = shux_ensure_runtime_time_os_o(0 as *u8);
      let rto: *u8 = shux_runtime_time_os_o_path(0 as *u8);
      if (rto != 0 as *u8) {
        if (rto[0] != 0) {
          let _pt2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rto);
        }
      }
    }
  }
  if (needs_runtime != 0) {
    unsafe {
      let _prt: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_o);
      let _ep: i32 = shux_ensure_runtime_panic_o(0 as *u8);
      let _pp: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_panic_o);
      let rp: *u8 = shux_runtime_panic_o_path(0 as *u8);
      if (rp != 0 as *u8) {
        if (rp[0] != 0) {
          let _pp2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rp);
        }
      }
    }
  }
  // PLATFORM: WINDOWS — win32 / WSA link flags only when generated C needs them.
  if (needs_win32 != 0) {
    let is_win2: i32 = 0;
    unsafe {
      is_win2 = link_abi_host_is_windows();
    }
    if (is_win2 != 0) {
      let fk: *u8 = "-lkernel32";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fk);
    }
  }
  if (needs_win32_wsa != 0) {
    let is_win3: i32 = 0;
    unsafe {
      is_win3 = link_abi_host_is_windows();
    }
    if (is_win3 != 0) {
      let fws: *u8 = 0 as *u8;
      unsafe {
        fws = labi_ld_flag_lws2_32();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fws);
    }
  }
  if (needs_libc_heap != 0) {
    let is_posix2: i32 = 0;
    unsafe {
      is_posix2 = shux_host_is_linux();
      if (is_posix2 == 0) {
        is_posix2 = link_abi_host_is_apple();
      }
    }
    if (is_posix2 != 0) {
      let flc2: *u8 = 0 as *u8;
      unsafe {
        flc2 = labi_ld_flag_lc();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc2);
    }
  }
}

/* ===== wave199 Cap residual pure: invoke_cc std module need scan ===== */
export extern "C" function link_abi_generated_c_contains_substr_use_line(c_path: *u8, needle: *u8): i32;
export extern "C" function link_abi_generated_c_contains_substr(c_path: *u8, needle: *u8): i32;

/**
 * Count of std-module need flag slots written by invoke_cc_scan_std_module_needs.
 * @return i32 — 52 (process..panic); mega flags[] must be at least this long
 * PLATFORM: SHARED — pure table size
 */
#[no_mangle]
export function labi_icc_std_need_count(): i32 {
  return 52;
}


/**
 * Needle count for one std-module need id (use_line OR of needles).
 * @param mid i32 — module id 0..51 (see labi_icc_std_need_count)
 * @return i32 — needle count; 0 if mid out of range
 * PLATFORM: SHARED pure table
 */
#[no_mangle]
export function labi_icc_std_need_needle_count(mid: i32): i32 {

  if (mid == 0) {
    return 5;
  }
  if (mid == 1) {
    return 8;
  }
  if (mid == 2) {
    return 2;
  }
  if (mid == 3) {
    return 3;
  }
  if (mid == 4) {
    return 1;
  }
  if (mid == 5) {
    return 18;
  }
  if (mid == 6) {
    return 3;
  }
  if (mid == 7) {
    return 3;
  }
  if (mid == 8) {
    return 2;
  }
  if (mid == 9) {
    return 3;
  }
  if (mid == 10) {
    return 3;
  }
  if (mid == 11) {
    return 1;
  }
  if (mid == 12) {
    return 3;
  }
  if (mid == 13) {
    return 5;
  }
  if (mid == 14) {
    return 3;
  }
  if (mid == 15) {
    return 4;
  }
  if (mid == 16) {
    return 3;
  }
  if (mid == 17) {
    return 2;
  }
  if (mid == 18) {
    return 3;
  }
  if (mid == 19) {
    return 3;
  }
  if (mid == 20) {
    return 3;
  }
  if (mid == 21) {
    return 10;
  }
  if (mid == 22) {
    return 2;
  }
  if (mid == 23) {
    return 3;
  }
  if (mid == 24) {
    return 2;
  }
  if (mid == 25) {
    return 2;
  }
  if (mid == 26) {
    return 2;
  }
  if (mid == 27) {
    return 2;
  }
  if (mid == 28) {
    return 4;
  }
  if (mid == 29) {
    return 2;
  }
  if (mid == 30) {
    return 2;
  }
  if (mid == 31) {
    return 3;
  }
  if (mid == 32) {
    return 3;
  }
  if (mid == 33) {
    return 1;
  }
  if (mid == 34) {
    return 8;
  }
  if (mid == 35) {
    return 2;
  }
  if (mid == 36) {
    return 1;
  }
  if (mid == 37) {
    return 3;
  }
  if (mid == 38) {
    return 3;
  }
  if (mid == 39) {
    return 2;
  }
  if (mid == 40) {
    return 1;
  }
  if (mid == 41) {
    return 1;
  }
  if (mid == 42) {
    return 1;
  }
  if (mid == 43) {
    return 1;
  }
  if (mid == 44) {
    return 1;
  }
  if (mid == 45) {
    return 1;
  }
  if (mid == 46) {
    return 2;
  }
  if (mid == 47) {
    return 3;
  }
  if (mid == 48) {
    return 1;
  }
  if (mid == 49) {
    return 1;
  }
  if (mid == 50) {
    return 1;
  }
  if (mid == 51) {
    return 1;
  }
  return 0;
}


/**
 * Needle string at index for std-module need id.
 * @param mid i32 — module id 0..51
 * @param i i32 — needle index; out of range → null
 * @return *u8 — NUL-terminated needle; null if invalid
 * PLATFORM: SHARED pure table
 */
#[no_mangle]
export function labi_icc_std_need_needle_at(mid: i32, i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }

  if (mid == 0) {
    if (i == 0) {
      let p: *u8 = "std_process_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "shux_process_spawn";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "shux_process_wait";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "process_spawn";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "process_exec";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 1) {
    if (i == 0) {
      let p: *u8 = "process_shux_argc_get";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "process_shux_argv_get";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "process_args_count_c";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "process_arg_c";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "args_iter_count_c";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "args_iter_at_c";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "std_process_args";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "std_env_args_iter";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 2) {
    if (i == 0) {
      let p: *u8 = "std_string_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "shux_string_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 3) {
    if (i == 0) {
      let p: *u8 = "std_path_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "path_join";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "path_dirname";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 4) {
    if (i == 0) {
      let p: *u8 = "std_runtime_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 5) {
    if (i == 0) {
      let p: *u8 = "std_net_listen";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "std_net_connect";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "std_net_udp_bind";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "std_net_udp_recv";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "std_net_udp_send";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "std_net_addr_to_u32";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "std_net_close_udp";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "net_tcp_connect_c";
      return p;
    }
    if (i == 8) {
      let p: *u8 = "net_tcp_listen_c";
      return p;
    }
    if (i == 9) {
      let p: *u8 = "net_udp_bind_c";
      return p;
    }
    if (i == 10) {
      let p: *u8 = "net_udp_recv_many_buf_c";
      return p;
    }
    if (i == 11) {
      let p: *u8 = "net_udp_send_many_buf_c";
      return p;
    }
    if (i == 12) {
      let p: *u8 = "net_udp_send_c";
      return p;
    }
    if (i == 13) {
      let p: *u8 = "net_dns_resolve_c";
      return p;
    }
    if (i == 14) {
      let p: *u8 = "net_sock_create_c";
      return p;
    }
    if (i == 15) {
      let p: *u8 = "net_stream_write_batch_c";
      return p;
    }
    if (i == 16) {
      let p: *u8 = "net_close_socket_c_real";
      return p;
    }
    if (i == 17) {
      let p: *u8 = "net_run_accept_workers_c_real";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 6) {
    if (i == 0) {
      let p: *u8 = "std_thread_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "thread_create_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "thread_join_c";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 7) {
    if (i == 0) {
      let p: *u8 = "std_time_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "time_now_";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "time_sleep_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 8) {
    if (i == 0) {
      let p: *u8 = "std_random_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "random_fill_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 9) {
    if (i == 0) {
      let p: *u8 = "std_env_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "env_get_";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "env_set_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 10) {
    if (i == 0) {
      let p: *u8 = "std_sync_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "sync_mutex_";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "sync_rwlock_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 11) {
    if (i == 0) {
      let p: *u8 = "std_encoding_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 12) {
    if (i == 0) {
      let p: *u8 = "std_base64_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "base64_encode";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "base64_decode";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 13) {
    if (i == 0) {
      let p: *u8 = "std_crypto_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "core_crypto_mem_eq";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "core_crypto_sha";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "crypto_sha";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "ed25519_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 14) {
    if (i == 0) {
      let p: *u8 = "std_log_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "log_write_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "log_info_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 15) {
    if (i == 0) {
      let p: *u8 = "std_atomic_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "atomic_load_i32_c";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "atomic_store_i32_c";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "atomic_fetch_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 16) {
    if (i == 0) {
      let p: *u8 = "std_channel_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "channel_send";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "channel_recv";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 17) {
    if (i == 0) {
      let p: *u8 = "std_backtrace_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "backtrace_capture";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 18) {
    if (i == 0) {
      let p: *u8 = "std_hash_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "hash_fnv";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "hash_sip";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 19) {
    if (i == 0) {
      let p: *u8 = "std_math_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "math_sin";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "math_cos";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 20) {
    if (i == 0) {
      let p: *u8 = "std_sort_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "sort_i32";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "sort_stable";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 21) {
    if (i == 0) {
      let p: *u8 = "std_vec_new";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "std_vec_push";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "std_vec_len_Vec";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "std_vec_len_ptr";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "std_vec_with_capacity";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "std_vec_from_slice";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "std_vec_append";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "std_vec_reserve";
      return p;
    }
    if (i == 8) {
      let p: *u8 = "std_vec_clear";
      return p;
    }
    if (i == 9) {
      let p: *u8 = "std_vec_free";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 22) {
    if (i == 0) {
      let p: *u8 = "std_ffi_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "ffi_call";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 23) {
    if (i == 0) {
      let p: *u8 = "std_db_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "sqlite3_";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "db_sqlite_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 24) {
    if (i == 0) {
      let p: *u8 = "std_elf_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "elf_parse";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 25) {
    if (i == 0) {
      let p: *u8 = "std_json_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "json_parse_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 26) {
    if (i == 0) {
      let p: *u8 = "std_csv_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "csv_next_field";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 27) {
    if (i == 0) {
      let p: *u8 = "std_regex_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "regex_match";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 28) {
    if (i == 0) {
      let p: *u8 = "std_compress_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "compress_gzip";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "compress_zstd";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "compress_brotli";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 29) {
    if (i == 0) {
      let p: *u8 = "std_unicode_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "unicode_utf8";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 30) {
    if (i == 0) {
      let p: *u8 = "std_dynlib_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "dynlib_open";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 31) {
    if (i == 0) {
      let p: *u8 = "std_http_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "http_request";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "http2_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 32) {
    if (i == 0) {
      let p: *u8 = "std_tar_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "tar_open";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "tar_extract";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 33) {
    if (i == 0) {
      let p: *u8 = "std_simd_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 34) {
    if (i == 0) {
      let p: *u8 = "std_context_background(";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "std_context_with_cancel(";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "std_context_with_deadline(";
      return p;
    }
    if (i == 3) {
      let p: *u8 = "std_context_with_timeout(";
      return p;
    }
    if (i == 4) {
      let p: *u8 = "std_context_cancel(";
      return p;
    }
    if (i == 5) {
      let p: *u8 = "std_context_set_value(";
      return p;
    }
    if (i == 6) {
      let p: *u8 = "std_context_get_value(";
      return p;
    }
    if (i == 7) {
      let p: *u8 = "std_context_free(";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 35) {
    if (i == 0) {
      let p: *u8 = "std_error_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "error_wrap_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 36) {
    if (i == 0) {
      let p: *u8 = "std_datetime_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 37) {
    if (i == 0) {
      let p: *u8 = "std_uuid_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "uuid_v4";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "uuid_parse";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 38) {
    if (i == 0) {
      let p: *u8 = "std_url_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "url_parse";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "url_join";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 39) {
    if (i == 0) {
      let p: *u8 = "std_cli_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "cli_parse";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 40) {
    if (i == 0) {
      let p: *u8 = "std_security_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 41) {
    if (i == 0) {
      let p: *u8 = "std_config_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 42) {
    if (i == 0) {
      let p: *u8 = "std_cache_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 43) {
    if (i == 0) {
      let p: *u8 = "std_trace_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 44) {
    if (i == 0) {
      let p: *u8 = "std_task_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 45) {
    if (i == 0) {
      let p: *u8 = "std_schema_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 46) {
    if (i == 0) {
      let p: *u8 = "std_test_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "test_call_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 47) {
    if (i == 0) {
      let p: *u8 = "std_socketio_";
      return p;
    }
    if (i == 1) {
      let p: *u8 = "socketio_emit";
      return p;
    }
    if (i == 2) {
      let p: *u8 = "socketio_on";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 48) {
    if (i == 0) {
      let p: *u8 = "std_set_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 49) {
    if (i == 0) {
      let p: *u8 = "std_map_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 50) {
    if (i == 0) {
      let p: *u8 = "std_queue_";
      return p;
    }
    return 0 as *u8;
  }
  if (mid == 51) {
    if (i == 0) {
      let p: *u8 = "shux_panic_(";
      return p;
    }
    return 0 as *u8;
  }
  return 0 as *u8;
}


/**
 * Scan generated C paths and set std-module need flags (OR across paths).
 * Composes pure needle tables + Cap residual peer contains_substr_use_line.
 * Special mid=51 panic: use_line "shux_panic_(" AND not co-emit body via contains_substr.
 * @param c_paths **u8 — generated C path table; null or n < 1 → zero flags only
 * @param n i32 — number of c_paths entries
 * @param flags *i32 — out flags bank; each slot 0/1; null → no-op
 * @param flags_cap i32 — length of flags; must be >= labi_icc_std_need_count() (52)
 * @return void — zeros flags[0..count) then ORs hits; does not touch flags beyond count
 * Pure orch: ≡ mega std need scan loop inside shux_invoke_cc_impl (pre ensure-push).
 * Cap residual: link_abi_generated_c_contains_substr_use_line + contains_substr (file view).
 * Why (wave199): hybrid still had std need scan always-mega inside invoke_cc_impl.
 * Flag index map (stable):
 *   0 process 1 process_argv_glue 2 string 3 path 4 runtime 5 net 6 thread 7 time
 *   8 random 9 env 10 sync 11 encoding 12 base64 13 crypto 14 log 15 atomic
 *   16 channel 17 backtrace 18 hash 19 math 20 sort 21 vec 22 ffi 23 db
 *   24 elf 25 json 26 csv 27 regex 28 compress 29 unicode 30 dynlib 31 http
 *   32 tar 33 simd 34 context 35 error 36 datetime 37 uuid 38 url 39 cli
 *   40 security 41 config 42 cache 43 trace 44 task 45 schema 46 test 47 socketio
 *   48 set 49 map 50 queue 51 panic
 * Callers: mega shux_invoke_cc_impl after early needs / MINIMAL path (SHARED product C link).
 * PLATFORM: SHARED orch
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_scan_std_module_needs(c_paths: **u8, n: i32, flags: *i32, flags_cap: i32): void {
  if (flags == 0 as *i32) {
    return;
  }
  if (flags_cap < 52) {
    return;
  }
  let k: i32 = 0;
  while (k < 52) {
    flags[k] = 0;
    k = k + 1;
  }
  if (n < 1) {
    return;
  }
  let cpb: *u8 = c_paths as *u8;
  if (cpb == 0 as *u8) {
    return;
  }
  let j: i32 = 0;
  while (j < n) {
    let cp: *u8 = c_paths[j];
    j = j + 1;
    if (cp == 0 as *u8) {
      continue;
    }
    let mid: i32 = 0;
    while (mid < 52) {
      // panic (51): use_line + not co-emit body
      if (mid == 51) {
        let hit_panic: i32 = 0;
        unsafe {
          hit_panic = link_abi_generated_c_contains_substr_use_line(cp, "shux_panic_(");
        }
        if (hit_panic != 0) {
          let body1: i32 = 0;
          let body2: i32 = 0;
          unsafe {
            body1 = link_abi_generated_c_contains_substr(cp, "void shux_panic_(int has_msg, int msg_val) {");
            body2 = link_abi_generated_c_contains_substr(cp, "void shux_panic_(int has_msg, int msg_val){");
          }
          if (body1 == 0) {
            if (body2 == 0) {
              flags[51] = 1;
            }
          }
        }
        mid = mid + 1;
        continue;
      }
      let nc: i32 = labi_icc_std_need_needle_count(mid);
      let ni: i32 = 0;
      while (ni < nc) {
        let nd: *u8 = labi_icc_std_need_needle_at(mid, ni);
        ni = ni + 1;
        if (nd == 0 as *u8) {
          continue;
        }
        let hit: i32 = 0;
        unsafe {
          hit = link_abi_generated_c_contains_substr_use_line(cp, nd);
        }
        if (hit != 0) {
          flags[mid] = 1;
          // OR done for this mid on this path; still continue other mids
          ni = nc;
        }
      }
      mid = mid + 1;
    }
  }
}

/**
 * invoke_cc ensure-push front: string → process → heap → path → runtime → panic →
 * net → thread → time → random → env (contiguous prefix; preserves link argv order).
 * Composes Cap residual ensure/path/push peers + pure labi_icc_argv_try_push_flag.
 * Mutates need_flags[6] (thread) when net.o is linked (workers → thread_create_c).
 * @param argv **u8 — cc argv table; null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity (leave room for NULL terminator later)
 * @param need_flags *i32 — flags bank from invoke_cc_scan_std_module_needs; null → no-op
 * @param flags_cap i32 — must be >= 52
 * @param include_root *u8 — repo/include root for formal time ensure + rel paths (nullable)
 * @param process_o *u8 — product process.o path (nullable)
 * @param string_o *u8 — product string.o path (nullable)
 * @param heap_o *u8 — product heap.o path (nullable; push if non-empty)
 * @param path_o *u8 — product path.o path (nullable)
 * @param runtime_o *u8 — product runtime.o path (nullable)
 * @param runtime_panic_o *u8 — product runtime_panic.o path (nullable)
 * @param net_o *u8 — product net.o path (nullable)
 * @param thread_o *u8 — product thread.o path (nullable)
 * @param time_o *u8 — product time.o path (nullable; fallback after formal ensure)
 * @param random_o *u8 — product random.o path (nullable)
 * @param env_o *u8 — product env.o path (nullable)
 * @return void — appends .o paths and platform -l* / -pthread flags; mutates *ia and flags[6]
 * Pure orch: ≡ mega ensure-push front inside shux_invoke_cc_impl (after std need scan).
 * Cap residual: ensure_runtime_* + push_existing resolve pool + formal_std_make + net_tls_ld.
 * Why (wave200): hybrid still had ensure-push front always-mega after wave199 flags bank.
 * Tail residual (sync…process_argv complement) + heap F-06 + fork/exec remain mega.
 * Callers: mega shux_invoke_cc_impl after invoke_cc_scan_std_module_needs.
 * PLATFORM: SHARED orch / LINUX -pthread + asm_io_stubs with net / WINDOWS -lws2_32 -lbcrypt.
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_std_ensure_push_front(argv: **u8, ia: *i32, argv_cap: i32, need_flags: *i32, flags_cap: i32, include_root: *u8, process_o: *u8, string_o: *u8, heap_o: *u8, path_o: *u8, runtime_o: *u8, runtime_panic_o: *u8, net_o: *u8, thread_o: *u8, time_o: *u8, random_o: *u8, env_o: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  if (need_flags == 0 as *i32) {
    return;
  }
  if (flags_cap < 52) {
    return;
  }
  let need_process: i32 = need_flags[0];
  let need_process_argv_glue: i32 = need_flags[1];
  let need_string: i32 = need_flags[2];
  let need_path: i32 = need_flags[3];
  let need_runtime: i32 = need_flags[4];
  let need_net: i32 = need_flags[5];
  let need_thread: i32 = need_flags[6];
  let need_time: i32 = need_flags[7];
  let need_random: i32 = need_flags[8];
  let need_env: i32 = need_flags[9];
  let need_panic: i32 = need_flags[51];

  // string.o: co-emit scan historically no-op; always push when need_string.
  if (need_string != 0) {
    unsafe {
      let _ps: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, string_o);
    }
  }

  // process.o + optional -pthread; else ensure process_argv glue (no double-link).
  let pushed_process_o: i32 = 0;
  if (need_process != 0) {
    let pr: i32 = 0;
    unsafe {
      pr = invoke_cc_argv_push_existing(argv, ia, argv_cap, process_o);
    }
    if (pr != 0) {
      pushed_process_o = 1;
      let is_lin: i32 = 0;
      unsafe {
        is_lin = shux_host_is_linux();
      }
      if (is_lin != 0) {
        let pthr: *u8 = "-pthread";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, pthr);
      }
    }
  }
  if (pushed_process_o == 0) {
    if (need_process != 0 || need_env != 0 || need_process_argv_glue != 0) {
      unsafe {
        let _epa: i32 = shux_ensure_runtime_process_argv_o(0 as *u8);
        let rpa: *u8 = shux_runtime_process_argv_o_path(0 as *u8);
        if (rpa != 0 as *u8) {
          if (rpa[0] != 0) {
            let _ppa: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rpa);
          }
        }
      }
    }
  }

  // heap.o always candidate when path non-empty (F-06 on-demand complement is still mega).
  if (heap_o != 0 as *u8) {
    if (heap_o[0] != 0) {
      unsafe {
        let _ph: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, heap_o);
      }
    }
  }
  if (need_path != 0) {
    unsafe {
      let _pp: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, path_o);
    }
  }
  if (need_runtime != 0) {
    unsafe {
      let _pru: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_o);
    }
  }
  // PLATFORM: SHARED — need_panic/need_runtime must ensure then push (L4 cold may lack .o).
  if (need_panic != 0 || need_runtime != 0) {
    unsafe {
      let _ep: i32 = shux_ensure_runtime_panic_o(0 as *u8);
      let _ppn: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, runtime_panic_o);
      let rp: *u8 = shux_runtime_panic_o_path(0 as *u8);
      if (rp != 0 as *u8) {
        if (rp[0] != 0) {
          let _ppn2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rp);
        }
      }
    }
  }

  // net.o + tls ld + udp_batch + workers; force need_thread; Linux asm_io_stubs; Win ws2_32.
  if (need_net != 0) {
    let pn: i32 = 0;
    unsafe {
      pn = invoke_cc_argv_push_existing(argv, ia, argv_cap, net_o);
    }
    if (pn != 0) {
      unsafe {
        let _nt: i32 = invoke_cc_append_net_tls_ld(argv, ia, argv_cap, net_o, include_root);
        let _eub: i32 = shux_ensure_runtime_net_udp_batch_o(0 as *u8);
        let rnub: *u8 = shux_runtime_net_udp_batch_o_path(0 as *u8);
        if (rnub != 0 as *u8) {
          if (rnub[0] != 0) {
            let _pub: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rnub);
          }
        }
        let _enw: i32 = shux_ensure_runtime_net_workers_o(0 as *u8);
        let rnw: *u8 = shux_runtime_net_workers_o_path(0 as *u8);
        if (rnw != 0 as *u8) {
          if (rnw[0] != 0) {
            let _pnw: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rnw);
          }
        }
      }
      // workers.x U thread_*; same authority as asm on_demand after have_net.
      need_thread = 1;
      need_flags[6] = 1;
      let is_lin2: i32 = 0;
      unsafe {
        is_lin2 = shux_host_is_linux();
      }
      if (is_lin2 != 0) {
        unsafe {
          let _eis: i32 = shux_ensure_runtime_asm_io_stubs_o(0 as *u8);
          let ris: *u8 = shux_runtime_asm_io_stubs_o_path(0 as *u8);
          if (ris != 0 as *u8) {
            if (ris[0] != 0) {
              let _pis: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, ris);
            }
          }
        }
      }
      let is_win: i32 = 0;
      unsafe {
        is_win = link_abi_host_is_windows();
      }
      if (is_win != 0) {
        let fws: *u8 = 0 as *u8;
        unsafe {
          fws = labi_ld_flag_lws2_32();
        }
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fws);
      }
    }
  }

  // thread.o + thread_glue (ensure after push success — product path present).
  if (need_thread != 0) {
    let pt: i32 = 0;
    unsafe {
      pt = invoke_cc_argv_push_existing(argv, ia, argv_cap, thread_o);
    }
    if (pt != 0) {
      unsafe {
        let _etg: i32 = shux_ensure_runtime_thread_glue_o(0 as *u8);
        let rtg: *u8 = shux_runtime_thread_glue_o_path(0 as *u8);
        if (rtg != 0 as *u8) {
          if (rtg[0] != 0) {
            let _ptg: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rtg);
          }
        }
      }
    }
  }

  // PLATFORM: SHARED — formal time.o ensure + push decoupled from glue ensure (dedup).
  if (need_time != 0) {
    if (include_root != 0 as *u8) {
      if (include_root[0] != 0) {
        let rel_t: *u8 = "std/time/time.o";
        let mt_t: *u8 = "../std/time/time.o";
        unsafe {
          let _eft: i32 = shux_ensure_formal_std_make_o(include_root, rel_t, mt_t);
        }
      }
    }
    unsafe {
      let time_push: *u8 = shux_rel_o_path_from_argv0(include_root, "std/time/time.o");
      let use_fallback: i32 = 0;
      if (time_push == 0 as *u8) {
        use_fallback = 1;
      } else {
        if (time_push[0] == 0) {
          use_fallback = 1;
        }
      }
      if (use_fallback != 0) {
        if (time_o != 0 as *u8) {
          if (time_o[0] != 0) {
            time_push = time_o;
          }
        }
      }
      let _ptp: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, time_push);
      let _eto: i32 = shux_ensure_runtime_time_os_o(0 as *u8);
      let rto: *u8 = shux_runtime_time_os_o_path(0 as *u8);
      if (rto != 0 as *u8) {
        if (rto[0] != 0) {
          let _pto: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rto);
        }
      }
    }
  }

  if (need_random != 0) {
    unsafe {
      let _prnd: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, random_o);
      let _erf: i32 = shux_ensure_runtime_random_fill_o(0 as *u8);
      let rrf: *u8 = shux_runtime_random_fill_o_path(0 as *u8);
      if (rrf != 0 as *u8) {
        if (rrf[0] != 0) {
          let _prf: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rrf);
        }
      }
    }
    let is_win2: i32 = 0;
    unsafe {
      is_win2 = link_abi_host_is_windows();
    }
    if (is_win2 != 0) {
      let fbc: *u8 = 0 as *u8;
      unsafe {
        fbc = labi_ld_flag_lbcrypt();
      }
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fbc);
    }
  }

  // env.o optional; argv glue already handled above when process.o missing.
  if (need_env != 0) {
    unsafe {
      let _pe: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, env_o);
      let _eeo: i32 = shux_ensure_runtime_env_os_o(0 as *u8);
      let reo: *u8 = shux_runtime_env_os_o_path(0 as *u8);
      if (reo != 0 as *u8) {
        if (reo[0] != 0) {
          let _peo: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, reo);
        }
      }
    }
  }
}

/**
 * invoke_cc ensure-push mid: sync → encoding → base64 → crypto → log → atomic →
 * channel → backtrace → hash (contiguous after front; preserves link argv order).
 * Composes Cap residual ensure/path/push peers + pure labi_icc_argv_try_push_flag +
 * labi_icc_rel_log_o. Does not mutate need_flags (unlike front net→thread).
 * @param argv **u8 — cc argv table; null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity (leave room for NULL terminator later)
 * @param need_flags *i32 — flags bank from invoke_cc_scan_std_module_needs; null → no-op
 * @param flags_cap i32 — must be >= 52
 * @param include_root *u8 — repo root for log.o rel path (nullable)
 * @param sync_o *u8 — product sync.o path (nullable)
 * @param encoding_o *u8 — product encoding.o path (nullable)
 * @param base64_o *u8 — product base64.o path (nullable)
 * @param crypto_o *u8 — product crypto.o path (nullable)
 * @param atomic_o *u8 — product atomic.o path (nullable)
 * @param channel_o *u8 — product channel.o path (nullable; marker optional)
 * @param backtrace_o *u8 — product backtrace.o path (nullable; marker optional)
 * @param hash_o *u8 — product hash.o path (nullable)
 * @return void — appends .o paths and platform ld flags; mutates *ia
 * Pure orch: ≡ mega ensure-push mid inside shux_invoke_cc_impl (after front).
 * Cap residual: ensure_runtime_sync_* / crypto glues / log_os / atomic / channel /
 *   backtrace_platform + push_existing resolve pool.
 * Why (wave201): hybrid still had ensure-push mid always-mega after wave200 front.
 * Heavy tail residual (math…process_argv complement) + heap F-06 + fork/exec remain mega.
 * Callers: mega shux_invoke_cc_impl after invoke_cc_append_std_ensure_push_front.
 * PLATFORM: SHARED orch / LINUX -rdynamic -ldl on backtrace / APPLE -export_dynamic /
 *   WINDOWS -ldbghelp on backtrace.
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_std_ensure_push_mid(argv: **u8, ia: *i32, argv_cap: i32, need_flags: *i32, flags_cap: i32, include_root: *u8, sync_o: *u8, encoding_o: *u8, base64_o: *u8, crypto_o: *u8, atomic_o: *u8, channel_o: *u8, backtrace_o: *u8, hash_o: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  if (need_flags == 0 as *i32) {
    return;
  }
  if (flags_cap < 52) {
    return;
  }
  let need_sync: i32 = need_flags[10];
  let need_encoding: i32 = need_flags[11];
  let need_base64: i32 = need_flags[12];
  let need_crypto: i32 = need_flags[13];
  let need_log: i32 = need_flags[14];
  let need_atomic: i32 = need_flags[15];
  let need_channel: i32 = need_flags[16];
  let need_backtrace: i32 = need_flags[17];
  let need_hash: i32 = need_flags[18];

  // PLATFORM: SHARED — cold tree may lack runtime_sync_*.o; ensure then push (not push-only).
  if (need_sync != 0) {
    let ps: i32 = 0;
    unsafe {
      ps = invoke_cc_argv_push_existing(argv, ia, argv_cap, sync_o);
    }
    if (ps != 0) {
      unsafe {
        let _esld: i32 = shux_ensure_runtime_sync_lock_diag_tls_o(0 as *u8);
        let rsld: *u8 = shux_runtime_sync_lock_diag_tls_o_path(0 as *u8);
        if (rsld != 0 as *u8) {
          if (rsld[0] != 0) {
            let _psld: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rsld);
          }
        }
        let _eso: i32 = shux_ensure_runtime_sync_os_o(0 as *u8);
        let rso: *u8 = shux_runtime_sync_os_o_path(0 as *u8);
        if (rso != 0 as *u8) {
          if (rso[0] != 0) {
            let _pso: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rso);
          }
        }
      }
    }
  }

  if (need_encoding != 0) {
    unsafe {
      let _penc: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, encoding_o);
    }
  }
  if (need_base64 != 0) {
    unsafe {
      let _pb64: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, base64_o);
    }
  }

  if (need_crypto != 0) {
    unsafe {
      let _pc: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, crypto_o);
      let _eed: i32 = shux_ensure_runtime_ed25519_ref10_glue_o(0 as *u8);
      let red: *u8 = shux_runtime_ed25519_ref10_glue_o_path(0 as *u8);
      if (red != 0 as *u8) {
        if (red[0] != 0) {
          let _ped: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, red);
        }
      }
      let _eci: i32 = shux_ensure_runtime_crypto_inc_glue_o(0 as *u8);
      let rci: *u8 = shux_runtime_crypto_inc_glue_o_path(0 as *u8);
      if (rci != 0 as *u8) {
        if (rci[0] != 0) {
          let _pci: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rci);
        }
      }
    }
  }

  // log.o via pure rel table + ensure log_os (same as mega: not pre-resolved log_o arg).
  if (need_log != 0) {
    let log_rel: *u8 = labi_icc_rel_log_o();
    let log_path: *u8 = 0 as *u8;
    unsafe {
      log_path = shux_rel_o_path_from_argv0(include_root, log_rel);
    }
    let pl: i32 = 0;
    unsafe {
      pl = invoke_cc_argv_push_existing(argv, ia, argv_cap, log_path);
    }
    if (pl != 0) {
      unsafe {
        let _elo: i32 = shux_ensure_runtime_log_os_o(0 as *u8);
        let rlo: *u8 = shux_runtime_log_os_o_path(0 as *u8);
        if (rlo != 0 as *u8) {
          if (rlo[0] != 0) {
            let _plo: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rlo);
          }
        }
      }
    }
  }

  // PLATFORM: SHARED — atomic_glue ensure before U atomic_*_c (mac cold bstrict).
  if (need_atomic != 0) {
    let pa: i32 = 0;
    unsafe {
      pa = invoke_cc_argv_push_existing(argv, ia, argv_cap, atomic_o);
    }
    if (pa != 0) {
      unsafe {
        let _eag: i32 = shux_ensure_runtime_atomic_glue_o(0 as *u8);
        let rag: *u8 = shux_runtime_atomic_glue_o_path(0 as *u8);
        if (rag != 0 as *u8) {
          if (rag[0] != 0) {
            let _pag: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rag);
          }
        }
      }
    }
  }

  // channel.o marker optional; API co-emit + runtime_channel_glue.o.
  if (need_channel != 0) {
    unsafe {
      let _pch: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, channel_o);
      let _ecg: i32 = shux_ensure_runtime_channel_glue_o(0 as *u8);
      let rcg: *u8 = shux_runtime_channel_glue_o_path(0 as *u8);
      if (rcg != 0 as *u8) {
        if (rcg[0] != 0) {
          let _pcg: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rcg);
        }
      }
    }
  }

  // backtrace marker optional; platform .o + host ld flags (rdynamic/export_dynamic/dbghelp).
  if (need_backtrace != 0) {
    unsafe {
      let _pbt: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, backtrace_o);
      let _ebp: i32 = shux_ensure_runtime_backtrace_platform_o(0 as *u8);
      let rbp: *u8 = shux_runtime_backtrace_platform_o_path(0 as *u8);
      if (rbp != 0 as *u8) {
        if (rbp[0] != 0) {
          let _pbp: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rbp);
        }
      }
    }
    let is_lin: i32 = 0;
    unsafe {
      is_lin = shux_host_is_linux();
    }
    if (is_lin != 0) {
      let frd: *u8 = "-rdynamic";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, frd);
      let fdl: *u8 = "-ldl";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fdl);
    } else {
      let is_apple: i32 = 0;
      unsafe {
        is_apple = link_abi_host_is_apple();
      }
      if (is_apple != 0) {
        let fex: *u8 = "-Wl,-export_dynamic";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fex);
      } else {
        let is_win: i32 = 0;
        unsafe {
          is_win = link_abi_host_is_windows();
        }
        if (is_win != 0) {
          let fdbg: *u8 = "-ldbghelp";
          labi_icc_argv_try_push_flag(argv, ia, argv_cap, fdbg);
        }
      }
    }
  }

  if (need_hash != 0) {
    unsafe {
      let _ph: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, hash_o);
    }
  }
}

/**
 * invoke_cc ensure-push heavy_a: math → sort → vec → ffi → db → elf → json → csv →
 * set → map → queue → regex → compress (contiguous mid-heavy; preserves link argv order).
 * Composes Cap residual ensure/path/push peers + pure rel tables + co-emit body scans.
 * Does not mutate need_flags. set/map/queue use flags[48..50] (same bank as mega).
 * @param argv **u8 — cc argv table; null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity (leave room for NULL terminator later)
 * @param need_flags *i32 — flags bank from invoke_cc_scan_std_module_needs; null → no-op
 * @param flags_cap i32 — must be >= 52
 * @param include_root *u8 — repo/include root for formal ensure + rel paths (nullable)
 * @param c_paths **u8 — generated C paths for co-emit / compress lib scan (nullable if n<=0)
 * @param n i32 — count of c_paths entries
 * @param math_o *u8 — product math.o fallback path after formal ensure (nullable)
 * @param sort_o *u8 — product sort.o path (nullable; skipped when co-emit body present)
 * @param ffi_o *u8 — product ffi.o path (nullable)
 * @param db_o *u8 — product db.o path (nullable; sqlite glue + -lsqlite3 on push)
 * @param elf_o *u8 — product elf.o path (nullable)
 * @param regex_o *u8 — product regex.o path (nullable)
 * @param compress_o *u8 — product compress.o path (nullable; else scan zlib/zstd/brotli)
 * @param hash_o *u8 — product hash.o path (nullable; set.o U needs hash)
 * @return void — appends .o paths and -lm/-lsqlite3/-lz* flags; mutates *ia only
 * Pure orch: ≡ mega ensure-push heavy slice math…compress inside shux_invoke_cc_impl.
 * Cap residual: formal_std_make / math_libm / sqlite / compress_ld / brew paths / provides_*.
 * Why (wave202): hybrid still had ensure-push heavy always-mega after wave201 mid.
 * Residual heavy_b (unicode…process_argv) pure @ wave203; heap F-06 + fork/exec remain mega.
 * Callers: mega shux_invoke_cc_impl after invoke_cc_append_std_ensure_push_mid.
 * PLATFORM: SHARED orch; brew -L is mac-oriented peer (ld_append_brew_lib_paths).
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_std_ensure_push_heavy_a(argv: **u8, ia: *i32, argv_cap: i32, need_flags: *i32, flags_cap: i32, include_root: *u8, c_paths: **u8, n: i32, math_o: *u8, sort_o: *u8, ffi_o: *u8, db_o: *u8, elf_o: *u8, regex_o: *u8, compress_o: *u8, hash_o: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  if (need_flags == 0 as *i32) {
    return;
  }
  if (flags_cap < 52) {
    return;
  }
  let need_math: i32 = need_flags[19];
  let need_sort: i32 = need_flags[20];
  let need_vec: i32 = need_flags[21];
  let need_ffi: i32 = need_flags[22];
  let need_db: i32 = need_flags[23];
  let need_elf: i32 = need_flags[24];
  let need_json: i32 = need_flags[25];
  let need_csv: i32 = need_flags[26];
  let need_regex: i32 = need_flags[27];
  let need_compress: i32 = need_flags[28];
  let need_set: i32 = need_flags[48];
  let need_map: i32 = need_flags[49];
  let need_queue: i32 = need_flags[50];
  // Guard c_paths via *u8 cast (wave147/151–201: avoid **u8 null compare codegen drop).
  let cpb: *u8 = c_paths as *u8;
  let has_c_paths: i32 = 0;
  if (cpb != 0 as *u8) {
    if (n > 0) {
      has_c_paths = 1;
    }
  }

  // PLATFORM: SHARED — L4 wipe removes formal math.o; ensure then re-resolve (not stale math_o).
  if (need_math != 0) {
    if (include_root != 0 as *u8) {
      if (include_root[0] != 0) {
        let rel_m: *u8 = "std/math/math.o";
        let mt_m: *u8 = "../std/math/math.o";
        unsafe {
          let _em: i32 = shux_ensure_formal_std_make_o(include_root, rel_m, mt_m);
        }
      }
    }
    let math_push: *u8 = 0 as *u8;
    unsafe {
      let rel_math: *u8 = "std/math/math.o";
      math_push = shux_rel_o_path_from_argv0(include_root, rel_math);
    }
    if (math_push == 0 as *u8 || math_push[0] == 0) {
      if (math_o != 0 as *u8) {
        if (math_o[0] != 0) {
          math_push = math_o;
        }
      }
    }
    let pm: i32 = 0;
    unsafe {
      pm = invoke_cc_argv_push_existing(argv, ia, argv_cap, math_push);
    }
    if (pm != 0) {
      unsafe {
        let _eml: i32 = shux_ensure_runtime_math_libm_o(0 as *u8);
        let rml: *u8 = shux_runtime_math_libm_o_path(0 as *u8);
        if (rml != 0 as *u8) {
          if (rml[0] != 0) {
            let _pml: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rml);
          }
        }
      }
      let flm: *u8 = "-lm";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flm);
    }
  }

  // sort.o only when not co-emitted (body openers std_sort_sort_… / std_sort_sort().
  if (need_sort != 0) {
    let have_sort_body: i32 = 0;
    if (has_c_paths != 0) {
      let jscan: i32 = 0;
      while (jscan < n) {
        let cp: *u8 = c_paths[jscan];
        jscan = jscan + 1;
        if (cp == 0 as *u8) {
          continue;
        }
        unsafe {
          let h1: i32 = link_abi_generated_c_contains_substr(cp, "void std_sort_sort_");
          let h2: i32 = link_abi_generated_c_contains_substr(cp, "void std_sort_sort(");
          if (h1 != 0 || h2 != 0) {
            have_sort_body = 1;
          }
        }
        if (have_sort_body != 0) {
          break;
        }
      }
    }
    if (have_sort_body == 0) {
      unsafe {
        let _ps: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, sort_o);
      }
    }
  }

  // PLATFORM: SHARED — vec.o link_only: body open-brace only (not extern prototypes).
  // Formal U needs heap + core mem; mirror set/map ensure+push when C does not provide.
  if (need_vec != 0) {
    let have_vec_body: i32 = 0;
    if (has_c_paths != 0) {
      let jv: i32 = 0;
      while (jv < n) {
        let cpv: *u8 = c_paths[jv];
        jv = jv + 1;
        if (cpv == 0 as *u8) {
          continue;
        }
        unsafe {
          let v1: i32 = link_abi_generated_c_contains_substr(cpv, "std_vec_new_retVec_u8(void) {");
          let v2: i32 = link_abi_generated_c_contains_substr(cpv, "std_vec_new_retVec_u8(void){");
          let v3: i32 = link_abi_generated_c_contains_substr(cpv, "std_vec_push_Vec_u8_ptr_u8(struct std_vec_Vec_u8 * v, uint8_t x) {");
          let v4: i32 = link_abi_generated_c_contains_substr(cpv, "std_vec_push_Vec_u8_ptr_u8(struct std_vec_Vec_u8 *v, uint8_t x){");
          if (v1 != 0 || v2 != 0 || v3 != 0 || v4 != 0) {
            have_vec_body = 1;
          }
        }
        if (have_vec_body != 0) {
          break;
        }
      }
    }
    if (have_vec_body == 0) {
      let c_prov_cm_v: i32 = 0;
      let c_prov_sh_v: i32 = 0;
      if (has_c_paths != 0) {
        let jv2: i32 = 0;
        while (jv2 < n) {
          let cpv2: *u8 = c_paths[jv2];
          jv2 = jv2 + 1;
          if (cpv2 == 0 as *u8) {
            continue;
          }
          unsafe {
            if (link_abi_generated_c_provides_core_mem(cpv2) != 0) {
              c_prov_cm_v = 1;
            }
            if (link_abi_generated_c_provides_std_heap(cpv2) != 0) {
              c_prov_sh_v = 1;
            }
          }
        }
      }
      if (include_root != 0 as *u8) {
        if (include_root[0] != 0) {
          unsafe {
            let _ev: i32 = shux_ensure_formal_std_make_o(include_root, "std/vec/vec.o", "../std/vec/vec.o");
            if (c_prov_sh_v == 0) {
              let _eh: i32 = shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
            }
            if (c_prov_cm_v == 0) {
              let _em: i32 = shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
            }
          }
        }
      }
      let pvec: i32 = 0;
      unsafe {
        pvec = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, "std/vec/vec.o"));
      }
      if (pvec != 0) {
        if (c_prov_sh_v == 0) {
          unsafe {
            let _phv: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
          }
        }
        if (c_prov_cm_v == 0) {
          unsafe {
            let _pmv: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
          }
        }
      }
    }
  }

  if (need_ffi != 0) {
    unsafe {
      let _pf: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, ffi_o);
    }
  }

  if (need_db != 0) {
    let pdb: i32 = 0;
    unsafe {
      pdb = invoke_cc_argv_push_existing(argv, ia, argv_cap, db_o);
    }
    if (pdb != 0) {
      unsafe {
        let _esg: i32 = shux_ensure_runtime_sqlite_glue_o(0 as *u8);
        let rsg: *u8 = shux_runtime_sqlite_glue_o_path(0 as *u8);
        if (rsg != 0 as *u8) {
          if (rsg[0] != 0) {
            let _psg: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rsg);
          }
        }
      }
      let fsql: *u8 = "-lsqlite3";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fsql);
    }
  }

  if (need_elf != 0) {
    unsafe {
      let _pe: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, elf_o);
    }
  }
  if (need_json != 0) {
    unsafe {
      let _pj: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_json_o()));
    }
  }
  if (need_csv != 0) {
    unsafe {
      let _pc: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_csv_o()));
    }
  }

  // set.o U: heap alloc + hash_bytes; ensure formal + push heap/mem/hash when needed.
  if (need_set != 0) {
    let c_prov_cm_s: i32 = 0;
    let c_prov_sh_s: i32 = 0;
    if (has_c_paths != 0) {
      let js: i32 = 0;
      while (js < n) {
        let cps: *u8 = c_paths[js];
        js = js + 1;
        if (cps == 0 as *u8) {
          continue;
        }
        unsafe {
          if (link_abi_generated_c_provides_core_mem(cps) != 0) {
            c_prov_cm_s = 1;
          }
          if (link_abi_generated_c_provides_std_heap(cps) != 0) {
            c_prov_sh_s = 1;
          }
        }
      }
    }
    if (include_root != 0 as *u8) {
      if (include_root[0] != 0) {
        unsafe {
          let _es: i32 = shux_ensure_formal_std_make_o(include_root, "std/set/set.o", "../std/set/set.o");
          if (c_prov_sh_s == 0) {
            let _ehs: i32 = shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
          }
          if (c_prov_cm_s == 0) {
            let _ems: i32 = shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
          }
        }
      }
    }
    let pset: i32 = 0;
    unsafe {
      pset = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, "std/set/set.o"));
    }
    if (pset != 0) {
      if (c_prov_sh_s == 0) {
        unsafe {
          let _phs: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
        }
      }
      if (c_prov_cm_s == 0) {
        unsafe {
          let _pms: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
        }
      }
      unsafe {
        let _phash: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, hash_o);
      }
    }
  }

  if (need_map != 0) {
    let c_prov_cm_m: i32 = 0;
    let c_prov_sh_m: i32 = 0;
    if (has_c_paths != 0) {
      let jm: i32 = 0;
      while (jm < n) {
        let cpm: *u8 = c_paths[jm];
        jm = jm + 1;
        if (cpm == 0 as *u8) {
          continue;
        }
        unsafe {
          if (link_abi_generated_c_provides_core_mem(cpm) != 0) {
            c_prov_cm_m = 1;
          }
          if (link_abi_generated_c_provides_std_heap(cpm) != 0) {
            c_prov_sh_m = 1;
          }
        }
      }
    }
    if (include_root != 0 as *u8) {
      if (include_root[0] != 0) {
        unsafe {
          let _emap: i32 = shux_ensure_formal_std_make_o(include_root, "std/map/map.o", "../std/map/map.o");
          if (c_prov_sh_m == 0) {
            let _ehm: i32 = shux_ensure_formal_std_make_o(include_root, "std/heap/heap.o", "../std/heap/heap.o");
          }
          if (c_prov_cm_m == 0) {
            let _emm: i32 = shux_ensure_formal_std_make_o(include_root, "core/mem/mem.o", "../core/mem/mem.o");
          }
        }
      }
    }
    let pmap: i32 = 0;
    unsafe {
      pmap = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, "std/map/map.o"));
    }
    if (pmap != 0) {
      if (c_prov_sh_m == 0) {
        unsafe {
          let _phm: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
        }
      }
      if (c_prov_cm_m == 0) {
        unsafe {
          let _pmm: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
        }
      }
    }
  }

  if (need_queue != 0) {
    let pque: i32 = 0;
    unsafe {
      pque = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, "std/queue/queue.o"));
    }
    if (pque != 0) {
      let c_prov_cm_q: i32 = 0;
      let c_prov_sh_q: i32 = 0;
      if (has_c_paths != 0) {
        let jq: i32 = 0;
        while (jq < n) {
          let cpq: *u8 = c_paths[jq];
          jq = jq + 1;
          if (cpq == 0 as *u8) {
            continue;
          }
          unsafe {
            if (link_abi_generated_c_provides_core_mem(cpq) != 0) {
              c_prov_cm_q = 1;
            }
            if (link_abi_generated_c_provides_std_heap(cpq) != 0) {
              c_prov_sh_q = 1;
            }
          }
        }
      }
      if (c_prov_sh_q == 0) {
        unsafe {
          let _phq: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o()));
        }
      }
      if (c_prov_cm_q == 0) {
        unsafe {
          let _pmq: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o()));
        }
      }
    }
  }

  if (need_regex != 0) {
    unsafe {
      let _prx: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, regex_o);
    }
  }

  // compress.o + pure compress_ld; if not (need_compress && push ok), scan C for -lz*.
  // Matches mega: if (need && push) compress_ld; else scan zlib/zstd/brotli.
  let compress_pushed: i32 = 0;
  if (need_compress != 0) {
    unsafe {
      compress_pushed = invoke_cc_argv_push_existing(argv, ia, argv_cap, compress_o);
    }
    if (compress_pushed != 0) {
      unsafe {
        invoke_cc_append_compress_ld(argv, ia, argv_cap, compress_o, 0 as *u8);
      }
    }
  }
  if (compress_pushed == 0) {
    let needs_zlib: i32 = 0;
    let needs_zstd: i32 = 0;
    let needs_brotli: i32 = 0;
    if (has_c_paths != 0) {
      let jz: i32 = 0;
      while (jz < n) {
        let cpz: *u8 = c_paths[jz];
        jz = jz + 1;
        if (cpz == 0 as *u8) {
          continue;
        }
        unsafe {
          if (link_abi_generated_c_needs_zlib(cpz) != 0) {
            needs_zlib = 1;
          }
          if (link_abi_generated_c_needs_zstd(cpz) != 0) {
            needs_zstd = 1;
          }
          if (link_abi_generated_c_needs_brotli(cpz) != 0) {
            needs_brotli = 1;
          }
        }
      }
    }
    if (needs_zlib != 0 || needs_zstd != 0 || needs_brotli != 0) {
      unsafe {
        ld_append_brew_lib_paths(argv, ia, argv_cap);
      }
      if (needs_zlib != 0) {
        let flz: *u8 = "-lz";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, flz);
        unsafe {
          let _ez: i32 = shux_ensure_runtime_compress_zlib_glue_o(0 as *u8);
          let rz: *u8 = shux_runtime_compress_zlib_glue_o_path(0 as *u8);
          let _pz: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rz);
        }
      }
      if (needs_zstd != 0) {
        let fzs: *u8 = "-lzstd";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fzs);
      }
      if (needs_brotli != 0) {
        let fbe: *u8 = "-lbrotlienc";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fbe);
        let fbd: *u8 = "-lbrotlidec";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fbd);
      }
    }
  }
}

/**
 * invoke_cc ensure-push heavy_b: unicode → dynlib → http → socketio → tar → simd →
 * context → error → datetime → uuid → url → cli → security → config → cache →
 * trace → task/schema/test → async scheduler → process_argv complement.
 * Composes Cap residual ensure/path/push peers + co-emit unicode body scan +
 * post-push process_argv UNDEF scan. Local need_error may rise when http pushes.
 * @param argv **u8 — cc argv table; null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity (leave room for NULL terminator later)
 * @param need_flags *i32 — flags bank from invoke_cc_scan_std_module_needs; null → no-op
 * @param flags_cap i32 — must be >= 52
 * @param include_root *u8 — repo root for rel socketio/error + async_scheduler (nullable)
 * @param c_paths **u8 — generated C paths for unicode co-emit / async scan (nullable if n<=0)
 * @param n i32 — count of c_paths entries
 * @param unicode_o *u8 — product unicode.o path (nullable; skipped when co-emit body present)
 * @param dynlib_o *u8 — product dynlib.o path (nullable; + dynlib_os + LINUX -ldl)
 * @param http_o *u8 — product http.o path (nullable; + http_glue + WINDOWS -lws2_32; sets need_error)
 * @param tar_o *u8 — product tar.o path (nullable)
 * @param simd_o *u8 — product simd.o path (nullable)
 * @param context_o *u8 — product context.o path (nullable)
 * @param datetime_o *u8 — product datetime.o path (nullable)
 * @param uuid_o *u8 — product uuid.o path (nullable)
 * @param url_o *u8 — product url.o path (nullable)
 * @param cli_o *u8 — product cli.o path (nullable)
 * @param security_o *u8 — product security.o path (nullable)
 * @param config_o *u8 — product config.o path (nullable)
 * @param cache_o *u8 — product cache.o path (nullable)
 * @param trace_o *u8 — product trace.o path (nullable)
 * @param task_o *u8 — product task.o path (nullable; pulls scheduler + glue + LINUX -pthread)
 * @param schema_o *u8 — product schema.o path (nullable)
 * @param test_o *u8 — product test.o path (nullable; + test_fn_invoke glue)
 * @param async_scheduler_o *u8 — explicit async_scheduler.o path (nullable; else scan C needs)
 * @return void — appends .o paths and platform ld flags; mutates *ia only
 * Pure orch: ≡ mega ensure-push heavy slice unicode…process_argv inside shux_invoke_cc_impl.
 * Cap residual: dynlib_os / http_glue / test_fn_invoke / scheduler_glue / async path /
 *   scheduler_o_for_task_link / link_obj_needs_undef_sym / process_argv ensure+path.
 * Why (wave203): hybrid still had ensure-push heavy_b always-mega after wave202 heavy_a.
 * Residual heap F-06 pure @ wave204; fork/exec remain mega.
 * Callers: mega shux_invoke_cc_impl after invoke_cc_append_std_ensure_push_heavy_a.
 * PLATFORM: SHARED orch / LINUX -ldl -pthread / WINDOWS -lws2_32 on http.
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_std_ensure_push_heavy_b(argv: **u8, ia: *i32, argv_cap: i32, need_flags: *i32, flags_cap: i32, include_root: *u8, c_paths: **u8, n: i32, unicode_o: *u8, dynlib_o: *u8, http_o: *u8, tar_o: *u8, simd_o: *u8, context_o: *u8, datetime_o: *u8, uuid_o: *u8, url_o: *u8, cli_o: *u8, security_o: *u8, config_o: *u8, cache_o: *u8, trace_o: *u8, task_o: *u8, schema_o: *u8, test_o: *u8, async_scheduler_o: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }
  if (need_flags == 0 as *i32) {
    return;
  }
  if (flags_cap < 52) {
    return;
  }
  let need_unicode: i32 = need_flags[29];
  let need_dynlib: i32 = need_flags[30];
  let need_http: i32 = need_flags[31];
  let need_tar: i32 = need_flags[32];
  let need_simd: i32 = need_flags[33];
  let need_context: i32 = need_flags[34];
  // Local copy: http push may force error.o (mega does not write back to need_flags).
  let need_error: i32 = need_flags[35];
  let need_datetime: i32 = need_flags[36];
  let need_uuid: i32 = need_flags[37];
  let need_url: i32 = need_flags[38];
  let need_cli: i32 = need_flags[39];
  let need_security: i32 = need_flags[40];
  let need_config: i32 = need_flags[41];
  let need_cache: i32 = need_flags[42];
  let need_trace: i32 = need_flags[43];
  let need_task: i32 = need_flags[44];
  let need_schema: i32 = need_flags[45];
  let need_test: i32 = need_flags[46];
  let need_socketio: i32 = need_flags[47];
  // Guard c_paths via *u8 cast (wave147/151–202: avoid **u8 null compare codegen drop).
  let cpb: *u8 = c_paths as *u8;
  let has_c_paths: i32 = 0;
  if (cpb != 0 as *u8) {
    if (n > 0) {
      has_c_paths = 1;
    }
  }

  // unicode.o: skip when co-emit already provides category body (avoid dual def).
  if (need_unicode != 0) {
    let have_unicode_body: i32 = 0;
    if (has_c_paths != 0) {
      let jscan: i32 = 0;
      while (jscan < n) {
        let cp: *u8 = c_paths[jscan];
        jscan = jscan + 1;
        if (cp == 0 as *u8) {
          continue;
        }
        unsafe {
          let h1: i32 = link_abi_generated_c_contains_substr(cp, "int32_t std_unicode_category(");
          let h2: i32 = link_abi_generated_c_contains_substr(cp, "int32_t std_unicode_unicode_category(");
          if (h1 != 0 || h2 != 0) {
            have_unicode_body = 1;
          }
        }
        if (have_unicode_body != 0) {
          break;
        }
      }
    }
    if (have_unicode_body == 0) {
      unsafe {
        let _pu: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, unicode_o);
      }
    }
  }

  // PLATFORM: SHARED dynlib.o + dynlib_os; LINUX -ldl for dlopen.
  if (need_dynlib != 0) {
    let pd: i32 = 0;
    unsafe {
      pd = invoke_cc_argv_push_existing(argv, ia, argv_cap, dynlib_o);
    }
    if (pd != 0) {
      unsafe {
        let _edo: i32 = shux_ensure_runtime_dynlib_os_o(0 as *u8);
        let rdo: *u8 = shux_runtime_dynlib_os_o_path(0 as *u8);
        if (rdo != 0 as *u8) {
          if (rdo[0] != 0) {
            let _pdo: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rdo);
          }
        }
      }
      let is_lin: i32 = 0;
      unsafe {
        is_lin = shux_host_is_linux();
      }
      if (is_lin != 0) {
        let fdl: *u8 = "-ldl";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fdl);
      }
    }
  }

  // http.o + glue; WINDOWS winsock; force need_error for error.o symbols.
  if (need_http != 0) {
    let ph: i32 = 0;
    unsafe {
      ph = invoke_cc_argv_push_existing(argv, ia, argv_cap, http_o);
    }
    if (ph != 0) {
      unsafe {
        let _ehg: i32 = shux_ensure_runtime_http_glue_o(0 as *u8);
        let rhg: *u8 = shux_runtime_http_glue_o_path(0 as *u8);
        if (rhg != 0 as *u8) {
          if (rhg[0] != 0) {
            let _phg: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rhg);
          }
        }
      }
      let is_win: i32 = 0;
      unsafe {
        is_win = link_abi_host_is_windows();
      }
      if (is_win != 0) {
        let fws: *u8 = 0 as *u8;
        unsafe {
          fws = labi_ld_flag_lws2_32();
        }
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fws);
      }
      need_error = 1;
    }
  }

  if (need_socketio != 0) {
    unsafe {
      let _psio: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_socketio_o()));
    }
  }
  if (need_tar != 0) {
    unsafe {
      let _pt: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, tar_o);
    }
  }
  if (need_simd != 0) {
    unsafe {
      let _ps: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, simd_o);
    }
  }
  if (need_context != 0) {
    unsafe {
      let _pcx: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, context_o);
    }
  }
  if (need_error != 0) {
    unsafe {
      let _per: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, shux_rel_o_path_from_argv0(include_root, labi_icc_rel_error_o()));
    }
  }
  if (need_datetime != 0) {
    unsafe {
      let _pdt: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, datetime_o);
    }
  }
  if (need_uuid != 0) {
    unsafe {
      let _puu: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, uuid_o);
    }
  }
  if (need_url != 0) {
    unsafe {
      let _purl: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, url_o);
    }
  }
  if (need_cli != 0) {
    unsafe {
      let _pcli: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, cli_o);
    }
  }
  if (need_security != 0) {
    unsafe {
      let _psec: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, security_o);
    }
  }
  if (need_config != 0) {
    unsafe {
      let _pcfg: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, config_o);
    }
  }
  if (need_cache != 0) {
    unsafe {
      let _pca: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, cache_o);
    }
  }
  if (need_trace != 0) {
    unsafe {
      let _ptr: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, trace_o);
    }
  }

  // task/schema/test + async scheduler (explicit path or generated-C needs scan).
  let sched_link: *u8 = async_scheduler_o;
  let task_linked: i32 = 0;
  if (need_task != 0) {
    unsafe {
      task_linked = invoke_cc_argv_push_existing(argv, ia, argv_cap, task_o);
    }
  }
  if (need_schema != 0) {
    unsafe {
      let _psc: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, schema_o);
    }
  }
  if (need_test != 0) {
    let pte: i32 = 0;
    unsafe {
      pte = invoke_cc_argv_push_existing(argv, ia, argv_cap, test_o);
    }
    if (pte != 0) {
      unsafe {
        let _etfi: i32 = shux_ensure_runtime_test_fn_invoke_o(0 as *u8);
        let rtfi: *u8 = shux_runtime_test_fn_invoke_o_path(0 as *u8);
        if (rtfi != 0 as *u8) {
          if (rtfi[0] != 0) {
            let _ptfi: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rtfi);
          }
        }
      }
    }
  }
  // Resolve scheduler when not explicitly provided.
  let sched_ok: i32 = 0;
  if (sched_link != 0 as *u8) {
    if (sched_link[0] != 0) {
      sched_ok = 1;
    }
  }
  if (sched_ok == 0) {
    if (has_c_paths != 0) {
      let j: i32 = 0;
      while (j < n) {
        let cpj: *u8 = c_paths[j];
        j = j + 1;
        if (cpj == 0 as *u8) {
          continue;
        }
        let needs_as: i32 = 0;
        unsafe {
          needs_as = shux_generated_c_needs_async_scheduler(cpj);
        }
        if (needs_as != 0) {
          unsafe {
            sched_link = shux_std_async_scheduler_o_path(include_root);
          }
          break;
        }
      }
    }
  }
  if (task_linked != 0) {
    let sched: *u8 = 0 as *u8;
    unsafe {
      sched = scheduler_o_for_task_link(task_o, sched_link);
    }
    let psch: i32 = 0;
    unsafe {
      psch = invoke_cc_argv_push_existing(argv, ia, argv_cap, sched);
    }
    if (psch != 0) {
      let is_lin2: i32 = 0;
      unsafe {
        is_lin2 = shux_host_is_linux();
      }
      if (is_lin2 != 0) {
        let fpth: *u8 = "-pthread";
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, fpth);
      }
      unsafe {
        let _esg: i32 = shux_ensure_runtime_scheduler_glue_o(0 as *u8);
        let rsg: *u8 = shux_runtime_scheduler_glue_o_path(0 as *u8);
        if (rsg != 0 as *u8) {
          if (rsg[0] != 0) {
            let _psg: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rsg);
          }
        }
      }
    }
  } else {
    let sched2_ok: i32 = 0;
    if (sched_link != 0 as *u8) {
      if (sched_link[0] != 0) {
        sched2_ok = 1;
      }
    }
    if (sched2_ok != 0) {
      let psch2: i32 = 0;
      unsafe {
        psch2 = invoke_cc_argv_push_existing(argv, ia, argv_cap, sched_link);
      }
      if (psch2 != 0) {
        let is_lin3: i32 = 0;
        unsafe {
          is_lin3 = shux_host_is_linux();
        }
        if (is_lin3 != 0) {
          let fpth2: *u8 = "-pthread";
          labi_icc_argv_try_push_flag(argv, ia, argv_cap, fpth2);
        }
        unsafe {
          let _esg2: i32 = shux_ensure_runtime_scheduler_glue_o(0 as *u8);
          let rsg2: *u8 = shux_runtime_scheduler_glue_o_path(0 as *u8);
          if (rsg2 != 0 as *u8) {
            if (rsg2[0] != 0) {
              let _psg2: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rsg2);
            }
          }
        }
      }
    }
  }

  // PLATFORM: SHARED — after std/*.o pushes, complement process_argv when any linked
  // .o has U process_shux_* (string/math/… preamble weak). Skip if process.o already on line.
  // G.7: complete existing C-backend process_argv path; no second plan table.
  /* process_argv complement after std/*.o pushes */
  let need_pav: i32 = 0;
  let have_process_o: i32 = 0;
  let have_pav: i32 = 0;
  let ai: i32 = 0;
  let nargv: i32 = ia[0];
  while (ai < nargv) {
    let e: *u8 = argv[ai];
    ai = ai + 1;
    if (e == 0 as *u8) {
      break;
    }
    if (e[0] == 45) {
      /* Skip ld flags whose first byte is ASCII '-' (0x2d / 45). */
      continue;
    }
    unsafe {
      let hit_po: *u8 = strstr(e, "process.o");
      let hit_pav_name: *u8 = strstr(e, "process_argv");
      if (hit_po != 0 as *u8) {
        if (hit_pav_name == 0 as *u8) {
          have_process_o = 1;
        }
      }
      let hit_rpa: *u8 = strstr(e, "runtime_process_argv.o");
      let hit_pa: *u8 = strstr(e, "process_argv.o");
      if (hit_rpa != 0 as *u8 || hit_pa != 0 as *u8) {
        have_pav = 1;
      }
      let u1: i32 = shux_link_obj_needs_undef_sym(e, "process_shux_argc_get");
      let u2: i32 = shux_link_obj_needs_undef_sym(e, "process_shux_argv_get");
      if (u1 != 0 || u2 != 0) {
        need_pav = 1;
      }
    }
  }
  if (need_pav != 0) {
    if (have_process_o == 0) {
      if (have_pav == 0) {
        unsafe {
          let _epa: i32 = shux_ensure_runtime_process_argv_o(0 as *u8);
          let rpa: *u8 = shux_runtime_process_argv_o_path(0 as *u8);
          if (rpa != 0 as *u8) {
            if (rpa[0] != 0) {
              let _ppa: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rpa);
            }
          }
        }
      }
    }
  }
}

/**
 * Count of use_line needles for heap F-06 generated-C demand scan.
 * @return i32 — 11 (fixed table; ≡ mega inline list)
 * PLATFORM: SHARED — table pure; no host branch.
 */
#[no_mangle]
export function labi_icc_heap_f06_needle_count(): i32 {
  return 11;
}

/**
 * Heap F-06 use_line needle at index i (std_heap_* symbols).
 * @param i i32 — index in [0, 11); out of range → null
 * @return *u8 — static string literal; null if i out of range
 * Authority for wave204 generated-C heap demand (G.7 table, not mega hardcode).
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function labi_icc_heap_f06_needle_at(i: i32): *u8 {
  if (i < 0) {
    return 0 as *u8;
  }
  if (i == 0) {
    let p: *u8 = "std_heap_alloc_size_zero";
    return p;
  }
  if (i == 1) {
    let p: *u8 = "std_heap_alloc_usize";
    return p;
  }
  if (i == 2) {
    let p: *u8 = "std_heap_default_alloc";
    return p;
  }
  if (i == 3) {
    let p: *u8 = "std_heap_kind_arena";
    return p;
  }
  if (i == 4) {
    let p: *u8 = "std_heap_heap_alloc";
    return p;
  }
  if (i == 5) {
    let p: *u8 = "std_heap_alloc_Allocator";
    return p;
  }
  if (i == 6) {
    let p: *u8 = "std_heap_realloc_Allocator";
    return p;
  }
  if (i == 7) {
    let p: *u8 = "std_heap_free_Allocator";
    return p;
  }
  if (i == 8) {
    let p: *u8 = "std_heap_arena64_alloc";
    return p;
  }
  if (i == 9) {
    let p: *u8 = "std_heap_map_find";
    return p;
  }
  if (i == 10) {
    let p: *u8 = "std_heap_libc_heap_alloc";
    return p;
  }
  return 0 as *u8;
}

/**
 * invoke_cc heap F-06 on-demand: when argv or generated C needs std.heap,
 * push core/mem.o + heap.o (unless co-emitted) and page_mmap + asm_io_stubs.
 * @param argv **u8 — cc argv table (already holds ensure-push std .o); null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity
 * @param c_paths **u8 — generated C paths for use_line + provides scan (nullable if n<=0)
 * @param n i32 — count of c_paths entries
 * @param include_root *u8 — repo root for rel_o_path (nullable; path may fail soft)
 * @return void — mutates *ia only when heap chain is required
 * Pure orch: ≡ mega F-06 block after ensure-push heavy_b inside shux_invoke_cc_impl.
 * Cap residual: link_abi_link_needs_std_heap_import (nm argv) + contains_substr_use_line +
 *   provides_core_mem / provides_std_heap + labi_od_rel_page_mmap + asm_io_stubs ensure/path.
 * Why (wave204): hybrid still had heap F-06 always-mega after wave203 heavy_b.
 * Residual fork/exec pure @ wave205.
 * Callers: mega shux_invoke_cc_impl after invoke_cc_append_std_ensure_push_heavy_b.
 * PLATFORM: SHARED orch (page_mmap companions required on Ubuntu L4 cold for heap UNDEF).
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_heap_f06_ondemand(argv: **u8, ia: *i32, argv_cap: i32, c_paths: **u8, n: i32, include_root: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }

  // (1) nm / argv U scan: already-linked std .o may import heap without C use_line yet.
  let need_heap: i32 = 0;
  unsafe {
    need_heap = link_abi_link_needs_std_heap_import(0 as *u8, argv, ia[0]);
  }

  // (2) generated-C use_line scan: C backend has no user .o yet; nm alone misses refs.
  let cpb: *u8 = c_paths as *u8;
  let has_c_paths: i32 = 0;
  if (cpb != 0 as *u8) {
    if (n > 0) {
      has_c_paths = 1;
    }
  }
  if (need_heap == 0) {
    if (has_c_paths != 0) {
      let nc: i32 = 0;
      unsafe {
        nc = labi_icc_heap_f06_needle_count();
      }
      let cj: i32 = 0;
      while (cj < n) {
        let cp: *u8 = c_paths[cj];
        cj = cj + 1;
        if (cp == 0 as *u8) {
          continue;
        }
        let ki: i32 = 0;
        while (ki < nc) {
          let nd: *u8 = 0 as *u8;
          unsafe {
            nd = labi_icc_heap_f06_needle_at(ki);
          }
          ki = ki + 1;
          if (nd == 0 as *u8) {
            continue;
          }
          let hit: i32 = 0;
          unsafe {
            hit = link_abi_generated_c_contains_substr_use_line(cp, nd);
          }
          if (hit != 0) {
            need_heap = 1;
            break;
          }
        }
        if (need_heap != 0) {
          break;
        }
      }
    }
  }

  if (need_heap == 0) {
    return;
  }

  // Co-emit: skip core/mem.o or heap.o when generated C already provides definitions.
  let c_provides_core_mem: i32 = 0;
  let c_provides_std_heap: i32 = 0;
  if (has_c_paths != 0) {
    let pj: i32 = 0;
    while (pj < n) {
      let cpp: *u8 = c_paths[pj];
      pj = pj + 1;
      if (cpp == 0 as *u8) {
        continue;
      }
      unsafe {
        let pcm: i32 = link_abi_generated_c_provides_core_mem(cpp);
        if (pcm != 0) {
          c_provides_core_mem = 1;
        }
        let psh: i32 = link_abi_generated_c_provides_std_heap(cpp);
        if (psh != 0) {
          c_provides_std_heap = 1;
        }
      }
    }
  }

  if (c_provides_core_mem == 0) {
    unsafe {
      let mem_o: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_core_mem_o());
      let _pm: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, mem_o);
    }
  }
  if (c_provides_std_heap == 0) {
    unsafe {
      let heap_o: *u8 = shux_rel_o_path_from_argv0(include_root, labi_icc_rel_heap_o());
      let _ph: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, heap_o);
    }
  }

  // PLATFORM: SHARED / LINUX gold — heap.o imports page_mmap freestanding path unconditionally.
  // C backend must also push page_mmap.o + runtime_asm_io_stubs (weak mmap/munmap).
  // Symmetric with asm on-demand (labi_od_rel_page_mmap). Root fix 2026-07-19 Ubuntu L4 cold.
  unsafe {
    let pm_rel: *u8 = labi_od_rel_page_mmap();
    let pm_o: *u8 = shux_rel_o_path_from_argv0(include_root, pm_rel);
    let ppm: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, pm_o);
    if (ppm != 0) {
      let _eis: i32 = shux_ensure_runtime_asm_io_stubs_o(0 as *u8);
      let ris: *u8 = shux_runtime_asm_io_stubs_o_path(0 as *u8);
      if (ris != 0 as *u8) {
        if (ris[0] != 0) {
          let _pris: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, ris);
        }
      }
    }
  }
}

/**
 * Append invoke_cc argv head flags: driver, std, quiet, -B, -O*, native, NDEBUG, flto, harden, -o, sections, gc, -I.
 * @param argv **u8 — cc argv table (char**); null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op; starts at 0 for fresh table
 * @param argv_cap i32 — argv capacity; leave one slot for NULL terminator (try_push_flag guards)
 * @param out_path *u8 — product executable path for -o; null/empty still pushes -o then skips path
 * @param opt_level *u8 — optimization level string; null/empty treated as "2" (≡ mega default)
 * @param use_lto i32 — non-zero enables -flto when opt != "0" and native tuning not skipped
 * @param include_root *u8 — optional -I root; null/empty skips -I
 * @return void — mutates *ia and argv slots; writes durable -O* into g_labi_icc_oopt_buf BSS
 * Pure orch: ≡ mega argv head inside shux_invoke_cc_impl (before c_paths loop / early_needs).
 * Cap residual: getenv(SHUX_RUN_QUIET) + pure skip_native_tuning + pure harden_impl + host_is_*.
 * G.7: reuses labi_icc_argv_try_push_flag + shux_append_linux_link_harden_impl (no second flag path).
 * Why (wave206): hybrid still had quiet/O/harden/gc argv head always-mega after wave205 fork-exec pure.
 * PLATFORM: SHARED orch / LINUX -B/usr/bin + harden + --gc-sections / APPLE -dead_strip / WINDOWS no gc/harden.
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_argv_head_flags(argv: **u8, ia: *i32, argv_cap: i32, out_path: *u8, opt_level: *u8, use_lto: i32, include_root: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }

  // Driver + language dialect (preamble uses C11 _Generic → gnu11).
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, "cc");
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-std=gnu11");

  // PLATFORM: SHARED — mute generated-C noise under `shux run` / quiet product path.
  // Mega gates on getenv non-null only (empty value still enables quiet).
  let quiet: *u8 = 0 as *u8;
  unsafe {
    quiet = getenv("SHUX_RUN_QUIET");
  }
  if (quiet != 0 as *u8) {
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-w");
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-Wl,-w");
  }

  // PLATFORM: LINUX — force /usr/bin as compiler driver search root (Alpine/musl host tools).
  let is_linux: i32 = 0;
  unsafe {
    is_linux = shux_host_is_linux();
  }
  if (is_linux != 0) {
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-B/usr/bin");
  }

  // Build durable "-O{level}" into BSS (≡ mega static oopt_buf[8] + snprintf).
  let ol: *u8 = opt_level;
  if (ol == 0 as *u8) {
    ol = "2";
  }
  if (ol[0] == 0) {
    ol = "2";
  }
  g_labi_icc_oopt_buf[0] = 45; // '-'
  g_labi_icc_oopt_buf[1] = 79; // 'O'
  let k: i32 = 0;
  // Cap: 2 prefix + up to 5 level chars + NUL in 8-byte BSS (≡ snprintf sizeof 8).
  while (k < 5) {
    let ch: u8 = ol[k];
    if (ch == 0) {
      break;
    }
    g_labi_icc_oopt_buf[2 + k] = ch;
    k = k + 1;
  }
  g_labi_icc_oopt_buf[2 + k] = 0;
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, g_labi_icc_oopt_buf as *u8);

  // -march=native (+ -mtune=native for -O3); CI/Docker skip via pure skip_native_tuning.
  let skip_nat: i32 = invoke_cc_skip_native_tuning();
  let is2: i32 = 0;
  let is3: i32 = 0;
  unsafe {
    is2 = strcmp(ol, "2");
    is3 = strcmp(ol, "3");
  }
  if (skip_nat == 0) {
    if (is2 == 0 || is3 == 0) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-march=native");
      if (is3 == 0) {
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-mtune=native");
      }
    }
  }

  let is0: i32 = 0;
  unsafe {
    is0 = strcmp(ol, "0");
  }
  // Release: -DNDEBUG; optional -flto when not skipped and not -O0.
  if (is0 != 0) {
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-DNDEBUG");
  }
  if (use_lto != 0) {
    if (is0 != 0) {
      if (skip_nat == 0) {
        labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-flto");
      }
    }
  }

  // PLATFORM: LINUX — PIE + NX + RELRO via pure harden table (wave155).
  if (is_linux != 0) {
    if (is0 != 0) {
      shux_append_linux_link_harden_impl(argv, ia, argv_cap);
    }
  }

  labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-o");
  if (out_path != 0 as *u8) {
    if (out_path[0] != 0) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, out_path);
    }
  }

  // Dead-code GC pair: compile-side function/data sections + link-side strip/gc.
  // Invariant: never pass only --gc-sections without -ffunction-sections (see mega comment).
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-ffunction-sections");
  labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-fdata-sections");

  let is_apple: i32 = 0;
  unsafe {
    is_apple = link_abi_host_is_apple();
  }
  if (is_apple != 0) {
    // PLATFORM: MACOS|DARWIN — Mach-O dead strip from main reachability.
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-Wl,-dead_strip");
  } else {
    if (is_linux != 0) {
      // PLATFORM: LINUX — ELF --gc-sections (pair with function-sections above).
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-Wl,--gc-sections");
    }
  }

  // Optional -I include_root for generated C / std headers.
  if (include_root != 0 as *u8) {
    if (include_root[0] != 0) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, "-I");
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, include_root);
    }
  }
}

/**
 * Append invoke_cc argv tail: POSIX -pthread/-lc, WINDOWS allow-multiple, user_extra .o, NULL terminator.
 * @param argv **u8 — cc argv table; null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity; leave one slot for NULL; try_push_flag guards flags
 * @param thread_o *u8 — product thread.o path (nullable; existence gates -pthread)
 * @param sync_o *u8 — product sync.o path (nullable; existence gates -pthread)
 * @param channel_o *u8 — product channel.o path (nullable; existence gates -pthread)
 * @return void — mutates *ia and argv slots; ends with argv[*ia-1] = NULL when room
 * Pure orch: ≡ mega post-ensure tail inside shux_invoke_cc_impl (before spawn/strip).
 * Cap residual: asm_link_obj_skip_missing + link_abi_user_extra_o_{count,at} + push_existing + host_is_*.
 * G.7: reuses labi_icc_argv_try_push_flag + invoke_cc_argv_push_existing + user_extra count/at (no second table).
 * Why (wave207): hybrid still had -pthread/-lc/allow-multiple/user_extra+NULL always-mega after wave206 head pure.
 * PLATFORM: SHARED orch / POSIX (linux|apple) -pthread when thread|sync|channel .o present + always -lc /
 *   WINDOWS -Wl,--allow-multiple-definition (PE weak alias multi-def; ELF/Mach-O native weak).
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_argv_tail_flags(argv: **u8, ia: *i32, argv_cap: i32, thread_o: *u8, sync_o: *u8, channel_o: *u8): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }

  let is_linux: i32 = 0;
  let is_apple: i32 = 0;
  let is_win: i32 = 0;
  unsafe {
    is_linux = shux_host_is_linux();
    is_apple = link_abi_host_is_apple();
    is_win = link_abi_host_is_windows();
  }

  // PLATFORM: POSIX (linux|apple) — -pthread when any pthread-using std .o is present on disk;
  // always -lc so freestanding-ish links still resolve libc (≡ mega #if linux||apple).
  if (is_linux != 0 || is_apple != 0) {
    let need_pth: i32 = 0;
    let ht: *u8 = 0 as *u8;
    let hs: *u8 = 0 as *u8;
    let hc: *u8 = 0 as *u8;
    unsafe {
      ht = asm_link_obj_skip_missing(thread_o);
      hs = asm_link_obj_skip_missing(sync_o);
      hc = asm_link_obj_skip_missing(channel_o);
    }
    // thread.o uses CPU_ZERO/CPU_SET (sched.h); sync/channel pull pthread via glue.
    if (ht != 0 as *u8) {
      need_pth = 1;
    }
    if (hs != 0 as *u8) {
      need_pth = 1;
    }
    if (hc != 0 as *u8) {
      need_pth = 1;
    }
    if (need_pth != 0) {
      let fpth: *u8 = "-pthread";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, fpth);
    }
    // Prefer pure -lc flag peer when available (G.7); fall back literal if null.
    let flc: *u8 = 0 as *u8;
    unsafe {
      flc = labi_ld_flag_lc();
    }
    if (flc != 0 as *u8) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc);
    } else {
      let flc2: *u8 = "-lc";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc2);
    }
  }

  // PLATFORM: WINDOWS — PE/COFF lacks ELF weak; SHUX_WEAK + codegen weak aliases multi-def.
  // --allow-multiple-definition picks first def (≡ mega Windows-only flag).
  if (is_win != 0) {
    let fam: *u8 = "-Wl,--allow-multiple-definition";
    labi_icc_argv_try_push_flag(argv, ia, argv_cap, fam);
  }

  // CLI user .o after all std/core .o + link flags so user glue resolves last
  // (e.g. runtime_atomic_glue.o provides atomic_load_i32_c for context.o).
  // Authority table: link_abi_user_extra_o_{count,at} (mega g_shux_user_extra_o_files).
  let n_extra: i32 = 0;
  unsafe {
    n_extra = link_abi_user_extra_o_count();
  }
  let ui: i32 = 0;
  while (ui < n_extra) {
    unsafe {
      let p: *u8 = link_abi_user_extra_o_at(ui);
      if (p != 0 as *u8) {
        let _pu: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, p);
      }
    }
    ui = ui + 1;
  }

  // NULL-terminate argv for spawn (try_push_flag leaves room; direct write of null pointer).
  let cur: i32 = ia[0];
  if (cur < argv_cap) {
    argv[cur] = 0 as *u8;
    ia[0] = cur + 1;
  }
}

/**
 * Append SHUX_MINIMAL_CC_LINK branch argv tail: Windows process_argv.o, POSIX -lc, NULL terminator.
 * @param argv **u8 — cc argv table after head+c_paths+early_needs; null → no-op
 * @param ia *i32 — in/out argv length; null or *ia < 0 → no-op
 * @param argv_cap i32 — argv capacity; leave one slot for NULL; try_push_flag guards -lc
 * @return void — mutates *ia and argv slots; ends with argv[*ia-1] = NULL when room
 * Pure orch: ≡ mega SHUX_MINIMAL_CC_LINK block inside shux_invoke_cc_impl (before spawn/strip).
 * Cap residual: shux_runtime_process_argv_o_path (Windows CORE-009 argc/argv defs) + push_existing + host_is_*.
 * G.7: reuses labi_icc_argv_try_push_flag + labi_ld_flag_lc + invoke_cc_argv_push_existing (no second flag path).
 * Why (wave208): hybrid still had MINIMAL branch -lc/process_argv+NULL always-mega after wave207 always-tail pure.
 * Note: getenv("SHUX_MINIMAL_CC_LINK") gate stays mega Cap residual; this leaf only builds the minimal tail.
 * PLATFORM: SHARED orch / WINDOWS process_argv.o (codegen emits extern not weak) / POSIX (linux|apple) -lc only
 *   (minimal skips std ensure-push; shux_process_* weak defs on Linux/mac from generated C).
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_append_minimal_cc_link_tail(argv: **u8, ia: *i32, argv_cap: i32): void {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return;
  }
  if (ia == 0 as *i32) {
    return;
  }
  if (ia[0] < 0) {
    return;
  }

  let is_linux: i32 = 0;
  let is_apple: i32 = 0;
  let is_win: i32 = 0;
  unsafe {
    is_linux = shux_host_is_linux();
    is_apple = link_abi_host_is_apple();
    is_win = link_abi_host_is_windows();
  }

  // PLATFORM: WINDOWS — minimal link still needs runtime_process_argv.o for shux_process_argc/argv
  // (Windows codegen emits extern decls, not weak defs ≡ mega CORE-009 / Docker musl note).
  if (is_win != 0) {
    let rpav: *u8 = 0 as *u8;
    unsafe {
      rpav = shux_runtime_process_argv_o_path(0 as *u8);
    }
    if (rpav != 0 as *u8) {
      if (rpav[0] != 0) {
        unsafe {
          let _pu: i32 = invoke_cc_argv_push_existing(argv, ia, argv_cap, rpav);
        }
      }
    }
  }

  // PLATFORM: POSIX (linux|apple) — only -lc; no -pthread / no std ensure-push on minimal path.
  // Prefer pure -lc flag peer when available (G.7); fall back literal if null.
  if (is_linux != 0 || is_apple != 0) {
    let flc: *u8 = 0 as *u8;
    unsafe {
      flc = labi_ld_flag_lc();
    }
    if (flc != 0 as *u8) {
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc);
    } else {
      let flc2: *u8 = "-lc";
      labi_icc_argv_try_push_flag(argv, ia, argv_cap, flc2);
    }
  }

  // NULL-terminate argv for spawn (same contract as wave207 always-path tail).
  let cur: i32 = ia[0];
  if (cur < argv_cap) {
    argv[cur] = 0 as *u8;
    ia[0] = cur + 1;
  }
}

/**
 * Spawn system cc/gcc with a finished NULL-terminated argv (parent-side, no fork-first).
 * @param argv **u8 — full cc argv ending with null; argv[0] rewritten per candidate; null → -1
 * @return i32 — 0 success (first candidate exit 0); -1 all candidates failed (diag emitted)
 * Pure orch: ≡ mega post-argv fork/exec/wait shell (wave205).
 * Cap residual: setenv(PATH) + host_is_* + shux_spawn_sync (public pure thin wave219
 * → _impl mega) + link_diag_tool_status.
 * Candidate order ≡ historical mega child exec chain:
 *   WINDOWS: gcc only (MinGW; no bare `cc`)
 *   LINUX: gcc, cc, /usr/bin/gcc, /usr/bin/cc, /usr/local/bin/gcc, /usr/local/bin/cc
 *   APPLE / other POSIX: cc, gcc
 * Why: hybrid still had always-mega fork+exec+wait after argv pure (wave198–204).
 * G.7: single spawn authority = shux_spawn_sync (no second fork path in pure).
 * PLATFORM: SHARED orch / POSIX setenv+PATH / WINDOWS spawn gcc only.
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_run_cc_argv(argv: **u8): i32 {
  let ab: *u8 = argv as *u8;
  if (ab == 0 as *u8) {
    return 0 - 1;
  }

  // Freestanding shux_asm child/parent may inherit empty PATH; fix tool lookup.
  // PLATFORM: POSIX primarily; setenv on Windows is harmless when present.
  unsafe {
    let _p: i32 = setenv("PATH", "/usr/local/bin:/usr/bin:/bin", 1);
  }

  let is_win: i32 = 0;
  unsafe {
    is_win = link_abi_host_is_windows();
  }
  if (is_win != 0) {
    // PLATFORM: WINDOWS — no `cc`; MinGW gcc + _spawnvp via shux_spawn_sync.
    let gcc: *u8 = "gcc";
    argv[0] = gcc;
    let rc: i32 = 0;
    unsafe {
      rc = shux_spawn_sync(gcc, argv);
    }
    if (rc == 0) {
      return 0;
    }
    unsafe {
      link_diag_tool_status("cc", rc);
    }
    return 0 - 1;
  }

  let is_linux: i32 = 0;
  unsafe {
    is_linux = shux_host_is_linux();
  }
  if (is_linux != 0) {
    // PLATFORM: LINUX — Alpine prefers gcc argv[0]; absolute paths if PATH still broken.
    let c0: *u8 = "gcc";
    let c1: *u8 = "cc";
    let c2: *u8 = "/usr/bin/gcc";
    let c3: *u8 = "/usr/bin/cc";
    let c4: *u8 = "/usr/local/bin/gcc";
    let c5: *u8 = "/usr/local/bin/cc";
    let i: i32 = 0;
    while (i < 6) {
      let cand: *u8 = c0;
      if (i == 1) {
        cand = c1;
      }
      if (i == 2) {
        cand = c2;
      }
      if (i == 3) {
        cand = c3;
      }
      if (i == 4) {
        cand = c4;
      }
      if (i == 5) {
        cand = c5;
      }
      argv[0] = cand;
      let rc: i32 = 0;
      unsafe {
        rc = shux_spawn_sync(cand, argv);
      }
      if (rc == 0) {
        return 0;
      }
      i = i + 1;
    }
    unsafe {
      link_diag_tool_status("cc", 0 - 1);
    }
    return 0 - 1;
  }

  // PLATFORM: APPLE / other POSIX — prefer cc then gcc (Darwin cc is Apple clang wrapper).
  let a0: *u8 = "cc";
  let a1: *u8 = "gcc";
  argv[0] = a0;
  let rc0: i32 = 0;
  unsafe {
    rc0 = shux_spawn_sync(a0, argv);
  }
  if (rc0 == 0) {
    return 0;
  }
  argv[0] = a1;
  let rc1: i32 = 0;
  unsafe {
    rc1 = shux_spawn_sync(a1, argv);
  }
  if (rc1 == 0) {
    return 0;
  }
  unsafe {
    link_diag_tool_status("cc", 0 - 1);
  }
  return 0 - 1;
}

/**
 * Best-effort strip -x on linked product when opt_level is not "0".
 * @param out_path *u8 — executable path just produced by cc; null/empty → no-op
 * @param opt_level *u8 — optimization level string; null/empty/"0" → no-op
 * @return void — strip failure ignored (≡ mega (void)wait / (void)_spawnvp)
 * Pure orch: ≡ mega stage-8 strip shell after successful cc wait.
 * Cap residual: invoke_cc_strip_out_x (packs strip argv + spawn); host_is_windows skip
 *   (mega Windows path returned before strip; PE strip optional / often absent).
 * Why strip -x not bare strip: Darwin bare strip drops _main global → nm/otool false red.
 * PLATFORM: SHARED gate / POSIX strip body / WINDOWS no-op (preserve mega semantics).
 * Track-L: #[no_mangle] surface short name for mega call sites.
 * Note: export signature must stay single-line.
 */
#[no_mangle]
export function invoke_cc_maybe_strip_out(out_path: *u8, opt_level: *u8): void {
  if (out_path == 0 as *u8) {
    return;
  }
  if (out_path[0] == 0) {
    return;
  }
  if (opt_level == 0 as *u8) {
    return;
  }
  if (opt_level[0] == 0) {
    return;
  }
  let is0: i32 = 0;
  unsafe {
    is0 = strcmp(opt_level, "0");
  }
  if (is0 == 0) {
    return;
  }
  let is_win: i32 = 0;
  unsafe {
    is_win = link_abi_host_is_windows();
  }
  if (is_win != 0) {
    // PLATFORM: WINDOWS — mega historically returned before strip; keep no-op.
    return;
  }
  unsafe {
    invoke_cc_strip_out_x(out_path);
  }
}
