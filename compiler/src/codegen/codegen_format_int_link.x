// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Link-name adapter for format_int.
// codegen.x keeps #[no_mangle] format_int because codegen_late calls that
// bare name. The pipeline runtime calls codegen_format_int. The installed
// codegen object defines the long name and also the rest of codegen, so it
// cannot be linked next to the fresh codegen object.
// PLATFORM: SHARED.

/**
 * Product link name of codegen.format_int.
 * out is the codegen buffer pointer. val is the signed value.
 * Returns the formatter result.
 * PLATFORM: SHARED.
 */
export extern "C" function format_int(out: *u8, val: i64): i32;

/**
 * Format a signed integer under the pipeline runtime's call name.
 * Params: out — codegen buffer. val — value to format.
 * Returns: the format_int result.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function codegen_format_int(out: *u8, val: i64): i32 {
  unsafe {
    return format_int(out, val);
  }
}
