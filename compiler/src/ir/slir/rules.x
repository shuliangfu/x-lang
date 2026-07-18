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

// rules.x — e-graph rewrite rule definitions
//
// Module: ir/slir
// Layer: SLIR
// Phase: Phase 3
// Responsibility:
//   - Four rewrite rule sets (§4.2): algebra_simplify / strength_reduction /
//     linear_optim / alias_optim
//   - Rule priority (§4.6): algebra > contract optim > search optim
// Depends: ../inst / ../contract / ./egraph
// Design constraints:
//   - Each rule must preserve contract equivalence
//   - External Pass Provider may inject AI-generated rules (§6.2)
//
// Ref: analysis IR core design §4.2 (rewrite rules) / §4.6 (layered saturation)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
