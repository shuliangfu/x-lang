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

// spill.x — 热度感知 spilling
//
// 模块：ir/mir
// 层级：Target MIR
// Phase：Phase 6
// 职责：
//   - 寄存器分配失败时选择溢出变量到栈
//   - 热度感知：冷变量优先溢出（基于性能分析）
//   - 插入 load/store 指令（栈 ↔ 寄存器）
//   - 溢出后重新尝试寄存器分配
// 依赖：./regalloc / ../vmir/machine_inst
// 设计约束：
//   - 热度信息来自 PGO（Profile-Guided Optimization）或静态分析
//   - 溢出决策基于 Cost Model（溢出 cost < 寄存器复用 cost）
//   - 确定性：相同热度信息相同溢出决策
//
// 参考文档：analysis/IR核心设计.md §5.3（热度感知 spilling 策略）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 6 填充
