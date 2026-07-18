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

// verify.x — SHIR-layer independent verifier
//
// Module: ir/shir
// Layer: SHIR
// Phase: Phase 1
// Responsibility:
//   - SHIR contract consistency checks after lowering
//   - High-level structure integrity; type consistency after monomorphization
//   - debug_loc source-location completeness
// Depends: ../inst / ../contract / ../effect / ../verify
// Design constraints:
//   - Verification failure = compiler bug; panic
//   - Coordinates with ../verify.x for general contract checks
//
// Ref: analysis IR core design §1.3 (contract verification) / §2.2 (SHIR duties)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
