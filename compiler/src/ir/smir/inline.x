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

// inline.x — X ABI 跨模块内联 + 契约快照
//
// 模块：ir/smir
// 层级：SMIR
// Phase：Phase 2
// 职责：
//   - X ABI 跨模块内联决策（InlinePolicy: Always / Never + 热度阈值）
//   - 契约快照策略（§1.6）：
//     · Step 1 检查被调用者 pre-condition 是否满足
//     · Step 2 直接注入 post-condition 到当前上下文（不递归展开）
//     · Step 3 后续优化基于注入的 post-condition
//   - 继承被调用者的 Effect（Inline Pass 关心 Effect，§1.7 消费关系表）
//   - 所有权传递（Linear move 边跨内联边界延续）
// 依赖：../inst / ../contract / ../effect / ../abi
// 设计约束：
//   - 契约传播复杂度 O(1)：只查一次 pre + 注入一次 post，不递归
//   - C ABI 永不内联（FFI 边界，§1.8 映射表）
//   - 内联后契约不变量仍需满足（§1.4 等价规则）
//
// 参考文档：analysis/IR核心设计.md §1.6（契约快照）/ §1.7（Inline Pass 消费关系）/ §8（X ABI 内联策略）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
