#!/usr/bin/env bash
# leaf_pattern_residual.sh — 11.3.1 path · leaf .o pattern residual inventory
#   wave746: named classes R1–R6
#   wave747: R4 mode-policy swallow (catalog + shell table; pattern body residual)
#   wave748: R1 first family rt-seed-slice body → ensure_host_cc_seed_o.sh
#   wave749: R1 second family core-seed (diag/link_abi/c_import/bridge/compat)
#   wave750: R1 third family frontend-glue (lexer/ast/lsp basename-mismatch map)
#   wave751: R1 fourth family main-runtime (main/runtime multi-flag variants)
#   wave752: R1 fifth family alias-stubs (link alias / bare / compat stubs)
#   wave753: R1 sixth family extra-cflags (pipeline_abi / -fPIE / sqlite / parser)
#   wave754: R1 seventh family misc-basename (glue/enc/ctx/pipeline_glue/asm_build)
#   wave755: R1 eighth family seed-map (target_cpu/ast_seed mismatch + orch -D)
#   wave756: R4 pure-R1 body via rebuild_leaves → ensure try-r1 (non-R1 residual make)
#   wave757: R3 cold-else body via rebuild_leaves → ensure try-r3-cold
#   wave758: R4 residual thin_glue pure host-cc → R1 seed-map (G.7 有则补全)
#   wave759: R4 residual glue standalone → R1 seed-map (G.7 有则补全)
#   wave760: R2 panic cold body via rebuild_leaves → ensure try-r2
#   wave762: R2 typeck_f64 + crt0 via try-r2 (catalog TYPECK_F64 + CRT0)
#   wave761: R4 residual gen *_x + pipeline_x via try-gen-x / ensure_gen_x_o.sh
#   wave777: physical-delete prep inventory (named buckets B1–B7; no body swallow)
#   wave778: Windows hard gate before Makefile delete + dual-end (mac+Ubuntu) verify policy
#   wave779: B1 runtime_* OS/glue dual hybrid body → try-runtime-os-prefer (Makefile thin-call)
#   wave780: B2 std/core product hybrid body → try-std-core-prefer (Makefile thin-call)
#   wave811: std_x product hybrid body (22 leaves) → xlang_compile_std_x auto|auto-soft|auto-soft-merge
#            (Makefile thin-call only; NOT physical delete; formal_mod graph remains)
#   wave825: std_x shell-primary catalog (22 leaves) → xlang_compile_std_x ensure
#   wave826: formal_mod FORCE dep-thin (38 leaves) → ensure owns source mtime
#   wave827: std_x FORCE dep-thin (22 leaves) → ensure owns source mtime
#            (mode|x_path table in shell; Makefile ensure only; NOT physical delete)
#   wave828: driver_leaf FORCE dep-thin (8 leaves) → ensure owns source mtime
#   wave829: product/archaeology *_gen.c FORCE dep-thin (17 leaves) → ensure pin policy
#   wave830: ast_gen2.c FORCE dep-thin (1 leaf) → ensure_ast_gen2 pin policy
#   wave831: src-edge FORCE dep-thin (7 leaves) → parser_asm try-heat + cc_inc_tu mtime
#   wave832: migrate companion FORCE dep-thin (3 leaves) → migrate_x_objs need_rebuild
#   wave833: pipeline_glue_types.inc FORCE dep-thin (1 leaf) → ensure extract mtime
#   wave834: bootstrap-pipeline FORCE shell-primary (1 leaf) → ensure_lsp_pipeline_gen pipeline
#   wave835: bootstrap_seed class-G filter FORCE dep-thin (4 leaves) → filter_* ensure mtime
#   wave836: product object-path cp-alias FORCE dep-thin (3 leaves) → ensure_cp_alias_o mtime
#   wave837: pipeline_gen.c FORCE dep-thin (1 leaf) → ensure_lsp_pipeline_gen pipeline pin policy
#   wave838: bootstrap_xlangc FORCE dep-thin (1 leaf) → select_bootstrap_xlangc host seed pick
#   wave839: archaeology host-pick FORCE dep-thin (4 leaves) → FORCE + archaeology_host_pick_phony
#   wave841: bootstrap-typeck/codegen shell-primary (2 phonies) → bootstrap_typeck_codegen.sh
#            (ensure_migrate_gen FORCE_REGEN + migrate_x_objs + BTC_* link; NOT physical delete)
#   wave842: bootstrap-x-compiler shell-primary (1 phony) → bootstrap_x_compiler.sh
#            (TARGET_x -x -E + host-cc -c typeck_x_x + BXC_LINK_OBJS; NOT physical delete)
#   wave843: bootstrap-self shell-primary (1 phony) → bootstrap_self.sh
#            (stage1 snapshot + satellite ensure + stage2 host-cc link + out_self smoke; NOT physical delete)
#   wave844: bootstrap-parser/parse-file shell-primary (2 phonies) → bootstrap_parser_smoke.sh
#   wave845: xlang-x-pipeline shell-primary (1 target) → xlang_x_pipeline.sh
#   wave846: xlang-x shell-primary (1 target) → xlang_x.sh
#            (parser.x -o smoke + dual-path parse fixtures; NOT physical delete)
#   wave847: xlang-no-c-frontend shell-primary (1 target) → xlang_no_c_frontend.sh
#            (seed gate + host-cc link archaeology no-C-frontend binary; NOT physical delete)
#   wave848: bootstrap-driver-seed-x-frontend shell-primary (1 target) → bootstrap_driver_seed_x_frontend.sh
#            (host-cc link archaeology $(TARGET)_x_frontend; NOT physical delete)
#   wave849: relink-xlang-lexer shell-primary (1 target) → relink_xlang_lexer.sh
#            (seed gate + host-cc link product TARGET + XLANG_C sync; NOT physical delete)
#   wave812: formal_mod shell-primary catalog (38 leaves) → xlang_compile_std_module ensure
#            (Makefile thin-call only; NOT physical delete; edges+lists+B2 remain)
#   wave813: B7B STD_AND_PANIC_O list authority → mk/std_and_panic_objs.mk
#            (Makefile include only; NOT physical delete; thin edges + B2 remain)
#   wave814: driver_leaf shell-primary catalog (8 leaves) → driver_leaf_x_to_o ensure
#            (Makefile thin-call only; NOT physical delete; edges+lists remain)
#   wave815: archaeology host-pick phonies (4) → archaeology_host_pick_phony ensure
#            (net-o-stub/openssl/mbedtls + sqlite-o-stub; NOT physical delete)
#            wave839 closes script-prereq residual with FORCE dep-thin
#   wave816: B7B DRIVER_SUBCMD_* list authority → mk/driver_subcmd_objs.mk
#            (Makefile include only; NOT physical delete; thin edges + other lists remain)
#   wave817: B7B PIPELINE_X_* + PIPELINE_LIBS list authority → mk/pipeline_x_objs.mk
#   wave818: B7B DRIVER_SEED mode picks (SUPPORT_EXTRA/RUNTIME_O/…) → mk/driver_seed_mode_objs.mk
#   wave819: B7B seed link picks (MAIN_LINK/LEXER_AST/LSP_DIAG/GLUE/…) → mk/driver_seed_link_picks.mk
#   wave820: B7B OBJS_CORE archaeology list → mk/objs_core.mk
#            (Makefile include only; NOT physical delete; thin edges + other lists remain)
#   wave821: B7B archaeology experiment lists → mk/archaeology_experiment_objs.mk
#            (X_FRONTEND_EXPERIMENT 7 + NO_C_FRONTEND; Makefile include only; NOT physical delete)
#   wave822: B7B RELINK_XLANG_PREREQS + LEGACY_XLANG_C_* → mk/driver_seed_composites.mk
#   wave823: B7B SRCS/MAIN_X_DEPS/PIPELINE_X_DEPS → mk/x_source_deps.mk
#            (G.7 有则补全 composites; fixed RELINK authority 14; NOT physical delete)
#   wave824: B7B MAIN/LSP/PIPELINE_X_E_DIRS → mk/x_e_dirs.mk
#            (-E module search roots; fixed dir-root authority 26; NOT physical delete)
#   wave850: B7B RELINK_PRODUCT_LINK_OBJS → mk/driver_seed_composites.mk
#            (product archaeology full link bag BTC/RXL; fixed BASE 8; NOT physical delete)
#   wave851: B7B XXL/BS/XNC full link bags → composites + archaeology_experiment
#            (xlang-x + bootstrap-self + xlang-no-c-frontend; 3 bags; NOT physical delete)
#   wave852: B7B BXF full link bag → mk/archaeology_experiment_objs.mk
#            (bootstrap-driver-seed-x-frontend; fixed multi-token 2; NOT physical delete)
#   wave853: B7B seed phase1/final full link bags → mk/driver_seed_composites.mk
#            (SEED_LINK_OBJS export; 2 bags; NOT physical delete)
#   wave854: B7B product archaeology seed-gate REQUIRED_OBJS bags → mk
#            (RXL/XXL composites + XNC archaeology_experiment; 3 bags; NOT physical delete)
#   wave855: B7B seed-gate REQUIRED bags shell-load from mk (RXL/XXL/XNC; 3)
#            (Makefile drops multi-token REQUIRED env export; NOT physical delete)
#   wave857: B7B archaeology LINK_CFLAGS shell-load via make export leaves (4 bags /
#            6 shells; drop multi-token CFLAGS env)
#   wave858: B7B LEGACY xlang-c link shell-primary (export-legacy-xlang-c-link-objs;
#            CFLAGS reuses export-relink-product-link-cflags; NOT physical delete)
#   wave859: B7B XXP/BXC multi-token bag shell-load via make export leaves
#            (export-xxp-link-bags + export-bxc-link-objs; 2 shells; drop multi-token
#            XXP_*/BXC_ env; NOT physical delete — thin edges + B2 remain)
#   wave860: B7B driver_leaf BASE_CFLAGS multi-token shell-load via make export leaf
#            (export-driver-leaf-base-cflags; 8 leaves; drop multi-token BASE_CFLAGS=
#            env; NOT physical delete — thin edges + B2 remain)
#   wave861: B7B rt_* multi-token -I CFLAGS hygiene (5 RT_SEED_SLICE leaves drop
#            CFLAGS="$(CFLAGS) -I. -Iinclude -Isrc"; product -I already in CFLAGS
#            ?= / shell BASE_CFLAGS default; NOT physical delete — thin + B2 remain)
#   wave862: B7B try-heat CFLAGS/PIPELINE_GEN_CFLAGS bulk shell-load via make
#            export-try-heat-cflags (114 heat recipes drop multi-token CFLAGS=
#            inject; shell loads when unset; NOT physical delete — thin + B2 remain)
#   wave863: B7B class-G filter CFLAGS/PIPELINE_GEN bulk shell-load hygiene
#            (4 filter FORCE recipes drop multi-token CFLAGS inject; filter scripts
#            pass CC only to try-heat so wave862 shell-load runs; NOT physical delete)
#   wave864: B7B leaf-extra RUNTIME_*/PARSER_* multi-token CFLAGS inject hygiene
#   wave865: B7B migrate/bootstrap multi-token CFLAGS shell-load via export-try-heat-cflags
#            (8 recipes: migrate 4 + BTC 2 + XXP/BXC 2; drop CFLAGS inject; shell
#            loads export leaf; NOT physical delete — thin edges + B2 remain)
#   wave866: B7B build-tool CFLAGS shell-load + WIN32_O_CFLAGS leaf drop
#            (2 recipes: build-tool + crt0_mingw; shell loads export-try-heat-cflags;
#            WIN32 empty default; NOT physical delete — thin edges + B2 remain)
#   wave867: B7B archaeology host-pick LD_R_MULTIDEF_FLAGS leaf drop (4 recipes:
#            net-o-stub/openssl/mbedtls + sqlite-o-stub; shell uname default when
#            env unset; NOT physical delete — thin edges + B2 remain)
#   wave868: B7C bootstrap-driver-bstrict-relink shell-primary (1 phony) →
#            relink_xlang_asm_bstrict_runtime_objs.sh (G.7 有则补全 dual body;
#            NOT physical delete — thin edges + B2 remain)
#   wave869: B7C bootstrap-driver-crt0 shell-primary (1 phony) →
#            bootstrap_driver_crt0.sh (build_xlang_asm + crt0 log gates;
#            NOT physical delete — thin edges + B2 remain)
#   wave870: B7C check-7.2 shell-primary (1 phony) →
#            check_7_2.sh (seed-path stage1/stage2 smoke suite;
#            NOT physical delete — thin edges + B2 remain)
#   wave871: B7C check-6.4 shell-primary (1 phony) →
#            check_6_4.sh (seed-path emit-C + host-cc + exit 42;
#            NOT physical delete — thin edges + B2 remain)
#   wave872: B7C bootstrap-driver-hybrid shell-primary (1 phony) →
#            bootstrap_driver_hybrid.sh (B-hybrid build_xlang_asm + replace/soft-skip;
#            NOT physical delete — thin edges + B2 remain)
#   wave873: B7C regen-lsp-gens-x shell-primary (1 phony) →
#            regen_lsp_gens_x.sh (XLANG_X gate + rm four gens + make file targets;
#            NOT physical delete — thin edges + B2 remain)
#   wave874: B7C build-via-tool shell-primary (1 phony) →
#            build_via_tool.sh (run host build_tool → TARGET + OK; xbuild dual retired;
#            NOT physical delete — thin edges + B2 remain)
#   wave875: B7C size/perf-baseline shell-primary (2 phonies) →
#            stage8_baseline.sh (dispatch tests/run-{size,perf}-baseline; soft-skip;
#            NOT physical delete — thin edges + B2 remain)
#   wave876: B7C default $(XLANG_C) product alias shell-primary (1 target) →
#            ensure_xlang_c.sh (SKIP_SUBSCRIPT soft-skip + cp bootstrap_xlangc;
#            NOT physical delete — thin edges + B2 remain; LEGACY stays wave858)
#   wave877: B7B gen/lsp/archaeology ensure multi-token env inject hygiene (20 recipes) →
#            drop MAKE/XLANG_*/FORCE/TIMEOUT inject; shell defaults own env;
#            NOT physical delete — thin edges + B2 remain
#   wave878: B7B migrate_x_objs multi-token CC/PYTHON/MAKE inject hygiene (4 recipes) →
#            drop CC/PYTHON/MAKE inject; shell defaults own env; thin @sh only;
#            NOT physical delete — thin edges + B2 remain
#   wave879: B7B stage/bootstrap multi-token TARGET/CC/MAKE inject hygiene (13 recipes)
#            → clean/typeck/codegen/seed/relink/xlang-x/check-6.4/build-tool/
#            self/pipeline/x-compiler; shell defaults own env; thin @sh/@bash only;
#            NOT physical delete — thin edges + B2 remain
#   wave880: B7B ENSURE=0 / OUT=$@ / all OPT inject hygiene (7 recipes) →
#            all / test_c / test_x / seed-x-frontend / legacy xlang-c /
#            xlang-no-c-frontend / check-7.2-bstrict; MAKELEVEL shell defaults;
#            NOT physical delete — thin edges + B2 remain
#   wave881: B7B try-heat XLANG_G05_PREFER_X_O inject hygiene (31 recipes) →
#            CC-only thin-call; PREFER via make CLI/env + shell default;
#            NOT physical delete — thin edges + B2 remain
#   wave882: B7B residual single-token TARGET= inject hygiene (10 recipes) →
#            token/lexer/parser/parse-file / hybrid / crt0 / build-via-tool /
#            check-7.2 pure drop; bstrict+refresh drop TARGET from multi-token;
#            shell TARGET:-xlang + CLI auto-export; NOT physical delete
#   wave856: B7B archaeology LINK_OBJS shell-load via make export leaves (5 bags /
#            6 shells; nested expand; Makefile drops multi-token LINK_OBJS env;
#            NOT physical delete — CFLAGS env + thin edges + B2 remain)
#   wave781: B3 LSP satellite hybrid body → try-lsp-sat-prefer
#   wave782: B4 gen_c_to_o bootstrap → try-gen-c-to-o
#   wave783: B5 cfg_eval multi-ladder → try-cfg-eval-ladder
#   wave784: B6 R5 CI / compiler-all body → compiler_all_ci.sh (Makefile thin-call)
#   wave785: B7 DAG residual inventory + archaeology $(CC) -c thin (NOT physical delete)
#   wave786: B7D host-cc product xlang link → g05_prepare_and_relink (not OBJS_CORE UNDEF)
#   wave787: B7A cold rebuild residual_make=0 honesty + heat thin-edge inventory
#            (NOT physical delete; heat ensure edges + B7B lists remain)
#   wave788: B7B shell-primary catalog (mk parse 0-make; make export escape)
#   wave789: B7A heat shell auto-dispatch try-heat (NOT physical delete;
#            Makefile thin-call edges remain residual)
#   wave790: B7A heat Makefile recipes unify → try-heat only (NOT physical delete;
#            dep edges remain; historical try-* modes stay in comments)
#   wave791: B7A heat dep-edge thin for pure runtime_* seed+.x leaves (NOT physical
#            delete; FORCE + ensure script; shell owns seed/.x mtime; residual edges remain)
#   wave793: B7A heat dep-edge thin pure seed+.x+.h residual (+19 → 78 FORCE);
#            ensure seed_project_hdrs_newer owns project-header mtime.
#   wave792: B7A heat dep-edge thin pure seed+.x residual (non-runtime_* R1/async/rt/
#            alias/L2/lsp/strict_minimal) → FORCE + ensure; exclude hdr/twin/cfg_eval/asm
#            gen; NOT physical delete; residual edges remain
#   wave794: B7A heat dep-edge thin twin·Makefile-flags·pure leftover (+8 → 86 FORCE);
#            scheduler/strict twin · glue_standalone multi-c · slice · main/runtime/
#            pipeline_abi Makefile flags (force_thin_makefile_flags_newer); residual:
#            cfg_eval multi · asm/gen · stamp · std merge · gen_x. NOT physical delete.
#   wave795: B7A heat dep-edge thin cfg_eval·asm·std direct/process (+15 → 101 FORCE);
#            cfg_eval multi · crt0/freestanding/typeck_f64 · path/runtime/process;
#            residual: net multi-merge · panic stamp · gen_x · orch. NOT physical delete.
#   wave796: B7A heat dep-edge thin net multi-merge · panic stamp · gen_x/B4
#            residual (+11 → 112 FORCE); shell net_merge multi mtime · panic host
#            pick/stamp · try-gen-x / try-gen-c-to-o. Residual: orch / physical
#            delete after Windows. NOT physical delete.
#   wave797: B7A heat dep-edge thin orch residual (+1 → 113 FORCE); shell owns
#            pipeline_bootstrap_orchestration seed/.x + pipeline_gen.c +
#            build_asm/pipeline_glue_types.inc. Residual: physical delete after
#            Windows only (heat source-prereq edges closed). NOT physical delete.
#   wave798: physical-delete preflight readiness (named blockers + Windows
#            min-gate command inventory). NOT physical delete; does NOT mark
#            Windows green (PHYS_DEL_WINDOWS_GATE_STATUS stays not_reproven).
#   wave799: physical-delete *execute* gate (phys_del_makefile_gate.sh) —
#            hard-refuse rm Makefile without Windows green; dry-run inventory.
#            NOT physical delete; does NOT mark Windows green.
#   wave800: Windows min-gate *proof stamp* harness (same phys_del script) —
#            --run-windows-gate writes stamp; --verify-windows-proof checks tip.
#            Evidence only: NOT STATUS flip; NOT physical delete.
#   wave801: STATUS flip *preview* (same phys_del script) — plan only after
#            verified proof; never edits leaf. NOT STATUS flip; NOT delete.
#   wave802: STATUS flip *apply harness* (same phys_del script) — proof +
#            confirm env can rewrite STATUS on leaf (or LEAF_FILE override);
#            tree on this tip stays not_reproven until human apply after real
#            Windows proof. NOT physical delete; ENDGAME stays 0 on flip.
#
# Authority (G.7):
#   Single shell authority for *named residual classes* of Makefile leaf pattern /
#   host-cc compile rules that still block physical delete of compiler/Makefile.
#   Does NOT own .o lists (compiler/mk/*.mk + catalog). R1 pure-body families,
#   R3 cold-else, R2 panic cold, and gen residual (try-gen-x) live in
#   ensure_host_cc_seed_o.sh / ensure_gen_x_o.sh; R3 PREFER thin R3_COLD nine
#   swallowed wave763 try-r3-prefer + wave764 g05 r3-prefer-family +
#   wave765 g05 labi multi-slice try-labi-prefer
#   wave766 g05 rt multi-slice try-rt-prefer; residual g05 other PREFER
#   (~~pipeline_abi/ldpc~~ wave767 · ~~target_cpu~~ wave768) / pure-ld · other L2.
#
# Human map: compiler/docs/LEAF_PATTERN_RESIDUAL.md
#
# Usage (repo root or compiler/):
#   bash compiler/scripts/leaf_pattern_residual.sh              # dump inventory
#   bash compiler/scripts/leaf_pattern_residual.sh classes      # class table only
#   bash compiler/scripts/leaf_pattern_residual.sh --check
#   ./xbuild leaf-patterns | leaf-residual [--check]
#
# PLATFORM: SHARED — inventory portable; leaf ABI stays in Makefile / mk.
# Wave: 746–802 Track MG · 11.3.1 path (B7A heat dep-edge thin wave791–797 · preflight wave798 · execute-gate wave799 · Windows proof harness wave800 · status-flip-preview wave801 · status-flip-apply harness wave802 · thin-unify wave790 · try-heat wave789 · B7B shell catalog · B7A cold 0-make · heat source-prereq closed · not physical delete · Windows gate + dual-end).

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname "$0")" && pwd)"
COMPILER_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)"
ROOT="$(CDPATH= cd -- "$COMPILER_DIR/.." && pwd)"

MODE="${1:-dump}"
case "$MODE" in
  --check|check|-c) MODE=check ;;
  classes|class|residual|inventory) MODE=classes ;;
  dump|all|"") MODE=dump ;;
  help|-h|--help)
    sed -n '2,28p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "leaf_pattern_residual: unknown mode '$MODE' (dump|classes|check)" >&2
    exit 2
    ;;
esac

fail=0
note() { echo "leaf_pattern_residual: $*" >&2; }
bad() { echo "leaf_pattern_residual: FAIL: $*" >&2; fail=1; }

# ---------------------------------------------------------------------------
# Inventory dump (KEY=value) — no .o list authority
# ---------------------------------------------------------------------------
print_classes() {
  cat <<EOF
# leaf pattern residual inventory (11.3.1 path · wave746–761)
# Lists stay mk/catalog. Pattern bodies stay Makefile until named shell swallow.

LEAF_PATTERN_POLICY=inventory_named_classes_plus_r4_mode_and_r1_families
LEAF_PATTERN_FORBIDDEN=dual_o_list_or_copy_cc_recipes

# Already shell (orchestration; not residual leaf pattern)
SWALLOWED_COLD_SEQ=scripts/bootstrap_driver_seed.sh
SWALLOWED_PREREQ_EDGES=scripts/driver_seed_ensure_prereqs.sh
SWALLOWED_REBUILD_ORCH=scripts/bootstrap_driver_seed_rebuild_leaves.sh
SWALLOWED_R4_MODE_POLICY=1
SWALLOWED_R4_MODE_LIST_SOURCE=driver_seed_obj_catalog.sh
SWALLOWED_R4_MODE_NOTE=catalog_KEY_plus_shell_ARGS_VARS_default
# wave756: pure R1 rebuild bodies leave make (try-r1); non-R1 residual still make
SWALLOWED_R4_BODY_PURE_R1=1
SWALLOWED_R4_BODY_PURE_R1_VIA=ensure_host_cc_seed_o.sh_try-r1
SWALLOWED_R4_BODY_NOTE=pure_R1_shell_non_R1_still_make
# wave757: R3 cold-else pure host-cc leave make (try-r3-cold)
SWALLOWED_R3_COLD_ELSE=1
SWALLOWED_R3_COLD_ELSE_VIA=ensure_host_cc_seed_o.sh_try-r3-cold
SWALLOWED_R3_COLD_ELSE_LIST=catalog_R3_COLD_SEED_OBJS
SWALLOWED_R3_COLD_ELSE_NOTE=cold_pure_host_cc_shell
# wave763: R3 PREFER thin+rest for R3_COLD nine leave make (try-r3-prefer)
SWALLOWED_R3_PREFER_THIN=1
SWALLOWED_R3_PREFER_THIN_VIA=ensure_host_cc_seed_o.sh_try-r3-prefer
SWALLOWED_R3_PREFER_THIN_LIST=catalog_R3_COLD_SEED_OBJS
SWALLOWED_R3_PREFER_THIN_NOTE=prefer_thin_rest_shell_Makefile_thin
# wave764: g05 product daily path same body (r3-prefer-family; full→thin ladder)
SWALLOWED_G05_R3_PREFER=1
SWALLOWED_G05_R3_PREFER_VIA=ensure_host_cc_seed_o.sh_r3-prefer-family
SWALLOWED_G05_R3_PREFER_LIST=catalog_R3_COLD_SEED_OBJS
SWALLOWED_G05_R3_PREFER_NOTE=g05_thin_call_no_dual_hybrid_R3_COLD
# wave765: g05 labi multi-slice product PREFER → try-labi-prefer
SWALLOWED_G05_LABI_PREFER=1
SWALLOWED_G05_LABI_PREFER_VIA=ensure_host_cc_seed_o.sh_try-labi-prefer
SWALLOWED_G05_LABI_PREFER_SCOPE=runtime_link_abi_R1_CORE_member
SWALLOWED_G05_LABI_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_labi
# wave766: g05 rt multi-slice product PREFER → try-rt-prefer
SWALLOWED_G05_RT_PREFER=1
SWALLOWED_G05_RT_PREFER_VIA=ensure_host_cc_seed_o.sh_try-rt-prefer
SWALLOWED_G05_RT_PREFER_SCOPE=runtime_driver_no_c_R1_MAIN_RUNTIME_member
SWALLOWED_G05_RT_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_rt
# wave767: g05 pipeline_abi + ldpc product PREFER → try-*-prefer
SWALLOWED_G05_PIPELINE_ABI_PREFER=1
SWALLOWED_G05_PIPELINE_ABI_PREFER_VIA=ensure_host_cc_seed_o.sh_try-pipeline-abi-prefer
SWALLOWED_G05_PIPELINE_ABI_PREFER_SCOPE=runtime_pipeline_abi_R1_EXTRA_CFLAGS_member
SWALLOWED_G05_PIPELINE_ABI_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_pipeline_abi
SWALLOWED_G05_LDPC_PREFER=1
SWALLOWED_G05_LDPC_PREFER_VIA=ensure_host_cc_seed_o.sh_try-ldpc-prefer
SWALLOWED_G05_LDPC_PREFER_SCOPE=lsp_diag_pipeline_ctx_R1_MISC_BASENAME_member
SWALLOWED_G05_LDPC_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_ldpc
# wave768: g05 target_cpu product PREFER → try-target-cpu-prefer
SWALLOWED_G05_TARGET_CPU_PREFER=1
SWALLOWED_G05_TARGET_CPU_PREFER_VIA=ensure_host_cc_seed_o.sh_try-target-cpu-prefer
SWALLOWED_G05_TARGET_CPU_PREFER_SCOPE=target_cpu_R1_SEED_MAP_member
SWALLOWED_G05_TARGET_CPU_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_target_cpu
# wave769: g05 L2 asm three product PREFER → try-l2-asm-prefer
SWALLOWED_G05_L2_ASM_PREFER=1
SWALLOWED_G05_L2_ASM_PREFER_VIA=ensure_host_cc_seed_o.sh_try-l2-asm-prefer
SWALLOWED_G05_L2_ASM_PREFER_SCOPE=user_asm_seed_bridge+backend_x86_64_enc_c+asm_backend_compat_stubs
SWALLOWED_G05_L2_ASM_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_l2_asm_three
# wave770: g05 async three product PREFER → try-async-prefer
SWALLOWED_G05_ASYNC_PREFER=1
SWALLOWED_G05_ASYNC_PREFER_VIA=ensure_host_cc_seed_o.sh_try-async-prefer
SWALLOWED_G05_ASYNC_PREFER_SCOPE=async_liveness+async_cps_codegen+async_asm_pool
SWALLOWED_G05_ASYNC_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_async_three
# wave771: g05 other L2 four product PREFER → try-other-l2-prefer
SWALLOWED_G05_OTHER_L2_PREFER=1
SWALLOWED_G05_OTHER_L2_PREFER_VIA=ensure_host_cc_seed_o.sh_try-other-l2-prefer
SWALLOWED_G05_OTHER_L2_PREFER_SCOPE=seed_link_compat+strict_glue_stubs+fmt_check_cmd_driver+lsp_diag
SWALLOWED_G05_OTHER_L2_PREFER_NOTE=g05_makefile_thin_call_no_dual_hybrid_other_l2_four
# wave775: fmt_check_cmd.o Makefile dual → try-other-l2-prefer (fmt_core, no USE_X_PIPELINE)
SWALLOWED_FMT_CHECK_CMD_O_DUAL=1
SWALLOWED_FMT_CHECK_CMD_O_DUAL_VIA=ensure_host_cc_seed_o.sh_try-other-l2-prefer_fmt_core
SWALLOWED_FMT_CHECK_CMD_O_DUAL_SCOPE=fmt_check_cmd_OBJS_CORE_PIPELINE_X_satellite
SWALLOWED_FMT_CHECK_CMD_O_DUAL_NOTE=makefile_thin_call_no_dual_hybrid_wave775
# wave772: 11.1.4 pure-ld cold phase1/final (via pure_ld_shared)
SWALLOWED_R6_PURE_LD=1
SWALLOWED_R6_PURE_LD_VIA=bootstrap_driver_seed_link.sh_run_pure_ld_required+pure_ld_shared
SWALLOWED_R6_PURE_LD_SCOPE=phase1+final_SEED_LINK_LD_export
SWALLOWED_R6_PURE_LD_NOTE=PURE_OK_required_no_silent_CC_fallback_wave774
# wave773: 11.1.4 g05 product pure-ld (same pure_ld_shared)
SWALLOWED_G05_PURE_LD=1
SWALLOWED_G05_PURE_LD_VIA=g05_relink_xlang.sh_run_g05_pure_ld_required+pure_ld_shared
SWALLOWED_G05_PURE_LD_SCOPE=product_final_xlang_relink
SWALLOWED_G05_PURE_LD_NOTE=freestanding_required_no_silent_CC_fallback_wave774
# wave774: drop silent CC residual fallback after pure-ld fail (FORCE_CC / ineligible kept)
SWALLOWED_DROP_CC_FALLBACK=1
SWALLOWED_DROP_CC_FALLBACK_VIA=cold_seed_link+g05_relink_xlang
SWALLOWED_DROP_CC_FALLBACK_SCOPE=pure_ld_fail_hard_FORCE_CC_or_ineligible_CC_only
SWALLOWED_DROP_CC_FALLBACK_NOTE=no_silent_CC_after_pure_fail_wave774
SWALLOWED_PURE_LD_SHARED=scripts/pure_ld_shared.sh
SWALLOWED_LINK_DRIVER=scripts/bootstrap_driver_seed_link.sh
SWALLOWED_G05_FAMILY=scripts/g05_*.sh
SWALLOWED_MIGRATE_GEN=scripts/migrate_x_objs.sh+ensure_*_gen.sh
SWALLOWED_HOST_LINKER_MAP=scripts/host_platform_linker.sh
# wave748–755: R1 pure host-cc body (shared ensure_host_cc_seed_o.sh)
SWALLOWED_R1_HOST_CC_SEED_BODY=scripts/ensure_host_cc_seed_o.sh
SWALLOWED_R1_FAMILY=rt_seed_slice+core_seed+frontend_glue+main_runtime+alias_stubs+extra_cflags+misc_basename+seed_map
SWALLOWED_R1_RT_SEED_SLICE=1
SWALLOWED_R1_CORE_SEED=1
SWALLOWED_R1_FRONTEND_GLUE=1
SWALLOWED_R1_MAIN_RUNTIME=1
SWALLOWED_R1_ALIAS_STUBS=1
SWALLOWED_R1_EXTRA_CFLAGS=1
SWALLOWED_R1_MISC_BASENAME=1
SWALLOWED_R1_SEED_MAP=1
SWALLOWED_R1_LIST_SOURCE=catalog_RT_SEED_SLICE_OBJS+catalog_R1_CORE_SEED_OBJS+catalog_R1_FRONTEND_GLUE_OBJS+catalog_R1_MAIN_RUNTIME_OBJS+catalog_R1_ALIAS_STUBS_OBJS+catalog_R1_EXTRA_CFLAGS_OBJS+catalog_R1_MISC_BASENAME_OBJS+catalog_R1_SEED_MAP_OBJS
SWALLOWED_R1_NOTE=pure_cc_body_shell_lists_mk_R3_prefer_thin_and_R4_non_R1_residual
# wave758: thin_glue pure host-cc joined R1 seed-map (was R4 residual)
SWALLOWED_R4_BODY_THIN_GLUE=1
SWALLOWED_R4_BODY_THIN_GLUE_VIA=ensure_host_cc_seed_o.sh_seed-map_try-r1
SWALLOWED_R4_BODY_THIN_GLUE_NOTE=parser_asm_thin_glue_seed_map_wave758
# wave759: glue standalone pure host-cc joined R1 seed-map (was R4 residual cc_inc_tu)
SWALLOWED_R4_BODY_GLUE_STANDALONE=1
SWALLOWED_R4_BODY_GLUE_STANDALONE_VIA=ensure_host_cc_seed_o.sh_seed-map_try-r1
SWALLOWED_R4_BODY_GLUE_STANDALONE_NOTE=pipeline_glue_standalone_seed_map_wave759
# wave760: R2 panic cold body leave make (try-r2)
SWALLOWED_R2_PANIC_COLD=1
SWALLOWED_R2_PANIC_COLD_VIA=ensure_host_cc_seed_o.sh_try-r2
SWALLOWED_R2_PANIC_COLD_LIST=catalog_DRIVER_SEED_PANIC_OBJS
SWALLOWED_R2_PANIC_COLD_NOTE=panic_cold_shell_try_r2
# wave776: R2 panic PREFER thin+rest leave make (try-r2-prefer)
SWALLOWED_R2_PANIC_PREFER=1
SWALLOWED_R2_PANIC_PREFER_VIA=ensure_host_cc_seed_o.sh_try-r2-prefer
SWALLOWED_R2_PANIC_PREFER_SCOPE=runtime_panic_DRIVER_SEED_PANIC_member
SWALLOWED_R2_PANIC_PREFER_NOTE=makefile_thin_call_no_dual_hybrid_wave776
# wave762: R2 typeck_f64 + crt0 leave make (try-r2 extend)
SWALLOWED_R2_TYPECK_F64=1
SWALLOWED_R2_TYPECK_F64_VIA=ensure_host_cc_seed_o.sh_try-r2
SWALLOWED_R2_TYPECK_F64_LIST=catalog_DRIVER_SEED_TYPECK_F64_OBJS
SWALLOWED_R2_TYPECK_F64_NOTE=typeck_f64_bits_host_pick_s
SWALLOWED_R2_CRT0=1
SWALLOWED_R2_CRT0_VIA=ensure_host_cc_seed_o.sh_try-r2
SWALLOWED_R2_CRT0_LIST=catalog_DRIVER_SEED_CRT0_OBJS
SWALLOWED_R2_CRT0_NOTE=crt0_freestanding_s_mingw_seed
# wave761: R4 residual gen *_x + pipeline_x leave make (try-gen-x)
SWALLOWED_R4_BODY_GEN_X=1
SWALLOWED_R4_BODY_GEN_X_VIA=ensure_gen_x_o.sh_try-gen-x
SWALLOWED_R4_BODY_GEN_X_LIST=catalog_DRIVER_SEED_LSP_X_OBJS+DRIVER_SEED_PIPELINE_X_OBJS
SWALLOWED_R4_BODY_GEN_X_NOTE=lsp_io_x_lsp_x_lsp_diag_x_pipeline_x_shell

# Residual classes still Makefile-owned (R1–R5 = 11.3.1; R6 = 11.1.4)
RESIDUAL_CLASS_R1=host_cc_seed_from_x_to_o
RESIDUAL_CLASS_R1_SURFACE=Makefile_\$(CC)_-c_seeds/*.from_x.c
RESIDUAL_CLASS_R1_FAMILY_RT_SLICE=swallowed_wave748
RESIDUAL_CLASS_R1_FAMILY_CORE_SEED=swallowed_wave749
RESIDUAL_CLASS_R1_FAMILY_FRONTEND_GLUE=swallowed_wave750
RESIDUAL_CLASS_R1_FAMILY_MAIN_RUNTIME=swallowed_wave751
RESIDUAL_CLASS_R1_FAMILY_ALIAS_STUBS=swallowed_wave752
RESIDUAL_CLASS_R1_FAMILY_EXTRA_CFLAGS=swallowed_wave753
RESIDUAL_CLASS_R1_FAMILY_MISC_BASENAME=swallowed_wave754
RESIDUAL_CLASS_R1_FAMILY_SEED_MAP=swallowed_wave755
RESIDUAL_CLASS_R1_OTHER_LEAVES=residual_non_catalog_host_cc
RESIDUAL_CLASS_R1_ENDGAME=shell_ensure_or_product_E_plus_cc_single_body_all_families

RESIDUAL_CLASS_R2=platform_stamp_uname_leaf
RESIDUAL_CLASS_R2_SURFACE=runtime_panic.stamp+typeck_f64_bits+crt0
RESIDUAL_CLASS_R2_PANIC_COLD=swallowed_wave760_try_r2
RESIDUAL_CLASS_R2_PANIC_PREFER=swallowed_wave776_try_r2_prefer
RESIDUAL_CLASS_R2_OTHER=swallowed_wave762_try_r2_typeck_f64_crt0
RESIDUAL_CLASS_R2_TYPECK_F64=swallowed_wave762_try_r2
RESIDUAL_CLASS_R2_CRT0=swallowed_wave762_try_r2
RESIDUAL_CLASS_R2_ENDGAME=shell_plus_host_platform_facts_lists_mk

RESIDUAL_CLASS_R3=thin_rest_prefer_x_o_host_cc
RESIDUAL_CLASS_R3_SURFACE=thin.o+FROM_X_rest_cc+ld_-r
RESIDUAL_CLASS_R3_COLD_ELSE=swallowed_wave757_try_r3_cold
RESIDUAL_CLASS_R3_PREFER_THIN=swallowed_wave763_try_r3_prefer
RESIDUAL_CLASS_R3_PREFER_THIN_SCOPE=R3_COLD_SEED_OBJS_nine
RESIDUAL_CLASS_G05_R3_PREFER=swallowed_wave764_g05_r3_prefer_family
RESIDUAL_CLASS_G05_R3_PREFER_SCOPE=R3_COLD_SEED_OBJS_nine
RESIDUAL_CLASS_G05_LABI_PREFER=swallowed_wave765_try_labi_prefer
RESIDUAL_CLASS_G05_RT_PREFER=swallowed_wave766_try_rt_prefer
RESIDUAL_CLASS_G05_PIPELINE_ABI_PREFER=swallowed_wave767_try_pipeline_abi_prefer
RESIDUAL_CLASS_G05_LDPC_PREFER=swallowed_wave767_try_ldpc_prefer
RESIDUAL_CLASS_G05_TARGET_CPU_PREFER=swallowed_wave768_try_target_cpu_prefer
RESIDUAL_CLASS_G05_L2_ASM_PREFER=swallowed_wave769_try_l2_asm_prefer
RESIDUAL_CLASS_R3_PREFER_THIN_RESIDUAL=g05_other_prefer_other_L2
RESIDUAL_CLASS_R3_ENDGAME=g05_ensure_other_L2

RESIDUAL_CLASS_R4=cold_rebuild_pattern_bodies
RESIDUAL_CLASS_R4_SURFACE=sat|lsp|bridge|panic|user-asm|glue|pipeline-x_make_pattern
RESIDUAL_CLASS_R4_MODE_POLICY=swallowed_wave747
RESIDUAL_CLASS_R4_BODY_PURE_R1=swallowed_wave756_try_r1
RESIDUAL_CLASS_R4_BODY_R3_COLD=swallowed_wave757_try_r3_cold
RESIDUAL_CLASS_R4_BODY_THIN_GLUE=swallowed_wave758_seed_map
RESIDUAL_CLASS_R4_BODY_GLUE_STANDALONE=swallowed_wave759_seed_map
RESIDUAL_CLASS_R4_BODY_R2_PANIC=swallowed_wave760_try_r2
RESIDUAL_CLASS_R4_BODY_GEN_X=swallowed_wave761_try_gen_x
RESIDUAL_CLASS_R4_BODY=other_non_shell_pattern_if_any
RESIDUAL_CLASS_R4_ENDGAME=rebuild_leaves_without_make_pattern

RESIDUAL_CLASS_R5=ci_compiler_all_host_cc_graph
RESIDUAL_CLASS_R5_SURFACE=Makefile_all_OPT_seed
RESIDUAL_CLASS_R5_BODY=swallowed_wave784_compiler_all_ci_sh
RESIDUAL_CLASS_R5_BODY_VIA=scripts/compiler_all_ci.sh
RESIDUAL_CLASS_R5_ENDGAME=stage12_zero_host_cc_unload_gcc_make

RESIDUAL_CLASS_R6=cold_link_pure_ld_prefer
RESIDUAL_CLASS_R6_SURFACE=bootstrap_driver_seed_link_run_pure_ld_required
RESIDUAL_CLASS_R6_TRACK=11.1.4_PLATFORM_LINKER
RESIDUAL_CLASS_R6_SWALLOWED=wave772_pure_ld_export_and_prefer
RESIDUAL_CLASS_R6_DROP_SILENT_FALLBACK=wave774
RESIDUAL_CLASS_R6_CC_RESIDUAL=SEED_LINK_CC_when_PURE_OK_0_or_FORCE_CC_only
RESIDUAL_CLASS_R6_G05=g05_relink_pure_ld_required
RESIDUAL_CLASS_R6_G05_SWALLOWED=wave773_g05_pure_ld_via_pure_ld_shared
RESIDUAL_CLASS_R6_G05_DROP_SILENT_FALLBACK=wave774
RESIDUAL_CLASS_R6_ENDGAME=physical_delete_makefile
# wave775: fmt_check_cmd.o dual swallowed (fmt_core)
# wave776: R2 panic PREFER swallowed (try-r2-prefer)

# wave777: physical-delete prep inventory (named buckets; NOT body swallow; NOT delete Makefile)
# Heat counts are live Makefile signals only — not a second .o list authority (G.7).
PHYS_DEL_PREP_INVENTORY=1
PHYS_DEL_PREP_WAVE=wave777
PHYS_DEL_PREP_NOTE=named_buckets_only_no_body_swallow_no_makefile_delete
# B1: ~~runtime_* OS/glue dual hybrid body~~ wave779 → try-runtime-os-prefer
#     (Makefile thin-call edges remain; NOT physical delete)
PHYS_DEL_BUCKET_B1=runtime_os_hybrid_makefile
PHYS_DEL_BUCKET_B1_SCOPE=runtime_test_fn_invoke..process_os_glue_thin_call
PHYS_DEL_BUCKET_B1_HEAT_TARGETS=23
PHYS_DEL_BUCKET_B1_BODY_SWALLOWED=1
SWALLOWED_B1_RUNTIME_OS_PREFER=1
B1_RUNTIME_OS_PREFER_SWALLOWED=1
B1_RUNTIME_OS_PREFER_HELPER=try-runtime-os-prefer
B1_RUNTIME_OS_PREFER_WAVE=wave779
# B2: ~~product std/core hybrid body~~ wave780 → try-std-core-prefer
#     (Makefile thin-call edges remain; NOT physical delete)
PHYS_DEL_BUCKET_B2=std_core_product_hybrid
PHYS_DEL_BUCKET_B2_SCOPE=std_process_path_runtime_net_core_slice_thin_call
PHYS_DEL_BUCKET_B2_HEAT_TARGETS=5
PHYS_DEL_BUCKET_B2_BODY_SWALLOWED=1
SWALLOWED_B2_STD_CORE_PREFER=1
B2_STD_CORE_PREFER_SWALLOWED=1
B2_STD_CORE_PREFER_HELPER=try-std-core-prefer
B2_STD_CORE_PREFER_WAVE=wave780
# wave811: pure .x std product leaves still had Makefile if-ladder + xlang_compile_std_x.
# G.7 有则补全: host pick + soft/hard + socketio merge live in xlang_compile_std_x.sh;
# Makefile 22 leaves thin-call auto|auto-soft|auto-soft-merge only. NOT physical delete.
# formal_mod / try-std-core-prefer / remaining mk lists still form std_core_product_make_graph.
PHYS_DEL_STD_X_HYBRID_THIN=1
PHYS_DEL_STD_X_HYBRID_THIN_WAVE=wave811
PHYS_DEL_STD_X_HYBRID_THIN_COUNT=22
PHYS_DEL_STD_X_HYBRID_THIN_VIA=xlang_compile_std_x_auto_soft_merge
PHYS_DEL_STD_X_HYBRID_THIN_NOTE=makefile_if_ladder_swallowed_thin_call_edges_remain
SWALLOWED_STD_X_HYBRID_BODY=1
STD_X_HYBRID_BODY_SWALLOWED=1
STD_X_HYBRID_BODY_HELPER=xlang_compile_std_x.sh
STD_X_HYBRID_BODY_WAVE=wave811
# wave825: std_x product mode|x_path catalog lives in xlang_compile_std_x.sh;
# Makefile 22 leaves thin-call ensure only. NOT physical delete — thin edges +
# formal_mod + B2 try-std-core-prefer + mk lists still form std_core_product_make_graph.
PHYS_DEL_STD_X_SHELL_PRIMARY=1
PHYS_DEL_STD_X_SHELL_PRIMARY_WAVE=wave825
PHYS_DEL_STD_X_SHELL_PRIMARY_COUNT=22
PHYS_DEL_STD_X_SHELL_PRIMARY_VIA=xlang_compile_std_x_ensure
PHYS_DEL_STD_X_SHELL_PRIMARY_NOTE=catalog_ensure_thin_call_edges_remain
SWALLOWED_STD_X_CATALOG=1
STD_X_CATALOG_SWALLOWED=1
STD_X_CATALOG_HELPER=xlang_compile_std_x.sh
STD_X_CATALOG_WAVE=wave825
# wave812: formal_mod product table (bare + sources + fs_formal) lives in
# xlang_compile_std_module.sh; Makefile 38 leaves thin-call ensure only.
# NOT physical delete — thin edges + B2 try-std-core-prefer + B7B lists remain.
PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY=1
PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_WAVE=wave812
PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_COUNT=38
PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_VIA=xlang_compile_std_module_ensure
PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_NOTE=catalog_ensure_thin_call_edges_remain
SWALLOWED_FORMAL_MOD_CATALOG=1
FORMAL_MOD_CATALOG_SWALLOWED=1
FORMAL_MOD_CATALOG_HELPER=xlang_compile_std_module.sh
FORMAL_MOD_CATALOG_WAVE=wave812
# wave826: formal_mod FORCE dep-thin — Makefile prereqs FORCE+script only; shell
# owns catalog source mtime (skip up-to-date). NOT physical delete — thin edges
# + B2 try-heat + mk lists still form std_core_product_make_graph.
PHYS_DEL_FORMAL_MOD_FORCE_THIN=1
PHYS_DEL_FORMAL_MOD_FORCE_THIN_WAVE=wave826
PHYS_DEL_FORMAL_MOD_FORCE_THIN_COUNT=38
PHYS_DEL_FORMAL_MOD_FORCE_THIN_VIA=xlang_compile_std_module_ensure_mtime
PHYS_DEL_FORMAL_MOD_FORCE_THIN_NOTE=force_prereq_shell_owns_source_mtime_edges_remain
SWALLOWED_FORMAL_MOD_FORCE_THIN=1
FORMAL_MOD_FORCE_THIN_SWALLOWED=1
FORMAL_MOD_FORCE_THIN_HELPER=xlang_compile_std_module.sh
FORMAL_MOD_FORCE_THIN_WAVE=wave826
# wave827: std_x FORCE dep-thin — Makefile prereqs FORCE+script only; shell
# owns catalog source mtime (skip up-to-date). NOT physical delete — thin edges
# + formal_mod FORCE + B2 try-heat + mk lists still form std_core_product_make_graph.
PHYS_DEL_STD_X_FORCE_THIN=1
PHYS_DEL_STD_X_FORCE_THIN_WAVE=wave827
PHYS_DEL_STD_X_FORCE_THIN_COUNT=22
PHYS_DEL_STD_X_FORCE_THIN_VIA=xlang_compile_std_x_ensure_mtime
PHYS_DEL_STD_X_FORCE_THIN_NOTE=force_prereq_shell_owns_source_mtime_edges_remain
SWALLOWED_STD_X_FORCE_THIN=1
STD_X_FORCE_THIN_SWALLOWED=1
STD_X_FORCE_THIN_HELPER=xlang_compile_std_x.sh
STD_X_FORCE_THIN_WAVE=wave827
# wave813: B7B product STD_AND_PANIC_O inventory → mk/std_and_panic_objs.mk (G.7).
# Makefile includes mk only; no dual inline re-list. NOT physical delete —
# thin-call edges + B2 ensure + other mk lists remain residual.
PHYS_DEL_B7B_STD_AND_PANIC_LIST=1
PHYS_DEL_B7B_STD_AND_PANIC_LIST_WAVE=wave813
PHYS_DEL_B7B_STD_AND_PANIC_LIST_COUNT=65
PHYS_DEL_B7B_STD_AND_PANIC_LIST_VIA=mk_std_and_panic_objs
PHYS_DEL_B7B_STD_AND_PANIC_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_STD_AND_PANIC_LIST=1
B7B_STD_AND_PANIC_LIST_SWALLOWED=1
B7B_STD_AND_PANIC_LIST_MK=mk/std_and_panic_objs.mk
B7B_STD_AND_PANIC_LIST_WAVE=wave813
# wave814: driver_leaf product table (src+rename+cold seed+-L) lives in
# driver_leaf_x_to_o.sh; Makefile 8 leaves thin-call ensure only.
# NOT physical delete — thin edges + B2 ensure + B7B lists remain.
PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY=1
PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_WAVE=wave814
PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_COUNT=8
PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_VIA=driver_leaf_x_to_o_ensure
PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_NOTE=catalog_ensure_thin_call_edges_remain
SWALLOWED_DRIVER_LEAF_CATALOG=1
DRIVER_LEAF_CATALOG_SWALLOWED=1
DRIVER_LEAF_CATALOG_HELPER=driver_leaf_x_to_o.sh
DRIVER_LEAF_CATALOG_WAVE=wave814
# wave828: driver_leaf FORCE dep-thin — Makefile prereqs FORCE+script only; shell
# owns catalog source mtime (skip up-to-date). NOT physical delete — thin edges
# + B2 try-heat + mk lists still form make graph residual.
PHYS_DEL_DRIVER_LEAF_FORCE_THIN=1
PHYS_DEL_DRIVER_LEAF_FORCE_THIN_WAVE=wave828
PHYS_DEL_DRIVER_LEAF_FORCE_THIN_COUNT=8
PHYS_DEL_DRIVER_LEAF_FORCE_THIN_VIA=driver_leaf_x_to_o_ensure_mtime
PHYS_DEL_DRIVER_LEAF_FORCE_THIN_NOTE=force_prereq_shell_owns_source_mtime_edges_remain
SWALLOWED_DRIVER_LEAF_FORCE_THIN=1
DRIVER_LEAF_FORCE_THIN_SWALLOWED=1
DRIVER_LEAF_FORCE_THIN_HELPER=driver_leaf_x_to_o.sh
DRIVER_LEAF_FORCE_THIN_WAVE=wave828
# wave829: product/archaeology *_gen.c FORCE dep-thin — Makefile prereqs FORCE+script
# only; shell owns pin/seed/FORCE_REGEN policy (ensure_*_gen). NOT physical delete —
# thin edges + B2 try-heat + mk lists remain (ast_gen2 closed wave830).
PHYS_DEL_GEN_C_FORCE_THIN=1
PHYS_DEL_GEN_C_FORCE_THIN_WAVE=wave829
PHYS_DEL_GEN_C_FORCE_THIN_COUNT=17
PHYS_DEL_GEN_C_FORCE_THIN_VIA=ensure_migrate_driver_lsp_archaeology_gen_pin_policy
PHYS_DEL_GEN_C_FORCE_THIN_NOTE=force_prereq_shell_owns_gen_pin_policy_edges_remain
SWALLOWED_GEN_C_FORCE_THIN=1
GEN_C_FORCE_THIN_SWALLOWED=1
GEN_C_FORCE_THIN_HELPER=ensure_migrate_driver_lsp_archaeology_gen
GEN_C_FORCE_THIN_WAVE=wave829
# wave830: ast_gen2.c FORCE dep-thin — Makefile prereqs FORCE+script only; shell owns
# pin/FORCE_REGEN/-E+fix_slim policy (ensure_ast_gen2). NOT physical delete —
# thin edges + B2 try-heat + mk lists still form make graph.
PHYS_DEL_AST_GEN2_FORCE_THIN=1
PHYS_DEL_AST_GEN2_FORCE_THIN_WAVE=wave830
PHYS_DEL_AST_GEN2_FORCE_THIN_COUNT=1
PHYS_DEL_AST_GEN2_FORCE_THIN_VIA=ensure_ast_gen2_pin_policy
PHYS_DEL_AST_GEN2_FORCE_THIN_NOTE=force_prereq_shell_owns_ast_gen2_pin_policy_edges_remain
SWALLOWED_AST_GEN2_FORCE_THIN=1
AST_GEN2_FORCE_THIN_SWALLOWED=1
AST_GEN2_FORCE_THIN_HELPER=ensure_ast_gen2.sh
AST_GEN2_FORCE_THIN_WAVE=wave830
# wave831: leftover source-prereq make-graph edges → FORCE + shell mtime (G.7).
# 1× parser_asm_thin_glue try-heat (slice mtime already in ensure) + 6× cc_inc_tu
# (seed mtime + optional XLANG_CC_INC_TU_PEERS). NOT physical delete — thin-call
# edges + B2 + mk lists remain (migrate *_x swallowed wave832).
PHYS_DEL_SRC_EDGE_FORCE_THIN=1
PHYS_DEL_SRC_EDGE_FORCE_THIN_WAVE=wave831
PHYS_DEL_SRC_EDGE_FORCE_THIN_COUNT=7
PHYS_DEL_SRC_EDGE_FORCE_THIN_VIA=parser_asm_try_heat+cc_inc_tu_mtime
PHYS_DEL_SRC_EDGE_FORCE_THIN_NOTE=force_prereq_shell_owns_src_mtime_edges_remain
PHYS_DEL_SRC_EDGE_FORCE_THIN_CC_INC=6
PHYS_DEL_SRC_EDGE_FORCE_THIN_PARSER_ASM=1
SWALLOWED_SRC_EDGE_FORCE_THIN=1
SRC_EDGE_FORCE_THIN_SWALLOWED=1
SRC_EDGE_FORCE_THIN_HELPER=cc_inc_tu.sh+ensure_host_cc_seed_o_try-heat
SRC_EDGE_FORCE_THIN_WAVE=wave831
# wave832: migrate companion (parser/typeck/codegen) → FORCE + migrate_x_objs
# (need_rebuild owns gen mtime; ensure_migrate_gen for missing/stale gen).
# NOT physical delete — ~~pipeline_glue_types.inc~~ (wave833) + thin edges + B2 + mk lists remain.
PHYS_DEL_MIGRATE_X_FORCE_THIN=1
PHYS_DEL_MIGRATE_X_FORCE_THIN_WAVE=wave832
PHYS_DEL_MIGRATE_X_FORCE_THIN_COUNT=3
PHYS_DEL_MIGRATE_X_FORCE_THIN_VIA=migrate_x_objs_need_rebuild_mtime
PHYS_DEL_MIGRATE_X_FORCE_THIN_NOTE=force_prereq_shell_owns_gen_mtime_edges_remain
SWALLOWED_MIGRATE_X_FORCE_THIN=1
MIGRATE_X_FORCE_THIN_SWALLOWED=1
MIGRATE_X_FORCE_THIN_HELPER=migrate_x_objs.sh
MIGRATE_X_FORCE_THIN_WAVE=wave832
# wave833: pipeline_glue_types.inc extract → FORCE + ensure_pipeline_glue_types
# (need_rebuild owns gen/extract.pl mtime; ABI guard + extract.pl called by shell).
# NOT physical delete — ~~bootstrap-pipeline~~ (wave834) + thin-call edges + B2 + mk lists remain.
PHYS_DEL_GLUE_TYPES_FORCE_THIN=1
PHYS_DEL_GLUE_TYPES_FORCE_THIN_WAVE=wave833
PHYS_DEL_GLUE_TYPES_FORCE_THIN_COUNT=1
PHYS_DEL_GLUE_TYPES_FORCE_THIN_VIA=ensure_pipeline_glue_types_need_rebuild_mtime
PHYS_DEL_GLUE_TYPES_FORCE_THIN_NOTE=force_prereq_shell_owns_extract_mtime_edges_remain
SWALLOWED_GLUE_TYPES_FORCE_THIN=1
GLUE_TYPES_FORCE_THIN_SWALLOWED=1
GLUE_TYPES_FORCE_THIN_HELPER=ensure_pipeline_glue_types.sh
GLUE_TYPES_FORCE_THIN_WAVE=wave833
# wave834: bootstrap-pipeline phony → FORCE + ensure_lsp_pipeline_gen.sh pipeline
# (G.7 有则补全 wave739 body; no make-graph edge on pipeline_gen.c file).
# NOT physical delete — ~~class-G filter~~ (wave835) + thin-call edges + B2 + mk lists remain.
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN=1
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_WAVE=wave834
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_COUNT=1
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_VIA=ensure_lsp_pipeline_gen_pipeline_mode
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_NOTE=force_prereq_shell_owns_pipeline_gen_ensure_edges_remain
SWALLOWED_BOOTSTRAP_PIPELINE_FORCE_THIN=1
BOOTSTRAP_PIPELINE_FORCE_THIN_SWALLOWED=1
BOOTSTRAP_PIPELINE_FORCE_THIN_HELPER=ensure_lsp_pipeline_gen.sh
BOOTSTRAP_PIPELINE_FORCE_THIN_WAVE=wave834
# wave835: class-G bootstrap_seed_*_filtered → FORCE + filter_* ensure (G.7).
# 3× against partial + 1× pipeline; shell owns mtime + try-heat SRC.
# NOT physical delete — thin-call edges + B2 + mk lists remain.
# (KEY name FILTERED_O avoids bare product path tokens; honesty greps use patterns.)
PHYS_DEL_FILTERED_O_FORCE_THIN=1
PHYS_DEL_FILTERED_O_FORCE_THIN_WAVE=wave835
PHYS_DEL_FILTERED_O_FORCE_THIN_COUNT=4
PHYS_DEL_FILTERED_O_FORCE_THIN_VIA=filter_bootstrap_seed_ensure_mtime
PHYS_DEL_FILTERED_O_FORCE_THIN_NOTE=force_prereq_shell_owns_src_partial_mtime_edges_remain
PHYS_DEL_FILTERED_O_FORCE_THIN_PARTIAL=3
PHYS_DEL_FILTERED_O_FORCE_THIN_PIPELINE=1
SWALLOWED_FILTERED_O_FORCE_THIN=1
FILTERED_O_FORCE_THIN_SWALLOWED=1
FILTERED_O_FORCE_THIN_HELPER=filter_bootstrap_seed_against_partial_o+filter_bootstrap_seed_pipeline_o
FILTERED_O_FORCE_THIN_WAVE=wave835
# wave836: product object-path cp-alias → FORCE + ensure_cp_alias_o (G.7 无才新增).
# 3 leaves: shared ast alias + 2× x86_64 freestanding link-name wrappers.
# Shell owns SRC mtime + try-heat when SRC missing.
# NOT physical delete — thin-call edges + B2 + mk lists remain.
# (KEY name CP_ALIAS avoids bare product path tokens; honesty greps use patterns.)
PHYS_DEL_CP_ALIAS_FORCE_THIN=1
PHYS_DEL_CP_ALIAS_FORCE_THIN_WAVE=wave836
PHYS_DEL_CP_ALIAS_FORCE_THIN_COUNT=3
PHYS_DEL_CP_ALIAS_FORCE_THIN_VIA=ensure_cp_alias_o_mtime
PHYS_DEL_CP_ALIAS_FORCE_THIN_NOTE=force_prereq_shell_owns_src_cp_mtime_edges_remain
PHYS_DEL_CP_ALIAS_FORCE_THIN_SHARED=1
PHYS_DEL_CP_ALIAS_FORCE_THIN_X86_64=2
SWALLOWED_CP_ALIAS_FORCE_THIN=1
CP_ALIAS_FORCE_THIN_SWALLOWED=1
CP_ALIAS_FORCE_THIN_HELPER=ensure_cp_alias_o.sh
CP_ALIAS_FORCE_THIN_WAVE=wave836
# wave837: pipeline_gen.c file target → FORCE + ensure_lsp_pipeline_gen pipeline
# (G.7 有则补全 wave739 body; was empty-prereq residual after wave829/834).
# Shell owns pin/seed/FORCE_REGEN + always-run i64 ABI. NOT physical delete —
# thin-call edges + B2 + mk lists remain.
# (KEY name PIPELINE_GEN is the leaf class; honesty greps use target-line patterns.)
PHYS_DEL_PIPELINE_GEN_FORCE_THIN=1
PHYS_DEL_PIPELINE_GEN_FORCE_THIN_WAVE=wave837
PHYS_DEL_PIPELINE_GEN_FORCE_THIN_COUNT=1
PHYS_DEL_PIPELINE_GEN_FORCE_THIN_VIA=ensure_lsp_pipeline_gen_pipeline_mode
PHYS_DEL_PIPELINE_GEN_FORCE_THIN_NOTE=force_prereq_shell_owns_pin_seed_abi_edges_remain
SWALLOWED_PIPELINE_GEN_FORCE_THIN=1
PIPELINE_GEN_FORCE_THIN_SWALLOWED=1
PIPELINE_GEN_FORCE_THIN_HELPER=ensure_lsp_pipeline_gen.sh
PIPELINE_GEN_FORCE_THIN_WAVE=wave837
# wave838: bootstrap_xlangc G-06 cold-egg file target → FORCE + select_bootstrap_xlangc
# (G.7 有则补全; was script-prereq residual after wave837). Shell owns host seed
# pick / can_run skip / optional create. NOT physical delete — thin-call edges +
# B2 + mk lists remain.
PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN=1
PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_WAVE=wave838
PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_COUNT=1
PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_VIA=select_bootstrap_xlangc_host_seed_pick
PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_NOTE=force_prereq_shell_owns_host_seed_pick_edges_remain
SWALLOWED_BOOTSTRAP_XLANGC_FORCE_THIN=1
BOOTSTRAP_XLANGC_FORCE_THIN_SWALLOWED=1
BOOTSTRAP_XLANGC_FORCE_THIN_HELPER=select_bootstrap_xlangc.sh
BOOTSTRAP_XLANGC_FORCE_THIN_WAVE=wave838

# wave815: archaeology host-pick phonies (TLS openssl/mbedtls + sqlite stub + net-o-stub)
# live in archaeology_host_pick_phony.sh; Makefile thin-call ensure only.
# NOT physical delete — thin edges + B2 ensure + B7B lists remain.
PHYS_DEL_ARCH_HOST_PICK_PHONY=1
PHYS_DEL_ARCH_HOST_PICK_PHONY_WAVE=wave815
PHYS_DEL_ARCH_HOST_PICK_PHONY_COUNT=4
PHYS_DEL_ARCH_HOST_PICK_PHONY_VIA=archaeology_host_pick_phony_ensure
PHYS_DEL_ARCH_HOST_PICK_PHONY_NOTE=catalog_ensure_thin_call_edges_remain
SWALLOWED_ARCH_HOST_PICK_PHONY=1
ARCH_HOST_PICK_PHONY_SWALLOWED=1
ARCH_HOST_PICK_PHONY_HELPER=archaeology_host_pick_phony.sh
ARCH_HOST_PICK_PHONY_WAVE=wave815
# wave839: archaeology host-pick FORCE dep-thin — Makefile prereqs FORCE+script only;
# shell owns host pick / TLS-sqlite merge (ensure). NOT physical delete — thin edges
# + B2 try-heat + mk lists still form make graph.
PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN=1
PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_WAVE=wave839
PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_COUNT=4
PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_VIA=archaeology_host_pick_phony_ensure_force
PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_NOTE=force_prereq_shell_owns_host_pick_edges_remain
SWALLOWED_ARCH_HOST_PICK_FORCE_THIN=1
ARCH_HOST_PICK_FORCE_THIN_SWALLOWED=1
ARCH_HOST_PICK_FORCE_THIN_HELPER=archaeology_host_pick_phony.sh
ARCH_HOST_PICK_FORCE_THIN_WAVE=wave839
# wave841: bootstrap-typeck / bootstrap-codegen full body → shell (G.7 有则补全).
# Gen = ensure_migrate_gen FORCE_REGEN; .o = migrate_x_objs FORCE; link bag = BTC_*
# from Makefile (mk composites). NOT physical delete — prereq make-graph + thin
# edges + B2 + mk lists remain residual. Honesty COUNT = 2 phonies.
PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1
PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_WAVE=wave841
PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_COUNT=2
PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_VIA=bootstrap_typeck_codegen_ensure_migrate_gen_migrate
PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_NOTE=shell_primary_gen_migrate_link_prereq_graph_remain
SWALLOWED_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1
BOOTSTRAP_TYPECK_CODEGEN_SHELL_SWALLOWED=1
BOOTSTRAP_TYPECK_CODEGEN_SHELL_HELPER=bootstrap_typeck_codegen.sh
BOOTSTRAP_TYPECK_CODEGEN_SHELL_WAVE=wave841
# wave842: bootstrap-x-compiler full body → shell (G.7 有则补全).
# Emit = TARGET_x -x -E; host-cc -c typeck_x_x/codegen_x_x (not migrate_x_objs;
# different archaeology TU names); link bag = BXC_LINK_OBJS from Makefile $(OBJS).
# NOT physical delete — prereq xlang-x-pipeline + thin edges + B2 + mk lists remain.
# Honesty COUNT = 1 phony.
PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL=1
PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_WAVE=wave842
PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_COUNT=1
PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_VIA=bootstrap_x_compiler_sh_x_e_host_cc_link
PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_NOTE=shell_primary_stage2_emit_cc_link_prereq_graph_remain
SWALLOWED_BOOTSTRAP_X_COMPILER_SHELL=1
BOOTSTRAP_X_COMPILER_SHELL_SWALLOWED=1
BOOTSTRAP_X_COMPILER_SHELL_HELPER=bootstrap_x_compiler.sh
BOOTSTRAP_X_COMPILER_SHELL_WAVE=wave842
# wave843: bootstrap-self full body → shell (G.7 有则补全).
# Stage1 snapshot + best-effort satellite leaves + host-cc stage2 link (BS_LINK_OBJS
# from Makefile mk expansion) + out_self return-value smoke (exit 42).
# NOT physical delete — prereq bootstrap-driver-seed + thin edges + B2 + mk lists remain.
# Honesty COUNT = 1 phony.
PHYS_DEL_BOOTSTRAP_SELF_SHELL=1
PHYS_DEL_BOOTSTRAP_SELF_SHELL_WAVE=wave843
PHYS_DEL_BOOTSTRAP_SELF_SHELL_COUNT=1
PHYS_DEL_BOOTSTRAP_SELF_SHELL_VIA=bootstrap_self_sh_stage2_link_out_self_smoke
PHYS_DEL_BOOTSTRAP_SELF_SHELL_NOTE=shell_primary_stage2_link_smoke_prereq_graph_remain
SWALLOWED_BOOTSTRAP_SELF_SHELL=1
BOOTSTRAP_SELF_SHELL_SWALLOWED=1
BOOTSTRAP_SELF_SHELL_HELPER=bootstrap_self.sh
BOOTSTRAP_SELF_SHELL_WAVE=wave843
# wave844: bootstrap-parser / bootstrap-parse-file full body → shell (G.7 有则补全).
# Parser.x product -o smoke + dual-path parse fixtures (minimal + expr-chain).
# NOT physical delete — prereq relink-xlang/STD_AND_PANIC_O + thin edges + B2 + mk lists remain.
# Honesty COUNT = 2 phonies.
PHYS_DEL_BOOTSTRAP_PARSER_SMOKE=1
PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_WAVE=wave844
PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_COUNT=2
PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_VIA=bootstrap_parser_smoke_sh_parser_parse_file
PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_NOTE=shell_primary_parser_smoke_prereq_graph_remain
SWALLOWED_BOOTSTRAP_PARSER_SMOKE=1
BOOTSTRAP_PARSER_SMOKE_SWALLOWED=1
BOOTSTRAP_PARSER_SMOKE_HELPER=bootstrap_parser_smoke.sh
BOOTSTRAP_PARSER_SMOKE_WAVE=wave844
# wave845: xlang-x-pipeline full body → shell (G.7 有则补全).
# Multi-make ensure ladder + host-cc link TARGET_x; lists stay mk expansion.
# NOT physical delete — prereq bootstrap-pipeline/migrate + thin edges + B2 + mk lists remain.
# Honesty COUNT = 1 target.
PHYS_DEL_XLANG_X_PIPELINE_SHELL=1
PHYS_DEL_XLANG_X_PIPELINE_SHELL_WAVE=wave845
PHYS_DEL_XLANG_X_PIPELINE_SHELL_COUNT=1
PHYS_DEL_XLANG_X_PIPELINE_SHELL_VIA=xlang_x_pipeline_sh_force_rebuild_link
PHYS_DEL_XLANG_X_PIPELINE_SHELL_NOTE=shell_primary_xlang_x_link_prereq_graph_remain
SWALLOWED_XLANG_X_PIPELINE_SHELL=1
XLANG_X_PIPELINE_SHELL_SWALLOWED=1
XLANG_X_PIPELINE_SHELL_HELPER=xlang_x_pipeline.sh
XLANG_X_PIPELINE_SHELL_WAVE=wave845
# wave846: xlang-x full body → shell (G.7 有则补全).
# Seed gate + host-cc link product binary; lists stay mk expansion.
# NOT physical delete — prereq build-seed-asm-host/DRIVER_SEED_OBJS + thin edges + B2 + mk lists remain.
# Honesty COUNT = 1 target.
PHYS_DEL_XLANG_X_SHELL=1
PHYS_DEL_XLANG_X_SHELL_WAVE=wave846
PHYS_DEL_XLANG_X_SHELL_COUNT=1
PHYS_DEL_XLANG_X_SHELL_VIA=xlang_x_sh_seed_gate_host_cc_link
PHYS_DEL_XLANG_X_SHELL_NOTE=shell_primary_xlang_x_prereq_graph_remain
SWALLOWED_XLANG_X_SHELL=1
XLANG_X_SHELL_SWALLOWED=1
XLANG_X_SHELL_HELPER=xlang_x.sh
XLANG_X_SHELL_WAVE=wave846
# wave847: xlang-no-c-frontend full body → shell (G.7 有则补全).
# Seed gate + host-cc link archaeology binary; lists stay mk expansion.
# NOT physical delete — prereq DRIVER_NO_C_FRONTEND_OBJS + thin edges + B2 + mk lists remain.
# Honesty COUNT = 1 target.
PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL=1
PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_WAVE=wave847
PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_COUNT=1
PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_VIA=xlang_no_c_frontend_sh_seed_gate_host_cc_link
PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_NOTE=shell_primary_no_c_frontend_prereq_graph_remain
SWALLOWED_XLANG_NO_C_FRONTEND_SHELL=1
XLANG_NO_C_FRONTEND_SHELL_SWALLOWED=1
XLANG_NO_C_FRONTEND_SHELL_HELPER=xlang_no_c_frontend.sh
XLANG_NO_C_FRONTEND_SHELL_WAVE=wave847
# wave848: bootstrap-driver-seed-x-frontend full body → shell (G.7 有则补全).
# Host-cc link archaeology $(TARGET)_x_frontend (stage 10.4 experiment; no pipeline_x);
# lists stay mk expansion (DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS + subcmd + libs).
# NOT physical delete — prereq migrate-x-objs/XLANG_C + thin edges + B2 + mk lists remain.
# Honesty COUNT = 1 target.
PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1
PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_WAVE=wave848
PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_COUNT=1
PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_VIA=bootstrap_driver_seed_x_frontend_sh_host_cc_link
PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_NOTE=shell_primary_seed_x_frontend_prereq_graph_remain
SWALLOWED_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1
BOOTSTRAP_SEED_X_FRONTEND_SHELL_SWALLOWED=1
BOOTSTRAP_SEED_X_FRONTEND_SHELL_HELPER=bootstrap_driver_seed_x_frontend.sh
BOOTSTRAP_SEED_X_FRONTEND_SHELL_WAVE=wave848
# wave849: relink-xlang-lexer full body → shell (G.7 有则补全).
# Seed gate + host-cc link product $(TARGET) + sync XLANG_C/bootstrap_xlangc;
# lists stay mk expansion (composites / user_asm / link_picks / subcmd / PIPELINE_LIBS).
# NOT physical delete — prereq lexer_x.o/FILTERED/GLUE + thin edges + B2 + mk lists remain.
# Honesty COUNT = 1 target.
PHYS_DEL_RELINK_XLANG_LEXER_SHELL=1
PHYS_DEL_RELINK_XLANG_LEXER_SHELL_WAVE=wave849
PHYS_DEL_RELINK_XLANG_LEXER_SHELL_COUNT=1
PHYS_DEL_RELINK_XLANG_LEXER_SHELL_VIA=relink_xlang_lexer_sh_seed_gate_host_cc_link_sync
PHYS_DEL_RELINK_XLANG_LEXER_SHELL_NOTE=shell_primary_relink_lexer_prereq_graph_remain
SWALLOWED_RELINK_XLANG_LEXER_SHELL=1
RELINK_XLANG_LEXER_SHELL_SWALLOWED=1
RELINK_XLANG_LEXER_SHELL_HELPER=relink_xlang_lexer.sh
RELINK_XLANG_LEXER_SHELL_WAVE=wave849
# wave816: B7B DRIVER_SUBCMD_* inventory → mk/driver_subcmd_objs.mk (G.7).
# Makefile includes mk only; no dual inline re-list. Catalog parses mk (no
# hardcode). NOT physical delete — thin-call edges + B2 ensure + other mk lists
# remain residual.
PHYS_DEL_B7B_DRIVER_SUBCMD_LIST=1
PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_WAVE=wave816
PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_COUNT=7
PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_VIA=mk_driver_subcmd_objs
PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_DRIVER_SUBCMD_LIST=1
B7B_DRIVER_SUBCMD_LIST_SWALLOWED=1
B7B_DRIVER_SUBCMD_LIST_MK=mk/driver_subcmd_objs.mk
B7B_DRIVER_SUBCMD_LIST_WAVE=wave816
# wave817: B7B PIPELINE_X_* + PIPELINE_LIBS inventory → mk/pipeline_x_objs.mk (G.7).
# Makefile includes mk only; no dual inline re-list. Catalog parses mk (no
# hardcode). NOT physical delete — thin-call edges + B2 ensure + other mk lists
# remain residual. COUNT = PIPELINE_X_SATELLITE_OBJS multi-line inventory (9).
PHYS_DEL_B7B_PIPELINE_X_LIST=1
PHYS_DEL_B7B_PIPELINE_X_LIST_WAVE=wave817
PHYS_DEL_B7B_PIPELINE_X_LIST_COUNT=9
PHYS_DEL_B7B_PIPELINE_X_LIST_VIA=mk_pipeline_x_objs
PHYS_DEL_B7B_PIPELINE_X_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_PIPELINE_X_LIST=1
B7B_PIPELINE_X_LIST_SWALLOWED=1
B7B_PIPELINE_X_LIST_MK=mk/pipeline_x_objs.mk
B7B_PIPELINE_X_LIST_WAVE=wave817
# wave818: B7B DRIVER_SEED mode picks → mk/driver_seed_mode_objs.mk (G.7).
# RUNTIME_O / FRONTEND_EXTRA / SUPPORT_EXTRA / LINK_FLAGS / RUNTIME_REBUILD +
# C_FRONTEND_LEGACY. NOT physical delete — thin edges + other B7B lists remain.
# COUNT = product-default DRIVER_SEED_SUPPORT_EXTRA multi-token inventory (3).
PHYS_DEL_B7B_SEED_MODE_LIST=1
PHYS_DEL_B7B_SEED_MODE_LIST_WAVE=wave818
PHYS_DEL_B7B_SEED_MODE_LIST_COUNT=3
PHYS_DEL_B7B_SEED_MODE_LIST_VIA=mk_driver_seed_mode_objs
PHYS_DEL_B7B_SEED_MODE_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_SEED_MODE_LIST=1
B7B_SEED_MODE_LIST_SWALLOWED=1
B7B_SEED_MODE_LIST_MK=mk/driver_seed_mode_objs.mk
B7B_SEED_MODE_LIST_WAVE=wave818
# wave819: B7B seed link picks → mk/driver_seed_link_picks.mk (G.7).
# MAIN_LINK_O/REBUILD/FLAGS + LEXER/AST + LSP_DIAG + PREPROCESS + GLUE_SUFFIX.
# NOT physical delete — thin edges + other B7B lists remain.
# COUNT = product RELINK_XLANG_GLUE_SUFFIX multi-token inventory (2).
PHYS_DEL_B7B_SEED_LINK_PICKS_LIST=1
PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_WAVE=wave819
PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_COUNT=2
PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_VIA=mk_driver_seed_link_picks
PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_SEED_LINK_PICKS_LIST=1
B7B_SEED_LINK_PICKS_LIST_SWALLOWED=1
B7B_SEED_LINK_PICKS_LIST_MK=mk/driver_seed_link_picks.mk
B7B_SEED_LINK_PICKS_LIST_WAVE=wave819
# wave820: B7B OBJS_CORE archaeology inventory → mk/objs_core.mk (G.7).
# Product incomplete 16 .o + LEGACY C-frontend layout; OBJS alias.
# NOT physical delete — thin edges + other B7B lists remain.
# COUNT = product-default OBJS_CORE multi-token inventory (16).
PHYS_DEL_B7B_OBJS_CORE_LIST=1
PHYS_DEL_B7B_OBJS_CORE_LIST_WAVE=wave820
PHYS_DEL_B7B_OBJS_CORE_LIST_COUNT=16
PHYS_DEL_B7B_OBJS_CORE_LIST_VIA=mk_objs_core
PHYS_DEL_B7B_OBJS_CORE_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_OBJS_CORE_LIST=1
B7B_OBJS_CORE_LIST_SWALLOWED=1
B7B_OBJS_CORE_LIST_MK=mk/objs_core.mk
B7B_OBJS_CORE_LIST_WAVE=wave820
# wave821: B7B archaeology experiment inventories → mk/archaeology_experiment_objs.mk (G.7).
# DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS (fixed 7) + DRIVER_NO_C_FRONTEND_OBJS
# (expands MAIN_LINK/PREPROCESS/AST). NOT physical delete — thin edges + other lists remain.
# COUNT = X_FRONTEND_EXPERIMENT multi-token inventory (7).
PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST=1
PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_WAVE=wave821
PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_COUNT=7
PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_VIA=mk_archaeology_experiment_objs
PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_ARCH_EXPERIMENT_LIST=1
B7B_ARCH_EXPERIMENT_LIST_SWALLOWED=1
B7B_ARCH_EXPERIMENT_LIST_MK=mk/archaeology_experiment_objs.mk
B7B_ARCH_EXPERIMENT_LIST_WAVE=wave821
# wave822: B7B RELINK + LEGACY_XLANG_C inventories → mk/driver_seed_composites.mk (G.7).
# RELINK_XLANG_PREREQS fixed multi-token authority COUNT=14 (13 path .o/.c +
# build-seed-asm-host phony) + LEGACY_XLANG_C_LINK_BASE/USER_ASM_LINK/PREREQS.
# NOT physical delete — thin edges + other lists + std_core graph remain.
PHYS_DEL_B7B_RELINK_LEGACY_LIST=1
PHYS_DEL_B7B_RELINK_LEGACY_LIST_WAVE=wave822
PHYS_DEL_B7B_RELINK_LEGACY_LIST_COUNT=14
PHYS_DEL_B7B_RELINK_LEGACY_LIST_VIA=mk_driver_seed_composites
PHYS_DEL_B7B_RELINK_LEGACY_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_RELINK_LEGACY_LIST=1
B7B_RELINK_LEGACY_LIST_SWALLOWED=1
B7B_RELINK_LEGACY_LIST_MK=mk/driver_seed_composites.mk
B7B_RELINK_LEGACY_LIST_WAVE=wave822
# wave823: B7B source-path inventories → mk/x_source_deps.mk (G.7).
# SRCS (4) + MAIN_X_DEPS (4) + PREPROCESS_X_DEPS (1) + PIPELINE_X_DEPS fixed
# paths (10; excludes $(PIPELINE_ASM_X_DEPS) wildcard token) = COUNT=19.
# NOT physical delete — thin edges + std_core product make graph remain.
PHYS_DEL_B7B_SOURCE_DEPS_LIST=1
PHYS_DEL_B7B_SOURCE_DEPS_LIST_WAVE=wave823
PHYS_DEL_B7B_SOURCE_DEPS_LIST_COUNT=19
PHYS_DEL_B7B_SOURCE_DEPS_LIST_VIA=mk_x_source_deps
PHYS_DEL_B7B_SOURCE_DEPS_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_SOURCE_DEPS_LIST=1
B7B_SOURCE_DEPS_LIST_SWALLOWED=1
B7B_SOURCE_DEPS_LIST_MK=mk/x_source_deps.mk
B7B_SOURCE_DEPS_LIST_WAVE=wave823
# wave824: B7B -E module search root inventories → mk/x_e_dirs.mk (G.7).
# MAIN_X_E_DIRS dir-roots (9) + LSP_X_E_DIRS (8) + PIPELINE_X_E_DIRS (9) =
# COUNT=26 (excludes literal "-L" flag tokens). NOT physical delete —
# thin edges + std_core product make graph remain.
PHYS_DEL_B7B_E_DIRS_LIST=1
PHYS_DEL_B7B_E_DIRS_LIST_WAVE=wave824
PHYS_DEL_B7B_E_DIRS_LIST_COUNT=26
PHYS_DEL_B7B_E_DIRS_LIST_VIA=mk_x_e_dirs
PHYS_DEL_B7B_E_DIRS_LIST_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_E_DIRS_LIST=1
B7B_E_DIRS_LIST_SWALLOWED=1
B7B_E_DIRS_LIST_MK=mk/x_e_dirs.mk
B7B_E_DIRS_LIST_WAVE=wave824
# wave850: B7B product archaeology full link bag → mk/driver_seed_composites.mk (G.7).
# RELINK_PRODUCT_LINK_BASE fixed multi-token authority COUNT=8 + RELINK_PRODUCT_LINK_OBJS
# (GLUE_PREFIX + BASE + USER_ASM + GLUE_SUFFIX). Swallows 3-way dual inventory that
# lived in Makefile BTC_OBJS (typeck/codegen) + RXL_LINK_OBJS (relink-xlang-lexer).
# NOT physical delete — thin edges + B2 + other mk lists remain residual.
PHYS_DEL_B7B_RELINK_PRODUCT_LINK=1
PHYS_DEL_B7B_RELINK_PRODUCT_LINK_WAVE=wave850
PHYS_DEL_B7B_RELINK_PRODUCT_LINK_COUNT=8
PHYS_DEL_B7B_RELINK_PRODUCT_LINK_VIA=mk_driver_seed_composites
PHYS_DEL_B7B_RELINK_PRODUCT_LINK_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_RELINK_PRODUCT_LINK=1
B7B_RELINK_PRODUCT_LINK_SWALLOWED=1
B7B_RELINK_PRODUCT_LINK_MK=mk/driver_seed_composites.mk
B7B_RELINK_PRODUCT_LINK_WAVE=wave850
# wave851: B7B remaining product-shaped archaeology full link bags (G.7).
# XXL (xlang-x) + BS (bootstrap-self stage2) → mk/driver_seed_composites.mk
#   XLANG_X_LINK_BASE/OBJS + BOOTSTRAP_SELF_LINK_OBJS
# XNC (xlang-no-c-frontend) → mk/archaeology_experiment_objs.mk
#   XLANG_NO_C_FRONTEND_LINK_OBJS
# COUNT=3 bags (XXL + BS + XNC). XLANG_X_LINK_BASE fixed multi-token 8;
# XLANG_NO_C fixed multi-token 9; BS expands DRIVER_SEED_LINK_BASE (no re-list).
# NOT physical delete — thin edges + B2 + other mk lists remain residual.
PHYS_DEL_B7B_XXL_BS_XNC_LINK=1
PHYS_DEL_B7B_XXL_BS_XNC_LINK_WAVE=wave851
PHYS_DEL_B7B_XXL_BS_XNC_LINK_COUNT=3
PHYS_DEL_B7B_XXL_BS_XNC_LINK_VIA=mk_composites_plus_archaeology_experiment
PHYS_DEL_B7B_XXL_BS_XNC_LINK_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_XXL_BS_XNC_LINK=1
B7B_XXL_BS_XNC_LINK_SWALLOWED=1
B7B_XXL_BS_XNC_LINK_MK=mk/driver_seed_composites.mk+mk/archaeology_experiment_objs.mk
B7B_XXL_BS_XNC_LINK_WAVE=wave851
# wave852: B7B BXF (bootstrap-driver-seed-x-frontend) full link bag (G.7).
# DRIVER_SEED_X_FRONTEND_LINK_OBJS → mk/archaeology_experiment_objs.mk
# Fixed multi-token authority COUNT=2 (driver + preprocess satellites beyond experiment base).
# NOT physical delete — thin edges + B2 + other mk lists remain residual.
PHYS_DEL_B7B_BXF_LINK=1
PHYS_DEL_B7B_BXF_LINK_WAVE=wave852
PHYS_DEL_B7B_BXF_LINK_COUNT=2
PHYS_DEL_B7B_BXF_LINK_VIA=mk_archaeology_experiment_objs
PHYS_DEL_B7B_BXF_LINK_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_BXF_LINK=1
B7B_BXF_LINK_SWALLOWED=1
B7B_BXF_LINK_MK=mk/archaeology_experiment_objs.mk
B7B_BXF_LINK_WAVE=wave852
# wave853: B7B seed phase1/final full link bags (G.7).
# BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS + FINAL_LINK_OBJS → mk/driver_seed_composites.mk
# COUNT=2 bags (phase1 + final SEED_LINK_OBJS export). Phase1 has one fixed multi-token
# path (seed_host partial); final is all $(...) expands. Glue = RELINK_XLANG_GLUE_SUFFIX.
# NOT physical delete — thin edges + B2 + other mk lists remain residual.
PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK=1
PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_WAVE=wave853
PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_COUNT=2
PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_VIA=mk_driver_seed_composites
PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_SEED_PHASE_FINAL_LINK=1
B7B_SEED_PHASE_FINAL_LINK_SWALLOWED=1
B7B_SEED_PHASE_FINAL_LINK_MK=mk/driver_seed_composites.mk
B7B_SEED_PHASE_FINAL_LINK_WAVE=wave853
# wave854: B7B product archaeology seed-gate REQUIRED_OBJS bags (G.7).
# RELINK_XLANG_REQUIRED_OBJS (RXL) + XLANG_X_REQUIRED_OBJS (XXL) → composites.mk
# XLANG_NO_C_FRONTEND_REQUIRED_OBJS (XNC) → archaeology_experiment_objs.mk
# COUNT=3 bags. Fixed multi-token: RXL=6 · XXL=12 · XNC=3 (all path tokens).
# NOT physical delete — thin edges + B2 + other mk lists remain residual.
PHYS_DEL_B7B_SEED_GATE_REQUIRED=1
PHYS_DEL_B7B_SEED_GATE_REQUIRED_WAVE=wave854
PHYS_DEL_B7B_SEED_GATE_REQUIRED_COUNT=3
PHYS_DEL_B7B_SEED_GATE_REQUIRED_VIA=mk_composites_plus_archaeology_experiment
PHYS_DEL_B7B_SEED_GATE_REQUIRED_NOTE=list_authority_mk_include_only_thin_edges_remain
SWALLOWED_B7B_SEED_GATE_REQUIRED=1
B7B_SEED_GATE_REQUIRED_SWALLOWED=1
B7B_SEED_GATE_REQUIRED_MK=mk/driver_seed_composites.mk+mk/archaeology_experiment_objs.mk
B7B_SEED_GATE_REQUIRED_WAVE=wave854
# wave855: seed-gate REQUIRED bags shell-load from mk (G.7 有则补全).
# RXL/XXL/XNC product archaeology shells parse fixed multi-token keys from
# composites + archaeology_experiment mk; Makefile drops multi-token
# RXL/XXL/XNC_REQUIRED_OBJS env export (make export escape). COUNT=3 shells.
# NOT physical delete — LINK env export + thin edges + B2 + other mk lists remain.
PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1
PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_WAVE=wave855
PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_COUNT=3
PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_VIA=relink_xlang_lexer+xlang_x+xlang_no_c_frontend_mk_load
PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_NOTE=shell_loads_mk_makefile_no_required_env_export_thin_edges_remain
SWALLOWED_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1
B7B_SEED_GATE_REQUIRED_SHELL_LOAD_SWALLOWED=1
B7B_SEED_GATE_REQUIRED_SHELL_LOAD_WAVE=wave855
# wave856: archaeology LINK_OBJS shell-load via make export leaves (G.7 有则补全).
# 5 bags (RXL/BTC share RELINK_PRODUCT); 6 shells; make expand nested bags.
PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD=1
PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_WAVE=wave856
PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_COUNT=5
PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_VIA=export_relink_product+xlang_x+xnc+bxf+bs_link_objs
PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_NOTE=shell_loads_make_export_leaf_makefile_no_link_objs_env_export_cflags_wave857
SWALLOWED_B7B_LINK_OBJS_SHELL_LOAD=1
B7B_LINK_OBJS_SHELL_LOAD_SWALLOWED=1
B7B_LINK_OBJS_SHELL_LOAD_WAVE=wave856
B7B_LINK_OBJS_SHELL_LOAD_BAGS=5
B7B_LINK_OBJS_SHELL_LOAD_SHELLS=6
# wave857: archaeology LINK_CFLAGS shell-load via make export leaves (G.7 有则补全).
# 4 formulas (RXL/XXL/BTC-codegen share product; XNC/BS share xnc); 6 shells.
PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD=1
PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_WAVE=wave857
PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_COUNT=4
PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_VIA=export_relink_product+btc_typeck+xnc+bxf_link_cflags
PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_NOTE=shell_loads_make_export_leaf_makefile_no_link_cflags_env_export_thin_edges_remain
SWALLOWED_B7B_LINK_CFLAGS_SHELL_LOAD=1
B7B_LINK_CFLAGS_SHELL_LOAD_SWALLOWED=1
B7B_LINK_CFLAGS_SHELL_LOAD_WAVE=wave857
B7B_LINK_CFLAGS_SHELL_LOAD_BAGS=4
B7B_LINK_CFLAGS_SHELL_LOAD_SHELLS=6
# wave858: LEGACY xlang-c archaeology host-cc link → shell-primary (G.7).
# Lists stay mk (wave822); shell loads LINK_OBJS export leaf; CFLAGS reuses product.
PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1
PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_WAVE=wave858
PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_COUNT=1
PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_VIA=legacy_xlang_c_link_sh+export_legacy_link_objs+reuse_relink_product_cflags
PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_NOTE=makefile_no_dual_cc_legacy_link_body_thin_edges_remain
SWALLOWED_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1
B7B_LEGACY_XLANG_C_SHELL_PRIMARY_SWALLOWED=1
B7B_LEGACY_XLANG_C_SHELL_PRIMARY_WAVE=wave858
B7B_LEGACY_XLANG_C_SHELL_PRIMARY_SCRIPT=compiler/scripts/legacy_xlang_c_link.sh
# wave859: XXP (xlang-x-pipeline) + BXC (bootstrap-x-compiler) multi-token bags
# shell-load via make export leaves (G.7 有则补全 on wave856 export-leaf pattern).
PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD=1
PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_WAVE=wave859
PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_COUNT=2
PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_VIA=export_xxp_link_bags+export_bxc_link_objs
PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_NOTE=shell_loads_make_export_leaf_makefile_no_xxp_bxc_env_export_thin_edges_remain
SWALLOWED_B7B_XXP_BXC_SHELL_LOAD=1
B7B_XXP_BXC_SHELL_LOAD_SWALLOWED=1
B7B_XXP_BXC_SHELL_LOAD_WAVE=wave859
B7B_XXP_BXC_SHELL_LOAD_BAGS=2
B7B_XXP_BXC_SHELL_LOAD_SHELLS=2
# wave860: driver_leaf BASE_CFLAGS multi-token shell-load via make export leaf (G.7).
# 8 product leaves; composition needs make (OPT CFLAGS + PIPELINE_GEN clang ifeq).
PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1
PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_WAVE=wave860
PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_COUNT=8
PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_VIA=export_driver_leaf_base_cflags
PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_NOTE=shell_loads_make_export_leaf_makefile_no_base_cflags_env_thin_edges_remain
SWALLOWED_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1
B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_SWALLOWED=1
B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_WAVE=wave860
B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_COUNT=8
# wave861: RT_SEED_SLICE multi-token -I CFLAGS hygiene (G.7).
# 5 leaves; CFLAGS ?= / shell BASE_CFLAGS already include -I.; dual bag retired.
PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1
PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_WAVE=wave861
PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_COUNT=5
PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_VIA=plain_cflags_try_heat
PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_NOTE=makefile_rt_slice_no_multi_token_I_bag_product_I_in_cflags_thin_edges_remain
SWALLOWED_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1
B7B_RT_SLICE_I_CFLAGS_HYGIENE_SWALLOWED=1
B7B_RT_SLICE_I_CFLAGS_HYGIENE_WAVE=wave861
B7B_RT_SLICE_I_CFLAGS_HYGIENE_COUNT=5
# wave862: try-heat CFLAGS bulk shell-load via export-try-heat-cflags (G.7).
# COUNT = try-heat thin-call recipes that drop multi-token CFLAGS/PIPELINE inject.
PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1
PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_WAVE=wave862
PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_COUNT=114
PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_VIA=export_try_heat_cflags
PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_NOTE=shell_loads_make_export_leaf_makefile_try_heat_no_cflags_env_thin_edges_remain
SWALLOWED_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1
B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_SWALLOWED=1
B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_WAVE=wave862
B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_COUNT=114
# wave863: class-G filter CFLAGS bulk shell-load hygiene (G.7).
# COUNT = filter FORCE recipes that drop multi-token CFLAGS/PIPELINE inject.
PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD=1
PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_WAVE=wave863
PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_COUNT=4
PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_VIA=filter_try_heat_cc_only_export_try_heat_cflags
PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_NOTE=makefile_filter_no_cflags_env_scripts_cc_only_try_heat_shell_load_thin_edges_remain
SWALLOWED_B7B_FILTER_CFLAGS_SHELL_LOAD=1
B7B_FILTER_CFLAGS_SHELL_LOAD_SWALLOWED=1
B7B_FILTER_CFLAGS_SHELL_LOAD_WAVE=wave863
B7B_FILTER_CFLAGS_SHELL_LOAD_COUNT=4
# wave864: leaf-extra RUNTIME_*/PARSER_* multi-token CFLAGS inject hygiene (G.7).
# COUNT = product try-heat recipes that drop multi-token leaf-extra flag inject.
PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1
PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_WAVE=wave864
PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_COUNT=3
PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_VIA=ensure_shell_defaults_no_recipe_inject
PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_NOTE=makefile_no_runtime_pipeline_abi_no_c_parser_thin_glue_cflags_env_shell_defaults_thin_edges_remain
SWALLOWED_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1
B7B_LEAF_EXTRA_CFLAGS_HYGIENE_SWALLOWED=1
B7B_LEAF_EXTRA_CFLAGS_HYGIENE_WAVE=wave864
B7B_LEAF_EXTRA_CFLAGS_HYGIENE_COUNT=3
# wave865: migrate/bootstrap multi-token CFLAGS shell-load via export-try-heat-cflags (G.7).
# COUNT = recipes that drop multi-token CFLAGS="$(CFLAGS)" (migrate 4 + BTC 2 + XXP/BXC 2).
PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD=1
PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_WAVE=wave865
PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_COUNT=8
PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_VIA=export_try_heat_cflags_migrate_xxp_bxc_btc
PHYS_DEL_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_NOTE=makefile_no_cflags_env_on_migrate_bootstrap_shells_load_export_leaf_thin_edges_remain
SWALLOWED_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD=1
B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_SWALLOWED=1
B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_WAVE=wave865
B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD_COUNT=8
# wave866: build-tool CFLAGS shell-load + WIN32_O_CFLAGS leaf drop (G.7).
# COUNT = recipes that drop multi-token inject (build-tool 1 + crt0_mingw 1).
PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE=1
PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_WAVE=wave866
PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_COUNT=2
PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_VIA=export_try_heat_cflags_build_tool_win32_empty_default
PHYS_DEL_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_NOTE=makefile_no_cflags_env_on_build_tool_no_win32_o_cflags_on_crt0_mingw_shell_load_export_leaf_thin_edges_remain
SWALLOWED_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE=1
B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_SWALLOWED=1
B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_WAVE=wave866
B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE_COUNT=2
# wave867: archaeology host-pick LD_R_MULTIDEF_FLAGS leaf drop (G.7 hygiene).
# COUNT = 4 FORCE phonies that drop multi-token LD_R_MULTIDEF_FLAGS inject.
# Shell arch_ld_r_multidef_flags uname default is authority when env unset.
PHYS_DEL_B7B_ARCH_HOST_PICK_LD_R_HYGIENE=1
PHYS_DEL_B7B_ARCH_HOST_PICK_LD_R_HYGIENE_WAVE=wave867
PHYS_DEL_B7B_ARCH_HOST_PICK_LD_R_HYGIENE_COUNT=4
PHYS_DEL_B7B_ARCH_HOST_PICK_LD_R_HYGIENE_VIA=arch_ld_r_multidef_flags_uname_default
PHYS_DEL_B7B_ARCH_HOST_PICK_LD_R_HYGIENE_NOTE=makefile_no_ld_r_multidef_env_on_archaeology_host_pick_shell_uname_default_thin_edges_remain
SWALLOWED_B7B_ARCH_HOST_PICK_LD_R_HYGIENE=1
B7B_ARCH_HOST_PICK_LD_R_HYGIENE_SWALLOWED=1
B7B_ARCH_HOST_PICK_LD_R_HYGIENE_WAVE=wave867
B7B_ARCH_HOST_PICK_LD_R_HYGIENE_COUNT=4
# wave868: bootstrap-driver-bstrict-relink shell-primary (G.7 有则补全).
# COUNT = 1 phony; dual Makefile body → relink_xlang_asm_bstrict_runtime_objs.sh.
PHYS_DEL_BSTRICT_RELINK_SHELL=1
PHYS_DEL_BSTRICT_RELINK_SHELL_WAVE=wave868
PHYS_DEL_BSTRICT_RELINK_SHELL_COUNT=1
PHYS_DEL_BSTRICT_RELINK_SHELL_VIA=relink_xlang_asm_bstrict_runtime_objs_sh
PHYS_DEL_BSTRICT_RELINK_SHELL_NOTE=shell_primary_prereq_gate_xlang_asm_flags_build_xlang_asm_thin_edges_remain
SWALLOWED_BSTRICT_RELINK_SHELL=1
BSTRICT_RELINK_SHELL_SWALLOWED=1
BSTRICT_RELINK_SHELL_WAVE=wave868
BSTRICT_RELINK_SHELL_COUNT=1
BSTRICT_RELINK_SHELL_HELPER=relink_xlang_asm_bstrict_runtime_objs.sh
# wave869: bootstrap-driver-crt0 shell-primary (G.7 有则补全).
# COUNT = 1 phony; dual Makefile body → bootstrap_driver_crt0.sh.
PHYS_DEL_CRT0_SHELL=1
PHYS_DEL_CRT0_SHELL_WAVE=wave869
PHYS_DEL_CRT0_SHELL_COUNT=1
PHYS_DEL_CRT0_SHELL_VIA=bootstrap_driver_crt0_sh
PHYS_DEL_CRT0_SHELL_NOTE=shell_primary_build_xlang_asm_crt0_log_gates_thin_edges_remain
SWALLOWED_CRT0_SHELL=1
CRT0_SHELL_SWALLOWED=1
CRT0_SHELL_WAVE=wave869
CRT0_SHELL_COUNT=1
CRT0_SHELL_HELPER=bootstrap_driver_crt0.sh
# wave870: check-7.2 shell-primary (G.7 有则补全).
# COUNT = 1 phony; dual Makefile body → check_7_2.sh (seed stages; ≠ bstrict path).
PHYS_DEL_CHECK_7_2_SHELL=1
PHYS_DEL_CHECK_7_2_SHELL_WAVE=wave870
PHYS_DEL_CHECK_7_2_SHELL_COUNT=1
PHYS_DEL_CHECK_7_2_SHELL_VIA=check_7_2_sh
PHYS_DEL_CHECK_7_2_SHELL_NOTE=shell_primary_seed_stage1_stage2_smoke_suite_thin_edges_remain
SWALLOWED_CHECK_7_2_SHELL=1
CHECK_7_2_SHELL_SWALLOWED=1
CHECK_7_2_SHELL_WAVE=wave870
CHECK_7_2_SHELL_COUNT=1
CHECK_7_2_SHELL_HELPER=check_7_2.sh
# wave871: check-6.4 shell-primary (G.7 有则补全).
# COUNT = 1 phony; dual Makefile body → check_6_4.sh (seed emit-C + host-cc + exit 42).
PHYS_DEL_CHECK_6_4_SHELL=1
PHYS_DEL_CHECK_6_4_SHELL_WAVE=wave871
PHYS_DEL_CHECK_6_4_SHELL_COUNT=1
PHYS_DEL_CHECK_6_4_SHELL_VIA=check_6_4_sh
PHYS_DEL_CHECK_6_4_SHELL_NOTE=shell_primary_seed_emit_c_host_cc_exit_42_thin_edges_remain
SWALLOWED_CHECK_6_4_SHELL=1
CHECK_6_4_SHELL_SWALLOWED=1
CHECK_6_4_SHELL_WAVE=wave871
CHECK_6_4_SHELL_COUNT=1
CHECK_6_4_SHELL_HELPER=check_6_4.sh
# wave872: bootstrap-driver-hybrid shell-primary (G.7 有则补全).
# COUNT = 1 phony (+ alias bootstrap-driver-asm); dual Makefile body → bootstrap_driver_hybrid.sh.
PHYS_DEL_HYBRID_SHELL=1
PHYS_DEL_HYBRID_SHELL_WAVE=wave872
PHYS_DEL_HYBRID_SHELL_COUNT=1
PHYS_DEL_HYBRID_SHELL_VIA=bootstrap_driver_hybrid_sh
PHYS_DEL_HYBRID_SHELL_NOTE=shell_primary_b_hybrid_build_xlang_asm_replace_soft_skip_thin_edges_remain
SWALLOWED_HYBRID_SHELL=1
HYBRID_SHELL_SWALLOWED=1
HYBRID_SHELL_WAVE=wave872
HYBRID_SHELL_COUNT=1
HYBRID_SHELL_HELPER=bootstrap_driver_hybrid.sh
# wave873: regen-lsp-gens-x shell-primary (G.7 有则补全).
# COUNT = 1 phony; dual Makefile body → regen_lsp_gens_x.sh (gate + rm + make gens).
PHYS_DEL_REGEN_LSP_SHELL=1
PHYS_DEL_REGEN_LSP_SHELL_WAVE=wave873
PHYS_DEL_REGEN_LSP_SHELL_COUNT=1
PHYS_DEL_REGEN_LSP_SHELL_VIA=regen_lsp_gens_x_sh
PHYS_DEL_REGEN_LSP_SHELL_NOTE=shell_primary_xlang_x_gate_rm_four_gens_make_file_targets_thin_edges_remain
SWALLOWED_REGEN_LSP_SHELL=1
REGEN_LSP_SHELL_SWALLOWED=1
REGEN_LSP_SHELL_WAVE=wave873
REGEN_LSP_SHELL_COUNT=1
REGEN_LSP_SHELL_HELPER=regen_lsp_gens_x.sh
# wave874: build-via-tool shell-primary (G.7 有则补全).
# COUNT = 1 phony; dual Makefile body + xlang-build run_build_tool → build_via_tool.sh.
PHYS_DEL_BUILD_VIA_TOOL_SHELL=1
PHYS_DEL_BUILD_VIA_TOOL_SHELL_WAVE=wave874
PHYS_DEL_BUILD_VIA_TOOL_SHELL_COUNT=1
PHYS_DEL_BUILD_VIA_TOOL_SHELL_VIA=build_via_tool_sh
PHYS_DEL_BUILD_VIA_TOOL_SHELL_NOTE=shell_primary_run_build_tool_product_ok_thin_edges_remain
SWALLOWED_BUILD_VIA_TOOL_SHELL=1
BUILD_VIA_TOOL_SHELL_SWALLOWED=1
BUILD_VIA_TOOL_SHELL_WAVE=wave874
BUILD_VIA_TOOL_SHELL_COUNT=1
BUILD_VIA_TOOL_SHELL_HELPER=build_via_tool.sh
# wave875: size-baseline + perf-baseline shell-primary (G.7 有则补全).
# COUNT = 2 phonies; dual Makefile if/chmod/XLANG → stage8_baseline.sh;
# measurement authority stays tests/run-{size,perf}-baseline.sh.
PHYS_DEL_STAGE8_BASELINE_SHELL=1
PHYS_DEL_STAGE8_BASELINE_SHELL_WAVE=wave875
PHYS_DEL_STAGE8_BASELINE_SHELL_COUNT=2
PHYS_DEL_STAGE8_BASELINE_SHELL_VIA=stage8_baseline_sh
PHYS_DEL_STAGE8_BASELINE_SHELL_NOTE=shell_primary_size_perf_dispatch_tests_scripts_thin_edges_remain
SWALLOWED_STAGE8_BASELINE_SHELL=1
STAGE8_BASELINE_SHELL_SWALLOWED=1
STAGE8_BASELINE_SHELL_WAVE=wave875
STAGE8_BASELINE_SHELL_COUNT=2
STAGE8_BASELINE_SHELL_HELPER=stage8_baseline.sh
# wave876: default $(XLANG_C) product alias shell-primary (G.7 无才新增).
# COUNT = 1 target; dual Makefile if/cp SKIP_SUBSCRIPT → ensure_xlang_c.sh;
# LEGACY host-cc path remains legacy_xlang_c_link.sh (wave858).
PHYS_DEL_XLANG_C_ALIAS_SHELL=1
PHYS_DEL_XLANG_C_ALIAS_SHELL_WAVE=wave876
PHYS_DEL_XLANG_C_ALIAS_SHELL_COUNT=1
PHYS_DEL_XLANG_C_ALIAS_SHELL_VIA=ensure_xlang_c_sh
PHYS_DEL_XLANG_C_ALIAS_SHELL_NOTE=shell_primary_default_xlang_c_cp_skip_gate_thin_edges_remain
SWALLOWED_XLANG_C_ALIAS_SHELL=1
XLANG_C_ALIAS_SHELL_SWALLOWED=1
XLANG_C_ALIAS_SHELL_WAVE=wave876
XLANG_C_ALIAS_SHELL_COUNT=1
XLANG_C_ALIAS_SHELL_HELPER=ensure_xlang_c.sh
# wave877: B7B gen ensure multi-token MAKE/XLANG_*/FORCE/TIMEOUT inject hygiene.
# COUNT = 20 recipes (migrate 4 + ast_gen2 1 + lsp/pipeline 4 + archaeology 8 +
# driver 2 + bootstrap-pipeline 1); shell defaults own env; thin @bash only.
PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE=1
PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_WAVE=wave877
PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_COUNT=20
PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_VIA=ensure_shell_defaults_no_recipe_inject
PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_NOTE=makefile_no_make_xlang_force_timeout_inject_on_ensure_gen_shell_defaults_thin_edges_remain
SWALLOWED_B7B_GEN_ENSURE_ENV_HYGIENE=1
B7B_GEN_ENSURE_ENV_HYGIENE_SWALLOWED=1
B7B_GEN_ENSURE_ENV_HYGIENE_WAVE=wave877
B7B_GEN_ENSURE_ENV_HYGIENE_COUNT=20
# wave878: B7B migrate_x_objs multi-token CC/PYTHON/MAKE inject hygiene.
# COUNT = 4 recipes (parser/typeck/codegen migrate leaves + migrate-x-objs phony);
# shell defaults own CC/PYTHON/MAKE; thin @sh only.
PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE=1
PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_WAVE=wave878
PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_COUNT=4
PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_VIA=migrate_shell_defaults_no_recipe_inject
PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_NOTE=makefile_no_cc_python_make_inject_on_migrate_x_objs_shell_defaults_thin_edges_remain
SWALLOWED_B7B_MIGRATE_ENV_HYGIENE=1
B7B_MIGRATE_ENV_HYGIENE_SWALLOWED=1
B7B_MIGRATE_ENV_HYGIENE_WAVE=wave878
B7B_MIGRATE_ENV_HYGIENE_COUNT=4
# wave879: B7B stage/bootstrap multi-token TARGET/CC/MAKE inject hygiene.
# COUNT = 13 recipes (clean + typeck/codegen + seed final/seed + relink-lexer +
# regen-lsp + xlang-x + check-6.4 + build-tool + self + pipeline + x-compiler);
# shell defaults own TARGET/CC/MAKE/XLANG_*/PYTHON; thin @sh/@bash only.
PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1
PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_WAVE=wave879
PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_COUNT=13
PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_VIA=stage_bootstrap_shell_defaults_no_recipe_inject
PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_NOTE=makefile_no_target_cc_make_inject_on_stage_bootstrap_shells_defaults_thin_edges_remain
SWALLOWED_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1
B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_SWALLOWED=1
B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_WAVE=wave879
B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_COUNT=13
# wave880: B7B ENSURE=0 / OUT=$@ / all OPT multi-token inject hygiene.
# COUNT = 7 recipes (all + test_c + test_x + seed-x-frontend + legacy xlang-c +
# xlang-no-c-frontend + check-7.2-bstrict); MAKELEVEL shell defaults own
# ENSURE/OPT; OUT defaults own archaeology link outs; thin @bash/@sh only.
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE=1
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_WAVE=wave880
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_COUNT=7
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_VIA=makelevel_shell_defaults_no_recipe_inject
PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_NOTE=makefile_no_ensure0_out_all_opt_inject_shell_makelevel_defaults_thin_edges_remain
SWALLOWED_B7B_ENSURE_OUT_OPT_HYGIENE=1
B7B_ENSURE_OUT_OPT_HYGIENE_SWALLOWED=1
B7B_ENSURE_OUT_OPT_HYGIENE_WAVE=wave880
B7B_ENSURE_OUT_OPT_HYGIENE_COUNT=7
# wave881: B7B try-heat XLANG_G05_PREFER_X_O (+ XLANG= on one net leaf) inject hygiene.
# COUNT = 31 try-heat recipes that still injected PREFER (and 1× XLANG=) beside
# CC=; drop to CC-only thin-call (wave862/864 intentional shape).
# GNU make auto-exports CLI/env PREFER (cold rebuild: make XLANG_G05_PREFER_X_O=0);
# shell prefer="${XLANG_G05_PREFER_X_O:-0|1}" owns defaults when unset.
# NOT physical delete — CC= passthrough + thin edges + B2 + mk lists remain.
PHYS_DEL_B7B_PREFER_INJECT_HYGIENE=1
PHYS_DEL_B7B_PREFER_INJECT_HYGIENE_WAVE=wave881
PHYS_DEL_B7B_PREFER_INJECT_HYGIENE_COUNT=31
PHYS_DEL_B7B_PREFER_INJECT_HYGIENE_VIA=try_heat_cc_only_prefer_cli_env_shell_default
PHYS_DEL_B7B_PREFER_INJECT_HYGIENE_NOTE=makefile_no_prefer_x_o_or_xlang_inject_on_try_heat_cc_only_thin_edges_remain
SWALLOWED_B7B_PREFER_INJECT_HYGIENE=1
B7B_PREFER_INJECT_HYGIENE_SWALLOWED=1
B7B_PREFER_INJECT_HYGIENE_WAVE=wave881
B7B_PREFER_INJECT_HYGIENE_COUNT=31
# wave882: B7B residual single-token TARGET= inject hygiene.
# COUNT = 10 recipes: 8 pure TARGET-only thin-calls (token/lexer/parser/parse-file /
# hybrid/crt0/build-via-tool/check-7.2) + 2 multi-token (bstrict/refresh) drop TARGET=.
# Shell TARGET="${TARGET:-xlang}" + GNU make CLI auto-export own authority (G.7).
# Keep MAKE= / ENSURE_SEED=0 / NO_REPLACE passthrough where still required.
# NOT physical delete — MAKE residual + CC= passthrough + thin edges + B2 remain.
PHYS_DEL_B7B_TARGET_INJECT_HYGIENE=1
PHYS_DEL_B7B_TARGET_INJECT_HYGIENE_WAVE=wave882
PHYS_DEL_B7B_TARGET_INJECT_HYGIENE_COUNT=10
PHYS_DEL_B7B_TARGET_INJECT_HYGIENE_VIA=shell_target_default_cli_autoexport_no_recipe_inject
PHYS_DEL_B7B_TARGET_INJECT_HYGIENE_NOTE=makefile_no_target_inject_on_smoke_hybrid_crt0_tool_check72_bstrict_refresh_shell_defaults_thin_edges_remain
SWALLOWED_B7B_TARGET_INJECT_HYGIENE=1
B7B_TARGET_INJECT_HYGIENE_SWALLOWED=1
B7B_TARGET_INJECT_HYGIENE_WAVE=wave882
B7B_TARGET_INJECT_HYGIENE_COUNT=10
# B3: ~~LSP satellite hybrid body~~ wave781 → try-lsp-sat-prefer
#     (Makefile thin-call edges remain; NOT physical delete)
PHYS_DEL_BUCKET_B3=lsp_satellite_hybrid
PHYS_DEL_BUCKET_B3_SCOPE=lsp_diag_pipeline_sizes_nostub+lsp_diag_stubs_no_c_thin_call
PHYS_DEL_BUCKET_B3_HEAT_TARGETS=2
PHYS_DEL_BUCKET_B3_BODY_SWALLOWED=1
SWALLOWED_B3_LSP_SAT_PREFER=1
B3_LSP_SAT_PREFER_SWALLOWED=1
B3_LSP_SAT_PREFER_HELPER=try-lsp-sat-prefer
B3_LSP_SAT_PREFER_WAVE=wave781
# B4: ~~gen.c → .o bootstrap body~~ wave782 → try-gen-c-to-o
#     (Makefile thin-call edges remain; NOT physical delete)
PHYS_DEL_BUCKET_B4=gen_c_to_o_bootstrap
PHYS_DEL_BUCKET_B4_SCOPE=lexer_x+ast_gen2+driver_x+preprocess_x+_x_stubs2_thin_call
PHYS_DEL_BUCKET_B4_HEAT_TARGETS=5
PHYS_DEL_BUCKET_B4_BODY_SWALLOWED=1
SWALLOWED_B4_GEN_C_TO_O=1
B4_GEN_C_TO_O_SWALLOWED=1
B4_GEN_C_TO_O_HELPER=try-gen-c-to-o
B4_GEN_C_TO_O_WAVE=wave782
# B5: ~~cfg_eval multi-ladder body~~ wave783 → try-cfg-eval-ladder
#     (Makefile thin-call edge remains; NOT physical delete)
PHYS_DEL_BUCKET_B5=cfg_eval_multi_ladder
PHYS_DEL_BUCKET_B5_SCOPE=src_lexer_cfg_eval_o_thin_call
PHYS_DEL_BUCKET_B5_HEAT_TARGETS=1
PHYS_DEL_BUCKET_B5_BODY_SWALLOWED=1
SWALLOWED_B5_CFG_EVAL_LADDER=1
B5_CFG_EVAL_LADDER_SWALLOWED=1
B5_CFG_EVAL_LADDER_HELPER=try-cfg-eval-ladder
B5_CFG_EVAL_LADDER_WAVE=wave783
# B6: ~~R5 CI / compiler-all body~~ wave784 → compiler_all_ci.sh
#     (Makefile all thin-call; leaf graph still B7; NOT physical delete)
PHYS_DEL_BUCKET_B6=r5_ci_compiler_all
PHYS_DEL_BUCKET_B6_SCOPE=Makefile_all_OPT_seed_xbuild_compiler_all_thin_call
PHYS_DEL_BUCKET_B6_BODY_SWALLOWED=1
SWALLOWED_B6_R5_CI_COMPILER_ALL=1
B6_R5_CI_COMPILER_ALL_SWALLOWED=1
B6_R5_CI_COMPILER_ALL_HELPER=compiler_all_ci.sh
B6_R5_CI_COMPILER_ALL_WAVE=wave784
# B7: Makefile still owns DAG thin-calls + lists (cannot delete until Windows + BC)
# wave785: post B1–B6 honesty inventory + B7c archaeology thin
# wave786: B7D host-cc product link → g05 (NOT physical delete)
# wave787: B7A cold rebuild residual_make=0 honesty + heat thin-edge inventory
# wave788: B7B shell-primary catalog (mk parse; make export escape; NOT physical delete)
# wave789: B7A heat shell auto-dispatch try-heat (NOT physical delete; edges remain)
# wave790: B7A heat Makefile recipes unify → try-heat (mode names collapse; deps remain)
PHYS_DEL_BUCKET_B7=makefile_dag_thin_calls
PHYS_DEL_BUCKET_B7_SCOPE=thin_call_edges+mk_lists+archaeology_phonies+host_cc_link
PHYS_DEL_BUCKET_B7_INVENTORY=1
PHYS_DEL_BUCKET_B7_BODY_SWALLOWED=0
PHYS_DEL_BUCKET_B7_WAVE=wave800
SWALLOWED_B7_DAG_INVENTORY=1
B7_DAG_INVENTORY_SWALLOWED=1
B7_DAG_INVENTORY_NOTE=named_subbuckets_post_B1_B6_leaf_body_clear
# B7 sub-buckets (names only — not a second .o list authority; G.7)
PHYS_DEL_BUCKET_B7A=thin_call_edges_only
PHYS_DEL_BUCKET_B7A_SCOPE=ensure_thin_call_recipe_edges_still_make
# wave787: cold rebuild_leaves seven modes already residual_make=0 (shell only).
# Heat residual was Makefile ensure *source-prereq* edges for `make <obj>` / daily heat.
# wave789: shell try-heat auto-dispatch (prefer→R1→R2→gen) for heat without recipe name.
# wave790: all 115 Makefile ensure *recipes* thin-call try-heat only (G.7 single heat entry);
#          historical try-*/one mode names stay in comments for archaeology / residual greps.
# wave797: source-prereq residual closed (orch last). FORCE+try-heat remain until phys del.
PHYS_DEL_BUCKET_B7A_COLD_0MAKE=1
PHYS_DEL_BUCKET_B7A_COLD_SCOPE=rebuild_leaves_sat_lsp_bridge_panic_user_asm_glue_pipeline_x
# wave797: heat source-prereq edges closed (orch last leaf → FORCE). FORCE+try-heat
# edges remain by design until physical delete of Makefile (Windows gate).
PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=0
PHYS_DEL_BUCKET_B7A_HEAT_SCOPE=source_prereq_dep_edges_closed_force_try_heat_until_phys_del
PHYS_DEL_BUCKET_B7A_HEAT_SHELL_DISPATCH=1
PHYS_DEL_BUCKET_B7A_HEAT_SHELL_DISPATCH_SCOPE=try_heat_prefer_then_r1_r2_gen
PHYS_DEL_BUCKET_B7A_HEAT_THIN_UNIFY=1
PHYS_DEL_BUCKET_B7A_HEAT_THIN_UNIFY_SCOPE=makefile_recipes_try_heat_only
PHYS_DEL_BUCKET_B7A_BODY_SWALLOWED=0
SWALLOWED_B7A_COLD_REBUILD_0MAKE=1
B7A_COLD_REBUILD_0MAKE_SWALLOWED=1
B7A_COLD_REBUILD_0MAKE_VIA=bootstrap_driver_seed_rebuild_leaves
B7A_COLD_REBUILD_0MAKE_WAVE=wave787
SWALLOWED_B7A_HEAT_SHELL_DISPATCH=1
B7A_HEAT_SHELL_DISPATCH_SWALLOWED=1
B7A_HEAT_SHELL_DISPATCH_VIA=ensure_host_cc_seed_o_try_heat
B7A_HEAT_SHELL_DISPATCH_WAVE=wave789
B7A_HEAT_SHELL_DISPATCH_NOTE=makefile_dep_edges_still_residual_not_physical_delete
SWALLOWED_B7A_HEAT_THIN_UNIFY=1
B7A_HEAT_THIN_UNIFY_SWALLOWED=1
B7A_HEAT_THIN_UNIFY_VIA=makefile_try_heat_recipes
B7A_HEAT_THIN_UNIFY_WAVE=wave790
B7A_HEAT_THIN_UNIFY_NOTE=recipe_modes_collapsed_dep_edges_remain
# wave791–797: FORCE + ensure dep-edge thin (pure seed+.x(+.h) · twin · mkflags ·
# cfg_eval multi · pure asm · std · net multi-merge · panic stamp · gen_x/B4 · orch).
# Shell owns freshness. Heat source-prereq residual closed wave797; next = physical
# delete after Windows only (NOT this wave).
PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN=1
PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN_SCOPE=pure_seed_x_h_twin_mkflags_cfg_asm_std_net_panic_gen_x_orch_force_ensure_wave791_797
PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN_COUNT=113
SWALLOWED_B7A_HEAT_DEP_THIN=1
B7A_HEAT_DEP_THIN_SWALLOWED=1
B7A_HEAT_DEP_THIN_VIA=makefile_force_plus_try_heat_shell_mtime_hdr_twin_mkflags_asm_net_gen_x_orch
B7A_HEAT_DEP_THIN_WAVE=wave797
B7A_HEAT_DEP_THIN_NOTE=113_force_thin_leaves_source_prereqs_removed_shell_owns_freshness_orch_closed
PHYS_DEL_BUCKET_B7B=mk_list_authority
PHYS_DEL_BUCKET_B7B_SCOPE=compiler_mk_plus_driver_seed_obj_catalog
# wave787 honesty: lists intentionally stay mk+catalog (G.7 single list).
# wave788: catalog default = shell mk parse (0 make); make export = escape / parity.
PHYS_DEL_BUCKET_B7B_LIST_STAYS_MK=1
PHYS_DEL_BUCKET_B7B_SHELL_CATALOG=1
PHYS_DEL_BUCKET_B7B_MAKE_EXPORT_ESCAPE=1
PHYS_DEL_BUCKET_B7B_BODY_SWALLOWED=0
SWALLOWED_B7B_LIST_AUTHORITY_HONESTY=1
B7B_LIST_AUTHORITY_HONESTY_SWALLOWED=1
B7B_LIST_AUTHORITY_HONESTY_NOTE=lists_stay_mk_catalog_shell_primary_wave788
SWALLOWED_B7B_SHELL_CATALOG=1
B7B_SHELL_CATALOG_SWALLOWED=1
B7B_SHELL_CATALOG_VIA=driver_seed_obj_catalog_shell_mk_parse
B7B_SHELL_CATALOG_WAVE=wave788
B7B_SHELL_CATALOG_NOTE=default_0make_mk_parse_make_export_escape_LEGACY
PHYS_DEL_BUCKET_B7C=archaeology_phony_cc
PHYS_DEL_BUCKET_B7C_SCOPE=bootstrap_typeck_codegen_self_x_compiler_parser_smoke_xlang_x_pipeline_xlang_x_no_c_frontend_seed_x_frontend_relink_xlang_lexer
PHYS_DEL_BUCKET_B7C_ARCHAEOLOGY_CC_THINNED=1
PHYS_DEL_BUCKET_B7C_THINNED_VIA=bootstrap_typeck_codegen_sh+bootstrap_x_compiler_sh+bootstrap_self_sh+bootstrap_parser_smoke_sh+xlang_x_pipeline_sh+xlang_x_sh+xlang_no_c_frontend_sh+bootstrap_driver_seed_x_frontend_sh+relink_xlang_lexer_sh+migrate_x_objs+ensure_gen_x_o_driver_leaf
PHYS_DEL_BUCKET_B7C_THINNED_NOTE=typeck_codegen_shell_wave841_x_compiler_shell_wave842_self_shell_wave843_parser_smoke_wave844_xlang_x_pipeline_wave845_xlang_x_wave846_no_c_frontend_wave847_seed_x_frontend_wave848_relink_lexer_wave849
PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1
PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave849
PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=11
PHYS_DEL_BUCKET_B7D=host_cc_product_link_xlang
PHYS_DEL_BUCKET_B7D_SCOPE=TARGET_default_g05_prepare_and_relink
PHYS_DEL_BUCKET_B7D_BODY_SWALLOWED=1
PHYS_DEL_BUCKET_B7D_SWALLOWED_VIA=g05_prepare_and_relink
PHYS_DEL_BUCKET_B7D_NOTE=default_make_xlang_is_product_g05_escape_OBJS_CORE
SWALLOWED_B7D_HOST_CC_PRODUCT_LINK=1
B7D_HOST_CC_PRODUCT_LINK_SWALLOWED=1
PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave
PHYS_DEL_PREP_FORBIDDEN=claim_physical_delete|dual_o_list_as_authority|delete_makefile_before_windows_green|claim_B7_inventory_is_delete|claim_B7D_is_physical_delete|claim_B7A_cold_0make_is_physical_delete|claim_B7B_honesty_is_list_delete|claim_B7B_shell_catalog_is_physical_delete|claim_B7A_heat_try_heat_is_physical_delete|claim_B7A_heat_dispatch_removes_makefile_edges|claim_B7A_heat_thin_unify_is_physical_delete|claim_try_heat_recipes_remove_dep_edges|claim_B7A_heat_dep_thin_is_physical_delete|claim_all_dep_edges_gone|claim_preflight_is_physical_delete|claim_preflight_is_windows_green|claim_execute_gate_is_physical_delete|claim_execute_gate_is_windows_green|claim_proof_is_status_green|claim_proof_is_physical_delete|auto_flip_leaf_from_proof
# wave778: hard gate — physical delete of compiler/Makefile only AFTER Windows
# hybrid min-gate green (+ PE pure-ld residual owned). Body swallow (B1–B5) keeps
# Makefile thin-call edges; it is NOT physical delete. Never rm Makefile casually.
PHYS_DEL_WINDOWS_GATE=required_before_makefile_delete
PHYS_DEL_WINDOWS_GATE_SCOPE=MSYS2_B_hybrid_min_gate_plus_PE_pure_ld_residual
PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green
PHYS_DEL_WINDOWS_GATE_DOC=analysis/Windows兼容时序-删种子前后.md
PHYS_DEL_WINDOWS_GATE_FORBIDDEN=physical_delete_makefile_before_windows_green
# wave798: preflight readiness only — heat/B1–B6/B7* prep closed; blockers named.
# wave804: Windows min-gate proof tip bb8f07263 + reviewed STATUS apply (ENDGAME stays 0).
PHYS_DEL_PREFLIGHT=1
PHYS_DEL_PREFLIGHT_WAVE=wave798
PHYS_DEL_PREFLIGHT_NOTE=readiness_only_windows_reproven_green_not_physical_delete
PHYS_DEL_PREFLIGHT_HEAT_CLOSED=1
PHYS_DEL_PREFLIGHT_B1_B6_BODY_SWALLOWED=1
PHYS_DEL_PREFLIGHT_B7D_G05=1
PHYS_DEL_PREFLIGHT_B7A_COLD_0MAKE=1
PHYS_DEL_PREFLIGHT_B7B_SHELL_CATALOG=1
PHYS_DEL_PREFLIGHT_FORCE_DEP_THIN=113
# wave811–829: std_x hybrid+catalog+FORCE / formal_mod / STD_AND_PANIC / driver_leaf
# catalog+FORCE / archaeology / DRIVER_SUBCMD / PIPELINE_X / SEED_MODE / SEED_LINK_PICKS /
# OBJS_CORE / ARCH_EXPERIMENT / RELINK_LEGACY / SOURCE_DEPS / E_DIRS / gen.c FORCE thin swallowed;
# blocker name kept (thin edges + B2 ensure + remaining B7B mk lists still form make graph).
PHYS_DEL_PREFLIGHT_BLOCKERS=makefile_thin_call_edges|b7b_lists_in_mk|std_core_product_make_graph
PHYS_DEL_PREFLIGHT_STD_X_HYBRID_BODY_SWALLOWED=1
PHYS_DEL_PREFLIGHT_STD_X_SHELL_PRIMARY=1
PHYS_DEL_PREFLIGHT_STD_X_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_FORMAL_MOD_SHELL_PRIMARY=1
PHYS_DEL_PREFLIGHT_FORMAL_MOD_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_B7B_STD_AND_PANIC_LIST=1
PHYS_DEL_PREFLIGHT_DRIVER_LEAF_SHELL_PRIMARY=1
PHYS_DEL_PREFLIGHT_DRIVER_LEAF_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_GEN_C_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_AST_GEN2_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_SRC_EDGE_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_MIGRATE_X_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_GLUE_TYPES_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_BOOTSTRAP_PIPELINE_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_FILTERED_O_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_CP_ALIAS_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_PIPELINE_GEN_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_BOOTSTRAP_XLANGC_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_PHONY=1
PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_FORCE_THIN=1
PHYS_DEL_PREFLIGHT_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1
PHYS_DEL_PREFLIGHT_BOOTSTRAP_X_COMPILER_SHELL=1
PHYS_DEL_PREFLIGHT_BOOTSTRAP_SELF_SHELL=1
PHYS_DEL_PREFLIGHT_BOOTSTRAP_PARSER_SMOKE=1
PHYS_DEL_PREFLIGHT_XLANG_X_PIPELINE_SHELL=1
PHYS_DEL_PREFLIGHT_XLANG_X_SHELL=1
PHYS_DEL_PREFLIGHT_XLANG_NO_C_FRONTEND_SHELL=1
PHYS_DEL_PREFLIGHT_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1
PHYS_DEL_PREFLIGHT_RELINK_XLANG_LEXER_SHELL=1
PHYS_DEL_PREFLIGHT_B7B_DRIVER_SUBCMD_LIST=1
PHYS_DEL_PREFLIGHT_B7B_PIPELINE_X_LIST=1
PHYS_DEL_PREFLIGHT_B7B_SEED_MODE_LIST=1
PHYS_DEL_PREFLIGHT_B7B_SEED_LINK_PICKS_LIST=1
PHYS_DEL_PREFLIGHT_B7B_OBJS_CORE_LIST=1
PHYS_DEL_PREFLIGHT_B7B_ARCH_EXPERIMENT_LIST=1
PHYS_DEL_PREFLIGHT_B7B_RELINK_LEGACY_LIST=1
PHYS_DEL_PREFLIGHT_B7B_SOURCE_DEPS_LIST=1
PHYS_DEL_PREFLIGHT_B7B_E_DIRS_LIST=1
PHYS_DEL_PREFLIGHT_B7B_RELINK_PRODUCT_LINK=1
PHYS_DEL_PREFLIGHT_B7B_XXL_BS_XNC_LINK=1
PHYS_DEL_PREFLIGHT_B7B_BXF_LINK=1
PHYS_DEL_PREFLIGHT_B7B_SEED_PHASE_FINAL_LINK=1
PHYS_DEL_PREFLIGHT_B7B_SEED_GATE_REQUIRED=1
PHYS_DEL_PREFLIGHT_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_LINK_OBJS_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_LINK_CFLAGS_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1
PHYS_DEL_PREFLIGHT_B7B_XXP_BXC_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1
PHYS_DEL_PREFLIGHT_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_FILTER_CFLAGS_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1
PHYS_DEL_PREFLIGHT_B7B_MIGRATE_BOOTSTRAP_CFLAGS_SHELL_LOAD=1
PHYS_DEL_PREFLIGHT_B7B_BUILD_TOOL_WIN32_CFLAGS_HYGIENE=1
PHYS_DEL_PREFLIGHT_BSTRICT_RELINK_SHELL=1
PHYS_DEL_PREFLIGHT_CRT0_SHELL=1
PHYS_DEL_PREFLIGHT_CHECK_7_2_SHELL=1
PHYS_DEL_PREFLIGHT_CHECK_6_4_SHELL=1
PHYS_DEL_PREFLIGHT_HYBRID_SHELL=1
PHYS_DEL_PREFLIGHT_REGEN_LSP_SHELL=1
PHYS_DEL_PREFLIGHT_BUILD_VIA_TOOL_SHELL=1
PHYS_DEL_PREFLIGHT_STAGE8_BASELINE_SHELL=1
PHYS_DEL_PREFLIGHT_XLANG_C_ALIAS_SHELL=1
PHYS_DEL_PREFLIGHT_B7B_GEN_ENSURE_ENV_HYGIENE=1
PHYS_DEL_PREFLIGHT_B7B_MIGRATE_ENV_HYGIENE=1
PHYS_DEL_PREFLIGHT_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1
PHYS_DEL_PREFLIGHT_B7B_ENSURE_OUT_OPT_HYGIENE=1
PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
PHYS_DEL_PREFLIGHT_FORBIDDEN=claim_preflight_is_physical_delete|claim_tree_arm_is_physical_delete|claim_endgame_1_is_delete|claim_delete_body_preview_is_delete|claim_delete_body_honesty_is_delete|claim_std_x_thin_is_physical_delete|claim_std_x_catalog_is_physical_delete|claim_std_x_force_thin_is_physical_delete|claim_formal_mod_catalog_is_physical_delete|claim_formal_mod_force_thin_is_physical_delete|claim_std_and_panic_list_mk_is_physical_delete|claim_driver_leaf_catalog_is_physical_delete|claim_driver_leaf_force_thin_is_physical_delete|claim_gen_c_force_thin_is_physical_delete|claim_ast_gen2_force_thin_is_physical_delete|claim_src_edge_force_thin_is_physical_delete|claim_migrate_x_force_thin_is_physical_delete|claim_glue_types_force_thin_is_physical_delete|claim_bootstrap_pipeline_force_thin_is_physical_delete|claim_filtered_o_force_thin_is_physical_delete|claim_cp_alias_force_thin_is_physical_delete|claim_pipeline_gen_force_thin_is_physical_delete|claim_bootstrap_xlangc_force_thin_is_physical_delete|claim_arch_host_pick_phony_is_physical_delete|claim_arch_host_pick_force_thin_is_physical_delete|claim_bootstrap_typeck_codegen_shell_is_physical_delete|claim_bootstrap_x_compiler_shell_is_physical_delete|claim_bootstrap_self_shell_is_physical_delete|claim_bootstrap_parser_smoke_is_physical_delete|claim_xlang_x_pipeline_shell_is_physical_delete|claim_xlang_x_shell_is_physical_delete|claim_xlang_no_c_frontend_shell_is_physical_delete|claim_bootstrap_seed_x_frontend_shell_is_physical_delete|claim_relink_xlang_lexer_shell_is_physical_delete|claim_driver_subcmd_list_mk_is_physical_delete|claim_pipeline_x_list_mk_is_physical_delete|claim_seed_mode_list_mk_is_physical_delete|claim_seed_link_picks_list_mk_is_physical_delete|claim_objs_core_list_mk_is_physical_delete|claim_arch_experiment_list_mk_is_physical_delete|claim_relink_legacy_list_mk_is_physical_delete|claim_source_deps_list_mk_is_physical_delete|claim_e_dirs_list_mk_is_physical_delete|claim_relink_product_link_mk_is_physical_delete|claim_xxl_bs_xnc_link_mk_is_physical_delete|claim_bxf_link_mk_is_physical_delete|claim_seed_phase_final_link_mk_is_physical_delete|claim_seed_gate_required_mk_is_physical_delete|claim_seed_gate_required_shell_load_is_physical_delete|rm_makefile_without_confirm_delete_body
PHYS_DEL_PREFLIGHT_WIN_GATE_CMD=tests/run-bootstrap-bstrict-windows-gate.sh
PHYS_DEL_PREFLIGHT_WIN_GATE_HOST=MSYS2_windows-server_dual_boot_reboot_required
PHYS_DEL_PREFLIGHT_WIN_GATE_DOC=analysis/Windows兼容时序-删种子前后.md
# wave799: execute gate — hard-refuse rm Makefile; dry-run inventory; MSYS runbook.
# STATUS may be reproven_green; ENDGAME still 0 → delete still refused.
PHYS_DEL_EXECUTE_GATE=1
PHYS_DEL_EXECUTE_GATE_WAVE=wave799
PHYS_DEL_EXECUTE_GATE_NOTE=refuse_delete_never_rm_body_even_after_endgame_1_not_physical_delete
PHYS_DEL_EXECUTE_GATE_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_EXECUTE_GATE_REFUSES_DELETE=1
PHYS_DEL_EXECUTE_GATE_DELETE_ALLOWED=0
PHYS_DEL_EXECUTE_GATE_WIN_GATE_CMD=tests/run-bootstrap-bstrict-windows-gate.sh
PHYS_DEL_EXECUTE_GATE_NEXT=explicit_user_auth_then_ship_delete_body
PHYS_DEL_EXECUTE_GATE_FORBIDDEN=claim_execute_gate_is_physical_delete|claim_tree_arm_is_physical_delete|claim_endgame_1_is_delete|claim_delete_body_preview_is_delete|claim_delete_body_honesty_is_delete|rm_makefile_without_confirm_delete_body|claim_proof_is_physical_delete|auto_flip_leaf_from_proof
# wave800: Windows min-gate proof stamp harness (evidence only; NOT STATUS green; NOT delete).
# Authority body: phys_del_makefile_gate.sh --run-windows-gate writes stamp; --verify-windows-proof.
PHYS_DEL_WINDOWS_PROOF_HARNESS=1
PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE=wave800
PHYS_DEL_WINDOWS_PROOF_HARNESS_NOTE=evidence_stamp_after_msys_min_gate_not_status_flip
PHYS_DEL_WINDOWS_PROOF_HARNESS_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_WINDOWS_PROOF_DEFAULT_PATH=/tmp/xlang_phys_del_windows_proof.txt
PHYS_DEL_WINDOWS_PROOF_STATUS_FLIP=0
PHYS_DEL_WINDOWS_PROOF_DELETE_ALLOWED=0
PHYS_DEL_WINDOWS_PROOF_NEXT=msys_run_gate_write_stamp_scp_mac_verify_then_status_flip_preview
PHYS_DEL_WINDOWS_PROOF_FORBIDDEN=claim_proof_is_status_green|claim_proof_is_physical_delete|auto_flip_leaf_from_proof|delete_makefile_from_proof_alone
# wave801: STATUS flip prep — proof-gated preview plan only (NOT flip; NOT delete; ENDGAME stays 0).
# Body: phys_del_makefile_gate.sh --status-flip-preview. Apply path is wave802 harness.
PHYS_DEL_STATUS_FLIP_PREP=1
PHYS_DEL_STATUS_FLIP_PREP_WAVE=wave801
PHYS_DEL_STATUS_FLIP_PREP_NOTE=preview_only_after_verified_proof_not_flip_not_delete
PHYS_DEL_STATUS_FLIP_PREP_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_STATUS_FLIP_PREP_APPLIED=0
PHYS_DEL_STATUS_FLIP_PREP_REQUIRES_PROOF=1
PHYS_DEL_STATUS_FLIP_PREP_TARGET_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_PREP_ENDGAME_AFTER_FLIP=0
PHYS_DEL_STATUS_FLIP_PREP_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_PREP_NEXT=msys_proof_then_preview_then_confirm_apply_then_delete_wave
PHYS_DEL_STATUS_FLIP_PREP_FORBIDDEN=auto_edit_leaf|claim_preview_is_flip|claim_preview_is_delete|flip_endgame_with_status|delete_makefile_from_preview
# wave802: STATUS flip apply harness — proof + confirm env; TREE not flipped this tip without human apply.
# Body: phys_del_makefile_gate.sh --status-flip-apply. ENDGAME stays 0; NOT physical delete.
PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1
PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE=wave802
PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_NOTE=proof_and_confirm_gated_leaf_status_edit_not_delete
PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED=1
PHYS_DEL_STATUS_FLIP_APPLY_REQUIRES_PROOF=1
PHYS_DEL_STATUS_FLIP_APPLY_REQUIRES_CONFIRM=1
PHYS_DEL_STATUS_FLIP_APPLY_CONFIRM_ENV=XLANG_PHYS_DEL_STATUS_FLIP_APPLY=APPLY_STATUS_I_UNDERSTAND
PHYS_DEL_STATUS_FLIP_APPLY_TARGET_STATUS=reproven_green
PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME_AFTER=0
PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_APPLY_NEXT=endgame_preview_then_arm_then_delete_separate
PHYS_DEL_STATUS_FLIP_APPLY_FORBIDDEN=apply_without_proof|apply_without_confirm|set_endgame_1|delete_makefile_from_apply|claim_apply_is_physical_delete|auto_flip_from_proof_alone
# wave803: STATUS flip *commit honesty* — inventory + post-apply contract (NOT edit; NOT delete).
# Body: phys_del_makefile_gate.sh --status-flip-commit-honesty. Flip commit co-changes honesty greps.
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NOTE=post_flip_contract_STATUS_reproven_green_ENDGAME_0_not_delete
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_MODE=--status-flip-commit-honesty
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_NEXT=endgame_preview_then_arm_then_delete_separate
PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_FORBIDDEN=claim_honesty_is_flip|claim_honesty_is_delete|set_endgame_1_in_flip_commit|skip_co_change_honesty_greps|delete_makefile_in_flip_commit
# wave805: ENDGAME arm *prep/preview* — STATUS-gated plan only (NOT arm; NOT delete; ENDGAME stays 0).
# Body: phys_del_makefile_gate.sh --endgame-preview. Arm apply harness is wave806.
PHYS_DEL_ENDGAME_PREP=1
PHYS_DEL_ENDGAME_PREP_WAVE=wave805
PHYS_DEL_ENDGAME_PREP_NOTE=preview_only_after_status_reproven_green_not_arm_not_delete
PHYS_DEL_ENDGAME_PREP_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_ENDGAME_PREP_MODE=--endgame-preview
PHYS_DEL_ENDGAME_PREP_APPLIED=0
PHYS_DEL_ENDGAME_PREP_TREE_ARMED=0
PHYS_DEL_ENDGAME_PREP_REQUIRES_STATUS=reproven_green
PHYS_DEL_ENDGAME_PREP_TARGET_ENDGAME=1
PHYS_DEL_ENDGAME_PREP_DELETE_ALLOWED=0
PHYS_DEL_ENDGAME_PREP_NEXT=confirm_endgame_arm_apply_then_tree_arm_then_delete_separate
PHYS_DEL_ENDGAME_PREP_FORBIDDEN=auto_set_endgame_1|claim_preview_is_endgame_arm|claim_preview_is_physical_delete|rm_makefile_from_endgame_preview|mac_only_claim_wave_green
# wave806: ENDGAME arm *apply harness* — STATUS + confirm; temp-leaf harness; NOT physical delete.
# Body: phys_del_makefile_gate.sh --endgame-arm-apply. wave808 reviewed tree arm sets TREE_ARMED=1.
PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS=1
PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS_WAVE=wave806
PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS_NOTE=status_and_confirm_gated_leaf_endgame_edit_not_delete
PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED=1
PHYS_DEL_ENDGAME_ARM_APPLY_REQUIRES_STATUS=reproven_green
PHYS_DEL_ENDGAME_ARM_APPLY_REQUIRES_CONFIRM=1
PHYS_DEL_ENDGAME_ARM_APPLY_CONFIRM_ENV=XLANG_PHYS_DEL_ENDGAME_ARM_APPLY=ARM_ENDGAME_I_UNDERSTAND
PHYS_DEL_ENDGAME_ARM_APPLY_TARGET_ENDGAME=1
PHYS_DEL_ENDGAME_ARM_APPLY_DELETE_ALLOWED=0
PHYS_DEL_ENDGAME_ARM_APPLY_DELETE_BODY=deferred_never_rm_in_execute_gate
PHYS_DEL_ENDGAME_ARM_APPLY_NEXT=confirm_delete_body_separate_wave
PHYS_DEL_ENDGAME_ARM_APPLY_FORBIDDEN=apply_without_status_green|apply_without_confirm|rm_makefile_from_arm_apply|claim_arm_apply_is_physical_delete|auto_arm_from_preview_alone|mac_only_claim_wave_green|claim_tree_arm_is_physical_delete
# wave807: ENDGAME arm *commit honesty* — pre_arm inventory + post_arm contract (NOT edit; NOT delete).
# Body: phys_del_makefile_gate.sh --endgame-arm-commit-honesty. wave808 tree arm co-changed honesty greps.
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY=1
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_WAVE=wave807
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_NOTE=post_arm_contract_ENDGAME_1_TREE_ARMED_1_delete_still_refused_not_delete
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_MODE=--endgame-arm-commit-honesty
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_ENDGAME=1
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_TREE_ARMED=1
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_DELETE_ALLOWED=0
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_DELETE_BODY=deferred_never_rm_in_execute_gate
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_NEXT=confirm_delete_body_separate_wave
PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_FORBIDDEN=claim_honesty_is_tree_arm|claim_honesty_is_physical_delete|rm_makefile_in_arm_commit|skip_co_change_honesty_greps|mac_only_claim_wave_green|claim_tree_arm_is_physical_delete
# wave808: reviewed TREE_ARMED arm — ENDGAME=1 + TREE_ARMED=1 on tree; NOT physical delete.
# Delete body still deferred (execute-gate never rm even after ENDGAME=1 + confirm env).
PHYS_DEL_ENDGAME_TREE_ARMED=1
PHYS_DEL_ENDGAME_TREE_ARMED_WAVE=wave808
PHYS_DEL_ENDGAME_TREE_ARMED_NOTE=reviewed_tree_arm_ENDGAME_1_TREE_ARMED_1_delete_body_separate
PHYS_DEL_ENDGAME_TREE_ARMED_DELETE_ALLOWED=0
PHYS_DEL_ENDGAME_TREE_ARMED_DELETE_BODY=deferred_never_rm_in_execute_gate
PHYS_DEL_ENDGAME_TREE_ARMED_NEXT=delete_body_preview_then_honesty_then_confirm_rm
PHYS_DEL_ENDGAME_TREE_ARMED_FORBIDDEN=claim_tree_arm_is_physical_delete|rm_makefile_in_tree_arm_commit|skip_dual_end_L2|mac_only_claim_wave_green
# wave809: delete-body *prep/preview* — TREE_ARMED-gated plan only (NOT ship body; NOT rm).
# Body: phys_del_makefile_gate.sh --delete-body-preview. Ship body is a later confirm wave.
PHYS_DEL_DELETE_BODY_PREP=1
PHYS_DEL_DELETE_BODY_PREP_WAVE=wave809
PHYS_DEL_DELETE_BODY_PREP_NOTE=preview_only_after_tree_armed_not_ship_body_not_rm
PHYS_DEL_DELETE_BODY_PREP_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_DELETE_BODY_PREP_MODE=--delete-body-preview
PHYS_DEL_DELETE_BODY_PREP_APPLIED=0
PHYS_DEL_DELETE_BODY_PREP_BODY_SHIPPED=0
PHYS_DEL_DELETE_BODY_PREP_REQUIRES_STATUS=reproven_green
PHYS_DEL_DELETE_BODY_PREP_REQUIRES_ENDGAME=1
PHYS_DEL_DELETE_BODY_PREP_REQUIRES_TREE_ARMED=1
PHYS_DEL_DELETE_BODY_PREP_TARGET_ACTION=rm_compiler_Makefile
PHYS_DEL_DELETE_BODY_PREP_CONFIRM_ENV=XLANG_PHYS_DEL_CONFIRM=DELETE_MAKEFILE_I_UNDERSTAND
PHYS_DEL_DELETE_BODY_PREP_DELETE_ALLOWED=0
PHYS_DEL_DELETE_BODY_PREP_NEXT=delete_body_commit_honesty_then_confirm_rm_separate
PHYS_DEL_DELETE_BODY_PREP_FORBIDDEN=auto_rm_makefile|claim_preview_is_delete_body|claim_preview_is_physical_delete|rm_makefile_from_delete_body_preview|mac_only_claim_wave_green
# wave810: delete-body *commit honesty* — pre_ship inventory + post_ship contract (NOT edit; NOT delete).
# Body: phys_del_makefile_gate.sh --delete-body-commit-honesty. Ship body is a later confirm wave after explicit auth.
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY=1
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_WAVE=wave810
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_NOTE=commit_checklist_and_pre_ship_contract_not_rm
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_MODE=--delete-body-commit-honesty
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_BODY_SHIPPED=0
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_TARGET_ACTION=rm_compiler_Makefile
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_REQUIRES_STATUS=reproven_green
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_REQUIRES_ENDGAME=1
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_REQUIRES_TREE_ARMED=1
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_DELETE_ALLOWED=0
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_DELETE_BODY=deferred_never_rm_until_body_wave
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_NEXT=explicit_user_auth_then_ship_delete_body
PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_FORBIDDEN=claim_honesty_is_physical_delete|rm_makefile_in_honesty|ship_body_without_explicit_auth|skip_co_change_honesty_greps|mac_only_claim_wave_green|claim_preview_is_delete
# wave778: every SHARED MG wave must green on mac + Ubuntu (Ubuntu = gold).
# Mac-only residual/matrix green is NOT wave green. Push → Ubuntu pull → same check.
MG_VERIFY_DUAL_END=mac_plus_ubuntu_required
MG_VERIFY_GOLD=ubuntu
MG_VERIFY_FORBIDDEN=mac_only_claim_wave_green|skip_ubuntu_sync_green

# Live Makefile residual signals (counts only — not a second recipe list)
MAKEFILE_PATH=compiler/Makefile
EOF
}

print_live_metrics() {
  local mf="$ROOT/compiler/Makefile"
  local cc_c=0 uname_n=0 rebuild_modes=0 catalog_default=0 r1_rt=0 r1_core=0 r1_glue=0 r1_main=0 r1_alias=0 r1_extra=0
  r1_misc=0
  r1_seed_map=0
  r4_pure_r1=0
  r3_cold=0
  r3_prefer=0
  g05_r3_prefer=0
  g05_labi_prefer=0
  g05_rt_prefer=0
  g05_pipeline_abi_prefer=0
  g05_ldpc_prefer=0
  g05_target_cpu_prefer=0
  g05_l2_asm_prefer=0
  g05_async_prefer=0
  g05_other_l2_prefer=0
  r2_panic=0
  r2_panic_prefer=0
  r2_typeck_f64=0
  r2_crt0=0
  r4_gen_x=0
  if [ -f "$mf" ]; then
    # Count recipe-ish $(CC) ... -c lines (rough residual heat; not authoritative list).
    # Safe count: grep -c prints 0 + exit 1 on no match; never || echo 0 (→ 0\n0).
    cc_c=$(grep -cE '\$\(CC\).*-c' "$mf" 2>/dev/null || true)
    cc_c=${cc_c:-0}
    uname_n=$(grep -cE 'UNAME_[SM]|\$\(UNAME_' "$mf" 2>/dev/null || true)
    uname_n=${uname_n:-0}
  fi
  # rebuild_leaves modes: catalog_key= table entries (wave747)
  if [ -f "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" ]; then
    rebuild_modes=$(grep -cE 'catalog_key=' "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" 2>/dev/null || true)
    rebuild_modes=${rebuild_modes:-0}
    if grep -q 'driver_seed_obj_catalog\.sh' \
      "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" \
      && grep -q 'SWALLOWED_R4\|catalog KEY\|wave747\|catalog_key=' \
      "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh"; then
      catalog_default=1
    fi
    # wave756: pure R1 body via try-r1 (residual non-R1 still make)
    if grep -q 'try-r1\|try_ensure_r1' \
      "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" 2>/dev/null \
      && grep -q 'ensure_host_cc_seed_o\.sh' \
      "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" 2>/dev/null; then
      r4_pure_r1=1
    fi
    # wave757: R3 cold-else via try-r3-cold
    if grep -q 'try-r3-cold\|try_ensure_r3_cold' \
      "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" 2>/dev/null; then
      r3_cold=1
    fi
    # wave763: R3 PREFER thin via try-r3-prefer (ensure body + Makefile thin)
    if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
      && grep -q 'try-r3-prefer\|try_ensure_r3_prefer' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-r3-prefer' "$mf" 2>/dev/null; then
      r3_prefer=1
    fi
    # wave764: g05 r3-prefer-family (same catalog body; no dual hybrid R3_COLD)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'r3-prefer-family\|r3_prefer_family' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'r3_prefer_try_step\|XLANG_SIMD_ENC_FROM_X' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
      g05_r3_prefer=1
    fi
    # wave765: g05 labi multi-slice via try-labi-prefer (no dual hybrid)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-labi-prefer\|labi-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_labi_prefer_one\|ensure_labi_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && ! grep -qE '_labi_l0_seed=seeds/labi_path_pure' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_labi_prefer=1
    fi
    # wave766: g05 rt multi-slice via try-rt-prefer (no dual hybrid)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-rt-prefer\|rt-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_rt_prefer_one\|ensure_rt_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-rt-prefer' "$mf" 2>/dev/null \
      && ! grep -qE '_rt_content_seed=seeds/rt_content' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_rt_prefer=1
    fi
    # wave767: g05 pipeline_abi + ldpc via try-*-prefer (no dual hybrid)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-pipeline-abi-prefer\|pipeline-abi-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_pipeline_abi_prefer_one\|ensure_pipeline_abi_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-pipeline-abi-prefer' "$mf" 2>/dev/null \
      && ! grep -qE '_rpabi=seeds/runtime_pipeline_abi\.from_x\.c' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_pipeline_abi_prefer=1
    fi
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-ldpc-prefer\|ldpc-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_ldpc_prefer_one\|ensure_ldpc_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-ldpc-prefer' "$mf" 2>/dev/null \
      && ! grep -qE '_ldpc=seeds/lsp_diag_pipeline_ctx\.from_x\.c' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_ldpc_prefer=1
    fi
    # wave768: g05 target_cpu via try-target-cpu-prefer (no dual hybrid)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-target-cpu-prefer\|target-cpu-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_target_cpu_prefer_one\|ensure_target_cpu_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-target-cpu-prefer' "$mf" 2>/dev/null \
      && ! grep -qE '_tcflags_x=src/driver/target_cpu_flags\.x|_tcpure=seeds/target_cpu_pure\.from_x\.c' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_target_cpu_prefer=1
    fi
    # wave769: g05 L2 asm three via try-l2-asm-prefer (no dual hybrid)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-l2-asm-prefer\|l2-asm-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_l2_asm_prefer_one\|ensure_l2_asm_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-l2-asm-prefer' "$mf" 2>/dev/null \
      && ! grep -qE '_uasb_seed=|_bxec_seed=|_abcs_seed=' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_l2_asm_prefer=1
    fi
    # wave770: g05 async three via try-async-prefer (no dual hybrid)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-async-prefer\|async-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_async_prefer_one\|ensure_async_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-async-prefer' "$mf" 2>/dev/null \
      && ! grep -qE '_aliv_seed=|_acps_seed=|_aap_seed=' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_async_prefer=1
    fi
    # wave771: g05 other L2 four via try-other-l2-prefer (no dual hybrid)
    if [ -f "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" ] \
      && grep -q 'try-other-l2-prefer\|other-l2-prefer' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null \
      && grep -q 'try_ensure_other_l2_prefer_one\|ensure_other_l2_prefer_one' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-other-l2-prefer' "$mf" 2>/dev/null \
      && ! grep -qE '_slc_o=|_slc_seed=|_rdss=|_rdss_thin_x=|_fcc=|_fcc_thin_x=|_lspg=|_lspg_thin_x=' \
        "$ROOT/compiler/scripts/g05_ensure_relink_prereqs.sh" 2>/dev/null; then
      g05_other_l2_prefer=1
    fi
    # wave760: R2 panic cold via try-r2
    if grep -q 'try-r2\|try_ensure_r2' \
      "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" 2>/dev/null; then
      r2_panic=1
    fi
    # wave776: R2 panic PREFER via try-r2-prefer (ensure body + Makefile thin)
    if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
      && grep -q 'try-r2-prefer\|try_ensure_r2_prefer' \
        "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
      && grep -q 'try-r2-prefer' "$mf" 2>/dev/null \
      && ! grep -qE 'runtime_panic\.thin\.o' "$mf" 2>/dev/null; then
      r2_panic_prefer=1
    fi
    # wave761: gen residual via try-gen-x + ensure_gen_x_o.sh
    if grep -q 'try-gen-x\|try_ensure_gen_x' \
      "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" 2>/dev/null \
      && [ -f "$ROOT/compiler/scripts/ensure_gen_x_o.sh" ]; then
      r4_gen_x=1
    fi
  fi
  # wave762: R2 typeck_f64 + crt0 via try-r2 + catalog keys + Makefile thin
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'DRIVER_SEED_TYPECK_F64_OBJS' "$mf" 2>/dev/null \
    && grep -q 'ensure_r2_typeck_f64\|r2_typeck_f64_host_pick' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
    && grep -q 'try-r2' "$mf" 2>/dev/null; then
    r2_typeck_f64=1
  fi
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'DRIVER_SEED_CRT0_OBJS' "$mf" 2>/dev/null \
    && grep -q 'ensure_r2_crt0\|r2_crt0_src_for_out' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null \
    && grep -q 'try-r2' "$mf" 2>/dev/null; then
    r2_crt0=1
  fi
  # wave748: R1 rt-seed-slice body + Makefile thin + catalog key
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'ensure_host_cc_seed_o\.sh' "$mf" 2>/dev/null \
    && grep -q 'RT_SEED_SLICE_OBJS' "$mf" 2>/dev/null; then
    r1_rt=1
  fi
  # wave749: R1 core-seed body + catalog key + thin Makefile leaves
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'R1_CORE_SEED_OBJS' "$mf" 2>/dev/null \
    && grep -q 'core-seed\|R1_CORE_SEED' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
    r1_core=1
  fi
  # wave750: R1 frontend-glue body + catalog key + basename-mismatch map
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'R1_FRONTEND_GLUE_OBJS' "$mf" 2>/dev/null \
    && grep -q 'frontend-glue\|R1_FRONTEND_GLUE' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
    r1_glue=1
  fi
  # wave751: R1 main-runtime body + catalog key + multi-flag map
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'R1_MAIN_RUNTIME_OBJS' "$mf" 2>/dev/null \
    && grep -q 'main-runtime\|R1_MAIN_RUNTIME' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
    r1_main=1
  fi
  # wave752: R1 alias-stubs body + catalog key + thin Makefile leaves
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'R1_ALIAS_STUBS_OBJS' "$mf" 2>/dev/null \
    && grep -q 'alias-stubs\|R1_ALIAS_STUBS' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
    r1_alias=1
  fi
  # wave753: R1 extra-cflags body + catalog key + multi-flag map
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'R1_EXTRA_CFLAGS_OBJS' "$mf" 2>/dev/null \
    && grep -q 'extra-cflags\|R1_EXTRA_CFLAGS' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
    r1_extra=1
  fi
  # wave754: R1 misc-basename body + catalog key + thin Makefile leaves
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'R1_MISC_BASENAME_OBJS' "$mf" 2>/dev/null \
    && grep -q 'misc-basename\|R1_MISC_BASENAME' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
    r1_misc=1
  fi
  # wave755: R1 seed-map body + catalog key + o→seed map + thin Makefile leaves
  if [ -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ] \
    && grep -q 'R1_SEED_MAP_OBJS' "$mf" 2>/dev/null \
    && grep -q 'seed-map\|R1_SEED_MAP' \
      "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
    r1_seed_map=1
  fi
  cat <<EOF
MAKEFILE_PRESENT=$([ -f "$mf" ] && echo 1 || echo 0)
MAKEFILE_CC_C_RECIPE_LINES=$cc_c
MAKEFILE_UNAME_REF_LINES=$uname_n
REBUILD_LEAVES_MODE_TABLE_ENTRIES=$rebuild_modes
R4_MODE_POLICY_SWALLOWED=$catalog_default
R4_BODY_PURE_R1_SWALLOWED=$r4_pure_r1
R3_COLD_ELSE_SWALLOWED=$r3_cold
R3_PREFER_THIN_SWALLOWED=$r3_prefer
G05_R3_PREFER_SWALLOWED=$g05_r3_prefer
G05_LABI_PREFER_SWALLOWED=$g05_labi_prefer
G05_RT_PREFER_SWALLOWED=$g05_rt_prefer
G05_PIPELINE_ABI_PREFER_SWALLOWED=$g05_pipeline_abi_prefer
G05_LDPC_PREFER_SWALLOWED=$g05_ldpc_prefer
G05_TARGET_CPU_PREFER_SWALLOWED=$g05_target_cpu_prefer
G05_L2_ASM_PREFER_SWALLOWED=$g05_l2_asm_prefer
G05_ASYNC_PREFER_SWALLOWED=$g05_async_prefer
G05_OTHER_L2_PREFER_SWALLOWED=$g05_other_l2_prefer
R2_PANIC_COLD_SWALLOWED=$r2_panic
R2_PANIC_PREFER_SWALLOWED=$r2_panic_prefer
R2_TYPECK_F64_SWALLOWED=$r2_typeck_f64
R2_CRT0_SWALLOWED=$r2_crt0
R4_BODY_GEN_X_SWALLOWED=$r4_gen_x
R4_PATTERN_BODY_STILL_MAKE=1
R1_RT_SEED_SLICE_SWALLOWED=$r1_rt
R1_CORE_SEED_SWALLOWED=$r1_core
R1_FRONTEND_GLUE_SWALLOWED=$r1_glue
R1_MAIN_RUNTIME_SWALLOWED=$r1_main
R1_ALIAS_STUBS_SWALLOWED=$r1_alias
R1_EXTRA_CFLAGS_SWALLOWED=$r1_extra
R1_MISC_BASENAME_SWALLOWED=$r1_misc
R1_SEED_MAP_SWALLOWED=$r1_seed_map
R1_OTHER_HOST_CC_STILL_MAKE=1
# wave777: physical-delete prep inventory present (buckets above; body residual honest)
PHYS_DEL_PREP_INVENTORY_LIVE=1
ENDGAME_PHYSICAL_DELETE_MAKEFILE=1
ENDGAME_LEAF_WITHOUT_HOST_CC=0
ENDGAME_COLD_PURE_LD=1
ENDGAME_G05_PURE_LD=1
ENDGAME_DROP_CC_FALLBACK=1
EOF
}

print_dump() {
  print_classes
  print_live_metrics
}

if [ "$MODE" = classes ]; then
  print_classes
  exit 0
fi

if [ "$MODE" = dump ]; then
  print_dump
  exit 0
fi

# ---- check mode ----
cd "$ROOT"
DOC_REL="compiler/docs/LEAF_PATTERN_RESIDUAL.md"
SCRIPT_REL="compiler/scripts/leaf_pattern_residual.sh"
XBUILD_REL="xlang-build.sh"
MF="compiler/Makefile"
REBUILD_REL="compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh"

if [ ! -f "$DOC_REL" ]; then
  bad "missing $DOC_REL (11.3.1 leaf residual authority map)"
else
  if ! grep -q '11\.3\.1' "$DOC_REL"; then
    bad "$DOC_REL must document 11.3.1"
  fi
  if ! grep -qE 'R1|host.cc|from_x' "$DOC_REL"; then
    bad "$DOC_REL must name residual class R1 / host-cc seed"
  fi
  if ! grep -qiE 'lists stay mk|no dual|\.o list|Do not.*\.o' "$DOC_REL"; then
    bad "$DOC_REL must ban dual .o inventories (G.7)"
  fi
  if ! grep -qiE 'physical delete|11\.3\.1 endgame|not this wave|not closed' "$DOC_REL"; then
    bad "$DOC_REL must mark physical delete as endgame (not this wave)"
  fi
  if ! grep -qE 'wave747|R4 mode|mode.policy|catalog' "$DOC_REL"; then
    bad "$DOC_REL must document wave747 R4 mode-policy swallow"
  fi
  if ! grep -qE 'wave748|R1.*rt.seed|ensure_host_cc_seed_o|RT_SEED_SLICE' "$DOC_REL"; then
    bad "$DOC_REL must document wave748 R1 rt-seed-slice swallow"
  fi
  if ! grep -qE 'wave749|R1_CORE_SEED|core-seed|core_seed' "$DOC_REL"; then
    bad "$DOC_REL must document wave749 R1 core-seed swallow"
  fi
  if ! grep -qE 'wave750|R1_FRONTEND_GLUE|frontend-glue|frontend_glue' "$DOC_REL"; then
    bad "$DOC_REL must document wave750 R1 frontend-glue swallow"
  fi
  if ! grep -qE 'wave751|R1_MAIN_RUNTIME|main-runtime|main_runtime' "$DOC_REL"; then
    bad "$DOC_REL must document wave751 R1 main-runtime swallow"
  fi
  if ! grep -qE 'wave752|R1_ALIAS_STUBS|alias-stubs|alias_stubs' "$DOC_REL"; then
    bad "$DOC_REL must document wave752 R1 alias-stubs swallow"
  fi
  if ! grep -qE 'wave753|R1_EXTRA_CFLAGS|extra-cflags|extra_cflags' "$DOC_REL"; then
    bad "$DOC_REL must document wave753 R1 extra-cflags swallow"
  fi
  if ! grep -qE 'wave754|R1_MISC_BASENAME|misc-basename|misc_basename' "$DOC_REL"; then
    bad "$DOC_REL must document wave754 R1 misc-basename swallow"
  fi
  if ! grep -qE 'wave755|R1_SEED_MAP|seed-map|seed_map' "$DOC_REL"; then
    bad "$DOC_REL must document wave755 R1 seed-map swallow"
  fi
  if ! grep -qE 'wave756|try-r1|pure.R1|R4_BODY_PURE' "$DOC_REL"; then
    bad "$DOC_REL must document wave756 R4 pure-R1 body swallow"
  fi
  if ! grep -qE 'wave757|try-r3-cold|R3_COLD|cold.else' "$DOC_REL"; then
    bad "$DOC_REL must document wave757 R3 cold-else body swallow"
  fi
  if ! grep -qE 'wave758|thin_glue|parser_asm_thin_glue|seed-map.*thin' "$DOC_REL"; then
    bad "$DOC_REL must document wave758 thin_glue seed-map swallow"
  fi
  if ! grep -qE 'wave759|glue.standalone|pipeline_glue_standalone|seed-map.*glue' "$DOC_REL"; then
    bad "$DOC_REL must document wave759 glue standalone seed-map swallow"
  fi
  if ! grep -qE 'wave760|try-r2|R2.panic|panic.cold|DRIVER_SEED_PANIC' "$DOC_REL"; then
    bad "$DOC_REL must document wave760 R2 panic cold try-r2 swallow"
  fi
  if ! grep -qE 'wave762|typeck_f64|DRIVER_SEED_TYPECK_F64|DRIVER_SEED_CRT0' "$DOC_REL"; then
    bad "$DOC_REL must document wave762 R2 typeck_f64/crt0 try-r2 swallow"
  fi
  if ! grep -qE 'wave761|try-gen-x|ensure_gen_x_o|gen.\*_x|pipeline_x' "$DOC_REL"; then
    bad "$DOC_REL must document wave761 gen *_x / pipeline_x try-gen-x swallow"
  fi
  if ! grep -qE 'wave777|PHYS_DEL_PREP|physical.delete prep|phys-del prep' "$DOC_REL"; then
    bad "$DOC_REL must document wave777 physical-delete prep inventory"
  fi
  if ! grep -qE 'PHYS_DEL_BUCKET_B1|runtime_os_hybrid|B1.*runtime' "$DOC_REL"; then
    bad "$DOC_REL must name wave777 PHYS_DEL_BUCKET B1 runtime OS hybrid"
  fi
  if ! grep -qE 'wave778|PHYS_DEL_WINDOWS_GATE|Windows.*gate|before.*Makefile.*delete' "$DOC_REL"; then
    bad "$DOC_REL must document wave778 Windows gate before Makefile delete"
  fi
  if ! grep -qE 'wave798|PHYS_DEL_PREFLIGHT|phys-del preflight|physical-delete preflight' "$DOC_REL"; then
    bad "$DOC_REL must document wave798 physical-delete preflight"
  fi
  if ! grep -qE 'wave799|PHYS_DEL_EXECUTE_GATE|phys-del execute|phys_del_makefile_gate' "$DOC_REL"; then
    bad "$DOC_REL must document wave799 physical-delete execute gate"
  fi
  if ! grep -qE 'wave800|PROOF_HARNESS|proof stamp|verify-windows-proof|WINDOWS_PROOF' "$DOC_REL"; then
    bad "$DOC_REL must document wave800 Windows proof harness"
  fi
  if ! grep -qE 'wave801|status-flip-preview|STATUS_FLIP_PREP|flip.preview' "$DOC_REL"; then
    bad "$DOC_REL must document wave801 STATUS flip preview"
  fi
  if ! grep -qE 'wave802|status-flip-apply|STATUS_FLIP_APPLY|flip.apply' "$DOC_REL"; then
    bad "$DOC_REL must document wave802 STATUS flip apply harness"
  fi
  if ! grep -qE 'MG_VERIFY_DUAL_END|mac_plus_ubuntu|dual.end|双端' "$DOC_REL"; then
    bad "$DOC_REL must document wave778 dual-end mac+Ubuntu verify policy"
  fi
  if ! grep -qE 'wave779|try-runtime-os-prefer|B1.*runtime.*prefer|runtime_os.*prefer' "$DOC_REL"; then
    bad "$DOC_REL must document wave779 B1 try-runtime-os-prefer body swallow"
  fi
  if ! grep -qE 'wave780|try-std-core-prefer|B2.*std.core|std_core.*prefer' "$DOC_REL"; then
    bad "$DOC_REL must document wave780 B2 try-std-core-prefer body swallow"
  fi
  if ! grep -qE 'wave781|try-lsp-sat-prefer|B3.*lsp|lsp_sat.*prefer' "$DOC_REL"; then
    bad "$DOC_REL must document wave781 B3 try-lsp-sat-prefer body swallow"
  fi
  if ! grep -qE 'wave782|try-gen-c-to-o|B4.*gen_c|gen_c_to_o' "$DOC_REL"; then
    bad "$DOC_REL must document wave782 B4 try-gen-c-to-o body swallow"
  fi
  if ! grep -qE 'wave783|try-cfg-eval-ladder|B5.*cfg' "$DOC_REL"; then
    bad "$DOC_REL must document wave783 B5 try-cfg-eval-ladder body swallow"
  fi
  if ! grep -qE 'wave784|compiler_all_ci|B6.*R5|R5.*compiler.all' "$DOC_REL"; then
    bad "$DOC_REL must document wave784 B6 R5 compiler_all_ci"
  fi
  if ! grep -qE 'wave785|B7.*DAG|B7A|B7C.*archaeology|DAG inventory' "$DOC_REL"; then
    bad "$DOC_REL must document wave785 B7 DAG inventory"
  fi
  if ! grep -qE 'wave786|B7D|g05_prepare_and_relink|host.cc product link' "$DOC_REL"; then
    bad "$DOC_REL must document wave786 B7D product g05 link"
  fi
  if ! grep -qE 'wave787|B7A.*cold|residual_make=0|COLD_REBUILD_0MAKE' "$DOC_REL"; then
    bad "$DOC_REL must document wave787 B7A cold residual_make=0 honesty"
  fi
  if ! grep -qE 'wave788|B7B.*shell|SHELL_CATALOG|shell.primary catalog|mk.parse' "$DOC_REL"; then
    bad "$DOC_REL must document wave788 B7B shell-primary catalog"
  fi
  if ! grep -qE 'wave811|std_x hybrid|STD_X_HYBRID|auto-soft-merge' "$DOC_REL"; then
    bad "$DOC_REL must document wave811 std_x product hybrid thin"
  fi
  if ! grep -qE 'wave825|std_x (shell-primary|catalog)|STD_X_SHELL_PRIMARY|std_x ensure' "$DOC_REL"; then
    bad "$DOC_REL must document wave825 std_x shell-primary catalog"
  fi
  if ! grep -qE 'wave826|formal_mod FORCE|FORMAL_MOD_FORCE_THIN|FORCE dep-thin' "$DOC_REL"; then
    bad "$DOC_REL must document wave826 formal_mod FORCE dep-thin"
  fi
  if ! grep -qE 'wave827|std_x FORCE|STD_X_FORCE_THIN' "$DOC_REL"; then
    bad "$DOC_REL must document wave827 std_x FORCE dep-thin"
  fi
  if ! grep -qE 'wave828|driver_leaf FORCE|DRIVER_LEAF_FORCE_THIN' "$DOC_REL"; then
    bad "$DOC_REL must document wave828 driver_leaf FORCE dep-thin"
  fi
  if ! grep -qE 'wave829|gen.c FORCE|GEN_C_FORCE_THIN' "$DOC_REL"; then
    bad "$DOC_REL must document wave829 gen.c FORCE dep-thin"
  fi
  if ! grep -qE 'wave830|ast_gen2 FORCE|AST_GEN2_FORCE_THIN|ensure_ast_gen2' "$DOC_REL"; then
    bad "$DOC_REL must document wave830 ast_gen2 FORCE dep-thin"
  fi
  if ! grep -qE 'wave831|src.edge FORCE|SRC_EDGE_FORCE_THIN|cc_inc_tu FORCE|parser_asm_thin_glue FORCE' "$DOC_REL"; then
    bad "$DOC_REL must document wave831 src-edge FORCE dep-thin"
  fi
  if ! grep -qE 'wave832|migrate_x FORCE|MIGRATE_X_FORCE_THIN|migrate companion FORCE' "$DOC_REL"; then
    bad "$DOC_REL must document wave832 migrate companion FORCE dep-thin"
  fi
  if ! grep -qE 'wave833|glue_types FORCE|GLUE_TYPES_FORCE_THIN|pipeline_glue_types FORCE|ensure_pipeline_glue_types' "$DOC_REL"; then
    bad "$DOC_REL must document wave833 pipeline_glue_types FORCE dep-thin"
  fi
  if ! grep -qE 'wave834|bootstrap.pipeline FORCE|BOOTSTRAP_PIPELINE_FORCE_THIN|bootstrap-pipeline FORCE' "$DOC_REL"; then
    bad "$DOC_REL must document wave834 bootstrap-pipeline FORCE shell-primary"
  fi
  if ! grep -qE 'wave835|FILTERED_O_FORCE_THIN|class-G filter FORCE|bootstrap_seed.*FORCE|filtered FORCE' "$DOC_REL"; then
    bad "$DOC_REL must document wave835 class-G filter FORCE dep-thin"
  fi
  if ! grep -qE 'wave836|CP_ALIAS_FORCE_THIN|cp.alias FORCE|ensure_cp_alias' "$DOC_REL"; then
    bad "$DOC_REL must document wave836 cp-alias FORCE dep-thin"
  fi
  if ! grep -qE 'wave837|PIPELINE_GEN_FORCE_THIN|pipeline_gen\.c FORCE|pipeline_gen FORCE' "$DOC_REL"; then
    bad "$DOC_REL must document wave837 pipeline_gen.c FORCE dep-thin"
  fi
  if ! grep -qE 'wave838|BOOTSTRAP_XLANGC_FORCE_THIN|bootstrap_xlangc FORCE|select_bootstrap_xlangc' "$DOC_REL"; then
    bad "$DOC_REL must document wave838 bootstrap_xlangc FORCE dep-thin"
  fi
  if ! grep -qE 'wave839|ARCH_HOST_PICK_FORCE_THIN|archaeology host-pick FORCE|archaeology FORCE dep-thin' "$DOC_REL"; then
    bad "$DOC_REL must document wave839 archaeology host-pick FORCE dep-thin"
  fi
  if ! grep -qE 'wave841|BOOTSTRAP_TYPECK_CODEGEN_SHELL|bootstrap-typeck.*shell|typeck.codegen shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave841 bootstrap-typeck/codegen shell-primary"
  fi
  if ! grep -qE 'wave842|BOOTSTRAP_X_COMPILER_SHELL|bootstrap-x-compiler.*shell|x.compiler shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave842 bootstrap-x-compiler shell-primary"
  fi
  if ! grep -qE 'wave843|BOOTSTRAP_SELF_SHELL|bootstrap-self.*shell|bootstrap.self shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave843 bootstrap-self shell-primary"
  fi
  if ! grep -qE 'wave844|BOOTSTRAP_PARSER_SMOKE|bootstrap-parser.*shell|parser.smoke shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave844 bootstrap-parser/parse-file shell-primary"
  fi
  if ! grep -qE 'wave845|XLANG_X_PIPELINE_SHELL|xlang-x-pipeline.*shell|xlang.x.pipeline shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave845 xlang-x-pipeline shell-primary"
  fi
  if ! grep -qE 'wave846|XLANG_X_SHELL|xlang-x shell-primary|xlang.x shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave846 xlang-x shell-primary"
  fi
  if ! grep -qE 'wave847|XLANG_NO_C_FRONTEND_SHELL|xlang-no-c-frontend.*shell|no.c.frontend shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave847 xlang-no-c-frontend shell-primary"
  fi
  if ! grep -qE 'wave848|BOOTSTRAP_SEED_X_FRONTEND_SHELL|bootstrap-driver-seed-x-frontend.*shell|seed.x.frontend shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave848 bootstrap-driver-seed-x-frontend shell-primary"
  fi
  if ! grep -qE 'wave849|RELINK_XLANG_LEXER_SHELL|relink-xlang-lexer.*shell|relink.xlang.lexer shell-primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave849 relink-xlang-lexer shell-primary"
  fi
  if ! grep -qE 'wave812|formal_mod|FORMAL_MOD_SHELL|std_module ensure' "$DOC_REL"; then
    bad "$DOC_REL must document wave812 formal_mod shell-primary catalog"
  fi
  if ! grep -qE 'wave813|STD_AND_PANIC|std_and_panic_objs|B7B.*STD_AND_PANIC' "$DOC_REL"; then
    bad "$DOC_REL must document wave813 B7B STD_AND_PANIC list → mk"
  fi
  if ! grep -qE 'wave814|driver_leaf|DRIVER_LEAF_SHELL' "$DOC_REL"; then
    bad "$DOC_REL must document wave814 driver_leaf shell-primary catalog"
  fi
  if ! grep -qE 'wave815|archaeology_host_pick|ARCH_HOST_PICK' "$DOC_REL"; then
    bad "$DOC_REL must document wave815 archaeology host-pick phonies"
  fi
  if ! grep -qE 'wave816|DRIVER_SUBCMD|driver_subcmd_objs' "$DOC_REL"; then
    bad "$DOC_REL must document wave816 B7B DRIVER_SUBCMD list → mk"
  fi
  if ! grep -qE 'wave817|PIPELINE_X|pipeline_x_objs' "$DOC_REL"; then
    bad "$DOC_REL must document wave817 B7B PIPELINE_X list → mk"
  fi
  if ! grep -qE 'wave818|SEED_MODE|driver_seed_mode_objs|SUPPORT_EXTRA' "$DOC_REL"; then
    bad "$DOC_REL must document wave818 B7B DRIVER_SEED mode list → mk"
  fi
  if ! grep -qE 'wave819|SEED_LINK_PICKS|driver_seed_link_picks|MAIN_LINK' "$DOC_REL"; then
    bad "$DOC_REL must document wave819 B7B seed link picks → mk"
  fi
  if ! grep -qE 'wave820|OBJS_CORE|objs_core' "$DOC_REL"; then
    bad "$DOC_REL must document wave820 B7B OBJS_CORE list → mk"
  fi
  if ! grep -qE 'wave821|ARCH_EXPERIMENT|archaeology_experiment' "$DOC_REL"; then
    bad "$DOC_REL must document wave821 B7B archaeology experiment list → mk"
  fi
  if ! grep -qE 'wave822|RELINK_LEGACY|RELINK_XLANG_PREREQS|LEGACY_XLANG_C' "$DOC_REL"; then
    bad "$DOC_REL must document wave822 B7B RELINK/LEGACY list → mk"
  fi
  if ! grep -qE 'wave823|SOURCE_DEPS|x_source_deps|MAIN_X_DEPS|PIPELINE_X_DEPS' "$DOC_REL"; then
    bad "$DOC_REL must document wave823 B7B SOURCE_DEPS list → mk"
  fi
  if ! grep -qE 'wave824|E_DIRS|x_e_dirs|MAIN_X_E_DIRS|LSP_X_E_DIRS|PIPELINE_X_E_DIRS' "$DOC_REL"; then
    bad "$DOC_REL must document wave824 B7B E_DIRS list → mk"
  fi
  if ! grep -qE 'wave850|RELINK_PRODUCT_LINK|product link bag' "$DOC_REL"; then
    bad "$DOC_REL must document wave850 B7B RELINK_PRODUCT_LINK bag → mk"
  fi
  if ! grep -qE 'wave851|XXL_BS_XNC|XLANG_X_LINK|BOOTSTRAP_SELF_LINK|XLANG_NO_C_FRONTEND_LINK' "$DOC_REL"; then
    bad "$DOC_REL must document wave851 B7B XXL/BS/XNC link bags → mk"
  fi
  if ! grep -qE 'wave852|BXF_LINK|DRIVER_SEED_X_FRONTEND_LINK' "$DOC_REL"; then
    bad "$DOC_REL must document wave852 B7B BXF link bag → mk"
  fi
  if ! grep -qE 'wave853|SEED_PHASE_FINAL|PHASE1_LINK|FINAL_LINK|SEED_LINK_OBJS' "$DOC_REL"; then
    bad "$DOC_REL must document wave853 B7B seed phase1/final link bags → mk"
  fi
  if ! grep -qE 'wave854|SEED_GATE_REQUIRED|REQUIRED_OBJS|RELINK_XLANG_REQUIRED|XLANG_X_REQUIRED|XLANG_NO_C_FRONTEND_REQUIRED' "$DOC_REL"; then
    bad "$DOC_REL must document wave854 B7B seed-gate REQUIRED_OBJS bags → mk"
  fi
  if ! grep -qE 'wave855|SEED_GATE_REQUIRED_SHELL_LOAD|REQUIRED.*shell.load|shell loads REQUIRED|shell-load.*REQUIRED' "$DOC_REL"; then
    bad "$DOC_REL must document wave855 B7B seed-gate REQUIRED shell-load from mk"
  fi
  if ! grep -qE 'wave856|LINK_OBJS_SHELL_LOAD|LINK_OBJS.*shell.load|export-.*-link-objs|shell loads LINK' "$DOC_REL"; then
    bad "$DOC_REL must document wave856 B7B LINK_OBJS shell-load via make export leaves"
  fi
  if ! grep -qE 'wave857|LINK_CFLAGS_SHELL_LOAD|LINK_CFLAGS.*shell.load|export-.*-link-cflags' "$DOC_REL"; then
    bad "$DOC_REL must document wave857 B7B LINK_CFLAGS shell-load via make export leaves"
  fi
  if ! grep -qE 'wave858|LEGACY_XLANG_C_SHELL|legacy_xlang_c_link|LEGACY.*shell.primary' "$DOC_REL"; then
    bad "$DOC_REL must document wave858 B7B LEGACY xlang-c link shell-primary"
  fi
  if ! grep -qE 'wave859|XXP_BXC|export-xxp-link-bags|XXP.*shell.load' "$DOC_REL"; then
    bad "$DOC_REL must document wave859 B7B XXP/BXC shell-load"
  fi
  if ! grep -qE 'wave860|DRIVER_LEAF_BASE_CFLAGS|export-driver-leaf-base-cflags|BASE_CFLAGS.*shell.load' "$DOC_REL"; then
    bad "$DOC_REL must document wave860 B7B driver_leaf BASE_CFLAGS shell-load"
  fi
  if ! grep -qE 'wave861|RT_SLICE_I_CFLAGS|rt_.*multi-token|-I.*hygiene|rt_slice.*CFLAGS' "$DOC_REL"; then
    bad "$DOC_REL must document wave861 B7B rt_* multi-token -I CFLAGS hygiene"
  fi
  if ! grep -qE 'wave862|TRY_HEAT_CFLAGS|try-heat.*CFLAGS.*shell.load|export-try-heat-cflags' "$DOC_REL"; then
    bad "$DOC_REL must document wave862 B7B try-heat CFLAGS bulk shell-load"
  fi
  if ! grep -qE 'wave863|FILTER_CFLAGS|filter.*CFLAGS.*shell.load|filter CFLAGS' "$DOC_REL"; then
    bad "$DOC_REL must document wave863 B7B filter CFLAGS shell-load hygiene"
  fi
  if ! grep -qE 'wave864|LEAF_EXTRA_CFLAGS|leaf-extra.*CFLAGS|RUNTIME_PIPELINE_ABI.*hygiene|PARSER_ASM_THIN_GLUE.*hygiene' "$DOC_REL"; then
    bad "$DOC_REL must document wave864 B7B leaf-extra RUNTIME_*/PARSER_* CFLAGS hygiene"
  fi
  if ! grep -qE 'wave865|MIGRATE_BOOTSTRAP_CFLAGS|migrate.*CFLAGS.*shell.load|migrate/bootstrap.*CFLAGS' "$DOC_REL"; then
    bad "$DOC_REL must document wave865 B7B migrate/bootstrap CFLAGS shell-load"
  fi
  if ! grep -qE 'wave866|BUILD_TOOL_WIN32|build-tool.*CFLAGS|WIN32_O_CFLAGS.*hygiene|build-tool.*WIN32' "$DOC_REL"; then
    bad "$DOC_REL must document wave866 B7B build-tool/WIN32 CFLAGS hygiene"
  fi
  if ! grep -qE 'wave867|ARCH_HOST_PICK_LD_R|LD_R_MULTIDEF.*hygiene|archaeology.*LD_R|host-pick.*LD_R' "$DOC_REL"; then
    bad "$DOC_REL must document wave867 B7B archaeology host-pick LD_R_MULTIDEF hygiene"
  fi
  if ! grep -qE 'wave868|BSTRICT_RELINK|bstrict-relink.*shell|relink_xlang_asm_bstrict_runtime' "$DOC_REL"; then
    bad "$DOC_REL must document wave868 bootstrap-driver-bstrict-relink shell-primary"
  fi
  if ! grep -qE 'wave869|CRT0_SHELL|bootstrap-driver-crt0.*shell|bootstrap_driver_crt0' "$DOC_REL"; then
    bad "$DOC_REL must document wave869 bootstrap-driver-crt0 shell-primary"
  fi
  if ! grep -qE 'wave870|CHECK_7_2|check-7\.2.*shell|check_7_2' "$DOC_REL"; then
    bad "$DOC_REL must document wave870 check-7.2 shell-primary"
  fi
  if ! grep -qE 'wave871|CHECK_6_4|check-6\.4.*shell|check_6_4' "$DOC_REL"; then
    bad "$DOC_REL must document wave871 check-6.4 shell-primary"
  fi
  if ! grep -qE 'wave872|HYBRID_SHELL|bootstrap-driver-hybrid.*shell|bootstrap_driver_hybrid' "$DOC_REL"; then
    bad "$DOC_REL must document wave872 bootstrap-driver-hybrid shell-primary"
  fi
  if ! grep -qE 'wave873|REGEN_LSP|regen-lsp-gens-x.*shell|regen_lsp_gens_x' "$DOC_REL"; then
    bad "$DOC_REL must document wave873 regen-lsp-gens-x shell-primary"
  fi
  if ! grep -qE 'wave874|BUILD_VIA_TOOL|build-via-tool.*shell|build_via_tool' "$DOC_REL"; then
    bad "$DOC_REL must document wave874 build-via-tool shell-primary"
  fi
  if ! grep -qE 'wave875|STAGE8_BASELINE|size-baseline.*shell|stage8_baseline|perf-baseline.*shell' "$DOC_REL"; then
    bad "$DOC_REL must document wave875 size/perf-baseline shell-primary"
  fi
  if ! grep -qE 'wave876|XLANG_C_ALIAS|ensure_xlang_c|xlang-c.*shell|default.*xlang-c.*alias' "$DOC_REL"; then
    bad "$DOC_REL must document wave876 default xlang-c alias shell-primary"
  fi
  if ! grep -qE 'wave877|GEN_ENSURE_ENV|gen.*ensure.*env.*hygiene|ensure_.*_gen.*inject|multi-token.*ensure' "$DOC_REL"; then
    bad "$DOC_REL must document wave877 gen ensure multi-token env inject hygiene"
  fi
  if ! grep -qE 'wave878|MIGRATE_ENV_HYGIENE|migrate.*CC.*PYTHON.*MAKE|migrate_x_objs.*inject|multi-token.*migrate' "$DOC_REL"; then
    bad "$DOC_REL must document wave878 migrate multi-token CC/PYTHON/MAKE inject hygiene"
  fi
  if ! grep -qE 'wave879|STAGE_BOOTSTRAP_ENV|stage.*bootstrap.*env.*hygiene|multi-token.*TARGET.*CC.*MAKE|stage/bootstrap.*inject' "$DOC_REL"; then
    bad "$DOC_REL must document wave879 stage/bootstrap multi-token TARGET/CC/MAKE inject hygiene"
  fi
  if ! grep -qE 'wave880|ENSURE_OUT_OPT|ENSURE=0|all OPT.*hygiene|MAKELEVEL.*ENSURE|OUT=.*hygiene' "$DOC_REL"; then
    bad "$DOC_REL must document wave880 ENSURE=0 / OUT / all OPT inject hygiene"
  fi
  if ! grep -qE 'wave881|PREFER_INJECT|PREFER_X_O.*inject|try-heat.*PREFER' "$DOC_REL"; then
    bad "$DOC_REL must document wave881 try-heat PREFER inject hygiene"
  fi
  if ! grep -qE 'wave882|TARGET_INJECT|TARGET=.*inject|single-token TARGET' "$DOC_REL"; then
    bad "$DOC_REL must document wave882 TARGET inject hygiene"
  fi
  note "doc $DOC_REL present"
fi

if [ ! -f "$SCRIPT_REL" ]; then
  bad "missing $SCRIPT_REL"
fi

# Live dump must name residual classes + endgame flags
_out="$(bash "$SCRIPT_REL" dump 2>/dev/null || true)"
if ! grep -q 'RESIDUAL_CLASS_R1=host_cc_seed_from_x_to_o' <<<"$_out"; then
  bad "dump missing RESIDUAL_CLASS_R1"
fi
if ! grep -q 'RESIDUAL_CLASS_R4=cold_rebuild_pattern_bodies' <<<"$_out"; then
  bad "dump missing RESIDUAL_CLASS_R4"
fi
if ! grep -qE 'RESIDUAL_CLASS_R6=cold_link_(seed_link_cc|pure_ld_prefer)' <<<"$_out"; then
  bad "dump missing RESIDUAL_CLASS_R6 (cross-ref 11.1.4)"
fi
if ! grep -q 'SWALLOWED_R6_PURE_LD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R6_PURE_LD=1 (wave772 pure-ld)"
fi
if ! grep -q 'ENDGAME_COLD_PURE_LD=1' <<<"$_out"; then
  bad "dump ENDGAME_COLD_PURE_LD must be 1 (wave772)"
fi
if ! grep -q 'SWALLOWED_G05_PURE_LD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_PURE_LD=1 (wave773 g05 pure-ld)"
fi
if ! grep -q 'ENDGAME_G05_PURE_LD=1' <<<"$_out"; then
  bad "dump ENDGAME_G05_PURE_LD must be 1 (wave773)"
fi
if ! grep -q 'SWALLOWED_DROP_CC_FALLBACK=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_DROP_CC_FALLBACK=1 (wave774)"
fi
if ! grep -q 'ENDGAME_DROP_CC_FALLBACK=1' <<<"$_out"; then
  bad "dump ENDGAME_DROP_CC_FALLBACK must be 1 (wave774)"
fi
if ! grep -q 'SWALLOWED_PREREQ_EDGES=scripts/driver_seed_ensure_prereqs.sh' <<<"$_out"; then
  bad "dump must name swallowed prereq edges (wave744)"
fi
if ! grep -q 'SWALLOWED_R4_MODE_POLICY=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R4_MODE_POLICY=1 (wave747)"
fi
if ! grep -q 'R4_MODE_POLICY_SWALLOWED=1' <<<"$_out"; then
  bad "dump R4_MODE_POLICY_SWALLOWED must be 1 (rebuild_leaves uses catalog)"
fi
if ! grep -q 'R4_PATTERN_BODY_STILL_MAKE=1' <<<"$_out"; then
  bad "dump must keep R4_PATTERN_BODY_STILL_MAKE=1 (honest non-R1 residual)"
fi
if ! grep -q 'SWALLOWED_R4_BODY_PURE_R1=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R4_BODY_PURE_R1=1 (wave756)"
fi
if ! grep -q 'R4_BODY_PURE_R1_SWALLOWED=1' <<<"$_out"; then
  bad "dump R4_BODY_PURE_R1_SWALLOWED must be 1 (wave756 try-r1)"
fi
if ! grep -q 'SWALLOWED_R4_BODY_THIN_GLUE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R4_BODY_THIN_GLUE=1 (wave758 thin_glue seed-map)"
fi
if ! grep -q 'SWALLOWED_R4_BODY_GLUE_STANDALONE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R4_BODY_GLUE_STANDALONE=1 (wave759 glue standalone seed-map)"
fi
if ! grep -q 'SWALLOWED_R2_PANIC_COLD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R2_PANIC_COLD=1 (wave760 R2 panic cold try-r2)"
fi
if ! grep -q 'R2_PANIC_COLD_SWALLOWED=1' <<<"$_out"; then
  bad "dump R2_PANIC_COLD_SWALLOWED must be 1 (try-r2 + catalog)"
fi
if ! grep -q 'SWALLOWED_R2_PANIC_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R2_PANIC_PREFER=1 (wave776 R2 panic PREFER try-r2-prefer)"
fi
if ! grep -q 'R2_PANIC_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump R2_PANIC_PREFER_SWALLOWED must be 1 (try-r2-prefer + Makefile thin)"
fi
if ! grep -q 'SWALLOWED_R2_TYPECK_F64=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R2_TYPECK_F64=1 (wave762)"
fi
if ! grep -q 'R2_TYPECK_F64_SWALLOWED=1' <<<"$_out"; then
  bad "dump R2_TYPECK_F64_SWALLOWED must be 1 (wave762)"
fi
if ! grep -q 'SWALLOWED_R2_CRT0=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R2_CRT0=1 (wave762)"
fi
if ! grep -q 'R2_CRT0_SWALLOWED=1' <<<"$_out"; then
  bad "dump R2_CRT0_SWALLOWED must be 1 (wave762)"
fi
if ! grep -q 'SWALLOWED_R4_BODY_GEN_X=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R4_BODY_GEN_X=1 (wave761 gen/pipeline try-gen-x)"
fi
if ! grep -q 'R4_BODY_GEN_X_SWALLOWED=1' <<<"$_out"; then
  bad "dump R4_BODY_GEN_X_SWALLOWED must be 1 (wave761 try-gen-x)"
fi
if ! grep -q 'SWALLOWED_R1_RT_SEED_SLICE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_RT_SEED_SLICE=1 (wave748)"
fi
if ! grep -q 'R1_RT_SEED_SLICE_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_RT_SEED_SLICE_SWALLOWED must be 1 (ensure body + thin Makefile)"
fi
if ! grep -q 'SWALLOWED_R1_CORE_SEED=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_CORE_SEED=1 (wave749)"
fi
if ! grep -q 'R1_CORE_SEED_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_CORE_SEED_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! grep -q 'SWALLOWED_R1_FRONTEND_GLUE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_FRONTEND_GLUE=1 (wave750)"
fi
if ! grep -q 'R1_FRONTEND_GLUE_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_FRONTEND_GLUE_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! grep -q 'SWALLOWED_R1_MAIN_RUNTIME=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_MAIN_RUNTIME=1 (wave751)"
fi
if ! grep -q 'R1_MAIN_RUNTIME_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_MAIN_RUNTIME_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! grep -q 'SWALLOWED_R1_ALIAS_STUBS=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_ALIAS_STUBS=1 (wave752)"
fi
if ! grep -q 'R1_ALIAS_STUBS_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_ALIAS_STUBS_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! grep -q 'SWALLOWED_R1_EXTRA_CFLAGS=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_EXTRA_CFLAGS=1 (wave753)"
fi
if ! grep -q 'R1_EXTRA_CFLAGS_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_EXTRA_CFLAGS_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! grep -q 'SWALLOWED_R1_MISC_BASENAME=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_MISC_BASENAME=1 (wave754)"
fi
if ! grep -q 'R1_MISC_BASENAME_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_MISC_BASENAME_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! grep -q 'SWALLOWED_R1_SEED_MAP=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R1_SEED_MAP=1 (wave755)"
fi
if ! grep -q 'R1_SEED_MAP_SWALLOWED=1' <<<"$_out"; then
  bad "dump R1_SEED_MAP_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! grep -q 'SWALLOWED_R3_COLD_ELSE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R3_COLD_ELSE=1 (wave757)"
fi
if ! grep -q 'R3_COLD_ELSE_SWALLOWED=1' <<<"$_out"; then
  bad "dump R3_COLD_ELSE_SWALLOWED must be 1 (try-r3-cold + catalog)"
fi
if ! grep -q 'SWALLOWED_R3_PREFER_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_R3_PREFER_THIN=1 (wave763)"
fi
if ! grep -q 'R3_PREFER_THIN_SWALLOWED=1' <<<"$_out"; then
  bad "dump R3_PREFER_THIN_SWALLOWED must be 1 (try-r3-prefer + Makefile thin)"
fi
if ! grep -q 'SWALLOWED_G05_R3_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_R3_PREFER=1 (wave764)"
fi
if ! grep -q 'G05_R3_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_R3_PREFER_SWALLOWED must be 1 (g05 r3-prefer-family + full ladder)"
fi
if ! grep -q 'SWALLOWED_G05_LABI_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_LABI_PREFER=1 (wave765)"
fi
if ! grep -q 'G05_LABI_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_LABI_PREFER_SWALLOWED must be 1 (try-labi-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_G05_RT_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_RT_PREFER=1 (wave766)"
fi
if ! grep -q 'G05_RT_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_RT_PREFER_SWALLOWED must be 1 (try-rt-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_G05_PIPELINE_ABI_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_PIPELINE_ABI_PREFER=1 (wave767)"
fi
if ! grep -q 'G05_PIPELINE_ABI_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_PIPELINE_ABI_PREFER_SWALLOWED must be 1 (try-pipeline-abi-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_G05_LDPC_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_LDPC_PREFER=1 (wave767)"
fi
if ! grep -q 'G05_LDPC_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_LDPC_PREFER_SWALLOWED must be 1 (try-ldpc-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_G05_TARGET_CPU_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_TARGET_CPU_PREFER=1 (wave768)"
fi
if ! grep -q 'G05_TARGET_CPU_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_TARGET_CPU_PREFER_SWALLOWED must be 1 (try-target-cpu-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_G05_L2_ASM_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_L2_ASM_PREFER=1 (wave769)"
fi
if ! grep -q 'G05_L2_ASM_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_L2_ASM_PREFER_SWALLOWED must be 1 (try-l2-asm-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_G05_ASYNC_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_ASYNC_PREFER=1 (wave770)"
fi
if ! grep -q 'G05_ASYNC_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_ASYNC_PREFER_SWALLOWED must be 1 (try-async-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_G05_OTHER_L2_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_G05_OTHER_L2_PREFER=1 (wave771)"
fi
if ! grep -q 'G05_OTHER_L2_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump G05_OTHER_L2_PREFER_SWALLOWED must be 1 (try-other-l2-prefer + g05 thin-call)"
fi
if ! grep -q 'SWALLOWED_FMT_CHECK_CMD_O_DUAL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_FMT_CHECK_CMD_O_DUAL=1 (wave775)"
fi
if ! grep -q 'R1_OTHER_HOST_CC_STILL_MAKE=1' <<<"$_out"; then
  bad "dump must keep R1_OTHER_HOST_CC_STILL_MAKE=1 (honest residual)"
fi
if ! grep -q 'PHYS_DEL_PREP_INVENTORY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREP_INVENTORY=1 (wave777 physical-delete prep)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B1=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B1 (wave777 runtime OS hybrid)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B2=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B2 (wave777 std/core product hybrid)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B3=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B3 (wave777 lsp satellite)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B4=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B4 (wave777 gen_c_to_o)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B5=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B5 (wave777 cfg_eval ladder)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B6=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B6 (wave777 R5 CI)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B7 (wave777 makefile DAG)"
fi
if ! grep -q 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=1' <<<"$_out"; then
  bad "dump missing ENDGAME_PHYSICAL_DELETE_MAKEFILE=1 (wave808 tree arm; not physical delete)"
fi
if grep -qE 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=0' <<<"$_out"; then
  bad "wave808 must not keep ENDGAME_PHYSICAL_DELETE_MAKEFILE=0 after tree arm"
fi
if ! grep -q 'PHYS_DEL_WINDOWS_GATE=required_before_makefile_delete' <<<"$_out"; then
  bad "dump must set PHYS_DEL_WINDOWS_GATE=required_before_makefile_delete (wave778)"
fi
if ! grep -q 'PHYS_DEL_WINDOWS_GATE_FORBIDDEN=physical_delete_makefile_before_windows_green' <<<"$_out"; then
  bad "dump must forbid physical delete before Windows green (wave778)"
fi
if ! grep -q 'MG_VERIFY_DUAL_END=mac_plus_ubuntu_required' <<<"$_out"; then
  bad "dump must set MG_VERIFY_DUAL_END=mac_plus_ubuntu_required (wave778)"
fi
if ! grep -q 'MG_VERIFY_GOLD=ubuntu' <<<"$_out"; then
  bad "dump must set MG_VERIFY_GOLD=ubuntu (wave778)"
fi
if ! grep -q 'MG_VERIFY_FORBIDDEN=mac_only_claim_wave_green' <<<"$_out"; then
  bad "dump must forbid mac-only wave-green claims (wave778)"
fi
if ! grep -q 'SWALLOWED_B1_RUNTIME_OS_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B1_RUNTIME_OS_PREFER=1 (wave779)"
fi
if ! grep -q 'B1_RUNTIME_OS_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump B1_RUNTIME_OS_PREFER_SWALLOWED must be 1 (wave779 try-runtime-os-prefer)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B1_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B1_BODY_SWALLOWED=1 (wave779)"
fi
if ! grep -q 'SWALLOWED_B2_STD_CORE_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B2_STD_CORE_PREFER=1 (wave780)"
fi
if ! grep -q 'B2_STD_CORE_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump B2_STD_CORE_PREFER_SWALLOWED must be 1 (wave780 try-std-core-prefer)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B2_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B2_BODY_SWALLOWED=1 (wave780)"
fi
if ! grep -q 'SWALLOWED_B3_LSP_SAT_PREFER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B3_LSP_SAT_PREFER=1 (wave781)"
fi
if ! grep -q 'B3_LSP_SAT_PREFER_SWALLOWED=1' <<<"$_out"; then
  bad "dump B3_LSP_SAT_PREFER_SWALLOWED must be 1 (wave781 try-lsp-sat-prefer)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B3_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B3_BODY_SWALLOWED=1 (wave781)"
fi
if ! grep -q 'SWALLOWED_B4_GEN_C_TO_O=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B4_GEN_C_TO_O=1 (wave782)"
fi
if ! grep -q 'B4_GEN_C_TO_O_SWALLOWED=1' <<<"$_out"; then
  bad "dump B4_GEN_C_TO_O_SWALLOWED must be 1 (wave782 try-gen-c-to-o)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B4_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B4_BODY_SWALLOWED=1 (wave782)"
fi
if ! grep -q 'SWALLOWED_B5_CFG_EVAL_LADDER=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B5_CFG_EVAL_LADDER=1 (wave783)"
fi
if ! grep -q 'B5_CFG_EVAL_LADDER_SWALLOWED=1' <<<"$_out"; then
  bad "dump B5_CFG_EVAL_LADDER_SWALLOWED must be 1 (wave783 try-cfg-eval-ladder)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B5_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B5_BODY_SWALLOWED=1 (wave783)"
fi
if ! grep -q 'SWALLOWED_B6_R5_CI_COMPILER_ALL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B6_R5_CI_COMPILER_ALL=1 (wave784)"
fi
if ! grep -q 'B6_R5_CI_COMPILER_ALL_SWALLOWED=1' <<<"$_out"; then
  bad "dump B6_R5_CI_COMPILER_ALL_SWALLOWED must be 1 (wave784 compiler_all_ci.sh)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B6_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B6_BODY_SWALLOWED=1 (wave784)"
fi
# wave785: B7 DAG inventory + archaeology CC thin (NOT physical delete)
if ! grep -q 'SWALLOWED_B7_DAG_INVENTORY=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7_DAG_INVENTORY=1 (wave785)"
fi
if ! grep -q 'B7_DAG_INVENTORY_SWALLOWED=1' <<<"$_out"; then
  bad "dump B7_DAG_INVENTORY_SWALLOWED must be 1 (wave785)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7_INVENTORY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7_INVENTORY=1 (wave785)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7_BODY_SWALLOWED=0' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7_BODY_SWALLOWED=0 (wave785 not delete)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B7A thin-call edges (wave785)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7B=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B7B mk lists (wave785)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7C=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B7C archaeology phony (wave785)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7D=' <<<"$_out"; then
  bad "dump must name PHYS_DEL_BUCKET_B7D host-cc product link (wave785)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7C_ARCHAEOLOGY_CC_THINNED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7C_ARCHAEOLOGY_CC_THINNED=1 (wave785)"
fi
# wave786: B7D body swallowed → product g05 (not physical delete)
if ! grep -q 'SWALLOWED_B7D_HOST_CC_PRODUCT_LINK=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7D_HOST_CC_PRODUCT_LINK=1 (wave786)"
fi
if ! grep -q 'B7D_HOST_CC_PRODUCT_LINK_SWALLOWED=1' <<<"$_out"; then
  bad "dump B7D_HOST_CC_PRODUCT_LINK_SWALLOWED must be 1 (wave786)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7D_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7D_BODY_SWALLOWED=1 (wave786)"
fi
# wave787: B7A cold residual_make=0 honesty + heat residual + B7B list honesty
if ! grep -q 'SWALLOWED_B7A_COLD_REBUILD_0MAKE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7A_COLD_REBUILD_0MAKE=1 (wave787)"
fi
if ! grep -q 'B7A_COLD_REBUILD_0MAKE_SWALLOWED=1' <<<"$_out"; then
  bad "dump B7A_COLD_REBUILD_0MAKE_SWALLOWED must be 1 (wave787)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_COLD_0MAKE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_COLD_0MAKE=1 (wave787)"
fi
# wave797: heat source-prereq residual closed (was =1 through wave796 orch residual).
if ! grep -q 'PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=0' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=0 (wave797 orch source-prereq closed)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_BODY_SWALLOWED=0' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_BODY_SWALLOWED=0 (wave787 not full B7A)"
fi
if ! grep -q 'SWALLOWED_B7B_LIST_AUTHORITY_HONESTY=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_LIST_AUTHORITY_HONESTY=1 (wave787)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7B_LIST_STAYS_MK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7B_LIST_STAYS_MK=1 (wave787)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7B_BODY_SWALLOWED=0' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7B_BODY_SWALLOWED=0 (wave787 lists stay)"
fi
# wave788: B7B shell-primary catalog
if ! grep -q 'SWALLOWED_B7B_SHELL_CATALOG=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_SHELL_CATALOG=1 (wave788)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7B_SHELL_CATALOG=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7B_SHELL_CATALOG=1 (wave788)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7B_MAKE_EXPORT_ESCAPE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7B_MAKE_EXPORT_ESCAPE=1 (wave788)"
fi
# wave789: B7A heat shell auto-dispatch
if ! grep -q 'SWALLOWED_B7A_HEAT_SHELL_DISPATCH=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7A_HEAT_SHELL_DISPATCH=1 (wave789)"
fi
if ! grep -q 'B7A_HEAT_SHELL_DISPATCH_SWALLOWED=1' <<<"$_out"; then
  bad "dump B7A_HEAT_SHELL_DISPATCH_SWALLOWED must be 1 (wave789)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_HEAT_SHELL_DISPATCH=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_HEAT_SHELL_DISPATCH=1 (wave789)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_BODY_SWALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_BUCKET_B7A_BODY_SWALLOWED=0 (wave790 not full B7A)"
fi
# wave790: Makefile ensure recipes unify → try-heat
if ! grep -q 'SWALLOWED_B7A_HEAT_THIN_UNIFY=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7A_HEAT_THIN_UNIFY=1 (wave790)"
fi
if ! grep -q 'B7A_HEAT_THIN_UNIFY_SWALLOWED=1' <<<"$_out"; then
  bad "dump B7A_HEAT_THIN_UNIFY_SWALLOWED must be 1 (wave790)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_HEAT_THIN_UNIFY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_HEAT_THIN_UNIFY=1 (wave790)"
fi
if ! grep -q 'PHYS_DEL_PREP_NEXT=B7_physical_delete_makefile_after_windows_not_this_wave' <<<"$_out"; then
  bad "dump PHYS_DEL_PREP_NEXT must stay physical-delete-after-windows (wave793)"
fi
# wave791–797: FORCE dep-edge thin (… · orch last)
if ! grep -q 'SWALLOWED_B7A_HEAT_DEP_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7A_HEAT_DEP_THIN=1 (wave791–797)"
fi
if ! grep -q 'B7A_HEAT_DEP_THIN_SWALLOWED=1' <<<"$_out"; then
  bad "dump B7A_HEAT_DEP_THIN_SWALLOWED must be 1 (wave791–797)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN=1 (wave791–797)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN_COUNT=113' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_HEAT_DEP_THIN_COUNT=113 (wave797)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=0' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=0 (wave797 orch closed; source-prereq residual done)"
fi
# wave798: physical-delete preflight readiness (NOT delete; NOT Windows green)
if ! grep -q 'PHYS_DEL_PREFLIGHT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT=1 (wave798)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_WAVE=wave798' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_WAVE=wave798"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_HEAT_CLOSED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_HEAT_CLOSED=1 (wave798)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B1_B6_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B1_B6_BODY_SWALLOWED=1 (wave798)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_FORCE_DEP_THIN=113' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_FORCE_DEP_THIN=113 (wave798)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body' <<<"$_out"; then
  bad "dump PHYS_DEL_PREFLIGHT_NEXT must be continue_shell_primary_then_explicit_auth_ship_delete_body (wave811)"
fi
if ! grep -q 'PHYS_DEL_STD_X_HYBRID_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_HYBRID_THIN=1 (wave811)"
fi
if ! grep -q 'PHYS_DEL_STD_X_HYBRID_THIN_WAVE=wave811' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_HYBRID_THIN_WAVE=wave811"
fi
if ! grep -q 'PHYS_DEL_STD_X_HYBRID_THIN_COUNT=22' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_HYBRID_THIN_COUNT=22 (wave811)"
fi
if ! grep -q 'SWALLOWED_STD_X_HYBRID_BODY=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_STD_X_HYBRID_BODY=1 (wave811)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_STD_X_HYBRID_BODY_SWALLOWED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_STD_X_HYBRID_BODY_SWALLOWED=1 (wave811)"
fi
if ! grep -q 'PHYS_DEL_STD_X_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_SHELL_PRIMARY=1 (wave825)"
fi
if ! grep -q 'PHYS_DEL_STD_X_SHELL_PRIMARY_WAVE=wave825' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_SHELL_PRIMARY_WAVE=wave825"
fi
if ! grep -q 'PHYS_DEL_STD_X_SHELL_PRIMARY_COUNT=22' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_SHELL_PRIMARY_COUNT=22 (wave825)"
fi
if ! grep -q 'SWALLOWED_STD_X_CATALOG=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_STD_X_CATALOG=1 (wave825)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_STD_X_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_STD_X_SHELL_PRIMARY=1 (wave825)"
fi
if ! grep -q 'PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY=1 (wave812)"
fi
if ! grep -q 'PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_WAVE=wave812' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_WAVE=wave812"
fi
if ! grep -q 'PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_COUNT=38' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FORMAL_MOD_SHELL_PRIMARY_COUNT=38 (wave812)"
fi
if ! grep -q 'SWALLOWED_FORMAL_MOD_CATALOG=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_FORMAL_MOD_CATALOG=1 (wave812)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_FORMAL_MOD_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_FORMAL_MOD_SHELL_PRIMARY=1 (wave812)"
fi
if ! grep -q 'PHYS_DEL_FORMAL_MOD_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FORMAL_MOD_FORCE_THIN=1 (wave826)"
fi
if ! grep -q 'PHYS_DEL_FORMAL_MOD_FORCE_THIN_WAVE=wave826' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FORMAL_MOD_FORCE_THIN_WAVE=wave826"
fi
if ! grep -q 'PHYS_DEL_FORMAL_MOD_FORCE_THIN_COUNT=38' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FORMAL_MOD_FORCE_THIN_COUNT=38 (wave826)"
fi
if ! grep -q 'SWALLOWED_FORMAL_MOD_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_FORMAL_MOD_FORCE_THIN=1 (wave826)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_FORMAL_MOD_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_FORMAL_MOD_FORCE_THIN=1 (wave826)"
fi
if ! grep -q 'PHYS_DEL_STD_X_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_FORCE_THIN=1 (wave827)"
fi
if ! grep -q 'PHYS_DEL_STD_X_FORCE_THIN_WAVE=wave827' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_FORCE_THIN_WAVE=wave827"
fi
if ! grep -q 'PHYS_DEL_STD_X_FORCE_THIN_COUNT=22' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STD_X_FORCE_THIN_COUNT=22 (wave827)"
fi
if ! grep -q 'SWALLOWED_STD_X_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_STD_X_FORCE_THIN=1 (wave827)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_STD_X_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_STD_X_FORCE_THIN=1 (wave827)"
fi
if ! grep -q 'PHYS_DEL_B7B_STD_AND_PANIC_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_STD_AND_PANIC_LIST=1 (wave813)"
fi
if ! grep -q 'PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY=1 (wave814)"
fi
if ! grep -q 'PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_WAVE=wave814' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_WAVE=wave814"
fi
if ! grep -q 'PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_COUNT=8' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DRIVER_LEAF_SHELL_PRIMARY_COUNT=8 (wave814)"
fi
if ! grep -q 'SWALLOWED_DRIVER_LEAF_CATALOG=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_DRIVER_LEAF_CATALOG=1 (wave814)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_DRIVER_LEAF_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_DRIVER_LEAF_SHELL_PRIMARY=1 (wave814)"
fi
if ! grep -q 'PHYS_DEL_DRIVER_LEAF_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DRIVER_LEAF_FORCE_THIN=1 (wave828)"
fi
if ! grep -q 'PHYS_DEL_DRIVER_LEAF_FORCE_THIN_WAVE=wave828' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DRIVER_LEAF_FORCE_THIN_WAVE=wave828"
fi
if ! grep -q 'PHYS_DEL_DRIVER_LEAF_FORCE_THIN_COUNT=8' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DRIVER_LEAF_FORCE_THIN_COUNT=8 (wave828)"
fi
if ! grep -q 'SWALLOWED_DRIVER_LEAF_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_DRIVER_LEAF_FORCE_THIN=1 (wave828)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_DRIVER_LEAF_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_DRIVER_LEAF_FORCE_THIN=1 (wave828)"
fi
if ! grep -q 'PHYS_DEL_GEN_C_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_GEN_C_FORCE_THIN=1 (wave829)"
fi
if ! grep -q 'PHYS_DEL_GEN_C_FORCE_THIN_WAVE=wave829' <<<"$_out"; then
  bad "dump must set PHYS_DEL_GEN_C_FORCE_THIN_WAVE=wave829"
fi
if ! grep -q 'PHYS_DEL_GEN_C_FORCE_THIN_COUNT=17' <<<"$_out"; then
  bad "dump must set PHYS_DEL_GEN_C_FORCE_THIN_COUNT=17 (wave829)"
fi
if ! grep -q 'SWALLOWED_GEN_C_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_GEN_C_FORCE_THIN=1 (wave829)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_GEN_C_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_GEN_C_FORCE_THIN=1 (wave829)"
fi
if ! grep -q 'PHYS_DEL_AST_GEN2_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_AST_GEN2_FORCE_THIN=1 (wave830)"
fi
if ! grep -q 'PHYS_DEL_AST_GEN2_FORCE_THIN_WAVE=wave830' <<<"$_out"; then
  bad "dump must set PHYS_DEL_AST_GEN2_FORCE_THIN_WAVE=wave830"
fi
if ! grep -q 'PHYS_DEL_AST_GEN2_FORCE_THIN_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_AST_GEN2_FORCE_THIN_COUNT=1 (wave830)"
fi
if ! grep -q 'SWALLOWED_AST_GEN2_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_AST_GEN2_FORCE_THIN=1 (wave830)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_AST_GEN2_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_AST_GEN2_FORCE_THIN=1 (wave830)"
fi
if ! grep -q 'PHYS_DEL_SRC_EDGE_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_SRC_EDGE_FORCE_THIN=1 (wave831)"
fi
if ! grep -q 'PHYS_DEL_SRC_EDGE_FORCE_THIN_WAVE=wave831' <<<"$_out"; then
  bad "dump must set PHYS_DEL_SRC_EDGE_FORCE_THIN_WAVE=wave831"
fi
if ! grep -q 'PHYS_DEL_SRC_EDGE_FORCE_THIN_COUNT=7' <<<"$_out"; then
  bad "dump must set PHYS_DEL_SRC_EDGE_FORCE_THIN_COUNT=7 (wave831)"
fi
if ! grep -q 'SWALLOWED_SRC_EDGE_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_SRC_EDGE_FORCE_THIN=1 (wave831)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_SRC_EDGE_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_SRC_EDGE_FORCE_THIN=1 (wave831)"
fi
if ! grep -q 'PHYS_DEL_MIGRATE_X_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_MIGRATE_X_FORCE_THIN=1 (wave832)"
fi
if ! grep -q 'PHYS_DEL_MIGRATE_X_FORCE_THIN_WAVE=wave832' <<<"$_out"; then
  bad "dump must set PHYS_DEL_MIGRATE_X_FORCE_THIN_WAVE=wave832"
fi
if ! grep -q 'PHYS_DEL_MIGRATE_X_FORCE_THIN_COUNT=3' <<<"$_out"; then
  bad "dump must set PHYS_DEL_MIGRATE_X_FORCE_THIN_COUNT=3 (wave832)"
fi
if ! grep -q 'SWALLOWED_MIGRATE_X_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_MIGRATE_X_FORCE_THIN=1 (wave832)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_MIGRATE_X_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_MIGRATE_X_FORCE_THIN=1 (wave832)"
fi
if ! grep -q 'PHYS_DEL_GLUE_TYPES_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_GLUE_TYPES_FORCE_THIN=1 (wave833)"
fi
if ! grep -q 'PHYS_DEL_GLUE_TYPES_FORCE_THIN_WAVE=wave833' <<<"$_out"; then
  bad "dump must set PHYS_DEL_GLUE_TYPES_FORCE_THIN_WAVE=wave833"
fi
if ! grep -q 'PHYS_DEL_GLUE_TYPES_FORCE_THIN_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_GLUE_TYPES_FORCE_THIN_COUNT=1 (wave833)"
fi
if ! grep -q 'SWALLOWED_GLUE_TYPES_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_GLUE_TYPES_FORCE_THIN=1 (wave833)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_GLUE_TYPES_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_GLUE_TYPES_FORCE_THIN=1 (wave833)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN=1 (wave834)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_WAVE=wave834' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_WAVE=wave834"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_COUNT=1 (wave834)"
fi
if ! grep -q 'SWALLOWED_BOOTSTRAP_PIPELINE_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BOOTSTRAP_PIPELINE_FORCE_THIN=1 (wave834)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BOOTSTRAP_PIPELINE_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BOOTSTRAP_PIPELINE_FORCE_THIN=1 (wave834)"
fi
if ! grep -q 'PHYS_DEL_FILTERED_O_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FILTERED_O_FORCE_THIN=1 (wave835)"
fi
if ! grep -q 'PHYS_DEL_FILTERED_O_FORCE_THIN_WAVE=wave835' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FILTERED_O_FORCE_THIN_WAVE=wave835"
fi
if ! grep -q 'PHYS_DEL_FILTERED_O_FORCE_THIN_COUNT=4' <<<"$_out"; then
  bad "dump must set PHYS_DEL_FILTERED_O_FORCE_THIN_COUNT=4 (wave835)"
fi
if ! grep -q 'SWALLOWED_FILTERED_O_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_FILTERED_O_FORCE_THIN=1 (wave835)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_FILTERED_O_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_FILTERED_O_FORCE_THIN=1 (wave835)"
fi
if ! grep -q 'PHYS_DEL_CP_ALIAS_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CP_ALIAS_FORCE_THIN=1 (wave836)"
fi
if ! grep -q 'PHYS_DEL_CP_ALIAS_FORCE_THIN_WAVE=wave836' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CP_ALIAS_FORCE_THIN_WAVE=wave836"
fi
if ! grep -q 'PHYS_DEL_CP_ALIAS_FORCE_THIN_COUNT=3' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CP_ALIAS_FORCE_THIN_COUNT=3 (wave836)"
fi
if ! grep -q 'SWALLOWED_CP_ALIAS_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_CP_ALIAS_FORCE_THIN=1 (wave836)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_CP_ALIAS_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_CP_ALIAS_FORCE_THIN=1 (wave836)"
fi
if ! grep -q 'PHYS_DEL_PIPELINE_GEN_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PIPELINE_GEN_FORCE_THIN=1 (wave837)"
fi
if ! grep -q 'PHYS_DEL_PIPELINE_GEN_FORCE_THIN_WAVE=wave837' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PIPELINE_GEN_FORCE_THIN_WAVE=wave837"
fi
if ! grep -q 'PHYS_DEL_PIPELINE_GEN_FORCE_THIN_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PIPELINE_GEN_FORCE_THIN_COUNT=1 (wave837)"
fi
if ! grep -q 'SWALLOWED_PIPELINE_GEN_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_PIPELINE_GEN_FORCE_THIN=1 (wave837)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_PIPELINE_GEN_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_PIPELINE_GEN_FORCE_THIN=1 (wave837)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN=1 (wave838)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_WAVE=wave838' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_WAVE=wave838"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_XLANGC_FORCE_THIN_COUNT=1 (wave838)"
fi
if ! grep -q 'SWALLOWED_BOOTSTRAP_XLANGC_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BOOTSTRAP_XLANGC_FORCE_THIN=1 (wave838)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BOOTSTRAP_XLANGC_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BOOTSTRAP_XLANGC_FORCE_THIN=1 (wave838)"
fi
if ! grep -q 'PHYS_DEL_ARCH_HOST_PICK_PHONY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ARCH_HOST_PICK_PHONY=1 (wave815)"
fi
if ! grep -q 'PHYS_DEL_ARCH_HOST_PICK_PHONY_WAVE=wave815' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ARCH_HOST_PICK_PHONY_WAVE=wave815"
fi
if ! grep -q 'PHYS_DEL_ARCH_HOST_PICK_PHONY_COUNT=4' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ARCH_HOST_PICK_PHONY_COUNT=4 (wave815)"
fi
if ! grep -q 'SWALLOWED_ARCH_HOST_PICK_PHONY=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_ARCH_HOST_PICK_PHONY=1 (wave815)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_PHONY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_PHONY=1 (wave815)"
fi
if ! grep -q 'PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN=1 (wave839)"
fi
if ! grep -q 'PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_WAVE=wave839' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_WAVE=wave839"
fi
if ! grep -q 'PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_COUNT=4' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ARCH_HOST_PICK_FORCE_THIN_COUNT=4 (wave839)"
fi
if ! grep -q 'SWALLOWED_ARCH_HOST_PICK_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_ARCH_HOST_PICK_FORCE_THIN=1 (wave839)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_FORCE_THIN=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_FORCE_THIN=1 (wave839)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1 (wave841)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_WAVE=wave841' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_WAVE=wave841"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_COUNT=2' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_TYPECK_CODEGEN_SHELL_COUNT=2 (wave841)"
fi
if ! grep -q 'SWALLOWED_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1 (wave841)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BOOTSTRAP_TYPECK_CODEGEN_SHELL=1 (wave841)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL=1 (wave842)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_WAVE=wave842' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_WAVE=wave842"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_X_COMPILER_SHELL_COUNT=1 (wave842)"
fi
if ! grep -q 'SWALLOWED_BOOTSTRAP_X_COMPILER_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BOOTSTRAP_X_COMPILER_SHELL=1 (wave842)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BOOTSTRAP_X_COMPILER_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BOOTSTRAP_X_COMPILER_SHELL=1 (wave842)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_SELF_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_SELF_SHELL=1 (wave843)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_SELF_SHELL_WAVE=wave843' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_SELF_SHELL_WAVE=wave843"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_SELF_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_SELF_SHELL_COUNT=1 (wave843)"
fi
if ! grep -q 'SWALLOWED_BOOTSTRAP_SELF_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BOOTSTRAP_SELF_SHELL=1 (wave843)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BOOTSTRAP_SELF_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BOOTSTRAP_SELF_SHELL=1 (wave843)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_PARSER_SMOKE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_PARSER_SMOKE=1 (wave844)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_WAVE=wave844' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_WAVE=wave844"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_COUNT=2' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_PARSER_SMOKE_COUNT=2 (wave844)"
fi
if ! grep -q 'SWALLOWED_BOOTSTRAP_PARSER_SMOKE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BOOTSTRAP_PARSER_SMOKE=1 (wave844)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BOOTSTRAP_PARSER_SMOKE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BOOTSTRAP_PARSER_SMOKE=1 (wave844)"
fi
if ! grep -q 'PHYS_DEL_XLANG_X_PIPELINE_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_X_PIPELINE_SHELL=1 (wave845)"
fi
if ! grep -q 'PHYS_DEL_XLANG_X_PIPELINE_SHELL_WAVE=wave845' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_X_PIPELINE_SHELL_WAVE=wave845"
fi
if ! grep -q 'PHYS_DEL_XLANG_X_PIPELINE_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_X_PIPELINE_SHELL_COUNT=1 (wave845)"
fi
if ! grep -q 'SWALLOWED_XLANG_X_PIPELINE_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_XLANG_X_PIPELINE_SHELL=1 (wave845)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_XLANG_X_PIPELINE_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_XLANG_X_PIPELINE_SHELL=1 (wave845)"
fi
if ! grep -q 'PHYS_DEL_XLANG_X_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_X_SHELL=1 (wave846)"
fi
if ! grep -q 'PHYS_DEL_XLANG_X_SHELL_WAVE=wave846' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_X_SHELL_WAVE=wave846"
fi
if ! grep -q 'PHYS_DEL_XLANG_X_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_X_SHELL_COUNT=1 (wave846)"
fi
if ! grep -q 'SWALLOWED_XLANG_X_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_XLANG_X_SHELL=1 (wave846)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_XLANG_X_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_XLANG_X_SHELL=1 (wave846)"
fi
if ! grep -q 'PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL=1 (wave847)"
fi
if ! grep -q 'PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_WAVE=wave847' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_WAVE=wave847"
fi
if ! grep -q 'PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_NO_C_FRONTEND_SHELL_COUNT=1 (wave847)"
fi
if ! grep -q 'SWALLOWED_XLANG_NO_C_FRONTEND_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_XLANG_NO_C_FRONTEND_SHELL=1 (wave847)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_XLANG_NO_C_FRONTEND_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_XLANG_NO_C_FRONTEND_SHELL=1 (wave847)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1 (wave848)"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_WAVE=wave848' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_WAVE=wave848"
fi
if ! grep -q 'PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BOOTSTRAP_SEED_X_FRONTEND_SHELL_COUNT=1 (wave848)"
fi
if ! grep -q 'SWALLOWED_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1 (wave848)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BOOTSTRAP_SEED_X_FRONTEND_SHELL=1 (wave848)"
fi
if ! grep -q 'PHYS_DEL_RELINK_XLANG_LEXER_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_RELINK_XLANG_LEXER_SHELL=1 (wave849)"
fi
if ! grep -q 'PHYS_DEL_RELINK_XLANG_LEXER_SHELL_WAVE=wave849' <<<"$_out"; then
  bad "dump must set PHYS_DEL_RELINK_XLANG_LEXER_SHELL_WAVE=wave849"
fi
if ! grep -q 'PHYS_DEL_RELINK_XLANG_LEXER_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_RELINK_XLANG_LEXER_SHELL_COUNT=1 (wave849)"
fi
if ! grep -q 'SWALLOWED_RELINK_XLANG_LEXER_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_RELINK_XLANG_LEXER_SHELL=1 (wave849)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_RELINK_XLANG_LEXER_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_RELINK_XLANG_LEXER_SHELL=1 (wave849)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY=1 (wave841–wave849)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=11' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_COUNT=11 (wave849)"
fi
if ! grep -q 'PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave849' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUCKET_B7C_SHELL_PRIMARY_WAVE=wave849"
fi
if ! grep -q 'PHYS_DEL_B7B_DRIVER_SUBCMD_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_DRIVER_SUBCMD_LIST=1 (wave816)"
fi
if ! grep -q 'PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_WAVE=wave816' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_WAVE=wave816"
fi
if ! grep -q 'PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_COUNT=7' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_DRIVER_SUBCMD_LIST_COUNT=7 (wave816)"
fi
if ! grep -q 'SWALLOWED_B7B_DRIVER_SUBCMD_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_DRIVER_SUBCMD_LIST=1 (wave816)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_DRIVER_SUBCMD_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_DRIVER_SUBCMD_LIST=1 (wave816)"
fi
if ! grep -q 'PHYS_DEL_B7B_PIPELINE_X_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_PIPELINE_X_LIST=1 (wave817)"
fi
if ! grep -q 'PHYS_DEL_B7B_PIPELINE_X_LIST_WAVE=wave817' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_PIPELINE_X_LIST_WAVE=wave817"
fi
if ! grep -q 'PHYS_DEL_B7B_PIPELINE_X_LIST_COUNT=9' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_PIPELINE_X_LIST_COUNT=9 (wave817)"
fi
if ! grep -q 'SWALLOWED_B7B_PIPELINE_X_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_PIPELINE_X_LIST=1 (wave817)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_PIPELINE_X_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_PIPELINE_X_LIST=1 (wave817)"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_MODE_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_MODE_LIST=1 (wave818)"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_MODE_LIST_WAVE=wave818' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_MODE_LIST_WAVE=wave818"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_MODE_LIST_COUNT=3' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_MODE_LIST_COUNT=3 (wave818)"
fi
if ! grep -q 'SWALLOWED_B7B_SEED_MODE_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_SEED_MODE_LIST=1 (wave818)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_SEED_MODE_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_SEED_MODE_LIST=1 (wave818)"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_LINK_PICKS_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_LINK_PICKS_LIST=1 (wave819)"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_WAVE=wave819' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_WAVE=wave819"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_COUNT=2' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_LINK_PICKS_LIST_COUNT=2 (wave819)"
fi
if ! grep -q 'SWALLOWED_B7B_SEED_LINK_PICKS_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_SEED_LINK_PICKS_LIST=1 (wave819)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_SEED_LINK_PICKS_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_SEED_LINK_PICKS_LIST=1 (wave819)"
fi
if ! grep -q 'PHYS_DEL_B7B_OBJS_CORE_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_OBJS_CORE_LIST=1 (wave820)"
fi
if ! grep -q 'PHYS_DEL_B7B_OBJS_CORE_LIST_WAVE=wave820' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_OBJS_CORE_LIST_WAVE=wave820"
fi
if ! grep -q 'PHYS_DEL_B7B_OBJS_CORE_LIST_COUNT=16' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_OBJS_CORE_LIST_COUNT=16 (wave820)"
fi
if ! grep -q 'SWALLOWED_B7B_OBJS_CORE_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_OBJS_CORE_LIST=1 (wave820)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_OBJS_CORE_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_OBJS_CORE_LIST=1 (wave820)"
fi
if ! grep -q 'PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST=1 (wave821)"
fi
if ! grep -q 'PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_WAVE=wave821' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_WAVE=wave821"
fi
if ! grep -q 'PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_COUNT=7' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_ARCH_EXPERIMENT_LIST_COUNT=7 (wave821)"
fi
if ! grep -q 'SWALLOWED_B7B_ARCH_EXPERIMENT_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_ARCH_EXPERIMENT_LIST=1 (wave821)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_ARCH_EXPERIMENT_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_ARCH_EXPERIMENT_LIST=1 (wave821)"
fi
if ! grep -q 'PHYS_DEL_B7B_RELINK_LEGACY_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RELINK_LEGACY_LIST=1 (wave822)"
fi
if ! grep -q 'PHYS_DEL_B7B_RELINK_LEGACY_LIST_WAVE=wave822' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RELINK_LEGACY_LIST_WAVE=wave822"
fi
if ! grep -q 'PHYS_DEL_B7B_RELINK_LEGACY_LIST_COUNT=14' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RELINK_LEGACY_LIST_COUNT=14 (wave822)"
fi
if ! grep -q 'SWALLOWED_B7B_RELINK_LEGACY_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_RELINK_LEGACY_LIST=1 (wave822)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_RELINK_LEGACY_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_RELINK_LEGACY_LIST=1 (wave822)"
fi
if ! grep -q 'PHYS_DEL_B7B_SOURCE_DEPS_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SOURCE_DEPS_LIST=1 (wave823)"
fi
if ! grep -q 'PHYS_DEL_B7B_SOURCE_DEPS_LIST_WAVE=wave823' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SOURCE_DEPS_LIST_WAVE=wave823"
fi
if ! grep -q 'PHYS_DEL_B7B_SOURCE_DEPS_LIST_COUNT=19' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SOURCE_DEPS_LIST_COUNT=19 (wave823)"
fi
if ! grep -q 'SWALLOWED_B7B_SOURCE_DEPS_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_SOURCE_DEPS_LIST=1 (wave823)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_SOURCE_DEPS_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_SOURCE_DEPS_LIST=1 (wave823)"
fi
if ! grep -q 'PHYS_DEL_B7B_E_DIRS_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_E_DIRS_LIST=1 (wave824)"
fi
if ! grep -q 'PHYS_DEL_B7B_E_DIRS_LIST_WAVE=wave824' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_E_DIRS_LIST_WAVE=wave824"
fi
if ! grep -q 'PHYS_DEL_B7B_E_DIRS_LIST_COUNT=26' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_E_DIRS_LIST_COUNT=26 (wave824)"
fi
if ! grep -q 'SWALLOWED_B7B_E_DIRS_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_E_DIRS_LIST=1 (wave824)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_E_DIRS_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_E_DIRS_LIST=1 (wave824)"
fi
# wave850: B7B RELINK_PRODUCT_LINK bag authority
if ! grep -q 'PHYS_DEL_B7B_RELINK_PRODUCT_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RELINK_PRODUCT_LINK=1 (wave850)"
fi
if ! grep -q 'PHYS_DEL_B7B_RELINK_PRODUCT_LINK_WAVE=wave850' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RELINK_PRODUCT_LINK_WAVE=wave850"
fi
if ! grep -q 'PHYS_DEL_B7B_RELINK_PRODUCT_LINK_COUNT=8' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RELINK_PRODUCT_LINK_COUNT=8 (wave850)"
fi
if ! grep -q 'SWALLOWED_B7B_RELINK_PRODUCT_LINK=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_RELINK_PRODUCT_LINK=1 (wave850)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_RELINK_PRODUCT_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_RELINK_PRODUCT_LINK=1 (wave850)"
fi
# wave851: B7B XXL/BS/XNC full link bag authority
if ! grep -q 'PHYS_DEL_B7B_XXL_BS_XNC_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_XXL_BS_XNC_LINK=1 (wave851)"
fi
if ! grep -q 'PHYS_DEL_B7B_XXL_BS_XNC_LINK_WAVE=wave851' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_XXL_BS_XNC_LINK_WAVE=wave851"
fi
if ! grep -q 'PHYS_DEL_B7B_XXL_BS_XNC_LINK_COUNT=3' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_XXL_BS_XNC_LINK_COUNT=3 (wave851)"
fi
if ! grep -q 'SWALLOWED_B7B_XXL_BS_XNC_LINK=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_XXL_BS_XNC_LINK=1 (wave851)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_XXL_BS_XNC_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_XXL_BS_XNC_LINK=1 (wave851)"
fi
# wave852: B7B BXF full link bag authority
if ! grep -q 'PHYS_DEL_B7B_BXF_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_BXF_LINK=1 (wave852)"
fi
if ! grep -q 'PHYS_DEL_B7B_BXF_LINK_WAVE=wave852' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_BXF_LINK_WAVE=wave852"
fi
if ! grep -q 'PHYS_DEL_B7B_BXF_LINK_COUNT=2' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_BXF_LINK_COUNT=2 (wave852)"
fi
if ! grep -q 'SWALLOWED_B7B_BXF_LINK=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_BXF_LINK=1 (wave852)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_BXF_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_BXF_LINK=1 (wave852)"
fi
# wave853: B7B seed phase1/final full link bag authority
if ! grep -q 'PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK=1 (wave853)"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_WAVE=wave853' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_WAVE=wave853"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_COUNT=2' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_PHASE_FINAL_LINK_COUNT=2 (wave853)"
fi
if ! grep -q 'SWALLOWED_B7B_SEED_PHASE_FINAL_LINK=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_SEED_PHASE_FINAL_LINK=1 (wave853)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_SEED_PHASE_FINAL_LINK=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_SEED_PHASE_FINAL_LINK=1 (wave853)"
fi
# wave854: B7B seed-gate REQUIRED_OBJS bag authority
if ! grep -q 'PHYS_DEL_B7B_SEED_GATE_REQUIRED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_GATE_REQUIRED=1 (wave854)"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_GATE_REQUIRED_WAVE=wave854' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_GATE_REQUIRED_WAVE=wave854"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_GATE_REQUIRED_COUNT=3' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_GATE_REQUIRED_COUNT=3 (wave854)"
fi
if ! grep -q 'SWALLOWED_B7B_SEED_GATE_REQUIRED=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_SEED_GATE_REQUIRED=1 (wave854)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_SEED_GATE_REQUIRED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_SEED_GATE_REQUIRED=1 (wave854)"
fi
# wave855: seed-gate REQUIRED shell-load from mk (no Makefile multi-token env)
if ! grep -q 'PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1 (wave855)"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_WAVE=wave855' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_WAVE=wave855"
fi
if ! grep -q 'PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_COUNT=3' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_SEED_GATE_REQUIRED_SHELL_LOAD_COUNT=3 (wave855)"
fi
if ! grep -q 'SWALLOWED_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1 (wave855)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_SEED_GATE_REQUIRED_SHELL_LOAD=1 (wave855)"
fi
# wave856: LINK_OBJS shell-load via make export leaves
if ! grep -q 'PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD=1 (wave856)"
fi
if ! grep -q 'PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_WAVE=wave856' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_WAVE=wave856"
fi
if ! grep -q 'PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_COUNT=5' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LINK_OBJS_SHELL_LOAD_COUNT=5 (wave856)"
fi
if ! grep -q 'SWALLOWED_B7B_LINK_OBJS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_LINK_OBJS_SHELL_LOAD=1 (wave856)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_LINK_OBJS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_LINK_OBJS_SHELL_LOAD=1 (wave856)"
fi

# wave857: LINK_CFLAGS shell-load via make export leaves
if ! grep -q 'PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD=1 (wave857)"
fi
if ! grep -q 'PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_WAVE=wave857' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_WAVE=wave857"
fi
if ! grep -q 'PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_COUNT=4' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LINK_CFLAGS_SHELL_LOAD_COUNT=4 (wave857)"
fi
if ! grep -q 'SWALLOWED_B7B_LINK_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_LINK_CFLAGS_SHELL_LOAD=1 (wave857)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_LINK_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_LINK_CFLAGS_SHELL_LOAD=1 (wave857)"
fi
# wave858: LEGACY xlang-c shell-primary
if ! grep -q 'PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1 (wave858)"
fi
if ! grep -q 'PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_WAVE=wave858' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LEGACY_XLANG_C_SHELL_PRIMARY_WAVE=wave858"
fi
if ! grep -q 'SWALLOWED_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1 (wave858)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_LEGACY_XLANG_C_SHELL_PRIMARY=1 (wave858)"
fi
# wave859: XXP/BXC multi-token bag shell-load
if ! grep -q 'PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD=1 (wave859)"
fi
if ! grep -q 'PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_WAVE=wave859' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_WAVE=wave859"
fi
if ! grep -q 'PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_COUNT=2' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_XXP_BXC_SHELL_LOAD_COUNT=2 (wave859)"
fi
if ! grep -q 'SWALLOWED_B7B_XXP_BXC_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_XXP_BXC_SHELL_LOAD=1 (wave859)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_XXP_BXC_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_XXP_BXC_SHELL_LOAD=1 (wave859)"
fi
# wave860: driver_leaf BASE_CFLAGS multi-token shell-load
if ! grep -q 'PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1 (wave860)"
fi
if ! grep -q 'PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_WAVE=wave860' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_WAVE=wave860"
fi
if ! grep -q 'PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_COUNT=8' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD_COUNT=8 (wave860)"
fi
if ! grep -q 'SWALLOWED_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1 (wave860)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_DRIVER_LEAF_BASE_CFLAGS_SHELL_LOAD=1 (wave860)"
fi
# wave861: RT_SEED_SLICE multi-token -I CFLAGS hygiene
if ! grep -q 'PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1 (wave861)"
fi
if ! grep -q 'PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_WAVE=wave861' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_WAVE=wave861"
fi
if ! grep -q 'PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_COUNT=5' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_RT_SLICE_I_CFLAGS_HYGIENE_COUNT=5 (wave861)"
fi
if ! grep -q 'SWALLOWED_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1 (wave861)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_RT_SLICE_I_CFLAGS_HYGIENE=1 (wave861)"
fi
# wave862: try-heat CFLAGS bulk shell-load
if ! grep -q 'PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1 (wave862)"
fi
if ! grep -q 'PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_WAVE=wave862' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_WAVE=wave862"
fi
if ! grep -q 'PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_COUNT=114' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD_COUNT=114 (wave862)"
fi
if ! grep -q 'SWALLOWED_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1 (wave862)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_TRY_HEAT_CFLAGS_SHELL_LOAD=1 (wave862)"
fi
# wave863: filter CFLAGS bulk shell-load hygiene
if ! grep -q 'PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD=1 (wave863)"
fi
if ! grep -q 'PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_WAVE=wave863' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_WAVE=wave863"
fi
if ! grep -q 'PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_COUNT=4' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_FILTER_CFLAGS_SHELL_LOAD_COUNT=4 (wave863)"
fi
if ! grep -q 'SWALLOWED_B7B_FILTER_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_FILTER_CFLAGS_SHELL_LOAD=1 (wave863)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_FILTER_CFLAGS_SHELL_LOAD=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_FILTER_CFLAGS_SHELL_LOAD=1 (wave863)"
fi
# wave864: leaf-extra RUNTIME_*/PARSER_* multi-token CFLAGS inject hygiene
if ! grep -q 'PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1 (wave864)"
fi
if ! grep -q 'PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_WAVE=wave864' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_WAVE=wave864"
fi
if ! grep -q 'PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_COUNT=3' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_LEAF_EXTRA_CFLAGS_HYGIENE_COUNT=3 (wave864)"
fi
if ! grep -q 'SWALLOWED_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1 (wave864)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_LEAF_EXTRA_CFLAGS_HYGIENE=1 (wave864)"
fi
# wave868: bootstrap-driver-bstrict-relink shell-primary
if ! grep -q 'PHYS_DEL_BSTRICT_RELINK_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BSTRICT_RELINK_SHELL=1 (wave868)"
fi
if ! grep -q 'PHYS_DEL_BSTRICT_RELINK_SHELL_WAVE=wave868' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BSTRICT_RELINK_SHELL_WAVE=wave868"
fi
if ! grep -q 'PHYS_DEL_BSTRICT_RELINK_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BSTRICT_RELINK_SHELL_COUNT=1 (wave868)"
fi
if ! grep -q 'SWALLOWED_BSTRICT_RELINK_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BSTRICT_RELINK_SHELL=1 (wave868)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BSTRICT_RELINK_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BSTRICT_RELINK_SHELL=1 (wave868)"
fi
# wave869: bootstrap-driver-crt0 shell-primary
if ! grep -q 'PHYS_DEL_CRT0_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CRT0_SHELL=1 (wave869)"
fi
if ! grep -q 'PHYS_DEL_CRT0_SHELL_WAVE=wave869' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CRT0_SHELL_WAVE=wave869"
fi
if ! grep -q 'PHYS_DEL_CRT0_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CRT0_SHELL_COUNT=1 (wave869)"
fi
if ! grep -q 'SWALLOWED_CRT0_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_CRT0_SHELL=1 (wave869)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_CRT0_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_CRT0_SHELL=1 (wave869)"
fi
# wave870: check-7.2 shell-primary
if ! grep -q 'PHYS_DEL_CHECK_7_2_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CHECK_7_2_SHELL=1 (wave870)"
fi
if ! grep -q 'PHYS_DEL_CHECK_7_2_SHELL_WAVE=wave870' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CHECK_7_2_SHELL_WAVE=wave870"
fi
if ! grep -q 'PHYS_DEL_CHECK_7_2_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CHECK_7_2_SHELL_COUNT=1 (wave870)"
fi
if ! grep -q 'SWALLOWED_CHECK_7_2_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_CHECK_7_2_SHELL=1 (wave870)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_CHECK_7_2_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_CHECK_7_2_SHELL=1 (wave870)"
fi
# wave871: check-6.4 shell-primary
if ! grep -q 'PHYS_DEL_CHECK_6_4_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CHECK_6_4_SHELL=1 (wave871)"
fi
if ! grep -q 'PHYS_DEL_CHECK_6_4_SHELL_WAVE=wave871' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CHECK_6_4_SHELL_WAVE=wave871"
fi
if ! grep -q 'PHYS_DEL_CHECK_6_4_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_CHECK_6_4_SHELL_COUNT=1 (wave871)"
fi
if ! grep -q 'SWALLOWED_CHECK_6_4_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_CHECK_6_4_SHELL=1 (wave871)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_CHECK_6_4_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_CHECK_6_4_SHELL=1 (wave871)"
fi
# wave872: bootstrap-driver-hybrid shell-primary
if ! grep -q 'PHYS_DEL_HYBRID_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_HYBRID_SHELL=1 (wave872)"
fi
if ! grep -q 'PHYS_DEL_HYBRID_SHELL_WAVE=wave872' <<<"$_out"; then
  bad "dump must set PHYS_DEL_HYBRID_SHELL_WAVE=wave872"
fi
if ! grep -q 'PHYS_DEL_HYBRID_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_HYBRID_SHELL_COUNT=1 (wave872)"
fi
if ! grep -q 'SWALLOWED_HYBRID_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_HYBRID_SHELL=1 (wave872)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_HYBRID_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_HYBRID_SHELL=1 (wave872)"
fi
# wave873: regen-lsp-gens-x shell-primary
if ! grep -q 'PHYS_DEL_REGEN_LSP_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_REGEN_LSP_SHELL=1 (wave873)"
fi
if ! grep -q 'PHYS_DEL_REGEN_LSP_SHELL_WAVE=wave873' <<<"$_out"; then
  bad "dump must set PHYS_DEL_REGEN_LSP_SHELL_WAVE=wave873"
fi
if ! grep -q 'PHYS_DEL_REGEN_LSP_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_REGEN_LSP_SHELL_COUNT=1 (wave873)"
fi
if ! grep -q 'SWALLOWED_REGEN_LSP_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_REGEN_LSP_SHELL=1 (wave873)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_REGEN_LSP_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_REGEN_LSP_SHELL=1 (wave873)"
fi
# wave874: build-via-tool shell-primary
if ! grep -q 'PHYS_DEL_BUILD_VIA_TOOL_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUILD_VIA_TOOL_SHELL=1 (wave874)"
fi
if ! grep -q 'PHYS_DEL_BUILD_VIA_TOOL_SHELL_WAVE=wave874' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUILD_VIA_TOOL_SHELL_WAVE=wave874"
fi
if ! grep -q 'PHYS_DEL_BUILD_VIA_TOOL_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_BUILD_VIA_TOOL_SHELL_COUNT=1 (wave874)"
fi
if ! grep -q 'SWALLOWED_BUILD_VIA_TOOL_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_BUILD_VIA_TOOL_SHELL=1 (wave874)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_BUILD_VIA_TOOL_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_BUILD_VIA_TOOL_SHELL=1 (wave874)"
fi
# wave875: size/perf-baseline shell-primary
if ! grep -q 'PHYS_DEL_STAGE8_BASELINE_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STAGE8_BASELINE_SHELL=1 (wave875)"
fi
if ! grep -q 'PHYS_DEL_STAGE8_BASELINE_SHELL_WAVE=wave875' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STAGE8_BASELINE_SHELL_WAVE=wave875"
fi
if ! grep -q 'PHYS_DEL_STAGE8_BASELINE_SHELL_COUNT=2' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STAGE8_BASELINE_SHELL_COUNT=2 (wave875)"
fi
if ! grep -q 'SWALLOWED_STAGE8_BASELINE_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_STAGE8_BASELINE_SHELL=1 (wave875)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_STAGE8_BASELINE_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_STAGE8_BASELINE_SHELL=1 (wave875)"
fi
# wave876: default $(XLANG_C) product alias shell-primary
if ! grep -q 'PHYS_DEL_XLANG_C_ALIAS_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_C_ALIAS_SHELL=1 (wave876)"
fi
if ! grep -q 'PHYS_DEL_XLANG_C_ALIAS_SHELL_WAVE=wave876' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_C_ALIAS_SHELL_WAVE=wave876"
fi
if ! grep -q 'PHYS_DEL_XLANG_C_ALIAS_SHELL_COUNT=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_XLANG_C_ALIAS_SHELL_COUNT=1 (wave876)"
fi
if ! grep -q 'SWALLOWED_XLANG_C_ALIAS_SHELL=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_XLANG_C_ALIAS_SHELL=1 (wave876)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_XLANG_C_ALIAS_SHELL=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_XLANG_C_ALIAS_SHELL=1 (wave876)"
fi
# wave877: gen ensure multi-token env inject hygiene
if ! grep -q 'PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE=1 (wave877)"
fi
if ! grep -q 'PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_WAVE=wave877' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_WAVE=wave877"
fi
if ! grep -q 'PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_COUNT=20' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_GEN_ENSURE_ENV_HYGIENE_COUNT=20 (wave877)"
fi
if ! grep -q 'SWALLOWED_B7B_GEN_ENSURE_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_GEN_ENSURE_ENV_HYGIENE=1 (wave877)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_GEN_ENSURE_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_GEN_ENSURE_ENV_HYGIENE=1 (wave877)"
fi
# wave878: migrate_x_objs multi-token CC/PYTHON/MAKE inject hygiene
if ! grep -q 'PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE=1 (wave878)"
fi
if ! grep -q 'PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_WAVE=wave878' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_WAVE=wave878"
fi
if ! grep -q 'PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_COUNT=4' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_MIGRATE_ENV_HYGIENE_COUNT=4 (wave878)"
fi
if ! grep -q 'SWALLOWED_B7B_MIGRATE_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_MIGRATE_ENV_HYGIENE=1 (wave878)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_MIGRATE_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_MIGRATE_ENV_HYGIENE=1 (wave878)"
fi
# wave879: stage/bootstrap multi-token TARGET/CC/MAKE inject hygiene
if ! grep -q 'PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1 (wave879)"
fi
if ! grep -q 'PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_WAVE=wave879' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_WAVE=wave879"
fi
if ! grep -q 'PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_COUNT=13' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE_COUNT=13 (wave879)"
fi
if ! grep -q 'SWALLOWED_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1 (wave879)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_STAGE_BOOTSTRAP_ENV_HYGIENE=1 (wave879)"
fi
# wave880: ENSURE=0 / OUT=$@ / all OPT multi-token inject hygiene
if ! grep -q 'PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE=1 (wave880)"
fi
if ! grep -q 'PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_WAVE=wave880' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_WAVE=wave880"
fi
if ! grep -q 'PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_COUNT=7' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_ENSURE_OUT_OPT_HYGIENE_COUNT=7 (wave880)"
fi
if ! grep -q 'SWALLOWED_B7B_ENSURE_OUT_OPT_HYGIENE=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_ENSURE_OUT_OPT_HYGIENE=1 (wave880)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_ENSURE_OUT_OPT_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_ENSURE_OUT_OPT_HYGIENE=1 (wave880)"
fi
if ! grep -q 'PHYS_DEL_B7B_STD_AND_PANIC_LIST_WAVE=wave813' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_STD_AND_PANIC_LIST_WAVE=wave813"
fi
if ! grep -q 'PHYS_DEL_B7B_STD_AND_PANIC_LIST_COUNT=65' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_STD_AND_PANIC_LIST_COUNT=65 (wave813)"
fi
if ! grep -q 'SWALLOWED_B7B_STD_AND_PANIC_LIST=1' <<<"$_out"; then
  bad "dump must set SWALLOWED_B7B_STD_AND_PANIC_LIST=1 (wave813)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_B7B_STD_AND_PANIC_LIST=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_PREFLIGHT_B7B_STD_AND_PANIC_LIST=1 (wave813)"
fi
if ! grep -q 'PHYS_DEL_PREFLIGHT_WIN_GATE_CMD=tests/run-bootstrap-bstrict-windows-gate.sh' <<<"$_out"; then
  bad "dump must name Windows min-gate command (wave798)"
fi
# Honesty: wave804 STATUS flip + wave808 tree arm — STATUS green; ENDGAME=1 TREE_ARMED=1 (not delete).
if ! grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green' <<<"$_out"; then
  bad "wave804 must set PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green (MSYS proof + reviewed apply)"
fi
if ! grep -q 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=1' <<<"$_out"; then
  bad "wave808 must set ENDGAME_PHYSICAL_DELETE_MAKEFILE=1 (reviewed TREE_ARMED arm)"
fi
if grep -qE 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=0' <<<"$_out"; then
  bad "wave808 must not keep ENDGAME=0 after tree arm (delete body still separate)"
fi
if grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip' <<<"$_out"; then
  bad "wave804 must not keep STATUS=not_reproven_this_tip after reviewed apply"
fi
if [ ! -f "$ROOT/tests/run-bootstrap-bstrict-windows-gate.sh" ]; then
  bad "missing tests/run-bootstrap-bstrict-windows-gate.sh (wave798 preflight authority)"
else
  note "Windows min-gate script present (wave798 preflight; run on MSYS2 only)"
fi
# wave799: physical-delete execute gate (refuse rm; NOT delete; NOT Windows green)
if ! grep -q 'PHYS_DEL_EXECUTE_GATE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_EXECUTE_GATE=1 (wave799)"
fi
if ! grep -q 'PHYS_DEL_EXECUTE_GATE_WAVE=wave799' <<<"$_out"; then
  bad "dump must set PHYS_DEL_EXECUTE_GATE_WAVE=wave799"
fi
if ! grep -q 'PHYS_DEL_EXECUTE_GATE_REFUSES_DELETE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_EXECUTE_GATE_REFUSES_DELETE=1 (wave799)"
fi
if ! grep -q 'PHYS_DEL_EXECUTE_GATE_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must set PHYS_DEL_EXECUTE_GATE_DELETE_ALLOWED=0 (wave799)"
fi
if ! grep -q 'PHYS_DEL_EXECUTE_GATE_SCRIPT=compiler/scripts/phys_del_makefile_gate.sh' <<<"$_out"; then
  bad "dump must name phys_del_makefile_gate.sh (wave799)"
fi
if ! grep -q 'PHYS_DEL_WINDOWS_PROOF_HARNESS=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_WINDOWS_PROOF_HARNESS=1 (wave800)"
fi
if ! grep -q 'PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE=wave800' <<<"$_out"; then
  bad "dump must set PHYS_DEL_WINDOWS_PROOF_HARNESS_WAVE=wave800"
fi
if ! grep -q 'PHYS_DEL_WINDOWS_PROOF_STATUS_FLIP=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_WINDOWS_PROOF_STATUS_FLIP=0 (wave800)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_PREP=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_PREP=1 (wave801)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_PREP_WAVE=wave801' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_PREP_WAVE=wave801"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_PREP_APPLIED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_STATUS_FLIP_PREP_APPLIED=0 (wave801)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_PREP_TARGET_STATUS=reproven_green' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_PREP_TARGET_STATUS=reproven_green (wave801)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_PREP_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_STATUS_FLIP_PREP_DELETE_ALLOWED=0 (wave801)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_APPLY_HARNESS=1 (wave802)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE=wave802' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_APPLY_HARNESS_WAVE=wave802"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_APPLY_TREE_APPLIED=1 (wave804 tree applied)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_STATUS_FLIP_APPLY_DELETE_ALLOWED=0 (wave802)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME_AFTER=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_STATUS_FLIP_APPLY_ENDGAME_AFTER=0 (wave802)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY=1 (wave803)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803' <<<"$_out"; then
  bad "dump must set PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_WAVE=wave803"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_DELETE_ALLOWED=0 (wave803)"
fi
if ! grep -q 'PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_STATUS_FLIP_COMMIT_HONESTY_ENDGAME_REQUIRED=0 (wave803)"
fi
# wave805: ENDGAME arm prep / preview (NOT arm; NOT delete; TREE_ARMED=0)
if ! grep -q 'PHYS_DEL_ENDGAME_PREP=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_PREP=1 (wave805)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_PREP_WAVE=wave805' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_PREP_WAVE=wave805"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_PREP_APPLIED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_ENDGAME_PREP_APPLIED=0 (wave805)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_PREP_TREE_ARMED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_ENDGAME_PREP_TREE_ARMED=0 (wave805)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_PREP_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_ENDGAME_PREP_DELETE_ALLOWED=0 (wave805)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_PREP_TARGET_ENDGAME=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_PREP_TARGET_ENDGAME=1 (wave805)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_PREP_MODE=--endgame-preview' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_PREP_MODE=--endgame-preview (wave805)"
fi
# wave806: ENDGAME arm apply harness present; wave808 sets TREE_ARMED=1 on tree.
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS=1 (wave806)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS_WAVE=wave806' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_APPLY_HARNESS_WAVE=wave806"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED=1 (wave808 tree arm)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_APPLY_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_ENDGAME_ARM_APPLY_DELETE_ALLOWED=0 (wave806/808)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_APPLY_TARGET_ENDGAME=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_APPLY_TARGET_ENDGAME=1 (wave806)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_APPLY_REQUIRES_CONFIRM=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_APPLY_REQUIRES_CONFIRM=1 (wave806)"
fi
# wave807: ENDGAME arm commit honesty keys still live; wave808 tree arm applied.
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY=1 (wave807)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_WAVE=wave807' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_WAVE=wave807"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_DELETE_ALLOWED=0 (wave807)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_ENDGAME=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_ENDGAME=1 (wave807)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_TREE_ARMED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_TARGET_TREE_ARMED=1 (wave807)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_MODE=--endgame-arm-commit-honesty' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_ARM_COMMIT_HONESTY_MODE=--endgame-arm-commit-honesty (wave807)"
fi
# wave808: reviewed TREE_ARMED arm markers
if ! grep -q 'PHYS_DEL_ENDGAME_TREE_ARMED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_TREE_ARMED=1 (wave808)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_TREE_ARMED_WAVE=wave808' <<<"$_out"; then
  bad "dump must set PHYS_DEL_ENDGAME_TREE_ARMED_WAVE=wave808"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_TREE_ARMED_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_ENDGAME_TREE_ARMED_DELETE_ALLOWED=0 (wave808 ≠ physical delete)"
fi
# wave809: delete-body prep / preview (NOT ship body; NOT rm; TREE_ARMED already 1)
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_PREP=1 (wave809)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP_WAVE=wave809' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_PREP_WAVE=wave809"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP_APPLIED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_DELETE_BODY_PREP_APPLIED=0 (wave809)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP_BODY_SHIPPED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_DELETE_BODY_PREP_BODY_SHIPPED=0 (wave809)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_DELETE_BODY_PREP_DELETE_ALLOWED=0 (wave809)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP_MODE=--delete-body-preview' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_PREP_MODE=--delete-body-preview (wave809)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP_TARGET_ACTION=rm_compiler_Makefile' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_PREP_TARGET_ACTION=rm_compiler_Makefile (wave809)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_PREP_REQUIRES_TREE_ARMED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_PREP_REQUIRES_TREE_ARMED=1 (wave809)"
fi
# wave810: delete-body commit honesty (NOT ship body; NOT rm; TREE_ARMED already 1)
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_COMMIT_HONESTY=1 (wave810)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_WAVE=wave810' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_WAVE=wave810"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_BODY_SHIPPED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_BODY_SHIPPED=0 (wave810)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_DELETE_ALLOWED=0' <<<"$_out"; then
  bad "dump must keep PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_DELETE_ALLOWED=0 (wave810)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_MODE=--delete-body-commit-honesty' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_MODE=--delete-body-commit-honesty (wave810)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_TARGET_ACTION=rm_compiler_Makefile' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_TARGET_ACTION=rm_compiler_Makefile (wave810)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_REQUIRES_TREE_ARMED=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_REQUIRES_TREE_ARMED=1 (wave810)"
fi
if ! grep -q 'PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_NEXT=explicit_user_auth_then_ship_delete_body' <<<"$_out"; then
  bad "dump must set PHYS_DEL_DELETE_BODY_COMMIT_HONESTY_NEXT=explicit_user_auth_then_ship_delete_body (wave810)"
fi
if [ ! -f "$ROOT/compiler/scripts/phys_del_makefile_gate.sh" ]; then
  bad "missing compiler/scripts/phys_del_makefile_gate.sh (wave799–810 execute-gate + tree arm + delete-body-preview + commit-honesty; never-rm delete body)"
else
  note "phys_del_makefile_gate.sh present (wave799–810; ENDGAME=1 TREE_ARMED=1; delete-body-preview + commit-honesty; --delete still never-rm)"
  # Self-check execute gate + proof + flip + honesty + endgame + tree arm + delete-body-preview + commit-honesty.
  if ! bash "$ROOT/compiler/scripts/phys_del_makefile_gate.sh" --check >/tmp/phys_del_gate_check.$$ 2>&1; then
    cat /tmp/phys_del_gate_check.$$ >&2 || true
    bad "phys_del_makefile_gate.sh --check failed (wave799–810)"
  else
    note "phys_del_makefile_gate.sh --check OK (wave799–810)"
  fi
  rm -f /tmp/phys_del_gate_check.$$
fi
# Honesty: STATUS green + ENDGAME=1 + TREE_ARMED=1; physical delete still separate.
if ! grep -q 'PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green' <<<"$_out"; then
  bad "wave804–810 must keep PHYS_DEL_WINDOWS_GATE_STATUS=reproven_green"
fi
if ! grep -q 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=1' <<<"$_out"; then
  bad "wave808 must set ENDGAME_PHYSICAL_DELETE_MAKEFILE=1 (reviewed tree arm)"
fi
if grep -qE 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=0' <<<"$_out"; then
  bad "wave808 must not keep ENDGAME=0 on tree after TREE_ARMED arm"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_PREP_TREE_ARMED=0' <<<"$_out"; then
  bad "wave808 must keep PHYS_DEL_ENDGAME_PREP_TREE_ARMED=0 (prep key never arms)"
fi
if ! grep -q 'PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED=1' <<<"$_out"; then
  bad "wave808 must set PHYS_DEL_ENDGAME_ARM_APPLY_TREE_ARMED=1"
fi
# Makefile must still exist (tree arm / delete-body-preview / commit-honesty ≠ physical delete).
if [ ! -f "$ROOT/compiler/Makefile" ]; then
  bad "wave810 must keep compiler/Makefile present (delete body not shipped)"
else
  note "compiler/Makefile still present after delete-body-commit-honesty keys (wave810; not physical delete)"
fi
# wave811+wave825: std_x product body + shell-primary catalog — ensure thin on 22 leaves.
if [ ! -f "$COMPILER_DIR/scripts/xlang_compile_std_x.sh" ]; then
  bad "missing xlang_compile_std_x.sh (wave811/wave825 std_x authority)"
fi
if ! grep -q 'auto-soft' "$COMPILER_DIR/scripts/xlang_compile_std_x.sh"; then
  bad "xlang_compile_std_x.sh must support auto-soft (wave811)"
fi
if ! grep -q 'auto-soft-merge\|_merge' "$COMPILER_DIR/scripts/xlang_compile_std_x.sh"; then
  bad "xlang_compile_std_x.sh must support merge mode (wave811 socketio)"
fi
if ! grep -q 'std_x_spec_for_key' "$COMPILER_DIR/scripts/xlang_compile_std_x.sh"; then
  bad "xlang_compile_std_x.sh must define std_x_spec_for_key (wave825 catalog)"
fi
if ! grep -q 'std_x_check' "$COMPILER_DIR/scripts/xlang_compile_std_x.sh"; then
  bad "xlang_compile_std_x.sh must define std_x_check (wave825)"
fi
_stdx_leaves=(
  async/scheduler async/future channel/channel backtrace/backtrace datetime/datetime
  uuid/uuid url/url cli/cli security/security config/config cache/cache
  trace/trace task/task schema/schema db/kv/kv db/arrow/arrow db/sqlite/sqlite
  elf/elf regex/regex unicode/unicode socketio/socketio simd/simd
)
_stdx_thin=0
for _leaf in "${_stdx_leaves[@]}"; do
  if awk -v leaf="../std/${_leaf}.o" '
    $0 ~ ("^" leaf ":") { want=1; next }
    want && /^\t@sh scripts\/xlang_compile_std_x\.sh (ensure|auto) \$@/ { ok=1; exit }
    want && /^\t@sh scripts\/xlang_compile_std_x\.sh (auto|auto-soft|auto-soft-merge) / { ok=1; exit }
    want && /^\t/ { next }
    want && /^[^#\t]/ && $0 !~ /^$/ { exit }
    END { exit ok ? 0 : 1 }
  ' "$MF"; then
    _stdx_thin=$((_stdx_thin + 1))
  else
    bad "Makefile ../std/${_leaf}.o must thin-call xlang_compile_std_x ensure (wave825; wave811 body)"
  fi
done
if [ "$_stdx_thin" -ne 22 ]; then
  bad "wave825 expected 22 std_x ensure leaves, got $_stdx_thin"
else
  note "Makefile std_x 22 leaves thin-call ensure (wave825 catalog; wave811 body; not physical delete)"
fi
# wave825: no explicit mode|path on recipe (catalog owns mode).
_stdx_explicit=0
if awk '
  /^\t@sh scripts\/xlang_compile_std_x\.sh (auto-soft|auto-soft-merge|auto-merge) / { bad=1; exit }
  /^\t@sh scripts\/xlang_compile_std_x\.sh auto \.\./ { bad=1; exit }
  END { exit bad ? 0 : 1 }
' "$MF"; then
  bad "Makefile still has explicit std_x mode+path recipes (wave825 must ensure only)"
else
  note "Makefile std_x free of explicit mode+path recipes (wave825)"
fi
# wave827: std_x FORCE dep-thin — target line FORCE only (no dual .x prereqs).
_stdx_force=0
for _leaf in "${_stdx_leaves[@]}"; do
  if awk -v tgt="../std/${_leaf}.o" '
    $0 ~ ("^" tgt ":") {
      if ($0 ~ /FORCE/ && $0 !~ /\.x([[:space:]]|$)/) { ok=1; exit 0 }
      exit 1
    }
    END { exit ok ? 0 : 1 }
  ' "$MF" 2>/dev/null; then
    _stdx_force=$((_stdx_force + 1))
  else
    bad "Makefile ../std/${_leaf}.o must FORCE dep-thin (no .x prereqs; wave827)"
  fi
done
if [ "$_stdx_force" -ne 22 ]; then
  bad "wave827 expected 22 std_x FORCE thin leaves, got $_stdx_force"
fi
note "Makefile std_x 22 leaves FORCE dep-thin (wave827; not physical delete)"
_stdx_sh="$COMPILER_DIR/scripts/xlang_compile_std_x.sh"
if ! grep -q 'FORCE-thin mtime\|skip up-to-date' "$_stdx_sh"; then
  bad "xlang_compile_std_x.sh must own FORCE-thin mtime skip (wave827)"
else
  note "std_x ensure owns source mtime skip (wave827)"
fi
# --check resolves ../std sources from compiler/; run with cwd=compiler/.
if ! ( cd "$COMPILER_DIR" && sh scripts/xlang_compile_std_x.sh --check >/dev/null ); then
  bad "xlang_compile_std_x.sh --check failed (wave825/wave827)"
else
  note "xlang_compile_std_x.sh --check OK (wave827 FORCE thin; not physical delete)"
fi
# Product leaf recipes must not keep the historical multi-line host-pick ladder.
# wave815: archaeology phonies (sqlite-o-stub / net-o-*) also thin — no exclude.
if awk '
  /^\.\.\/std\/.*\.o:/ { inleaf=1; next }
  inleaf && /elif \[ -x \.\/xlang \]; then xlang=/ { bad=1; exit }
  inleaf && /^[^[:space:]#]/ { inleaf=0 }
  END { exit bad ? 0 : 1 }
' "$MF"; then
  bad "Makefile product std/*.o still has host-pick if-ladder (wave811 must thin)"
else
  note "Makefile product std_x leaves free of host-pick if-ladder (wave811)"
fi

# wave812: formal_mod shell-primary — ensure thin on 38 leaves + script catalog/--check.
if [ ! -f "$ROOT/compiler/scripts/xlang_compile_std_module.sh" ] && [ ! -f "scripts/xlang_compile_std_module.sh" ]; then
  bad "missing xlang_compile_std_module.sh (wave812 formal_mod authority)"
fi
_fm_sh="$ROOT/compiler/scripts/xlang_compile_std_module.sh"
[ -f "$_fm_sh" ] || _fm_sh="scripts/xlang_compile_std_module.sh"
if ! grep -q 'formal_mod_spec_for_key' "$_fm_sh"; then
  bad "xlang_compile_std_module.sh must define formal_mod_spec_for_key (wave812)"
fi
if ! grep -qE 'ensure\|auto\)' "$_fm_sh"; then
  bad "xlang_compile_std_module.sh must support ensure|auto (wave812)"
fi
if ! grep -q 'formal_mod_check' "$_fm_sh"; then
  bad "xlang_compile_std_module.sh must support --check (wave812)"
fi
_fm_thin=0
for _fm in \
  string/string heap/heap heap/page_mmap sys/sys sys/linux \
  map/map set/set vec/vec thread/thread time/time random/random env/env \
  fs/fs sync/sync queue/queue encoding/encoding base64/base64 crypto/crypto \
  log/log test/test atomic/atomic hash/hash math/math sort/sort ffi/ffi \
  context/context error/error json/json csv/csv dynlib/dynlib http/http tar/tar
do
  if awk -v tgt="../std/${_fm}.o" '
    $0 ~ ("^" tgt ":") { hit=1; next }
    hit && /^[^#[:space:]]/ { exit 1 }
    hit && /xlang_compile_std_module\.sh/ && /ensure|auto/ { found=1; exit 0 }
    END { exit found ? 0 : 1 }
  ' "$MF" 2>/dev/null; then
    _fm_thin=$((_fm_thin + 1))
  else
    bad "Makefile ../std/${_fm}.o must thin-call xlang_compile_std_module ensure|auto (wave812)"
  fi
done
for _fm in mem/mem types/types option/option result/result debug/debug slice/mod; do
  if awk -v tgt="../core/${_fm}.o" '
    $0 ~ ("^" tgt ":") { hit=1; next }
    hit && /^[^#[:space:]]/ { exit 1 }
    hit && /xlang_compile_std_module\.sh/ && /ensure|auto/ { found=1; exit 0 }
    END { exit found ? 0 : 1 }
  ' "$MF" 2>/dev/null; then
    _fm_thin=$((_fm_thin + 1))
  else
    bad "Makefile ../core/${_fm}.o must thin-call xlang_compile_std_module ensure|auto (wave812)"
  fi
done
if [ "$_fm_thin" -ne 38 ]; then
  bad "wave812 expected 38 formal_mod ensure leaves, got $_fm_thin"
fi
note "Makefile formal_mod 38 leaves thin-call ensure (wave812; not physical delete)"
# no residual explicit source lists after ensure in formal recipe bodies
if grep -nE '^\t@?sh scripts/xlang_compile_std_module\.sh (--bare-impl )?[.]{0,2}/' "$MF" 2>/dev/null \
  | grep -v ensure | grep -v auto | head -1 | grep -q .; then
  bad "Makefile formal_mod still has explicit-source std_module calls (wave812 must ensure)"
else
  note "Makefile formal_mod free of explicit-source std_module recipe args (wave812)"
fi
# wave826: formal_mod FORCE dep-thin — target line FORCE only (no dual .x prereqs).
_fm_force=0
for _fm in \
  string/string heap/heap heap/page_mmap sys/sys sys/linux \
  map/map set/set vec/vec thread/thread time/time random/random env/env \
  fs/fs sync/sync queue/queue encoding/encoding base64/base64 crypto/crypto \
  log/log test/test atomic/atomic hash/hash math/math sort/sort ffi/ffi \
  context/context error/error json/json csv/csv dynlib/dynlib http/http tar/tar
do
  if awk -v tgt="../std/${_fm}.o" '
    $0 ~ ("^" tgt ":") {
      if ($0 ~ /FORCE/ && $0 !~ /\.x([[:space:]]|$)/) { ok=1; exit 0 }
      exit 1
    }
    END { exit ok ? 0 : 1 }
  ' "$MF" 2>/dev/null; then
    _fm_force=$((_fm_force + 1))
  else
    bad "Makefile ../std/${_fm}.o must FORCE dep-thin (no .x prereqs; wave826)"
  fi
done
for _fm in mem/mem types/types option/option result/result debug/debug slice/mod; do
  if awk -v tgt="../core/${_fm}.o" '
    $0 ~ ("^" tgt ":") {
      if ($0 ~ /FORCE/ && $0 !~ /\.x([[:space:]]|$)/) { ok=1; exit 0 }
      exit 1
    }
    END { exit ok ? 0 : 1 }
  ' "$MF" 2>/dev/null; then
    _fm_force=$((_fm_force + 1))
  else
    bad "Makefile ../core/${_fm}.o must FORCE dep-thin (no .x prereqs; wave826)"
  fi
done
if [ "$_fm_force" -ne 38 ]; then
  bad "wave826 expected 38 formal_mod FORCE thin leaves, got $_fm_force"
fi
note "Makefile formal_mod 38 leaves FORCE dep-thin (wave826; not physical delete)"
if ! grep -q 'FORCE-thin mtime\|skip up-to-date' "$_fm_sh"; then
  bad "xlang_compile_std_module.sh must own FORCE-thin mtime skip (wave826)"
else
  note "formal_mod ensure owns source mtime skip (wave826)"
fi
# wave813: B7B STD_AND_PANIC_O list authority in mk; Makefile include only.
_SAP_MK="compiler/mk/std_and_panic_objs.mk"
if [ ! -f "$_SAP_MK" ]; then
  bad "missing $_SAP_MK (wave813 B7B STD_AND_PANIC list authority)"
fi
if ! grep -qE '^STD_AND_PANIC_O\s*=' "$_SAP_MK"; then
  bad "$_SAP_MK must define STD_AND_PANIC_O (wave813)"
fi
# Base list must stay 65 tokens (Linux freestanding append is conditional, not base).
_sap_n=$(awk '
  /^STD_AND_PANIC_O[[:space:]]*=/ {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    n=split(line, a, /[[:space:]]+/)
    c=0
    for (i=1;i<=n;i++) if (a[i] != "") c++
    print c
    exit
  }
' "$_SAP_MK")
if [ "${_sap_n:-0}" -ne 65 ]; then
  bad "wave813 expected STD_AND_PANIC_O base count 65 in mk, got ${_sap_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/std_and_panic_objs\.mk' "$MF"; then
  bad "Makefile must include mk/std_and_panic_objs.mk (wave813)"
fi
# Forbid dual authority: long inline re-assignment of the product inventory.
if grep -nE '^STD_AND_PANIC_O[[:space:]]*=' "$MF" 2>/dev/null | grep -qE '\.\./std/'; then
  bad "Makefile must not re-list STD_AND_PANIC_O inline (wave813 dual authority)"
else
  note "Makefile STD_AND_PANIC_O has no dual inline product list (wave813)"
fi
# make must still expand the list (std-objs target exists; prereq graph).
if ! grep -qE '^std-objs:.*\$\(STD_AND_PANIC_O\)' "$MF"; then
  bad "Makefile std-objs must still depend on \$(STD_AND_PANIC_O) (wave813 consumers)"
fi
note "B7B STD_AND_PANIC_O list authority in mk (65 base; wave813; not physical delete)"
# wave814: driver_leaf shell-primary — ensure thin on 8 leaves + script catalog/--check.
if [ ! -f "$ROOT/compiler/scripts/driver_leaf_x_to_o.sh" ] && [ ! -f "scripts/driver_leaf_x_to_o.sh" ]; then
  bad "missing driver_leaf_x_to_o.sh (wave814 driver_leaf authority)"
fi
_dl_sh="$ROOT/compiler/scripts/driver_leaf_x_to_o.sh"
[ -f "$_dl_sh" ] || _dl_sh="scripts/driver_leaf_x_to_o.sh"
if ! grep -q 'driver_leaf_spec_for_key' "$_dl_sh"; then
  bad "driver_leaf_x_to_o.sh must define driver_leaf_spec_for_key (wave814)"
fi
if ! grep -qE 'ensure\|auto\)' "$_dl_sh"; then
  bad "driver_leaf_x_to_o.sh must support ensure|auto (wave814)"
fi
if ! grep -q 'driver_leaf_check' "$_dl_sh"; then
  bad "driver_leaf_x_to_o.sh must support --check (wave814)"
fi
_dl_thin=0
# Keys come from catalog `list` only (G.7: residual shell must not hardcode .o inventory).
while IFS= read -r _dl; do
  [ -z "$_dl" ] && continue
  if awk -v leaf="$_dl" '
    $0 ~ ("^" leaf ":") { want=1; next }
    want && /^[^#[:space:]]/ { want=0 }
    want && /driver_leaf_x_to_o\.sh ensure/ { found=1 }
    END { exit found ? 0 : 1 }
  ' "$MF"; then
    _dl_thin=$((_dl_thin + 1))
  else
    bad "Makefile $_dl must thin-call driver_leaf_x_to_o ensure (wave814)"
  fi
done < <(bash "$_dl_sh" list 2>/dev/null || true)
if [ "$_dl_thin" -ne 8 ]; then
  bad "wave814 expected 8 driver_leaf ensure leaves, got $_dl_thin"
fi
note "Makefile driver_leaf 8 leaves thin-call ensure (wave814; not physical delete)"
# wave828: driver_leaf FORCE dep-thin — target line FORCE only (no dual .x prereqs).
_dl_force=0
while IFS= read -r _dl; do
  [ -z "$_dl" ] && continue
  if awk -v leaf="$_dl" '
    $0 ~ ("^" leaf ":") {
      if ($0 ~ /FORCE/ && $0 !~ /\.x([[:space:]]|$)/) { ok=1; exit 0 }
      exit 1
    }
    END { exit ok ? 0 : 1 }
  ' "$MF" 2>/dev/null; then
    _dl_force=$((_dl_force + 1))
  else
    bad "Makefile $_dl must FORCE dep-thin (no .x prereqs; wave828)"
  fi
done < <(bash "$_dl_sh" list 2>/dev/null || true)
if [ "$_dl_force" -ne 8 ]; then
  bad "wave828 expected 8 driver_leaf FORCE thin leaves, got $_dl_force"
fi
note "Makefile driver_leaf 8 leaves FORCE dep-thin (wave828; not physical delete)"
if ! grep -q 'FORCE-thin mtime\|skip up-to-date' "$_dl_sh"; then
  bad "driver_leaf_x_to_o.sh must own FORCE-thin mtime skip (wave828)"
else
  note "driver_leaf ensure owns source mtime skip (wave828)"
fi
if grep -nE $'^\t.*driver_leaf_x_to_o\.sh (src/|seeds/)' "$MF" 2>/dev/null | head -1 | grep -q .; then
  bad "Makefile driver_leaf still has explicit-arg recipe calls (wave814 must ensure)"
else
  note "Makefile driver_leaf free of explicit-arg recipe args (wave814)"
fi
# Dual authority: no long DRIVER_COMPILE_RENAME / DRIVER_EMIT_RENAME in Makefile.
if grep -nE '^DRIVER_COMPILE_RENAME[[:space:]]*=' "$MF" 2>/dev/null | grep -q 'compile_dispatch'; then
  bad "Makefile must not keep DRIVER_COMPILE_RENAME inline (wave814 dual authority)"
fi
if grep -nE '^DRIVER_EMIT_RENAME[[:space:]]*=' "$MF" 2>/dev/null | grep -q 'emit_copy_lib'; then
  bad "Makefile must not keep DRIVER_EMIT_RENAME inline (wave814 dual authority)"
fi
if grep -nE '^LSP_IO_STD_HEAP_RENAME[[:space:]]*=' "$MF" 2>/dev/null | grep -q 'std_heap_alloc'; then
  bad "Makefile must not keep LSP_IO_STD_HEAP_RENAME inline (wave814 dual authority)"
fi
note "Makefile free of driver_leaf rename dual lists (wave814)"
# --check resolves catalog + Makefile FORCE greps (cwd=compiler/).
if ! ( cd "$COMPILER_DIR" && bash scripts/driver_leaf_x_to_o.sh --check >/dev/null ); then
  bad "driver_leaf_x_to_o.sh --check failed (wave814/wave828)"
else
  note "driver_leaf_x_to_o.sh --check OK (wave828 FORCE thin; not physical delete)"
fi

# wave829: product/archaeology *_gen.c FORCE dep-thin (17 leaves; no dual .x / X_DEPS prereqs).
_gen_c_force_leaves="
parser_gen.c
lexer_gen.c
typeck_gen.c
codegen_gen.c
lsp_diag_gen.c
lsp_io_gen.c
lsp_gen.c
lsp_io_std_heap_gen.c
driver_fmt_gen.c
driver_check_gen.c
driver_test_gen.c
driver_compile_gen.c
driver_build_gen.c
driver_run_gen.c
driver_emit_gen.c
driver_gen.c
preprocess_gen.c
"
_gen_c_force=0
for _g in $_gen_c_force_leaves; do
  [ -z "$_g" ] && continue
  if awk -v leaf="$_g" '
    $0 ~ ("^" leaf ":") {
      if ($0 ~ /FORCE/ && $0 ~ /scripts\/ensure_/ && $0 !~ /\.x([[:space:]]|$)/ && $0 !~ /X_DEPS/) { ok=1; exit 0 }
      exit 1
    }
    END { exit ok ? 0 : 1 }
  ' "$MF" 2>/dev/null; then
    _gen_c_force=$((_gen_c_force + 1))
  else
    bad "Makefile $_g must FORCE dep-thin (no .x/X_DEPS prereqs; wave829)"
  fi
done
if [ "$_gen_c_force" -ne 17 ]; then
  bad "wave829 expected 17 gen.c FORCE thin leaves, got $_gen_c_force"
fi
note "Makefile gen.c 17 leaves FORCE dep-thin (wave829; not physical delete)"
# ensure scripts document pin/FORCE_REGEN ownership (shell-primary gen policy)
for _gs in ensure_migrate_gen.sh ensure_driver_gen.sh ensure_lsp_pipeline_gen.sh ensure_archaeology_gen.sh; do
  _gp="$ROOT/compiler/scripts/$_gs"
  [ -f "$_gp" ] || _gp="scripts/$_gs"
  if [ ! -f "$_gp" ]; then
    bad "missing $_gs (wave829 gen.c FORCE thin authority)"
  fi
  if ! grep -qE 'XLANG_FORCE_REGEN_GEN|pinned|pin' "$_gp"; then
    bad "$_gs must own pin/FORCE_REGEN gen policy (wave829)"
  fi
done
note "ensure_*_gen scripts own pin/FORCE_REGEN policy (wave829)"
# PLATFORM: SHARED — ensure_*_gen use bash arrays; Ubuntu /bin/sh is dash.
# Recipes must invoke bash (not sh) so FORCE always-run path works on Linux.
if grep -nE $'^\tsh scripts/ensure_(migrate|driver|lsp_pipeline|archaeology)_gen\.sh' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile ensure_*_gen recipes must use bash (not sh/dash; wave829 Ubuntu)"
else
  note "Makefile ensure_*_gen recipes use bash (wave829 dash-safe)"
fi

# wave830: ast_gen2.c FORCE dep-thin (1 leaf; no src/ast/ast.x make-graph prereq).
if awk '
  $0 ~ /^ast_gen2\.c:/ {
    if ($0 ~ /FORCE/ && $0 ~ /ensure_ast_gen2/ && $0 !~ /src\/ast\/ast\.x/) { ok=1; exit 0 }
    exit 1
  }
  END { exit ok ? 0 : 1 }
' "$MF" 2>/dev/null; then
  note "Makefile ast_gen2.c FORCE dep-thin (wave830; not physical delete)"
else
  bad "Makefile ast_gen2.c must FORCE dep-thin via ensure_ast_gen2 (no ast.x prereq; wave830)"
fi
_ag2_sh="$ROOT/compiler/scripts/ensure_ast_gen2.sh"
[ -f "$_ag2_sh" ] || _ag2_sh="scripts/ensure_ast_gen2.sh"
if [ ! -f "$_ag2_sh" ]; then
  bad "missing ensure_ast_gen2.sh (wave830 ast_gen2 FORCE thin authority)"
elif ! grep -qE 'XLANG_FORCE_REGEN_GEN|pinned' "$_ag2_sh"; then
  bad "ensure_ast_gen2.sh must own pin/FORCE_REGEN policy (wave830)"
elif ! bash "$_ag2_sh" --check >/dev/null 2>&1; then
  bad "ensure_ast_gen2.sh --check failed (wave830)"
else
  note "ensure_ast_gen2.sh --check OK (wave830 FORCE thin; not physical delete)"
fi
if grep -nE $'^\tsh scripts/ensure_ast_gen2\.sh' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile ensure_ast_gen2 recipe must use bash (not sh/dash; wave830 Ubuntu)"
else
  note "Makefile ensure_ast_gen2 recipe uses bash (wave830 dash-safe)"
fi

# wave831: src-edge FORCE dep-thin (COUNT=7). Pattern greps only — no product .o inventory
# (G.7 residual script hardcode ban). Shell owns seed/slice mtime.
if awk '
  $0 ~ /^parser_asm_thin_glue\.o:/ {
    if ($0 ~ /FORCE/ && $0 ~ /ensure_host_cc_seed_o/ && $0 !~ /seeds\// && $0 !~ /\.inc/) { ok=1; exit 0 }
    exit 1
  }
  END { exit ok ? 0 : 1 }
' "$MF" 2>/dev/null; then
  note "Makefile parser_asm thin_glue FORCE dep-thin (wave831; not physical delete)"
else
  bad "Makefile parser_asm thin_glue must FORCE dep-thin via try-heat (no seed/inc prereq; wave831)"
fi
# Count FORCE+cc_inc_tu target lines (exactly 6 residual pure-seed leaves).
_cc_inc_force=$(grep -cE '^[a-zA-Z0-9_./-]+: FORCE scripts/cc_inc_tu\.sh[[:space:]]*$' "$MF" 2>/dev/null || true)
if [ "${_cc_inc_force:-0}" -eq 6 ]; then
  note "Makefile cc_inc_tu residual 6 leaves FORCE dep-thin (wave831; not physical delete)"
else
  bad "Makefile expected 6 FORCE+cc_inc_tu residual leaves, got ${_cc_inc_force:-0} (wave831)"
fi
# No seed/.from_x.c make-graph prereqs remaining on FORCE+cc_inc_tu leaves.
if grep -nE '^[a-zA-Z0-9_./-]+:.*seeds/.*cc_inc_tu' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile still lists seed make-graph prereq with cc_inc_tu (wave831 must FORCE only)"
else
  note "Makefile free of seed+cc_inc_tu dual prereq edges (wave831)"
fi
_cc_sh="$ROOT/compiler/scripts/cc_inc_tu.sh"
[ -f "$_cc_sh" ] || _cc_sh="scripts/cc_inc_tu.sh"
if [ ! -f "$_cc_sh" ]; then
  bad "missing cc_inc_tu.sh (wave831 src-edge FORCE thin authority)"
elif ! grep -qE 'XLANG_CC_INC_TU_PEERS|XLANG_CC_INC_TU_FORCE' "$_cc_sh"; then
  bad "cc_inc_tu.sh must own mtime/PEERS/FORCE policy (wave831)"
else
  note "cc_inc_tu.sh owns mtime/PEERS policy (wave831 FORCE thin; not physical delete)"
fi

# wave832: migrate companion FORCE dep-thin (COUNT=3). Pattern greps only — no
# product object inventory hardcode (G.7 residual honesty). Shell owns gen mtime.
_migrate_x_force=$(grep -cE ': FORCE scripts/migrate_x_objs\.sh[[:space:]]*$' "$MF" 2>/dev/null || true)
if [ "${_migrate_x_force:-0}" -eq 3 ]; then
  note "Makefile migrate companion 3 leaves FORCE dep-thin (wave832; not physical delete)"
else
  bad "Makefile expected 3 FORCE+migrate_x_objs companion leaves, got ${_migrate_x_force:-0} (wave832)"
fi
# Companion leaves that still list gen as make-graph prereq (pre-FORCE shape) must be 0.
# wave834 closed bootstrap-pipeline: pipeline_gen.c — no allowlist for that phony.
if grep -nE '^[a-zA-Z0-9_./-]+:.*_gen\.c' "$MF" 2>/dev/null \
  | grep -v FORCE \
  | grep -q .; then
  bad "Makefile still lists gen make-graph prereq on non-FORCE migrate-shaped leaves (wave832/834 must FORCE only)"
else
  note "Makefile free of migrate companion / bootstrap-pipeline gen prereq edges (wave832+834)"
fi
_mig_sh="$ROOT/compiler/scripts/migrate_x_objs.sh"
[ -f "$_mig_sh" ] || _mig_sh="scripts/migrate_x_objs.sh"
if [ ! -f "$_mig_sh" ]; then
  bad "missing migrate_x_objs.sh (wave832 migrate FORCE thin authority)"
elif ! grep -qE 'need_rebuild|XLANG_MIGRATE_FORCE' "$_mig_sh"; then
  bad "migrate_x_objs.sh must own need_rebuild/MIGRATE_FORCE policy (wave832)"
else
  note "migrate_x_objs.sh owns gen mtime policy (wave832 FORCE thin; not physical delete)"
fi

# wave833: pipeline_glue_types.inc FORCE dep-thin (COUNT=1). Pattern greps only —
# no product object inventory hardcode (G.7 residual honesty). Shell owns extract mtime.
if awk '
  $0 ~ /pipeline_glue_types\.inc:/ {
    if ($0 ~ /FORCE/ && $0 ~ /ensure_pipeline_glue_types/ && $0 !~ /pipeline_gen\.c/ && $0 !~ /extract_pipeline_glue_types\.pl/) { ok=1; exit 0 }
    exit 1
  }
  END { exit ok ? 0 : 1 }
' "$MF" 2>/dev/null; then
  note "Makefile pipeline_glue_types.inc FORCE dep-thin (wave833; not physical delete)"
else
  bad "Makefile pipeline_glue_types.inc must FORCE dep-thin via ensure (no gen/extract.pl prereq; wave833)"
fi
_gt_sh="$ROOT/compiler/scripts/ensure_pipeline_glue_types.sh"
[ -f "$_gt_sh" ] || _gt_sh="scripts/ensure_pipeline_glue_types.sh"
if [ ! -f "$_gt_sh" ]; then
  bad "missing ensure_pipeline_glue_types.sh (wave833 glue types FORCE thin authority)"
elif ! grep -qE 'XLANG_GLUE_TYPES_FORCE|need_rebuild' "$_gt_sh"; then
  bad "ensure_pipeline_glue_types.sh must own need_rebuild/GLUE_TYPES_FORCE policy (wave833)"
elif ! bash "$_gt_sh" --check >/dev/null 2>&1; then
  bad "ensure_pipeline_glue_types.sh --check failed (wave833)"
else
  note "ensure_pipeline_glue_types.sh --check OK (wave833 FORCE thin; not physical delete)"
fi
if grep -nE $'^\tsh scripts/ensure_pipeline_glue_types\.sh' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile ensure_pipeline_glue_types recipe must use bash (not sh/dash; wave833 Ubuntu)"
else
  note "Makefile ensure_pipeline_glue_types recipe uses bash (wave833 dash-safe)"
fi

# wave834: bootstrap-pipeline FORCE shell-primary (COUNT=1). Pattern greps only —
# no product inventory hardcode (G.7 residual honesty). Body = ensure_lsp_pipeline_gen.
if awk '
  $0 ~ /^bootstrap-pipeline:/ {
    if ($0 ~ /FORCE/ && $0 ~ /ensure_lsp_pipeline_gen/ && $0 !~ /pipeline_gen\.c/) { ok=1; exit 0 }
    exit 1
  }
  END { exit ok ? 0 : 1 }
' "$MF" 2>/dev/null; then
  note "Makefile bootstrap-pipeline FORCE shell-primary (wave834; not physical delete)"
else
  bad "Makefile bootstrap-pipeline must FORCE + ensure_lsp_pipeline_gen (no pipeline_gen.c prereq; wave834)"
fi
_bp_sh="$ROOT/compiler/scripts/ensure_lsp_pipeline_gen.sh"
[ -f "$_bp_sh" ] || _bp_sh="scripts/ensure_lsp_pipeline_gen.sh"
if [ ! -f "$_bp_sh" ]; then
  bad "missing ensure_lsp_pipeline_gen.sh (wave834 bootstrap-pipeline FORCE thin authority)"
elif ! grep -q 'ensure_pipeline_gen' "$_bp_sh"; then
  bad "ensure_lsp_pipeline_gen.sh must own ensure_pipeline_gen body (wave834)"
elif ! grep -qE 'pipeline\|pipeline_gen\.c\)' "$_bp_sh" && ! grep -q 'pipeline|' "$_bp_sh"; then
  bad "ensure_lsp_pipeline_gen.sh must expose pipeline mode (wave834)"
else
  note "ensure_lsp_pipeline_gen.sh owns pipeline mode (wave834 FORCE thin; not physical delete)"
fi
if grep -nE $'^\tsh scripts/ensure_lsp_pipeline_gen\.sh pipeline' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile bootstrap-pipeline recipe must use bash ensure (not sh/dash; wave834 Ubuntu)"
else
  note "Makefile bootstrap-pipeline recipe uses bash ensure (wave834 dash-safe)"
fi
# Honesty: bootstrap-pipeline must not still list bare pipeline_gen.c as prereq.
if grep -nE '^bootstrap-pipeline:.*pipeline_gen\.c' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile bootstrap-pipeline still lists pipeline_gen.c make-graph prereq (wave834 must FORCE only)"
else
  note "Makefile bootstrap-pipeline free of pipeline_gen.c prereq edge (wave834)"
fi

# wave835: class-G bootstrap_seed_*_filtered FORCE dep-thin (COUNT=4).
# Pattern greps only — no product object inventory hardcode (G.7 self-scan).
# Match target lines by class-G stem; avoid writing product object paths in this script.
_filt_n="$(
  awk '
    $0 ~ /^build_asm\/bootstrap_seed_.*_filtered/ && $0 ~ /:/ {
      if ($0 ~ /FORCE/ && ($0 ~ /filter_bootstrap_seed_against_partial/ || $0 ~ /filter_bootstrap_seed_pipeline/)) n++
    }
    END { print n+0 }
  ' "$MF" 2>/dev/null
)"
if [ "${_filt_n:-0}" -eq 4 ]; then
  note "Makefile bootstrap_seed class-G filter FORCE thin (n=4; wave835; not physical delete)"
else
  bad "Makefile bootstrap_seed class-G filter FORCE thin expected 4 got ${_filt_n:-0} (wave835)"
fi
_fp_sh="$ROOT/compiler/scripts/filter_bootstrap_seed_against_partial_o.sh"
[ -f "$_fp_sh" ] || _fp_sh="scripts/filter_bootstrap_seed_against_partial_o.sh"
_fpipe_sh="$ROOT/compiler/scripts/filter_bootstrap_seed_pipeline_o.sh"
[ -f "$_fpipe_sh" ] || _fpipe_sh="scripts/filter_bootstrap_seed_pipeline_o.sh"
if [ ! -f "$_fp_sh" ] || [ ! -f "$_fpipe_sh" ]; then
  bad "missing filter_bootstrap_seed_*.sh (wave835 class-G filter FORCE thin authority)"
elif ! bash "$_fp_sh" --check >/dev/null; then
  bad "filter_bootstrap_seed_against_partial_o.sh --check failed (wave835)"
elif ! bash "$_fpipe_sh" --check >/dev/null; then
  bad "filter_bootstrap_seed_pipeline_o.sh --check failed (wave835)"
else
  note "filter_bootstrap_seed_*.sh --check OK (wave835 FORCE thin; not physical delete)"
fi
if grep -nE $'^\tsh scripts/filter_bootstrap_seed_(against_partial|pipeline)_o\.sh ensure' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile class-G filter recipe must use bash ensure (not sh/dash; wave835 Ubuntu)"
else
  note "Makefile class-G filter recipes use bash ensure (wave835 dash-safe)"
fi
# Honesty: class-G filter leaves must not still list SRC objects as make-graph prereq.
# Temp: avoid bare object-path tokens in residual script body (G.7 self hardcode scan).
if awk '
  $0 ~ /^build_asm\/bootstrap_seed_.*_filtered/ && $0 ~ /:/ {
    line=$0
    sub(/^[^:]+:/, "", line)
    n=split(line, a, /[ \t]+/)
    for (i=1;i<=n;i++) {
      if (a[i]=="" || a[i]=="FORCE") continue
      if (a[i] ~ /^scripts\//) continue
      # residual source edge if prereq looks like an object leaf (ends with o after dot)
      if (a[i] ~ /\.[oO]$/) { bad=1; exit 1 }
    }
  }
  END { exit bad ? 1 : 0 }
' "$MF" 2>/dev/null; then
  note "Makefile class-G filter free of SRC object prereq edges (wave835)"
else
  bad "Makefile class-G filter still lists SRC object make-graph prereq (wave835 must FORCE only)"
fi

# wave836: product object-path cp-alias FORCE dep-thin (COUNT=3).
# Pattern greps only — no product object inventory hardcode (G.7 self-scan).
_cp_n="$(
  awk '
    $0 ~ /ensure_cp_alias_o\.sh/ && $0 ~ /:/ {
      if ($0 ~ /FORCE/) n++
    }
    END { print n+0 }
  ' "$MF" 2>/dev/null
)"
if [ "${_cp_n:-0}" -eq 3 ]; then
  note "Makefile cp-alias FORCE thin (n=3; wave836; not physical delete)"
else
  bad "Makefile cp-alias FORCE thin expected 3 got ${_cp_n:-0} (wave836)"
fi
_cp_sh="$ROOT/compiler/scripts/ensure_cp_alias_o.sh"
[ -f "$_cp_sh" ] || _cp_sh="scripts/ensure_cp_alias_o.sh"
if [ ! -f "$_cp_sh" ]; then
  bad "missing ensure_cp_alias_o.sh (wave836 cp-alias FORCE thin authority)"
elif ! bash "$_cp_sh" --check >/dev/null; then
  bad "ensure_cp_alias_o.sh --check failed (wave836)"
else
  note "ensure_cp_alias_o.sh --check OK (wave836 FORCE thin; not physical delete)"
fi
if grep -nE $'^\tsh scripts/ensure_cp_alias_o\.sh ensure' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile cp-alias recipe must use bash ensure (not sh/dash; wave836 Ubuntu)"
else
  note "Makefile cp-alias recipes use bash ensure (wave836 dash-safe)"
fi
# Honesty: cp-alias leaves must not still list SRC objects as make-graph prereq.
if awk '
  $0 ~ /ensure_cp_alias_o\.sh/ && $0 ~ /:/ {
    line=$0
    sub(/^[^:]+:/, "", line)
    n=split(line, a, /[ \t]+/)
    for (i=1;i<=n;i++) {
      if (a[i]=="" || a[i]=="FORCE") continue
      if (a[i] ~ /^scripts\//) continue
      if (a[i] ~ /\.[oO]$/) { bad=1; exit 1 }
    }
  }
  END { exit bad ? 1 : 0 }
' "$MF" 2>/dev/null; then
  note "Makefile cp-alias free of SRC object prereq edges (wave836)"
else
  bad "Makefile cp-alias still lists SRC object make-graph prereq (wave836 must FORCE only)"
fi

# wave837: pipeline_gen.c FORCE dep-thin (COUNT=1). Pattern greps only —
# file-target residual after wave829 (17 *_gen.c) + wave834 (bootstrap-pipeline phony).
if awk '
  $0 ~ /^pipeline_gen\.c:/ {
    if ($0 ~ /FORCE/ && $0 ~ /ensure_lsp_pipeline_gen/) { ok=1; exit 0 }
    exit 1
  }
  END { exit ok ? 0 : 1 }
' "$MF" 2>/dev/null; then
  note "Makefile pipeline_gen.c FORCE dep-thin (wave837; not physical delete)"
else
  bad "Makefile pipeline_gen.c must FORCE + ensure_lsp_pipeline_gen (wave837)"
fi
_pg_sh="$ROOT/compiler/scripts/ensure_lsp_pipeline_gen.sh"
[ -f "$_pg_sh" ] || _pg_sh="scripts/ensure_lsp_pipeline_gen.sh"
if [ ! -f "$_pg_sh" ]; then
  bad "missing ensure_lsp_pipeline_gen.sh (wave837 pipeline_gen FORCE thin authority)"
elif ! grep -q 'ensure_pipeline_gen' "$_pg_sh"; then
  bad "ensure_lsp_pipeline_gen.sh must own ensure_pipeline_gen body (wave837)"
elif ! grep -qE 'check_pipeline_gen_expr_i64_abi|int64_t int_val' "$_pg_sh"; then
  bad "ensure_lsp_pipeline_gen.sh must own i64 ABI guard for pipeline_gen (wave837)"
else
  note "ensure_lsp_pipeline_gen.sh owns pipeline pin+ABI (wave837 FORCE thin; not physical delete)"
fi
if grep -nE $'^\tsh scripts/ensure_lsp_pipeline_gen\.sh pipeline' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile pipeline_gen.c recipe must use bash ensure (not sh/dash; wave837 Ubuntu)"
else
  note "Makefile pipeline_gen.c recipe uses bash ensure (wave837 dash-safe)"
fi
# Honesty: pipeline_gen.c must not keep empty / non-FORCE prereq shape.
if grep -nE '^pipeline_gen\.c:[[:space:]]*$' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile pipeline_gen.c still has empty prereq (wave837 must FORCE)"
else
  note "Makefile pipeline_gen.c free of empty-prereq residual (wave837)"
fi

# wave838: bootstrap_xlangc FORCE dep-thin (COUNT=1). G-06 cold-egg; shell select owns
# host seed pick. Drop create.sh make-graph edge; create is optional via select.
if awk '
  $0 ~ /^bootstrap_xlangc:/ {
    if ($0 ~ /FORCE/ && $0 ~ /select_bootstrap_xlangc/) { ok=1; exit 0 }
    exit 1
  }
  END { exit ok ? 0 : 1 }
' "$MF" 2>/dev/null; then
  note "Makefile bootstrap_xlangc FORCE dep-thin (wave838; not physical delete)"
else
  bad "Makefile bootstrap_xlangc must FORCE + select_bootstrap_xlangc (wave838)"
fi
_bx_sh="$ROOT/compiler/scripts/select_bootstrap_xlangc.sh"
[ -f "$_bx_sh" ] || _bx_sh="scripts/select_bootstrap_xlangc.sh"
if [ ! -f "$_bx_sh" ]; then
  bad "missing select_bootstrap_xlangc.sh (wave838 bootstrap_xlangc FORCE thin authority)"
elif ! grep -q 'can_run' "$_bx_sh"; then
  bad "select_bootstrap_xlangc.sh must own can_run host seed pick (wave838)"
elif ! grep -q 'bootstrap_xlangc\.' "$_bx_sh"; then
  bad "select_bootstrap_xlangc.sh must own multi-arch seed pick (wave838)"
else
  note "select_bootstrap_xlangc.sh owns host seed pick (wave838 FORCE thin; not physical delete)"
fi
if grep -nE $'^\t(\./scripts/select_bootstrap_xlangc\.sh|sh scripts/select_bootstrap_xlangc\.sh)' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile bootstrap_xlangc recipe must use bash select (not sh/./ relative; wave838 Ubuntu)"
else
  note "Makefile bootstrap_xlangc recipe uses bash select (wave838 dash-safe)"
fi
# Honesty: create.sh must not remain a make-graph prereq on bootstrap_xlangc.
if awk '
  $0 ~ /^bootstrap_xlangc:/ {
    if ($0 ~ /bootstrap_xlangc_create/) { bad=1; exit 1 }
  }
  END { exit bad ? 1 : 0 }
' "$MF" 2>/dev/null; then
  note "Makefile bootstrap_xlangc free of create.sh make-graph edge (wave838)"
else
  bad "Makefile bootstrap_xlangc still lists bootstrap_xlangc_create as prereq (wave838 must FORCE+select only)"
fi

# wave815: archaeology host-pick phonies — ensure thin on catalog keys + script --check.
# wave839: same 4 leaves must FORCE + script prereq (dep-thin; not physical delete).
if [ ! -f "$ROOT/compiler/scripts/archaeology_host_pick_phony.sh" ] && [ ! -f "scripts/archaeology_host_pick_phony.sh" ]; then
  bad "missing archaeology_host_pick_phony.sh (wave815 archaeology host-pick authority)"
fi
_ahp_sh="$ROOT/compiler/scripts/archaeology_host_pick_phony.sh"
[ -f "$_ahp_sh" ] || _ahp_sh="scripts/archaeology_host_pick_phony.sh"
if ! grep -q 'arch_phony_keys' "$_ahp_sh"; then
  bad "archaeology_host_pick_phony.sh must define arch_phony_keys (wave815)"
fi
if ! grep -qE 'ensure\|auto\)' "$_ahp_sh"; then
  bad "archaeology_host_pick_phony.sh must support ensure|auto (wave815)"
fi
if ! grep -q 'arch_check' "$_ahp_sh"; then
  bad "archaeology_host_pick_phony.sh must support --check (wave815)"
fi
if ! bash "$_ahp_sh" --check >/dev/null 2>&1; then
  bad "archaeology_host_pick_phony.sh --check failed (wave815)"
fi
note "archaeology_host_pick_phony.sh --check OK (wave815)"
_ahp_thin=0
_ahp_force=0
# Keys from catalog `list` only (G.7: residual shell must not hardcode phony inventory).
while IFS= read -r _ahp; do
  [ -n "$_ahp" ] || continue
  if awk -v phony="$_ahp" '
    $0 ~ ("^" phony ":") {
      hdr=$0
      if (hdr ~ /FORCE/ && hdr ~ /archaeology_host_pick_phony\.sh/) force=1
      want=1; next
    }
    want && /archaeology_host_pick_phony\.sh ensure/ { ok=1; exit }
    want && /^\t/ { next }
    want && /^[^#\t]/ && $0 !~ /^$/ { exit }
    END { exit ok ? 0 : 1 }
  ' "$MF"; then
    _ahp_thin=$((_ahp_thin + 1))
  else
    bad "Makefile $_ahp must thin-call archaeology_host_pick_phony ensure (wave815)"
  fi
  if awk -v phony="$_ahp" '
    $0 ~ ("^" phony ":") {
      if ($0 ~ /FORCE/ && $0 ~ /archaeology_host_pick_phony\.sh/) { ok=1; exit }
      exit 1
    }
    END { exit ok ? 0 : 1 }
  ' "$MF"; then
    _ahp_force=$((_ahp_force + 1))
  else
    bad "Makefile $_ahp must FORCE + archaeology_host_pick_phony (wave839)"
  fi
done < <(bash "$_ahp_sh" list 2>/dev/null || true)
if [ "$_ahp_thin" -ne 4 ]; then
  bad "wave815 expected 4 archaeology host-pick ensure phonies, got $_ahp_thin"
fi
note "Makefile archaeology 4 phonies thin-call ensure (wave815; not physical delete)"
if [ "$_ahp_force" -ne 4 ]; then
  bad "wave839 expected 4 archaeology host-pick FORCE dep-thin leaves, got $_ahp_force"
fi
note "Makefile archaeology 4 phonies FORCE dep-thin (wave839; not physical delete)"
# No residual multi-line host-pick ladder on archaeology phonies.
if grep -nE '^\t@?if \[ -x \./xlang_asm \]' "$MF" 2>/dev/null | head -1 | grep -q .; then
  bad "Makefile still has host-pick if-ladder (wave815 archaeology must thin)"
else
  note "Makefile free of archaeology host-pick if-ladder (wave815)"
fi
# wave816: B7B DRIVER_SUBCMD_* list authority in mk; Makefile include only.
_DSC_MK="compiler/mk/driver_subcmd_objs.mk"
if [ ! -f "$_DSC_MK" ]; then
  bad "missing $_DSC_MK (wave816 B7B DRIVER_SUBCMD list authority)"
fi
if ! grep -qE '^DRIVER_SUBCMD_OBJS\s*=' "$_DSC_MK"; then
  bad "$_DSC_MK must define DRIVER_SUBCMD_OBJS (wave816)"
fi
_dsc_n=$(awk '
  /^DRIVER_SUBCMD_OBJS[[:space:]]*=/ {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    n=split(line, a, /[[:space:]]+/)
    c=0
    for (i=1;i<=n;i++) if (a[i] != "") c++
    print c
    exit
  }
' "$_DSC_MK")
if [ "${_dsc_n:-0}" -ne 7 ]; then
  bad "wave816 expected DRIVER_SUBCMD_OBJS count 7 in mk, got ${_dsc_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/driver_subcmd_objs\.mk' "$MF"; then
  bad "Makefile must include mk/driver_subcmd_objs.mk (wave816)"
fi
# Forbid dual authority: inline re-list of the 7 product leaves.
if grep -nE '^DRIVER_SUBCMD_OBJS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'driver_fmt_x\.o'; then
  bad "Makefile must not re-list DRIVER_SUBCMD_OBJS inline (wave816 dual authority)"
else
  note "Makefile DRIVER_SUBCMD_OBJS has no dual inline product list (wave816)"
fi
# Consumers must still expand $(DRIVER_SUBCMD_OBJS) (seed link / relink paths).
if ! grep -qE '\$\(DRIVER_SUBCMD_OBJS\)' "$MF"; then
  bad "Makefile must still consume \$(DRIVER_SUBCMD_OBJS) (wave816 consumers)"
fi
# Catalog must parse mk (no hardcode second inventory).
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/driver_subcmd_objs.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/driver_subcmd_objs.mk (wave816)"
fi
if grep -nE 'catalog_set DRIVER_SUBCMD_OBJS "' "$_cat_sh" 2>/dev/null | grep -q 'driver_fmt_x'; then
  bad "catalog must not hardcode DRIVER_SUBCMD_OBJS list (wave816 dual authority)"
fi
note "B7B DRIVER_SUBCMD_OBJS list authority in mk (7; wave816; not physical delete)"
# wave817: B7B PIPELINE_X_* + PIPELINE_LIBS list authority in mk; Makefile include only.
_PX_MK="compiler/mk/pipeline_x_objs.mk"
if [ ! -f "$_PX_MK" ]; then
  bad "missing $_PX_MK (wave817 B7B PIPELINE_X list authority)"
fi
if ! grep -qE '^PIPELINE_X_SATELLITE_OBJS\s*=' "$_PX_MK"; then
  bad "$_PX_MK must define PIPELINE_X_SATELLITE_OBJS (wave817)"
fi
if ! grep -qE '^PIPELINE_X_BASE_OBJS\s*=' "$_PX_MK"; then
  bad "$_PX_MK must define PIPELINE_X_BASE_OBJS (wave817)"
fi
if ! grep -qE '^PIPELINE_LIBS\s*:?=' "$_PX_MK"; then
  bad "$_PX_MK must define PIPELINE_LIBS (wave817)"
fi
_px_n=$(awk '
  /^PIPELINE_X_SATELLITE_OBJS[[:space:]]*=/ { want=1 }
  want {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) if (a[i] != "") c++
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_PX_MK")
if [ "${_px_n:-0}" -ne 9 ]; then
  bad "wave817 expected PIPELINE_X_SATELLITE_OBJS count 9 in mk, got ${_px_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/pipeline_x_objs\.mk' "$MF"; then
  bad "Makefile must include mk/pipeline_x_objs.mk (wave817)"
fi
# Forbid dual authority: inline re-list of satellite / base inventory.
if grep -nE '^PIPELINE_X_SATELLITE_OBJS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'lexer_x\.o'; then
  bad "Makefile must not re-list PIPELINE_X_SATELLITE_OBJS inline (wave817 dual authority)"
else
  note "Makefile PIPELINE_X_SATELLITE_OBJS has no dual inline product list (wave817)"
fi
if grep -nE '^PIPELINE_X_BASE_OBJS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'main_x\.o'; then
  bad "Makefile must not re-list PIPELINE_X_BASE_OBJS inline (wave817 dual authority)"
fi
if grep -nE '^PIPELINE_LIBS[[:space:]]*:?=' "$MF" 2>/dev/null | grep -qE 'lpthread|-lpthread'; then
  bad "Makefile must not re-list PIPELINE_LIBS inline (wave817 dual authority)"
fi
# Consumers must still expand $(PIPELINE_X_*) / $(PIPELINE_LIBS).
if ! grep -qE '\$\(PIPELINE_X_BASE_OBJS\)' "$MF"; then
  bad "Makefile must still consume \$(PIPELINE_X_BASE_OBJS) (wave817 consumers)"
fi
if ! grep -qE '\$\(PIPELINE_LIBS\)' "$MF"; then
  bad "Makefile must still consume \$(PIPELINE_LIBS) (wave817 consumers)"
fi
# Catalog must parse mk (no hardcode second inventory).
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/pipeline_x_objs.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/pipeline_x_objs.mk (wave817)"
fi
if grep -nE 'catalog_set PIPELINE_LIBS "' "$_cat_sh" 2>/dev/null | grep -qE 'lpthread|pthread'; then
  bad "catalog must not hardcode PIPELINE_LIBS (wave817 dual authority)"
fi
if grep -nE 'catalog_set PIPELINE_X_SATELLITE_OBJS "' "$_cat_sh" 2>/dev/null | grep -q 'lexer_x'; then
  bad "catalog must not hardcode PIPELINE_X_SATELLITE_OBJS (wave817 dual authority)"
fi
note "B7B PIPELINE_X_* + PIPELINE_LIBS list authority in mk (satellite 9; wave817; not physical delete)"
# wave818: B7B DRIVER_SEED mode picks list authority in mk; Makefile include only.
_SM_MK="compiler/mk/driver_seed_mode_objs.mk"
if [ ! -f "$_SM_MK" ]; then
  bad "missing $_SM_MK (wave818 B7B SEED_MODE list authority)"
fi
if ! grep -qE '^DRIVER_SEED_SUPPORT_EXTRA\s*=' "$_SM_MK"; then
  bad "$_SM_MK must define DRIVER_SEED_SUPPORT_EXTRA (wave818)"
fi
if ! grep -qE '^DRIVER_SEED_RUNTIME_O\s*=' "$_SM_MK"; then
  bad "$_SM_MK must define DRIVER_SEED_RUNTIME_O (wave818)"
fi
if ! grep -qE '^DRIVER_SEED_LINK_FLAGS\s*=' "$_SM_MK"; then
  bad "$_SM_MK must define DRIVER_SEED_LINK_FLAGS (wave818)"
fi
# Product-default SUPPORT_EXTRA count (non-LEGACY branch; last assignment wins in awk scan of tokens on product lines).
_sm_n=$(awk '
  /^DRIVER_SEED_SUPPORT_EXTRA[[:space:]]*=/ {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    c=0
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) if (a[i] ~ /\.o$/) c++
    # Keep last assignment (product no_c is second; LEGACY is first with 5).
    last=c
  }
  END { print last+0 }
' "$_SM_MK")
if [ "${_sm_n:-0}" -ne 3 ]; then
  bad "wave818 expected product DRIVER_SEED_SUPPORT_EXTRA count 3 in mk, got ${_sm_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/driver_seed_mode_objs\.mk' "$MF"; then
  bad "Makefile must include mk/driver_seed_mode_objs.mk (wave818)"
fi
# Forbid dual authority: inline re-list of product SUPPORT_EXTRA inventory.
if grep -nE '^DRIVER_SEED_SUPPORT_EXTRA[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'async_asm_pool\.o'; then
  bad "Makefile must not re-list DRIVER_SEED_SUPPORT_EXTRA inline (wave818 dual authority)"
else
  note "Makefile DRIVER_SEED_SUPPORT_EXTRA has no dual inline product list (wave818)"
fi
if grep -nE '^DRIVER_SEED_RUNTIME_O[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'runtime_driver'; then
  bad "Makefile must not re-list DRIVER_SEED_RUNTIME_O inline (wave818 dual authority)"
fi
# Consumers: composites expand $(DRIVER_SEED_SUPPORT_EXTRA) / RUNTIME_O into
# DRIVER_SEED_OBJS / PREREQS; Makefile recipes consume those composites.
_COMP_MK="compiler/mk/driver_seed_composites.mk"
if [ ! -f "$_COMP_MK" ]; then
  bad "missing $_COMP_MK (wave818 composites consumer of mode lists)"
fi
if ! grep -qE '\$\(DRIVER_SEED_SUPPORT_EXTRA\)' "$_COMP_MK"; then
  bad "composites must still expand \$(DRIVER_SEED_SUPPORT_EXTRA) (wave818 consumers)"
fi
if ! grep -qE '\$\(DRIVER_SEED_RUNTIME_O\)' "$_COMP_MK"; then
  bad "composites must still expand \$(DRIVER_SEED_RUNTIME_O) (wave818 consumers)"
fi
if ! grep -qE '\$\(DRIVER_SEED_OBJS\)' "$MF"; then
  bad "Makefile must still consume \$(DRIVER_SEED_OBJS) (wave818 composite consumers)"
fi
# Catalog must parse mk (no hardcode second inventory).
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/driver_seed_mode_objs.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/driver_seed_mode_objs.mk (wave818)"
fi
if grep -nE 'catalog_set DRIVER_SEED_SUPPORT_EXTRA "' "$_cat_sh" 2>/dev/null | grep -q 'async_asm_pool'; then
  bad "catalog must not hardcode DRIVER_SEED_SUPPORT_EXTRA (wave818 dual authority)"
fi
if grep -nE 'catalog_set DRIVER_SEED_RUNTIME_O "' "$_cat_sh" 2>/dev/null | grep -q 'runtime_driver'; then
  bad "catalog must not hardcode DRIVER_SEED_RUNTIME_O (wave818 dual authority)"
fi
note "B7B DRIVER_SEED mode picks list authority in mk (SUPPORT_EXTRA 3; wave818; not physical delete)"
# wave819: B7B seed link picks list authority in mk; Makefile include only.
_LP_MK="compiler/mk/driver_seed_link_picks.mk"
if [ ! -f "$_LP_MK" ]; then
  bad "missing $_LP_MK (wave819 B7B SEED_LINK_PICKS list authority)"
fi
if ! grep -qE '^MAIN_LINK_O\s*=' "$_LP_MK"; then
  bad "$_LP_MK must define MAIN_LINK_O (wave819)"
fi
if ! grep -qE '^LSP_DIAG_LINK_O\s*=' "$_LP_MK"; then
  bad "$_LP_MK must define LSP_DIAG_LINK_O (wave819)"
fi
if ! grep -qE '^RELINK_XLANG_GLUE_SUFFIX\s*=' "$_LP_MK"; then
  bad "$_LP_MK must define RELINK_XLANG_GLUE_SUFFIX (wave819)"
fi
# Product-default RELINK_XLANG_GLUE_SUFFIX multi-token count (fixed 2 .o).
_lp_n=$(awk '
  /^RELINK_XLANG_GLUE_SUFFIX[[:space:]]*=/ {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    c=0
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) if (a[i] ~ /\.o$/) c++
    last=c
  }
  END { print last+0 }
' "$_LP_MK")
if [ "${_lp_n:-0}" -ne 2 ]; then
  bad "wave819 expected product RELINK_XLANG_GLUE_SUFFIX count 2 in mk, got ${_lp_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/driver_seed_link_picks\.mk' "$MF"; then
  bad "Makefile must include mk/driver_seed_link_picks.mk (wave819)"
fi
# Forbid dual authority: inline re-list of product MAIN_LINK / GLUE / LSP inventory.
if grep -nE '^MAIN_LINK_O[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'crt0_|main_driver\.o'; then
  bad "Makefile must not re-list MAIN_LINK_O inline (wave819 dual authority)"
else
  note "Makefile MAIN_LINK_O has no dual inline product list (wave819)"
fi
if grep -nE '^RELINK_XLANG_GLUE_SUFFIX[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'pipeline_glue_strict_minimal\.o'; then
  bad "Makefile must not re-list RELINK_XLANG_GLUE_SUFFIX inline (wave819 dual authority)"
fi
if grep -nE '^LSP_DIAG_LINK_O[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'lsp_diag\.o'; then
  bad "Makefile must not re-list LSP_DIAG_LINK_O inline (wave819 dual authority)"
fi
# Consumers: composites expand $(MAIN_LINK_O)/LEXER/AST; Makefile recipes use GLUE/MAIN_FLAGS.
_COMP_MK="compiler/mk/driver_seed_composites.mk"
if [ ! -f "$_COMP_MK" ]; then
  bad "missing $_COMP_MK (wave819 composites consumer of link picks)"
fi
if ! grep -qE '\$\(MAIN_LINK_O\)' "$_COMP_MK"; then
  bad "composites must still expand \$(MAIN_LINK_O) (wave819 consumers)"
fi
if ! grep -qE '\$\(LSP_DIAG_LINK_O\)' "$_COMP_MK"; then
  bad "composites must still expand \$(LSP_DIAG_LINK_O) (wave819 consumers)"
fi
if ! grep -qE '\$\(MAIN_LINK_FLAGS\)' "$MF"; then
  bad "Makefile must still consume \$(MAIN_LINK_FLAGS) (wave819 consumers)"
fi
if ! grep -qE '\$\(RELINK_XLANG_GLUE_SUFFIX\)|\$\(DRIVER_SEED_GLUE_SUFFIX\)' "$MF"; then
  bad "Makefile must still consume \$(RELINK_XLANG_GLUE_SUFFIX) or \$(DRIVER_SEED_GLUE_SUFFIX) (wave819 consumers)"
fi
# Catalog must parse mk (no hardcode second inventory).
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/driver_seed_link_picks.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/driver_seed_link_picks.mk (wave819)"
fi
if grep -nE 'catalog_set MAIN_LINK_O "' "$_cat_sh" 2>/dev/null | grep -qE 'crt0_|main_driver'; then
  bad "catalog must not hardcode MAIN_LINK_O (wave819 dual authority)"
fi
if grep -nE 'catalog_set LSP_DIAG_LINK_O "' "$_cat_sh" 2>/dev/null | grep -q 'lsp_diag'; then
  bad "catalog must not hardcode LSP_DIAG_LINK_O (wave819 dual authority)"
fi
note "B7B seed link picks list authority in mk (GLUE_SUFFIX 2; wave819; not physical delete)"
# wave820: B7B OBJS_CORE archaeology list authority in mk; Makefile include only.
_OC_MK="compiler/mk/objs_core.mk"
if [ ! -f "$_OC_MK" ]; then
  bad "missing $_OC_MK (wave820 B7B OBJS_CORE list authority)"
fi
if ! grep -qE '^OBJS_CORE\s*=' "$_OC_MK"; then
  bad "$_OC_MK must define OBJS_CORE (wave820)"
fi
if ! grep -qE '^OBJS\s*=' "$_OC_MK"; then
  bad "$_OC_MK must define OBJS alias (wave820)"
fi
# Product-default OBJS_CORE multi-token count (fixed 16 .o; first assignment before ifeq).
_oc_n=$(awk '
  /^OBJS_CORE[[:space:]]*=/ {
    if (seen++) next
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    c=0
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) if (a[i] ~ /\.o$/) c++
    print c+0
    exit
  }
' "$_OC_MK")
if [ "${_oc_n:-0}" -ne 16 ]; then
  bad "wave820 expected product OBJS_CORE count 16 in mk, got ${_oc_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/objs_core\.mk' "$MF"; then
  bad "Makefile must include mk/objs_core.mk (wave820)"
fi
# Forbid dual authority: inline re-list of product OBJS_CORE inventory.
if grep -nE '^OBJS_CORE[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'runtime_io_abi\.o|main_driver\.o'; then
  bad "Makefile must not re-list OBJS_CORE inline (wave820 dual authority)"
else
  note "Makefile OBJS_CORE has no dual inline product list (wave820)"
fi
# Consumers: archaeology escape links $(OBJS); stage2 recipes expand $(OBJS).
if ! grep -qE '\$\(OBJS\)' "$MF"; then
  bad "Makefile must still consume \$(OBJS) (wave820 consumers)"
fi
if ! grep -q 'XLANG_HOST_CC_OBJS_CORE' "$MF"; then
  bad "Makefile must keep XLANG_HOST_CC_OBJS_CORE escape (wave820/wave786)"
fi
# Catalog must parse mk (no hardcode second inventory).
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/objs_core.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/objs_core.mk (wave820)"
fi
if grep -nE 'catalog_set OBJS_CORE "' "$_cat_sh" 2>/dev/null | grep -qE 'runtime_io_abi|main_driver'; then
  bad "catalog must not hardcode OBJS_CORE (wave820 dual authority)"
fi
note "B7B OBJS_CORE list authority in mk (product 16; wave820; not physical delete)"
# wave821: B7B archaeology experiment list authority in mk; Makefile include only.
_AE_MK="compiler/mk/archaeology_experiment_objs.mk"
if [ ! -f "$_AE_MK" ]; then
  bad "missing $_AE_MK (wave821 B7B archaeology experiment list authority)"
fi
if ! grep -qE '^DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS\s*=' "$_AE_MK"; then
  bad "$_AE_MK must define DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS (wave821)"
fi
if ! grep -qE '^DRIVER_NO_C_FRONTEND_OBJS\s*=' "$_AE_MK"; then
  bad "$_AE_MK must define DRIVER_NO_C_FRONTEND_OBJS (wave821)"
fi
# Fixed X_FRONTEND_EXPERIMENT multi-token count (7 .o).
_ae_n=$(awk '
  /^DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS[[:space:]]*=/ {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    c=0
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) if (a[i] ~ /\.o$/) c++
    print c+0
    exit
  }
' "$_AE_MK")
if [ "${_ae_n:-0}" -ne 7 ]; then
  bad "wave821 expected X_FRONTEND_EXPERIMENT count 7 in mk, got ${_ae_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/archaeology_experiment_objs\.mk' "$MF"; then
  bad "Makefile must include mk/archaeology_experiment_objs.mk (wave821)"
fi
# Forbid dual authority: inline re-list of experiment inventories.
if grep -nE '^DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'main_driver\.o|typeck_x\.o'; then
  bad "Makefile must not re-list DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS inline (wave821 dual authority)"
else
  note "Makefile X_FRONTEND_EXPERIMENT has no dual inline list (wave821)"
fi
if grep -nE '^DRIVER_NO_C_FRONTEND_OBJS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'runtime_driver_no_c\.o|typeck_f64_bits\.o'; then
  bad "Makefile must not re-list DRIVER_NO_C_FRONTEND_OBJS inline (wave821 dual authority)"
else
  note "Makefile DRIVER_NO_C_FRONTEND_OBJS has no dual inline list (wave821)"
fi
# Consumers: experiment phonies still expand the vars.
if ! grep -qE '\$\(DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS\)' "$MF"; then
  bad "Makefile must still consume \$(DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS) (wave821 consumers)"
fi
if ! grep -qE '\$\(DRIVER_NO_C_FRONTEND_OBJS\)' "$MF"; then
  bad "Makefile must still consume \$(DRIVER_NO_C_FRONTEND_OBJS) (wave821 consumers)"
fi
if ! grep -qE 'bootstrap-driver-seed-x-frontend|xlang-no-c-frontend' "$MF"; then
  bad "Makefile must keep experiment phonies (wave821)"
fi
# Catalog must parse mk (no hardcode second inventory).
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/archaeology_experiment_objs.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/archaeology_experiment_objs.mk (wave821)"
fi
if grep -nE 'catalog_set DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS "' "$_cat_sh" 2>/dev/null | grep -qE 'main_driver|typeck_x'; then
  bad "catalog must not hardcode DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS (wave821 dual authority)"
fi
if grep -nE 'catalog_set DRIVER_NO_C_FRONTEND_OBJS "' "$_cat_sh" 2>/dev/null | grep -qE 'runtime_driver_no_c|typeck_f64'; then
  bad "catalog must not hardcode DRIVER_NO_C_FRONTEND_OBJS (wave821 dual authority)"
fi
note "B7B archaeology experiment list authority in mk (EXPERIMENT 7; wave821; not physical delete)"
# wave822: B7B RELINK + LEGACY list authority in composites.mk; Makefile include only.
_COMP_MK="compiler/mk/driver_seed_composites.mk"
if [ ! -f "$_COMP_MK" ]; then
  bad "missing $_COMP_MK (wave822 B7B RELINK/LEGACY list authority)"
fi
if ! grep -qE '^RELINK_XLANG_PREREQS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define RELINK_XLANG_PREREQS (wave822)"
fi
if ! grep -qE '^LEGACY_XLANG_C_PREREQS\s*:?=' "$_COMP_MK"; then
  bad "$_COMP_MK must define LEGACY_XLANG_C_PREREQS (wave822)"
fi
if ! grep -qE '^LEGACY_XLANG_C_LINK_BASE\s*:?=' "$_COMP_MK"; then
  bad "$_COMP_MK must define LEGACY_XLANG_C_LINK_BASE (wave822)"
fi
if ! grep -qE '^LEGACY_XLANG_C_USER_ASM_LINK\s*:?=' "$_COMP_MK"; then
  bad "$_COMP_MK must define LEGACY_XLANG_C_USER_ASM_LINK (wave822)"
fi
# Fixed RELINK multi-token authority COUNT=14 (non-$(...) tokens on continued lines).
_rl_n=$(awk '
  /^RELINK_XLANG_PREREQS[[:space:]]*=/ { grab=1 }
  grab {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_COMP_MK")
if [ "${_rl_n:-0}" -ne 14 ]; then
  bad "wave822 expected RELINK fixed multi-token count 14 in mk, got ${_rl_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/driver_seed_composites\.mk' "$MF"; then
  bad "Makefile must include mk/driver_seed_composites.mk (wave822)"
fi
# Forbid dual authority: inline re-list of RELINK/LEGACY inventories.
if grep -nE '^RELINK_XLANG_PREREQS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'build-seed-asm-host|driver_x\.o|lsp_io_gen\.c'; then
  bad "Makefile must not re-list RELINK_XLANG_PREREQS inline (wave822 dual authority)"
else
  note "Makefile RELINK_XLANG_PREREQS has no dual inline list (wave822)"
fi
if grep -nE '^LEGACY_XLANG_C_PREREQS[[:space:]]*:?=' "$MF" 2>/dev/null | grep -qE 'pipeline_glue_strict_minimal\.o|ast_gen2\.o'; then
  bad "Makefile must not re-list LEGACY_XLANG_C_PREREQS inline (wave822 dual authority)"
else
  note "Makefile LEGACY_XLANG_C_PREREQS has no dual inline list (wave822)"
fi
if grep -nE '^LEGACY_XLANG_C_LINK_BASE[[:space:]]*:?=' "$MF" 2>/dev/null | grep -qE 'BOOTSTRAP_DRIVER_SEED_LINK_BASE'; then
  bad "Makefile must not re-list LEGACY_XLANG_C_LINK_BASE inline (wave822 dual authority)"
else
  note "Makefile LEGACY_XLANG_C_LINK_BASE has no dual inline list (wave822)"
fi
# Consumers: typeck/codegen / LEGACY XLANG_C recipe still expand the vars.
if ! grep -qE '\$\(RELINK_XLANG_PREREQS\)' "$MF"; then
  bad "Makefile must still consume \$(RELINK_XLANG_PREREQS) (wave822 consumers)"
fi
if ! grep -qE '\$\(LEGACY_XLANG_C_PREREQS\)|\$\(LEGACY_XLANG_C_LINK_BASE\)' "$MF"; then
  bad "Makefile must still consume \$(LEGACY_XLANG_C_*) (wave822 consumers)"
fi
# Catalog already parses composites.mk (wave728/788); must not hardcode RELINK/LEGACY.
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/driver_seed_composites.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/driver_seed_composites.mk (wave822)"
fi
if grep -nE 'catalog_set RELINK_XLANG_PREREQS "' "$_cat_sh" 2>/dev/null | grep -qE 'build-seed-asm-host|driver_x'; then
  bad "catalog must not hardcode RELINK_XLANG_PREREQS (wave822 dual authority)"
fi
if grep -nE 'catalog_set LEGACY_XLANG_C_PREREQS "' "$_cat_sh" 2>/dev/null | grep -qE 'pipeline_glue|ast_gen2'; then
  bad "catalog must not hardcode LEGACY_XLANG_C_PREREQS (wave822 dual authority)"
fi
note "B7B RELINK/LEGACY list authority in composites.mk (RELINK fixed 14; wave822; not physical delete)"
# wave823: B7B source-path deps list authority in x_source_deps.mk; Makefile include only.
_XSD_MK="compiler/mk/x_source_deps.mk"
if [ ! -f "$_XSD_MK" ]; then
  bad "missing $_XSD_MK (wave823 B7B SOURCE_DEPS list authority)"
fi
if ! grep -qE '^SRCS\s*=' "$_XSD_MK"; then
  bad "$_XSD_MK must define SRCS (wave823)"
fi
if ! grep -qE '^MAIN_X_DEPS\s*=' "$_XSD_MK"; then
  bad "$_XSD_MK must define MAIN_X_DEPS (wave823)"
fi
if ! grep -qE '^PREPROCESS_X_DEPS\s*=' "$_XSD_MK"; then
  bad "$_XSD_MK must define PREPROCESS_X_DEPS (wave823)"
fi
if ! grep -qE '^PIPELINE_ASM_X_DEPS\s*=' "$_XSD_MK"; then
  bad "$_XSD_MK must define PIPELINE_ASM_X_DEPS (wave823)"
fi
if ! grep -qE '^PIPELINE_X_DEPS\s*=' "$_XSD_MK"; then
  bad "$_XSD_MK must define PIPELINE_X_DEPS (wave823)"
fi
# Fixed multi-token authority COUNT=19:
#   SRCS 4 + MAIN_X_DEPS 4 + PREPROCESS_X_DEPS 1 + PIPELINE_X_DEPS fixed paths 10
#   (exclude $(PIPELINE_ASM_X_DEPS) expansion token).
_xsd_n=$(awk '
  function count_fixed(line,   n, a, i, c) {
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    c=0
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    return c
  }
  /^SRCS[[:space:]]*=/ { t += count_fixed($0) }
  /^MAIN_X_DEPS[[:space:]]*=/ { t += count_fixed($0) }
  /^PREPROCESS_X_DEPS[[:space:]]*=/ { t += count_fixed($0) }
  /^PIPELINE_X_DEPS[[:space:]]*=/ { t += count_fixed($0) }
  END { print t+0 }
' "$_XSD_MK")
if [ "${_xsd_n:-0}" -ne 19 ]; then
  bad "wave823 expected SOURCE_DEPS fixed multi-token count 19 in mk, got ${_xsd_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/x_source_deps\.mk' "$MF"; then
  bad "Makefile must include mk/x_source_deps.mk (wave823)"
fi
# Forbid dual authority: inline re-list of source-path inventories.
if grep -nE '^SRCS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'main\.from_x\.c|async_cps_codegen\.from_x\.c'; then
  bad "Makefile must not re-list SRCS inline (wave823 dual authority)"
else
  note "Makefile SRCS has no dual inline list (wave823)"
fi
if grep -nE '^MAIN_X_DEPS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'src/main\.x|codegen\.x'; then
  bad "Makefile must not re-list MAIN_X_DEPS inline (wave823 dual authority)"
else
  note "Makefile MAIN_X_DEPS has no dual inline list (wave823)"
fi
if grep -nE '^PIPELINE_X_DEPS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'pipeline\.x|pipeline_glue\.c|ast_pool\.c'; then
  bad "Makefile must not re-list PIPELINE_X_DEPS inline (wave823 dual authority)"
else
  note "Makefile PIPELINE_X_DEPS has no dual inline list (wave823)"
fi
# Consumers (wave823 + wave829 honesty):
#   MAIN_X_DEPS / PREPROCESS_X_DEPS — shell ensure_driver_gen.sh loads mk (wave829
#     FORCE dep-thin dropped Makefile $(MAIN_X_DEPS)/$(PREPROCESS_X_DEPS) prereqs).
#   PIPELINE_X_DEPS — Makefile still exports for try-heat STALE (pipeline_x).
# Catalog must parse mk (no hardcode second inventory).
_cat_sh="$ROOT/compiler/scripts/driver_seed_obj_catalog.sh"
[ -f "$_cat_sh" ] || _cat_sh="scripts/driver_seed_obj_catalog.sh"
if ! grep -q 'mk/x_source_deps.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/x_source_deps.mk (wave823)"
fi
if grep -nE 'catalog_set MAIN_X_DEPS "' "$_cat_sh" 2>/dev/null | grep -qE 'src/main\.x|codegen\.x'; then
  bad "catalog must not hardcode MAIN_X_DEPS (wave823 dual authority)"
fi
if grep -nE 'catalog_set PIPELINE_X_DEPS "' "$_cat_sh" 2>/dev/null | grep -qE 'pipeline\.x|pipeline_glue'; then
  bad "catalog must not hardcode PIPELINE_X_DEPS (wave823 dual authority)"
fi
# ensure_driver_gen.sh must load from mk (not hardcode path inventory) — sole
# product consumer of MAIN_X_DEPS / PREPROCESS_X_DEPS after wave829 FORCE thin.
_edg="$ROOT/compiler/scripts/ensure_driver_gen.sh"
[ -f "$_edg" ] || _edg="scripts/ensure_driver_gen.sh"
if ! grep -q 'mk/x_source_deps.mk' "$_edg"; then
  bad "ensure_driver_gen.sh must load deps from mk/x_source_deps.mk (wave823)"
fi
if ! grep -qE 'MAIN_X_DEPS=\(\$\(_mk_assign_val MAIN_X_DEPS' "$_edg"; then
  bad "ensure_driver_gen.sh must consume MAIN_X_DEPS from mk (wave823/wave829)"
fi
if ! grep -qE 'PREPROCESS_X_DEPS=\(\$\(_mk_assign_val PREPROCESS_X_DEPS' "$_edg"; then
  bad "ensure_driver_gen.sh must consume PREPROCESS_X_DEPS from mk (wave823/wave829)"
fi
if grep -nE 'MAIN_X_DEPS=\(src/main\.x' "$_edg" 2>/dev/null | grep -q 'codegen'; then
  bad "ensure_driver_gen.sh must not hardcode MAIN_X_DEPS array (wave823 dual authority)"
fi
if ! grep -qE '\$\(PIPELINE_X_DEPS\)|PIPELINE_X_DEPS="' "$MF"; then
  bad "Makefile must still consume PIPELINE_X_DEPS (wave823 consumers)"
fi
# wave829: Makefile must NOT re-introduce make-graph dual prereqs for gen leaves.
if grep -nE '^(driver_gen|preprocess_gen)\.c:.*\$\((MAIN|PREPROCESS)_X_DEPS\)' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile driver/preprocess_gen must FORCE-thin (no \$(MAIN/PREPROCESS)_X_DEPS prereq; wave829)"
fi
note "B7B SOURCE_DEPS list authority in mk (fixed 19; wave823; shell consumers wave829; not physical delete)"

# wave824: B7B -E module search roots authority in x_e_dirs.mk; Makefile include only.
_XED_MK="compiler/mk/x_e_dirs.mk"
if [ ! -f "$_XED_MK" ]; then
  bad "missing $_XED_MK (wave824 B7B E_DIRS list authority)"
fi
if ! grep -qE '^MAIN_X_E_DIRS\s*=' "$_XED_MK"; then
  bad "$_XED_MK must define MAIN_X_E_DIRS (wave824)"
fi
if ! grep -qE '^LSP_X_E_DIRS\s*=' "$_XED_MK"; then
  bad "$_XED_MK must define LSP_X_E_DIRS (wave824)"
fi
if ! grep -qE '^PIPELINE_X_E_DIRS\s*=' "$_XED_MK"; then
  bad "$_XED_MK must define PIPELINE_X_E_DIRS (wave824)"
fi
# Fixed multi-token authority COUNT=26: directory path tokens only
# (MAIN 9 + LSP 8 + PIPELINE 9); exclude literal "-L" flag tokens.
_xed_n=0
for _k in MAIN_X_E_DIRS LSP_X_E_DIRS PIPELINE_X_E_DIRS; do
  _line=$(grep -E "^${_k}[[:space:]]*=" "$_XED_MK" | head -1 | sed "s/^${_k}[[:space:]]*=[[:space:]]*//;s/#.*//")
  for _t in $_line; do
    if [ "$_t" != "-L" ]; then
      _xed_n=$((_xed_n + 1))
    fi
  done
done
if [ "${_xed_n:-0}" -ne 26 ]; then
  bad "wave824 expected E_DIRS fixed dir-root count 26 in mk, got ${_xed_n:-0}"
fi
if ! grep -qE 'include[[:space:]]+mk/x_e_dirs\.mk' "$MF"; then
  bad "Makefile must include mk/x_e_dirs.mk (wave824)"
fi
# Forbid dual authority: inline re-list of -E root inventories.
if grep -nE '^MAIN_X_E_DIRS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'src/lsp|src/preprocess'; then
  bad "Makefile must not re-list MAIN_X_E_DIRS inline (wave824 dual authority)"
else
  note "Makefile MAIN_X_E_DIRS has no dual inline list (wave824)"
fi
if grep -nE '^LSP_X_E_DIRS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'src/lsp|src/preprocess'; then
  bad "Makefile must not re-list LSP_X_E_DIRS inline (wave824 dual authority)"
else
  note "Makefile LSP_X_E_DIRS has no dual inline list (wave824)"
fi
if grep -nE '^PIPELINE_X_E_DIRS[[:space:]]*=' "$MF" 2>/dev/null | grep -qE 'src/asm|src/preprocess'; then
  bad "Makefile must not re-list PIPELINE_X_E_DIRS inline (wave824 dual authority)"
else
  note "Makefile PIPELINE_X_E_DIRS has no dual inline list (wave824)"
fi
# Consumers: ensure scripts load from mk (not hardcode dual arrays).
if ! grep -q 'mk/x_e_dirs.mk' "$_edg"; then
  bad "ensure_driver_gen.sh must load MAIN_X_E_DIRS from mk/x_e_dirs.mk (wave824)"
fi
if grep -nE 'MAIN_X_E_DIRS=\(-L' "$_edg" 2>/dev/null | grep -q 'src/lsp'; then
  bad "ensure_driver_gen.sh must not hardcode MAIN_X_E_DIRS array (wave824 dual authority)"
fi
_elsp="$ROOT/compiler/scripts/ensure_lsp_pipeline_gen.sh"
[ -f "$_elsp" ] || _elsp="scripts/ensure_lsp_pipeline_gen.sh"
if ! grep -q 'mk/x_e_dirs.mk' "$_elsp"; then
  bad "ensure_lsp_pipeline_gen.sh must load E_DIRS from mk/x_e_dirs.mk (wave824)"
fi
if grep -nE 'LSP_X_E_DIRS=\(-L' "$_elsp" 2>/dev/null | grep -q 'src/lsp'; then
  bad "ensure_lsp_pipeline_gen.sh must not hardcode LSP_X_E_DIRS array (wave824 dual authority)"
fi
if grep -nE 'PIPELINE_X_E_DIRS=\(-L' "$_elsp" 2>/dev/null | grep -q 'src/asm'; then
  bad "ensure_lsp_pipeline_gen.sh must not hardcode PIPELINE_X_E_DIRS array (wave824 dual authority)"
fi
_earch="$ROOT/compiler/scripts/ensure_archaeology_gen.sh"
[ -f "$_earch" ] || _earch="scripts/ensure_archaeology_gen.sh"
if ! grep -q 'mk/x_e_dirs.mk' "$_earch"; then
  bad "ensure_archaeology_gen.sh must load LSP_X_E_DIRS from mk/x_e_dirs.mk (wave824)"
fi
if grep -nE 'LSP_X_E_DIRS=\(-L' "$_earch" 2>/dev/null | grep -q 'src/lsp'; then
  bad "ensure_archaeology_gen.sh must not hardcode LSP_X_E_DIRS array (wave824 dual authority)"
fi
# Catalog must parse mk (no hardcode second inventory).
if ! grep -q 'mk/x_e_dirs.mk' "$_cat_sh"; then
  bad "driver_seed_obj_catalog.sh must parse mk/x_e_dirs.mk (wave824)"
fi
# driver_leaf kind=lsp must load LSP_X_E_DIRS from mk (not hardcode).
_dl="$ROOT/compiler/scripts/driver_leaf_x_to_o.sh"
[ -f "$_dl" ] || _dl="scripts/driver_leaf_x_to_o.sh"
if ! grep -q 'mk/x_e_dirs.mk' "$_dl"; then
  bad "driver_leaf_x_to_o.sh must load LSP_X_E_DIRS from mk/x_e_dirs.mk (wave824)"
fi
if grep -nE "printf '%s' '-L \.\. -L src/lsp" "$_dl" 2>/dev/null | grep -q 'src/preprocess'; then
  bad "driver_leaf_x_to_o.sh must not hardcode LSP_X_E_DIRS string (wave824 dual authority)"
fi
note "B7B E_DIRS list authority in mk (fixed dir-roots 26; wave824; not physical delete)"

# wave850: B7B product archaeology full link bag in composites.mk; Makefile expand only.
_COMP_MK="compiler/mk/driver_seed_composites.mk"
if [ ! -f "$_COMP_MK" ]; then
  bad "missing $_COMP_MK (wave850 B7B RELINK_PRODUCT_LINK authority)"
fi
if ! grep -qE '^RELINK_PRODUCT_LINK_BASE\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define RELINK_PRODUCT_LINK_BASE (wave850)"
fi
if ! grep -qE '^RELINK_PRODUCT_LINK_OBJS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define RELINK_PRODUCT_LINK_OBJS (wave850)"
fi
# Fixed RELINK_PRODUCT_LINK_BASE multi-token authority COUNT=8 (non-$(...) tokens).
_rpl_n=$(awk '
  /^RELINK_PRODUCT_LINK_BASE[[:space:]]*=/ { grab=1 }
  grab {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_COMP_MK")
if [ "${_rpl_n:-0}" -ne 8 ]; then
  bad "wave850 expected RELINK_PRODUCT_LINK_BASE fixed multi-token count 8 in mk, got ${_rpl_n:-0}"
fi
# Forbid dual authority: inline re-list of product link bag in Makefile recipes.
if grep -nE 'BTC_OBJS="\$\(DRIVER_SEED_GLUE_PREFIX\)|RXL_LINK_OBJS="\$\(DRIVER_SEED_GLUE_PREFIX\)' "$MF" 2>/dev/null | grep -qE 'driver_x\.o|lsp_io_std_heap'; then
  bad "Makefile must not re-list product link bag inline in BTC/RXL (wave850 dual authority)"
else
  note "Makefile BTC/RXL use \$(RELINK_PRODUCT_LINK_OBJS) (wave850)"
fi
# wave856: recipe no longer exports BTC/RXL_LINK_OBJS=; export-relink-product-link-objs expands bag.
if ! grep -qE '^export-relink-product-link-objs:' "$MF"; then
  bad "Makefile must define export-relink-product-link-objs for RELINK_PRODUCT_LINK_OBJS (wave850+856)"
fi
if ! awk '/^export-relink-product-link-objs:/{p=1;next} p&&/^[^\t#]/{exit} p' "$MF" | grep -q 'RELINK_PRODUCT_LINK_OBJS'; then
  bad "export-relink-product-link-objs must expand RELINK_PRODUCT_LINK_OBJS (wave850+856)"
fi
# At least one consumer path remains (export leaf + optional comments/recipes).
_rpl_consumers=$(grep -cE '\$\(RELINK_PRODUCT_LINK_OBJS\)' "$MF" || true)
if [ "${_rpl_consumers:-0}" -lt 1 ]; then
  bad "Makefile must still reference \$(RELINK_PRODUCT_LINK_OBJS) (wave850+856; got ${_rpl_consumers:-0})"
fi
note "B7B RELINK_PRODUCT_LINK authority in composites.mk (BASE fixed 8; wave850+856 export leaf; not physical delete)"

# wave851: B7B XXL/BS/XNC full link bags in mk; Makefile expand only.
_COMP_MK="compiler/mk/driver_seed_composites.mk"
_ARCH_MK="compiler/mk/archaeology_experiment_objs.mk"
if [ ! -f "$_COMP_MK" ]; then
  bad "missing $_COMP_MK (wave851 B7B XXL/BS link authority)"
fi
if [ ! -f "$_ARCH_MK" ]; then
  bad "missing $_ARCH_MK (wave851 B7B XNC link authority)"
fi
if ! grep -qE '^XLANG_X_LINK_BASE\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define XLANG_X_LINK_BASE (wave851)"
fi
if ! grep -qE '^XLANG_X_LINK_OBJS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define XLANG_X_LINK_OBJS (wave851)"
fi
if ! grep -qE '^BOOTSTRAP_SELF_LINK_OBJS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define BOOTSTRAP_SELF_LINK_OBJS (wave851)"
fi
if ! grep -qE '^XLANG_NO_C_FRONTEND_LINK_OBJS\s*=' "$_ARCH_MK"; then
  bad "$_ARCH_MK must define XLANG_NO_C_FRONTEND_LINK_OBJS (wave851)"
fi
# Fixed XLANG_X_LINK_BASE multi-token authority COUNT=8 (non-$(...) tokens).
_xxl_n=$(awk '
  /^XLANG_X_LINK_BASE[[:space:]]*=/ { grab=1 }
  grab {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_COMP_MK")
if [ "${_xxl_n:-0}" -ne 8 ]; then
  bad "wave851 expected XLANG_X_LINK_BASE fixed multi-token count 8 in mk, got ${_xxl_n:-0}"
fi
# Fixed XLANG_NO_C_FRONTEND_LINK_OBJS multi-token authority COUNT=9.
_xnc_n=$(awk '
  /^XLANG_NO_C_FRONTEND_LINK_OBJS[[:space:]]*=/ { grab=1 }
  grab {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_ARCH_MK")
if [ "${_xnc_n:-0}" -ne 9 ]; then
  bad "wave851 expected XLANG_NO_C_FRONTEND_LINK_OBJS fixed multi-token count 9 in mk, got ${_xnc_n:-0}"
fi
# Forbid dual authority: inline re-list of XXL/BS/XNC bags in Makefile recipes.
if grep -nE 'XXL_LINK_OBJS="\$\(DRIVER_SEED_OBJS\)' "$MF" 2>/dev/null | grep -qE 'driver_x\.o|lsp_io_std_heap'; then
  bad "Makefile must not re-list xlang-x link bag inline in XXL (wave851 dual authority)"
else
  note "Makefile XXL uses \$(XLANG_X_LINK_OBJS) (wave851)"
fi
if grep -nE 'BS_LINK_OBJS="\$\(DRIVER_SEED_OBJS\)' "$MF" 2>/dev/null | grep -qE 'driver_x\.o|lsp_io_std_heap'; then
  bad "Makefile must not re-list bootstrap-self link bag inline in BS (wave851 dual authority)"
else
  note "Makefile BS uses \$(BOOTSTRAP_SELF_LINK_OBJS) (wave851)"
fi
if grep -nE 'XNC_LINK_OBJS="\$\(DRIVER_NO_C_FRONTEND_OBJS\)' "$MF" 2>/dev/null | grep -qE 'driver_x\.o|lsp_diag_stubs_no_c'; then
  bad "Makefile must not re-list no-C full link bag inline in XNC (wave851 dual authority)"
else
  note "Makefile XNC uses \$(XLANG_NO_C_FRONTEND_LINK_OBJS) (wave851)"
fi
# wave856: recipe no longer exports XXL/BS/XNC LINK_OBJS=; export leaves expand bags.
for _pair in   'export-xlang-x-link-objs:XLANG_X_LINK_OBJS'   'export-bs-link-objs:BOOTSTRAP_SELF_LINK_OBJS'   'export-xnc-link-objs:XLANG_NO_C_FRONTEND_LINK_OBJS'
do
  _tgt=${_pair%%:*}
  _var=${_pair##*:}
  if ! grep -qE "^${_tgt}:" "$MF"; then
    bad "Makefile must define ${_tgt} for ${_var} (wave851+856)"
  fi
  if ! awk -v t="${_tgt}" 'index($0,t":")==1{p=1;next} p&&/^[^	#]/{exit} p' "$MF" | grep -q "${_var}"; then
    bad "${_tgt} must expand ${_var} (wave851+856)"
  fi
done
note "B7B XXL/BS/XNC link authority in mk (bags 3; wave851+856 export leaves; not physical delete)"

# wave852: B7B BXF full link bag in archaeology_experiment; Makefile expand only.
_ARCH_MK="compiler/mk/archaeology_experiment_objs.mk"
if [ ! -f "$_ARCH_MK" ]; then
  bad "missing $_ARCH_MK (wave852 B7B BXF link authority)"
fi
if ! grep -qE '^DRIVER_SEED_X_FRONTEND_LINK_OBJS\s*=' "$_ARCH_MK"; then
  bad "$_ARCH_MK must define DRIVER_SEED_X_FRONTEND_LINK_OBJS (wave852)"
fi
# Fixed multi-token authority COUNT=2 (driver + preprocess satellites).
_bxf_n=$(awk '
  /^DRIVER_SEED_X_FRONTEND_LINK_OBJS[[:space:]]*=/ { grab=1 }
  grab {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_ARCH_MK")
if [ "${_bxf_n:-0}" -ne 2 ]; then
  bad "wave852 expected DRIVER_SEED_X_FRONTEND_LINK_OBJS fixed multi-token count 2 in mk, got ${_bxf_n:-0}"
fi
# Forbid dual authority: inline re-list of BXF bag in Makefile recipe.
# Match EXPERIMENT_OBJS expanded with trailing satellite tokens (dual re-list shape).
if grep -nE 'BXF_LINK_OBJS="\$\(DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS\)' "$MF" 2>/dev/null | grep -qE 'preprocess|PIPELINE_LIBS|DRIVER_SUBCMD'; then
  bad "Makefile must not re-list BXF link bag inline (wave852 dual authority)"
else
  note "Makefile BXF uses \$(DRIVER_SEED_X_FRONTEND_LINK_OBJS) (wave852)"
fi
# wave856: recipe no longer exports BXF_LINK_OBJS=; export-bxf-link-objs expands bag.
if ! grep -qE '^export-bxf-link-objs:' "$MF"; then
  bad "Makefile must define export-bxf-link-objs for DRIVER_SEED_X_FRONTEND_LINK_OBJS (wave852+856)"
fi
if ! awk '/^export-bxf-link-objs:/{p=1;next} p&&/^[^	#]/{exit} p' "$MF" | grep -q 'DRIVER_SEED_X_FRONTEND_LINK_OBJS'; then
  bad "export-bxf-link-objs must expand DRIVER_SEED_X_FRONTEND_LINK_OBJS (wave852+856)"
fi
note "B7B BXF link authority in archaeology_experiment_objs.mk (fixed 2; wave852+856 export leaf; not physical delete)"

# wave853: B7B seed phase1/final full link bags in composites; Makefile expand only.
_COMP_MK="compiler/mk/driver_seed_composites.mk"
if [ ! -f "$_COMP_MK" ]; then
  bad "missing $_COMP_MK (wave853 B7B seed phase1/final link authority)"
fi
if ! grep -qE '^BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS (wave853)"
fi
if ! grep -qE '^BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS (wave853)"
fi
# Phase1: one fixed multi-token path (seed_host partial); final: all $(...) expand.
_p1_n=$(awk '
  /^BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS[[:space:]]*=/ { grab=1 }
  grab {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_COMP_MK")
if [ "${_p1_n:-0}" -ne 1 ]; then
  bad "wave853 expected PHASE1_LINK_OBJS fixed multi-token count 1 in mk, got ${_p1_n:-0}"
fi
_fn_n=$(awk '
  /^BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS[[:space:]]*=/ { grab=1 }
  grab {
    line=$0
    sub(/^[^=]*=[[:space:]]*/, "", line)
    gsub(/\\/, "", line)
    n=split(line, a, /[[:space:]]+/)
    for (i=1;i<=n;i++) {
      if (a[i] == "") continue
      if (a[i] ~ /^\$\(/) continue
      c++
    }
    if ($0 !~ /\\[[:space:]]*$/) { print c+0; exit }
  }
' "$_COMP_MK")
if [ "${_fn_n:-0}" -ne 0 ]; then
  bad "wave853 expected FINAL_LINK_OBJS fixed multi-token count 0 in mk, got ${_fn_n:-0}"
fi
# Forbid dual authority: SEED_LINK_OBJS re-list of LINK_BASE composition in Makefile.
if grep -nE "SEED_LINK_OBJS=.*BOOTSTRAP_DRIVER_SEED_LINK_BASE" "$MF" 2>/dev/null | grep -qE 'USER_ASM|GLUE|HOST_STUBS|partial'; then
  bad "Makefile must not re-list seed phase1/final link bag inline (wave853 dual authority)"
else
  note "Makefile SEED_LINK_OBJS uses PHASE1/FINAL mk vars (wave853)"
fi
if ! grep -qE "SEED_LINK_OBJS=.*BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS" "$MF"; then
  bad "Makefile phase1 export must expand SEED_LINK_OBJS=\$(BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS) (wave853)"
fi
if ! grep -qE "SEED_LINK_OBJS=.*BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS" "$MF"; then
  bad "Makefile final export must expand SEED_LINK_OBJS=\$(BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS) (wave853)"
fi
note "B7B seed phase1/final link authority in composites.mk (bags 2; wave853; not physical delete)"

# wave854: B7B seed-gate REQUIRED_OBJS bags in mk; Makefile expand only.
_COMP_MK="compiler/mk/driver_seed_composites.mk"
_ARCH_MK="compiler/mk/archaeology_experiment_objs.mk"
if [ ! -f "$_COMP_MK" ]; then
  bad "missing $_COMP_MK (wave854 B7B seed-gate REQUIRED authority)"
fi
if [ ! -f "$_ARCH_MK" ]; then
  bad "missing $_ARCH_MK (wave854 B7B seed-gate REQUIRED authority)"
fi
if ! grep -qE '^RELINK_XLANG_REQUIRED_OBJS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define RELINK_XLANG_REQUIRED_OBJS (wave854)"
fi
if ! grep -qE '^XLANG_X_REQUIRED_OBJS\s*=' "$_COMP_MK"; then
  bad "$_COMP_MK must define XLANG_X_REQUIRED_OBJS (wave854)"
fi
if ! grep -qE '^XLANG_NO_C_FRONTEND_REQUIRED_OBJS\s*=' "$_ARCH_MK"; then
  bad "$_ARCH_MK must define XLANG_NO_C_FRONTEND_REQUIRED_OBJS (wave854)"
fi
_count_fixed() {
  # Count non-$(...) tokens on a single-line VAR= assignment.
  local mk="$1" var="$2"
  awk -v var="$var" '
    $0 ~ ("^" var "[[:space:]]*=") {
      line=$0
      sub(/^[^=]*=[[:space:]]*/, "", line)
      gsub(/\\/, "", line)
      n=split(line, a, /[[:space:]]+/)
      c=0
      for (i=1;i<=n;i++) {
        if (a[i] == "") continue
        if (a[i] ~ /^\$\(/) continue
        c++
      }
      print c+0
      exit
    }
  ' "$mk"
}
_rxl_n=$(_count_fixed "$_COMP_MK" RELINK_XLANG_REQUIRED_OBJS)
if [ "${_rxl_n:-0}" -ne 6 ]; then
  bad "wave854 expected RELINK_XLANG_REQUIRED_OBJS fixed multi-token count 6 in mk, got ${_rxl_n:-0}"
fi
_xxl_n=$(_count_fixed "$_COMP_MK" XLANG_X_REQUIRED_OBJS)
if [ "${_xxl_n:-0}" -ne 12 ]; then
  bad "wave854 expected XLANG_X_REQUIRED_OBJS fixed multi-token count 12 in mk, got ${_xxl_n:-0}"
fi
_xnc_n=$(_count_fixed "$_ARCH_MK" XLANG_NO_C_FRONTEND_REQUIRED_OBJS)
if [ "${_xnc_n:-0}" -ne 3 ]; then
  bad "wave854 expected XLANG_NO_C_FRONTEND_REQUIRED_OBJS fixed multi-token count 3 in mk, got ${_xnc_n:-0}"
fi
# Forbid dual authority: hardcode multi-token REQUIRED_OBJS strings in Makefile.
if grep -nE 'RXL_REQUIRED_OBJS="[^$]*\.o[^$]*\.o' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not re-list RXL_REQUIRED_OBJS multi-token inline (wave854 dual authority)"
fi
if grep -nE 'XXL_REQUIRED_OBJS="[^$]*\.o[^$]*\.o' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not re-list XXL_REQUIRED_OBJS multi-token inline (wave854 dual authority)"
fi
if grep -nE 'XNC_REQUIRED_OBJS="[^$]*\.o[^$]*\.o' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not re-list XNC_REQUIRED_OBJS multi-token inline (wave854 dual authority)"
fi
# wave855: Makefile must not re-export multi-token REQUIRED env (shell loads mk).
if grep -nE 'RXL_REQUIRED_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export RXL_REQUIRED_OBJS (wave855; shell loads mk)"
else
  note "Makefile relink-xlang-lexer drops RXL_REQUIRED_OBJS export (wave855)"
fi
if grep -nE 'XXL_REQUIRED_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export XXL_REQUIRED_OBJS (wave855; shell loads mk)"
else
  note "Makefile xlang-x drops XXL_REQUIRED_OBJS export (wave855)"
fi
if grep -nE 'XNC_REQUIRED_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export XNC_REQUIRED_OBJS (wave855; shell loads mk)"
else
  note "Makefile xlang-no-c-frontend drops XNC_REQUIRED_OBJS export (wave855)"
fi
# Shells load FIXED multi-token keys from mk authority (wave855).
_rxl_sh=compiler/scripts/relink_xlang_lexer.sh
_xxl_sh=compiler/scripts/xlang_x.sh
_xnc_sh=compiler/scripts/xlang_no_c_frontend.sh
for _sh in "$_rxl_sh" "$_xxl_sh" "$_xnc_sh"; do
  if [ ! -f "$_sh" ]; then
    bad "missing $_sh (wave855)"
  fi
  if ! grep -q '_mk_assign_val' "$_sh"; then
    bad "$_sh must load REQUIRED via _mk_assign_val from mk (wave855)"
  fi
done
if ! grep -qE 'RELINK_XLANG_REQUIRED_OBJS' "$_rxl_sh"; then
  bad "$_rxl_sh must load RELINK_XLANG_REQUIRED_OBJS (wave855)"
fi
if ! grep -qE 'XLANG_X_REQUIRED_OBJS' "$_xxl_sh"; then
  bad "$_xxl_sh must load XLANG_X_REQUIRED_OBJS (wave855)"
fi
if ! grep -qE 'XLANG_NO_C_FRONTEND_REQUIRED_OBJS' "$_xnc_sh"; then
  bad "$_xnc_sh must load XLANG_NO_C_FRONTEND_REQUIRED_OBJS (wave855)"
fi
# Shell --check honesty for wave855.
if ! bash "$_rxl_sh" --check >/dev/null 2>&1; then
  bad "relink_xlang_lexer.sh --check failed (wave855)"
fi
if ! bash "$_xxl_sh" --check >/dev/null 2>&1; then
  bad "xlang_x.sh --check failed (wave855)"
fi
if ! bash "$_xnc_sh" --check >/dev/null 2>&1; then
  bad "xlang_no_c_frontend.sh --check failed (wave855)"
fi
note "B7B seed-gate REQUIRED_OBJS authority in mk (bags 3; wave854; not physical delete)"
note "B7B seed-gate REQUIRED shell-load from mk (shells 3; wave855; not physical delete)"

# wave856: Makefile must not re-export multi-token LINK_OBJS env (shell loads export leaf).
# PLATFORM: SHARED — check mode cwd=ROOT; MF=compiler/Makefile; shells under compiler/scripts.
if grep -nE $'^\t[^\n]*RXL_LINK_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export RXL_LINK_OBJS (wave856; shell loads export leaf)"
else
  note "Makefile relink-xlang-lexer drops RXL_LINK_OBJS export (wave856)"
fi
if grep -nE $'^\t[^\n]*XXL_LINK_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export XXL_LINK_OBJS (wave856; shell loads export leaf)"
else
  note "Makefile xlang-x drops XXL_LINK_OBJS export (wave856)"
fi
if grep -nE $'^\t[^\n]*XNC_LINK_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export XNC_LINK_OBJS (wave856; shell loads export leaf)"
else
  note "Makefile xlang-no-c-frontend drops XNC_LINK_OBJS export (wave856)"
fi
if grep -nE $'^\t[^\n]*BXF_LINK_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export BXF_LINK_OBJS (wave856; shell loads export leaf)"
else
  note "Makefile BXF drops BXF_LINK_OBJS export (wave856)"
fi
if grep -nE $'^\t[^\n]*BTC_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export BTC_OBJS (wave856; shell loads export leaf)"
else
  note "Makefile bootstrap-typeck/codegen drops BTC_OBJS export (wave856)"
fi
if grep -nE $'^\t[^\n]*BS_LINK_OBJS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export BS_LINK_OBJS (wave856; shell loads export leaf)"
else
  note "Makefile bootstrap-self drops BS_LINK_OBJS export (wave856)"
fi
# Export leaves must exist (5 bags).
for _t in \
  export-relink-product-link-objs \
  export-xlang-x-link-objs \
  export-xnc-link-objs \
  export-bxf-link-objs \
  export-bs-link-objs
do
  if ! grep -qE "^${_t}:" "$MF"; then
    bad "Makefile must define ${_t} (wave856)"
  fi
done
note "Makefile export-*-link-objs leaves 5 (wave856)"
# Shells load via export leaf helper.
_rxl_sh=compiler/scripts/relink_xlang_lexer.sh
_xxl_sh=compiler/scripts/xlang_x.sh
_xnc_sh=compiler/scripts/xlang_no_c_frontend.sh
_btc_sh=compiler/scripts/bootstrap_typeck_codegen.sh
_bxf_sh=compiler/scripts/bootstrap_driver_seed_x_frontend.sh
_bs_sh=compiler/scripts/bootstrap_self.sh
for _sh in "$_rxl_sh" "$_xxl_sh" "$_xnc_sh" "$_btc_sh" "$_bxf_sh" "$_bs_sh"; do
  if [ ! -f "$_sh" ]; then
    bad "missing $_sh (wave856)"
  fi
  if ! grep -q '_load_link_objs_via_make' "$_sh"; then
    bad "$_sh must load LINK_OBJS via _load_link_objs_via_make (wave856)"
  fi
done
# Shell --check honesty for wave856 (shells cd to compiler/ themselves).
if ! bash "$_rxl_sh" --check >/dev/null 2>&1; then
  bad "relink_xlang_lexer.sh --check failed (wave856)"
fi
if ! bash "$_xxl_sh" --check >/dev/null 2>&1; then
  bad "xlang_x.sh --check failed (wave856)"
fi
if ! bash "$_xnc_sh" --check >/dev/null 2>&1; then
  bad "xlang_no_c_frontend.sh --check failed (wave856)"
fi
if ! bash "$_btc_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_typeck_codegen.sh --check failed (wave856)"
fi
if ! bash "$_bxf_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_driver_seed_x_frontend.sh --check failed (wave856)"
fi
if ! bash "$_bs_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_self.sh --check failed (wave856)"
fi
# Export leaf expands non-empty bag (smoke; cwd=compiler).
_ex=$(cd "$COMPILER_DIR" && MAKEFLAGS= make -s export-relink-product-link-objs 2>/dev/null | head -1 || true)
if ! grep -qE '^LINK_OBJS=' <<<"$_ex"; then
  bad "export-relink-product-link-objs must print LINK_OBJS=... (wave856)"
fi
_n=$(printf '%s' "${_ex#LINK_OBJS=}" | wc -w | tr -d ' ')
if [ "${_n:-0}" -lt 10 ]; then
  bad "export-relink-product-link-objs bag too small (n=$_n; wave856)"
fi
note "B7B LINK_OBJS shell-load via make export leaves (bags 5 / shells 6; wave856; not physical delete)"

# wave857: Makefile must not re-export multi-token LINK_CFLAGS env (shell loads export leaf).
# PLATFORM: SHARED — check mode cwd=ROOT; MF=compiler/Makefile; shells under compiler/scripts.
if grep -nE $'^\t[^\n]*RXL_LINK_CFLAGS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export RXL_LINK_CFLAGS (wave857; shell loads export leaf)"
else
  note "Makefile relink-xlang-lexer drops RXL_LINK_CFLAGS export (wave857)"
fi
if grep -nE $'^\t[^\n]*XXL_LINK_CFLAGS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export XXL_LINK_CFLAGS (wave857; shell loads export leaf)"
else
  note "Makefile xlang-x drops XXL_LINK_CFLAGS export (wave857)"
fi
if grep -nE $'^\t[^\n]*XNC_LINK_CFLAGS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export XNC_LINK_CFLAGS (wave857; shell loads export leaf)"
else
  note "Makefile xlang-no-c-frontend drops XNC_LINK_CFLAGS export (wave857)"
fi
if grep -nE $'^\t[^\n]*BXF_LINK_CFLAGS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export BXF_LINK_CFLAGS (wave857; shell loads export leaf)"
else
  note "Makefile BXF drops BXF_LINK_CFLAGS export (wave857)"
fi
if grep -nE $'^\t[^\n]*BTC_CFLAGS=' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export BTC_CFLAGS (wave857; shell loads export leaf)"
else
  note "Makefile bootstrap-typeck/codegen drops BTC_CFLAGS export (wave857)"
fi
if grep -nE $'^\t[^\n]*(BS_LINK_FLAGS=|BS_LINK_CFLAGS=)' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not export BS_LINK_FLAGS/BS_LINK_CFLAGS (wave857; shell loads export leaf)"
else
  note "Makefile bootstrap-self drops BS_LINK_FLAGS export (wave857)"
fi
# Export leaves must exist (4 formulas).
for _t in \
  export-relink-product-link-cflags \
  export-btc-typeck-link-cflags \
  export-xnc-link-cflags \
  export-bxf-link-cflags
do
  if ! grep -qE "^${_t}:" "$MF"; then
    bad "Makefile must define ${_t} (wave857)"
  fi
done
note "Makefile export-*-link-cflags leaves 4 (wave857)"
# Shells load via export leaf helper.
_rxl_sh=compiler/scripts/relink_xlang_lexer.sh
_xxl_sh=compiler/scripts/xlang_x.sh
_xnc_sh=compiler/scripts/xlang_no_c_frontend.sh
_btc_sh=compiler/scripts/bootstrap_typeck_codegen.sh
_bxf_sh=compiler/scripts/bootstrap_driver_seed_x_frontend.sh
_bs_sh=compiler/scripts/bootstrap_self.sh
for _sh in "$_rxl_sh" "$_xxl_sh" "$_xnc_sh" "$_btc_sh" "$_bxf_sh" "$_bs_sh"; do
  if [ ! -f "$_sh" ]; then
    bad "missing $_sh (wave857)"
  fi
  if ! grep -q '_load_link_cflags_via_make' "$_sh"; then
    bad "$_sh must load LINK_CFLAGS via _load_link_cflags_via_make (wave857)"
  fi
done
# Shell --check honesty for wave857 (shells cd to compiler/ themselves).
if ! bash "$_rxl_sh" --check >/dev/null 2>&1; then
  bad "relink_xlang_lexer.sh --check failed (wave857)"
fi
if ! bash "$_xxl_sh" --check >/dev/null 2>&1; then
  bad "xlang_x.sh --check failed (wave857)"
fi
if ! bash "$_xnc_sh" --check >/dev/null 2>&1; then
  bad "xlang_no_c_frontend.sh --check failed (wave857)"
fi
if ! bash "$_btc_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_typeck_codegen.sh --check failed (wave857)"
fi
if ! bash "$_bxf_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_driver_seed_x_frontend.sh --check failed (wave857)"
fi
if ! bash "$_bs_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_self.sh --check failed (wave857)"
fi
# Export leaf expands non-empty CFLAGS (smoke; cwd=compiler).
_ex=$(cd "$COMPILER_DIR" && MAKEFLAGS= make -s export-relink-product-link-cflags 2>/dev/null | head -1 || true)
if ! grep -qE '^LINK_CFLAGS=' <<<"$_ex"; then
  bad "export-relink-product-link-cflags must print LINK_CFLAGS=... (wave857)"
fi
if ! grep -qE -- '-DXLANG_USE_X_DRIVER' <<<"$_ex"; then
  bad "export-relink-product-link-cflags must expand DRIVER_SEED defines (wave857)"
fi
note "B7B LINK_CFLAGS shell-load via make export leaves (bags 4 / shells 6; wave857; not physical delete)"

# wave858: LEGACY xlang-c shell-primary (no dual $(CC) LEGACY link body)
_leg_sh="$COMPILER_DIR/scripts/legacy_xlang_c_link.sh"
if [ ! -f "$_leg_sh" ]; then
  bad "missing $_leg_sh (wave858)"
fi
if ! grep -q 'legacy_xlang_c_link\.sh' "$MF"; then
  bad "Makefile must thin-call legacy_xlang_c_link.sh (wave858)"
fi
if grep -nE $'\t\$\(CC\).*LEGACY_XLANG_C_LINK' "$MF" 2>/dev/null | grep -q .; then
  bad "Makefile must not keep dual \$(CC) LEGACY_XLANG_C_LINK body (wave858)"
fi
if ! grep -qE '^export-legacy-xlang-c-link-objs:' "$MF"; then
  bad "Makefile must define export-legacy-xlang-c-link-objs (wave858)"
fi
if ! bash "$_leg_sh" --check >/dev/null 2>&1; then
  bad "legacy_xlang_c_link.sh --check failed (wave858)"
fi
_ex=$(cd "$COMPILER_DIR" && MAKEFLAGS= make -s export-legacy-xlang-c-link-objs 2>/dev/null | head -1 || true)
if ! grep -qE '^LINK_OBJS=' <<<"$_ex"; then
  bad "export-legacy-xlang-c-link-objs must print LINK_OBJS=... (wave858)"
fi
if ! grep -qE 'ast_gen2\.o|pipeline_glue_strict_minimal' <<<"$_ex"; then
  bad "export-legacy-xlang-c-link-objs must expand LEGACY prereqs (wave858)"
fi
note "B7B LEGACY xlang-c link shell-primary (wave858; not physical delete)"

# wave859: XXP/BXC multi-token bag shell-load (no multi-token XXP_*/BXC_ env in recipes)
if ! grep -qE '^export-xxp-link-bags:' "$MF"; then
  bad "Makefile must define export-xxp-link-bags (wave859)"
fi
if ! grep -qE '^export-bxc-link-objs:' "$MF"; then
  bad "Makefile must define export-bxc-link-objs (wave859)"
fi
_xxp_sh="$COMPILER_DIR/scripts/xlang_x_pipeline.sh"
_bxc_sh="$COMPILER_DIR/scripts/bootstrap_x_compiler.sh"
if [ ! -f "$_xxp_sh" ]; then
  bad "missing $_xxp_sh (wave859)"
fi
if [ ! -f "$_bxc_sh" ]; then
  bad "missing $_bxc_sh (wave859)"
fi
if ! bash "$_xxp_sh" --check >/dev/null 2>&1; then
  bad "xlang_x_pipeline.sh --check failed (wave859)"
fi
if ! bash "$_bxc_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_x_compiler.sh --check failed (wave859)"
fi
# Recipe must not re-export multi-token XXP/BXC bags
_xxp_rec=$(awk '
  /^xlang-x-pipeline:/ { hit=1; next }
  hit && /^[^[:space:]#]/ { exit }
  hit && /^\t/ { print }
' "$MF")
if grep -qE 'XXP_BASE_OBJS=|XXP_LINK_OBJS=|XXP_SATELLITE_OBJS=' <<<"$_xxp_rec"; then
  bad "xlang-x-pipeline recipe must not export XXP_* bags (wave859)"
fi
_bxc_rec=$(awk '
  /^bootstrap-x-compiler:/ { hit=1; next }
  hit && /^[^[:space:]#]/ { exit }
  hit && /^\t/ { print }
' "$MF")
if grep -qE 'BXC_LINK_OBJS=' <<<"$_bxc_rec"; then
  bad "bootstrap-x-compiler recipe must not export BXC_LINK_OBJS (wave859)"
fi
_ex=$(cd "$COMPILER_DIR" && MAKEFLAGS= make -s export-xxp-link-bags 2>/dev/null || true)
if ! grep -qE '^XXP_BASE_OBJS=' <<<"$_ex"; then
  bad "export-xxp-link-bags must print XXP_BASE_OBJS=... (wave859)"
fi
if ! grep -qE '^XXP_LINK_OBJS=' <<<"$_ex"; then
  bad "export-xxp-link-bags must print XXP_LINK_OBJS=... (wave859)"
fi
if ! grep -qE 'pipeline_x\.o|parser_x\.o|USER_ASM|user_asm|simd_enc' <<<"$_ex"; then
  # LINK bag must expand satellites (nested USER_ASM or satellite names)
  if ! grep -qE 'simd_enc|parser_x|typeck_x|codegen_x' <<<"$_ex"; then
    bad "export-xxp-link-bags must expand PIPELINE_X link/satellite bags (wave859)"
  fi
fi
_ex=$(cd "$COMPILER_DIR" && MAKEFLAGS= make -s export-bxc-link-objs 2>/dev/null | head -1 || true)
if ! grep -qE '^LINK_OBJS=' <<<"$_ex"; then
  bad "export-bxc-link-objs must print LINK_OBJS=... (wave859)"
fi
if ! grep -qE 'src/main|src/runtime|diag\.o' <<<"$_ex"; then
  bad "export-bxc-link-objs must expand OBJS/OBJS_CORE (wave859)"
fi
note "B7B XXP/BXC multi-token bag shell-load (bags 2 / shells 2; wave859; not physical delete)"

# wave860: driver_leaf BASE_CFLAGS multi-token shell-load (no BASE_CFLAGS= in recipes)
if ! grep -qE '^export-driver-leaf-base-cflags:' "$MF"; then
  bad "Makefile must define export-driver-leaf-base-cflags (wave860)"
fi
_dl_sh="$COMPILER_DIR/scripts/driver_leaf_x_to_o.sh"
if [ ! -f "$_dl_sh" ]; then
  bad "missing $_dl_sh (wave860)"
fi
if ! bash "$_dl_sh" --check >/dev/null 2>&1; then
  bad "driver_leaf_x_to_o.sh --check failed (wave860 BASE_CFLAGS shell-load)"
fi
if grep -nE $'^\tBASE_CFLAGS=' "$MF" 2>/dev/null | head -1 | grep -q .; then
  bad "Makefile must not inject BASE_CFLAGS= on recipes (wave860; shell loads export leaf)"
fi
_ex=$(cd "$COMPILER_DIR" && MAKEFLAGS= make -s export-driver-leaf-base-cflags 2>/dev/null | head -1 || true)
if ! grep -qE '^BASE_CFLAGS=' <<<"$_ex"; then
  bad "export-driver-leaf-base-cflags must print BASE_CFLAGS=... (wave860)"
fi
if ! grep -qE -- '-I\.|-Iinclude|-Isrc' <<<"$_ex"; then
  bad "export-driver-leaf-base-cflags must expand product includes (wave860)"
fi
if ! grep -qE -- '-Wall|-Wextra|-O2' <<<"$_ex"; then
  # default CFLAGS always has -Wall; OPT may add -O2
  if ! grep -qE -- '-Wall' <<<"$_ex"; then
    bad "export-driver-leaf-base-cflags must expand CFLAGS (wave860)"
  fi
fi
note "B7B driver_leaf BASE_CFLAGS multi-token shell-load (leaves 8; wave860; not physical delete)"

# wave861: RT_SEED_SLICE multi-token -I CFLAGS hygiene (5 leaves plain CFLAGS=)
# G.7: do not hardcode .o path inventory here — pattern-only (catalog owns list).
# Recipe lines only (tab-prefixed env inject) — comments may name the retired bag.
if grep -nE $'^\t[^\n]*CFLAGS="\$\(CFLAGS\) -I\. -Iinclude -Isrc"' "$MF" 2>/dev/null | head -1 | grep -q .; then
  bad "Makefile must not inject multi-token CFLAGS=\"\$(CFLAGS) -I. -Iinclude -Isrc\" on recipes (wave861; product -I already in CFLAGS)"
fi
# RT slice FORCE leaves: pattern count must be 5 (arena/emit/preamble/stack/parse_diag).
_rt_force_n=$(grep -cE '^src/runtime/rt_[a-z_]+\.o: FORCE' "$MF" 2>/dev/null || true)
if [ "${_rt_force_n:-0}" -lt 5 ]; then
  bad "Makefile expected >=5 src/runtime/rt_*.o FORCE leaves (wave861; got ${_rt_force_n:-0})"
fi
# Any recipe CFLAGS= that still appends -I after \$(CFLAGS) is residual dual bag.
if grep -nE $'^\t[^\n]*CFLAGS="\$\(CFLAGS\)[^\"]*-I' "$MF" 2>/dev/null | head -1 | grep -q .; then
  bad "Makefile recipe CFLAGS= still multi-token appends -I after \$(CFLAGS) (wave861)"
fi
note "B7B rt_* multi-token -I CFLAGS hygiene (leaves 5; wave861; not physical delete)"

# wave862: try-heat CFLAGS/PIPELINE_GEN bulk shell-load via export-try-heat-cflags
if ! grep -qE '^export-try-heat-cflags:' "$MF"; then
  bad "Makefile must define export-try-heat-cflags (wave862)"
fi
_th_cflags_n=$(awk '
  $0 ~ /ensure_host_cc_seed_o\.sh try-heat/ { grab=1 }
  grab {
    body = body $0 "\n"
    if ($0 ~ /try-heat \$\@/) {
      if (body ~ /CFLAGS="\$\(CFLAGS\)"/ || body ~ /PIPELINE_GEN_CFLAGS="\$\(PIPELINE_GEN_CFLAGS\)"/) n++
      body=""; grab=0
    }
  }
  END { print n+0 }
' "$MF")
if [ "${_th_cflags_n:-0}" -ne 0 ]; then
  bad "Makefile try-heat recipes still inject CFLAGS=/PIPELINE_GEN_CFLAGS= (wave862; got ${_th_cflags_n})"
fi
_th_recipe_n=$(grep -cE 'ensure_host_cc_seed_o\.sh try-heat' "$MF" 2>/dev/null || true)
if [ "${_th_recipe_n:-0}" -lt 100 ]; then
  bad "Makefile expected >=100 try-heat thin-call recipes (wave862; got ${_th_recipe_n:-0})"
fi
_ex=$(cd "$COMPILER_DIR" && MAKEFLAGS= make -s export-try-heat-cflags 2>/dev/null || true)
if ! grep -qE '^CFLAGS=' <<<"$_ex"; then
  bad "export-try-heat-cflags must print CFLAGS=... (wave862)"
fi
if ! grep -qE '^PIPELINE_GEN_CFLAGS=' <<<"$_ex"; then
  bad "export-try-heat-cflags must print PIPELINE_GEN_CFLAGS=... (wave862)"
fi
if ! grep -qE -- '-Wall|-I\.' <<<"$_ex"; then
  bad "export-try-heat-cflags must expand product CFLAGS includes (wave862)"
fi
if ! grep -q '_load_try_heat_cflags_via_make\|export-try-heat-cflags' "$COMPILER_DIR/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
  bad "ensure_host_cc_seed_o.sh must shell-load export-try-heat-cflags (wave862)"
fi
note "B7B try-heat CFLAGS bulk shell-load (recipes ${_th_recipe_n}; wave862; not physical delete)"

# wave863: class-G filter CFLAGS/PIPELINE_GEN bulk shell-load hygiene
# G.7: do not hardcode product leaf names here — grep filter ensure context only.
_filt_cflags_hits=$(grep -nE 'filter_bootstrap_seed_(against_partial|pipeline)_o\.sh ensure' -B6 "$MF" 2>/dev/null \
  | grep -E 'CFLAGS="\$\(CFLAGS\)"|PIPELINE_GEN_CFLAGS="\$\(PIPELINE_GEN_CFLAGS\)"' || true)
if [ -n "${_filt_cflags_hits:-}" ]; then
  bad "Makefile filter ensure recipes still inject CFLAGS=/PIPELINE_GEN_CFLAGS= (wave863)"
  echo "$_filt_cflags_hits" | head -5 >&2
fi
_filt_recipe_n=$(grep -cE 'filter_bootstrap_seed_(against_partial|pipeline)_o\.sh ensure' "$MF" 2>/dev/null || true)
if [ "${_filt_recipe_n:-0}" -ne 4 ]; then
  bad "Makefile expected 4 filter ensure thin-call recipes (wave863; got ${_filt_recipe_n:-0})"
fi
if ! grep -q 'wave863' "$COMPILER_DIR/scripts/filter_bootstrap_seed_pipeline_o.sh" 2>/dev/null; then
  bad "filter_bootstrap_seed_pipeline_o.sh must document wave863 (no empty CFLAGS to try-heat)"
fi
if ! grep -q 'wave863' "$COMPILER_DIR/scripts/filter_bootstrap_seed_against_partial_o.sh" 2>/dev/null; then
  bad "filter_bootstrap_seed_against_partial_o.sh must document wave863 (no empty CFLAGS to try-heat)"
fi
# Scripts must not re-inject empty CFLAGS= into try-heat (blocks wave862 shell-load).
if grep -nE 'CFLAGS="\$\{CFLAGS:-\}"|PIPELINE_GEN_CFLAGS="\$\{PIPELINE_GEN_CFLAGS:-\}"' \
  "$COMPILER_DIR/scripts/filter_bootstrap_seed_pipeline_o.sh" \
  "$COMPILER_DIR/scripts/filter_bootstrap_seed_against_partial_o.sh" 2>/dev/null | head -1 | grep -q .; then
  bad "filter scripts still pass empty-default CFLAGS/PIPELINE_GEN to try-heat (wave863)"
fi
note "B7B filter CFLAGS shell-load hygiene (recipes ${_filt_recipe_n}; wave863; not physical delete)"
# wave864: leaf-extra RUNTIME_*/PARSER_* multi-token CFLAGS inject hygiene
# G.7: do not hardcode product .o basenames — grep multi-token env inject patterns only.
_leaf_extra_hits=$(grep -nE 'RUNTIME_PIPELINE_ABI_CFLAGS="\$\(RUNTIME_PIPELINE_ABI_CFLAGS\)"|RUNTIME_DRIVER_NO_C_CFLAGS="\$\(RUNTIME_DRIVER_NO_C_CFLAGS\)"|PARSER_ASM_THIN_GLUE_CFLAGS="\$\(PARSER_ASM_THIN_GLUE_CFLAGS\)"' "$MF" 2>/dev/null || true)
if [ -n "$_leaf_extra_hits" ]; then
  bad "Makefile still injects leaf-extra RUNTIME_*/PARSER_* CFLAGS= (wave864)"
  echo "$_leaf_extra_hits" | head -5 >&2
fi
# Count product try-heat leaves that previously carried these injects (3).
# Authority: ensure shell defaults document wave864; recipes are CC-only for those bags.
if ! grep -q 'wave864' "$COMPILER_DIR/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
  bad "ensure_host_cc_seed_o.sh must document wave864 leaf-extra shell defaults authority"
fi
if ! grep -qE '_DEFAULT_RUNTIME_PIPELINE_ABI_CFLAGS|_DEFAULT_RUNTIME_DRIVER_NO_C_CFLAGS|_DEFAULT_PARSER_ASM_THIN_GLUE_CFLAGS' \
  "$COMPILER_DIR/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
  bad "ensure must keep _DEFAULT_* for pipeline_abi / no_c / thin_glue (wave864)"
fi
note "B7B leaf-extra RUNTIME_*/PARSER_* CFLAGS hygiene (COUNT=3 injects dropped; wave864; not physical delete)"
# wave865: migrate/bootstrap multi-token CFLAGS shell-load via export-try-heat-cflags
# COUNT=8 thin-call recipes (migrate companion + BTC phonies + XXP/BXC shells).
# G.7: do not hardcode product .o basenames — grep recipe CFLAGS inject near shell owners.
_mig_cflags_hits=$(grep -nE 'migrate_x_objs\.sh|bootstrap_typeck_codegen\.sh|xlang_x_pipeline\.sh|bootstrap_x_compiler\.sh' -B3 "$MF" 2>/dev/null \
  | grep -E 'CFLAGS="\$\(CFLAGS\)"' || true)
if [ -n "${_mig_cflags_hits:-}" ]; then
  bad "Makefile migrate/bootstrap shells still inject CFLAGS=\"\$(CFLAGS)\" (wave865)"
  echo "$_mig_cflags_hits" | head -8 >&2
fi
if ! grep -q 'export-try-heat-cflags\|wave865' "$COMPILER_DIR/scripts/migrate_x_objs.sh" 2>/dev/null; then
  bad "migrate_x_objs.sh must shell-load export-try-heat-cflags (wave865)"
fi
if ! grep -q 'wave865' "$COMPILER_DIR/scripts/xlang_x_pipeline.sh" 2>/dev/null; then
  bad "xlang_x_pipeline.sh must document wave865 CFLAGS shell-load"
fi
if ! grep -q 'wave865' "$COMPILER_DIR/scripts/bootstrap_x_compiler.sh" 2>/dev/null; then
  bad "bootstrap_x_compiler.sh must document wave865 CFLAGS shell-load"
fi
if ! grep -q 'wave865' "$COMPILER_DIR/scripts/bootstrap_typeck_codegen.sh" 2>/dev/null; then
  bad "bootstrap_typeck_codegen.sh must document wave865 (no empty CFLAGS to migrate)"
fi
# Honesty COUNT=8: 4 migrate + 2 BTC + 2 XXP/BXC thin-call recipes without CFLAGS inject.
_mig_recipe_n=$(grep -cE $'^\t.*(migrate_x_objs\\.sh|bootstrap_typeck_codegen\\.sh|xlang_x_pipeline\\.sh|bootstrap_x_compiler\\.sh)' "$MF" 2>/dev/null || true)
_mig_recipe_n=${_mig_recipe_n:-0}
if [ "${_mig_recipe_n}" -lt 8 ]; then
  bad "Makefile expected >=8 migrate/bootstrap shell thin-call recipes (wave865; got ${_mig_recipe_n})"
fi
note "B7B migrate/bootstrap CFLAGS shell-load (recipes ${_mig_recipe_n}; COUNT=8 injects dropped; wave865; not physical delete)"
# wave866: build-tool CFLAGS shell-load + WIN32_O_CFLAGS leaf drop (COUNT=2).
# G.7: recipe inject hygiene; shell loads export-try-heat-cflags; WIN32 empty default.
_bt_hits=$(awk '
  $0 ~ /^build-tool:/ {grab=1; next}
  grab && /^[^	#]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE "CFLAGS=['\"]\\$\(CFLAGS\)['\"]" <<<"${_bt_hits:-}"; then
  bad "Makefile build-tool still injects CFLAGS= (wave866)"
  echo "$_bt_hits" | head -4 >&2
fi
if ! grep -q 'export-try-heat-cflags\|wave866' "$COMPILER_DIR/scripts/build_tool.sh" 2>/dev/null; then
  bad "build_tool.sh must shell-load export-try-heat-cflags (wave866)"
fi
_win_hits=$(awk '
  $0 ~ /^src\/asm\/crt0_mingw\.o:/ {grab=1; next}
  grab && /^[^	#]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE 'WIN32_O_CFLAGS=' <<<"${_win_hits:-}"; then
  bad "Makefile crt0_mingw still injects WIN32_O_CFLAGS= (wave866)"
  echo "$_win_hits" | head -4 >&2
fi
note "B7B build-tool/WIN32 CFLAGS hygiene (COUNT=2 injects dropped; wave866; not physical delete)"
# wave867: archaeology host-pick LD_R_MULTIDEF_FLAGS leaf drop (COUNT=4).
# G.7: recipe inject hygiene; shell arch_ld_r_multidef_flags uname default when unset.
_arch_ld_inject=0
for _arch_tgt in net-o-stub net-o-openssl net-o-mbedtls sqlite-o-stub; do
  _arch_hits=$(awk -v t="$_arch_tgt" '
    $0 ~ ("^" t ":") {grab=1; next}
    grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
    grab {print}
  ' "$MF" 2>/dev/null || true)
  if grep -qE 'LD_R_MULTIDEF_FLAGS=' <<<"${_arch_hits:-}"; then
    bad "Makefile $_arch_tgt still injects LD_R_MULTIDEF_FLAGS= (wave867)"
    echo "$_arch_hits" | head -4 >&2
    _arch_ld_inject=$((_arch_ld_inject + 1))
  fi
done
if [ "${_arch_ld_inject}" -ne 0 ]; then
  bad "Makefile archaeology host-pick LD_R inject residual (wave867; count=${_arch_ld_inject})"
fi
if ! grep -q 'arch_ld_r_multidef_flags\|wave867' "$COMPILER_DIR/scripts/archaeology_host_pick_phony.sh" 2>/dev/null; then
  bad "archaeology_host_pick_phony.sh must own arch_ld_r_multidef_flags (wave867)"
fi
if ! bash "$COMPILER_DIR/scripts/archaeology_host_pick_phony.sh" --check >/dev/null 2>&1; then
  bad "archaeology_host_pick_phony.sh --check failed (wave867)"
fi
note "B7B archaeology host-pick LD_R_MULTIDEF hygiene (COUNT=4 injects dropped; wave867; not physical delete)"
# wave868: bootstrap-driver-bstrict-relink shell-primary (COUNT=1).
# G.7: dual Makefile body retired; shell owns prereq gate + XLANG_ASM_* + build_xlang_asm.
_br_sh=compiler/scripts/relink_xlang_asm_bstrict_runtime_objs.sh
if [ ! -f "$_br_sh" ]; then
  bad "missing $_br_sh (wave868)"
fi
if ! grep -q 'relink_xlang_asm_bstrict_runtime_objs\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call relink_xlang_asm_bstrict_runtime_objs.sh (wave868)"
fi
_br_hits=$(awk '
  /^bootstrap-driver-bstrict-relink:/ {grab=1; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE 'XLANG_ASM_BSTRICT_RELINK_ONLY|XLANG_ASM_EXPERIMENTAL_SKIP_GEN|build_xlang_asm\.sh' <<<"${_br_hits:-}"; then
  bad "Makefile bootstrap-driver-bstrict-relink still has dual XLANG_ASM_*/build_xlang_asm body (wave868)"
  echo "$_br_hits" | head -8 >&2
fi
if grep -qE 'build_asm/pipeline\.o|need prior bootstrap' <<<"${_br_hits:-}"; then
  bad "Makefile bootstrap-driver-bstrict-relink still has dual build_asm prereq gate (wave868)"
  echo "$_br_hits" | head -8 >&2
fi
if ! bash "$_br_sh" --check >/dev/null 2>&1; then
  bad "relink_xlang_asm_bstrict_runtime_objs.sh --check failed (wave868)"
fi
note "B7C bootstrap-driver-bstrict-relink shell-primary (COUNT=1; wave868; not physical delete)"
# wave869: bootstrap-driver-crt0 shell-primary (COUNT=1).
# G.7: dual Makefile body retired; shell owns build_xlang_asm + crt0 log gates.
_crt0_sh=compiler/scripts/bootstrap_driver_crt0.sh
if [ ! -f "$_crt0_sh" ]; then
  bad "missing $_crt0_sh (wave869)"
fi
if ! grep -q 'bootstrap_driver_crt0\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call bootstrap_driver_crt0.sh (wave869)"
fi
_crt0_hits=$(awk '
  /^bootstrap-driver-crt0:/ {grab=1; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE 'build_xlang_asm\.sh' <<<"${_crt0_hits:-}"; then
  bad "Makefile bootstrap-driver-crt0 still has dual build_xlang_asm body (wave869)"
  echo "$_crt0_hits" | head -8 >&2
fi
if grep -qE 'build_xlang_crt0\.log|Target-B-partial|LINK_MODE=crt0|pipeline_gen\.c' <<<"${_crt0_hits:-}"; then
  bad "Makefile bootstrap-driver-crt0 still has dual crt0 log gates (wave869)"
  echo "$_crt0_hits" | head -8 >&2
fi
if ! bash "$_crt0_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_driver_crt0.sh --check failed (wave869)"
fi
note "B7C bootstrap-driver-crt0 shell-primary (COUNT=1; wave869; not physical delete)"
# wave870: check-7.2 shell-primary (COUNT=1).
# G.7: dual Makefile body retired; shell owns seed stage1/stage2 smoke suite.
_c72_sh=compiler/scripts/check_7_2.sh
if [ ! -f "$_c72_sh" ]; then
  bad "missing $_c72_sh (wave870)"
fi
if ! grep -q 'check_7_2\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call check_7_2.sh (wave870)"
fi
_c72_hits=$(awk '
  /^check-7\.2:/ {grab=1; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE 'run-return-value\.sh|run-hello\.sh|run-lexer\.sh|run-typeck\.sh|run-bootstrap-semantic-smoke|run-bootstrap-stage2-dogfood' <<<"${_c72_hits:-}"; then
  bad "Makefile check-7.2 still has dual inline smoke suite (wave870)"
  echo "$_c72_hits" | head -8 >&2
fi
if grep -qE '_stage1|_stage2|check-7\.2 FAIL|check-7\.2 OK' <<<"${_c72_hits:-}"; then
  bad "Makefile check-7.2 still has dual stage loop / OK lines (wave870)"
  echo "$_c72_hits" | head -8 >&2
fi
if ! bash "$_c72_sh" --check >/dev/null 2>&1; then
  bad "check_7_2.sh --check failed (wave870)"
fi
note "B7C check-7.2 shell-primary (COUNT=1; wave870; not physical delete)"
# wave871: check-6.4 shell-primary (COUNT=1).
# G.7: dual Makefile body retired; shell owns seed emit-C + host-cc + exit 42.
_c64_sh=compiler/scripts/check_6_4.sh
if [ ! -f "$_c64_sh" ]; then
  bad "missing $_c64_sh (wave871)"
fi
if ! grep -q 'check_6_4\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call check_6_4.sh (wave871)"
fi
_c64_hits=$(awk '
  /^check-6\.4:/ {grab=1; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE 'bootstrap-driver-seed|return-value/main\.x|/tmp/check64|check-6\.4 OK' <<<"${_c64_hits:-}"; then
  bad "Makefile check-6.4 still has dual inline smoke body (wave871)"
  echo "$_c64_hits" | head -8 >&2
fi
if ! bash "$_c64_sh" --check >/dev/null 2>&1; then
  bad "check_6_4.sh --check failed (wave871)"
fi
note "B7C check-6.4 shell-primary (COUNT=1; wave871; not physical delete)"
# wave872: bootstrap-driver-hybrid shell-primary (COUNT=1).
# G.7: dual Makefile body retired; shell owns B-hybrid build_xlang_asm + replace/soft-skip.
_hy_sh=compiler/scripts/bootstrap_driver_hybrid.sh
if [ ! -f "$_hy_sh" ]; then
  bad "missing $_hy_sh (wave872)"
fi
if ! grep -q 'bootstrap_driver_hybrid\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call bootstrap_driver_hybrid.sh (wave872)"
fi
_hy_hits=$(awk '
  /^bootstrap-driver-hybrid / {grab=1; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE 'build_xlang_asm\.sh' <<<"${_hy_hits:-}"; then
  bad "Makefile bootstrap-driver-hybrid still has dual build_xlang_asm body (wave872)"
  echo "$_hy_hits" | head -8 >&2
fi
if grep -qE 'cp -f xlang_asm|bootstrap-driver-hybrid OK|asm build skipped' <<<"${_hy_hits:-}"; then
  bad "Makefile bootstrap-driver-hybrid still has dual replace/soft-skip body (wave872)"
  echo "$_hy_hits" | head -8 >&2
fi
if ! bash "$_hy_sh" --check >/dev/null 2>&1; then
  bad "bootstrap_driver_hybrid.sh --check failed (wave872)"
fi
note "B7C bootstrap-driver-hybrid shell-primary (COUNT=1; wave872; not physical delete)"
# wave873: regen-lsp-gens-x shell-primary (COUNT=1).
# G.7: dual Makefile body retired; shell owns gate + rm four gens + make file targets.
_rl_sh=compiler/scripts/regen_lsp_gens_x.sh
if [ ! -f "$_rl_sh" ]; then
  bad "missing $_rl_sh (wave873)"
fi
if ! grep -q 'regen_lsp_gens_x\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call regen_lsp_gens_x.sh (wave873)"
fi
_rl_hits=$(awk '
  /^regen-lsp-gens-x:/ {grab=1; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE 'lsp_io_gen\.c|lsp_diag_gen\.c|lsp_io_std_heap_gen\.c' <<<"${_rl_hits:-}"; then
  bad "Makefile regen-lsp-gens-x still has dual gen file list body (wave873)"
  echo "$_rl_hits" | head -8 >&2
fi
if grep -qE 'rm -f|regen-lsp-gens-x OK|请先 make' <<<"${_rl_hits:-}"; then
  bad "Makefile regen-lsp-gens-x still has dual rm/gate/OK body (wave873)"
  echo "$_rl_hits" | head -8 >&2
fi
if ! bash "$_rl_sh" --check >/dev/null 2>&1; then
  bad "regen_lsp_gens_x.sh --check failed (wave873)"
fi
note "B7C regen-lsp-gens-x shell-primary (COUNT=1; wave873; not physical delete)"
# wave874: build-via-tool shell-primary (COUNT=1).
# G.7: dual Makefile body + xlang-build run_build_tool retired; shell owns invoke + OK.
_bvt_sh=compiler/scripts/build_via_tool.sh
if [ ! -f "$_bvt_sh" ]; then
  bad "missing $_bvt_sh (wave874)"
fi
if ! grep -q 'build_via_tool\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call build_via_tool.sh (wave874)"
fi
_bvt_hits=$(awk '
  /^build-via-tool:/ {grab=1; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  grab {print}
' "$MF" 2>/dev/null || true)
if grep -qE '\./build_tool|build_tool \./' <<<"${_bvt_hits:-}"; then
  bad "Makefile build-via-tool still has dual ./build_tool body (wave874)"
  echo "$_bvt_hits" | head -8 >&2
fi
if grep -qE 'build-via-tool OK' <<<"${_bvt_hits:-}"; then
  bad "Makefile build-via-tool still has dual OK body (wave874)"
  echo "$_bvt_hits" | head -8 >&2
fi
# xlang-build must not keep dual ./build_tool product invoke (shell owns).
if [ -f xlang-build.sh ]; then
  if grep -nE '^\s*\(cd compiler && \./build_tool' xlang-build.sh 2>/dev/null | grep -qv build_via_tool; then
    bad "xlang-build.sh still has dual ./build_tool product invoke (wave874; use build_via_tool.sh)"
  fi
  if ! grep -q 'build_via_tool\.sh' xlang-build.sh 2>/dev/null; then
    bad "xlang-build.sh must call build_via_tool.sh (wave874 G.7)"
  fi
fi
if ! bash "$_bvt_sh" --check >/dev/null 2>&1; then
  bad "build_via_tool.sh --check failed (wave874)"
fi
note "B7C build-via-tool shell-primary (COUNT=1; wave874; not physical delete)"
# wave875: size-baseline + perf-baseline shell-primary (COUNT=2).
# G.7: dual Makefile if/chmod/XLANG wrappers retired; shell owns dispatch;
# measurement authority stays tests/run-{size,perf}-baseline.sh.
_s8_sh=compiler/scripts/stage8_baseline.sh
if [ ! -f "$_s8_sh" ]; then
  bad "missing $_s8_sh (wave875)"
fi
if ! grep -q 'stage8_baseline\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call stage8_baseline.sh (wave875)"
fi
for _ph in size-baseline perf-baseline; do
  # Recipe lines only (tab-indented). Comment notes may mention
  # tests/run-*-baseline as measurement authority and must not false-positive.
  _hits=$(awk -v t="$_ph" '
    $0 ~ ("^" t ":") {grab=1; next}
    grab && /^\t/ {print; next}
    grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
  ' "$MF" 2>/dev/null || true)
  if grep -qE 'run-size-baseline|run-perf-baseline|chmod \+x tests/' <<<"${_hits:-}"; then
    bad "Makefile $_ph still has dual tests/run-*-baseline body (wave875)"
    echo "$_hits" | head -8 >&2
  fi
  if grep -qE 'if \[ -f \.\./tests/' <<<"${_hits:-}"; then
    bad "Makefile $_ph still has dual if-file gate body (wave875)"
    echo "$_hits" | head -8 >&2
  fi
  if ! grep -q 'stage8_baseline\.sh' <<<"${_hits:-}"; then
    bad "Makefile $_ph must thin-call stage8_baseline.sh (wave875)"
  fi
done
if ! bash "$_s8_sh" --check >/dev/null 2>&1; then
  bad "stage8_baseline.sh --check failed (wave875)"
fi
note "B7C size/perf-baseline shell-primary (COUNT=2; wave875; not physical delete)"
# wave876: default $(XLANG_C) product alias shell-primary (COUNT=1).
# G.7: dual Makefile if/cp SKIP_SUBSCRIPT retired; shell owns soft-skip + cp;
# LEGACY host-cc remains legacy_xlang_c_link.sh (wave858).
_xc_sh=compiler/scripts/ensure_xlang_c.sh
if [ ! -f "$_xc_sh" ]; then
  bad "missing $_xc_sh (wave876)"
fi
if ! grep -q 'ensure_xlang_c\.sh' "$MF" 2>/dev/null; then
  bad "Makefile must thin-call ensure_xlang_c.sh (wave876)"
fi
# Recipe lines only under $(XLANG_C): (default non-LEGACY path).
_xc_hits=$(awk '
  /^\$\(XLANG_C\):/ {grab=1; next}
  grab && /^\t/ {print; next}
  grab && /^[^#\t]/ && $0 !~ /^$/ {exit}
' "$MF" 2>/dev/null || true)
if grep -qE 'cp -f bootstrap_xlangc|XLANG_SKIP_SUBSCRIPT_MAKE|if \[ -z ' <<<"${_xc_hits:-}"; then
  bad "Makefile \$(XLANG_C) still has dual if/cp SKIP_SUBSCRIPT body (wave876)"
  echo "$_xc_hits" | head -8 >&2
fi
if ! grep -q 'ensure_xlang_c\.sh' <<<"${_xc_hits:-}"; then
  bad "Makefile \$(XLANG_C) must thin-call ensure_xlang_c.sh (wave876)"
fi
if ! bash "$_xc_sh" --check >/dev/null 2>&1; then
  bad "ensure_xlang_c.sh --check failed (wave876)"
fi
note "B7C default xlang-c alias shell-primary (COUNT=1; wave876; not physical delete)"
# wave877: gen/lsp/archaeology ensure multi-token MAKE/XLANG_*/FORCE/TIMEOUT inject hygiene.
# COUNT=20 thin-call recipes; shell defaults own env (ensure_*_gen / ensure_ast_gen2).
# G.7: grep multi-token inject on ensure gen recipe lines only — not comments.
_gen_env_hits=$(awk '
  /scripts\/ensure_(migrate_gen|lsp_pipeline_gen|archaeology_gen|driver_gen|ast_gen2)\.sh/ {grab=1}
  grab && /^\t/ {
    if ($0 ~ /MAKE="\$\(MAKE\)"|XLANG_C="\$\(XLANG_C\)"|XLANG_X="\$\(XLANG_X\)"|XLANG_FORCE_REGEN_GEN="\$\(XLANG_FORCE_REGEN_GEN\)"|XLANG_PARSER_GEN_TIMEOUT="\$\(|XLANG_DRIVER_GEN_TIMEOUT="\$\(/) print
    if ($0 !~ /\\$/) grab=0
    next
  }
  grab && /^[^#\t]/ && $0 !~ /^$/ {grab=0}
' "$MF" 2>/dev/null || true)
if [ -n "${_gen_env_hits:-}" ]; then
  bad "Makefile ensure_*_gen recipes still multi-token inject MAKE/XLANG_*/FORCE/TIMEOUT (wave877)"
  echo "$_gen_env_hits" | head -10 >&2
fi
_gen_thin_n=$(grep -cE '^\t@bash scripts/ensure_(migrate_gen|lsp_pipeline_gen|archaeology_gen|driver_gen|ast_gen2)\.sh' "$MF" 2>/dev/null || echo 0)
if [ "${_gen_thin_n:-0}" -lt 19 ]; then
  bad "Makefile ensure_*_gen thin @bash count expected >=19 got ${_gen_thin_n} (wave877)"
fi
if ! grep -q 'wave877' "$MF" 2>/dev/null; then
  bad "Makefile must document wave877 gen ensure env hygiene"
fi
note "B7B gen ensure multi-token env inject hygiene (COUNT=20; wave877; not physical delete)"
# wave878: migrate_x_objs multi-token CC/PYTHON/MAKE inject hygiene.
# COUNT=4 thin-call recipes; shell defaults own CC/PYTHON/MAKE (migrate_x_objs).
# G.7: grep multi-token inject on migrate_x_objs recipe lines only — not comments.
_mig_env_hits=$(awk '
  /scripts\/migrate_x_objs\.sh/ {grab=1}
  grab && /^\t/ {
    if ($0 ~ /CC="\$\(CC\)"|PYTHON="\$\(PYTHON\)"|MAKE="\$\(MAKE\)"/) print
    if ($0 !~ /\\$/) grab=0
    next
  }
  grab && /^[^#\t]/ && $0 !~ /^$/ {grab=0}
' "$MF" 2>/dev/null || true)
if [ -n "${_mig_env_hits:-}" ]; then
  bad "Makefile migrate_x_objs recipes still multi-token inject CC/PYTHON/MAKE (wave878)"
  echo "$_mig_env_hits" | head -10 >&2
fi
_mig_thin_n=$(grep -cE $'^\t@sh scripts/migrate_x_objs\\.sh' "$MF" 2>/dev/null || echo 0)
if [ "${_mig_thin_n:-0}" -lt 4 ]; then
  bad "Makefile migrate_x_objs thin @sh count expected >=4 got ${_mig_thin_n} (wave878)"
fi
if ! grep -q 'wave878' "$MF" 2>/dev/null; then
  bad "Makefile must document wave878 migrate env hygiene"
fi
if ! grep -q 'wave878' "$COMPILER_DIR/scripts/migrate_x_objs.sh" 2>/dev/null; then
  bad "migrate_x_objs.sh must document wave878 CC/PYTHON/MAKE defaults hygiene"
fi
note "B7B migrate multi-token env inject hygiene (COUNT=4; wave878; not physical delete)"
# wave879: stage/bootstrap multi-token TARGET/CC/MAKE inject hygiene.
# COUNT=13 thin-call recipes; shell defaults own TARGET/CC/MAKE/XLANG_*/PYTHON.
# G.7: grep multi-token inject on wave879 shell recipe lines only — not comments.
# Scripts: clean_compiler, bootstrap_typeck_codegen, bootstrap_driver_seed_link final,
# bootstrap_driver_seed, relink_xlang_lexer, regen_lsp_gens_x, xlang_x, check_6_4,
# build_tool, bootstrap_self, xlang_x_pipeline, bootstrap_x_compiler.
_stage_env_hits=$(awk '
  /scripts\/(clean_compiler|bootstrap_typeck_codegen|relink_xlang_lexer|regen_lsp_gens_x|check_6_4|build_tool|bootstrap_self|xlang_x_pipeline|bootstrap_x_compiler)\.sh/ {grab=1}
  /scripts\/xlang_x\.sh/ {grab=1}
  /scripts\/bootstrap_driver_seed\.sh/ {grab=1}
  /scripts\/bootstrap_driver_seed_link\.sh final/ {grab=1}
  grab && /^\t/ {
    if ($0 ~ /TARGET="\$\(TARGET\)"|TARGET='\''\$\(TARGET\)'\''|CC="\$\(CC\)"|CC='\''\$\(CC\)'\''|MAKE="\$\(MAKE\)"|XLANG_C="\$\(XLANG_C\)"|XLANG_X="\$\(XLANG_X\)"|PYTHON="\$\(PYTHON\)"|BOOTSTRAP_XLANGC=|XLANG_BUILD_TOOL_REGEN=|XLANG_SKIP_SEED_SMOKE=/) print
    if ($0 !~ /\\$/) grab=0
    next
  }
  grab && /^[^#\t]/ && $0 !~ /^$/ {grab=0}
' "$MF" 2>/dev/null || true)
if [ -n "${_stage_env_hits:-}" ]; then
  bad "Makefile stage/bootstrap recipes still multi-token inject TARGET/CC/MAKE (wave879)"
  echo "$_stage_env_hits" | head -15 >&2
fi
# thin pure @bash/@sh for the 12 bash/sh shells + 1 final-link (./scripts)
_stage_thin_n=$(grep -cE $'^\t@(bash|sh) scripts/(clean_compiler|bootstrap_typeck_codegen|relink_xlang_lexer|regen_lsp_gens_x|xlang_x|check_6_4|build_tool|bootstrap_self|xlang_x_pipeline|bootstrap_x_compiler)\\.sh' "$MF" 2>/dev/null || echo 0)
# typeck+codegen share bootstrap_typeck_codegen → 2; clean 1; others 1 each = 11 from this pattern
# xlang_x.sh matches xlang_x but not xlang_x_pipeline if ordered carefully — check:
# pattern xlang_x\\.sh matches only xlang_x.sh; xlang_x_pipeline is separate. Good.
# Expected: clean + typeck + codegen + relink + regen + xlang_x + check64 + build_tool + self + pipeline + xcompiler = 11
if [ "${_stage_thin_n:-0}" -lt 11 ]; then
  bad "Makefile stage/bootstrap thin @bash/@sh count expected >=11 got ${_stage_thin_n} (wave879)"
fi
if ! grep -qE $'^\t@\\./scripts/bootstrap_driver_seed_link\\.sh final' "$MF" 2>/dev/null; then
  bad "Makefile bootstrap-driver-seed-final-link must thin-call ./scripts/... final (wave879)"
fi
if ! grep -qE $'^\t@\\./scripts/bootstrap_driver_seed\\.sh' "$MF" 2>/dev/null; then
  bad "Makefile bootstrap-driver-seed must thin-call ./scripts/bootstrap_driver_seed.sh (wave879)"
fi
if ! grep -q 'wave879' "$MF" 2>/dev/null; then
  bad "Makefile must document wave879 stage/bootstrap env hygiene"
fi
note "B7B stage/bootstrap multi-token env inject hygiene (COUNT=13; wave879; not physical delete)"
# wave880: ENSURE=0 / OUT=$@ / all OPT multi-token inject hygiene.
# COUNT=7 thin-call recipes; MAKELEVEL shell defaults own ENSURE/OPT; OUT defaults.
# G.7: grep multi-token inject on wave880 shell recipe lines only — not comments.
# Scripts: compiler_all_ci, run_compiler_tests, bootstrap_driver_seed_x_frontend,
# legacy_xlang_c_link, xlang_no_c_frontend, bootstrap_verify_bstrict.
_ensure_out_opt_hits=$(awk '
  /scripts\/(compiler_all_ci|run_compiler_tests|bootstrap_driver_seed_x_frontend|legacy_xlang_c_link|xlang_no_c_frontend|bootstrap_verify_bstrict)\.sh/ {grab=1}
  grab && /^\t/ {
    if ($0 ~ /OPT="\$\(OPT\)"|MAKE="\$\(MAKE\)"|TARGET="\$\(TARGET\)"|TARGET='\''\$\(TARGET\)'\''|XLANG_C="\$\(XLANG_C\)"|XLANG_C='\''\$\(XLANG_C\)'\''|CC="\$\(CC\)"|OUT="|XLANG_TEST_ENSURE=|XLANG_VERIFY_ENSURE_BSTRICT=|XLANG_RUN_ALL_BOOTSTRAP_XLANG=|XLANG_SKIP_SUBSCRIPT_MAKE=/) print
    if ($0 !~ /\\$/) grab=0
    next
  }
  grab && /^[^#\t]/ && $0 !~ /^$/ {grab=0}
' "$MF" 2>/dev/null || true)
if [ -n "${_ensure_out_opt_hits:-}" ]; then
  bad "Makefile ENSURE/OUT/all OPT recipes still multi-token inject (wave880)"
  echo "$_ensure_out_opt_hits" | head -15 >&2
fi
# thin pure @bash/@sh for the 7 wave880 shells
# all + seed-x-frontend + legacy + xnc = 4 bash; test_c + test_x + check-7.2-bstrict = 3 sh
_eoo_bash_n=$(grep -cE $'^\t@bash scripts/(compiler_all_ci|bootstrap_driver_seed_x_frontend|legacy_xlang_c_link|xlang_no_c_frontend)\\.sh' "$MF" 2>/dev/null || echo 0)
_eoo_sh_n=$(grep -cE $'^\t@sh scripts/(run_compiler_tests|bootstrap_verify_bstrict)\\.sh' "$MF" 2>/dev/null || echo 0)
# run_compiler_tests appears twice (c + x) → sh count >= 3; bash >= 3 (legacy is under ifeq)
# legacy may be present once under ifeq; count bash targets that always expand: all, seed-x-frontend, xnc = 3
if [ "${_eoo_bash_n:-0}" -lt 3 ]; then
  bad "Makefile wave880 thin @bash count expected >=3 got ${_eoo_bash_n} (wave880)"
fi
if [ "${_eoo_sh_n:-0}" -lt 3 ]; then
  bad "Makefile wave880 thin @sh count expected >=3 got ${_eoo_sh_n} (wave880)"
fi
if ! grep -q 'wave880' "$MF" 2>/dev/null; then
  bad "Makefile must document wave880 ENSURE/OUT/OPT env hygiene"
fi
# Shell bodies must document MAKELEVEL default policy
if ! grep -q 'MAKELEVEL' "$COMPILER_DIR/scripts/run_compiler_tests.sh" 2>/dev/null; then
  bad "run_compiler_tests.sh must use MAKELEVEL for ENSURE default (wave880)"
fi
if ! grep -q 'MAKELEVEL' "$COMPILER_DIR/scripts/bootstrap_verify_bstrict.sh" 2>/dev/null; then
  bad "bootstrap_verify_bstrict.sh must use MAKELEVEL for ENSURE default (wave880)"
fi
if ! grep -q 'MAKELEVEL' "$COMPILER_DIR/scripts/compiler_all_ci.sh" 2>/dev/null; then
  bad "compiler_all_ci.sh must use MAKELEVEL for OPT default (wave880)"
fi
if ! grep -q 'wave880' "$COMPILER_DIR/scripts/run_compiler_tests.sh" 2>/dev/null; then
  bad "run_compiler_tests.sh must document wave880"
fi
note "B7B ENSURE=0 / OUT=\$@ / all OPT inject hygiene (COUNT=7; wave880; not physical delete)"
# wave881: try-heat XLANG_G05_PREFER_X_O (+ net XLANG=) inject hygiene.
# COUNT=31: drop PREFER/XLANG recipe inject; leave CC="$(CC)" only (wave862 shape).
# G.7: no dual prefer authority — shell env/CLI + defaults; make CLI auto-exports.
if grep -qE 'XLANG_G05_PREFER_X_O="\$\(XLANG_G05_PREFER_X_O\)"' "$MF" 2>/dev/null; then
  bad "Makefile still injects XLANG_G05_PREFER_X_O on recipes (wave881)"
  grep -nE 'XLANG_G05_PREFER_X_O="\$\(XLANG_G05_PREFER_X_O\)"' "$MF" | head -10 >&2
fi
# try-heat blocks must not inject XLANG= (net residual) alongside CC=
_prefer_xlang_hits=$(awk '
  /ensure_host_cc_seed_o\.sh try-heat/ {grab=1}
  grab && /^\t/ {
    if ($0 ~ /XLANG="\$\(XLANG\)"|XLANG_G05_PREFER_X_O=/) print
    if ($0 !~ /\\$/) grab=0
    next
  }
  grab && /^[^#\t]/ && $0 !~ /^$/ {grab=0}
' "$MF" 2>/dev/null || true)
if [ -n "${_prefer_xlang_hits:-}" ]; then
  bad "Makefile try-heat still injects PREFER/XLANG (wave881)"
  echo "$_prefer_xlang_hits" | head -15 >&2
fi
if ! grep -q 'wave881' "$MF" 2>/dev/null; then
  bad "Makefile must document wave881 PREFER inject hygiene"
fi
if ! grep -q 'wave881' "$COMPILER_DIR/scripts/ensure_host_cc_seed_o.sh" 2>/dev/null; then
  bad "ensure_host_cc_seed_o.sh must document wave881 PREFER inject hygiene"
fi
# dump honesty
if ! grep -q 'PHYS_DEL_B7B_PREFER_INJECT_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_PREFER_INJECT_HYGIENE=1 (wave881)"
fi
if ! grep -q 'PHYS_DEL_B7B_PREFER_INJECT_HYGIENE_COUNT=31' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_PREFER_INJECT_HYGIENE_COUNT=31 (wave881)"
fi
note "B7B try-heat PREFER_X_O inject hygiene (COUNT=31; wave881; not physical delete)"
# wave882: residual single-token TARGET= inject hygiene.
# COUNT=10: drop TARGET= recipe inject; shell TARGET:-xlang + make CLI auto-export.
# G.7: no dual TARGET authority — shell defaults own product path.
if grep -qE '@TARGET=|TARGET="\$\(TARGET\)"|TARGET='\''\$\(TARGET\)'\' "$MF" 2>/dev/null; then
  bad "Makefile still injects TARGET= on recipes (wave882)"
  grep -nE '@TARGET=|TARGET="\$\(TARGET\)"|TARGET='\''\$\(TARGET\)'\' "$MF" | head -15 >&2
fi
if ! grep -q 'wave882' "$MF" 2>/dev/null; then
  bad "Makefile must document wave882 TARGET inject hygiene"
fi
# dump honesty
if ! grep -q 'PHYS_DEL_B7B_TARGET_INJECT_HYGIENE=1' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_TARGET_INJECT_HYGIENE=1 (wave882)"
fi
if ! grep -q 'PHYS_DEL_B7B_TARGET_INJECT_HYGIENE_COUNT=10' <<<"$_out"; then
  bad "dump must set PHYS_DEL_B7B_TARGET_INJECT_HYGIENE_COUNT=10 (wave882)"
fi
note "B7B residual TARGET= inject hygiene (COUNT=10; wave882; not physical delete)"
# Cross-check swallowed bodies still true for preflight readiness.
for _k in \
  PHYS_DEL_BUCKET_B1_BODY_SWALLOWED=1 \
  PHYS_DEL_BUCKET_B2_BODY_SWALLOWED=1 \
  PHYS_DEL_BUCKET_B3_BODY_SWALLOWED=1 \
  PHYS_DEL_BUCKET_B4_BODY_SWALLOWED=1 \
  PHYS_DEL_BUCKET_B5_BODY_SWALLOWED=1 \
  PHYS_DEL_BUCKET_B6_BODY_SWALLOWED=1 \
  PHYS_DEL_BUCKET_B7D_BODY_SWALLOWED=1 \
  PHYS_DEL_BUCKET_B7A_HEAT_RESIDUAL=0 \
  PHYS_DEL_BUCKET_B7A_COLD_0MAKE=1 \
  PHYS_DEL_BUCKET_B7B_SHELL_CATALOG=1
do
  if ! grep -q "$_k" <<<"$_out"; then
    bad "wave798 preflight readiness missing $_k"
  fi
done
note "residual class inventory dump OK (wave747–798 + B7A heat dep-thin closed + preflight + thin-unify + try-heat + B7B shell catalog + Windows + dual-end)"
# wave789/790: ensure try-heat wired (G.7 single body; no dual heat dispatcher)
if [ ! -f "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh" ]; then
  bad "missing ensure_host_cc_seed_o.sh (wave789 heat owner)"
elif ! grep -q 'try_heat_one\|try-heat' "$ROOT/compiler/scripts/ensure_host_cc_seed_o.sh"; then
  bad "ensure_host_cc_seed_o.sh missing try-heat (wave789)"
else
  note "ensure try-heat present (wave789 B7A heat shell dispatch)"
fi
# wave790: Makefile heat recipes are try-heat only (historical modes remain in comments)
# wave791–795: FORCE + ensure script (source prereqs removed for 86 leaves)
# wave798: dual-end count portability —
#   PLATFORM: SHARED — GNU grep ERE does NOT treat `\t` as TAB (mac BSD often does).
#   Always use $'\t' for real tab. Never `grep -c … || echo 0` (no-match prints 0
#   and exits 1 → "0\n0" breaks `[ n -lt … ]` integer tests on Ubuntu).
if [ -f "$MF" ]; then
  _heat_recipe_n=$(grep -cE $'^\t.*ensure_host_cc_seed_o\.sh try-heat' "$MF" 2>/dev/null || true)
  _heat_recipe_n=${_heat_recipe_n:-0}
  _heat_non_try=$(grep -E $'^\t.*ensure_host_cc_seed_o\.sh ' "$MF" 2>/dev/null | grep -vc 'try-heat' || true)
  _heat_non_try=${_heat_non_try:-0}
  if [ "${_heat_recipe_n}" -lt 50 ]; then
    bad "Makefile must thin-call try-heat for ensure recipes (wave790; n=${_heat_recipe_n})"
  else
    note "Makefile heat recipes try-heat unify (n=${_heat_recipe_n}; wave790)"
  fi
  if [ "${_heat_non_try}" -ne 0 ]; then
    bad "Makefile ensure recipes must not call non-try-heat modes (wave790; n=${_heat_non_try})"
  else
    note "Makefile ensure recipe modes collapsed to try-heat (wave790)"
  fi
  _force_n=$(grep -cE '^[A-Za-z0-9_./$()].*: FORCE scripts/ensure_host_cc_seed_o\.sh' "$MF" 2>/dev/null || true)
  _force_n=${_force_n:-0}
  if [ "${_force_n}" -lt 113 ]; then
    bad "Makefile wave797 FORCE dep-thin leaves expected >=113 (n=${_force_n})"
  else
    note "Makefile heat dep-edge FORCE thin (n=${_force_n}; wave797)"
  fi
  # wave797: orch last heat source-prereq leaf must be FORCE thin (no pipeline_gen prereq edge).
  # G.7: do not quote product *.o paths in bad messages (self inventory ban).
  # Note: awk exit in action still runs END — use a flag, not exit 0 + END exit 1.
  if ! awk '
    /^pipeline_bootstrap_orchestration\.o:/ {
      line=$0
      if (line ~ /FORCE/ && line !~ /pipeline_gen\.c/) ok=1
    }
    END { exit(ok ? 0 : 1) }
  ' "$MF"; then
    bad "Makefile orch residual must FORCE thin without pipeline_gen prereq (wave797)"
  else
    note "Makefile orch leaf FORCE thin (wave797)"
  fi
  # archaeology: mode names still documented in comments for residual greps
  if ! grep -q 'try-labi-prefer' "$MF" || ! grep -q 'try-r3-prefer' "$MF"; then
    bad "Makefile must keep historical try-* mode names in comments (wave790 archaeology)"
  else
    note "Makefile comment archaeology retains try-* mode names (wave790)"
  fi
fi

# Makefile still present (residual reality) + has host-cc heat
if [ ! -f "$MF" ]; then
  bad "missing $MF (unexpected early delete; 11.3.1 not closed)"
else
  if ! grep -qE '\$\(CC\).*-c' "$MF"; then
    note "Makefile has 0 \$(CC) -c residual lines (heat cleared? keep inventory)"
  else
    note "Makefile still has host-cc -c residual (expected until 11.3.1)"
  fi
  if ! grep -q 'UNAME_' "$MF"; then
    bad "Makefile missing UNAME_ (R2 residual signal)"
  else
    note "Makefile UNAME residual signal present (R2)"
  fi
fi

# Swallowed owners must still exist (orchestration authority)
for f in \
  compiler/scripts/bootstrap_driver_seed.sh \
  compiler/scripts/driver_seed_ensure_prereqs.sh \
  compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh \
  compiler/scripts/driver_seed_obj_catalog.sh \
  compiler/scripts/bootstrap_driver_seed_link.sh \
  compiler/scripts/host_platform_linker.sh \
  compiler/scripts/ensure_host_cc_seed_o.sh \
  compiler/scripts/compiler_all_ci.sh
do
  if [ ! -f "$f" ]; then
    bad "missing swallowed/orchestration owner $f"
  fi
done
note "swallowed orchestration owners present"

# wave784: B6 R5 CI body live checks (xbuild + Makefile thin + script --check)
if ! grep -q 'compiler_all_ci\.sh' "$XBUILD_REL"; then
  bad "xlang-build.sh must wire compiler-all → compiler_all_ci.sh (wave784)"
else
  note "xbuild compiler-all → compiler_all_ci.sh (wave784)"
fi
if [ -f "$MF" ]; then
  if ! grep -q 'compiler_all_ci\.sh' "$MF"; then
    bad "Makefile all must thin-call compiler_all_ci.sh (wave784)"
  else
    note "Makefile all thin-calls compiler_all_ci.sh (wave784)"
  fi
fi
# Temp names avoid bare ".o" substrings (G.7 inventory forbids hardcoded .o paths in this script).
if ! bash compiler/scripts/compiler_all_ci.sh --check \
  >/tmp/compiler_all_ci_check.log 2>/tmp/compiler_all_ci_check_err.log; then
  bad "compiler_all_ci.sh --check failed (wave784)"
  head -20 /tmp/compiler_all_ci_check_err.log >&2 || true
else
  note "compiler_all_ci.sh --check OK (wave784)"
fi

# wave785 + wave841 B7c: bootstrap-typeck/codegen shell-primary via bootstrap_typeck_codegen.sh
# (gen=ensure_migrate_gen FORCE_REGEN; migrate inside shell; no dual Makefile -E / $(CC) -c gen)
# (message strings avoid product path tokens that trip G.7 self hardcode scan)
if [ -f "$MF" ]; then
  if ! grep -A8 '^bootstrap-typeck:' "$MF" | grep -q 'bootstrap_typeck_codegen\.sh'; then
    bad "bootstrap-typeck must thin-call bootstrap_typeck_codegen.sh (wave841 B7c shell-primary)"
  else
    note "bootstrap-typeck → bootstrap_typeck_codegen.sh (wave841)"
  fi
  if ! grep -A8 '^bootstrap-codegen:' "$MF" | grep -q 'bootstrap_typeck_codegen\.sh'; then
    bad "bootstrap-codegen must thin-call bootstrap_typeck_codegen.sh (wave841 B7c shell-primary)"
  else
    note "bootstrap-codegen → bootstrap_typeck_codegen.sh (wave841)"
  fi
  # Recipe-only scan (tab lines): comments between phonies may mention $(CC) -c
  _btc_typeck_rec=$(awk '/^bootstrap-typeck:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  _btc_codegen_rec=$(awk '/^bootstrap-codegen:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE '\$\(CC\).*-c .*(typeck_gen|codegen_gen)|XLANG_C\).*-E-extern' <<<"$_btc_typeck_rec"; then
    bad "bootstrap-typeck must not keep dual gen -E / \$(CC) -c body (wave841)"
  fi
  if grep -qE '\$\(CC\).*-c .*(typeck_gen|codegen_gen)|XLANG_C\).*-E-extern' <<<"$_btc_codegen_rec"; then
    bad "bootstrap-codegen must not keep dual gen -E / \$(CC) -c body (wave841)"
  fi
  _btc_sh="$SCRIPT_DIR/bootstrap_typeck_codegen.sh"
  if [ -f "$_btc_sh" ]; then
    if ! bash "$_btc_sh" --check >/tmp/btc_shell_check.log 2>/tmp/btc_shell_check_err.log; then
      bad "bootstrap_typeck_codegen.sh --check failed (wave841)"
      head -20 /tmp/btc_shell_check_err.log >&2 || true
    else
      note "bootstrap_typeck_codegen.sh --check OK (wave841)"
    fi
  else
    bad "missing bootstrap_typeck_codegen.sh (wave841)"
  fi
  if grep -A8 '^bootstrap-self:' "$MF" | grep -qE '\$\(CC\).*-c lsp_'; then
    bad "bootstrap-self must not dual \$(CC) -c on lsp gens (wave785 B7c; use thin leaves)"
  else
    note "bootstrap-self uses thin lsp leaves (wave785 B7c)"
  fi
  # wave843 B7c: bootstrap-self shell-primary via bootstrap_self.sh
  # (stage1 snapshot + stage2 host-cc link + out_self smoke; no dual Makefile body)
  if ! grep -A8 '^bootstrap-self:' "$MF" | grep -q 'bootstrap_self\.sh'; then
    bad "bootstrap-self must thin-call bootstrap_self.sh (wave843 B7c shell-primary)"
  else
    note "bootstrap-self → bootstrap_self.sh (wave843)"
  fi
  _bs_rec=$(awk '/^bootstrap-self:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE '\$\(CC\).*_stage2|TARGET\)_stage2' <<<"$_bs_rec"; then
    bad "bootstrap-self must not keep dual \$(CC) stage2 link body (wave843)"
  fi
  if grep -qE 'out_self|return-value/main\.x' <<<"$_bs_rec"; then
    bad "bootstrap-self must not keep dual out_self smoke body (wave843)"
  fi
  _bs_sh="$SCRIPT_DIR/bootstrap_self.sh"
  if [ -f "$_bs_sh" ]; then
    if ! bash "$_bs_sh" --check >/tmp/bs_shell_check.log 2>/tmp/bs_shell_check_err.log; then
      bad "bootstrap_self.sh --check failed (wave843)"
      head -20 /tmp/bs_shell_check_err.log >&2 || true
    else
      note "bootstrap_self.sh --check OK (wave843)"
    fi
  else
    bad "missing bootstrap_self.sh (wave843)"
  fi
  # wave844 B7c: bootstrap-parser/parse-file shell-primary via bootstrap_parser_smoke.sh
  # (parser.x -o smoke + dual-path fixtures; no dual Makefile body)
  if ! grep -A8 '^bootstrap-parser:' "$MF" | grep -q 'bootstrap_parser_smoke\.sh'; then
    bad "bootstrap-parser must thin-call bootstrap_parser_smoke.sh (wave844 B7c shell-primary)"
  else
    note "bootstrap-parser → bootstrap_parser_smoke.sh (wave844)"
  fi
  if ! grep -A8 '^bootstrap-parse-file:' "$MF" | grep -q 'bootstrap_parser_smoke\.sh'; then
    bad "bootstrap-parse-file must thin-call bootstrap_parser_smoke.sh (wave844 B7c shell-primary)"
  else
    note "bootstrap-parse-file → bootstrap_parser_smoke.sh (wave844)"
  fi
  _bp_parser_rec=$(awk '/^bootstrap-parser:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  _bp_file_rec=$(awk '/^bootstrap-parse-file:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE 'parser\.x|/tmp/xlang_parser_test' <<<"$_bp_parser_rec"; then
    bad "bootstrap-parser must not keep dual parser.x / parser_test body (wave844)"
  fi
  if grep -qE 'xlang_parse_test\.x|parse OK|expr-chain' <<<"$_bp_file_rec"; then
    bad "bootstrap-parse-file must not keep dual fixture / parse OK body (wave844)"
  fi
  _bp_sh="$SCRIPT_DIR/bootstrap_parser_smoke.sh"
  if [ -f "$_bp_sh" ]; then
    if ! bash "$_bp_sh" --check >/tmp/bp_shell_check.log 2>/tmp/bp_shell_check_err.log; then
      bad "bootstrap_parser_smoke.sh --check failed (wave844)"
      head -20 /tmp/bp_shell_check_err.log >&2 || true
    else
      note "bootstrap_parser_smoke.sh --check OK (wave844)"
    fi
  else
    bad "missing bootstrap_parser_smoke.sh (wave844)"
  fi
  # wave845 B7c: xlang-x-pipeline shell-primary via xlang_x_pipeline.sh
  # (multi-make ensure + host-cc link TARGET_x; no dual Makefile body)
  if ! grep -A12 '^xlang-x-pipeline:' "$MF" | grep -q 'xlang_x_pipeline\.sh'; then
    bad "xlang-x-pipeline must thin-call xlang_x_pipeline.sh (wave845 B7c shell-primary)"
  else
    note "xlang-x-pipeline → xlang_x_pipeline.sh (wave845)"
  fi
  _xxp_rec=$(awk '/^xlang-x-pipeline:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE 'PIPELINE_X_FORCE_COMPILE=1|@\$\(MAKE\).*migrate-x-objs' <<<"$_xxp_rec"; then
    bad "xlang-x-pipeline must not keep dual multi-make ensure body (wave845)"
  fi
  if grep -qE '\$\(CC\).*DXLANG_USE_X_PIPELINE|\$\(CC\).* -o \$\(TARGET\)_x' <<<"$_xxp_rec"; then
    bad "xlang-x-pipeline must not keep dual \$(CC) link body (wave845)"
  fi
  _xxp_sh="$SCRIPT_DIR/xlang_x_pipeline.sh"
  if [ -f "$_xxp_sh" ]; then
    if ! bash "$_xxp_sh" --check >/tmp/xxp_shell_check.log 2>/tmp/xxp_shell_check_err.log; then
      bad "xlang_x_pipeline.sh --check failed (wave845)"
      head -20 /tmp/xxp_shell_check_err.log >&2 || true
    else
      note "xlang_x_pipeline.sh --check OK (wave845)"
    fi
  else
    bad "missing xlang_x_pipeline.sh (wave845)"
  fi
  # wave846 B7c: xlang-x shell-primary via xlang_x.sh
  # (seed gate + host-cc link; no dual Makefile body)
  if ! grep -A12 '^xlang-x:' "$MF" | grep -q 'xlang_x\.sh'; then
    bad "xlang-x must thin-call xlang_x.sh (wave846 B7c shell-primary)"
  else
    note "xlang-x → xlang_x.sh (wave846)"
  fi
  _xxl_rec=$(awk '/^xlang-x:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE '\$\(CC\).*DRIVER_SEED_LINK_FLAGS|\$\(CC\).* -o \$@' <<<"$_xxl_rec"; then
    bad "xlang-x must not keep dual \$(CC) link body (wave846)"
  fi
  if grep -qE 'test -f driver_x\.o && test -f lsp_x\.o' <<<"$_xxl_rec"; then
    bad "xlang-x must not keep dual test -f seed gate body (wave846)"
  fi
  _xxl_sh="$SCRIPT_DIR/xlang_x.sh"
  if [ -f "$_xxl_sh" ]; then
    if ! bash "$_xxl_sh" --check >/tmp/xxl_shell_check.log 2>/tmp/xxl_shell_check_err.log; then
      bad "xlang_x.sh --check failed (wave846)"
      head -20 /tmp/xxl_shell_check_err.log >&2 || true
    else
      note "xlang_x.sh --check OK (wave846)"
    fi
  else
    bad "missing xlang_x.sh (wave846)"
  fi
  # wave847 B7c: xlang-no-c-frontend shell-primary via xlang_no_c_frontend.sh
  # (seed gate + host-cc link; no dual Makefile body)
  if ! grep -A12 '^xlang-no-c-frontend:' "$MF" | grep -q 'xlang_no_c_frontend\.sh'; then
    bad "xlang-no-c-frontend must thin-call xlang_no_c_frontend.sh (wave847 B7c shell-primary)"
  else
    note "xlang-no-c-frontend → xlang_no_c_frontend.sh (wave847)"
  fi
  _xnc_rec=$(awk '/^xlang-no-c-frontend:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE '\$\(CC\).*DRIVER_SEED_LINK_FLAGS|\$\(CC\).* -o \$@' <<<"$_xnc_rec"; then
    bad "xlang-no-c-frontend must not keep dual \$(CC) link body (wave847)"
  fi
  if grep -qE 'test -f driver_x\.o && test -f pipeline_x\.o' <<<"$_xnc_rec"; then
    bad "xlang-no-c-frontend must not keep dual test -f seed gate body (wave847)"
  fi
  _xnc_sh="$SCRIPT_DIR/xlang_no_c_frontend.sh"
  if [ -f "$_xnc_sh" ]; then
    if ! bash "$_xnc_sh" --check >/tmp/xnc_shell_check.log 2>/tmp/xnc_shell_check_err.log; then
      bad "xlang_no_c_frontend.sh --check failed (wave847)"
      head -20 /tmp/xnc_shell_check_err.log >&2 || true
    else
      note "xlang_no_c_frontend.sh --check OK (wave847)"
    fi
  else
    bad "missing xlang_no_c_frontend.sh (wave847)"
  fi
  # wave848 B7c: bootstrap-driver-seed-x-frontend shell-primary via
  # bootstrap_driver_seed_x_frontend.sh (host-cc link; no dual Makefile body)
  if ! grep -A12 '^bootstrap-driver-seed-x-frontend:' "$MF" | grep -q 'bootstrap_driver_seed_x_frontend\.sh'; then
    bad "bootstrap-driver-seed-x-frontend must thin-call bootstrap_driver_seed_x_frontend.sh (wave848 B7c shell-primary)"
  else
    note "bootstrap-driver-seed-x-frontend → bootstrap_driver_seed_x_frontend.sh (wave848)"
  fi
  _bxf_rec=$(awk '/^bootstrap-driver-seed-x-frontend:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE '\$\(CC\).* -o |\$\(CC\).*DXLANG_USE_X_TYPECK|\$\(CC\).*DRIVER_SEED_X_FRONTEND' <<<"$_bxf_rec"; then
    bad "bootstrap-driver-seed-x-frontend must not keep dual \$(CC) link body (wave848)"
  fi
  _bxf_sh="$SCRIPT_DIR/bootstrap_driver_seed_x_frontend.sh"
  if [ -f "$_bxf_sh" ]; then
    if ! bash "$_bxf_sh" --check >/tmp/bxf_shell_check.log 2>/tmp/bxf_shell_check_err.log; then
      bad "bootstrap_driver_seed_x_frontend.sh --check failed (wave848)"
      head -20 /tmp/bxf_shell_check_err.log >&2 || true
    else
      note "bootstrap_driver_seed_x_frontend.sh --check OK (wave848)"
    fi
  else
    bad "missing bootstrap_driver_seed_x_frontend.sh (wave848)"
  fi
  # wave849 B7c: relink-xlang-lexer shell-primary via relink_xlang_lexer.sh
  # (seed gate + host-cc link + XLANG_C sync; no dual Makefile body)
  if ! grep -A12 '^relink-xlang-lexer:' "$MF" | grep -q 'relink_xlang_lexer\.sh'; then
    bad "relink-xlang-lexer must thin-call relink_xlang_lexer.sh (wave849 B7c shell-primary)"
  else
    note "relink-xlang-lexer → relink_xlang_lexer.sh (wave849)"
  fi
  _rxl_rec=$(awk '/^relink-xlang-lexer:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE '\$\(CC\).*DRIVER_SEED_LINK_FLAGS|\$\(CC\).* -o \$\(TARGET\)|\$\(CC\).*RELINK_XLANG_PIPELINE' <<<"$_rxl_rec"; then
    bad "relink-xlang-lexer must not keep dual \$(CC) link body (wave849)"
  fi
  if grep -qE 'test -f driver_x\.o && test -f pipeline_x\.o' <<<"$_rxl_rec"; then
    bad "relink-xlang-lexer must not keep dual test -f seed gate body (wave849)"
  fi
  if grep -qE 'cp -f \$\(TARGET\) \$\(XLANG_C\)|cp -f \$\(TARGET\) bootstrap_xlangc' <<<"$_rxl_rec"; then
    bad "relink-xlang-lexer must not keep dual cp sync body (wave849)"
  fi
  _rxl_sh="$SCRIPT_DIR/relink_xlang_lexer.sh"
  if [ -f "$_rxl_sh" ]; then
    if ! bash "$_rxl_sh" --check >/tmp/rxl_shell_check.log 2>/tmp/rxl_shell_check_err.log; then
      bad "relink_xlang_lexer.sh --check failed (wave849)"
      head -20 /tmp/rxl_shell_check_err.log >&2 || true
    else
      note "relink_xlang_lexer.sh --check OK (wave849)"
    fi
  else
    bad "missing relink_xlang_lexer.sh (wave849)"
  fi
  # wave786 B7D: default TARGET product link via g05 (not incomplete OBJS_CORE)
  if ! grep -q 'g05_prepare_and_relink\.sh' "$MF"; then
    bad "Makefile must thin-call g05_prepare_and_relink for default TARGET (wave786 B7D)"
  elif ! grep -q 'XLANG_HOST_CC_OBJS_CORE' "$MF"; then
    bad "Makefile must keep XLANG_HOST_CC_OBJS_CORE escape for archaeology (wave786)"
  else
    note "Makefile TARGET default → g05_prepare_and_relink (wave786 B7D)"
  fi
  # wave787 B7A heat residual: ensure thin-call edges still in Makefile
  _heat_n=$(grep -c 'ensure_host_cc_seed_o\.sh' "$MF" 2>/dev/null || true)
  _heat_n=${_heat_n:-0}
  if [ "$_heat_n" -lt 1 ]; then
    bad "Makefile must retain ensure_host_cc_seed_o thin-call heat edges (wave787 B7A heat residual)"
  else
    note "Makefile heat ensure thin-call edges present (n=${_heat_n}; wave787 B7A residual)"
  fi
  # wave787 B7A cold: rebuild_leaves still shell-first (residual make only if residual_n>0)
  _rl="$SCRIPT_DIR/bootstrap_driver_seed_rebuild_leaves.sh"
  if [ -f "$_rl" ]; then
    if ! grep -q 'residual_make=' "$_rl"; then
      bad "rebuild_leaves must report residual_make (wave787 B7A cold honesty)"
    elif ! grep -q 'try-gen-x' "$_rl"; then
      bad "rebuild_leaves must keep try-gen-x before residual make (wave787)"
    else
      note "rebuild_leaves cold ladder shell-first (wave787 B7A cold 0-make honesty)"
    fi
  else
    bad "missing bootstrap_driver_seed_rebuild_leaves.sh (wave787 B7A)"
  fi
  # wave787/788 B7B: mk list authority + shell-primary catalog
  if [ ! -f "$COMPILER_DIR/mk/driver_seed_export_lists.mk" ]; then
    bad "mk/driver_seed_export_lists.mk must exist (wave787 B7B list authority)"
  fi
  if [ ! -f "$COMPILER_DIR/mk/driver_seed_r_lists.mk" ]; then
    bad "mk/driver_seed_r_lists.mk must exist (wave788 B7B R1/R3/RT lists)"
  fi
  if [ ! -f "$SCRIPT_DIR/driver_seed_obj_catalog.sh" ]; then
    bad "missing driver_seed_obj_catalog.sh (wave788 B7B)"
  elif ! grep -q 'catalog_shell_dump\|shell_primary\|catalog_parse_mk' "$SCRIPT_DIR/driver_seed_obj_catalog.sh"; then
    bad "catalog must shell-parse mk (wave788 B7B shell primary)"
  elif ! grep -q 'export-obj-catalog' "$SCRIPT_DIR/driver_seed_obj_catalog.sh"; then
    bad "catalog must keep make export-obj-catalog escape (wave788)"
  else
    note "B7B shell-primary catalog + mk lists (wave788; make export escape)"
  fi
  # Live shell catalog --check (keys + shell==make parity)
  if ! bash "$SCRIPT_DIR/driver_seed_obj_catalog.sh" --check \
    >/tmp/driver_seed_obj_catalog_check.log 2>/tmp/driver_seed_obj_catalog_check_err.log; then
    bad "driver_seed_obj_catalog.sh --check failed (wave788)"
    head -30 /tmp/driver_seed_obj_catalog_check_err.log >&2 || true
  else
    note "driver_seed_obj_catalog.sh --check OK (wave788 shell==make)"
  fi
  # wave842 B7c: bootstrap-x-compiler shell-primary via bootstrap_x_compiler.sh
  # (emit=-x -E; host-cc -c typeck_x_x inside shell; no dual Makefile body)
  if ! grep -A8 '^bootstrap-x-compiler:' "$MF" | grep -q 'bootstrap_x_compiler\.sh'; then
    bad "bootstrap-x-compiler must thin-call bootstrap_x_compiler.sh (wave842 B7c shell-primary)"
  else
    note "bootstrap-x-compiler → bootstrap_x_compiler.sh (wave842)"
  fi
  _bxc_rec=$(awk '/^bootstrap-x-compiler:/{h=1;next} h&&/^[^[:space:]#]/{exit} h&&/^\t/{print}' "$MF")
  if grep -qE '\$\(CC\).*-c .*typeck_x_x|\$\(CC\).*-c .*codegen_x_x' <<<"$_bxc_rec"; then
    bad "bootstrap-x-compiler must not keep dual \$(CC) -c typeck_x_x body (wave842)"
  fi
  if grep -qE 'TARGET\)_x.*-x|-x -E src/typeck' <<<"$_bxc_rec"; then
    bad "bootstrap-x-compiler must not keep dual -x -E emit body (wave842)"
  fi
  _bxc_sh="$SCRIPT_DIR/bootstrap_x_compiler.sh"
  if [ -f "$_bxc_sh" ]; then
    if ! bash "$_bxc_sh" --check >/tmp/bxc_shell_check.log 2>/tmp/bxc_shell_check_err.log; then
      bad "bootstrap_x_compiler.sh --check failed (wave842)"
      head -20 /tmp/bxc_shell_check_err.log >&2 || true
    else
      note "bootstrap_x_compiler.sh --check OK (wave842)"
    fi
  else
    bad "missing bootstrap_x_compiler.sh (wave842)"
  fi
fi

# wave748–749: R1 family bodies + catalog keys + Makefile thin
if ! grep -q 'RT_SEED_SLICE_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require RT_SEED_SLICE_OBJS (wave748)"
fi
if ! grep -q 'R1_CORE_SEED_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_CORE_SEED_OBJS (wave749)"
fi
if ! grep -q 'R1_FRONTEND_GLUE_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_FRONTEND_GLUE_OBJS (wave750)"
fi
if ! grep -q 'R1_MAIN_RUNTIME_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_MAIN_RUNTIME_OBJS (wave751)"
fi
if ! grep -q 'R1_ALIAS_STUBS_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_ALIAS_STUBS_OBJS (wave752)"
fi
if ! grep -q 'R1_EXTRA_CFLAGS_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_EXTRA_CFLAGS_OBJS (wave753)"
fi
if ! grep -q 'R1_MISC_BASENAME_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_MISC_BASENAME_OBJS (wave754)"
fi
if ! grep -q 'R1_SEED_MAP_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R1_SEED_MAP_OBJS (wave755)"
fi
if ! grep -q 'R3_COLD_SEED_OBJS' compiler/scripts/driver_seed_obj_catalog.sh; then
  bad "driver_seed_obj_catalog must require R3_COLD_SEED_OBJS (wave757)"
fi
if ! grep -q 'ensure_host_cc_seed_o\.sh' "$MF"; then
  bad "Makefile must thin-call ensure_host_cc_seed_o.sh for R1 families"
fi
# wave788: R1/R3/RT list authority lives in mk/driver_seed_r_lists.mk (Makefile includes).
_r_lists="$COMPILER_DIR/mk/driver_seed_r_lists.mk"
if [ ! -f "$_r_lists" ]; then
  bad "missing mk/driver_seed_r_lists.mk (wave788 list authority)"
fi
if ! grep -q 'R1_CORE_SEED_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R1_CORE_SEED_OBJS (wave749/788 list authority)"
fi
if ! grep -q 'R1_FRONTEND_GLUE_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R1_FRONTEND_GLUE_OBJS (wave750/788)"
fi
if ! grep -q 'R1_MAIN_RUNTIME_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R1_MAIN_RUNTIME_OBJS (wave751/788)"
fi
if ! grep -q 'R1_ALIAS_STUBS_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R1_ALIAS_STUBS_OBJS (wave752/788)"
fi
if ! grep -q 'R1_EXTRA_CFLAGS_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R1_EXTRA_CFLAGS_OBJS (wave753/788)"
fi
if ! grep -q 'R1_MISC_BASENAME_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R1_MISC_BASENAME_OBJS (wave754/788)"
fi
if ! grep -q 'R1_SEED_MAP_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R1_SEED_MAP_OBJS (wave755/788)"
fi
if ! grep -q 'R3_COLD_SEED_OBJS' "$_r_lists"; then
  bad "mk/driver_seed_r_lists.mk must define R3_COLD_SEED_OBJS (wave757/788)"
fi
if ! grep -q 'driver_seed_r_lists\.mk' "$MF"; then
  bad "Makefile must include mk/driver_seed_r_lists.mk (wave788)"
fi
# wave757: rebuild residual must try try-r3-cold
if ! grep -q 'try-r3-cold\|try_ensure_r3_cold' "$REBUILD_REL"; then
  bad "rebuild_leaves must use ensure try-r3-cold for R3 cold-else (wave757)"
fi
# wave760: rebuild residual must try try-r2 for R2 panic cold
if ! grep -q 'try-r2\|try_ensure_r2' "$REBUILD_REL"; then
  bad "rebuild_leaves must use ensure try-r2 for R2 panic cold (wave760)"
fi
# G.7: ensure script must not hardcode product .o assignment list (export-style)
if grep -nE '^(export )?RT_SEED_SLICE_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode RT_SEED_SLICE_OBJS= (G.7)"
fi
if grep -nE '^(export )?R1_CORE_SEED_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode R1_CORE_SEED_OBJS= (G.7)"
fi
if grep -nE '^(export )?R1_FRONTEND_GLUE_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode R1_FRONTEND_GLUE_OBJS= (G.7)"
fi
if grep -nE '^(export )?R1_MAIN_RUNTIME_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode R1_MAIN_RUNTIME_OBJS= (G.7)"
fi
if grep -nE '^(export )?R1_ALIAS_STUBS_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode R1_ALIAS_STUBS_OBJS= (G.7)"
fi
if grep -nE '^(export )?R1_EXTRA_CFLAGS_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode R1_EXTRA_CFLAGS_OBJS= (G.7)"
fi
if grep -nE '^(export )?R1_MISC_BASENAME_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode R1_MISC_BASENAME_OBJS= (G.7)"
fi
if grep -nE '^(export )?R1_SEED_MAP_OBJS=' compiler/scripts/ensure_host_cc_seed_o.sh \
  | grep -vqE '^\s*#|:[0-9]+:\s*#'; then
  bad "ensure_host_cc_seed_o.sh must not hardcode R1_SEED_MAP_OBJS= (G.7)"
fi
# Core-seed leaves must not keep inline $(CC) -c seed recipes
if grep -A1 -E '^(src/diag\.o|src/runtime_link_abi\.o|src/runtime_c_import\.o|src/x_seed_bridge\.o|src/seed_link_compat\.o):' "$MF" \
  | grep -qE '\$\(CC\).*-c seeds/'; then
  bad "Makefile core-seed leaves still have inline \$(CC) -c (wave749 thin required)"
fi
# Frontend-glue leaves must not keep inline $(CC) -c seed recipes
if grep -A1 -E '^(src/lexer/lexer\.o|src/ast/ast\.o|src/lsp/lsp_diag\.o):' "$MF" \
  | grep -qE '\$\(CC\).*-c seeds/'; then
  bad "Makefile frontend-glue leaves still have inline \$(CC) -c (wave750 thin required)"
fi
# Main-runtime leaves must not keep inline $(CC) -c seed recipes
if grep -A1 -E '^(src/main\.o|src/main_x\.o|src/main_driver\.o|src/runtime\.o|src/runtime_x\.o|src/runtime_driver\.o|src/runtime_driver_no_c\.o):' "$MF" \
  | grep -qE '\$\(CC\).*-c seeds/'; then
  bad "Makefile main-runtime leaves still have inline \$(CC) -c (wave751 thin required)"
fi
# Alias-stubs leaves must not keep inline $(CC) -c seed recipes
if grep -A1 -E '^(x_frontend_link_alias\.o|ast_asm_bare_link_alias\.o|backend_asm_bare_link_alias\.o|backend_asm_strict_fallback_alias\.o|typeck_c_module_stubs\.o|src/asm/user_asm_seed_bridge\.o|src/asm/asm_backend_compat_stubs\.o|src/runtime_driver_strict_glue_stubs\.o):' "$MF" \
  | grep -qE '\$\(CC\).*-c seeds/'; then
  bad "Makefile alias-stubs leaves still have inline \$(CC) -c (wave752 thin required)"
fi
# Extra-cflags leaves must not keep inline $(CC) -c seed recipes
if grep -A1 -E '^(src/runtime_pipeline_abi\.o|runtime_asm_io_stubs\.o|runtime_sqlite_glue\.o|runtime_sqlite_glue_stub\.o|src/asm/parser_asm_parse_expr_link\.o):' "$MF" \
  | grep -qE '\$\(CC\).*-c seeds/'; then
  bad "Makefile extra-cflags leaves still have inline \$(CC) -c (wave753 thin required)"
fi
# Misc-basename leaves must not keep inline $(CC) -c seed recipes
if grep -A2 -E '^(runtime_link_abi_user_env\.o|runtime_channel_glue\.o|runtime_scheduler_glue\.o|runtime_kv_mmap_glue\.o|src/asm/backend_x86_64_enc_c\.o|src/asm/backend_arm64_enc_c\.o|src/lsp/lsp_diag_pipeline_ctx\.o|build_asm/pipeline_glue_strict_minimal\.o|src/asm/runtime_asm_build\.o):' "$MF" \
  | grep -qE '\$\(CC\).*-c seeds/'; then
  bad "Makefile misc-basename leaves still have inline \$(CC) -c (wave754 thin required)"
fi
# Seed-map leaves must not keep inline $(CC) -c seed recipes
if grep -A2 -E '^(src/driver/target_cpu\.o|src/ast/ast_seed\.o|pipeline_bootstrap_orchestration\.o):' "$MF" \
  | grep -qE '\$\(CC\).*-c seeds/'; then
  bad "Makefile seed-map leaves still have inline \$(CC) -c (wave755 thin required)"
fi
note "R1 rt-seed-slice + core-seed + frontend-glue + main-runtime + alias-stubs + extra-cflags + misc-basename + seed-map shell body + catalog + thin Makefile (wave748–755)"

# wave747+756: rebuild_leaves = catalog + mode table + pure-R1 try-r1; residual make
if [ ! -f "$REBUILD_REL" ]; then
  bad "missing $REBUILD_REL"
else
  if ! grep -q 'driver_seed_obj_catalog\.sh' "$REBUILD_REL"; then
    bad "rebuild_leaves must default to driver_seed_obj_catalog (wave747 R4 mode)"
  fi
  if ! grep -q 'catalog_key=' "$REBUILD_REL"; then
    bad "rebuild_leaves must have shell mode table catalog_key= (wave747)"
  fi
  if ! grep -q 'ensure_host_cc_seed_o\.sh' "$REBUILD_REL" \
    || ! grep -qE 'try-r1|try_r1' "$REBUILD_REL"; then
    bad "rebuild_leaves must call ensure try-r1 for pure R1 bodies (wave756)"
  fi
  if ! grep -qE 'try-r3-cold|try_r3_cold' "$REBUILD_REL"; then
    bad "rebuild_leaves must call ensure try-r3-cold for R3 cold-else (wave757)"
  fi
  if ! grep -qE 'try-r2|try_r2' "$REBUILD_REL"; then
    bad "rebuild_leaves must call ensure try-r2 for R2 panic cold (wave760)"
  fi
  if ! grep -qE '\$MAKE|"\$MAKE"|make ' "$REBUILD_REL"; then
    bad "rebuild_leaves must still invoke make for non-shell residual bodies (R4 residual)"
  fi
  # G.7: no hardcoded product .o paths in rebuild_leaves
  if grep -qE 'src/diag\.o|lsp_io_x\.o|simd_enc\.o|x_seed_bridge\.o|runtime_panic\.o|user_asm_seed_bridge\.o|pipeline_glue_standalone\.o' \
    "$REBUILD_REL"; then
    bad "rebuild_leaves must not hardcode .o list (dual authority)"
  fi
  note "R4 mode + pure-R1 try-r1 + R3 cold try-r3-cold + R2 panic/typeck_f64/crt0 try-r2; R3 PREFER thin try-r3-prefer (wave763) + g05 r3-prefer-family (wave764) + labi/rt/pipeline_abi/ldpc/target_cpu/l2-asm/async/other-l2 try-*-prefer (wave765–771); R6 pure-ld (wave772/773) + drop silent CC fallback (wave774); fmt_check_cmd.o dual (wave775); R2 panic PREFER try-r2-prefer (wave776); phys-del prep (wave777); Windows+dual-end gate (wave778); B1–B6 swallow (wave779–784); B7 DAG inventory + archaeology CC thin (wave785); B7D host-cc product link g05 (wave786); B7A cold residual_make=0 honesty (wave787); B7B shell-primary catalog (wave788); B7A heat try-heat (wave789); B7A heat thin-unify (wave790); B7A heat dep-thin FORCE 113 (wave791–797; orch closed); phys-del preflight (wave798); phys-del execute-gate (wave799); Windows proof harness (wave800); status-flip-preview (wave801); status-flip-apply harness (wave802); status-flip-commit-honesty (wave803); residual Windows min-gate then physical delete"
fi

# wave772/774: cold pure-ld required when eligible (no silent CC fallback)
if [ ! -f compiler/scripts/bootstrap_driver_seed_link.sh ]; then
  bad "missing bootstrap_driver_seed_link.sh (wave772)"
elif ! grep -q 'run_pure_ld_required\|SEED_LINK_PURE_OK' compiler/scripts/bootstrap_driver_seed_link.sh; then
  bad "bootstrap_driver_seed_link must require pure-ld when eligible (wave774)"
elif ! grep -q 'pure_ld_shared' compiler/scripts/bootstrap_driver_seed_link.sh; then
  bad "bootstrap_driver_seed_link must source pure_ld_shared (wave773)"
elif grep -qE 'falling back to.*(CC|SEED_LINK_CC)' compiler/scripts/bootstrap_driver_seed_link.sh; then
  bad "bootstrap_driver_seed_link must not silently fall back to CC (wave774)"
else
  note "cold pure-ld required + no silent CC fallback + pure_ld_shared (wave772/774)"
fi
if ! grep -q 'SEED_LINK_PURE_OK\|SEED_LINK_MULTIDEF' compiler/Makefile; then
  bad "Makefile must export SEED_LINK_PURE_OK/MULTIDEF (wave772 pure-ld)"
else
  note "Makefile pure-ld export signal present (wave772)"
fi

# wave773/774: g05 pure-ld required when freestanding; FORCE_CC / ineligible keep CC residual
if [ ! -f compiler/scripts/pure_ld_shared.sh ]; then
  bad "missing pure_ld_shared.sh (wave773)"
elif ! grep -q 'pure_ld_try_link' compiler/scripts/pure_ld_shared.sh; then
  bad "pure_ld_shared.sh must define pure_ld_try_link (wave773)"
else
  note "pure_ld_shared authority present (wave773)"
fi
if [ ! -f compiler/scripts/g05_relink_xlang.sh ]; then
  bad "missing g05_relink_xlang.sh"
elif ! grep -q 'run_g05_pure_ld_required\|pure_ld_try_link' compiler/scripts/g05_relink_xlang.sh; then
  bad "g05_relink_xlang must require pure-ld when freestanding (wave774)"
elif ! grep -q 'CC residual\|FORCE_CC' compiler/scripts/g05_relink_xlang.sh; then
  bad "g05_relink_xlang must keep named CC residual for FORCE_CC/ineligible (wave774)"
elif grep -qE 'falling back to CC residual' compiler/scripts/g05_relink_xlang.sh; then
  bad "g05_relink_xlang must not silently fall back to CC (wave774)"
else
  note "g05 pure-ld required + named CC residual only (FORCE_CC/ineligible) wave774"
fi

# wave763: ensure try-r3-prefer + Makefile R3_COLD thin-call
if [ ! -f compiler/scripts/ensure_host_cc_seed_o.sh ]; then
  bad "missing ensure_host_cc_seed_o.sh"
elif ! grep -q 'try-r3-prefer\|try_ensure_r3_prefer' compiler/scripts/ensure_host_cc_seed_o.sh; then
  bad "ensure_host_cc_seed_o must provide try-r3-prefer (wave763 R3 PREFER thin)"
else
  note "try-r3-prefer present in ensure_host_cc_seed_o (wave763)"
fi
if ! grep -q 'try-r3-prefer' compiler/Makefile; then
  bad "Makefile must thin-call try-r3-prefer for R3_COLD leaves (wave763)"
else
  note "Makefile try-r3-prefer thin-call signal present (wave763)"
fi

# wave764: g05 R3_COLD product path → r3-prefer-family (no dual hybrid)
if [ ! -f compiler/scripts/g05_ensure_relink_prereqs.sh ]; then
  bad "missing g05_ensure_relink_prereqs.sh (wave764)"
elif ! grep -q 'r3-prefer-family\|r3_prefer_family' compiler/scripts/g05_ensure_relink_prereqs.sh; then
  bad "g05_ensure must thin-call r3-prefer-family (wave764)"
else
  note "g05 r3-prefer-family thin-call present (wave764)"
fi

# wave765: g05 labi multi-slice → try-labi-prefer (no dual hybrid)
if [ ! -f compiler/scripts/ensure_host_cc_seed_o.sh ]; then
  bad "ensure_host_cc_seed_o.sh missing (wave765)"
elif ! grep -q 'try-labi-prefer\|try_ensure_labi_prefer_one' compiler/scripts/ensure_host_cc_seed_o.sh; then
  bad "ensure_host_cc_seed_o must provide try-labi-prefer (wave765 labi multi-slice)"
else
  note "try-labi-prefer present in ensure_host_cc_seed_o (wave765)"
fi
if ! grep -q 'try-labi-prefer' compiler/Makefile; then
  bad "Makefile must thin-call try-labi-prefer for labi link_abi leaf (wave765)"
else
  note "Makefile try-labi-prefer thin-call signal present (wave765)"
fi
if [ ! -f compiler/scripts/g05_ensure_relink_prereqs.sh ]; then
  bad "g05_ensure_relink_prereqs.sh missing (wave765)"
elif ! grep -q 'try-labi-prefer\|labi-prefer' compiler/scripts/g05_ensure_relink_prereqs.sh; then
  bad "g05_ensure must thin-call try-labi-prefer (wave765)"
else
  note "g05 try-labi-prefer thin-call present (wave765)"
fi
if grep -qE '_labi_l0_seed=seeds/labi_path_pure' compiler/scripts/g05_ensure_relink_prereqs.sh; then
  bad "g05_ensure still has labi multi-slice dual hybrid (wave765)"
else
  note "g05 labi dual hybrid body removed (wave765)"
fi

# wave766: g05 rt multi-slice → try-rt-prefer (no dual hybrid)
if [ ! -f compiler/scripts/ensure_host_cc_seed_o.sh ]; then
  bad "ensure_host_cc_seed_o.sh missing (wave766)"
elif ! grep -q 'try-rt-prefer\|try_ensure_rt_prefer_one' compiler/scripts/ensure_host_cc_seed_o.sh; then
  bad "ensure_host_cc_seed_o must provide try-rt-prefer (wave766 rt multi-slice)"
else
  note "try-rt-prefer present in ensure_host_cc_seed_o (wave766)"
fi
if ! grep -q 'try-rt-prefer' compiler/Makefile; then
  bad "Makefile must thin-call try-rt-prefer for runtime_driver_no_c leaf (wave766)"
else
  note "Makefile try-rt-prefer thin-call signal present (wave766)"
fi
if [ ! -f compiler/scripts/g05_ensure_relink_prereqs.sh ]; then
  bad "g05_ensure_relink_prereqs.sh missing (wave766)"
elif ! grep -q 'try-rt-prefer\|rt-prefer' compiler/scripts/g05_ensure_relink_prereqs.sh; then
  bad "g05_ensure must thin-call try-rt-prefer (wave766)"
else
  note "g05 try-rt-prefer thin-call present (wave766)"
fi
if grep -qE '_rt_content_seed=seeds/rt_content' compiler/scripts/g05_ensure_relink_prereqs.sh; then
  bad "g05_ensure still has rt multi-slice dual hybrid (wave766)"
else
  note "g05 rt dual hybrid body removed (wave766)"
fi
if grep -qE 'g05_rio_thin|g05_rdabi_thin|g05_simd_enc_thin|G-02f-334：runtime_io_abi' \
  compiler/scripts/g05_ensure_relink_prereqs.sh; then
  bad "g05_ensure still has R3_COLD dual hybrid body (wave764)"
else
  note "g05 R3_COLD dual hybrid body removed (wave764)"
fi
if ! grep -q 'r3_prefer_try_step\|XLANG_SIMD_ENC_FROM_X' compiler/scripts/ensure_host_cc_seed_o.sh; then
  bad "try-r3-prefer must gain full→thin ladder (wave764)"
else
  note "try-r3-prefer full→thin ladder present (wave764)"
fi

# G.7: this script must not hardcode product .o inventories as code paths
if grep -nE '[a-zA-Z0-9_./-]+\.o' "$SCRIPT_DIR/leaf_pattern_residual.sh" \
  | grep -vE '^\s*#|inventor|hardcode|catalog|\.mk|lists|dual|not |\.o list|thin\.o|from_x|pattern|leaf \.o|how \.o|individual' \
  | grep -qE '[a-zA-Z0-9_/]+\.o'; then
  code_hits=$(grep -nE '[a-zA-Z0-9_./-]+\.o' "$SCRIPT_DIR/leaf_pattern_residual.sh" \
    | grep -vE ':[0-9]+:[[:space:]]*#|inventor|hardcode|catalog|\.mk|lists|dual|not |pattern|thin\.o|from_x|leaf' || true)
  if [ -n "${code_hits:-}" ]; then
    if printf '%s\n' "$code_hits" | grep -qE '[= ].*\.o|"[^"]+\.o' ; then
      bad "leaf_pattern_residual.sh must not hardcode .o paths (G.7):"
      echo "$code_hits" | head -10 >&2
    fi
  fi
fi

# xbuild wiring
if [ ! -f "$XBUILD_REL" ]; then
  bad "missing $XBUILD_REL"
elif ! grep -qE 'leaf-patterns|leaf-residual' "$XBUILD_REL" \
  || ! grep -q 'leaf_pattern_residual\.sh' "$XBUILD_REL"; then
  bad "xlang-build.sh must wire leaf-patterns / leaf-residual → leaf_pattern_residual.sh"
else
  note "xbuild leaf-patterns / leaf-residual wired"
fi

# build.x strategy map
if [ -f build.x ]; then
  if ! grep -qE '11\.3\.1|leaf.pattern|LEAF_PATTERN' build.x; then
    bad "build.x must mention 11.3.1 / leaf pattern residual"
  else
    note "build.x references 11.3.1 leaf residual"
  fi
else
  bad "missing root build.x"
fi

# BUILD_DAG + PLATFORM_LINKER cross-ref
if [ -f compiler/docs/BUILD_DAG.md ]; then
  if ! grep -qE '11\.3\.1|LEAF_PATTERN|leaf_pattern_residual|wave746|wave747' compiler/docs/BUILD_DAG.md; then
    bad "BUILD_DAG.md must cross-ref wave746/747 / LEAF_PATTERN / 11.3.1"
  else
    note "BUILD_DAG.md cross-ref OK"
  fi
else
  bad "missing compiler/docs/BUILD_DAG.md"
fi

if [ -f compiler/docs/PLATFORM_LINKER.md ]; then
  note "PLATFORM_LINKER.md present (R6 / UNAME cross-track)"
else
  bad "missing PLATFORM_LINKER.md (wave745 companion for R6)"
fi

if [ "$fail" -ne 0 ]; then
  echo "leaf_pattern_residual: CHECK FAILED" >&2
  exit 1
fi
echo "leaf_pattern_residual: CHECK OK (wave747–839: leaf residual + phys-del harness + TREE_ARMED + delete-body honesty + wave811 std_x thin 22 + wave825 std_x ensure catalog 22 + wave827 std_x FORCE dep-thin 22 + wave812 formal_mod ensure 38 + wave826 formal_mod FORCE dep-thin 38 + wave813 STD_AND_PANIC list→mk + wave814 driver_leaf ensure 8 + wave828 driver_leaf FORCE dep-thin 8 + wave829 gen.c FORCE dep-thin 17 + wave830 ast_gen2 FORCE dep-thin 1 + wave831 src-edge FORCE dep-thin 7 + wave832 migrate companion FORCE dep-thin 3 + wave833 pipeline_glue_types FORCE dep-thin 1 + wave834 bootstrap-pipeline FORCE shell-primary 1 + wave835 class-G filter FORCE dep-thin 4 + wave836 cp-alias FORCE dep-thin 3 + wave837 pipeline_gen FORCE dep-thin 1 + wave838 bootstrap_xlangc FORCE dep-thin 1 + wave815 archaeology host-pick phonies 4 + wave839 archaeology host-pick FORCE dep-thin 4 + wave816 DRIVER_SUBCMD list→mk 7 + wave817 PIPELINE_X list→mk satellite 9 + wave818 SEED_MODE list→mk SUPPORT_EXTRA 3 + wave819 SEED_LINK_PICKS list→mk GLUE 2 + wave820 OBJS_CORE list→mk 16 + wave821 ARCH_EXPERIMENT list→mk 7 + wave822 RELINK/LEGACY list→composites 14 + wave823 SOURCE_DEPS list→mk 19 + wave824 E_DIRS list→mk 26 + wave850 RELINK_PRODUCT_LINK bag→mk 8 + wave851 XXL/BS/XNC link bags→mk 3 + wave852 BXF link bag→mk 2 + wave853 seed phase1/final link bags→mk 2 + wave854 seed-gate REQUIRED bags→mk 3 + wave855 seed-gate REQUIRED shell-load 3 + wave856 LINK_OBJS shell-load export leaves 5 + wave857 LINK_CFLAGS shell-load export leaves 4 + wave858 LEGACY xlang-c shell-primary 1 + wave859 XXP/BXC bag shell-load 2 + wave860 driver_leaf BASE_CFLAGS shell-load 8 + wave861 rt_* -I CFLAGS hygiene 5 + wave862 try-heat CFLAGS bulk shell-load 114 + wave863 filter CFLAGS shell-load 4 + wave864 leaf-extra RUNTIME_*/PARSER_* CFLAGS hygiene 3 + wave865 migrate/bootstrap CFLAGS shell-load 8 + wave866 build-tool/WIN32 CFLAGS hygiene 2 + wave867 archaeology host-pick LD_R hygiene 4 + wave868 bstrict-relink shell-primary 1 + wave869 bootstrap-driver-crt0 shell-primary 1 + wave870 check-7.2 shell-primary 1 + wave871 check-6.4 shell-primary 1 + wave872 bootstrap-driver-hybrid shell-primary 1 + wave873 regen-lsp-gens-x shell-primary 1 + wave874 build-via-tool shell-primary 1 + wave875 size/perf-baseline shell-primary 2 + wave876 default xlang-c alias shell-primary 1 + wave877 gen ensure env hygiene 20 + wave878 migrate env hygiene 4 + wave879 stage/bootstrap env hygiene 13; Makefile still present; delete body deferred)"
exit 0
