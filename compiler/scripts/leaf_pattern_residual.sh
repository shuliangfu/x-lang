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
# Wave: 746–779 Track MG · 11.3.1 path (B1 body swallow wave779 · not physical delete · Windows gate + dual-end).

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
RESIDUAL_CLASS_R5_ENDGAME=xbuild_compiler_all_shell_body_stage12

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
# B2: product std/core modules with inline host-cc hybrid
PHYS_DEL_BUCKET_B2=std_core_product_hybrid
PHYS_DEL_BUCKET_B2_SCOPE=std_process_path_runtime_net_core_slice
PHYS_DEL_BUCKET_B2_HEAT_TARGETS=5
# B3: LSP satellite hybrid leaves outside try-other-l2-prefer / try-ldpc
PHYS_DEL_BUCKET_B3=lsp_satellite_hybrid
PHYS_DEL_BUCKET_B3_SCOPE=lsp_diag_pipeline_sizes_nostub+lsp_diag_stubs_no_c
PHYS_DEL_BUCKET_B3_HEAT_TARGETS=2
# B4: gen.c → .o bootstrap / stage stubs (not try-gen-x catalog)
PHYS_DEL_BUCKET_B4=gen_c_to_o_bootstrap
PHYS_DEL_BUCKET_B4_SCOPE=lexer_x+ast_gen2+driver_x+preprocess_x+_x_stubs2
PHYS_DEL_BUCKET_B4_HEAT_TARGETS=5
# B5: multi-ladder / one-off (cfg_eval)
PHYS_DEL_BUCKET_B5=cfg_eval_multi_ladder
PHYS_DEL_BUCKET_B5_SCOPE=src_lexer_cfg_eval_o
PHYS_DEL_BUCKET_B5_HEAT_TARGETS=1
# B6: R5 CI / compiler-all host-cc graph (orchestration residual)
PHYS_DEL_BUCKET_B6=r5_ci_compiler_all
PHYS_DEL_BUCKET_B6_SCOPE=Makefile_all_OPT_seed_xbuild_compiler_all
# B7: Makefile still owns DAG thin-calls + lists (cannot delete until B2–B6 + BC)
PHYS_DEL_BUCKET_B7=makefile_dag_thin_calls
PHYS_DEL_BUCKET_B7_SCOPE=ensure_thin_call_targets_plus_mk_lists
PHYS_DEL_PREP_NEXT=B2_std_core_product_hybrid_body_swallow_not_delete
PHYS_DEL_PREP_FORBIDDEN=claim_physical_delete|dual_o_list_as_authority|delete_makefile_before_windows_green
# wave778: hard gate — physical delete of compiler/Makefile only AFTER Windows
# hybrid min-gate green (+ PE pure-ld residual owned). Body swallow (B1–B5) keeps
# Makefile thin-call edges; it is NOT physical delete. Never rm Makefile casually.
PHYS_DEL_WINDOWS_GATE=required_before_makefile_delete
PHYS_DEL_WINDOWS_GATE_SCOPE=MSYS2_B_hybrid_min_gate_plus_PE_pure_ld_residual
PHYS_DEL_WINDOWS_GATE_STATUS=not_reproven_this_tip
PHYS_DEL_WINDOWS_GATE_DOC=analysis/Windows兼容时序-删种子前后.md
PHYS_DEL_WINDOWS_GATE_FORBIDDEN=physical_delete_makefile_before_windows_green
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
    cc_c=$(grep -cE '\$\(CC\).*-c' "$mf" 2>/dev/null || echo 0)
    uname_n=$(grep -cE 'UNAME_[SM]|\$\(UNAME_' "$mf" 2>/dev/null || echo 0)
  fi
  # rebuild_leaves modes: catalog_key= table entries (wave747)
  if [ -f "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" ]; then
    rebuild_modes=$(grep -cE 'catalog_key=' "$ROOT/compiler/scripts/bootstrap_driver_seed_rebuild_leaves.sh" 2>/dev/null || echo 0)
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
ENDGAME_PHYSICAL_DELETE_MAKEFILE=0
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
  if ! grep -qE 'MG_VERIFY_DUAL_END|mac_plus_ubuntu|dual.end|双端' "$DOC_REL"; then
    bad "$DOC_REL must document wave778 dual-end mac+Ubuntu verify policy"
  fi
  if ! grep -qE 'wave779|try-runtime-os-prefer|B1.*runtime.*prefer|runtime_os.*prefer' "$DOC_REL"; then
    bad "$DOC_REL must document wave779 B1 try-runtime-os-prefer body swallow"
  fi
  note "doc $DOC_REL present"
