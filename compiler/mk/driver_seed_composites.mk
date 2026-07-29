# driver_seed_composites.mk — wave728 · 11.0.4
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
#   USER_ASM_SEED_OBJS, XLANG_C
#
# G.7: Definitions live only here. Makefile must include, not re-assign.
# Shell / xbuild consume via driver_seed_obj_catalog.sh (wave788 shell primary).
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
