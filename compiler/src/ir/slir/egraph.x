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

// egraph.x — e-graph data structure (Arena-native)
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 3
// Responsibility:
//   - Arena-native EGraph (nodes / e-class / union-find)
//   - e-class merge; node cap 10k with capped warning (§4.8)
// Depends: ../inst / ../contract
// Design constraints:
//   - Arena-native O(1) bulk reclaim
//   - Function is primary chunk unit; region is alias boundary (§4.6)
//   - Not one e-graph per Region (too fine explodes)
//
// Ref: analysis IR core design §4.6 (layered saturation) / §4.8 (e-graph memory mgmt)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
