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
// Cap residual: getenv (libc); host_is_* #if probes; ensure/path/needs peers;
//   contains_substr(_use_line) peers for scan; ensure-push heavy tail (math…process_argv
//   complement) + heap F-06 + fork/exec still mega.
// PLATFORM: SHARED tables/orch; LINUX consumers for harden -pie/-z flags.

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
