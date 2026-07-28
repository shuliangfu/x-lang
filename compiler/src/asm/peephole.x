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

// See implementation.
//
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.
// See implementation.

const codegen_outbuf_abi = import("codegen_outbuf_abi");
const types = import("asm.types");
const elf = import("platform.elf");

/* See implementation. */
export extern function pipeline_elf_ctx_reloc_offset_at(ctx: *u8, idx: i32): i32;
export extern function pipeline_elf_ctx_reloc_offset_set(ctx: *u8, idx: i32, offset: i32): void;

/** Exported function `peephole_reloc_offset_at`.
 * Implements `peephole_reloc_offset_at`.
 * @param ctx *ElfCodegenCtx
 * @param idx i32
 * @return i32
 */
export function peephole_reloc_offset_at(ctx: *ElfCodegenCtx, idx: i32): i32 {
  unsafe {
    return pipeline_elf_ctx_reloc_offset_at(ctx as *u8, idx);
  }
}

/** Exported function `peephole_reloc_offset_set`.
 * Implements `peephole_reloc_offset_set`.
 * @param ctx *ElfCodegenCtx
 * @param idx i32
 * @param offset i32
 * @return void
 */
export function peephole_reloc_offset_set(ctx: *ElfCodegenCtx, idx: i32, offset: i32): void {
  unsafe {
    pipeline_elf_ctx_reloc_offset_set(ctx as *u8, idx, offset);
  }
}

/** Exported function `slice_eq`.
 * Implements `slice_eq`.
 * @param out *CodegenOutBuf
 * @param pos i32
 * @param ptr *u8
 * @param len i32
 * @return i32
 */
export function slice_eq(out: *CodegenOutBuf, pos: i32, ptr: *u8, len: i32): i32 {
  if (pos + len > out.length) { return 0; }
  let i: i32 = 0;
  while (i < len) {
    if (out.data[pos + i] != ptr[i]) { return 0; }
    i = i + 1;
  }
  return 1;
}

/** Exported function `peephole_remove_redundant_push_pop`.
 * Implements `peephole_remove_redundant_push_pop`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function peephole_remove_redundant_push_pop(out: *CodegenOutBuf): i32 {
  /* x86: "pushq %rax\n" 11 bytes; "popq %rax\n" 10. arm64: "str w0, [sp, #-16]!\n" 20;
  "ldr w0, [sp], #16\n" is 18 bytes. */
  let x86_push: u8[11] = [112, 117, 115, 104, 113, 32, 37, 114, 97, 120, 10];
  let x86_pop: u8[10] = [112, 111, 112, 113, 32, 37, 114, 97, 120, 10];
  let arm_push: u8[20] = [115, 116, 114, 32, 119, 48, 44, 32, 91, 115, 112, 44, 32, 35, 45, 49, 54,
  93, 33, 10];
  let arm_pop: u8[18] = [108, 100, 114, 32, 119, 48, 44, 32, 91, 115, 112, 93, 44, 32, 35, 49, 54,
  10];
  let i: i32 = 0;
  while (i < out.length) {
    let line_end: i32 = i;
    let line_len: i32 = 0;
    let next_start: i32 = 0;
    let remove_len: i32 = 0;
    while (line_end < out.length && out.data[line_end] != 10) { line_end = line_end + 1; }
    if (line_end >= out.length) { break; }
    line_len = line_end - i;
    next_start = line_end + 1;
    if (line_len == 10 && next_start + 10 <= out.length && slice_eq(out, i, x86_push, 11) != 0 &&
    slice_eq(out, next_start, x86_pop, 10) != 0) {
      remove_len = 11 + 10;
    } else if (line_len == 19 && next_start + 18 <= out.length && slice_eq(out, i, arm_push, 20) != 0
    && slice_eq(out, next_start, arm_pop, 18) != 0) {
      remove_len = 20 + 18;
    }
    if (remove_len > 0) {
      let j: i32 = i;
      while (j < out.length - remove_len) {
        out.data[j] = out.data[j + remove_len];
        j = j + 1;
      }
      out.length = out.length - remove_len;
      continue;
    }
    i = next_start;
  }
  return 0;
}

