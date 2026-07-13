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

// microarch.x — 微架构流水线建模 + 执行端口调度
//
// 模块：ir/mir
// 层级：Target MIR
// Phase：Phase 6
// 职责：
//   - 建模目标 CPU 的执行端口（如 x86 的 ALU/LSB/FP 端口）
//   - 流水线延迟建模（指令延迟 / 吞吐 / 端口占用）
//   - 微架构感知指令调度（避免端口冲突 / 流水线停顿）
//   - 直接建模目标 CPU 微架构（与 Cost Model 的 pipeline 维度协同）
// 依赖：../target / ../vmir/machine_inst
// 设计约束：
//   - 微架构信息从 target/ 加载（x86_64.x / arm64.x）
//   - 不同 CPU 微架构差异通过 Cost Model 配置支持（§10.3）
//   - 确定性：相同微架构模型相同调度结果
//
// 参考文档：analysis/IR核心设计.md §2.1（Target MIR 微架构流水线建模）/ §10（硬件适配层）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 6 填充
