// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
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

// Link name for a same-module function used as a value.
// Call sites and .data relocs share this spelling with
// glue_asm_build_func_export_sym_c, which adds the module prefix.
// A bare source name leaves `_inc` undefined while the body is
// `_p_global_inc`. Mach-O still gets one leading '_'.
// dst is the caller buffer, typically 130 bytes.
// PLATFORM: SHARED · MACOS Mach-O '_' · LINUX ELF bare name.

export extern function pipeline_elf_ctx_macho_leading_underscore(elf_ctx: *u8): i32;
export extern function pipeline_asm_emit_module_ref_c(): *u8;
export extern function pipeline_asm_emit_ctx_arena_get(): *u8;
export extern function glue_module_func_index_by_name_c(m: *u8, name: *u8, name_len: i32): i32;
export extern function glue_asm_build_func_export_sym_c(
  m: *u8, a: *u8, func_ix: i32, out: *u8, out_cap: i32
): i32;

/**
 * Spell a same-module function's link name into dst.
 * @param elf_ctx *u8 — encoder; null returns -1. Reads the Mach-O underscore flag
 * @param name *u8 — source-level function name; null returns -1
 * @param name_len i32 — 1..255; otherwise -1
 * @param dst *u8 — caller buffer, capacity at least 130; null returns -1
 * @return i32 — spelled length, or -1
 * The export builder supplies the module prefix and leaves main bare.
 * A lookup miss falls back to the source name so a non-function still
 * spells. Darwin prepends '_'. The spelled form must fit in 129 bytes.
 * PLATFORM: SHARED.
 */
#[no_mangle]
export function pipe_modlet_fn_sym_spell_into(
  elf_ctx: *u8, name: *u8, name_len: i32, dst: *u8
): i32 {
  let macho: i32 = 0;
  let m: *u8 = 0 as *u8;
  let arena: *u8 = 0 as *u8;
  let fi: i32 = 0 - 1;
  let spelled: u8[128] = [];
  let slen: i32 = 0;
  let k: i32 = 0;
  let pos: i32 = 0;
  if (elf_ctx == (0 as *u8) || name == (0 as *u8) || dst == (0 as *u8)) {
    return 0 - 1;
  }
  if (name_len <= 0 || name_len > 255) {
    return 0 - 1;
  }
  unsafe {
    macho = pipeline_elf_ctx_macho_leading_underscore(elf_ctx);
    m = pipeline_asm_emit_module_ref_c();
    arena = pipeline_asm_emit_ctx_arena_get();
  }
  if (m != (0 as *u8) && arena != (0 as *u8)) {
    unsafe {
      fi = glue_module_func_index_by_name_c(m, name, name_len);
    }
  }
  slen = 0;
  if (fi >= 0) {
    unsafe {
      slen = glue_asm_build_func_export_sym_c(m, arena, fi, &spelled[0], 128);
    }
  }
  if (slen <= 0) {
    k = 0;
    while (k < name_len) {
      unsafe {
        spelled[k] = name[k];
      }
      k = k + 1;
    }
    slen = name_len;
  }
  pos = 0;
  if (macho != 0) {
    if (slen + 1 > 129) {
      return 0 - 1;
    }
    unsafe {
      dst[0] = 95 as u8;
    }
    pos = 1;
  } else if (slen > 129) {
    return 0 - 1;
  }
  k = 0;
  while (k < slen) {
    unsafe {
      dst[pos] = spelled[k];
    }
    pos = pos + 1;
    k = k + 1;
  }
  return pos;
}
