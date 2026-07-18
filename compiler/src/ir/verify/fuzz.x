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

// fuzz.x — Differential Fuzzing
//
// Module: ir/verify
// Layer: shared
// Phase: Phase 1+
// Responsibility:
//   - Randomly generate .x programs; compare three oracles
//   - Cover all 22 opcodes + edge cases; record RNG seeds for repro
// Depends: ./diff_test / ./interp
// Design constraints:
//   - Fuzz-found contract violations = compiler bugs; fix at root
//
// Ref: analysis IR core design §9 (verification: Differential Fuzzing + Oracle)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
