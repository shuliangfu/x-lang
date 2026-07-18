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

// dag.x — DAG 依赖图构建
//
// 模块：ir/vmir
// 层级：VMIR
// Phase：Phase 5
// 职责：
//   - 将 MachineInst 序列构建为 DAG（有向无环图）
//   - 节点 = MachineInst，边 = 数据依赖 / 控制依赖
//   - 依赖来源：defs / uses 重叠 / Effect 约束（Write 不可重排）
//   - 供 sched.x 做指令调度
// 依赖：./machine_inst / ../effect
// 设计约束：
//   - DAG 必须无环（有环 = 编译器 bug）
//   - 依赖边基于 Effect（Write{regions} 不相交可并行）
//   - DAG 构建必须确定性
//
// 参考文档：analysis/IR核心设计.md §2.1（VMIR DAG 构建）/ §1.7（Effect 调度约束）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 5 填充
