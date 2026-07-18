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

// verify.x — contract verification mechanism (three-step check)
//
// Module: ir
// Layer: shared (called during lowering; reused by SMIR / SLIR / VMIR)
// Phase: Phase 1 (first triggered on SHIR → SMIR lowering)
// Responsibility:
//   - Step 1 contract extract: Linear / Region / ABI from .x type system → Contract
//   - Step 2 precondition check: before each inst, verify pre is satisfiable
//   - Step 3 postcondition propagation: after exec, update IR state
// Depends: contract / effect / inst
// Design constraints:
//   - Contract mismatch at lowering = compiler bug; panic
//   - Never emit error code (fail-fast; no silent degradation)
//   - Optimizer equivalence: pre subset / post superset / effects unchanged (§1.4)
//
// Ref: analysis IR core design §1.3 (contract verification) / §1.4 (optimizer model)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
