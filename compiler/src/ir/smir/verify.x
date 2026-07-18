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

// verify.x — SMIR-layer verifier
//
// Module: ir/smir
// Layer: SMIR
// Phase: Phase 2
// Responsibility:
//   - SSA integrity; ownership graph consistency
//   - Contract pre/post checks (§1.3 Steps 2–3); region liveness
// Depends: ../inst / ../contract / ../effect / ../verify / ./ssa / ./ownership / ./alias
// Design constraints:
//   - Verification failure = compiler bug; panic; fail-fast
//   - Main arena of contract verification (SMIR layer, §2.2)
//
// Ref: analysis IR core design §1.3 (three-step contract verify) / §2.2 (SMIR duties)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