fi

if [ ! -f "$SCRIPT_REL" ]; then
  bad "missing $SCRIPT_REL"
fi

# Live dump must name residual classes + endgame flags
_out="$(bash "$SCRIPT_REL" dump 2>/dev/null || true)"
if ! printf '%s\n' "$_out" | grep -q 'RESIDUAL_CLASS_R1=host_cc_seed_from_x_to_o'; then
  bad "dump missing RESIDUAL_CLASS_R1"
fi
if ! printf '%s\n' "$_out" | grep -q 'RESIDUAL_CLASS_R4=cold_rebuild_pattern_bodies'; then
  bad "dump missing RESIDUAL_CLASS_R4"
fi
if ! printf '%s\n' "$_out" | grep -qE 'RESIDUAL_CLASS_R6=cold_link_(seed_link_cc|pure_ld_prefer)'; then
  bad "dump missing RESIDUAL_CLASS_R6 (cross-ref 11.1.4)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R6_PURE_LD=1'; then
  bad "dump must set SWALLOWED_R6_PURE_LD=1 (wave772 pure-ld)"
fi
if ! printf '%s\n' "$_out" | grep -q 'ENDGAME_COLD_PURE_LD=1'; then
  bad "dump ENDGAME_COLD_PURE_LD must be 1 (wave772)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_PURE_LD=1'; then
  bad "dump must set SWALLOWED_G05_PURE_LD=1 (wave773 g05 pure-ld)"
fi
if ! printf '%s\n' "$_out" | grep -q 'ENDGAME_G05_PURE_LD=1'; then
  bad "dump ENDGAME_G05_PURE_LD must be 1 (wave773)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_DROP_CC_FALLBACK=1'; then
  bad "dump must set SWALLOWED_DROP_CC_FALLBACK=1 (wave774)"
