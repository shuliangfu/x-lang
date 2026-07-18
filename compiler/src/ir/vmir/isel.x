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

// isel.x — 模式匹配指令选择
//
// 模块：ir/vmir
// 层级：VMIR
// Phase：Phase 5
// 职责：
//   - SLIR → VMIR lowering：将机器无关运算选择为目标机器指令
//   - 模式匹配规则（a+b → LEA/ADD/FMA 决策）
//   - 复合指令识别（乘加 → FMA / 地址计算 → LEA）
//   - 目标架构特定指令选择（x86_64 / arm64 / riscv64）
// 依赖：../slir / ./machine_inst / ../target
// 设计约束：
//   - Phase 5 VMIR Gate：isel 正确率 100%，fibonacci 可执行（§11.3）
//   - 指令选择必须保持契约等价（Contract 物化不改变语义）
//   - 选择决策基于 Cost Model（选 cost 最小的指令序列）
//
// 参考文档：analysis/IR核心设计.md §2.1（VMIR isel）/ §2.2（VMIR 职责）/ §11.3（Phase 5 Gate）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 5 填充
