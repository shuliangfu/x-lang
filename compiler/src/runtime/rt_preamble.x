// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Preamble ABI inline write (G.9 English; body is authoritative).
// Preamble ABI inline write (G.9 English; body is authoritative).
// Preamble ABI inline write (G.9 English; body is authoritative).
// Preamble ABI inline write (G.9 English; body is authoritative).
// Preamble ABI inline write (G.9 English; body is authoritative).
// Preamble ABI inline write (G.9 English; body is authoritative).
// Preamble ABI inline write (G.9 English; body is authoritative).

export extern "C" function codegen_get_preamble_skip_mask(): i32;
export extern "C" function driver_preamble_io_net_line_at(i: i32): *u8;
export extern "C" function driver_preamble_io_net_line_count(): i32;
export extern "C" function driver_preamble_fs_path_line_at(i: i32): *u8;
export extern "C" function driver_preamble_fs_path_line_count(): i32;
export extern "C" function driver_preamble_fputs(s: *u8, stream: *u8): i32;

// Preamble ABI inline write (G.9 English; body is authoritative).
// 1=CORE_MACROS  2=DRIVER_HANDLE  4=UNDEF_REDEFINE  8=WEAK_IO_BATCH

/** Exported function `write_io_net_abi_inline`.
 * Write path helper `write_io_net_abi_inline`.
 * @param cf *u8
 * @return i32
 */
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
    // Preamble ABI inline write (G.9 English; body is authoritative).
    if ((skip & 2) != 0) {
      if (i >= 60) {
        if (i < 64) {
          skip_line = 1;
        }
      }
    }
    // Preamble ABI inline write (G.9 English; body is authoritative).
    if ((skip & 1) != 0) {
      if (i >= 64) {
        if (i < 82) {
          skip_line = 1;
        }
      }
    }
    // Preamble ABI inline write (G.9 English; body is authoritative).
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
        rc = driver_preamble_fputs(line, cf);
      }
      // Preamble ABI inline write (G.9 English; body is authoritative).
      if (rc < 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `write_fs_path_map_error_abi_inline`.
 * Write path helper `write_fs_path_map_error_abi_inline`.
 * @param cf *u8
 * @return i32
 */
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
      rc = driver_preamble_fputs(line, cf);
    }
    if (rc < 0) {
      return 1;
    }
    i = i + 1;
  }
  return 0;
}
