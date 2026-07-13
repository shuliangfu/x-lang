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

// registry.x — Pass 注册表 + External Pass Provider 注入接口
//
// 模块：ir/pass
// 层级：共享
// Phase：Phase 3+
// 职责：
//   - Pass 注册表（Pass ID / 名称 / 依赖 / 优化级别）
//   - External Pass Provider 注入接口（§6.2）
//     · 允许外部模块（如 x-neuron）注册 AI 生成的优化 Pass
//     · 注入的 Pass 必须通过 Performance Oracle 门控（§9.3）
//   - Pass 元数据查询（供 pipeline.x 排序用）
// 依赖：../verify/perf_oracle
// 设计约束：
//   - External Pass Provider 是通用术语，不绑定具体 AI 项目（x-neuron 抽象化）
//   - 注入的 Pass 性能不提升则自动拒绝（Performance Oracle 门控）
//   - Pass 注册必须确定性（相同注册顺序相同 ID）
//
// 参考文档：analysis/IR核心设计.md §6.2（Pass 注册表 + External Pass Provider 注入）/ §9.3（Performance Oracle 门控）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
