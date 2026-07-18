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

// mod.x — Pass Pipeline module entry (re-export)
//
// Module: ir/pass
// Layer: shared (schedules passes across five IR layers)
// Phase: Phase 3+
// Responsibility: Aggregate pass/ submodule exports (pipeline / registry).
// Depends: ../shir / ../smir / ../slir / ../vmir / ../mir
// Design constraints:
//   - Declarative Pass Pipeline system (§6.1)
//   - Allows dynamic injection of AI-generated optimization passes (External Pass Provider)
//   - Pipeline order is decided by Benchmark (implementation-level; not a design freeze)
//
// Ref: analysis IR core design §6 (optimization pipeline & Pass system)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
