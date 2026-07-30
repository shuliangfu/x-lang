# driver_seed_composites.mk — wave728 · 11.0.4 · wave822 B7B 有则补全
#
# Single-authority *composite* object lists for bootstrap-driver-seed /
# phase1 / final / relink (not the §5b leaf rebuild lists — those live in
# driver_seed_export_lists.mk).
#
# Requires (defined earlier in Makefile or user_asm_seed_objs.mk):
#   MAIN_LINK_O, MAIN_LINK_REBUILD, DRIVER_SEED_RUNTIME_O, RT_SEED_SLICE_OBJS,
#   PREPROCESS_LINK_O, LEXER_LINK_O, AST_LINK_O, DRIVER_SEED_FRONTEND_EXTRA,
#   DRIVER_SEED_SUPPORT_EXTRA, DRIVER_SUBCMD_OBJS, DRIVER_SUBCMD_GEN,
#   LSP_DIAG_LINK_O, PIPELINE_LIBS, BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O,
#   USER_ASM_SEED_OBJS, USER_ASM_SEED_HOST_OBJS, USER_ASM_SEED_HOST_STUBS,
#   BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS, RELINK_XLANG_FILTERED_OBJS,
#   RELINK_XLANG_PIPELINE_LINK_O, XLANG_C
#
# G.7: Definitions live only here. Makefile must include, not re-assign.
# Shell / xbuild consume via driver_seed_obj_catalog.sh (wave788 shell primary).
#
# wave822: LEGACY_XLANG_C_* + RELINK_XLANG_PREREQS moved from Makefile inline
# (list residual of b7b_lists_in_mk). NOT physical delete — thin edges + other
# mk lists + std_core product make graph still residual.
#
# wave850: RELINK_PRODUCT_LINK_BASE/OBJS — product archaeology full link bag
# (bootstrap-typeck|codegen BTC_OBJS + relink-xlang-lexer RXL_LINK_OBJS were
# the same 3-way dual inventory in Makefile thin-call exports). G.7 有则补全
# into this file; Makefile consumers expand $(RELINK_PRODUCT_LINK_OBJS) only.
# NOT physical delete — thin edges + B2 + other mk lists remain residual.
#
# wave851: XLANG_X_LINK_BASE/OBJS + BOOTSTRAP_SELF_LINK_OBJS — remaining
# product-shaped archaeology full link bags (xlang-x XXL + bootstrap-self BS
# stage2). G.7 有则补全; Makefile expand $(XLANG_X_LINK_OBJS) /
# $(BOOTSTRAP_SELF_LINK_OBJS) only. XNC full bag lives in
# archaeology_experiment_objs.mk (same wave). NOT physical delete.
#
# wave853: BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS + FINAL_LINK_OBJS — daily
# product seed phase1/final full host-cc link bags (export SEED_LINK_OBJS).
# G.7 有则补全; Makefile expand the two vars only (no dual re-list of
# LINK_BASE + user-asm + glue). Glue suffix is RELINK_XLANG_GLUE_SUFFIX
# (strict_minimal + stubs) — same as historic target-specific override on
# phase1/final export leaves. NOT physical delete.
#
# PLATFORM: SHARED — composite paths under compiler/; host-filtered pieces
# come from already-resolved vars (Darwin filtered pipeline, etc.).

# Frontend .x objs (parser/typeck/codegen) + lexer alias bundle for seed link.
DRIVER_SEED_X_OBJS = parser_x.o typeck_x.o codegen_x.o
DRIVER_SEED_X_FRONTEND_OBJS = lexer_x.o $(DRIVER_SEED_X_OBJS) x_frontend_link_alias.o

# PLATFORM: SHARED — process_xlang_argc/argv_get authority is runtime_process_argv.o;
# PREFER thin process_args_* and std/process depend on it; phase1/final seed link
# must include it explicitly in the closure.
DRIVER_SEED_OBJS = $(MAIN_LINK_O) src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_O) $(RT_SEED_SLICE_OBJS) runtime_process_argv.o src/driver/fmt_check_cmd_driver.o src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o $(PREPROCESS_LINK_O) $(LEXER_LINK_O) $(AST_LINK_O) $(DRIVER_SEED_X_FRONTEND_OBJS) $(DRIVER_SEED_FRONTEND_EXTRA) $(DRIVER_SEED_SUPPORT_EXTRA) src/x_seed_bridge.o src/seed_link_compat.o

# Link base for daily product-shaped seed (pipeline_x.o always) and bootstrap
# Darwin-filtered pipeline (BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O).
DRIVER_SEED_LINK_BASE = $(DRIVER_SEED_OBJS) driver_x.o pipeline_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS)
BOOTSTRAP_DRIVER_SEED_LINK_BASE = $(DRIVER_SEED_OBJS) driver_x.o $(BOOTSTRAP_DRIVER_SEED_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS)

