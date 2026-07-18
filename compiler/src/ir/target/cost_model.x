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

// cost_model.x — multi-dimensional Cost Model loader
//
// Module: ir/target
// Layer: shared
// Phase: Phase 3 + Phase 5
// Responsibility:
//   - Load .cost.json six dimensions (§10.3): inst_costs / register_pressure /
//     cache_hierarchy / branch_model / simd_capacity / pipeline_model
//   - Cost query API for SLIR / VMIR / Target MIR
// Depends: ../vmir/machine_inst
// Design constraints:
//   - New CPU = new .cost.json; Cost is deterministic
//
// Ref: analysis IR core design §10.3 (multi-dim Cost Model)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
