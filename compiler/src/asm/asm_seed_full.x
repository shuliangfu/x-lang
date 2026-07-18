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
const types = import("asm.types");
const backend = import("backend");
const peephole = import("peephole");
const elf = import("platform.elf");
const backend_enc_dispatch = import("backend_enc_dispatch");
const x86_64 = import("arch.x86_64");
const arm64 = import("arch.arm64");
const riscv64 = import("arch.riscv64");
#[cfg(target_os = "macos")]
const macho = import("platform.macho");
#[cfg(target_os = "windows")]
const coff = import("platform.coff");

/** Exported function `asm_codegen_ast`.
 * Implements `asm_codegen_ast`.
 * @param module *ast.Module
 * @param arena *ast.ASTArena
 * @param out *codegen_outbuf_abi.CodegenOutBuf
 * @param ctx *ast.PipelineDepCtx
 * @return i32
 */
export function asm_codegen_ast(module: *ast.Module, arena: *ast.ASTArena, out: *codegen_outbuf_abi.CodegenOutBuf, ctx: *ast.PipelineDepCtx): i32 {
  let err: i32 = backend.asm_codegen_ast(module, arena, out, ctx);
  let err2: i32 = peephole.peephole_run(out);
  return err + err2;
}

/** Exported function `asm_codegen_elf_o`.
 * Implements `asm_codegen_elf_o`.
 * @param module *ast.Module
 * @param arena *ast.ASTArena
 * @param ctx *ast.PipelineDepCtx
 * @param elf_ctx *elf.ElfCodegenCtx
 * @param out *codegen_outbuf_abi.CodegenOutBuf
 * @return i32
 */
#[cfg(target_os = "linux")]
export function asm_codegen_elf_o(module: *ast.Module, arena: *ast.ASTArena, ctx: *ast.PipelineDepCtx, elf_ctx: *elf.ElfCodegenCtx, out: *codegen_outbuf_abi.CodegenOutBuf): i32 {
  elf.elf_ctx_reset(elf_ctx);
  if (ctx.use_macho_o != 0 || ctx.use_coff_o != 0) { return -1; }
  let e1: i32 = backend.asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
  if (e1 != 0) {
    return -1;
  }
  let e2: i32 = peephole.peephole_elf_run(elf_ctx);
  if (e2 != 0) {
    return -1;
  }
  let e3: i32 = elf.elf_resolve_patches(elf_ctx);
  if (e3 != 0) {
    return -1;
  }
  if (elf.write_elf_o_to_buf(elf_ctx, out) < 0) {
    return -1;
  }
  return 0;
}

#[cfg(target_os = "windows")]
/** Exported function `asm_codegen_elf_o`.
 * Implements `asm_codegen_elf_o`.
 * @param module *ast.Module
 * @param arena *ast.ASTArena
 * @param ctx *ast.PipelineDepCtx
 * @param elf_ctx *elf.ElfCodegenCtx
 * @param out *codegen_outbuf_abi.CodegenOutBuf
 * @return i32
 */
export function asm_codegen_elf_o(module: *ast.Module, arena: *ast.ASTArena, ctx: *ast.PipelineDepCtx, elf_ctx: *elf.ElfCodegenCtx, out: *codegen_outbuf_abi.CodegenOutBuf): i32 {
  elf.elf_ctx_reset(elf_ctx);
  if (ctx.use_macho_o != 0 || ctx.use_coff_o != 0) {
    elf_ctx.macho_leading_underscore = 1;
  }
  let e1: i32 = backend.asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
  if (e1 != 0) {
    return -1;
  }
  let e2: i32 = peephole.peephole_elf_run(elf_ctx);
  if (e2 != 0) {
    return -1;
  }
  let e3: i32 = elf.elf_resolve_patches(elf_ctx);
  if (e3 != 0) {
    return -1;
  }
  if (ctx.use_coff_o != 0) {
    if (coff.write_coff_o_to_buf(elf_ctx, out) < 0) {
      return -1;
    }
    return 0;
  }
  if (elf.write_elf_o_to_buf(elf_ctx, out) < 0) {
    return -1;
  }
  return 0;
}

#[cfg(target_os = "macos")]
/** Exported function `asm_codegen_elf_o`.
 * Implements `asm_codegen_elf_o`.
 * @param module *ast.Module
 * @param arena *ast.ASTArena
 * @param ctx *ast.PipelineDepCtx
 * @param elf_ctx *elf.ElfCodegenCtx
 * @param out *codegen_outbuf_abi.CodegenOutBuf
 * @return i32
 */
export function asm_codegen_elf_o(module: *ast.Module, arena: *ast.ASTArena, ctx: *ast.PipelineDepCtx, elf_ctx: *elf.ElfCodegenCtx, out: *codegen_outbuf_abi.CodegenOutBuf): i32 {
  elf.elf_ctx_reset(elf_ctx);
  if (ctx.use_macho_o != 0 || ctx.use_coff_o != 0) {
    elf_ctx.macho_leading_underscore = 1;
  }
  let e1: i32 = backend.asm_codegen_ast_to_elf(module, arena, elf_ctx, ctx);
  if (e1 != 0) {
    return -1;
  }
  let e2: i32 = peephole.peephole_elf_run(elf_ctx);
  if (e2 != 0) {
    return -1;
  }
  let e3: i32 = elf.elf_resolve_patches(elf_ctx);
  if (e3 != 0) {
    return -1;
  }
  if (ctx.use_macho_o != 0) {
    if (macho.write_macho_o_to_buf(elf_ctx, out) < 0) {
      return -1;
    }
    return 0;
  }
  if (elf.write_elf_o_to_buf(elf_ctx, out) < 0) {
    return -1;
  }
  return 0;
}

// See implementation.
// See implementation.
