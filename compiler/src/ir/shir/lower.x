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

// lower.x — .x AST → SHIR lowering + contract extraction
//
// Module: ir/shir
// Layer: SHIR
// Phase: Phase 1
// Responsibility:
//   - Convert typeck'd AST into SHIR high-level nodes
//   - Extract Linear / Region / X ABI semantics into Contract (§1.3 Step 1)
//   - Preserve Pattern Match / Coroutine / Generator high-level structure (§1.8)
//   - Generic monomorphization; early DCE at SHIR
// Depends: ../../ast / ../inst / ../contract / ../effect / ../opcode / ../abi
// Design constraints:
//   - SHIR is a 1:1 map of language semantics; no aggressive lowering
//   - Contract extraction is 100% deterministic
//
// Ref: analysis IR core design §1.3 (contract extract) / §1.8 / §2.2 (SHIR duties)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
