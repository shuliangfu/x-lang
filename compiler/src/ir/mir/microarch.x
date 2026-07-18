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

// microarch.x — microarchitecture pipeline modeling + execution-port scheduling
//
// Module: ir/mir
// Layer: Target MIR
// Phase: Phase 6
// Responsibility:
//   - Model target CPU execution ports (e.g. x86 ALU/LSB/FP ports)
//   - Pipeline latency modeling (inst latency / throughput / port occupancy)
//   - Microarch-aware instruction scheduling (avoid port conflicts / pipeline stalls)
// Depends: ../target / ../vmir/machine_inst
// Design constraints:
//   - Microarch data is loaded from target/ (x86_64.x / arm64.x)
//   - CPU microarch differences via Cost Model config (§10.3)
//   - Determinism: same microarch model → same schedule
//
// Ref: analysis IR core design §2.1 (Target MIR microarch pipeline) / §10 (hardware adapt layer)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 6
