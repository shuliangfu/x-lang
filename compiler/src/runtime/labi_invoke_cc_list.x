// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-274 / P2 link_abi L5：invoke_cc 纯表（harden / skip-native env / needs rel）→ R2 full。
// 产品：PREFER_X_O → g05_try_x_to_o；冷启动 seeds/labi_invoke_cc_list.from_x.c。
// hybrid 宏 SHUX_LABI_INVOKE_CC_LIST_FROM_X（FROM_X rest 业务 H=0，仅 marker）。
//
// R2 full：.x 吃满 harden 表 + skip-native env + invoke_cc_skip_native_tuning + icc rel 表。
// Cap residual：getenv 🔒（libc）；fork/exec 仍在 mega shux_invoke_cc_impl（🔒）。
// G-02f-L：真迁 if/else + let 绑定短字符串（依赖 W-string-nul；无全局表）。
// 禁止「函数体仅 return "lit"」——parser 会 skip 整函数；用 let p + return p。

export extern "C" function getenv(name: *u8): *u8;

#[no_mangle]
export function labi_linux_harden_flag_count(): i32 {
  return 5;
}

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

#[no_mangle]
export function labi_invoke_cc_skip_native_env_count(): i32 {
  return 3;
}

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

// getenv 🔒 — 策略表仍 pure；读 env 走 libc。
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

#[no_mangle]
export function labi_icc_rel_core_builtin_o(): *u8 {
  let p: *u8 = "core/builtin/builtin.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_core_builtin_abi_h(): *u8 {
  let p: *u8 = "core/builtin/builtin_abi.h";
  return p;
}

#[no_mangle]
export function labi_icc_rel_core_mem_o(): *u8 {
  let p: *u8 = "core/mem/mem.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_core_slice_o(): *u8 {
  let p: *u8 = "core/slice/slice.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_db_kv_o(): *u8 {
  let p: *u8 = "std/db/kv/kv.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_db_arrow_o(): *u8 {
  let p: *u8 = "std/db/arrow/arrow.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_csv_o(): *u8 {
  let p: *u8 = "std/csv/csv.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_error_o(): *u8 {
  let p: *u8 = "std/error/error.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_heap_o(): *u8 {
  let p: *u8 = "std/heap/heap.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_json_o(): *u8 {
  let p: *u8 = "std/json/json.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_log_o(): *u8 {
  let p: *u8 = "std/log/log.o";
  return p;
}

#[no_mangle]
export function labi_icc_rel_socketio_o(): *u8 {
  let p: *u8 = "std/socketio/socketio.o";
  return p;
}

#[no_mangle]
export function labi_icc_needs_rel_count(): i32 {
  return 12;
}

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
