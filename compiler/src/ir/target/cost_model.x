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

// cost_model.x — 多维度 Cost Model 加载器
//
// 模块：ir/target
// 层级：共享
// Phase：Phase 3（SLIR e-graph 需要 cost）+ Phase 5（VMIR isel 需要 cost）
// 职责：
//   - 加载 .cost.json 配置文件（§10.3 六维度）：
//     · inst_costs：指令成本表
//     · register_pressure：寄存器压力权重
//     · cache_hierarchy：cache 层级配置
//     · branch_model：分支预测模型
//     · simd_capacity：SIMD 容量
//     · pipeline_model：流水线模型
//   - 提供 Cost 查询接口（供 SLIR cost.x / VMIR isel.x / Target MIR sched.x 消费）
//   - 支持 --target-cost 选项切换 Cost Model
// 依赖：../vmir/machine_inst
// 设计约束：
//   - 六维度 Cost Model，各 Pass 按需读取（§10.3）
//   - 新 CPU 配置通过新增 .cost.json 文件支持，无需修改 IR 架构
//   - Cost 必须确定性（相同配置相同查询结果）
//
// 参考文档：analysis/IR核心设计.md §10.3（多维度 Cost Model，六维度 + JSON 配置示例）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 3 填充
