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

// conflict.x — 规则冲突解决机制
//
// 模块：ir/slir
// 层级：SLIR
// Phase：Phase 3
// 职责：
//   - 处理五类规则冲突（§4.7）：
//     · 多规则匹配：多个规则同时匹配同一节点 → 按优先级选择
//     · 互逆：两条规则互为逆（a→b / b→a）→ 等价类合并，不重复应用
//     · 振荡：规则应用导致状态循环 → 检测并停止
//     · 契约矛盾：规则应用导致契约不一致 → 拒绝该规则
//     · 优先级：同级规则冲突 → 按规则 ID 顺序稳定选择
//   - 等价类合并语义（互逆规则的统一处理）
// 依赖：./egraph / ./rules / ../contract
// 设计约束：
//   - 冲突解决必须确定性（相同冲突相同决策）
//   - 契约矛盾的规则永远拒绝（不静默退化）
//   - 振荡检测防止 e-graph 不收敛
//
// 参考文档：analysis/IR核心设计.md §4.7（规则冲突解决，5 类冲突表 + 等价类合并语义）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
