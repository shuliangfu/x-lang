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

// mod.x — SHIR layer module entry (re-export)
//
// Module: ir/shir
// Layer: SHIR (Xlang High IR; closest to language semantics)
// Phase: Phase 1
// Responsibility: Aggregate shir/ submodule exports (lower / interp / verify).
// Depends: ../inst / ../contract / ../effect / ../opcode / ../abi
// Design constraints:
//   - SHIR is a 1:1 map of language semantics, not a pre-pass for low-level IR (§1.8)
//   - Preserve high-level structure (Linear / Region / X ABI / Pattern Match / Coroutine / Generator)
//   - Deferred lowering: lower to SMIR only when high-level form blocks further opts
//
// Ref: analysis IR core design §1.8 (SHIR high-level principle) / §2.1 (SHIR layer)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
