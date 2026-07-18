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

// cost.x — Cost function (multi-dimensional cost evaluation)
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 3
// Responsibility:
//   - e-graph node cost function from Cost Model six dimensions (§10.3)
//   - Used by extract.x when picking the optimal expression
// Depends: ../inst / ../target/cost_model / ./egraph
// Design constraints:
//   - Cost Model is external .cost.json; new CPUs need no IR code changes
//   - Cost computation is deterministic
//
// Ref: analysis IR core design §4.3 (Cost function) / §10.3 (multi-dim Cost Model)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
