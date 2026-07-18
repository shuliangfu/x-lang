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

// soa.x — SoA/AoS layout conversion
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 3-4
// Responsibility:
//   - Access-pattern analysis; benefit estimate; AoS → SoA transform; contract check
//   - Four-step workflow (§5.2)
// Depends: ./egraph / ./rules / ../contract / ../effect
// Design constraints:
//   - Transform keeps contract equivalence; validated by differential testing
//
// Ref: analysis IR core design §5.2 (SoA/AoS layout conversion)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
