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
#   - compiler/Makefile: bootstrap-driver-seed-x-frontend · xlang-no-c-frontend
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell must not hardcode a second copy of these lists.
#
# wave821: moved out of compiler/Makefile inline body (list residual of
# b7b_lists_in_mk). NOT physical delete — thin edges + other mk lists +
# std_core product make graph still residual.
#
# Requires (for DRIVER_NO_C_FRONTEND_OBJS expansion):
#   MAIN_LINK_O, PREPROCESS_LINK_O, AST_LINK_O
#   (from mk/driver_seed_link_picks.mk — include this mk after link_picks)
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
