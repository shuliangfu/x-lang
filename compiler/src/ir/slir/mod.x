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

// mod.x — SLIR layer module entry (re-export)
//
// Module: ir/slir
// Layer: SLIR (Xlang Low IR; machine-independent extreme opts; immutable graph)
// Phase: Phase 3-4
// Responsibility: Aggregate slir/ exports
//   (egraph / rules / cost / extract / saturate / conflict / superopt / soa / verify).
// Depends: ../smir / ../inst / ../contract / ../effect
// Design constraints:
//   - SLIR is immutable: pass API is functional (§4.9)
//   - e-graph rewrite engine is the core of SLIR
//   - Contract preservation across transforms (§1.4)
//
// Ref: analysis IR core design §2.1 (SLIR layer) / §4.9 (SLIR immutable principle)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
