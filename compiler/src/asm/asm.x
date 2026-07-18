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
const codegen_outbuf_abi = import("codegen_outbuf_abi");

/* See implementation. */
export extern function driver_skip_codegen_dep_0_get(): i32;
/* See implementation. */
export extern function driver_set_current_dep_path_for_codegen(path: *u8): void;
/* See implementation. */
export extern function asm_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, pipeline_ctx: *u8): i32;
export extern function asm_asm_codegen_elf_o(module: *u8, arena: *u8, pipeline_ctx: *u8, elf_ctx: *u8, out: *u8): i32;

/**
 * See implementation.
 * See implementation.
 */
export function asm_codegen_ast(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  return asm_asm_codegen_ast(module as *u8, arena as *u8, out as *u8, ctx as *u8);
}

/**
 * See implementation.
 * See implementation.
 * See implementation.
 * See implementation.
 */
#[cfg(target_os = "linux")]
export function asm_codegen_elf_o(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, elf_ctx: *u8, out: *CodegenOutBuf): i32 {
  return asm_asm_codegen_elf_o(module as *u8, arena as *u8, ctx as *u8, elf_ctx as *u8, out as *u8);
}

#[cfg(not(target_os = "linux"))]
/** Exported function `asm_codegen_elf_o`.
 * Implements `asm_codegen_elf_o`.
 * @param module *Module
 * @param arena *ASTArena
 * @param ctx *PipelineDepCtx
 * @param elf_ctx *u8
 * @param out *CodegenOutBuf
 * @return i32
 */
export function asm_codegen_elf_o(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, elf_ctx: *u8, out: *CodegenOutBuf): i32 {
  return asm_asm_codegen_elf_o(module as *u8, arena as *u8, ctx as *u8, elf_ctx as *u8, out as *u8);
}
