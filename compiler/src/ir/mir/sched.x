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

// sched.x — final instruction scheduling
//
// Module: ir/mir
// Layer: Target MIR
// Phase: Phase 6
// Responsibility:
//   - Final instruction scheduling after register allocation
//   - Microarch-aware: execution ports / pipeline latency / cache behavior
//   - Coordinates with VMIR early scheduling (VMIR coarse; Target MIR fine)
// Depends: ../vmir/dag / ../vmir/machine_inst / ./regalloc / ./microarch
// Design constraints:
//   - Scheduling must preserve dependency invariants (do not break DAG edges)
//   - Decisions use Cost Model pipeline + cache dimensions (§10.3)
//   - Determinism: same input → same schedule
//
// Ref: analysis IR core design §2.1 (Target MIR final schedule) / §10.3 (pipeline/cache cost)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 6
