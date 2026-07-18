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

// inline.x — X ABI cross-module inlining + contract snapshot
//
// Module: ir/smir
// Layer: SMIR
// Phase: Phase 2
// Responsibility:
//   - X ABI cross-module inline decisions (InlinePolicy + heat threshold)
//   - Contract snapshot strategy (§1.6): check pre, inject post, no recursive expand
//   - Inherit callee Effect; continue Linear move edges across inline boundary
// Depends: ../inst / ../contract / ../effect / ../abi
// Design constraints:
//   - Contract propagation complexity O(1)
//   - C ABI is never inlined (FFI boundary)
//
// Ref: analysis IR core design §1.6 (contract snapshot) / §1.7 / §8 (X ABI inline)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
