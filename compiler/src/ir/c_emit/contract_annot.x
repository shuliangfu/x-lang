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

// contract_annot.x — Contract annotation emitter for C output
//
// Module: ir/c_emit
// Layer: Phase 0 only
// Phase: Phase 0
// Responsibility:
//   - Extract Contract from .x AST / typeck (Linear / Region / X ABI semantics)
//   - Emit Contract annotations as C comments
//   - Insert annotations before corresponding functions / statements in C backend output
//   - Validate contract extraction logic (must match later IR-layer contracts)
// Depends: ../../ast / ../../typeck / ../contract
// Design constraints:
//   - Phase 0 validates contract extraction only; does not affect C runtime behavior
//   - Comment format is machine-parseable for differential testing
//   - Extraction is 100% deterministic
//
// Ref: analysis IR core design §11.3 (Phase 0 checklist: .x → .c emits Contract comments)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 0
