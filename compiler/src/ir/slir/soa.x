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

// soa.x — SoA/AoS 布局转换
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3-4
// 职责：
//   - 访问模式分析：识别结构体数组的字段访问模式
//   - 收益评估：SoA vs AoS 的 cache 命中率收益
//   - 布局转换：AoS → SoA（按字段拆分为独立数组）
//   - 契约验证：转换后契约等价（pre ⊆ / post ⊇ / effects 不变）
//   - 四步工作流（§5.2）：访问模式分析 → 收益评估 → 布局转换 → 契约验证
// 依赖：./egraph / ./rules / ../contract / ../effect
// 设计约束：
//   - 转换必须保持契约等价（不引入新副作用）
//   - 收益评估基于 Cost Model 的 cache 维度（§10.3）
//   - 转换后的代码必须通过差分测试验证
//
// 参考文档：analysis/IR核心设计.md §5.2（SoA/AoS 布局转换，四步工作流）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
