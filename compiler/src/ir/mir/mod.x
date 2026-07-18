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

// mod.x — Target MIR layer module entry (re-export)
//
// Module: ir/mir
// Layer: Target MIR (Machine IR; hardware register allocation + microarch alignment)
// Phase: Phase 6
// Responsibility: Aggregate mir/ submodule exports (regalloc / spill / sched / microarch).
// Depends: ../vmir / ../inst / ../contract / ../target
// Design constraints:
//   - Target MIR owns regalloc + microarch alignment only (split from VMIR)
//   - Region-based coloring register allocation (§5.3)
//   - Heat-aware spilling (cold vars to stack)
//   - Microarch pipeline modeling + execution-port scheduling
//   - Contract materialization: Contract already lowered to machine-inst attributes
//
// Ref: analysis IR core design §2.1 (Target MIR layer) / §2.2 (Target MIR duties)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 6
