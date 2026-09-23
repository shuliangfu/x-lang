// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Sole bodies of write_io_net_abi_inline / write_fs_path_map_error_abi_inline.
// The C twins in seeds/rt_preamble.from_x.c were deleted in w843. Do not
// restore them. w861: labi_rt_preamble_slice_marker lives here too and still
// returns 1. Cap-giant-string table data stays in that seed. Line access is
// driver_preamble_*_line_at/count (runtime_driver_abi). Each line is written
// by driver_preamble_fputs, which decodes the opaque fd-handle and calls
// xlang_io_write.
// Product install: ensure_rt_preamble_prefer (pure-asm this file + cc the
// seed for the string tables). No gcc -E. No full-seed fallback.
// PLATFORM: SHARED — same object on POSIX and Windows.
// wave29: WEAK_IO_BATCH skip i=178..181 (n=224).

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
 * @return i32 — 0 on success; 1 if any fputs fails (EOF or a bad handle)
 * PLATFORM: SHARED — sole definition. Skip ranges are 60..63 (handle),
 * 64..81 (core macros), 105..118 (undef/rebind), and 178..181 (weak IO).
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
    // WEAK_IO_BATCH (wave29): rows 178..181 = stdio guard + weak xlang_io_* /
    // process_xlang_* / std_io_driver_* / ctx_* (#include..#endif). Co-emit of
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
 * @return i32 — 0 on success; 1 if any fputs fails (EOF or a bad handle)
 * PLATFORM: SHARED — sole definition. Every table row is written.
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

/**
 * Slice presence marker for this translation unit.
 * Returns 1, the same value the former host-cc marker returned.
 * No product caller reads it. The ensure nm gate only checks the symbol exists.
 * @return i32 — always 1
 * PLATFORM: SHARED — pure asm. String tables stay in the C seed.
 */
#[no_mangle]
export function labi_rt_preamble_slice_marker(): i32 {
  return 1;
}
