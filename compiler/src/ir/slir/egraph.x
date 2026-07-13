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

// egraph.x — e-graph 数据结构（Arena-native）
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3
// 职责：
//   - 定义 Arena-native EGraph 数据结构（节点 / e-class / union-find）
//   - e-class 合并（add / merge / union）
//   - 节点上限控制（10k，超限触发 capped 警告，§4.8）
//   - 与 union-find 协同维护等价类
// 依赖：../inst / ../contract
// 设计约束：
//   - Arena-native：所有 e-graph 节点在 Arena 中分配，O(1) 批量回收
//   - 节点上限 10k，超限提取当前最优并报告警告（避免内存爆炸）
//   - 分块策略：函数为主分块单位 + region 作 alias 边界（§4.6）
//   - 不是"每 Region 一个 e-graph"——Region 是 Arena 粒度，过细会爆炸
//
// 参考文档：analysis/IR核心设计.md §4.6（分层饱和策略）/ §4.8（e-graph 内存管理）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
