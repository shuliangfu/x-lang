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

// superopt.x — Superoptimizer beam search
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 4 (superopt deferred; early ROI is low)
// Responsibility:
//   - Beam-search optimal instruction sequences on hot functions
//   - Bound search space; differential-test validation (§9.2)
// Depends: ./egraph / ./rules / ./cost / ../verify/diff_test
// Design constraints:
//   - Search space must be bounded; results must pass differential tests
//
// Ref: analysis IR core design §5.1 (Superoptimizer integration) / §11.3 (Phase 4 checklist)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 4
