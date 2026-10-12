// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Label scan for the ELF ctx diagnostic note.
// The copy loop stays in rt_pipeline_elf_diag.x. The message buffers stay
// in rt_pipeline_elf_diag_note.x. This file is the one while that walks labels.
// PLATFORM: SHARED.
// w1137: pure asm emits this scan on its own.

export extern "C" function rt_elf_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function rt_elf_name_at(base: *u8, entry_off: i32, name_rel: i32): *u8;
export extern "C" function rt_elf_names_eq(a: *u8, b: *u8, n: i32): i32;

export const RT_ELF_CTX_TABLE_CAP: i32 = 16384;
export const RT_ELF_LABEL_ENTRY_SIZE: i32 = 264;
export const RT_ELF_LABELS_OFF: i32 = 4;
export const RT_ELF_LAB_OFF_NAME_LEN: i32 = 256;

/** Return the label index whose name matches, or -1.
 * Stops at RT_ELF_CTX_TABLE_CAP. PLATFORM: SHARED. */
#[no_mangle]
export function rt_elf_find_label(ctx: *u8, name_len: i32, p_name: *u8, num_labels: i32): i32 {
  let l: i32 = 0;
  while (l < num_labels) {
    let idx: i32 = l;
    if (idx >= RT_ELF_CTX_TABLE_CAP) {
      break;
    }
    let lbl_base: i32 = RT_ELF_LABELS_OFF + idx * RT_ELF_LABEL_ENTRY_SIZE;
    let lbl_nl: i32 = 0;
    let same: i32 = 0;
    unsafe {
      lbl_nl = rt_elf_load_i32_le(ctx, lbl_base + RT_ELF_LAB_OFF_NAME_LEN);
    }
    if (lbl_nl == name_len) {
      same = 1;
    }
    if (same != 0) {
      if (name_len > 0) {
        let lbl_name: *u8 = 0 as *u8;
        unsafe {
          lbl_name = rt_elf_name_at(ctx, lbl_base, 0);
          same = rt_elf_names_eq(lbl_name, p_name, name_len);
        }
      }
    }
    if (same != 0) {
      return idx;
    }
    l = l + 1;
  }
  return 0 - 1;
}
