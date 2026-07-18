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

// mod.x — 硬件适配层模块入口（re-export）
//
// 模块：ir/target
// 层级：共享（被 VMIR isel / Target MIR regalloc/sched/microarch 消费）
// Phase：Phase 5+（VMIR isel 首次需要目标架构信息）
// 职责：聚合 target/ 子模块导出（cost_model / x86_64 / arm64）。
// 依赖：../vmir/machine_inst
// 设计约束：
//   - 硬件适配层通过 Target MIR 实现特定硬件的微操作和流水线级表示
//   - Cost Model 通过外部 .cost.json 配置，支持新 CPU 无需改代码（§10.3）
//   - 新 CPU 配置通过新增 .cost.json 文件支持，无需修改 IR 架构
//
// 参考文档：analysis/IR核心设计.md §10（硬件适配层）/ §10.3（多维度 Cost Model）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 5 填充
