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

// ownership.x — 所有权图（Linear move/borrow 边）
//
// 模块：ir/smir
// 层级：SMIR
// Phase：Phase 2
// 职责：
//   - 构建 Linear(T) move / borrow 的显式所有权图
//   - 验证 Linear move 语义：move 后 src 失效（post: linear_consumed(src)）
//   - 验证 borrow 生存期：borrow 不超过被借对象的生存期
//   - 跟踪 linear_valid / linear_consumed 状态（契约前置条件检查用）
// 依赖：../inst / ../contract / ../effect
// 设计约束：
//   - Linear(T) 的 move 语义在 IR 层不可复制（内存安全基础）
//   - 所有权传递通过 Contract.ownership 字段编码（Move / Borrow / None）
//   - 优先验证所有权语义，是内存安全的基础（项目约束）
//
// 参考文档：analysis/IR核心设计.md §1.2（Contract.ownership）/ §2.1（SMIR 所有权图）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
