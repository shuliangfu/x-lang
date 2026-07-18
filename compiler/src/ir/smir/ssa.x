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

// ssa.x — SSA construction (phi nodes + def-use chains)
//
// Module: ir/smir
// Layer: SMIR
// Phase: Phase 2
// Responsibility:
//   - Build SSA form during SHIR → SMIR lowering
//   - Insert phi nodes at dominance frontiers; build def-use chains
//   - Variable renaming (each SSAReg has a unique definition)
// Depends: ../shir / ../inst
// Design constraints:
//   - SSA is a SMIR invariant: each SSAReg is defined exactly once
//   - Phi in-edge count equals predecessor basic-block count
//
// Ref: analysis IR core design §2.1 (SMIR layer) / §2.4 (SSAReg data structure)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
