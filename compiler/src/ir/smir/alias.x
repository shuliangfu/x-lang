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

// alias.x — Region-aware alias analysis
//
// 模块：ir/smir
// 层级：SMIR
// Phase：Phase 2
// 职责：
//   - 基于 Region 的别名分析（不同 region 的指针无别名）
//   - 维护 alias set（post: no_alias(dst, other_ptrs) 更新）
//   - 为 SLIR e-graph 重写提供别名约束（region 作 alias 边界，§4.6）
//   - 为 Scheduler 提供可重排依据（Effect.Write{regions} 不相交即可重排）
// 依赖：../inst / ../contract / ../effect
// 设计约束：
//   - Region 是 Arena 粒度，region-aware 分析比传统指针分析精确
//   - Alias Analysis Pass 只关心 Effect（region 读写），不关心 Ownership（§1.7）
//   - 别名信息供后续 Pass 消费，不重复计算
//
// 参考文档：analysis/IR核心设计.md §1.7（Alias Analysis Pass）/ §2.1（SMIR region-aware 内存模型）/ §4.6（region 作 alias 边界）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
