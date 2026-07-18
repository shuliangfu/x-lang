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

// mod.x — Phase 0 Contract-Annotated C-Emitter module entry
//
// Module: ir/c_emit
// Layer: Phase 0 only (extends the existing C backend)
// Phase: Phase 0
// Responsibility:
//   - Phase 0 Contract-Annotated C-Emitter entry
//   - Extend existing codegen/codegen.x to emit C with Contract comments
//   - Early-test contract extraction before full IR lands
//   - Aggregate c_emit/ submodule exports (contract_annot)
// Depends: ../../codegen / ../contract
// Design constraints:
//   - Phase 0 is roadmap step 1 (§11): modify .x → .c generator to emit Contract comments
//   - Must not break existing C backend behavior (incremental extension)
//
// Ref: analysis IR core design §11 (roadmap Phase 0) / §11.3 (Phase 0 checklist)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 0
