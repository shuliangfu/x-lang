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
// Cap residual: getenv (libc); fork/exec still mega shux_invoke_cc_impl.
// PLATFORM: SHARED tables; LINUX consumers for harden -pie/-z flags.

export extern "C" function getenv(name: *u8): *u8;

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
