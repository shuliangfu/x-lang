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

// mod.x — SHIR 层模块入口（re-export）
//
// 模块：ir/shir
// 层级：SHIR（Shux High IR，最接近语言语义）
// Phase：Phase 1
// 职责：聚合 shir/ 子模块导出（lower / interp / verify）。
// 依赖：../inst / ../contract / ../effect / ../opcode / ../abi
// 设计约束：
//   - SHIR 是"语言语义的 1:1 映射"，不是"低级 IR 的预处理层"（§1.8）
//   - 保留高层结构（Linear / Region / X ABI / Pattern Match / Coroutine / Generator）
//   - 延迟 lowering：只有当高层结构阻碍进一步优化时才 lower 到 SMIR
//
// 参考文档：analysis/IR核心设计.md §1.8（SHIR 高层性原则）/ §2.1（SHIR 层）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
