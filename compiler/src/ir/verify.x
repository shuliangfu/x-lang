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

// verify.x — 契约验证机制（三步检查）
//
// 模块：ir
// 层级：共享（lowering 阶段调用，SMIR / SLIR / VMIR 逐层复用）
// Phase：Phase 1（SHIR → SMIR lowering 首次触发）
// 职责：
//   - Step 1 契约提取：从 .x 类型系统提取 Linear / Region / ABI 信息 → 生成 Contract
//   - Step 2 前置条件检查：每条指令执行前验证 pre-condition 可满足
//     · region_alive → 检查 region 未被 arena_reset
//     · linear_valid → 检查句柄未被 linear_move / consume
//     · ptr_aligned → 检查指针对齐边界
//   - Step 3 后置条件传播：执行后更新 IR 状态（标记 consumed / 更新 alias set）
// 依赖：contract / effect / inst
// 设计约束：
//   - lowering 时契约不一致 = 编译器 bug（前端 typeck 与 IR 契约矛盾），直接 panic
//   - 不生成错误代码（fail-fast，绝不静默退化）
//   - 优化器等价验证判据：pre 包含 / post 包含 / effects 不变（§1.4）
//
// 参考文档：analysis/IR核心设计.md §1.3（契约验证机制）/ §1.4（优化器工作模型）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
