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

// x86_64.x — x86_64 target description
//
// Module: ir/target
// Layer: shared
// Phase: Phase 5
// Responsibility:
//   - x86_64 arch description (registers / ISA / addressing)
//   - Instruction selection rules; regalloc constraints; microarch features
// Depends: ../vmir/machine_inst
// Design constraints:
//   - Coordinates with cost_model.x; calling convention follows X ABI / C ABI (§8)
//
// Ref: analysis IR core design §10 / §8
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 5