/** Exported function `peephole_remove_noop_mov_rax_rax`.
 * Implements `peephole_remove_noop_mov_rax_rax`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function peephole_remove_noop_mov_rax_rax(out: *CodegenOutBuf): i32 {
  let x86_noop: u8[16] = [109, 111, 118, 113, 32, 37, 114, 97, 120, 44, 32, 37, 114, 97, 120, 10];
  let i: i32 = 0;
  while (i < out.length) {
    if (i + 16 <= out.length && slice_eq(out, i, x86_noop, 16) != 0) {
      let j: i32 = i;
      while (j < out.length - 16) {
        out.data[j] = out.data[j + 16];
        j = j + 1;
      }
      out.length = out.length - 16;
      continue;
    }
    let line_end: i32 = i;
    while (line_end < out.length && out.data[line_end] != 10) { line_end = line_end + 1; }
    if (line_end >= out.length) { break; }
    i = line_end + 1;
  }
  return 0;
}

/** Exported function `peephole_remove_noop_mov_x0_x0`.
 * Implements `peephole_remove_noop_mov_x0_x0`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function peephole_remove_noop_mov_x0_x0(out: *CodegenOutBuf): i32 {
  let arm_noop: u8[11] = [109, 111, 118, 32, 120, 48, 44, 32, 120, 48, 10];
  let i: i32 = 0;
  while (i < out.length) {
    if (i + 11 <= out.length && slice_eq(out, i, arm_noop, 11) != 0) {
      let j: i32 = i;
      while (j < out.length - 11) {
        out.data[j] = out.data[j + 11];
        j = j + 1;
      }
      out.length = out.length - 11;
      continue;
    }
    let line_end: i32 = i;
    while (line_end < out.length && out.data[line_end] != 10) { line_end = line_end + 1; }
    if (line_end >= out.length) { break; }
    i = line_end + 1;
  }
  return 0;
}

/** Exported function `peephole_remove_empty_lines`.
 * Implements `peephole_remove_empty_lines`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function peephole_remove_empty_lines(out: *CodegenOutBuf): i32 {
  let src: i32 = 0;
  let dst: i32 = 0;
  let prev_was_nl: i32 = 0;
  while (src < out.length && dst < 8388608) {
    let ch: u8 = out.data[src];
    if (ch == 10) {
      if (prev_was_nl != 0) {
        src = src + 1;
        continue;
      }
      prev_was_nl = 1;
    } else {
      prev_was_nl = 0;
    }
    out.data[dst] = ch;
    dst = dst + 1;
    src = src + 1;
  }
  out.length = dst;
  return 0;
}

/** Exported function `peephole_run`.
 * Implements `peephole_run`.
 * @param out *CodegenOutBuf
 * @return i32
 */
export function peephole_run(out: *CodegenOutBuf): i32 {
  if (peephole_remove_redundant_push_pop(out) != 0) {
    return -1;
  }
  if (peephole_remove_noop_mov_rax_rax(out) != 0) {
    return -1;
  }
  if (peephole_remove_noop_mov_x0_x0(out) != 0) {
    return -1;
  }
  if (peephole_remove_empty_lines(out) != 0) {
    return -1;
  }
  return 0;
}

/** Exported function `peephole_elf_u32_eq`.
 * Implements `peephole_elf_u32_eq`.
 * @param ctx *ElfCodegenCtx
 * @param pos i32
 * @param w i32
 * @return i32
 */
