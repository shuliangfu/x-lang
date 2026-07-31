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
//   - Cold-start / residual leaf .o graphs use shell catalog + compiler-make hub (Makefile deleted wave942); was
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
//   ./xbuild migrate-gen         → ensure_migrate_gen.sh (parser/typeck/codegen)
//   ./xbuild lexer-gen           → ensure_migrate_gen.sh lexer (wave737)
//   ./xbuild driver-gen          → ensure_driver_gen.sh (driver+preprocess · wave738)
//   ./xbuild preprocess-gen      → ensure_driver_gen.sh preprocess
//   ./xbuild lsp-gen             → ensure_lsp_pipeline_gen.sh (lsp trio · wave739)
//   ./xbuild pipeline-gen        → ensure_lsp_pipeline_gen.sh pipeline
//   ./xbuild lsp-pipeline-gen    → ensure_lsp_pipeline_gen.sh all
//   ./xbuild archaeology-gen     → ensure_archaeology_gen.sh (Track L · wave740)
//   ./xbuild driver-subcmd-gen   → ensure_archaeology_gen.sh driver-all
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
//   *_gen.c (parser/typeck/codegen/lexer) — shell ensure_migrate_gen.sh (736/737)
//   *_gen.c (driver/preprocess) — shell ensure_driver_gen.sh (wave738)
//   *_gen.c (lsp_diag/io/lsp + pipeline) — shell ensure_lsp_pipeline_gen.sh (wave739)
//   archaeology *_gen.c (driver subcmd / lsp_io_std_heap) — ensure_archaeology_gen.sh (wave740)
//   migrate-x-objs / *_x.o compile — shell migrate_x_objs.sh (wave735)
//   bootstrap-driver-seed   — prereq DAG (body already shell)
//   std / residual .o leaves via ./xbuild compiler-make
//
// -----------------------------------------------------------------------------
// E. tests/ host-cc policy (11.5 · not product — wave734/741)
// -----------------------------------------------------------------------------
//   Authority: tests/HOST_CC_POLICY.md
//   11.5.1 bench/**/*.c     — permanent host-cc whitelist (diff baseline · wave734)
//   11.5.2 std-*/*.c        — permanent host-cc whitelist (C smoke harness · wave741)
//   11.5.3 abi|leak|safe|kernel/*.c — permanent host-cc whitelist (probes · wave741)
//   11.5.4 probes/**/*.c    — tool/generated artifacts; not product residual (wave741)
//   Never inputs to g05 / ./xbuild all / product compiler link.
//
// -----------------------------------------------------------------------------
// F. Orchestration DAG inventory + schedule (11.1.1 wave742 · 11.1.2 wave743
//     · 11.3 prereq edges wave744 · 11.1.3/4 platform+linker wave745)
// -----------------------------------------------------------------------------
//   Authority map: compiler/docs/BUILD_DAG.md
//   Machine check: compiler/scripts/product_build_dag.sh
//   ./xbuild product-dag | build-dag | cold-dag
//   ./xbuild product-dag --check
//   ./xbuild product-dag --dry-run [product|refresh|cold]
//   ./xbuild product-dag --run product|refresh|cold
//   Product schedule (11.1.2): ensure_*_gen → migrate → g05_prepare_and_relink
//     (prepare embeds ensure+link_env; archaeology off product)
//   Refresh schedule: refresh_gate alone
//   Cold schedule: dry-run starts with cold_ensure_prereqs; live → outer
//     bootstrap-driver-seed (embeds driver_seed_ensure_prereqs · wave744)
//   wave744: DRIVER_SEED_PREREQS *edge satisfaction* is shell
//     (driver_seed_ensure_prereqs.sh via catalog); Makefile bootstrap-driver-seed
//     is thin phony (no make-graph $(DRIVER_SEED_PREREQS) deps). List authority
//     remains compiler/mk/*.mk (G.7 no dual list). Leaf .o pattern rules residual
//     until 11.3 physical delete.
//   ./xbuild driver-seed-prereqs [--dry-run|--check|--run]
//   G.7: DAG lists orchestration edges/owners only; .o inventories stay in
//   compiler/mk/*.mk + driver_seed_obj_catalog.sh (no dual lists).
//
//   11.1.3 host platform (wave745):
//     Authority map: compiler/docs/PLATFORM_LINKER.md
//     Machine: compiler/scripts/host_platform_linker.sh
//     ./xbuild host-platform [--export|--check]
//     Single shell host OS/arch facts (XLANG_HOST_OS / ARCH / PLATFORM_TAG);
//     product seed pin = *.linux.x86_64.c (host-portable). Makefile UNAME for
//     leaf pattern rules residual until 11.3.1 (lists stay mk — G.7).
//
//   11.1.4 linker policy (wave745):
//     Prefer product xlang_asm_invoke_ld_platform + direct ld|lld|link.exe.
//     Named residual: bootstrap_driver_seed_link.sh SEED_LINK_CC -o (cold
//     phase1/final; list still Makefile export). Forbidden: silent default
//     $(CC) -o as linker without inventory. Pure-ld cold endgame later.
//     ./xbuild linker-policy [--check]
//
//   11.3.1 leaf pattern residual path (wave746 inventory · wave747 R4 mode ·
//   wave748–750 R1 families):
//     Authority map: compiler/docs/LEAF_PATTERN_RESIDUAL.md
//     Machine: compiler/scripts/leaf_pattern_residual.sh
//     ./xbuild leaf-patterns | leaf-residual [--check]
//     Named residual classes R1–R5 (host-cc seed/.o, UNAME stamp, thin+rest,
//     cold rebuild pattern bodies, CI all). R6 cold CC -o → 11.1.4.
//     wave747: R4 mode policy + catalog list in rebuild_leaves (default);
//     pattern bodies still make.
//     wave748: R1 pure host-cc body for RT_SEED_SLICE family
//       (ensure_host_cc_seed_o.sh; list = catalog RT_SEED_SLICE_OBJS).
//     wave749: R1 second family R1_CORE_SEED (diag/link_abi/c_import/
//       x_seed_bridge/seed_link_compat); same body; catalog R1_CORE_SEED_OBJS.
//     wave750: R1 third family R1_FRONTEND_GLUE (lexer/ast/lsp basename-
//       mismatch seed map); same body; catalog R1_FRONTEND_GLUE_OBJS.
//     wave751: R1 fourth family R1_MAIN_RUNTIME (main/runtime multi-flag
//       variants); same body; catalog R1_MAIN_RUNTIME_OBJS.
//     wave752: R1 fifth family R1_ALIAS_STUBS (link alias / bare / compat
//       stubs; pure basename); same body; catalog R1_ALIAS_STUBS_OBJS.
//     wave753: R1 sixth family R1_EXTRA_CFLAGS (pipeline_abi / -fPIE /
//       sqlite multi-flag / parser extras); same body; catalog
//       R1_EXTRA_CFLAGS_OBJS.
//     wave754: R1 seventh family R1_MISC_BASENAME (misc pure basename
//       glue/enc/ctx/pipeline_glue/asm_build/…); same body; catalog
//       R1_MISC_BASENAME_OBJS.
//     wave755: R1 eighth family R1_SEED_MAP (basename-mismatch + orch -D:
//       target_cpu_pure→target_cpu.o, runtime_ast_glue→ast_seed.o,
//       pipeline_bootstrap_orchestration extras); same body; catalog
//       R1_SEED_MAP_OBJS.
//       ./xbuild host-cc-seed | rt-seed-slice | core-seed | frontend-glue
//         | main-runtime | alias-stubs | extra-cflags | misc-basename | seed-map
//         [--check|--force]
//     wave756: R4 pure-R1 body — rebuild_leaves → ensure try-r1 for catalog
//       pure R1 members; non-R1 residual still make (bridge = no make).
//     wave757: R3 cold-else body — rebuild residual → ensure try-r3-cold
//       (catalog R3_COLD_SEED_OBJS; 9 thin+rest cold pure host-cc leaves);
//       Makefile cold-else thin-call ensure; PREFER thin still Makefile.
//       ./xbuild r3-cold-seed [--force]
//     wave758: R4 residual thin_glue → R1 seed-map (G.7 有则补全) —
//       parser_asm_thin_glue.o ← seeds/parser_asm_thin_c.from_x.c + monothin
//       -D/-I; ensure_one refreshes on seeds/parser_asm/*.inc; user-asm
//       rebuild shell-only; Makefile thin-call ensure.
//     wave759: R4 residual glue-standalone → R1 seed-map (G.7 有则补全).
//     wave760: R2 panic cold — rebuild residual → ensure try-r2
//       (catalog DRIVER_SEED_PANIC_OBJS; UNAME stamp + host source pick;
//       Makefile cold-else thin-call; PREFER thin still Makefile).
//       ./xbuild path: ensure try-r2 / r2-panic (via host-cc-seed family entry).
//       Residual: R3 PREFER thin · gen/pipeline-x · typeck_f64/crt0 · pure-ld
//       · physical delete.
//     G.7: lists stay mk; no dual .o inventory in residual shell.
//
//   Full .x import graph later; 11.3.1 endgame deletes Makefile residual leaf rules.
//
// References:
//   analysis/C迁移追踪.md §11.1 · §11.3 · §11.5 · analysis/Makefile迁移表.md class I
//   compiler/docs/SELFHOST.md · BUILD_DAG.md · PLATFORM_LINKER.md
//   compiler/docs/LEAF_PATTERN_RESIDUAL.md
//   tests/HOST_CC_POLICY.md · compiler/scripts/g05_*.sh
//   product_build_dag.sh · host_platform_linker.sh · leaf_pattern_residual.sh
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
