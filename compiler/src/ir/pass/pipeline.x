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

// pipeline.x — 声明式 pipeline 框架
//
// 模块：ir/pass
// 层级：共享
// Phase：Phase 3+
// 职责：
//   - 声明式 Pass Pipeline 框架（§6.1）
//   - Pass 注册与依赖排序
//   - Pipeline 执行引擎（按顺序调用 Pass）
//   - 支持动态注入 External Pass Provider 的 Pass
// 依赖：./registry
// 设计约束：
//   - Pipeline 顺序由 Benchmark 决定（实现级问题，§11.2）
//   - 不同优化级别（--opt=0/1/2/3）启用不同 Pass 子集
//   - 确定性：相同 Pipeline 相同输入相同输出
//
// 参考文档：analysis/IR核心设计.md §6.1（声明式 pipeline 框架）/ §11.2（Pass Pipeline 顺序由 Benchmark 决定）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