# Prerequisites for bootstrap-driver-seed orchestration (objs + gen sources).
# lsp_io_std_heap: Track L retired — product chain only needs lsp_io_std_heap_x.o.
DRIVER_SEED_PREREQS = $(XLANG_C) pipeline_x.o parser_x.o lexer_x.o typeck_x.o codegen_x.o x_frontend_link_alias.o driver_x.o preprocess_x.o lsp_io_gen.c lsp_gen.c lsp_diag_gen.c $(DRIVER_SUBCMD_GEN) $(MAIN_LINK_REBUILD) src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_O) $(RT_SEED_SLICE_OBJS) runtime_process_argv.o src/driver/fmt_check_cmd_driver.o $(PREPROCESS_LINK_O) $(LEXER_LINK_O) $(AST_LINK_O) $(DRIVER_SEED_FRONTEND_EXTRA) $(DRIVER_SEED_SUPPORT_EXTRA) src/x_seed_bridge.o src/seed_link_compat.o src/runtime_driver_strict_glue_stubs.o $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(DRIVER_SUBCMD_OBJS) $(USER_ASM_SEED_OBJS)

# wave822 B7B: legacy xlang-c reuses bootstrap-driver-seed closure (no second hand
# inventory). LINK_BASE / USER_ASM_LINK / PREREQS expand composites + fixed glue.
# COUNT authority for residual honesty = RELINK_XLANG_PREREQS fixed multi-token
# inventory (14 non-$(...) tokens; 13 path .o/.c + build-seed-asm-host phony).
LEGACY_XLANG_C_LINK_BASE := $(BOOTSTRAP_DRIVER_SEED_LINK_BASE)
LEGACY_XLANG_C_USER_ASM_LINK := $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS)
LEGACY_XLANG_C_PREREQS := $(LEGACY_XLANG_C_LINK_BASE) $(LEGACY_XLANG_C_USER_ASM_LINK) build_asm/pipeline_glue_strict_minimal.o src/runtime_driver_strict_glue_stubs.o ast_gen2.o

