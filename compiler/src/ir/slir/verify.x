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

// verify.x — SLIR 层验证器（含 immutable 检查）
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3
// 职责：
//   - e-graph 饱和后契约等价验证（§1.4：pre ⊆ / post ⊇ / effects 不变）
//   - immutable 检查（§4.9）：SLIR Pass 不改 Instruction，生成新 Graph
//   - 提取结果语义一致性验证（与 SMIR 解释器对比）
//   - 节点上限 capped 警告报告
// 依赖：./egraph / ./extract / ../contract / ../effect / ../verify
// 设计约束：
//   - immutable 违反 = 编译器 bug，直接 panic
//   - 契约不等价 = 规则错误，拒绝该变换
//   - 验证失败 fail-fast，不静默退化
//
// 参考文档：analysis/IR核心设计.md §1.4（优化器等价验证判据）/ §4.9（SLIR immutable 原则）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
