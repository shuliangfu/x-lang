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

// mod.x — Target MIR 层模块入口（re-export）
//
// 模块：ir/mir
// 层级：Target MIR（Machine IR，特定硬件寄存器分配 + 微架构对齐）
// Phase：Phase 6
// 职责：聚合 mir/ 子模块导出（regalloc / spill / sched / microarch）。
// 依赖：../vmir / ../inst / ../contract / ../target
// 设计约束：
//   - Target MIR 专做寄存器分配 + 微架构对齐（VMIR 拆分后职责单一）
//   - region-based Coloring 寄存器分配（§5.3）
//   - 热度感知 spilling（冷变量溢出到栈）
//   - 微架构流水线建模 + 执行端口调度
//   - 契约物化：Contract 已物化为机器指令属性
//
// 参考文档：analysis/IR核心设计.md §2.1（Target MIR 层）/ §2.2（Target MIR 职责）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 6 填充
