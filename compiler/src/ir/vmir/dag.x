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

// dag.x — DAG dependency graph construction
//
// Module: ir/vmir
// Layer: VMIR
// Phase: Phase 5
// Responsibility:
//   - Build a DAG from a MachineInst sequence
//   - Nodes = MachineInst; edges = data deps / control deps
//   - Consumed by sched.x for instruction scheduling
// Depends: ./machine_inst / ../effect
// Design constraints:
//   - DAG must be acyclic (cycle = compiler bug)
//   - Dep edges based on Effect (disjoint Write{regions} may run in parallel)
//   - DAG construction must be deterministic
//
// Ref: analysis IR core design §2.1 (VMIR DAG build) / §1.7 (Effect scheduling constraints)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 5
