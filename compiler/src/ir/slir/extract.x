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

// extract.x — e-graph extraction strategy
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 3
// Responsibility:
//   - Extract lowest-cost expression from a saturated e-graph (DP bottom-up)
//   - Handle capped case (§4.8); feed SLIR → VMIR lowering
// Depends: ./egraph / ./cost
// Design constraints:
//   - Extraction is deterministic; preserves contract equivalence
//
// Ref: analysis IR core design §4.4 (extraction strategy) / §4.8 (capped handling)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
