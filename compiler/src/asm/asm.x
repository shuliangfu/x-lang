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

// asm.x — 汇编后端对外入口（供 pipeline 调用）
//
// 职责：导出 asm_codegen_ast(module, arena, out, ctx)，供 pipeline 在 -backend asm 时调用；ctx.target_arch 决定架构。
// 依赖：ast、codegen_outbuf_abi；复杂实现与 ELF 上下文均经原始 C bridge 透传，避免 `asm.x -E`
// 解析大 .x 依赖。

const ast = import("ast");
const codegen_outbuf_abi = import("codegen_outbuf_abi");

/** 与 pipeline 对齐：若非 0 则跳过 dep 0 的机器码编码（宿主已提供等价 .o）。 */
extern function driver_skip_codegen_dep_0_get(): i32;
/** CALL 前缀：当前正在为第 j 个 dep 编码时须指向 dep 池 import 路径；入口模块前须置 NULL。 */
extern function driver_set_current_dep_path_for_codegen(path: *u8): void;
/** backend.x 的公开入口本身只是薄转发；这里直接走现成 C glue，避免 `asm.x -E` 解析整份 backend.x。 */
extern function asm_asm_codegen_ast(module: *u8, arena: *u8, out: *u8, pipeline_ctx: *u8): i32;
extern function asm_asm_codegen_elf_o(module: *u8, arena: *u8, pipeline_ctx: *u8, elf_ctx: *u8, out: *u8): i32;

/**
 * 汇编后端入口：将 AST 生成汇编文本写入 out（与 codegen 共用 CodegenOutBuf）。
 * M8b：勿写 `if (foo(...) != 0)`——.x parser 会丢整函数；用 let 累加后 return。
 */
function asm_codegen_ast(module: *Module, arena: *ASTArena, out: *CodegenOutBuf, ctx: *PipelineDepCtx): i32 {
  return asm_asm_codegen_ast(module as *u8, arena as *u8, out as *u8, ctx as *u8);
}

/**
 * 将 AST 生成机器码并写出 .o 到 out；elf_ctx 由调用方提供并在此处重置。返回 0 成功。
 * build_shux_asm（ENTRY_MODULE_ONLY）下 dep 机器码由其它 build_asm/*.o 提供，不在此编 dep 循环。
 * M8b：勿 `if (module.foo()!=0)` 嵌在 return 表达式内（.x parser 会丢函数）；
 * 用分分支 if + return；按 ctx.use_coff_o / use_macho_o 选择 COFF / Mach-O / ELF 写出。
 */
#[cfg(target_os = "linux")]
function asm_codegen_elf_o(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, elf_ctx: *u8, out: *CodegenOutBuf): i32 {
  return asm_asm_codegen_elf_o(module as *u8, arena as *u8, ctx as *u8, elf_ctx as *u8, out as *u8);
}

#[cfg(not(target_os = "linux"))]
function asm_codegen_elf_o(module: *Module, arena: *ASTArena, ctx: *PipelineDepCtx, elf_ctx: *u8, out: *CodegenOutBuf): i32 {
  return asm_asm_codegen_elf_o(module as *u8, arena as *u8, ctx as *u8, elf_ctx as *u8, out as *u8);
}
