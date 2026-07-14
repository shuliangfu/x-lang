// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-265 / P2 R3 → R2 full：preamble ABI 内联写盘。
// .x 吃满 write_io_net_abi_inline / write_fs_path_map_error_abi_inline
//   （skip mask 过滤 + fputs 循环）。
// 产品 PREFER_X_O：full .x + rest 在 FROM_X 下业务 T=0（marker + 巨型字串表数据）。
// Cap-giant-string residual：行表在 rest seed；line_at/count 在 driver_abi
// （.x 禁巨型 C 字串表；-E 体积/挂起风险）。
// 依赖：codegen_get_preamble_skip_mask（strict_glue / pipeline stubs）。

export extern "C" function fputs(s: *u8, stream: *u8): i32;
export extern "C" function codegen_get_preamble_skip_mask(): i32;
export extern "C" function driver_preamble_io_net_line_at(i: i32): *u8;
export extern "C" function driver_preamble_io_net_line_count(): i32;
export extern "C" function driver_preamble_fs_path_line_at(i: i32): *u8;
export extern "C" function driver_preamble_fs_path_line_count(): i32;

// skip mask bits（与 CODEGEN_PREAMBLE_SKIP_* 一致）
// 1=CORE_MACROS  2=DRIVER_HANDLE  4=UNDEF_REDEFINE  8=WEAK_IO_BATCH

/** 向生成 C 写入 std.io / std.net 内联 ABI。成功返回 0。 */
#[no_mangle]
export function write_io_net_abi_inline(cf: *u8): i32 {
  let skip: i32 = 0;
  let n: i32 = 0;
  let i: i32 = 0;
  unsafe {
    skip = codegen_get_preamble_skip_mask();
    n = driver_preamble_io_net_line_count();
  }
  while (i < n) {
    let skip_line: i32 = 0;
    // std_io_driver_handle_* 别名（i 60..63）
    if ((skip & 2) != 0) {
      if (i >= 60) {
        if (i < 64) {
          skip_line = 1;
        }
      }
    }
    // std_io_core_io_* 宏（i 64..81）
    if ((skip & 1) != 0) {
      if (i >= 64) {
        if (i < 82) {
          skip_line = 1;
        }
      }
    }
    // #undef / 重绑 std_io_core_*（i 105..118）
    if ((skip & 4) != 0) {
      if (i >= 105) {
        if (i < 119) {
          skip_line = 1;
        }
      }
    }
    // weak batch/register（i 124..134 inclusive）
    if ((skip & 8) != 0) {
      if (i >= 124) {
        if (i <= 134) {
          skip_line = 1;
        }
      }
    }
    if (skip_line == 0) {
      let line: *u8 = 0 as *u8;
      let rc: i32 = 0;
      unsafe {
        line = driver_preamble_io_net_line_at(i);
        rc = fputs(line, cf);
      }
      // fputs EOF == -1
      if (rc < 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  return 0;
}

/** 向生成 C 写入 std.fs / std.path / std.map / std.error 内联 ABI。成功返回 0。 */
#[no_mangle]
export function write_fs_path_map_error_abi_inline(cf: *u8): i32 {
  let n: i32 = 0;
  let i: i32 = 0;
  unsafe {
    n = driver_preamble_fs_path_line_count();
  }
  while (i < n) {
    let line: *u8 = 0 as *u8;
    let rc: i32 = 0;
    unsafe {
      line = driver_preamble_fs_path_line_at(i);
      rc = fputs(line, cf);
    }
    if (rc < 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}
