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

// asm_build_list.x — asm 自举构建顺序与 LIBROOT 的唯一定义（供 scripts/build_shux_asm.sh 读取）
//
// 职责：-backend asm 构建 shux 时，各 .x 模块的编译顺序与 -L 库根由此文件定义；脚本通过 grep/sed 读取，后续可迁为 .x 内逻辑（如 driver 调 spawn 逐条编译）。
// 约定：脚本匹配 "// BUILD:\t" 行，后接 "out.o\tpath/to/source.x"（制表符分隔）；"// LIBROOT:\t" 行整行为 -L 参数。
// 依赖顺序：token/ast/codegen/typeck/lexer → preprocess → std.fs → lsp → asm 子树 → parser → pipeline → main。

// LIBROOT:	-L asm_libroot -L .. -L src -L src/lexer -L src/ast -L src/parser -L src/typeck -L src/codegen -L src/preprocess -L src/pipeline -L src/lsp -L src/asm

// BUILD:	token.o	src/lexer/token.x
// BUILD:	ast.o	src/ast/ast.x
// BUILD:	codegen.o	src/codegen/codegen.x
// BUILD:	typeck.o	src/typeck/typeck.x
// BUILD:	lexer.o	src/lexer/lexer.x
// BUILD:	preprocess.o	src/preprocess/preprocess.x
// BUILD:	std_fs.o	asm_libroot/std/fs/mod.x
// BUILD:	lsp.o	src/lsp/lsp.x
// BUILD:	types.o	src/asm/types.x
// BUILD:	platform_elf.o	src/asm/platform/elf.x
// BUILD:	x86_64.o	src/asm/arch/x86_64.x
// BUILD:	x86_64_enc.o	src/asm/arch/x86_64_enc.x
// BUILD:	arm64.o	src/asm/arch/arm64.x
// BUILD:	arm64_enc.o	src/asm/arch/arm64_enc.x
// BUILD:	riscv64.o	src/asm/arch/riscv64.x
// BUILD:	riscv64_enc.o	src/asm/arch/riscv64_enc.x
// BUILD:	peephole.o	src/asm/peephole.x
// BUILD:	backend.o	src/asm/backend.x
// BUILD:	asm.o	src/asm/asm.x
// BUILD:	macho.o	src/asm/platform/macho.x
// BUILD:	coff.o	src/asm/platform/coff.x
// BUILD:	parser.o	src/parser/parser.x
// BUILD:	pipeline.o	src/pipeline/pipeline.x
// BUILD:	main.o	src/main.x

// EMPTY_TEXT_EMITTER_BACKLOG（M8a，2026-05）：lsp.o/asm.o/arm64_enc.o 等 __text=0 时先用
//   SHUX_ASM_ENTRY_ONLY_DEBUG=1 ./shux -backend asm -o /tmp/x.o $LIBROOT <src> 看 AFTER funcs=N。
// arm64_enc 典型 N=1/62（parser 截断，非仅 skip_heavy）。typeck/parser/backend 见 M8b 第二遍 EMIT_HEAVY。
// 曾见 dep path_buf 错乱已用 dep_logical_path_mirror 修复；对照 SELFHOST §4.1。
