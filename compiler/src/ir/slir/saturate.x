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

// saturate.x — 分层饱和策略
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3
// 职责：
//   - 分层饱和执行（§4.6）：
//     · Layer 1：algebra_simplify 规则饱和（代数化简）
//     · Layer 2：契约优化规则饱和（基于 Contract 的等价变换）
//     · Layer 3：搜索优化规则饱和（Superoptimizer 触发）
//   - 分块策略：函数为主分块单位 + region 作 alias 边界
//   - 饱和停止条件：无新节点 / 节点上限 / 迭代次数上限
// 依赖：./egraph / ./rules / ./conflict
// 设计约束：
//   - 不是"每 Region 一个 e-graph"——Region 是 Arena 粒度，过细会爆炸
//   - 函数为主分块，region 作 alias 边界（跨 region 不合并）
//   - 饱和过程必须确定性（相同输入相同输出）
//
// 参考文档：analysis/IR核心设计.md §4.6（分层饱和策略，含"为什么不是每 Region 一个 e-graph"论证）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
