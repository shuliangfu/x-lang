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

// regalloc.x — region-based coloring register allocation
//
// Module: ir/mir
// Layer: Target MIR
// Phase: Phase 6
// Responsibility:
//   - Region-based coloring algorithm (uses region live-range info)
//   - Interference graph construction (overlapping VReg live ranges → interfere)
//   - Graph coloring to assign physical registers
//   - Coloring failure triggers spilling (delegated to spill.x)
// Depends: ../vmir/machine_inst / ../target
// Design constraints:
//   - Region live ranges improve allocation precision (Arena grain)
//   - Allocation must preserve semantics (VReg → PReg does not change behavior)
//   - Determinism: same interference graph → same assignment
//
// Ref: analysis IR core design §5.3 (region-based coloring register allocation)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 6