export function peephole_elf_u32_eq(ctx: *ElfCodegenCtx, pos: i32, w: i32): i32 {
  if (pos < 0 || pos + 3 >= ctx.code_len) {
    return 0;
  }
  if (elf.elf_read_u32_le(ctx, pos) == w) {
    return 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function peephole_elf_region_has_meta(ctx: *ElfCodegenCtx, pos: i32, len: i32): i32 {
  let end: i32 = pos + len;
  let li: i32 = 0;
  while (li < ctx.num_labels) {
    let off: i32 = ctx.labels[li].offset;
    if (off >= pos && off < end) {
      return 1;
    }
    li = li + 1;
  }
  let pi: i32 = 0;
  while (pi < ctx.num_patches) {
    let poff: i32 = ctx.patches[pi].rel32_offset;
    if (poff >= pos && poff < end) {
      return 1;
    }
    pi = pi + 1;
  }
  let ri: i32 = 0;
  while (ri < ctx.num_relocs) {
    let roff: i32 = peephole_reloc_offset_at(ctx, ri);
    if (roff >= pos && roff < end) {
      return 1;
    }
    ri = ri + 1;
  }
  let si: i32 = 0;
  while (si < ctx.num_syms) {
    let soff: i32 = ctx.syms[si].offset;
    if (soff >= pos && soff < end) {
      return 1;
    }
    si = si + 1;
  }
  return 0;
}

/** Exported function `peephole_elf_shift_meta_after_remove`.
 * Implements `peephole_elf_shift_meta_after_remove`.
 * @param ctx *ElfCodegenCtx
 * @param pos i32
 * @param len i32
 * @return void
 */
export function peephole_elf_shift_meta_after_remove(ctx: *ElfCodegenCtx, pos: i32, len: i32): void {
  let bound: i32 = pos + len;
  let li: i32 = 0;
  while (li < ctx.num_labels) {
    if (ctx.labels[li].offset >= bound) {
      ctx.labels[li].offset = ctx.labels[li].offset - len;
    }
    li = li + 1;
  }
  let pi: i32 = 0;
  while (pi < ctx.num_patches) {
    if (ctx.patches[pi].rel32_offset >= bound) {
      ctx.patches[pi].rel32_offset = ctx.patches[pi].rel32_offset - len;
    }
    pi = pi + 1;
  }
  let ri: i32 = 0;
  while (ri < ctx.num_relocs) {
    let roff: i32 = peephole_reloc_offset_at(ctx, ri);
    if (roff >= bound) {
      peephole_reloc_offset_set(ctx, ri, roff - len);
    }
    ri = ri + 1;
  }
  let si: i32 = 0;
  while (si < ctx.num_syms) {
    if (ctx.syms[si].offset >= bound) {
      ctx.syms[si].offset = ctx.syms[si].offset - len;
    }
    si = si + 1;
  }
}

/** Exported function `peephole_elf_remove_code_bytes`.
 * Implements `peephole_elf_remove_code_bytes`.
 * @param ctx *ElfCodegenCtx
 * @param pos i32
 * @param len i32
 * @return i32
 */
export function peephole_elf_remove_code_bytes(ctx: *ElfCodegenCtx, pos: i32, len: i32): i32 {
  if (len <= 0 || pos < 0 || pos + len > ctx.code_len) {
    return -1;
  }
  if (peephole_elf_region_has_meta(ctx, pos, len) != 0) {
    return 0;
  }
  let j: i32 = pos;
  while (j < ctx.code_len - len) {
    ctx.code_data[j] = ctx.code_data[j + len];
    j = j + 1;
  }
  ctx.code_len = ctx.code_len - len;
  peephole_elf_shift_meta_after_remove(ctx, pos, len);
  return 0;
}

/**
 * See implementation.
 * e_machine：62=x86_64，183=arm64，243=riscv64。
 */
export function peephole_elf_remove_redundant_push_pop(ctx: *ElfCodegenCtx, e_machine: i32): i32 {
  let i: i32 = 0;
  while (i < ctx.code_len) {
    let remove_len: i32 = 0;
    if (e_machine == 62) {
      if (i + 1 < ctx.code_len && ctx.code_data[i] == 80 && ctx.code_data[i + 1] == 88) {
        remove_len = 2;
      }
    } else if (e_machine == 183) {
      if (i + 15 < ctx.code_len
      && peephole_elf_u32_eq(ctx, i, 3506455551) != 0
      && peephole_elf_u32_eq(ctx, i + 4, 4177527776) != 0
      && peephole_elf_u32_eq(ctx, i + 8, 4181722080) != 0
      && peephole_elf_u32_eq(ctx, i + 12, 2432713727) != 0) {
        remove_len = 16;
      }
    } else if (e_machine == 243) {
      if (i + 15 < ctx.code_len
      && peephole_elf_u32_eq(ctx, i, 4278255891) != 0
      && peephole_elf_u32_eq(ctx, i + 4, 10563619) != 0
      && peephole_elf_u32_eq(ctx, i + 8, 79107) != 0
      && peephole_elf_u32_eq(ctx, i + 12, 16843027) != 0) {
        remove_len = 16;
      }
    }
    if (remove_len > 0) {
      if (peephole_elf_remove_code_bytes(ctx, i, remove_len) != 0) {
        return -1;
      }
      continue;
    }
    i = i + 1;
  }
  return 0;
}

/**
 * See implementation.
 */
export function peephole_elf_arm64_mov_u32(rd: i32, rn: i32): i32 {
  return 2852127712 | (rn << 16) | rd;
}

/**
 * See implementation.
 * See implementation.
 */
export function peephole_elf_remove_redundant_spill_reg_mov_pair(ctx: *ElfCodegenCtx): i32 {
  if (ctx.e_machine != 183) {
    return 0;
  }
  let i: i32 = 0;
  while (i + 7 < ctx.code_len) {
    let remove_len: i32 = 0;
    let n: i32 = 10;
    while (n <= 15) {
      let w_to_rax: i32 = peephole_elf_arm64_mov_u32(n, 0);
      let w_from_rax: i32 = peephole_elf_arm64_mov_u32(0, n);
      let w_to_rbx: i32 = peephole_elf_arm64_mov_u32(n, 1);
      let w_from_rbx: i32 = peephole_elf_arm64_mov_u32(1, n);
      if (peephole_elf_u32_eq(ctx, i, w_to_rax) != 0
      && peephole_elf_u32_eq(ctx, i + 4, w_from_rax) != 0) {
        remove_len = 8;
      } else if (peephole_elf_u32_eq(ctx, i, w_from_rax) != 0
      && peephole_elf_u32_eq(ctx, i + 4, w_to_rax) != 0) {
        remove_len = 8;
      } else if (peephole_elf_u32_eq(ctx, i, w_to_rbx) != 0
      && peephole_elf_u32_eq(ctx, i + 4, w_from_rbx) != 0) {
        remove_len = 8;
      } else if (peephole_elf_u32_eq(ctx, i, w_from_rbx) != 0
      && peephole_elf_u32_eq(ctx, i + 4, w_to_rbx) != 0) {
        remove_len = 8;
      }
      if (remove_len > 0) {
        break;
      }
      n = n + 1;
    }
    if (remove_len > 0) {
      if (peephole_elf_remove_code_bytes(ctx, i, remove_len) != 0) {
        return -1;
      }
      continue;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `peephole_elf_remove_redundant_mov_x2_pair`.
 * Implements `peephole_elf_remove_redundant_mov_x2_pair`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function peephole_elf_remove_redundant_mov_x2_pair(ctx: *ElfCodegenCtx): i32 {
  if (ctx.e_machine != 183) {
    return 0;
  }
  let i: i32 = 0;
  while (i + 7 < ctx.code_len) {
    let remove_len: i32 = 0;
    /* mov x2, x0 (0xAA0003E2) + mov x0, x2 (0xAA0203E0) */
    if (peephole_elf_u32_eq(ctx, i, 2852127714) != 0
    && peephole_elf_u32_eq(ctx, i + 4, 2852258784) != 0) {
      remove_len = 8;
    } else if (peephole_elf_u32_eq(ctx, i, 2852193250) != 0
    && peephole_elf_u32_eq(ctx, i + 4, 2852258785) != 0) {
      /* mov x2, x1 + mov x1, x2 */
      remove_len = 8;
    }
    if (remove_len > 0) {
      if (peephole_elf_remove_code_bytes(ctx, i, remove_len) != 0) {
        return -1;
      }
      continue;
    }
    i = i + 1;
  }
  return 0;
}

/** Exported function `peephole_elf_run`.
 * Implements `peephole_elf_run`.
 * @param ctx *ElfCodegenCtx
 * @return i32
 */
export function peephole_elf_run(ctx: *ElfCodegenCtx): i32 {
  if (ctx == (0 as *ElfCodegenCtx)) {
    return 0;
  }
  if (peephole_elf_remove_redundant_push_pop(ctx, ctx.e_machine) != 0) {
    return -1;
  }
  if (peephole_elf_remove_redundant_mov_x2_pair(ctx) != 0) {
    return -1;
  }
  if (peephole_elf_remove_redundant_spill_reg_mov_pair(ctx) != 0) {
    return -1;
  }
  return 0;
}
