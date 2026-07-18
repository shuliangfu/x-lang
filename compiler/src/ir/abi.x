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

// abi.x — X ABI / C ABI calling conventions
//
// Module: ir
// Layer: shared (SMIR inlining / VMIR isel / Target MIR codegen all need ABI info)
// Phase: Phase 2 (SMIR X ABI cross-module inline) + Phase 5 (VMIR c_abi_call never inlined)
// Responsibility:
//   - Define ABIKind (XABI(InlinePolicy) / CABI)
//   - Define InlinePolicy (Always / Never + heat threshold)
//   - Query X ABI semantic contracts (restricted param types / 8-byte align no padding /
//     pure-by-default / no exception propagation)
//   - Mark C ABI FFI boundary (never inlined; Target MIR codegens directly)
// Depends: inst (reuses ABIKind)
// Design constraints:
//   - X ABI is the sole SHUX calling convention; safe (extern function, no unsafe)
//   - C ABI requires unsafe (extern "C"; C libraries / syscalls)
//   - X ABI param types are restricted: i32 / enum / struct / slice / Arena ptr;
//     forbid *void / raw function pointers
//   - Cross-ABI inlining is allowed under LTO / WPO
//
// Ref: analysis IR core design §8 (calling convention & ABI) / analysis X-ABI design
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
