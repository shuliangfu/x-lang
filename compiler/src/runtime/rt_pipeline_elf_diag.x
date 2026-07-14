// Copyright (C) 2026 Shuliang Fu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-304/445 / P2 runtime rest：ELF ctx 诊断 note（pure 读表）。
// R2 full（2026-07-14）：.x 吃满 runtime_pipeline_elf_ctx_diag_note；
// 产品 PREFER_X_O：full .x + rest 在 FROM_X 下仅 marker（业务 H=0）。
// 布局与 seeds/rt_pipeline_elf_diag.from_x.c RuntimePipelineElfCtxAccess 一致；
// 用字节偏移读 i32/name，避免在 .x 展开 labels/patches[16384] 巨型类型。
// 诊断走 diag_report_with_code（无 va / reportf）。

export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/** 与 PIPELINE_ELF_CTX_TABLE_CAP / seed CAP 一致。 */
export const RT_ELF_CTX_TABLE_CAP: i32 = 16384;
/** LabelEntry: name[64]+name_len+offset = 72。 */
export const RT_ELF_LABEL_ENTRY_SIZE: i32 = 72;
/** PatchEntry: rel32+name[64]+name_len+patch_imm = 76。 */
export const RT_ELF_PATCH_ENTRY_SIZE: i32 = 76;
/** labels 起始偏移（code_len 后）。 */
export const RT_ELF_LABELS_OFF: i32 = 4;
/** num_labels = 4 + CAP*72。 */
export const RT_ELF_NUM_LABELS_OFF: i32 = 1179652;
/** patches = num_labels 后 4 字节。 */
export const RT_ELF_PATCHES_OFF: i32 = 1179656;
/** num_patches = patches + CAP*76。 */
export const RT_ELF_NUM_PATCHES_OFF: i32 = 2424840;

