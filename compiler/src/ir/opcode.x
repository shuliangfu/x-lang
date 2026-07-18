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

// opcode.x — Opcode 枚举（22 条核心指令）
//
// 模块：ir
// 层级：共享（被五层 IR 共用）
// Phase：Phase 1（SHIR 首次发射 IRInst 即用）
// 职责：
//   - 定义 Opcode 枚举，覆盖四类指令：
//     · 核心契约指令（region_alloc / arena_alloc / arena_reset / linear_move / noalias_load / x_abi_call / pure_call）
//     - 优化提示指令（loop_unroll_hint / branch_predict / prefetch）
//     - SIMD 指令（vector_load / vector_op / vector_store，支持 VLA）
//     - 原子指令（atomic_load / atomic_store / atomic_cas / memory_fence，携带 MemoryOrder）
// 依赖：无
// 设计约束：
//   - 22 条指令是 v4.0 冻结的核心集，新增指令需 Benchmark 证明收益
//   - 每条指令的 Contract 定义在 contract.x 中，opcode 本身只关心操作码
//   - SIMD 指令支持 vl 参数（变长向量化）
//
// 参考文档：analysis/IR核心设计.md §3.1（指令集总览，22 条）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
