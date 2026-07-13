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

// perf_oracle.x — Performance Oracle 门控
//
// 模块：ir/verify
// 层级：共享
// Phase：Phase 3+（SLIR 优化 Pass 开始门控）
// 职责：
//   - Performance Oracle 系统（§9.3）：优化 Pass 合入门控
//   - 性能不提升的 Pass 自动拒绝（不进入 pipeline）
//   - 性能退化检测：Pass 应用后性能下降则回退
//   - External Pass Provider 注入的 Pass 必须通过 Performance Oracle 门控
// 依赖：../pass/registry
// 设计约束：
//   - 性能不提升的 Pass 自动拒绝（绝不静默退化）
//   - 门控基于 Benchmark 结果（确定性，相同输入相同决策）
//   - 性能退化检测必须可回退（风险治理：可回退设计）
//
// 参考文档：analysis/IR核心设计.md §9.3（Performance Oracle 系统）/ §13.3（风险治理可回退设计）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
