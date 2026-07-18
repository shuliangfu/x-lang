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

// mod.x — IR module entry (re-export)
//
// Module: ir
// Layer: shared (across the five-layer IR architecture)
// Phase: Phase 0+
// Responsibility:
//   Aggregate public exports from ir/ submodules for pipeline/codegen;
//   declare the top-level Module structure.
// Depends: contract / effect / inst / opcode / abi / verify;
//          shir / smir / slir / vmir / mir / pass / target / verify / c_emit
// Design constraints:
//   - Module owns the three global pools: contract_pool / effect_pool / cost_model (§2.4)
//   - IRInst stores only 4-byte contract_id / effect_id; does not inline Contract / Effect
//   - Architecture Freeze: top-level architecture is fixed; only implementation-level changes
//
// Ref: analysis IR core design §2.4 (core data structures) / §1.2 (Contract Pool) / §1.7 (Effect Pool)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill from Phase 0 onward
