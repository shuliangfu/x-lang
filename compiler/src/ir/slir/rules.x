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

// rules.x — e-graph 重写规则定义
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3
// 职责：
//   - 定义四组重写规则集（§4.2）：
//     · algebra_simplify：代数化简（a+0=a / a*1=a / a-a=0）
//     · strength_reduction：强度折减（x*2 → x<<1 / x/2 → x>>1）
//     · linear_optim：Linear move 优化（合并连续 move / 消除冗余 consume）
//     · alias_optim：别名优化（noalias_load 提升为寄存器缓存）
//   - 规则优先级（§4.6）：代数化简 > 契约优化 > 搜索优化
// 依赖：../inst / ../contract / ./egraph
// 设计约束：
//   - 每条规则必须保证契约等价（pre ⊆ / post ⊇ / effects 不变）
//   - 规则按优先级分层执行，先代数化简，再契约优化，最后搜索优化
//   - External Pass Provider 可注入 AI 生成的规则（§6.2）
//
// 参考文档：analysis/IR核心设计.md §4.2（重写规则定义）/ §4.6（分层饱和策略）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