fi
if ! printf '%s\n' "$_out" | grep -q 'ENDGAME_DROP_CC_FALLBACK=1'; then
  bad "dump ENDGAME_DROP_CC_FALLBACK must be 1 (wave774)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_PREREQ_EDGES=scripts/driver_seed_ensure_prereqs.sh'; then
  bad "dump must name swallowed prereq edges (wave744)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R4_MODE_POLICY=1'; then
  bad "dump must set SWALLOWED_R4_MODE_POLICY=1 (wave747)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R4_MODE_POLICY_SWALLOWED=1'; then
  bad "dump R4_MODE_POLICY_SWALLOWED must be 1 (rebuild_leaves uses catalog)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R4_PATTERN_BODY_STILL_MAKE=1'; then
  bad "dump must keep R4_PATTERN_BODY_STILL_MAKE=1 (honest non-R1 residual)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R4_BODY_PURE_R1=1'; then
  bad "dump must set SWALLOWED_R4_BODY_PURE_R1=1 (wave756)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R4_BODY_PURE_R1_SWALLOWED=1'; then
  bad "dump R4_BODY_PURE_R1_SWALLOWED must be 1 (wave756 try-r1)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R4_BODY_THIN_GLUE=1'; then
  bad "dump must set SWALLOWED_R4_BODY_THIN_GLUE=1 (wave758 thin_glue seed-map)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R4_BODY_GLUE_STANDALONE=1'; then
  bad "dump must set SWALLOWED_R4_BODY_GLUE_STANDALONE=1 (wave759 glue standalone seed-map)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R2_PANIC_COLD=1'; then
  bad "dump must set SWALLOWED_R2_PANIC_COLD=1 (wave760 R2 panic cold try-r2)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R2_PANIC_COLD_SWALLOWED=1'; then
  bad "dump R2_PANIC_COLD_SWALLOWED must be 1 (try-r2 + catalog)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R2_PANIC_PREFER=1'; then
  bad "dump must set SWALLOWED_R2_PANIC_PREFER=1 (wave776 R2 panic PREFER try-r2-prefer)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R2_PANIC_PREFER_SWALLOWED=1'; then
  bad "dump R2_PANIC_PREFER_SWALLOWED must be 1 (try-r2-prefer + Makefile thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R2_TYPECK_F64=1'; then
  bad "dump must set SWALLOWED_R2_TYPECK_F64=1 (wave762)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R2_TYPECK_F64_SWALLOWED=1'; then
  bad "dump R2_TYPECK_F64_SWALLOWED must be 1 (wave762)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R2_CRT0=1'; then
  bad "dump must set SWALLOWED_R2_CRT0=1 (wave762)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R2_CRT0_SWALLOWED=1'; then
  bad "dump R2_CRT0_SWALLOWED must be 1 (wave762)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R4_BODY_GEN_X=1'; then
  bad "dump must set SWALLOWED_R4_BODY_GEN_X=1 (wave761 gen/pipeline try-gen-x)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R4_BODY_GEN_X_SWALLOWED=1'; then
  bad "dump R4_BODY_GEN_X_SWALLOWED must be 1 (wave761 try-gen-x)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_RT_SEED_SLICE=1'; then
  bad "dump must set SWALLOWED_R1_RT_SEED_SLICE=1 (wave748)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_RT_SEED_SLICE_SWALLOWED=1'; then
  bad "dump R1_RT_SEED_SLICE_SWALLOWED must be 1 (ensure body + thin Makefile)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_CORE_SEED=1'; then
  bad "dump must set SWALLOWED_R1_CORE_SEED=1 (wave749)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_CORE_SEED_SWALLOWED=1'; then
  bad "dump R1_CORE_SEED_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_FRONTEND_GLUE=1'; then
  bad "dump must set SWALLOWED_R1_FRONTEND_GLUE=1 (wave750)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_FRONTEND_GLUE_SWALLOWED=1'; then
  bad "dump R1_FRONTEND_GLUE_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_MAIN_RUNTIME=1'; then
  bad "dump must set SWALLOWED_R1_MAIN_RUNTIME=1 (wave751)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_MAIN_RUNTIME_SWALLOWED=1'; then
  bad "dump R1_MAIN_RUNTIME_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_ALIAS_STUBS=1'; then
  bad "dump must set SWALLOWED_R1_ALIAS_STUBS=1 (wave752)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_ALIAS_STUBS_SWALLOWED=1'; then
  bad "dump R1_ALIAS_STUBS_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_EXTRA_CFLAGS=1'; then
  bad "dump must set SWALLOWED_R1_EXTRA_CFLAGS=1 (wave753)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_EXTRA_CFLAGS_SWALLOWED=1'; then
  bad "dump R1_EXTRA_CFLAGS_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_MISC_BASENAME=1'; then
  bad "dump must set SWALLOWED_R1_MISC_BASENAME=1 (wave754)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_MISC_BASENAME_SWALLOWED=1'; then
  bad "dump R1_MISC_BASENAME_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R1_SEED_MAP=1'; then
  bad "dump must set SWALLOWED_R1_SEED_MAP=1 (wave755)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_SEED_MAP_SWALLOWED=1'; then
  bad "dump R1_SEED_MAP_SWALLOWED must be 1 (ensure body + catalog + thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R3_COLD_ELSE=1'; then
  bad "dump must set SWALLOWED_R3_COLD_ELSE=1 (wave757)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R3_COLD_ELSE_SWALLOWED=1'; then
  bad "dump R3_COLD_ELSE_SWALLOWED must be 1 (try-r3-cold + catalog)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_R3_PREFER_THIN=1'; then
  bad "dump must set SWALLOWED_R3_PREFER_THIN=1 (wave763)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R3_PREFER_THIN_SWALLOWED=1'; then
  bad "dump R3_PREFER_THIN_SWALLOWED must be 1 (try-r3-prefer + Makefile thin)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_R3_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_R3_PREFER=1 (wave764)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_R3_PREFER_SWALLOWED=1'; then
  bad "dump G05_R3_PREFER_SWALLOWED must be 1 (g05 r3-prefer-family + full ladder)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_LABI_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_LABI_PREFER=1 (wave765)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_LABI_PREFER_SWALLOWED=1'; then
  bad "dump G05_LABI_PREFER_SWALLOWED must be 1 (try-labi-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_RT_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_RT_PREFER=1 (wave766)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_RT_PREFER_SWALLOWED=1'; then
  bad "dump G05_RT_PREFER_SWALLOWED must be 1 (try-rt-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_PIPELINE_ABI_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_PIPELINE_ABI_PREFER=1 (wave767)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_PIPELINE_ABI_PREFER_SWALLOWED=1'; then
  bad "dump G05_PIPELINE_ABI_PREFER_SWALLOWED must be 1 (try-pipeline-abi-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_LDPC_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_LDPC_PREFER=1 (wave767)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_LDPC_PREFER_SWALLOWED=1'; then
  bad "dump G05_LDPC_PREFER_SWALLOWED must be 1 (try-ldpc-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_TARGET_CPU_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_TARGET_CPU_PREFER=1 (wave768)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_TARGET_CPU_PREFER_SWALLOWED=1'; then
  bad "dump G05_TARGET_CPU_PREFER_SWALLOWED must be 1 (try-target-cpu-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_L2_ASM_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_L2_ASM_PREFER=1 (wave769)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_L2_ASM_PREFER_SWALLOWED=1'; then
  bad "dump G05_L2_ASM_PREFER_SWALLOWED must be 1 (try-l2-asm-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_ASYNC_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_ASYNC_PREFER=1 (wave770)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_ASYNC_PREFER_SWALLOWED=1'; then
  bad "dump G05_ASYNC_PREFER_SWALLOWED must be 1 (try-async-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_G05_OTHER_L2_PREFER=1'; then
  bad "dump must set SWALLOWED_G05_OTHER_L2_PREFER=1 (wave771)"
