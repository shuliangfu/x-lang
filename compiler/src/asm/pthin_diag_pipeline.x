// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

// pthin_diag_pipeline.x — G-02f-325 P16 pointer bodies.
//
// The C slice's parse / lex / onefunc helpers return structs by value.
// Those stay in seeds/pthin_diag_pipeline.from_x.c. This file owns the
// three pointer-ABI import readers. num_imports is the i32 at byte 8;
// the seed TU pins that with offsetof. Do not copy the layout here as a
// second authority. The path copy itself is pipeline_module_import_path_copy.
// PLATFORM: SHARED.

/** Byte offset of ASTModule.num_imports. Pinned in the seed TU. */
const P16_OFF_NUM_IMPORTS: i32 = 8;

/**
 * Copy one import path into dst. Authority lives in the pipeline module
 * import writer; this slice only calls it.
 * @param module *u8 — ASTModule; null is the callee's problem
 * @param idx i32 — import index
 * @param dst *u8 — destination bytes
 * @param dst_cap i32 — destination capacity
 * PLATFORM: SHARED.
 */
export extern function pipeline_module_import_path_copy(module: *u8, idx: i32, dst: *u8, dst_cap: i32): void;

/**
 * Return module.num_imports. A null module returns 0.
 * The index is the pinned constant: a variable offset plus four shifts
 * crashes this asm backend. The pad keeps a spill off saved x19.
 * @param module *u8 — ASTModule, or null
 * @return i32 — import count, or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_get_module_num_imports_c(module: *u8): i32 {
  let a: usize = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (module == 0 as *u8) {
    return 0;
  }
  unsafe {
    a = module[P16_OFF_NUM_IMPORTS] as usize;
    a = a | ((module[P16_OFF_NUM_IMPORTS + 1] as usize) << 8);
    a = a | ((module[P16_OFF_NUM_IMPORTS + 2] as usize) << 16);
    a = a | ((module[P16_OFF_NUM_IMPORTS + 3] as usize) << 24);
  }
  return a as i32;
}

/**
 * Copy import i into out[64], NUL terminated. A null out returns.
 * A negative index, a null module, or an index past num_imports
 * writes an empty string.
 * @param module *u8 — ASTModule, or null
 * @param i i32 — import index
 * @param out *u8 — 64-byte destination, or null
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_get_module_import_path_c(module: *u8, i: i32, out: *u8): void {
  let n: i32 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  if (out == 0 as *u8) {
    return;
  }
  if (i < 0 || module == 0 as *u8) {
    unsafe {
      out[0] = 0;
    }
    return;
  }
  unsafe {
    n = parser_asm_get_module_num_imports_c(module);
  }
  if (i >= n) {
    unsafe {
      out[0] = 0;
    }
    return;
  }
  unsafe {
    pipeline_module_import_path_copy(module, i, out, 64);
  }
}

/**
 * Copy import i and return the byte length, not counting the NUL.
 * A null out returns 0. The length stops at 64.
 * @param module *u8 — ASTModule, or null
 * @param i i32 — import index
 * @param out *u8 — 64-byte destination, or null
 * @return i32 — path length, or 0
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function parser_asm_copy_module_import_path64_c(module: *u8, i: i32, out: *u8): i32 {
  let path_len: i32 = 0;
  let b: i32 = 0;
  let pad: u8[32] = [];
  pad[0] = 0;
  unsafe {
    parser_asm_get_module_import_path_c(module, i, out);
  }
  if (out == 0 as *u8) {
    return 0;
  }
  while (path_len < 64) {
    unsafe {
      b = out[path_len] as i32;
    }
    if (b == 0) {
      return path_len;
    }
    path_len = path_len + 1;
  }
  return path_len;
}
