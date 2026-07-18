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

const ast = import("ast");
const backend = import("asm.backend");

/* See implementation. */
export extern function pipeline_asm_simd_try_inline_shuffle_call_elf_c(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32;

/** Function `simd_try_inline_shuffle_call_elf`.
 * Purpose: implements `simd_try_inline_shuffle_call_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function simd_try_inline_shuffle_call_elf(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32 {
  return pipeline_asm_simd_try_inline_shuffle_call_elf_c(
    arena, elf_ctx, call_ref, ctx, ta, stack_slot_off, type_ref);
}

/* See implementation. */
export extern function pipeline_asm_simd_try_inline_select_call_elf_c(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32;

/** Function `simd_try_inline_select_call_elf`.
 * Purpose: implements `simd_try_inline_select_call_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function simd_try_inline_select_call_elf(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32 {
  return pipeline_asm_simd_try_inline_select_call_elf_c(
    arena, elf_ctx, call_ref, ctx, ta, stack_slot_off, type_ref);
}

/* See implementation. */
export extern function pipeline_asm_simd_try_inline_binop2_call_elf_c(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32;

/** Function `simd_try_inline_binop2_call_elf`.
 * Purpose: implements `simd_try_inline_binop2_call_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function simd_try_inline_binop2_call_elf(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32 {
  return pipeline_asm_simd_try_inline_binop2_call_elf_c(
    arena, elf_ctx, call_ref, ctx, ta, stack_slot_off, type_ref);
}

/* See implementation. */
export extern function pipeline_asm_simd_try_inline_fma3_call_elf_c(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32;

/** Function `simd_try_inline_fma3_call_elf`.
 * Purpose: implements `simd_try_inline_fma3_call_elf`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
export function simd_try_inline_fma3_call_elf(
  arena: *ASTArena,
  elf_ctx: *ElfCodegenCtx,
  call_ref: i32,
  ctx: *AsmFuncCtx,
  ta: i32,
  stack_slot_off: i32,
  type_ref: i32,
): i32 {
  return pipeline_asm_simd_try_inline_fma3_call_elf_c(
    arena, elf_ctx, call_ref, ctx, ta, stack_slot_off, type_ref);
}
