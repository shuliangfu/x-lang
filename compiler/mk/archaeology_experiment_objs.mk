# archaeology_experiment_objs.mk — wave821 · 11.3.1 B7B
#
# Single-authority lists for archaeology / experiment host-cc link inventories:
#   DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS
#     — stage 10.4 experiment: chain typeck_x.o/codegen_x.o instead of C frontend
#       (no pipeline_x.o; no XLANG_USE_X_PIPELINE). Fixed 7 .o multi-token list.
#   DRIVER_NO_C_FRONTEND_OBJS
#     — xlang-no-c-frontend experiment: no C lexer/parser/typeck/codegen; expands
#       $(MAIN_LINK_O) / $(PREPROCESS_LINK_O) / $(AST_LINK_O) + fixed runtime picks.
#
# Used by:
#   - compiler/Makefile thin-call → bootstrap_driver_seed_x_frontend.sh (wave848)
#     · xlang_no_c_frontend.sh (wave847) — lists still expanded from this mk
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell must not hardcode a second copy of these lists.
#
# wave821: moved out of compiler/Makefile inline body (list residual of
# b7b_lists_in_mk). NOT physical delete — thin edges + other mk lists +
# std_core product make graph still residual.
#
# wave851: XLANG_NO_C_FRONTEND_LINK_OBJS — full host-cc link bag for
# xlang-no-c-frontend (base experiment list + driver/pipeline/lsp satellites).
# G.7 有则补全; Makefile expands $(XLANG_NO_C_FRONTEND_LINK_OBJS) only.
# NOT physical delete — thin edges + B2 + other mk lists remain residual.
#
# Requires (for DRIVER_NO_C_FRONTEND_OBJS expansion):
#   MAIN_LINK_O, PREPROCESS_LINK_O, AST_LINK_O
#   (from mk/driver_seed_link_picks.mk — include this mk after link_picks)
# Full link bag also expands DRIVER_SUBCMD_OBJS / PIPELINE_LIBS at recipe time
# (recursive make OK; subcmd/pipeline mk may be included later).
#
# PLATFORM: SHARED — leaf basenames are host-portable.
# Do NOT reuse DRIVER_SEED_X_FRONTEND_OBJS name: product seed link depends on
# parser_x.o/lexer_x.o (composites); experiment list is a separate inventory.

# Stage 10.4 experiment inventory (typeck_x/codegen_x replace C frontend pieces).
# COUNT authority = 7 multi-token .o (fixed; no host branch).
DRIVER_SEED_X_FRONTEND_EXPERIMENT_OBJS = src/main_driver.o src/runtime_driver.o src/diag.o src/lexer/lexer.o src/ast/ast_seed.o typeck_x.o codegen_x.o

# Experiment: no C lexer/parser/typeck/codegen in the closure; product seed
# driver_x/pipeline_x still expected present as separate prereqs on the phony.
DRIVER_NO_C_FRONTEND_OBJS = $(MAIN_LINK_O) src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/diag.o src/runtime_pipeline_abi.o src/runtime_driver_no_c.o $(PREPROCESS_LINK_O) $(AST_LINK_O) src/typeck/typeck_f64_bits.o

# wave851 B7B: full host-cc link bag for xlang-no-c-frontend (G.7 有则补全).
# Weak sizes.o + stubs_no_c (not nostub+ctx product path). Makefile thin-call
# must not re-list this inventory inline (dual authority with this mk).
# Fixed multi-token authority COUNT=9 (non-$(...) path tokens):
#   driver_x.o pipeline_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o
#   src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_stubs_no_c.o
#   lsp_io_std_heap_x.o
# Consumer: XNC_LINK_OBJS (make xlang-no-c-frontend → xlang_no_c_frontend.sh).
# PLATFORM: SHARED — leaf basenames host-portable; PIPELINE_LIBS host-filtered.
XLANG_NO_C_FRONTEND_LINK_OBJS = $(DRIVER_NO_C_FRONTEND_OBJS) driver_x.o pipeline_x.o lsp_x.o lsp_diag_x.o lsp_io_x.o preprocess_x.o $(DRIVER_SUBCMD_OBJS) src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_stubs_no_c.o lsp_io_std_heap_x.o $(PIPELINE_LIBS)
