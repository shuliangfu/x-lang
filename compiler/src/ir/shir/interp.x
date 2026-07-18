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

// interp.x — SHIR interpreter (semantic verification oracle)
//
// Module: ir/shir
// Layer: SHIR
// Phase: Phase 1
// Responsibility:
//   - Interpret SHIR high-level nodes directly as a semantic oracle
//   - Compare results with C backend / IR backend (differential oracle, §9.2)
//   - Early semantic checks before codegen lands
// Depends: ../inst / ../contract / ../effect / ../opcode
// Design constraints:
//   - Interpreter is for semantic validation only
//   - Results must match all later IR backends exactly
//   - Contract violation during interpret must panic (fail-fast)
//
// Ref: analysis IR core design §9.1 (unified interpreter) / §9.2 (differential testing)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 1
