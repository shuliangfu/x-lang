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

// inst.x — IRInst / Operand / ABIKind / SSAReg 数据结构
//
// 模块：ir
// 层级：共享（SHIR / SMIR / SLIR 三层共用 IRInst；VMIR / Target MIR 用 MachineInst）
// Phase：Phase 1（SHIR 首次生成 IRInst）
// 职责：
//   - 定义 IRInst（opcode / operands / contract_id / effect_id / debug_loc）
//   - 定义 Operand 枚举（Reg / Imm / Ptr / Func）
//   - 定义 ABIKind（XABI(InlinePolicy) / CABI）
//   - 定义 SSAReg（id / ty / def_inst）
// 依赖：opcode / contract / effect / abi
// 设计约束：
//   - IRInst 通过 contract_id / effect_id 间接引用 Pool，不内联 Contract / Effect
//   - Pool 化设计：IR 体积 ~32B/指令（vs 内联 ~200B/指令）
//   - debug_loc 保留源码位置（.x 行号），供调试与 panic 报告
//
// 参考文档：analysis/IR核心设计.md §2.4（核心数据结构）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 1 填充