fi
if ! printf '%s\n' "$_out" | grep -q 'G05_OTHER_L2_PREFER_SWALLOWED=1'; then
  bad "dump G05_OTHER_L2_PREFER_SWALLOWED must be 1 (try-other-l2-prefer + g05 thin-call)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_FMT_CHECK_CMD_O_DUAL=1'; then
  bad "dump must set SWALLOWED_FMT_CHECK_CMD_O_DUAL=1 (wave775)"
fi
if ! printf '%s\n' "$_out" | grep -q 'R1_OTHER_HOST_CC_STILL_MAKE=1'; then
  bad "dump must keep R1_OTHER_HOST_CC_STILL_MAKE=1 (honest residual)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_PREP_INVENTORY=1'; then
  bad "dump must set PHYS_DEL_PREP_INVENTORY=1 (wave777 physical-delete prep)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B1='; then
  bad "dump must name PHYS_DEL_BUCKET_B1 (wave777 runtime OS hybrid)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B2='; then
  bad "dump must name PHYS_DEL_BUCKET_B2 (wave777 std/core product hybrid)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B3='; then
  bad "dump must name PHYS_DEL_BUCKET_B3 (wave777 lsp satellite)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B4='; then
  bad "dump must name PHYS_DEL_BUCKET_B4 (wave777 gen_c_to_o)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B5='; then
  bad "dump must name PHYS_DEL_BUCKET_B5 (wave777 cfg_eval ladder)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B6='; then
  bad "dump must name PHYS_DEL_BUCKET_B6 (wave777 R5 CI)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B7='; then
  bad "dump must name PHYS_DEL_BUCKET_B7 (wave777 makefile DAG)"
fi
if ! printf '%s\n' "$_out" | grep -q 'ENDGAME_PHYSICAL_DELETE_MAKEFILE=0'; then
  bad "dump missing ENDGAME_PHYSICAL_DELETE_MAKEFILE=0 (not closed)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_WINDOWS_GATE=required_before_makefile_delete'; then
  bad "dump must set PHYS_DEL_WINDOWS_GATE=required_before_makefile_delete (wave778)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_WINDOWS_GATE_FORBIDDEN=physical_delete_makefile_before_windows_green'; then
  bad "dump must forbid physical delete before Windows green (wave778)"
fi
if ! printf '%s\n' "$_out" | grep -q 'MG_VERIFY_DUAL_END=mac_plus_ubuntu_required'; then
  bad "dump must set MG_VERIFY_DUAL_END=mac_plus_ubuntu_required (wave778)"
fi
if ! printf '%s\n' "$_out" | grep -q 'MG_VERIFY_GOLD=ubuntu'; then
  bad "dump must set MG_VERIFY_GOLD=ubuntu (wave778)"
