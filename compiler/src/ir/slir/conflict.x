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

// conflict.x — rewrite-rule conflict resolution
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 3
// Responsibility:
//   - Five conflict classes (§4.7): multi-match / inverse / oscillation /
//     contract contradiction / same-priority tie
// Depends: ./egraph / ./rules / ../contract
// Design constraints:
//   - Deterministic resolution; contract-contradicting rules always rejected
//
// Ref: analysis IR core design §4.7 (rule conflict resolution)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
