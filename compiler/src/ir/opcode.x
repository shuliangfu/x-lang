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

// opcode.x — Opcode enum (22 core instructions)
//
// Module: ir
// Layer: shared (used by all five IR layers)
// Phase: Phase 1 (first SHIR IRInst emission uses opcodes)
// Responsibility:
//   - Define Opcode enum covering four instruction classes:
//     · Core contract ops (region_alloc / arena_alloc / arena_reset / linear_move /
//       noalias_load / x_abi_call / pure_call)
//     · Optimization hint ops (loop_unroll_hint / branch_predict / prefetch)
//     · SIMD ops (vector_load / vector_op / vector_store; VLA supported)
//     · Atomic ops (atomic_load / atomic_store / atomic_cas / memory_fence with MemoryOrder)
// Depends: none
// Design constraints:
//   - 22 instructions are the v4.0 frozen core set; new opcodes need Benchmark proof
//   - Per-opcode Contracts live in contract.x; opcode itself only names the operation
//   - SIMD ops support a vl parameter (variable-length vectorization)
//
// Ref: analysis IR core design §3.1 (instruction set overview, 22 ops)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
