# driver_seed_r_lists.mk — wave788 · 11.3.1 B7B
#
# Single-authority pure-literal object lists for R1 / R3 / RT families and
# ASM_GLUE_STANDALONE_O. Included by compiler/Makefile (product make path) and
# parsed by scripts/driver_seed_obj_catalog.sh (shell catalog primary).
#
# G.7: Definitions live only here. Makefile must include, not re-assign.
# Shell must not hardcode a second copy of these lists.
#
# PLATFORM: SHARED — list paths under compiler/; host ABI stays elsewhere.

# RT seed slice (wave748 R1 first family)
RT_SEED_SLICE_OBJS = src/runtime/rt_arena_buf.o src/runtime/rt_emit_state.o src/runtime/rt_preamble.o src/runtime/rt_stack.o src/runtime/rt_parse_diag.o

# wave749 R1 second family: pure host-cc core seeds (basename → seeds/<leaf>.from_x.c).
# List authority for ensure_host_cc_seed_o.sh core-seed mode; body = same script as rt-slice.
# Not dual of DRIVER_SEED_BRIDGE_OBJS (bridge rebuild list); this is pure R1 recipe family only.
R1_CORE_SEED_OBJS = src/diag.o src/runtime_link_abi.o src/runtime_c_import.o src/x_seed_bridge.o src/seed_link_compat.o

# wave750 R1 third family: frontend glue with basename-mismatch seed map
# (lexer.o ← runtime_lexer_glue, ast.o ← runtime_ast_glue, lsp_diag.o ← runtime_lsp_glue).
# List authority for ensure_host_cc_seed_o.sh frontend-glue mode; body = same script.
# Seed map lives in ensure script (path convention); list stays here (G.7).
R1_FRONTEND_GLUE_OBJS = src/lexer/lexer.o src/ast/ast.o src/lsp/lsp_diag.o

# wave751 R1 fourth family: main/runtime multi-flag variants (shared seeds, different -D).
# List authority for ensure_host_cc_seed_o.sh main-runtime mode; body = same script.
# Seed/flag maps live in ensure script (path convention); list stays here (G.7).
R1_MAIN_RUNTIME_OBJS = src/main.o src/main_x.o src/main_driver.o src/runtime.o src/runtime_x.o src/runtime_driver.o src/runtime_driver_no_c.o

# wave752 R1 fifth family: pure host-cc link alias / bare / compat stubs
# (basename → seeds/<leaf>.from_x.c; no extra -D). List authority for
# ensure_host_cc_seed_o.sh alias-stubs mode; body = same script as rt-slice.
# Not dual of USER_ASM_SEED_* lists; this is pure R1 recipe family only.
R1_ALIAS_STUBS_OBJS = x_frontend_link_alias.o ast_asm_bare_link_alias.o backend_asm_bare_link_alias.o backend_asm_strict_fallback_alias.o typeck_c_module_stubs.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/runtime_driver_strict_glue_stubs.o

# wave753 R1 sixth family: pure host-cc with extra flags / multi-out seeds
# (pipeline_abi -D, asm_io_stubs -fPIE, sqlite glue+stub, parser link-alias -D).
# List authority for ensure_host_cc_seed_o.sh extra-cflags mode; body = same script.
# Seed/flag maps live in ensure script (path convention); list stays here (G.7).
R1_EXTRA_CFLAGS_OBJS = src/runtime_pipeline_abi.o runtime_asm_io_stubs.o runtime_sqlite_glue.o runtime_sqlite_glue_stub.o src/asm/parser_asm_parse_expr_link.o

# wave754 R1 seventh family: pure host-cc misc basename (no special -D/-f extras).
# List authority for ensure_host_cc_seed_o.sh misc-basename mode; body = same script.
# Basename → seeds/<leaf>.from_x.c.
R1_MISC_BASENAME_OBJS = runtime_link_abi_user_env.o runtime_channel_glue.o runtime_scheduler_glue.o runtime_kv_mmap_glue.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arm64_enc_c.o src/lsp/lsp_diag_pipeline_ctx.o build_asm/pipeline_glue_strict_minimal.o src/asm/runtime_asm_build.o

# wave755 R1 eighth family: basename-mismatch + bootstrap orch extras.
# List authority for ensure_host_cc_seed_o.sh seed-map mode; body = same script.
# Seed/flag maps live in ensure script (path convention); list stays here (G.7).
# wave758: parser_asm_thin_glue monothin joined seed-map.
# wave759: pipeline_glue_standalone joined seed-map.
R1_SEED_MAP_OBJS = src/driver/target_cpu.o src/ast/ast_seed.o pipeline_bootstrap_orchestration.o parser_asm_thin_glue.o build_asm/pipeline_glue_standalone.o

# wave757 R3 cold-else family: thin+rest leaves whose cold path is pure host-cc.
# List authority for ensure try-r3-cold / try-r3-prefer / r3-cold-seed (G.7).
R3_COLD_SEED_OBJS = src/runtime_io_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/asm/simd_enc.o src/asm/simd_loop.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o

# pipeline_glue_standalone product leaf (also referenced by composites / export lists).
ASM_GLUE_STANDALONE_O = build_asm/pipeline_glue_standalone.o
