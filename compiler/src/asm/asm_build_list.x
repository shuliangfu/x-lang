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

// See implementation.
// See implementation.
// See implementation.
// See implementation.
