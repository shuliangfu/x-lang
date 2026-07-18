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

// verify.x — SLIR-layer verifier (including immutability checks)
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 3
// Responsibility:
//   - Post-saturation contract equivalence; immutability check (§4.9)
//   - Extraction semantic consistency; capped-node warnings
// Depends: ./egraph / ./extract / ../contract / ../effect / ../verify
// Design constraints:
//   - Immutability violation = compiler bug; fail-fast
//
// Ref: analysis IR core design §1.4 / §4.9 (SLIR immutable principle)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
