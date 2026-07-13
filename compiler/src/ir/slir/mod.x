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

// mod.x — SLIR 层模块入口（re-export）
//
// 模块：ir/slir
// 层级：SLIR（Shux Low IR，机器无关极致优化，immutable graph）
// Phase：Phase 3-4
// 职责：聚合 slir/ 子模块导出（egraph / rules / cost / extract / saturate / conflict / superopt / soa / verify）。
// 依赖：../smir / ../inst / ../contract / ../effect
// 设计约束：
//   - SLIR 采用 immutable 设计：Pass 接口为函数式 `&SLIRGraph → SLIRGraph`（§4.9）
//   - 不改 Instruction，生成新 Graph（支持 Parallel Pass / Incremental Compile / Undo）
//   - e-graph 重写引擎是 SLIR 的核心
//   - 契约保持：变换前后契约等价（§1.4）
//
// 参考文档：analysis/IR核心设计.md §2.1（SLIR 层）/ §4.9（SLIR immutable 原则）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