function rt_elf_load_i32_le(base: *u8, off: i32): i32 {
  if (base == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  unsafe {
    let q: *u8 = base + off;
    let m: i32 = 256;
    let a0: i32 = q[0] as i32;
    let a1: i32 = a0 + (q[1] as i32) * m;
    let a2: i32 = a1 + (q[2] as i32) * m * m;
    let a3: i32 = a2 + (q[3] as i32) * m * m * m;
    return a3;
  }
  return 0;
}

function rt_elf_name_at(base: *u8, entry_off: i32, name_rel: i32): *u8 {
  if (base == 0 as *u8) {
    return 0 as *u8;
  }
  if (entry_off < 0) {
    return 0 as *u8;
  }
  if (name_rel < 0) {
    return 0 as *u8;
  }
  unsafe {
    return base + (entry_off + name_rel);
  }
  return 0 as *u8;
}

function rt_elf_names_eq(a: *u8, b: *u8, n: i32): i32 {
  let i: i32 = 0;
  if (n <= 0) {
    return 1;
  }
  if (a == 0 as *u8) {
    return 0;
  }
  if (b == 0 as *u8) {
    return 0;
  }
  while (i < n) {
    if (a[i as usize] != b[i as usize]) {
      return 0;
    }
    i = i + 1;
  }
  return 1;
}

function rt_elf_strlen(s: *u8): i32 {
  let i: i32 = 0;
  if (s == 0 as *u8) {
    return 0;
  }
  while (i < 512) {
    if (s[i as usize] == 0) {
      return i;
    }
    i = i + 1;
  }
  return i;
}

function rt_elf_append(dst: *u8, cap: i32, src: *u8): void {
  let dlen: i32 = 0;
  let slen: i32 = 0;
  let i: i32 = 0;
  if (dst == 0 as *u8) {
    return;
  }
  if (src == 0 as *u8) {
    return;
  }
  if (cap <= 1) {
    return;
  }
  dlen = rt_elf_strlen(dst);
  slen = rt_elf_strlen(src);
  while (i < slen) {
    if (dlen + 1 >= cap) {
      break;
    }
    dst[dlen as usize] = src[i as usize];
    dlen = dlen + 1;
    i = i + 1;
  }
  dst[dlen as usize] = 0;
}

function rt_elf_append_i32(dst: *u8, cap: i32, v: i32): void {
  let dig: u8[16] = [];
  let n: i32 = v;
  let i: i32 = 0;
  let j: i32 = 0;
  let neg: i32 = 0;
  let a: u8 = 0;
  dig[0] = 0;
  if (n == 0) {
    dig[0] = 48;
    dig[1] = 0;
    rt_elf_append(dst, cap, &dig[0]);
    return;
  }
  if (n < 0) {
    neg = 1;
    n = 0 - n;
  }
  while (n > 0) {
    if (i >= 15) {
      break;
    }
    dig[i] = (48 + (n - (n / 10) * 10)) as u8;
    n = n / 10;
    i = i + 1;
  }
  if (neg != 0) {
    if (i < 15) {
      dig[i] = 45;
      i = i + 1;
    }
  }
  j = 0;
  while (j < i / 2) {
    a = dig[j];
    dig[j] = dig[i - 1 - j];
    dig[i - 1 - j] = a;
    j = j + 1;
  }
  dig[i] = 0;
  rt_elf_append(dst, cap, &dig[0]);
}

function rt_elf_note_kind(kind: *u8): void {
  /* "note" */
  kind[0] = 110;
  kind[1] = 111;
  kind[2] = 116;
  kind[3] = 101;
  kind[4] = 0;
}

function rt_elf_report_note(msg: *u8): void {
  let kind: u8[8] = [];
  rt_elf_note_kind(&kind[0]);
  unsafe {
    diag_report_with_code(0 as *u8, 0, 0, &kind[0], 0 as *u8, msg, 0 as *u8);
  }
}

/**
 * elf ctx 诊断 note：code_len / labels / patches 摘要，并尝试匹配 first patch 标签。
 * ctx_bytes 为 *ElfCodegenCtx（前缀布局见 CAP 常量）。
 */
#[no_mangle]
export function runtime_pipeline_elf_ctx_diag_note(ctx_bytes: *u8): void {
  let code_len: i32 = 0;
  let num_labels: i32 = 0;
  let num_patches: i32 = 0;
  let msg: u8[192] = [];
  let name_len: i32 = 0;
  let l: i32 = 0;
  let p_base: i32 = 0;
  let p_name: *u8 = 0 as *u8;
  let lbl_base: i32 = 0;
  let lbl_name: *u8 = 0 as *u8;
  let lbl_nl: i32 = 0;
  let lbl_off: i32 = 0;
  let same: i32 = 0;
  let i: i32 = 0;
  let namebuf: u8[65] = [];

  if (ctx_bytes == 0 as *u8) {
    return;
  }

  code_len = rt_elf_load_i32_le(ctx_bytes, 0);
  num_labels = rt_elf_load_i32_le(ctx_bytes, RT_ELF_NUM_LABELS_OFF);
  num_patches = rt_elf_load_i32_le(ctx_bytes, RT_ELF_NUM_PATCHES_OFF);

  msg[0] = 0;
  /* "elf ctx code_len=" */
  rt_elf_append(&msg[0], 192, "elf ctx code_len=" as *u8);
  rt_elf_append_i32(&msg[0], 192, code_len);
  rt_elf_append(&msg[0], 192, " num_labels=" as *u8);
  rt_elf_append_i32(&msg[0], 192, num_labels);
  rt_elf_append(&msg[0], 192, " num_patches=" as *u8);
  rt_elf_append_i32(&msg[0], 192, num_patches);
  rt_elf_report_note(&msg[0]);

  if (num_patches <= 0) {
    return;
  }

  p_base = RT_ELF_PATCHES_OFF;
  /* name_len @ +68 within PatchEntry */
  name_len = rt_elf_load_i32_le(ctx_bytes, p_base + 68);
  if (name_len > 64) {
    name_len = 64;
  }
  if (name_len < 0) {
    name_len = 0;
  }
  p_name = rt_elf_name_at(ctx_bytes, p_base, 4);
  i = 0;
  while (i < name_len) {
    if (p_name != 0 as *u8) {
      namebuf[i] = p_name[i as usize];
    } else {
      namebuf[i] = 0;
    }
    i = i + 1;
  }
  namebuf[name_len] = 0;

  msg[0] = 0;
  rt_elf_append(&msg[0], 192, "elf first patch name_len=" as *u8);
  rt_elf_append_i32(&msg[0], 192, name_len);
  rt_elf_append(&msg[0], 192, " name='" as *u8);
  rt_elf_append(&msg[0], 192, &namebuf[0]);
  rt_elf_append(&msg[0], 192, "'" as *u8);
  rt_elf_report_note(&msg[0]);

  l = 0;
  while (l < num_labels) {
    if (l >= RT_ELF_CTX_TABLE_CAP) {
      break;
    }
    lbl_base = RT_ELF_LABELS_OFF + l * RT_ELF_LABEL_ENTRY_SIZE;
    lbl_nl = rt_elf_load_i32_le(ctx_bytes, lbl_base + 64);
    same = 0;
    if (lbl_nl == name_len) {
      same = 1;
    }
    if (same != 0) {
      if (name_len > 0) {
        lbl_name = rt_elf_name_at(ctx_bytes, lbl_base, 0);
        same = rt_elf_names_eq(lbl_name, p_name, name_len);
      }
    }
    if (same != 0) {
      lbl_off = rt_elf_load_i32_le(ctx_bytes, lbl_base + 68);
      msg[0] = 0;
      rt_elf_append(&msg[0], 192, "elf label match at idx=" as *u8);
      rt_elf_append_i32(&msg[0], 192, l);
      rt_elf_append(&msg[0], 192, " offset=" as *u8);
      rt_elf_append_i32(&msg[0], 192, lbl_off);
      rt_elf_report_note(&msg[0]);
      return;
    }
    l = l + 1;
  }

  msg[0] = 0;
  rt_elf_append(&msg[0], 192, "elf no label match for first patch" as *u8);
  rt_elf_report_note(&msg[0]);
}
