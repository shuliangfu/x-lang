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

// verify.x — SHIR 层独立验证器
//
// 模块：ir/shir
// 层级：SHIR
// Phase：Phase 1
// 职责：
//   - SHIR 层契约一致性检查（lowering 后立即验证）
//   - 高层结构完整性（Pattern 穷尽性 / Coroutine 状态机闭合性）
//   - 泛型特化后的类型一致性
//   - debug_loc 源码位置完整性
// 依赖：../inst / ../contract / ../effect / ../verify
// 设计约束：
//   - 验证失败 = 编译器 bug，直接 panic 报告不一致点
//   - 不生成错误代码（fail-fast）
//   - 与 ../verify.x（三步检查）协同：本文件做 SHIR 特定检查，../verify.x 做通用契约检查
//
// 参考文档：analysis/IR核心设计.md §1.3（契约验证机制）/ §2.2（SHIR 职责）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
