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

// machine_inst.x — MachineInst / McOperand 数据结构
//
// 模块：ir/vmir
// 层级：VMIR
// Phase：Phase 5
// 职责：
//   - 定义 MachineInst（mc_opcode / operands / defs / uses / deps / contract_id / cost）
//   - 定义 McOperand 枚举（VReg / Imm / Mem / Label）
//   - 定义 McOpcode（目标机器操作码，如 x86 LEA/ADD/FMA）
//   - 定义 VReg（虚拟寄存器，寄存器分配前）
// 依赖：../inst / ../contract
// 设计约束：
//   - MachineInst 是 VMIR / Target MIR 共用的机器指令表示
//   - contract_id 物化自 IRInst.contract_id（契约从高层传递到机器层）
//   - cost 来自 Cost Model（§10.3），供调度决策
//   - defs / uses 用于后续寄存器分配
//
// 参考文档：analysis/IR核心设计.md §2.4（MachineInst / McOperand 数据结构）
// 架构状态：v4.0 Architecture Freeze — 实现骨架，待 Phase 5 填充
