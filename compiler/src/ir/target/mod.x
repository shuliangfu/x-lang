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

// mod.x — hardware adaptation layer module entry (re-export)
//
// Module: ir/target
// Layer: shared (consumed by VMIR isel / Target MIR regalloc/sched/microarch)
// Phase: Phase 5+
// Responsibility: Aggregate target/ exports (cost_model / x86_64 / arm64).
// Depends: ../vmir/machine_inst
// Design constraints:
//   - Cost Model is external .cost.json; new CPUs need no IR code changes (§10.3)
//
// Ref: analysis IR core design §10 (hardware adaptation layer) / §10.3
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 5
