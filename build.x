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

// =============================================================================
// build.x — product / bootstrap strategy map (11.1.5 · wave734)
// =============================================================================
//
// Role (G.7 single authority for *policy*; execution still multi-layer):
//   - This file is the **strategy facade** consumed by the legacy build_tool
//     step table (build_get_step_count / build_get_step_at / build_use_asm_only).
//   - Product orchestration authority today is **`./xbuild` → xlang-build.sh**
//     plus **compiler/scripts/g05_*.sh** (not Makefile recipes for daily path).
//   - Cold-start / residual leaf .o graphs remain **compiler/Makefile** until
//     11.3 physical delete; outer entry is always `./xbuild` (no raw make -C).
//
// PLATFORM: SHARED — same entry names on macOS and Ubuntu; ABI details live
// in g05_relink_env.sh / seed pins / leaf recipes.
//
// -----------------------------------------------------------------------------
// A. Product daily path (zero make for link; preferred)
// -----------------------------------------------------------------------------
//   ./xbuild all | build | xlang
//       → build_tool → g05_build_xlang_asm → g05_prepare_and_relink
//   ./xbuild ensure              → g05_ensure_relink_prereqs.sh
//   ./xbuild link-env            → g05_relink_env.sh
//   ./xbuild link-product        → g05_prepare_and_relink (G05_SYNC_ASM=0)
//   ./xbuild link-product-asm    → g05_prepare_and_relink (G05_SYNC_ASM=1)
//   ./xbuild migrate             → migrate_x_objs.sh (parser/typeck/codegen _x.o)
//   ./xbuild refresh-gate        → refresh_xlang_asm_gate.sh
//       (migrate_x_objs.sh + g05 relink + overlay xlang_asm)
//   ./xbuild clean               → scripts/clean_compiler.sh
//
// -----------------------------------------------------------------------------
// B. Cold start / CI (outer 0× make -C; graph still Makefile → shell)
// -----------------------------------------------------------------------------
//   ./xbuild bootstrap-driver-seed     → make leaf → bootstrap_driver_seed.sh
//   ./xbuild bootstrap-driver-bstrict  → bootstrap_driver_bstrict.sh
//       (build_xlang_asm intermediate + refresh_xlang_asm_gate.sh)
//   ./xbuild compiler-all | ci-all     → host-cc/seed `make all` via hub
//   ./xbuild compiler-make <args…>     → tests/lib/compiler-make.sh (G.7 hub)
//
// -----------------------------------------------------------------------------
// C. Bootstrap step table (stable ABI for C build_runtime — DO NOT reorder)
// -----------------------------------------------------------------------------
// build_tool / C build_runtime still consult the three functions below.
// Step ids (historical; keep numeric ABI stable during self-host):
//   0 = prepare / prereqs
//   6 = migrate companions (parser/typeck/codegen _x.o path)
//   1..5 = staged frontend / pipeline / link slices (see SELFHOST.md)
// Count = 7. build_use_asm_only() = 1 (product default -backend asm).
// Wave734 fills this *map* only; function bodies stay pin-compatible (11.1.5
// doc slice). Full DAG-as-data (11.1.1–4) lands after g05 swallow completes.
//
// -----------------------------------------------------------------------------
// D. Residual make leaves (until 11.3)
// -----------------------------------------------------------------------------
//   *_gen.c (parser/typeck/codegen) — -E-extern production still Makefile
//   migrate-x-objs / *_x.o compile — shell migrate_x_objs.sh (wave735)
//   bootstrap-driver-seed   — prereq DAG (body already shell)
//   std / residual .o leaves via ./xbuild compiler-make
//
// References:
//   analysis/C迁移追踪.md §11.1 · analysis/Makefile迁移表.md class I
//   compiler/docs/SELFHOST.md · compiler/scripts/g05_*.sh
// =============================================================================

/**
 * Product default: prefer asm backend (BC endgame).
 * Called by build_tool / C build_runtime.
 * @return 1 = asm-only product path; 0 would re-enable hybrid C emit paths
 */
function build_use_asm_only(): i32 {
  return 1;
}

/**
 * Map logical step index → historical step id for C build_runtime.
 * Order is load-bearing for bootstrap; do not reorder without dual-end L4.
 * @param i i32 zero-based step index in [0, build_get_step_count())
 * @return i32 step id, or -1 if out of range
 */
function build_get_step_at(i: i32): i32 {
  if (i == 0) { return 0; }
  if (i == 1) { return 6; }
  if (i == 2) { return 1; }
  if (i == 3) { return 2; }
  if (i == 4) { return 3; }
  if (i == 5) { return 4; }
  if (i == 6) { return 5; }
  return -1;
}

/**
 * Number of bootstrap strategy steps (stable ABI for C build_runtime).
 * @return i32 always 7 until 11.1.1–4 replace the step table with a DAG
 */
function build_get_step_count(): i32 {
  return 7;
}
