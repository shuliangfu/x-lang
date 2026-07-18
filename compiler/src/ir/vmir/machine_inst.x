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

// machine_inst.x — MachineInst / McOperand data structures
//
// Module: ir/vmir
// Layer: VMIR
// Phase: Phase 5
// Responsibility:
//   - Define MachineInst (mc_opcode / operands / defs / uses / deps / contract_id / cost)
//   - Define McOperand enum (VReg / Imm / Mem / Label)
//   - Define McOpcode and VReg (virtual register, pre-regalloc)
// Depends: ../inst / ../contract
// Design constraints:
//   - MachineInst is shared by VMIR and Target MIR
//   - contract_id is materialized from IRInst.contract_id
//   - cost comes from Cost Model (§10.3); defs/uses feed regalloc
//
// Ref: analysis IR core design §2.4 (MachineInst / McOperand data structures)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 5
