// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// link_abi L5 invoke_cc pure table (G.9 English; body is authoritative).
// link_abi L5 invoke_cc pure table (G.9 English; body is authoritative).
// link_abi L5 invoke_cc pure table (G.9 English; body is authoritative).
//
// link_abi L5 invoke_cc pure table (G.9 English; body is authoritative).
// link_abi L5 invoke_cc pure table (G.9 English; body is authoritative).
// link_abi L5 invoke_cc pure table (G.9 English; body is authoritative).
// link_abi L5 invoke_cc pure table (G.9 English; body is authoritative).

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
