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

// mod.x — 验证与测试基础设施模块入口（re-export）
//
// 模块：ir/verify
// 层级：共享（跨五层 IR 验证）
// Phase：Phase 0+（Phase 0 即开始差分测试）
// 职责：聚合 verify/ 子模块导出（interp / diff_test / perf_oracle / fuzz）。
// 依赖：../shir / ../smir / ../slir / ../vmir / ../mir
// 设计约束：
//   - 验证策略：形式化契约驱动开发 + Differential Fuzzing + Oracle + Performance Oracle
//   - 差分测试三 oracle 对比（C 后端 / 解释器 / codegen），确保语义一致性
//   - Performance Oracle 作为优化 Pass 合入门控
//
// 参考文档：analysis/IR核心设计.md §9（验证测试差分框架）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 0 填充
