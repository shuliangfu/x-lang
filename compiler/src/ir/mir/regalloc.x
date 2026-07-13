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

// regalloc.x — region-based Coloring 寄存器分配
//
// 模块：ir/mir
// 层级：Target MIR
// Phase：Phase 6
// 职责：
//   - region-based Coloring 算法（结合 region 生存期信息）
//   - 干涉图构建（VReg 生存期重叠即干涉）
//   - 图着色分配物理寄存器
//   - 着色失败触发 spilling（交给 spill.x）
// 依赖：../vmir/machine_inst / ../target
// 设计约束：
//   - region 生存期信息提升分配精度（Arena 粒度，比传统生存期分析精确）
//   - 分配必须保持语义（VReg → PReg 映射不改变程序行为）
//   - 确定性：相同干涉图相同分配结果
//
// 参考文档：analysis/IR核心设计.md §5.3（region-based Coloring 寄存器分配）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 6 填充
