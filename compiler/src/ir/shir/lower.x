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

// lower.x — .x AST → SHIR lowering + 契约提取
//
// 模块：ir/shir
// 层级：SHIR
// Phase：Phase 1
// 职责：
//   - 将 typeck 后的 AST 转换为 SHIR 高层节点
//   - 提取 Linear / Region / X ABI 语义信息生成 Contract（§1.3 Step 1）
//   - 保留 Pattern Match / Coroutine / Generator 等高层结构（§1.8）
//   - 泛型 monomorphization（特化）
//   - 死代码消除（SHIR 层早期 DCE）
//   - Pattern 穷尽性检查（未来特性）
// 依赖：../../ast / ../inst / ../contract / ../effect / ../opcode / ../abi
// 设计约束：
//   - SHIR 是"语言语义的 1:1 映射"，不做激进 lowering
//   - 契约提取必须 100% 确定性（前端 typeck 已验证，IR 层只做物化）
//   - SHUX 语言新增高层特性时，SHIR 同步保留对应高层节点
//
// 参考文档：analysis/IR核心设计.md §1.3（契约提取）/ §1.8（SHIR 高层性原则）/ §2.2（SHIR 职责）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
