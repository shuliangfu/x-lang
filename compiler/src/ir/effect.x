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

// effect.x — Effect enum + EffectPool (independent subsystem)
//
// Module: ir
// Layer: shared (consumed by Scheduler / Alias Analysis / LICM / DCE / Inline, etc.)
// Phase: Phase 2+ (SMIR needs Pure / ReadOnly / Write distinctions)
// Responsibility:
//   - Define Effect enum (Pure / ReadOnly / Write / Call / Atomic / Fence)
//   - Implement EffectPool: Arena storage + HashMap dedup
//   - Provide effect_id indirection
// Depends: abi (ABIKind used by Call{kind})
// Design constraints:
//   - Effect is independent of Contract: Scheduler queries Effect only, not Ownership (§1.7)
//   - Same pooled dedup: 10k Pure insts share EffectId(0)
//   - Effect invariant: Effect set is unchanged across transforms
//
// Ref: analysis IR core design §1.7 (Effect as independent subsystem)
// Status: v4.0 Architecture Freeze — implementation skeleton; fill in Phase 2
