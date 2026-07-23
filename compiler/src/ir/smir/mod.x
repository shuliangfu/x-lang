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

// mod.x — SMIR layer module entry (re-export)
//
// Module: ir/smir
// Layer: SMIR (Xlang Mid IR; SSA + explicit ownership graph)
// Phase: Phase 2
// Responsibility: Aggregate smir/ exports (ssa / ownership / inline / alias / verify).
// Depends: ../shir / ../inst / ../contract / ../effect / ../abi
// Design constraints:
//   - SMIR turns language semantics into verifiable constraints
//   - Linear move / borrow edges are encoded explicitly
//   - Region-aware alias analysis; cross X ABI inlining (§1.6)
//
// Ref: analysis IR core design §2.1 (SMIR layer) / §2.2 (SMIR duties)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
