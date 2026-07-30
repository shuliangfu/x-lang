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
#   wave812: formal_mod shell-primary catalog (38 leaves) → xlang_compile_std_module ensure
#            (Makefile thin-call only; NOT physical delete; edges+lists+B2 remain)
#   wave813: B7B STD_AND_PANIC_O list authority → mk/std_and_panic_objs.mk
#            (Makefile include only; NOT physical delete; thin edges + B2 remain)
#   wave814: driver_leaf shell-primary catalog (8 leaves) → driver_leaf_x_to_o ensure
#            (Makefile thin-call only; NOT physical delete; edges+lists remain)
#   wave815: archaeology host-pick phonies (4) → archaeology_host_pick_phony ensure
#            (net-o-stub/openssl/mbedtls + sqlite-o-stub; NOT physical delete)
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
# NOT physical delete — thin-call edges + B2 + mk lists remain.
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN=1
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_WAVE=wave834
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_COUNT=1
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_VIA=ensure_lsp_pipeline_gen_pipeline_mode
PHYS_DEL_BOOTSTRAP_PIPELINE_FORCE_THIN_NOTE=force_prereq_shell_owns_pipeline_gen_ensure_edges_remain
SWALLOWED_BOOTSTRAP_PIPELINE_FORCE_THIN=1
BOOTSTRAP_PIPELINE_FORCE_THIN_SWALLOWED=1
BOOTSTRAP_PIPELINE_FORCE_THIN_HELPER=ensure_lsp_pipeline_gen.sh
BOOTSTRAP_PIPELINE_FORCE_THIN_WAVE=wave834

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
PHYS_DEL_BUCKET_B7C_SCOPE=bootstrap_typeck_codegen_self_x_compiler
PHYS_DEL_BUCKET_B7C_ARCHAEOLOGY_CC_THINNED=1
PHYS_DEL_BUCKET_B7C_THINNED_VIA=migrate_x_objs+ensure_gen_x_o_driver_leaf
PHYS_DEL_BUCKET_B7C_THINNED_NOTE=typeck_codegen_migrate_self_lsp_thin_x_x_residual
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
PHYS_DEL_PREFLIGHT_ARCH_HOST_PICK_PHONY=1
PHYS_DEL_PREFLIGHT_B7B_DRIVER_SUBCMD_LIST=1
PHYS_DEL_PREFLIGHT_B7B_PIPELINE_X_LIST=1
PHYS_DEL_PREFLIGHT_B7B_SEED_MODE_LIST=1
PHYS_DEL_PREFLIGHT_B7B_SEED_LINK_PICKS_LIST=1
PHYS_DEL_PREFLIGHT_B7B_OBJS_CORE_LIST=1
PHYS_DEL_PREFLIGHT_B7B_ARCH_EXPERIMENT_LIST=1
PHYS_DEL_PREFLIGHT_B7B_RELINK_LEGACY_LIST=1
PHYS_DEL_PREFLIGHT_B7B_SOURCE_DEPS_LIST=1
PHYS_DEL_PREFLIGHT_B7B_E_DIRS_LIST=1
PHYS_DEL_PREFLIGHT_NEXT=continue_shell_primary_then_explicit_auth_ship_delete_body
PHYS_DEL_PREFLIGHT_FORBIDDEN=claim_preflight_is_physical_delete|claim_tree_arm_is_physical_delete|claim_endgame_1_is_delete|claim_delete_body_preview_is_delete|claim_delete_body_honesty_is_delete|claim_std_x_thin_is_physical_delete|claim_std_x_catalog_is_physical_delete|claim_std_x_force_thin_is_physical_delete|claim_formal_mod_catalog_is_physical_delete|claim_formal_mod_force_thin_is_physical_delete|claim_std_and_panic_list_mk_is_physical_delete|claim_driver_leaf_catalog_is_physical_delete|claim_driver_leaf_force_thin_is_physical_delete|claim_gen_c_force_thin_is_physical_delete|claim_ast_gen2_force_thin_is_physical_delete|claim_src_edge_force_thin_is_physical_delete|claim_migrate_x_force_thin_is_physical_delete|claim_glue_types_force_thin_is_physical_delete|claim_bootstrap_pipeline_force_thin_is_physical_delete|claim_arch_host_pick_phony_is_physical_delete|claim_driver_subcmd_list_mk_is_physical_delete|claim_pipeline_x_list_mk_is_physical_delete|claim_seed_mode_list_mk_is_physical_delete|claim_seed_link_picks_list_mk_is_physical_delete|claim_objs_core_list_mk_is_physical_delete|claim_arch_experiment_list_mk_is_physical_delete|claim_relink_legacy_list_mk_is_physical_delete|claim_source_deps_list_mk_is_physical_delete|claim_e_dirs_list_mk_is_physical_delete|rm_makefile_without_confirm_delete_body
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


