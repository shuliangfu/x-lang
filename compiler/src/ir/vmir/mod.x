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

// mod.x — VMIR layer module entry (re-export)
//
// Module: ir/vmir
// Layer: VMIR (Value MIR / Instruction Selection IR)
// Phase: Phase 5
// Responsibility: Aggregate vmir/ submodule exports (isel / dag / sched / machine_inst).
// Depends: ../slir / ../inst / ../contract
// Design constraints:
//   - v4.0 new layer: splits former Target MIR dual duty (isel + regalloc)
//   - VMIR owns instruction selection (isel); Target MIR owns regalloc + microarch
//   - Contract materialization: Contract → machine-instruction attributes
//
// Ref: analysis IR core design §2.1 (VMIR layer) / §2.2 (VMIR duties)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 5
