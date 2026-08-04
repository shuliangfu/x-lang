# driver_seed_export_lists.mk — wave727 · 11.0.4
#
# Single-authority §5b rebuild / export leaf object lists for bootstrap-driver-seed.
# Included by compiler/Makefile after USER_ASM_SEED_OBJS, ASM_GLUE_STANDALONE_O,
# and DRIVER_SEED_RUNTIME_REBUILD / DRIVER_SEED_PREPROCESS_REBUILD exist.
#
# G.7: Definitions live only here (plus user_asm_seed_objs.mk for USER_ASM /
# filtered + driver_seed_r_lists.mk for R1/R3/RT). Makefile must include, not
# re-assign. Shell consumes via driver_seed_obj_catalog.sh (wave788 shell
# primary / make export escape) — never hardcode a second .o inventory.
#
# PLATFORM: SHARED — lists are host-portable paths under compiler/.

# §5b #2/#3/#4/#5/#6/#7/#12 — single-authority target lists (export + shell)
DRIVER_SEED_PIPELINE_X_OBJS = pipeline_x.o
DRIVER_SEED_SAT_REBUILD_OBJS = src/diag.o src/runtime_io_abi.o src/runtime_link_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/runtime_pipeline_abi.o $(DRIVER_SEED_RUNTIME_REBUILD) $(DRIVER_SEED_PREPROCESS_REBUILD) src/driver/target_cpu.o src/asm/simd_enc.o src/asm/simd_loop.o
DRIVER_SEED_LSP_X_OBJS = lsp_io_x.o lsp_x.o lsp_diag_x.o src/lsp/lsp_diag_pipeline_ctx.o x_frontend_link_alias.o
DRIVER_SEED_BRIDGE_OBJS = src/x_seed_bridge.o
# wave915: DRIVER_SEED_PANIC_OBJS literal → mk/driver_seed_r_lists.mk (early
# multi-target FORCE thin try-heat inventory; G.7 single authority — do not re-assign).
# Catalog still expands DRIVER_SEED_PANIC_OBJS via r_lists parse (shell primary).
# wave914: DRIVER_SEED_TYPECK_F64_OBJS literal → mk/driver_seed_r_lists.mk (early
# multi-target FORCE thin try-heat inventory; G.7 single authority — do not re-assign).
# Catalog still expands DRIVER_SEED_TYPECK_F64_OBJS via r_lists parse (shell primary).
# wave913: DRIVER_SEED_CRT0_OBJS literal → mk/driver_seed_r_lists.mk (early multi-target
# FORCE thin try-heat inventory; G.7 single authority — do not re-assign here).
# Catalog still expands DRIVER_SEED_CRT0_OBJS via r_lists parse (shell primary).
DRIVER_SEED_USER_ASM_SEED_OBJS = $(USER_ASM_SEED_OBJS)
DRIVER_SEED_ASM_GLUE_OBJS = $(ASM_GLUE_STANDALONE_O)
# §5b #9 — scan base for asm_full_link_stubs (export only; no dual list in shell)
DRIVER_SEED_HOST_STUBS_SCAN_BASE = pipeline_x.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS)