# Relink / archaeology bootstrap-typeck|codegen prereq closure — same object set
# as bootstrap-driver-seed link (plus gen sources + asm-host). Product daily
# relink-xlang is g05 (wave786); this list remains inventory + late consumers.
# Fixed multi-token authority surface COUNT=14 (see residual wave822).
RELINK_XLANG_PREREQS = build-seed-asm-host $(RELINK_XLANG_FILTERED_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(DRIVER_SUBCMD_GEN) \
  $(DRIVER_SEED_OBJS) driver_x.o pipeline_x.o $(RELINK_XLANG_PIPELINE_LINK_O) \
  lsp_io_gen.c lsp_gen.c lsp_diag_gen.c lsp_io_std_heap_gen.c \
  lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o \
  $(DRIVER_SUBCMD_OBJS) \
  $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o \
  src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o

# wave850 B7B: product archaeology full host-cc link bag (G.7 有则补全).
# Mirrors DRIVER_SEED_LINK_BASE shape but uses RELINK_XLANG_PIPELINE_LINK_O
# (Darwin filtered pipeline) + glue prefix/suffix + RELINK user-asm link.
# Fixed multi-token authority COUNT=8 on LINK_BASE (non-$(...) path tokens):
#   driver_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o
#   src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o
#   lsp_io_std_heap_x.o
# Consumers: BTC_OBJS (typeck/codegen) + RXL_LINK_OBJS (relink-xlang-lexer).
# PLATFORM: SHARED — pipeline pick from user_asm_seed_objs.mk (Darwin filtered).
RELINK_PRODUCT_LINK_BASE = $(DRIVER_SEED_OBJS) driver_x.o $(RELINK_XLANG_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o $(PIPELINE_LIBS)
RELINK_PRODUCT_LINK_OBJS = $(DRIVER_SEED_GLUE_PREFIX) $(RELINK_PRODUCT_LINK_BASE) $(RELINK_XLANG_USER_ASM_LINK) $(RELINK_XLANG_GLUE_SUFFIX)

# wave851 B7B: xlang-x product archaeology full host-cc link bag (G.7 有则补全).
# Shape is DRIVER_SEED_LINK_BASE-like but uses XLANG_X_PIPELINE_LINK_O (Darwin
# filtered) and does NOT include PIPELINE_LIBS (historic xlang-x link line).
# User-asm = HOST_OBJS + HOST_STUBS + XLANG_X_USER_ASM_OBJS + RELINK glue suffix.
# Fixed multi-token authority COUNT=8 on LINK_BASE (non-$(...) path tokens):
#   driver_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o
#   src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o
#   lsp_io_std_heap_x.o
# Consumer: XXL_LINK_OBJS (make xlang-x → xlang_x.sh).
# PLATFORM: SHARED — XLANG_X picks from user_asm_seed_objs.mk (Darwin filtered).
XLANG_X_LINK_BASE = $(DRIVER_SEED_OBJS) driver_x.o $(XLANG_X_PIPELINE_LINK_O) lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) $(LSP_DIAG_LINK_O) src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_pipeline_ctx.o lsp_io_std_heap_x.o
XLANG_X_LINK_OBJS = $(XLANG_X_LINK_BASE) $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(XLANG_X_USER_ASM_OBJS) $(RELINK_XLANG_GLUE_SUFFIX)

# wave851 B7B: bootstrap-self stage2 host-cc link bag (G.7 有则补全).
# Product daily seed link base + USER_ASM_LINK — no dual re-list of the
# DRIVER_SEED_LINK_BASE multi-token inventory in Makefile thin-call exports.
# Honesty: expands DRIVER_SEED_LINK_BASE (fixed multi-token COUNT=9 on that var:
#   driver_x.o pipeline_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o
#   sizes_nostub.o ctx.o lsp_io_std_heap_x.o).
# Consumer: BS_LINK_OBJS (make bootstrap-self → bootstrap_self.sh).
# PLATFORM: SHARED — USER_ASM_LINK from user_asm_seed_objs.mk.
BOOTSTRAP_SELF_LINK_OBJS = $(DRIVER_SEED_LINK_BASE) $(USER_ASM_LINK)

# wave853 B7B: daily product seed phase1 + final full host-cc link bags (G.7).
# Both expand BOOTSTRAP_DRIVER_SEED_LINK_BASE (Darwin-filtered pipeline pick)
# + glue prefix + RELINK_XLANG_GLUE_SUFFIX (strict_minimal + stubs at link END).
# Phase1 uses HOST_STUBS + partial host asm (not full HOST_OBJS) + filtered
# user-asm; final uses HOST_OBJS + HOST_STUBS + filtered user-asm.
# Honesty COUNT=2 bags (phase1 + final). Phase1 alone has one fixed multi-token
# path (seed_host partial); final is all $(...) expands.
# Consumers: SEED_LINK_OBJS on bootstrap-driver-seed-export-{phase1,final}-link.
# PLATFORM: SHARED — HOST/filtered picks from user_asm_seed_objs.mk.
BOOTSTRAP_DRIVER_SEED_PHASE1_LINK_OBJS = $(DRIVER_SEED_GLUE_PREFIX) $(BOOTSTRAP_DRIVER_SEED_LINK_BASE) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS) $(USER_ASM_SEED_HOST_STUBS) build_asm/seed_host/asm_backend_partial.o $(RELINK_XLANG_GLUE_SUFFIX)
BOOTSTRAP_DRIVER_SEED_FINAL_LINK_OBJS = $(DRIVER_SEED_GLUE_PREFIX) $(BOOTSTRAP_DRIVER_SEED_LINK_BASE) $(USER_ASM_SEED_HOST_OBJS) $(USER_ASM_SEED_HOST_STUBS) $(BOOTSTRAP_DRIVER_SEED_USER_ASM_OBJS) $(RELINK_XLANG_GLUE_SUFFIX)

# wave854 B7B: product archaeology seed-gate REQUIRED_OBJS bags (G.7 有则补全).
# Pre-link existence gates for shell-primary product archaeology targets.
# Makefile thin-call must not re-list these inventories inline (dual authority).
# Honesty COUNT=3 bags total with XNC in archaeology_experiment_objs.mk.
# Fixed multi-token authority (all path tokens; no $(...) expand):
#   RELINK_XLANG_REQUIRED_OBJS COUNT=6 (RXL relink-xlang-lexer seed gate)
#   XLANG_X_REQUIRED_OBJS      COUNT=12 (XXL xlang-x seed gate)
# wave855: shell consumers load these keys from this mk (relink_xlang_lexer.sh /
#   xlang_x.sh); Makefile must not re-export multi-token REQUIRED env.
# PLATFORM: SHARED — leaf basenames host-portable.
RELINK_XLANG_REQUIRED_OBJS = build_asm/seed_host/asm_backend_partial.o driver_x.o pipeline_x.o parser_x.o typeck_x.o codegen_x.o
XLANG_X_REQUIRED_OBJS = driver_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o lsp_io_std_heap_x.o driver_fmt_x.o driver_check_x.o driver_test_x.o driver_compile_x.o driver_build_x.o driver_run_x.o
