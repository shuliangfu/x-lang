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
DRIVER_SEED_PANIC_OBJS = runtime_panic.o
# wave762 R2 UNAME leaves (lists = mk only; body = ensure try-r2):
# typeck_f64_bits.o — host picks platform .s (Linux/Darwin/Windows mingw).
DRIVER_SEED_TYPECK_F64_OBJS = src/typeck/typeck_f64_bits.o
# crt0 / freestanding platform .s (and mingw seed) — fixed o→src map; host
# only builds the leaves its MAIN_LINK / freestanding path needs.
# Not in list: crt0_user.o / freestanding_io.o (cp-alias · wave836 ensure_cp_alias_o) · bootstrap_nostdlib_stubs (cc_inc_tu residual).
DRIVER_SEED_CRT0_OBJS = src/asm/crt0_x86_64.o src/asm/crt0_arm64.o src/asm/crt0_darwin_x86_64.o src/asm/crt0_mingw.o src/asm/crt0_user_x86_64.o src/asm/freestanding_io_x86_64.o
DRIVER_SEED_USER_ASM_SEED_OBJS = $(USER_ASM_SEED_OBJS)
DRIVER_SEED_ASM_GLUE_OBJS = $(ASM_GLUE_STANDALONE_O)
# §5b #9 — scan base for asm_full_link_stubs (export only; no dual list in shell)
DRIVER_SEED_HOST_STUBS_SCAN_BASE = pipeline_x.o $(ASM_GLUE_STANDALONE_O) $(USER_ASM_SEED_OBJS)
