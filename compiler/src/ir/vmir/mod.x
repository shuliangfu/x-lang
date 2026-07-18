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

// mod.x — VMIR 层模块入口（re-export）
//
// 模块：ir/vmir
// 层级：VMIR（Value MIR / Instruction Selection IR，指令选择层）
// Phase：Phase 5
// 职责：聚合 vmir/ 子模块导出（isel / dag / sched / machine_inst）。
// 依赖：../slir / ../inst / ../contract
// 设计约束：
//   - v4.0 新增层，将原 Target MIR 的"指令选择 + 寄存器分配"双重职责拆分
//   - VMIR 专做指令选择（isel），Target MIR 专做寄存器分配 + 微架构对齐
//   - 职责单一后，isel 可独立复用（新架构只需新增 VMIR → Target MIR lowering）
//   - 契约物化：Contract → 机器指令属性
//
// 参考文档：analysis/IR核心设计.md §2.1（VMIR 层）/ §2.2（VMIR 职责）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 5 填充
