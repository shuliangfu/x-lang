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

// sched.x — 最终指令调度
//
// 模块：ir/mir
// 层级：Target MIR
// Phase：Phase 6
// 职责：
//   - 寄存器分配后的最终指令调度
//   - 微架构感知：考虑执行端口 / 流水线延迟 / cache 行为
//   - 与 VMIR 早期调度协同（VMIR 做粗调度，Target MIR 做精调度）
//   - 目标：最大化流水线利用率 / 减少 cache miss
// 依赖：../vmir/dag / ../vmir/machine_inst / ./regalloc / ./microarch
// 设计约束：
//   - 调度必须保持依赖不变量（不破坏 DAG 边）
//   - 调度决策基于 Cost Model 的 pipeline + cache 维度（§10.3）
//   - 确定性：相同输入相同调度结果
//
// 参考文档：analysis/IR核心设计.md §2.1（Target MIR 最终指令调度）/ §10.3（Cost Model pipeline/cache 维度）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 6 填充
