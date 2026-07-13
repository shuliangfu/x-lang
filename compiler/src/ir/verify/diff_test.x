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

// diff_test.x — 差分测试框架
//
// 模块：ir/verify
// 层级：共享
// Phase：Phase 0+（自举前建立差分测试框架）
// 职责：
//   - 三 oracle 对比（§9.2）：
//     · Oracle 1：C 后端（现有 codegen/codegen.x）
//     · Oracle 2：IR 解释器（./interp.x）
//     · Oracle 3：IR codegen（VMIR → Target MIR → .s）
//   - 同一段代码三个 oracle 执行结果必须完全一致
//   - 自举前验证 shux 与 clang 编译同一段代码的执行结果一致性
//   - 差异报告（不一致时定位到具体 IR 指令）
// 依赖：./interp / ../../codegen
// 设计约束：
//   - 自举前建立差分测试框架（项目约束）
//   - 差异 = 编译器 bug，必须 fail-fast
//   - 差分测试覆盖所有 IR 指令（22 条 opcode）
//
// 参考文档：analysis/IR核心设计.md §9.2（差分测试框架，三 oracle 对比）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 0 填充
