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

// alias.x — region-aware alias analysis
//
// Module: ir/smir
// Layer: SMIR
// Phase: Phase 2
// Responsibility:
//   - Region-based alias analysis (pointers in different regions do not alias)
//   - Maintain alias sets; provide constraints for SLIR e-graph and Scheduler
// Depends: ../inst / ../contract / ../effect
// Design constraints:
//   - Region is Arena grain; more precise than classic pointer AA
//   - Alias Analysis cares about Effect (region R/W) only, not Ownership (§1.7)
//
// Ref: analysis IR core design §1.7 / §2.1 / §4.6 (region alias boundary)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
