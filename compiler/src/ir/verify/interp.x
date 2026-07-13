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

// interp.x — 统一解释器框架
//
// 模块：ir/verify
// 层级：共享
// Phase：Phase 0+（Phase 0 用于验证 C-Emitter 输出语义）
// 职责：
//   - 统一解释器框架（§9.1），支持五层 IR 解释执行
//   - SHIR 解释器（与 ../shir/interp.x 协同）
//   - SMIR / SLIR / VMIR / Target MIR 各层解释器
//   - 作为差分测试的 oracle 之一（§9.2）
// 依赖：../shir/interp / ../smir / ../slir / ../vmir / ../mir
// 设计约束：
//   - 解释器只做语义验证，不追求性能
//   - 各层解释执行结果必须完全一致（语义不变量）
//   - 解释执行时契约违反必须 panic（fail-fast）
//
// 参考文档：analysis/IR核心设计.md §9.1（统一解释器框架）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 0 填充
