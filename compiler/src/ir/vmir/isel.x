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

// isel.x — pattern-matching instruction selection
//
// Module: ir/vmir
// Layer: VMIR
// Phase: Phase 5
// Responsibility:
//   - SLIR → VMIR lowering: select target machine instructions
//   - Pattern-match rules (a+b → LEA/ADD/FMA decisions)
//   - Target-specific selection (x86_64 / arm64 / riscv64)
// Depends: ../slir / ./machine_inst / ../target
// Design constraints:
//   - Phase 5 VMIR Gate: isel correctness 100%; fibonacci executable (§11.3)
//   - Selection must preserve contract equivalence
//   - Selection decisions use Cost Model
//
// Ref: analysis IR core design §2.1 (VMIR isel) / §2.2 (VMIR duties) / §11.3 (Phase 5 gate)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 5