fi
if ! printf '%s\n' "$_out" | grep -q 'MG_VERIFY_FORBIDDEN=mac_only_claim_wave_green'; then
  bad "dump must forbid mac-only wave-green claims (wave778)"
fi
if ! printf '%s\n' "$_out" | grep -q 'SWALLOWED_B1_RUNTIME_OS_PREFER=1'; then
  bad "dump must set SWALLOWED_B1_RUNTIME_OS_PREFER=1 (wave779)"
fi
if ! printf '%s\n' "$_out" | grep -q 'B1_RUNTIME_OS_PREFER_SWALLOWED=1'; then
  bad "dump B1_RUNTIME_OS_PREFER_SWALLOWED must be 1 (wave779 try-runtime-os-prefer)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_BUCKET_B1_BODY_SWALLOWED=1'; then
  bad "dump must set PHYS_DEL_BUCKET_B1_BODY_SWALLOWED=1 (wave779)"
fi
if ! printf '%s\n' "$_out" | grep -q 'PHYS_DEL_PREP_NEXT=B2_std_core_product_hybrid_body_swallow_not_delete'; then
  bad "dump PHYS_DEL_PREP_NEXT must point to B2 after B1 swallow (wave779)"
else
  note "residual class inventory dump OK (wave747–779 + B1 swallow + Windows + dual-end)"
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
  compiler/scripts/ensure_host_cc_seed_o.sh
do
  if [ ! -f "$f" ]; then
    bad "missing swallowed/orchestration owner $f"
  fi
done
note "swallowed orchestration owners present"

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
if ! grep -q 'R1_CORE_SEED_OBJS' "$MF"; then
  bad "Makefile must define R1_CORE_SEED_OBJS (wave749 list authority)"
fi
if ! grep -q 'R1_FRONTEND_GLUE_OBJS' "$MF"; then
  bad "Makefile must define R1_FRONTEND_GLUE_OBJS (wave750 list authority)"
fi
if ! grep -q 'R1_MAIN_RUNTIME_OBJS' "$MF"; then
  bad "Makefile must define R1_MAIN_RUNTIME_OBJS (wave751 list authority)"
fi
if ! grep -q 'R1_ALIAS_STUBS_OBJS' "$MF"; then
  bad "Makefile must define R1_ALIAS_STUBS_OBJS (wave752 list authority)"
fi
if ! grep -q 'R1_EXTRA_CFLAGS_OBJS' "$MF"; then
  bad "Makefile must define R1_EXTRA_CFLAGS_OBJS (wave753 list authority)"
fi
if ! grep -q 'R1_MISC_BASENAME_OBJS' "$MF"; then
  bad "Makefile must define R1_MISC_BASENAME_OBJS (wave754 list authority)"
fi
if ! grep -q 'R1_SEED_MAP_OBJS' "$MF"; then
  bad "Makefile must define R1_SEED_MAP_OBJS (wave755 list authority)"
fi
if ! grep -q 'R3_COLD_SEED_OBJS' "$MF"; then
  bad "Makefile must define R3_COLD_SEED_OBJS (wave757 list authority)"
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
  note "R4 mode + pure-R1 try-r1 + R3 cold try-r3-cold + R2 panic/typeck_f64/crt0 try-r2; R3 PREFER thin try-r3-prefer (wave763) + g05 r3-prefer-family (wave764) + labi/rt/pipeline_abi/ldpc/target_cpu/l2-asm/async/other-l2 try-*-prefer (wave765–771); R6 pure-ld (wave772/773) + drop silent CC fallback (wave774); fmt_check_cmd.o dual (wave775); R2 panic PREFER try-r2-prefer (wave776); phys-del prep (wave777); Windows+dual-end gate (wave778); B1 runtime-os try-runtime-os-prefer (wave779); residual B2–B5 swallow body + R5 + physical delete"
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
echo "leaf_pattern_residual: CHECK OK (wave747 R4 mode + wave756 pure-R1 + wave757 R3 cold-else + wave763 R3 PREFER thin + wave764 g05 r3-prefer-family + wave765 labi try-labi-prefer + wave758 thin_glue + wave759 glue-standalone + wave760 R2 panic + wave761 gen-x + wave762 R2 typeck_f64/crt0 + wave748–755 R1 families + 11.3.1 leaf residual inventory)"
exit 0
