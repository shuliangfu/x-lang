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

// spill.x — heat-aware spilling
//
// Module: ir/mir
// Layer: Target MIR
// Phase: Phase 6
// Responsibility:
//   - When register allocation fails, choose variables to spill to the stack
//   - Heat-aware: spill cold variables first (profile- or static-analysis driven)
//   - Insert load/store instructions (stack ↔ register)
//   - Retry register allocation after spilling
// Depends: ./regalloc / ../vmir/machine_inst
// Design constraints:
//   - Heat info comes from PGO or static analysis
//   - Spill decision based on Cost Model (spill cost < register reuse cost)
//   - Determinism: same heat info → same spill decisions
//
// Ref: analysis IR core design §5.3 (heat-aware spilling strategy)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 6
