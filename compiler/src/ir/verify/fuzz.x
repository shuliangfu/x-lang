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

// fuzz.x — Differential Fuzzing
//
// 模块：ir/verify
// 层级：共享
// Phase：Phase 1+（SHIR 落地后开始 fuzz）
// 职责：
//   - Differential Fuzzing：随机生成 .x 程序，对比三 oracle 执行结果
//   - 覆盖所有 IR 指令（22 条 opcode）+ 边界情况
//   - 契约违反检测（fuzz 时契约不一致 = 编译器 bug）
//   - 与差分测试框架协同（./diff_test.x）
// 依赖：./diff_test / ./interp
// 设计约束：
//   - Fuzz 发现的契约违反 = 编译器 bug，必须修复根源（禁止补丁）
//   - Fuzz 覆盖率纳入 Phase Gate 指标
//   - 确定性复现：fuzz 用例必须可复现（记录随机种子）
//
// 参考文档：analysis/IR核心设计.md §9（验证策略：Differential Fuzzing + Oracle）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
