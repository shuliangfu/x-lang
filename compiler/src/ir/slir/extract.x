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

// extract.x — e-graph 提取策略
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3
// 职责：
//   - 从饱和后的 e-graph 中提取 cost 最小的表达式
//   - 动态规划提取（自底向上，每个 e-class 选 cost 最小的 e-node）
//   - 处理 capped 情况（节点超限时提取当前最优，§4.8）
//   - 提取结果作为 SLIR → VMIR lowering 的输入
// 依赖：./egraph / ./cost
// 设计约束：
//   - 提取必须确定性（相同 e-graph 相同 cost → 相同输出）
//   - 提取结果必须保持契约等价（变换前后 pre ⊆ / post ⊇ / effects 不变）
//   - 提取复杂度 O(节点数)，不重复计算
//
// 参考文档：analysis/IR核心设计.md §4.4（提取策略）/ §4.8（capped 处理）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
