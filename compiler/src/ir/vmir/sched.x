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

// sched.x — early instruction scheduling
//
// Module: ir/vmir
// Layer: VMIR
// Phase: Phase 5
// Responsibility:
//   - Reorder instructions under DAG dependency constraints
//   - Early schedule (VMIR); Target MIR does final schedule later
//   - Respect Effect constraints (Write must not reorder across Pure)
// Depends: ./dag / ./machine_inst / ../effect
// Design constraints:
//   - Scheduling must preserve dependency invariants
//   - Decisions use Cost Model pipeline dimension (§10.3)
//   - Determinism: same DAG → same schedule
//
// Ref: analysis IR core design §2.1 (VMIR early schedule) / §2.2 (VMIR duties)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 5
