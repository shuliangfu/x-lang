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

// registry.x — Pass registry + External Pass Provider injection interface
//
// Module: ir/pass
// Layer: shared
// Phase: Phase 3+
// Responsibility:
//   - Pass registry (Pass ID / name / deps / opt level)
//   - External Pass Provider injection interface (§6.2)
//   - Pass metadata queries (used by pipeline.x for ordering)
// Depends: ../verify/perf_oracle
// Design constraints:
//   - External Pass Provider is a generic term; not bound to a specific AI project
//   - Injected passes that do not improve performance are auto-rejected (Performance Oracle)
//   - Registration is deterministic (same registration order → same IDs)
//
// Ref: analysis IR core design §6.2 (Pass registry + External Pass Provider) / §9.3 (Oracle gate)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 3
