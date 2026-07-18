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

// inst.x — IRInst / Operand / ABIKind / SSAReg data structures
//
// Module: ir
// Layer: shared (SHIR / SMIR / SLIR share IRInst; VMIR / Target MIR use MachineInst)
// Phase: Phase 1 (SHIR first emits IRInst)
// Responsibility:
//   - Define IRInst (opcode / operands / contract_id / effect_id / debug_loc)
//   - Define Operand enum (Reg / Imm / Ptr / Func)
//   - Define ABIKind (XABI(InlinePolicy) / CABI)
//   - Define SSAReg (id / ty / def_inst)
// Depends: opcode / contract / effect / abi
// Design constraints:
//   - IRInst references pools via contract_id / effect_id; does not inline Contract / Effect
//   - Pool design: ~32B/inst IR size (vs ~200B/inst if inlined)
//   - debug_loc keeps source location (.x line) for debug and panic reports
//
// Ref: analysis IR core design §2.4 (core data structures)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
