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

// mod.x — Pass Pipeline 模块入口（re-export）
//
// 模块：ir/pass
// 层级：共享（跨五层 IR 调度 Pass）
// Phase：Phase 3+（SLIR 阶段开始大量使用 Pass）
// 职责：聚合 pass/ 子模块导出（pipeline / registry）。
// 依赖：../shir / ../smir / ../slir / ../vmir / ../mir
// 设计约束：
//   - 声明式 Pass Pipeline 系统（§6.1）
//   - 允许动态注入 AI 生成的优化 Pass（External Pass Provider）
//   - Pass Pipeline 顺序由 Benchmark 决定（实现级问题，非设计阶段决定）
//
// 参考文档：analysis/IR核心设计.md §6（优化管道与 Pass 系统）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
