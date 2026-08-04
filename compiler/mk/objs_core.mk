# objs_core.mk — wave820 · 11.3.1 B7B
#
# Single-authority lists for archaeology / host-cc incomplete core object sets:
#   OBJS_CORE  — product no_c incomplete inventory (16 .o) vs LEGACY C-frontend
#   OBJS       — alias $(OBJS_CORE) for $(TARGET) archaeology escape consumers
#
# Used by:
#   - compiler/Makefile: XLANG_HOST_CC_OBJS_CORE=1 escape → scripts/host_cc_objs_core_link.sh
#     (wave891 shell-primary; expect UNDEF residual; not product g05 path — wave786 B7D)
#   - stage2 / archaeology recipes that expand $(OBJS)
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell must not hardcode a second OBJS_CORE list (parse this
# mk instead).
#
# wave820: moved out of compiler/Makefile inline body (list residual of
# b7b_lists_in_mk). NOT physical delete — thin edges + other mk lists +
# std_core product make graph still residual.
#
# PLATFORM: SHARED — leaf basenames are host-portable.
# Branches: product default (G-06 no C frontend .c) vs XLANG_LEGACY_C_FRONTEND=1
# (archaeology capture / full C-frontend layout). Product default `make xlang`
# does NOT link OBJS_CORE (g05 authority); escape only.

# OBJS_CORE: G-06 product incomplete set (no C frontend .c; xlang-c = bootstrap_xlangc).
# Archaeology incomplete link only — product path is g05 (wave786).
OBJS_CORE = src/main.o src/runtime.o src/diag.o src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o src/runtime_c_import.o src/runtime_driver_strict_glue_stubs.o src/lexer/cfg_eval_bootstrap_stub.o src/driver/fmt_check_cmd.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_diag_pipeline_sizes.o src/lsp/lsp_diag_stubs_no_c.o
ifeq ($(XLANG_LEGACY_C_FRONTEND),1)
# Archaeology cold start: full C-frontend layout (seed capture / bootstrap_xlangc regen).
OBJS_CORE = src/main_driver.o src/runtime_driver.o src/diag.o src/driver/fmt_check_cmd.o src/lexer/lexer.o src/lexer/cfg_eval_bootstrap_stub.o src/ast/ast.o src/async/async_liveness.o src/async/async_cps_codegen.o src/lsp/lsp_diag.o src/lsp/lsp_diag_pipeline_sizes.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_c_import.o
endif
OBJS = $(OBJS_CORE)
