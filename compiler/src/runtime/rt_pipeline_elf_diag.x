// Copyright (C) 2026 ShuLiangfu <admin@shuliangfu.com>
// SPDX-License-Identifier: AGPL-3.0-or-later
//
// G-02f-304/445 / P2 runtime rest: ELF ctx diagnostic helpers.
// w1137: the label scan is rt_pipeline_elf_diag_find.x, the note kind is
// rt_pipeline_elf_diag_kind.x, and the message buffers are
// rt_pipeline_elf_diag_note.x. One translation unit that holds every while
// and the message buffers does not emit.
// Layout matches seeds RuntimePipelineElfCtxAccess; read i32/name via byte
// offsets so .x need not expand labels/patches[16384] giant types.
// PLATFORM: SHARED — surface short names are the link-name contract (Track L).
// Comment rule: never put star-slash sequences inside block comments.

export extern "C" function diag_report_with_code(
  file: *u8, line: i32, col: i32, kind: *u8, code: *u8, msg: *u8, detail: *u8): void;

/** Matches PIPELINE_ELF_CTX_TABLE_CAP / seed CAP / elf.x ElfCodegenCtx. */
export const RT_ELF_CTX_TABLE_CAP: i32 = 16384;
/**
 * LabelEntry size: name[256]+name_len+offset = 264.
 * G.7 authority = pipeline_abi pipe_elf_label_esz + elf.x ElfLabelEntry
 * (historical pure diag used 72 = name[64] dead layout → false num_labels=0).
 * PLATFORM: SHARED LP64 LE.
 */
export const RT_ELF_LABEL_ENTRY_SIZE: i32 = 264;
/**
 * PatchEntry size: rel32+name[256]+name_len+patch_imm = 268.
 * G.7 authority = pipeline_abi pipe_elf_patch_esz + elf.x ElfPatchEntry
 * (historical pure diag used 76 = name[64] dead layout).
 * PLATFORM: SHARED LP64 LE.
 */
export const RT_ELF_PATCH_ENTRY_SIZE: i32 = 268;
/** Byte offset of labels table (after code_len). */
export const RT_ELF_LABELS_OFF: i32 = 4;
/** Byte offset of num_labels — ≡ pipe_elf_off_num_labels (G.7 thin/warm; not 4+CAP*264 dead). */
export const RT_ELF_NUM_LABELS_OFF: i32 = 17301508;
/** Byte offset of patches — ≡ pipe_elf_off_patches (G.7 thin/warm). */
export const RT_ELF_PATCHES_OFF: i32 = 17301512;
/** Byte offset of num_patches — ≡ pipe_elf_off_num_patches (G.7=34865160=0x2140008). */
export const RT_ELF_NUM_PATCHES_OFF: i32 = 34865160;
/** LabelEntry.name_len offset (name[256] then i32). */
export const RT_ELF_LAB_OFF_NAME_LEN: i32 = 256;
/** LabelEntry.offset field (name_len + 4). */
export const RT_ELF_LAB_OFF_OFFSET: i32 = 260;
/** PatchEntry.name_len offset (rel32 + name[256]). */
export const RT_ELF_PAT_OFF_NAME_LEN: i32 = 260;

/** Load little-endian i32 at base+off. Returns 0 if base is null or off < 0.
 * Track-L: #[no_mangle] keeps surface short name (not pipeline_rt_elf_load_i32_le).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
/** One byte at base+off as i32. Caller has already rejected a null base.
 * PLATFORM: SHARED. */
function rt_elf_byte_at(base: *u8, off: i32): i32 {
  let p: *u8 = base + off;
  return p[0] as i32;
}

#[no_mangle]
export function rt_elf_load_i32_le(base: *u8, off: i32): i32 {
  let a: i32 = 0;
  if (base == 0 as *u8) {
    return 0;
  }
  if (off < 0) {
    return 0;
  }
  // Little-endian assemble. Each byte is loaded in its own frame.
  unsafe {
    a = rt_elf_byte_at(base, off);
    a = a + rt_elf_byte_at(base, off + 1) * 256;
    a = a + rt_elf_byte_at(base, off + 2) * 65536;
    a = a + rt_elf_byte_at(base, off + 3) * 16777216;
  }
  return a;
}

