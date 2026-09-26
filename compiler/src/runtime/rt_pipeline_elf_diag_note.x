// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// ELF ctx diagnostic note entry. Copy and label scan live in the sibling
// files. This translation unit holds the message buffers and has no while.
// PLATFORM: SHARED.
// w1137: pure asm of the combined file does not emit.

export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;
export extern "C" function rt_elf_load_i32_le(base: *u8, off: i32): i32;
export extern "C" function rt_elf_name_at(base: *u8, entry_off: i32, name_rel: i32): *u8;
export extern "C" function rt_elf_append(dst: *u8, cap: i32, src: *u8): void;
export extern "C" function rt_elf_append_i32(dst: *u8, cap: i32, v: i32): void;
export extern "C" function rt_elf_copy_name(dst: *u8, src: *u8, n: i32): void;
export extern "C" function rt_elf_find_label(ctx: *u8, name_len: i32, p_name: *u8, num_labels: i32): i32;
export extern "C" function rt_elf_report_note(msg: *u8): void;

export const RT_ELF_LABEL_ENTRY_SIZE: i32 = 264;
export const RT_ELF_LABELS_OFF: i32 = 4;
export const RT_ELF_NUM_LABELS_OFF: i32 = 17301508;
export const RT_ELF_PATCHES_OFF: i32 = 17301512;
export const RT_ELF_NUM_PATCHES_OFF: i32 = 34865160;
export const RT_ELF_LAB_OFF_OFFSET: i32 = 260;
export const RT_ELF_PAT_OFF_NAME_LEN: i32 = 260;

/** Emit ELF ctx diagnostic notes: code_len / labels / patches summary,
 * first patch name, and whether a matching label was found.
 * ctx_bytes is the ELF codegen context prefix. PLATFORM: SHARED. */
#[no_mangle]
export function runtime_pipeline_elf_ctx_diag_note(ctx_bytes: *u8): void {
  let code_len: i32 = 0;
  let num_labels: i32 = 0;
  let num_patches: i32 = 0;
  let msg: u8[192] = [];
  let name_len: i32 = 0;
  let p_base: i32 = 0;
  let p_name: *u8 = 0 as *u8;
  let namebuf: u8[65] = [];
  let mp: *u8 = 0 as *u8;
  let np: *u8 = 0 as *u8;
  let idx: i32 = 0;
  let lbl_base: i32 = 0;
  let lbl_off: i32 = 0;
  if (ctx_bytes == 0 as *u8) {
    return;
  }
  unsafe {
    code_len = rt_elf_load_i32_le(ctx_bytes, 0);
    num_labels = rt_elf_load_i32_le(ctx_bytes, RT_ELF_NUM_LABELS_OFF);
    num_patches = rt_elf_load_i32_le(ctx_bytes, RT_ELF_NUM_PATCHES_OFF);
  }
  mp = &msg[0];
  msg[0] = 0;
  unsafe {
    rt_elf_append(mp, 192, "elf ctx code_len=" as *u8);
    rt_elf_append_i32(mp, 192, code_len);
    rt_elf_append(mp, 192, " num_labels=" as *u8);
    rt_elf_append_i32(mp, 192, num_labels);
    rt_elf_append(mp, 192, " num_patches=" as *u8);
    rt_elf_append_i32(mp, 192, num_patches);
  }
  unsafe { rt_elf_report_note(mp); }
  if (num_patches <= 0) {
    return;
  }
  p_base = RT_ELF_PATCHES_OFF;
  unsafe {
    name_len = rt_elf_load_i32_le(ctx_bytes, p_base + RT_ELF_PAT_OFF_NAME_LEN);
  }
  if (name_len > 64) {
    name_len = 64;
  }
  if (name_len < 0) {
    name_len = 0;
  }
  unsafe {
    p_name = rt_elf_name_at(ctx_bytes, p_base, 4);
  }
  np = &namebuf[0];
  unsafe {
    rt_elf_copy_name(np, p_name, name_len);
  }
  msg[0] = 0;
  unsafe {
    rt_elf_append(mp, 192, "elf first patch name_len=" as *u8);
    rt_elf_append_i32(mp, 192, name_len);
    rt_elf_append(mp, 192, " name='" as *u8);
    rt_elf_append(mp, 192, np);
    rt_elf_append(mp, 192, "'" as *u8);
  }
  unsafe { rt_elf_report_note(mp); }
  unsafe {
    idx = rt_elf_find_label(ctx_bytes, name_len, p_name, num_labels);
  }
  if (idx >= 0) {
    lbl_base = RT_ELF_LABELS_OFF + idx * RT_ELF_LABEL_ENTRY_SIZE;
    unsafe {
      lbl_off = rt_elf_load_i32_le(ctx_bytes, lbl_base + RT_ELF_LAB_OFF_OFFSET);
    }
    msg[0] = 0;
    unsafe {
      rt_elf_append(mp, 192, "elf label match at idx=" as *u8);
      rt_elf_append_i32(mp, 192, idx);
      rt_elf_append(mp, 192, " offset=" as *u8);
      rt_elf_append_i32(mp, 192, lbl_off);
    }
    unsafe { rt_elf_report_note(mp); }
    return;
  }
  msg[0] = 0;
  unsafe {
    rt_elf_append(mp, 192, "elf no label match for first patch" as *u8);
  }
  unsafe { rt_elf_report_note(mp); }
}
