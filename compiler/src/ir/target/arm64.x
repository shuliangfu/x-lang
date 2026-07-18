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

// arm64.x — ARM64 目标描述
//
// 模块：ir/target
// 层级：共享
// Phase：Phase 5（VMIR isel 首次需要）
// 职责：
//   - ARM64 架构描述（寄存器集 / 指令集 / 寻址模式）
//   - 指令选择规则（SLIR → ARM64 MachineInst）
//   - 寄存器分配约束（ARM64 寄存器数量 / 调用约定）
//   - 微架构特性（NEON SIMD / 流水线端口）
// 依赖：../vmir/machine_inst
// 设计约束：
//   - 与 cost_model.x 协同（Cost Model 提供 cost，本文件提供架构约束）
//   - 不同 ARM64 CPU 微架构差异通过 .cost.json 配置支持
//   - 调用约定遵循 X ABI / C ABI（§8）
//
// 参考文档：analysis/IR核心设计.md §10（硬件适配层）/ §8（调用约定与 ABI）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 5 填充
