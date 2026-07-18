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

// verify.x — SMIR 层验证器
//
// 模块：ir/smir
// 层级：SMIR
// Phase：Phase 2
// 职责：
//   - SSA 完整性验证（每个 SSAReg 唯一定值 / φ 节点入边数正确）
//   - 所有权图一致性（Linear move 后 src 失效 / borrow 生存期闭合）
//   - 契约前置条件检查（§1.3 Step 2，每条指令执行前验证 pre-condition）
//   - 契约后置条件传播（§1.3 Step 3，执行后更新 IR 状态）
//   - region 存活性检查（region_alive，未被 arena_reset）
// 依赖：../inst / ../contract / ../effect / ../verify / ./ssa / ./ownership / ./alias
// 设计约束：
//   - 验证失败 = 编译器 bug（前端 typeck 与 IR 契约矛盾），直接 panic
//   - 不生成错误代码（fail-fast）
//   - 这是契约验证的主战场（SMIR 是"契约验证"层，§2.2）
//
// 参考文档：analysis/IR核心设计.md §1.3（契约三步验证）/ §2.2（SMIR 契约验证职责）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 2 填充
