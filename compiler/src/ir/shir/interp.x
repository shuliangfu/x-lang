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

// interp.x — SHIR 解释器（语义验证 oracle）
//
// 模块：ir/shir
// 层级：SHIR
// Phase：Phase 1
// 职责：
//   - 直接解释执行 SHIR 高层节点，作为语义验证 oracle
//   - 与 C 后端 / IR 后端执行结果对比（差分测试三 oracle 之一，§9.2）
//   - 早期语义验证：在 codegen 落地前发现契约违反
//   - 调试支持：单步执行 / 断点 / 状态检查
// 依赖：../inst / ../contract / ../effect / ../opcode
// 设计约束：
//   - 解释器只做语义验证，不追求性能
//   - 必须与 SMIR / SLIR / VMIR / Target MIR 后端执行结果完全一致
//   - 解释执行时契约违反必须 panic（fail-fast）
//
// 参考文档：analysis/IR核心设计.md §9.1（统一解释器框架）/ §9.2（差分测试）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
