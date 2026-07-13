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

// sched.x — 早期指令调度
//
// 模块：ir/vmir
// 层级：VMIR
// Phase：Phase 5
// 职责：
//   - 基于 DAG 的依赖约束下指令重排
//   - 早期调度（VMIR 层），后续 Target MIR 层做最终调度
//   - 目标：减少流水线停顿 / 提高 ILP（指令级并行）
//   - 考虑 Effect 约束（Write 不可跨 Pure 重排）
// 依赖：./dag / ./machine_inst / ../effect
// 设计约束：
//   - 调度必须保持依赖不变量（不破坏 DAG 边）
//   - 调度决策基于 Cost Model 的 pipeline 维度（§10.3）
//   - 确定性：相同 DAG 相同调度结果
//
// 参考文档：analysis/IR核心设计.md §2.1（VMIR 早期指令调度）/ §2.2（VMIR 职责）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 5 填充
