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

// contract.x — Contract struct + ContractPool (pooled dedup)
//
// Module: ir
// Layer: shared (consumed by all five IR layers)
// Phase: Phase 0 (C-Emitter extracts contract annotations) → Phase 1+ (SHIR lowering auto-gen)
// Responsibility:
//   - Define Contract struct (pre / post / effect_id / ownership)
//   - Implement ContractPool: Arena-compact storage + HashMap dedup index
//   - Provide contract_id indirection (IRInst holds only a 4-byte id)
// Depends: effect (references EffectId)
// Design constraints:
//   - Pooled dedup: 10k loads share ContractId(7); IR size drops from ~200B/inst to ~32B/inst
//   - Passes compare contracts by contract_id integer equality, not deep struct compare
//   - Contract invariants: after transform pre subset / post superset / effects unchanged (§1.4)
//
// Ref: analysis IR core design §1.2 (Contract Pool + Metadata ID) / §1.3 (contract verification)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 0
