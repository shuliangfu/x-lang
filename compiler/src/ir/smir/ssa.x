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

// ssa.x — SSA 构建（φ 节点 + def-use 链）
//
// 模块：ir/smir
// 层级：SMIR
// Phase：Phase 2
// 职责：
//   - SHIR → SMIR lowering 时构建 SSA 形式
//   - 插入 φ 节点（支配边界）
//   - 构建 def-use 链（每条 IRInst 的定义点与使用点）
//   - 变量重命名（保证每个 SSAReg 唯一定值）
// 依赖：../shir / ../inst
// 设计约束：
//   - SSA 是 SMIR 的不变量：每个 SSAReg 恰好被定义一次
//   - def_inst 字段必须正确填充（§2.4 SSAReg）
//   - φ 节点的入边数 = 前驱基本块数
//
// 参考文档：analysis/IR核心设计.md §2.1（SMIR 层）/ §2.4（SSAReg 数据结构）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
