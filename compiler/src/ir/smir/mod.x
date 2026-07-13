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

// mod.x — SMIR 层模块入口（re-export）
//
// 模块：ir/smir
// 层级：SMIR（Shux Mid IR，SSA + 显式所有权图）
// Phase：Phase 2
// 职责：聚合 smir/ 子模块导出（ssa / ownership / inline / alias / verify）。
// 依赖：../shir / ../inst / ../contract / ../effect / ../abi
// 设计约束：
//   - SMIR 把语言语义转化为可验证约束（契约验证的主战场）
//   - Linear move / borrow 边显式编码
//   - region-aware alias analysis
//   - 跨 X ABI 边界内联（契约快照策略，§1.6）
//
// 参考文档：analysis/IR核心设计.md §2.1（SMIR 层）/ §2.2（SMIR 职责）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
