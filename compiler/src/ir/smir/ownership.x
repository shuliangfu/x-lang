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

// ownership.x — ownership graph (Linear move/borrow edges)
//
// Module: ir/smir
// Layer: SMIR
// Phase: Phase 2
// Responsibility:
//   - Build explicit ownership graph for Linear(T) move / borrow
//   - Validate Linear move and borrow lifetimes
//   - Track linear_valid / linear_consumed for contract preconditions
// Depends: ../inst / ../contract / ../effect
// Design constraints:
//   - Linear(T) move is non-copyable at IR (memory-safety base)
//   - Ownership transfer encoded in Contract.ownership (Move / Borrow / None)
//
// Ref: analysis IR core design §1.2 (Contract.ownership) / §2.1 (SMIR ownership graph)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