# wave815: archaeology host-pick phonies — ensure thin on catalog keys + script --check.
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
# Keys from catalog `list` only (G.7: residual shell must not hardcode phony inventory).
while IFS= read -r _ahp; do
  [ -n "$_ahp" ] || continue
  if awk -v phony="$_ahp" '
    $0 ~ ("^" phony ":") { want=1; next }
    want && /archaeology_host_pick_phony\.sh ensure/ { ok=1; exit }
    want && /^\t/ { next }
    want && /^[^#\t]/ && $0 !~ /^$/ { exit }
    END { exit ok ? 0 : 1 }
  ' "$MF"; then
    _ahp_thin=$((_ahp_thin + 1))
  else
    bad "Makefile $_ahp must thin-call archaeology_host_pick_phony ensure (wave815)"
  fi
done < <(bash "$_ahp_sh" list 2>/dev/null || true)
if [ "$_ahp_thin" -ne 4 ]; then
  bad "wave815 expected 4 archaeology host-pick ensure phonies, got $_ahp_thin"
fi
note "Makefile archaeology 4 phonies thin-call ensure (wave815; not physical delete)"
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

# wave785: B7c archaeology thin — bootstrap-typeck/codegen use migrate; bootstrap-self no dual lsp $(CC) -c
# (message strings avoid product path tokens that trip G.7 self hardcode scan)
if [ -f "$MF" ]; then
  if ! grep -A12 '^bootstrap-typeck:' "$MF" | grep -q 'migrate_x_objs\.sh'; then
    bad "bootstrap-typeck must thin migrate leaf via migrate_x_objs.sh (wave785 B7c)"
  else
    note "bootstrap-typeck → migrate_x_objs (wave785 B7c)"
  fi
  if ! grep -A20 '^bootstrap-codegen:' "$MF" | grep -q 'migrate_x_objs\.sh'; then
    bad "bootstrap-codegen must thin migrate leaves via migrate_x_objs.sh (wave785 B7c)"
  else
    note "bootstrap-codegen → migrate_x_objs (wave785 B7c)"
  fi
  if grep -A8 '^bootstrap-self:' "$MF" | grep -qE '\$\(CC\).*-c lsp_'; then
    bad "bootstrap-self must not dual \$(CC) -c on lsp gens (wave785 B7c; use thin leaves)"
  else
    note "bootstrap-self uses thin lsp leaves (wave785 B7c)"
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
  # residual honesty: bootstrap-x-compiler still has archaeology stage2 $(CC) -c
  if ! grep -A8 '^bootstrap-x-compiler:' "$MF" | grep -qE '\$\(CC\).*-c typeck_x_x'; then
    note "bootstrap-x-compiler archaeology -c residual cleared (unexpected early)"
  else
    note "bootstrap-x-compiler archaeology \$(CC) -c residual kept (B7C honesty)"
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
echo "leaf_pattern_residual: CHECK OK (wave747–834: leaf residual + phys-del harness + TREE_ARMED + delete-body honesty + wave811 std_x thin 22 + wave825 std_x ensure catalog 22 + wave827 std_x FORCE dep-thin 22 + wave812 formal_mod ensure 38 + wave826 formal_mod FORCE dep-thin 38 + wave813 STD_AND_PANIC list→mk + wave814 driver_leaf ensure 8 + wave828 driver_leaf FORCE dep-thin 8 + wave829 gen.c FORCE dep-thin 17 + wave830 ast_gen2 FORCE dep-thin 1 + wave831 src-edge FORCE dep-thin 7 + wave832 migrate companion FORCE dep-thin 3 + wave833 pipeline_glue_types FORCE dep-thin 1 + wave834 bootstrap-pipeline FORCE shell-primary 1 + wave815 archaeology host-pick phonies 4 + wave816 DRIVER_SUBCMD list→mk 7 + wave817 PIPELINE_X list→mk satellite 9 + wave818 SEED_MODE list→mk SUPPORT_EXTRA 3 + wave819 SEED_LINK_PICKS list→mk GLUE 2 + wave820 OBJS_CORE list→mk 16 + wave821 ARCH_EXPERIMENT list→mk 7 + wave822 RELINK/LEGACY list→composites 14 + wave823 SOURCE_DEPS list→mk 19 + wave824 E_DIRS list→mk 26; Makefile still present; delete body deferred)"
exit 0