/** Pointer to name bytes at base + entry_off + name_rel (or null on bad args).
 * Track-L: #[no_mangle] keeps surface short name (not pipeline_rt_elf_name_at).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_elf_name_at(base: *u8, entry_off: i32, name_rel: i32): *u8 {
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

/** Return 1 iff a[0..n) equals b[0..n). Empty n is equal. Null a/b fails when n>0.
 * Track-L: #[no_mangle] keeps surface short name (not pipeline_rt_elf_names_eq).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_elf_names_eq(a: *u8, b: *u8, n: i32): i32 {
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

/** Length of NUL-terminated s, capped at 512 (returns 512 if no NUL in range).
 * Null s returns 0. Track-L: #[no_mangle] keeps surface short name.
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_elf_strlen(s: *u8): i32 {
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

/** Append NUL-terminated src onto dst, respecting capacity (leave room for NUL).
 * No-op if dst/src null or cap <= 1. Always writes trailing NUL when any copy runs.
 * Track-L: #[no_mangle] keeps surface short name (not pipeline_rt_elf_append).
 * PLATFORM: SHARED — link-name contract; dual-host prove. */
#[no_mangle]
export function rt_elf_append(dst: *u8, cap: i32, src: *u8): void {
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


/** Append decimal representation of v onto dst (handles 0 and negatives).
 * Digits built in a small local buffer then reverse-copied via rt_elf_append.
 *
 * Digit buffer accesses use an unsafe *u8 view of dig[16], matching the rest of
 * this module (rt_elf_load_i32_le / names_eq). Reason: pure-asm INDEX on fixed
 * arrays with two live index vars (swap dig[j] with dig[hi]) emits U xlang_panic_
 * bounds calls; g05 freestanding bag has no runtime_panic.o T for that surface
 * (product user path links panic via invoke_cc ensure). Pointer indexing keeps
 * pure-asm ABI equal to -E+$CC for this freestanding leaf (no U xlang_panic_).
 *
 * Track-L: #[no_mangle] keeps surface short name (not pipeline_rt_elf_append_i32).
 * PLATFORM: SHARED — link-name contract; dual-host prove; pure-asm g05 bag safe.
 */
#[no_mangle]
export function rt_elf_append_i32(dst: *u8, cap: i32, v: i32): void {
  let dig: u8[16] = [];
  let n: i32 = v;
  let i: i32 = 0;
  let j: i32 = 0;
  let neg: i32 = 0;
  let a: u8 = 0;
  let hi: i32 = 0;
  unsafe {
    let d: *u8 = &dig[0];
    // Manual digit buffer via d[k]; caller-owned stack storage, cap 16.
    d[0] = 0;
    if (n == 0) {
      d[0] = 48;
      d[1] = 0;
      rt_elf_append(dst, cap, d);
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
      // Least-significant digit first; reverse below.
      d[i as usize] = (48 + (n - (n / 10) * 10)) as u8;
      n = n / 10;
      i = i + 1;
    }
    if (neg != 0) {
      if (i < 15) {
        d[i as usize] = 45;
        i = i + 1;
      }
    }
    // Reverse digits in place (were least-significant first).
    j = 0;
    while (j < i / 2) {
      hi = i - 1 - j;
      a = d[j as usize];
      d[j as usize] = d[hi as usize];
      d[hi as usize] = a;
      j = j + 1;
    }
    d[i as usize] = 0;
    rt_elf_append(dst, cap, d);
  }
}


/** Copy n bytes from src into dst and write a trailing NUL at dst[n].
 * A null src stores zeros. Index and pointer are locals before the subscript.
 * PLATFORM: SHARED. */
#[no_mangle]
export function rt_elf_copy_name(dst: *u8, src: *u8, n: i32): void {
  let d: *u8 = dst;
  let s: *u8 = src;
  let i: i32 = 0;
  while (i < n) {
    let k: i32 = i;
    if (s != 0 as *u8) {
      d[k] = s[k];
    } else {
      d[k] = 0;
    }
    i = i + 1;
  }
  let ke: i32 = n;
  d[ke] = 0;
}

