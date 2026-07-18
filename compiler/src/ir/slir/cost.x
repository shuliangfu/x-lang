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

// cost.x — Cost function（多维度成本评估）
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3
// 职责：
//   - 定义 e-graph 节点的 cost function
//   - 读取 Cost Model 配置（§10.3 六维度）
//   - 节点 cost = instruction_cost + register_pressure + cache + branch + simd + pipeline
//   - 供 extract.x 提取最优表达式时使用
// 依赖：../inst / ../target/cost_model / ./egraph
// 设计约束：
//   - Cost Model 通过外部 .cost.json 配置，支持新 CPU 无需改代码（§10.3）
//   - cost 计算必须确定性（相同输入相同输出，禁止随机）
//   - 不同优化级别（--opt=0/1/2/3）可调整 cost 权重
//
// 参考文档：analysis/IR核心设计.md §4.3（Cost function）/ §10.3（多维度 Cost Model）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
