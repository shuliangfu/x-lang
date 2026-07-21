// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// R2 full: write_io_net_abi_inline / write_fs_path_map_error_abi_inline pure.
// Cap-giant-string table *data* stays in seeds/rt_preamble.from_x.c (always seed).
// Line access: driver_preamble_*_line_at/count (runtime_driver_abi pure wave20).
// fputs: driver_preamble_fputs (wave22). Skip mask: codegen_get_preamble_skip_mask.
// PLATFORM: SHARED — product PREFER hybrid = this .x + rest tables/marker.
// wave29: WEAK_IO_BATCH skip i=178..181 (n=224); was dual-auth 124..134 vs seed i==174.

export extern "C" function codegen_get_preamble_skip_mask(): i32;
export extern "C" function driver_preamble_io_net_line_at(i: i32): *u8;
export extern "C" function driver_preamble_io_net_line_count(): i32;
export extern "C" function driver_preamble_fs_path_line_at(i: i32): *u8;
export extern "C" function driver_preamble_fs_path_line_count(): i32;
export extern "C" function driver_preamble_fputs(s: *u8, stream: *u8): i32;

// CODEGEN_PREAMBLE_SKIP_* bit layout (codegen.h; keep numeric literals in .x):
//   1 = CORE_MACROS (i 64..81)
//   2 = DRIVER_HANDLE (i 60..63)
//   4 = UNDEF_REDEFINE (i 105..118)
//   8 = WEAK_IO_BATCH (i 178..181; wave29)

/**
 * Write std.io / std.net Cap-giant-string ABI lines into an opaque FILE* stream.
 * Honors codegen_get_preamble_skip_mask so co-emit of std.io.core / std.io.driver
 * does not redefine macros or weak stubs already emitted in the same TU.
 * @param cf *u8 — opaque FILE* (must be non-null open write stream)
 * @return i32 — 0 on success; 1 if any fputs fails (EOF)
 * PLATFORM: SHARED — authority under PREFER hybrid; cold seed twin in
 * seeds/rt_preamble.from_x.c must keep the same skip ranges.
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
    // DRIVER_HANDLE aliases: skip when codegen already emitted handle_stdin etc.
    if ((skip & 2) != 0) {
      if (i >= 60) {
        if (i < 64) {
          skip_line = 1;
        }
      }
    }
    // CORE_MACROS: std_io_core_io_* map macros when core is not co-emitted.
    if ((skip & 1) != 0) {
      if (i >= 64) {
        if (i < 82) {
          skip_line = 1;
        }
      }
    }
    // UNDEF_REDEFINE: #undef / rebind block when X inlines std.io.core.
    if ((skip & 4) != 0) {
      if (i >= 105) {
        if (i < 119) {
          skip_line = 1;
        }
      }
    }
    // WEAK_IO_BATCH (wave29): rows 178..181 = stdio guard + weak shux_io_* /
    // process_shux_* / std_io_driver_* / ctx_* (#include..#endif). Co-emit of
    // std.io.driver supplies strong defs; same-TU weak would redef.
    if ((skip & 8) != 0) {
      if (i >= 178) {
        if (i <= 181) {
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
      // driver_preamble_fputs returns libc fputs result; EOF is negative.
      if (rc < 0) {
        return 1;
      }
    }
    i = i + 1;
  }
  return 0;
}

/**
 * Write std.fs / std.path / std.map / std.error Cap-giant-string ABI lines.
 * No skip mask today (full table always emitted).
 * @param cf *u8 — opaque FILE* (must be non-null open write stream)
 * @return i32 — 0 on success; 1 if any fputs fails (EOF)
 * PLATFORM: SHARED — pure under PREFER hybrid; cold seed twin loops fputs.
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
