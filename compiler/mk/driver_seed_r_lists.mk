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

# RT seed slice (wave748 R1 first family).
# wave898: also make-graph multi-target FORCE thin try-heat inventory (COUNT=5).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
RT_SEED_SLICE_OBJS = src/runtime/rt_arena_buf.o src/runtime/rt_emit_state.o src/runtime/rt_preamble.o src/runtime/rt_stack.o src/runtime/rt_parse_diag.o

# wave749 R1 second family: pure host-cc core seeds (basename → seeds/<leaf>.from_x.c).
# List authority for ensure_host_cc_seed_o.sh core-seed mode; body = same script as rt-slice.
# Not dual of DRIVER_SEED_BRIDGE_OBJS (bridge rebuild list); this is pure R1 recipe family only.
# wave899: also make-graph multi-target FORCE thin try-heat inventory (COUNT=5).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
R1_CORE_SEED_OBJS = src/diag.o src/runtime_link_abi.o src/runtime_c_import.o src/x_seed_bridge.o src/seed_link_compat.o

# wave750 R1 third family: frontend glue with basename-mismatch seed map
# (lexer.o ← runtime_lexer_glue, ast.o ← runtime_ast_glue, lsp_diag.o ← runtime_lsp_glue).
# List authority for ensure_host_cc_seed_o.sh frontend-glue mode; body = same script.
# Seed map lives in ensure script (path convention); list stays here (G.7).
# wave900: also make-graph multi-target FORCE thin try-heat inventory (COUNT=3).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
R1_FRONTEND_GLUE_OBJS = src/lexer/lexer.o src/ast/ast.o src/lsp/lsp_diag.o

# wave751 R1 fourth family: main/runtime multi-flag variants (shared seeds, different -D).
# List authority for ensure_host_cc_seed_o.sh main-runtime mode; body = same script.
# Seed/flag maps live in ensure script (path convention); list stays here (G.7).
# wave901: also make-graph multi-target FORCE thin try-heat inventory (COUNT=7).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
R1_MAIN_RUNTIME_OBJS = src/main.o src/main_x.o src/main_driver.o src/runtime.o src/runtime_x.o src/runtime_driver.o src/runtime_driver_no_c.o

# wave752 R1 fifth family: pure host-cc link alias / bare / compat stubs
# (basename → seeds/<leaf>.from_x.c; no extra -D). List authority for
# ensure_host_cc_seed_o.sh alias-stubs mode; body = same script as rt-slice.
# Not dual of USER_ASM_SEED_* lists; this is pure R1 recipe family only.
# wave902: also make-graph multi-target FORCE thin try-heat inventory (COUNT=8).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
R1_ALIAS_STUBS_OBJS = x_frontend_link_alias.o ast_asm_bare_link_alias.o backend_asm_bare_link_alias.o backend_asm_strict_fallback_alias.o typeck_c_module_stubs.o src/asm/user_asm_seed_bridge.o src/asm/asm_backend_compat_stubs.o src/runtime_driver_strict_glue_stubs.o

# wave753 R1 sixth family: pure host-cc with extra flags / multi-out seeds
# (pipeline_abi -D, asm_io_stubs -fPIE, sqlite glue+stub, parser link-alias -D).
# List authority for ensure_host_cc_seed_o.sh extra-cflags mode; body = same script.
# Seed/flag maps live in ensure script (path convention); list stays here (G.7).
# wave903: also make-graph multi-target FORCE thin try-heat inventory (COUNT=5).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
R1_EXTRA_CFLAGS_OBJS = src/runtime_pipeline_abi.o runtime_asm_io_stubs.o runtime_sqlite_glue.o runtime_sqlite_glue_stub.o src/asm/parser_asm_parse_expr_link.o

# wave754 R1 seventh family: pure host-cc misc basename (no special -D/-f extras).
# List authority for ensure_host_cc_seed_o.sh misc-basename mode; body = same script.
# Basename → seeds/<leaf>.from_x.c.
# wave904: also make-graph multi-target FORCE thin try-heat inventory (COUNT=9).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
R1_MISC_BASENAME_OBJS = runtime_link_abi_user_env.o runtime_channel_glue.o runtime_scheduler_glue.o runtime_kv_mmap_glue.o src/asm/backend_x86_64_enc_c.o src/asm/backend_arm64_enc_c.o src/lsp/lsp_diag_pipeline_ctx.o build_asm/pipeline_glue_strict_minimal.o src/asm/runtime_asm_build.o

# wave755 R1 eighth family: basename-mismatch + bootstrap orch extras.
# List authority for ensure_host_cc_seed_o.sh seed-map mode; body = same script.
# Seed/flag maps live in ensure script (path convention); list stays here (G.7).
# wave758: parser_asm_thin_glue monothin joined seed-map.
# wave759: pipeline_glue_standalone joined seed-map.
# wave905: also make-graph multi-target FORCE thin try-heat inventory (COUNT=5).
# Body = ensure try-heat; do not re-list in Makefile or residual shells (G.7).
R1_SEED_MAP_OBJS = src/driver/target_cpu.o src/ast/ast_seed.o pipeline_bootstrap_orchestration.o parser_asm_thin_glue.o build_asm/pipeline_glue_standalone.o

# wave757 R3 cold-else family: thin+rest leaves whose cold path is pure host-cc.
# List authority for ensure try-r3-cold / try-r3-prefer / r3-cold-seed (G.7).
# wave906: also make-graph multi-target FORCE thin try-heat inventory (COUNT=9).
# Body = ensure try-heat → try-r3-prefer; do not re-list in Makefile or residual shells (G.7).
R3_COLD_SEED_OBJS = src/runtime_io_abi.o src/runtime_driver_abi.o src/runtime_driver_diagnostic.o src/asm/simd_enc.o src/asm/simd_loop.o src/asm/backend_enc_dispatch.o src/asm/backend_arch_emit_dispatch.o src/asm/backend_try_inline_dispatch.o src/asm/backend_call_dispatch.o

# wave770 async three: full.x+rest PREFER family (try-async-prefer table in ensure).
# List authority for make-graph multi-target FORCE thin try-heat (wave907 COUNT=3).
# Body = ensure try-heat → try-async-prefer; do not re-list in Makefile or residual shells (G.7).
# Leaves: async_liveness · async_cps_codegen · async_asm_pool (paths under src/async/).
ASYNC_THREE_SEED_OBJS = src/async/async_liveness.o src/async/async_cps_codegen.o src/async/async_asm_pool.o

# wave779 B1 runtime_* OS/glue dual hybrid family (try-runtime-os-prefer table in ensure).
# List authority for make-graph multi-target FORCE thin try-heat (wave908 COUNT=23).
# Body = ensure try-heat → try-runtime-os-prefer; do not re-list in Makefile or residual shells (G.7).
# Leaves: runtime_test_fn_invoke … runtime_process_os_glue (top-level product .o names).
B1_RUNTIME_OS_SEED_OBJS = runtime_test_fn_invoke.o runtime_random_fill.o runtime_compress_zlib_glue.o runtime_time_os.o runtime_queue_contention.o runtime_dynlib_os.o runtime_env_os.o runtime_backtrace_platform.o runtime_log_os.o runtime_math_libm.o runtime_atomic_glue.o runtime_net_udp_batch.o runtime_net_workers.o runtime_sync_os.o runtime_sync_lock_diag_tls.o runtime_thread_glue.o runtime_http_glue.o runtime_tls_mbedtls_bio.o runtime_arrow_simd_glue.o runtime_crypto_inc_glue.o runtime_ed25519_ref10_glue.o runtime_process_argv.o runtime_process_os_glue.o

# wave761 try-gen-x family (lsp trio + pipeline_x) make-graph multi-target inventory.
# List authority for multi-target FORCE thin try-heat (wave909 COUNT=4).
# Body = ensure try-heat → try-gen-x → ensure_gen_x_o.sh (G.7 single body).
# Membership for rebuild_leaves try-gen-x remains catalog:
#   DRIVER_SEED_LSP_X_OBJS (lsp_io/lsp/lsp_diag subset) + DRIVER_SEED_PIPELINE_X_OBJS.
# This list is the exact try-gen-x OUT map (not full LSP_X which also has ldpc/alias).
# Do not re-list in Makefile or residual shells (G.7).
GEN_X_SEED_OBJS = lsp_io_x.o lsp_x.o lsp_diag_x.o pipeline_x.o

# wave782 B4 gen.c → .o bootstrap family (try-gen-c-to-o table in ensure).
# List authority for multi-target FORCE thin try-heat (wave910 COUNT=5).
# Body = ensure try-heat → try-gen-c-to-o → ensure_gen_x_o.sh one OUT (G.7 single body).
# Membership for rebuild stays gen_c_to_o_spec_for_out table (outside try-gen-x catalog).
# Leaves: lexer_x · ast_gen2 · driver_x · preprocess_x · _x_stubs2 (top-level product .o).
# Do not re-list in Makefile or residual shells (G.7).
GEN_C_TO_O_SEED_OBJS = lexer_x.o ast_gen2.o driver_x.o preprocess_x.o _x_stubs2.o

# wave781 B3 LSP satellite hybrid family (try-lsp-sat-prefer table in ensure).
# List authority for multi-target FORCE thin try-heat (wave911 COUNT=2).
# Body = ensure try-heat → try-lsp-sat-prefer (direct_e / thin_rest_e ladder; G.7 single body).
# Leaves: lsp_diag_pipeline_sizes_nostub · lsp_diag_stubs_no_c (under src/lsp/).
# Do not re-list in Makefile or residual shells (G.7).
B3_LSP_SAT_SEED_OBJS = src/lsp/lsp_diag_pipeline_sizes_nostub.o src/lsp/lsp_diag_stubs_no_c.o

# wave771/775 other-L2 fmt_check family (try-other-l2-prefer table in ensure).
# List authority for multi-target FORCE thin try-heat (wave912 COUNT=2).
# Body = ensure try-heat → try-other-l2-prefer (fmt_core / fmt leaf_kind; G.7 single body).
# Leaves: fmt_check_cmd.o (OBJS_CORE/PIPELINE_X satellite, no USE_X_PIPELINE) ·
#         fmt_check_cmd_driver.o (driver USE_X_PIPELINE).
# Do not re-list in Makefile or residual shells (G.7).
FMT_CHECK_SEED_OBJS = src/driver/fmt_check_cmd.o src/driver/fmt_check_cmd_driver.o

# wave762/913 R2 CRT0 / freestanding platform .s (and mingw seed) family.
# List authority for multi-target FORCE thin try-heat (wave913 COUNT=6).
# Body = ensure try-heat → try-r2 (fixed o→src map; r2_crt0_host_relevant filters
# family rebuild). Migrated from export_lists so multi-target binds before late
# include (G.7 single literal authority; export_lists no longer re-assigns).
# Leaves: crt0_x86_64 · crt0_arm64 · crt0_darwin_x86_64 · crt0_mingw ·
#         crt0_user_x86_64 · freestanding_io_x86_64.
# Not in list: crt0_user.o / freestanding_io.o (cp-alias · wave836) ·
#              bootstrap_nostdlib_stubs (cc_inc_tu residual · wave831).
# Do not re-list in Makefile or residual shells (G.7).
DRIVER_SEED_CRT0_OBJS = src/asm/crt0_x86_64.o src/asm/crt0_arm64.o src/asm/crt0_darwin_x86_64.o src/asm/crt0_mingw.o src/asm/crt0_user_x86_64.o src/asm/freestanding_io_x86_64.o

# wave762/914 R2 typeck_f64_bits host-pick pure-.s family (N=1 leaf).
# List authority for multi-target FORCE thin try-heat (wave914 COUNT=1).
# Body = ensure try-heat → try-r2 → r2_typeck_f64_host_pick_src (G.7 single body).
# UNAME ifeq hard-error surface dropped from Makefile — shell fails closed on
# unsupported host (ensure_r2_typeck_f64_one). Migrated from export_lists so
# multi-target binds before late include (G.7 single literal authority).
# Leaf: src/typeck/typeck_f64_bits.o.
# Do not re-list in Makefile or residual shells (G.7).
DRIVER_SEED_TYPECK_F64_OBJS = src/typeck/typeck_f64_bits.o

# wave760/776/915 R2 runtime_panic family (N=1 leaf; cold try-r2 + PREFER try-r2-prefer).
# List authority for multi-target FORCE thin try-heat (wave915 COUNT=1).
# Body = ensure try-heat → try-r2-prefer / try-r2 (G.7 single body; host pick + stamp).
# Migrated from export_lists so multi-target binds before late include (G.7 single
# literal authority; export_lists no longer re-assigns).
# Leaf: runtime_panic.o.
# Do not re-list in Makefile or residual shells (G.7).
DRIVER_SEED_PANIC_OBJS = runtime_panic.o

# wave783/916 B5 cfg_eval multi-ladder family (N=1 leaf).
# List authority for multi-target FORCE thin try-heat (wave916 COUNT=1).
# Body = ensure try-heat → try-cfg-eval-ladder (G.7 single body; live -E-extern →
# pin gen → bootstrap stub rungs; LD/LD_RELFLAGS shell defaults via wave886).
# Migrated from per-leaf Makefile recipe so multi-target binds before late include
# (G.7 single literal authority; export_lists never re-assigns this leaf).
# Leaf: src/lexer/cfg_eval.o.
# Not in list: src/lexer/cfg_eval_bootstrap_stub.o (cc_inc_tu residual · wave831;
# different family — direct seed copy, not multi-ladder).
# Do not re-list in Makefile or residual shells (G.7).
DRIVER_SEED_CFG_EVAL_OBJS = src/lexer/cfg_eval.o

# wave831/917 B7B cc_inc_tu SHARED family (N=5 leaves; Linux x86_64 only
# bootstrap_nostdlib_stubs.o excluded — different platform guard).
# List authority for multi-target FORCE thin cc_inc_tu --auto (wave917).
# Body = @bash scripts/cc_inc_tu.sh --auto $@ (G.7 single body; seed-map in
# cc_inc_tu.sh cc_inc_tu_seed_for_out handles per-leaf seed path variance
# such as lsp_diag_pipeline_sizes → _weak suffix).
# Migrated from per-leaf Makefile recipes so multi-target binds before late
# include (G.7 single literal authority; export_lists never re-assigns).
# Leaves: src/asm/asm_experimental_symbol_bridge.o
#         src/lsp/lsp_diag_pipeline_sizes.o (seed: _weak.from_x.c)
#         src/lexer/cfg_eval_bootstrap_stub.o
#         src/lsp/typeck_lsp_io_stub.o
#         src/build_tool_main.o
# Not in list: src/asm/bootstrap_nostdlib_stubs.o (ifeq Linux x86_64 guard;
# wave831/918; different platform scope — see CC_INC_TU_LINUX_X86_64_OBJS).
# Do not re-list in Makefile or residual shells (G.7).
CC_INC_TU_OBJS = \
	src/asm/asm_experimental_symbol_bridge.o \
	src/lsp/lsp_diag_pipeline_sizes.o \
	src/lexer/cfg_eval_bootstrap_stub.o \
	src/lsp/typeck_lsp_io_stub.o \
	src/build_tool_main.o

# wave831/918 B7B cc_inc_tu Linux x86_64 guard family (N=1 leaf).
# List authority for multi-target FORCE thin cc_inc_tu --auto inside
# ifeq ($(UNAME_S),Linux) ifeq ($(UNAME_M),x86_64) guard block (wave918).
# Body = @bash scripts/cc_inc_tu.sh --auto $@ (same as SHARED family;
# seed-map in cc_inc_tu.sh cc_inc_tu_seed_for_out).
# PLATFORM: LINUX|UBUNTU x86_64 only — Makefile ifeq guard preserved.
# Leaf: src/asm/bootstrap_nostdlib_stubs.o (freestanding nostdlib stubs).
# Do not re-list in Makefile or residual shells (G.7).
CC_INC_TU_LINUX_X86_64_OBJS = src/asm/bootstrap_nostdlib_stubs.o

# wave735/919 B7B migrate_x family (N=3 leaves; root-level .o).
# List authority for multi-target FORCE thin migrate_x_objs (wave919).
# Body = @bash scripts/migrate_x_objs.sh $@ (G.7 single body; script's
# case statement accepts both <name> and <name>_x.o as MODE, so $@ passes
# parser_x.o / typeck_x.o / codegen_x.o directly — no --auto seed-map needed).
# Migrated from 3 per-leaf Makefile recipes (parser_x/typeck_x/codegen_x).
# Leaves: parser_x.o typeck_x.o codegen_x.o (root-level; gen.c mtime owned
# by migrate_x_objs.sh need_rebuild + XLANG_MIGRATE_FORCE; ensure_migrate_gen
# for missing/stale gen.c still via separate *_gen.c recipes).
# Do not re-list in Makefile or residual shells (G.7).
MIGRATE_X_OBJS = parser_x.o typeck_x.o codegen_x.o

# wave836/920 B7B cp-alias SHARED family (N=1 leaf; ast_x.o alias of ast_seed.o).
# List authority for multi-target FORCE thin ensure_cp_alias_o (wave920).
# Body = @bash scripts/ensure_cp_alias_o.sh ensure $@ (G.7 single body; script's
# CATALOG single authority for OUT|SRC map; $@ passes ast_x.o directly).
# Migrated from 1 per-leaf Makefile recipe (ast_x.o; SHARED scope).
# Leaf: ast_x.o (G-02a C ABI alias; PLATFORM: SHARED — Mac arm64 still has leaf).
# Not in list: crt0_user.o / freestanding_io.o (see CP_ALIAS_LINUX_X86_64_OBJS;
# x86_64 freestanding wrappers under ifeq Linux x86_64 guard).
# Do not re-list in Makefile or residual shells (G.7).
CP_ALIAS_SHARED_OBJS = ast_x.o

# wave836/920 B7B cp-alias Linux x86_64 guard family (N=2 leaves; freestanding
# link-name wrappers). List authority for multi-target FORCE thin ensure_cp_alias_o
# inside ifeq ($(UNAME_S),Linux) ifeq ($(UNAME_M),x86_64) guard block (wave920).
# Body = @bash scripts/ensure_cp_alias_o.sh ensure $@ (same as SHARED family;
# script CATALOG owns OUT|SRC map).
# PLATFORM: LINUX|UBUNTU x86_64 only — Makefile ifeq guard preserved.
# Leaves: crt0_user.o (← src/asm/crt0_user_x86_64.o) ·
#         freestanding_io.o (← src/asm/freestanding_io_x86_64.o).
# Not in list: ast_x.o (see CP_ALIAS_SHARED_OBJS; SHARED scope).
# Do not re-list in Makefile or residual shells (G.7).
CP_ALIAS_LINUX_X86_64_OBJS = crt0_user.o freestanding_io.o

# wave835/921 B7B class-G filter against_partial family (N=3 leaves; SHARED).
# List authority for multi-target FORCE thin filter_bootstrap_seed_against_partial_o
# (wave921). Body = @bash scripts/filter_bootstrap_seed_against_partial_o.sh ensure $@
# (G.7 single body; script CATALOG owns OUT|SRC map; $@ passes leaf path directly).
# Migrated from 3 per-leaf Makefile recipes.
# Leaves: build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o ·
#         build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o ·
#         build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o.
# Not dual of BOOTSTRAP_DRIVER_SEED_FILTERED_OBJS (mk/user_asm_seed_objs.mk) —
# that composite mixes filtered + non-filtered for link graph; this list is the
# pure recipe-family authority for FORCE thin multi-target only.
# Do not re-list in Makefile or residual shells (G.7).
FILTER_AGAINST_PARTIAL_OBJS = \
	build_asm/bootstrap_seed_backend_x86_64_enc_c_filtered.o \
	build_asm/bootstrap_seed_user_asm_seed_bridge_filtered.o \
	build_asm/bootstrap_seed_asm_backend_compat_stubs_filtered.o

# wave835/921 B7B class-G filter pipeline family (N=1 leaf; SHARED).
# List authority for multi-target FORCE thin filter_bootstrap_seed_pipeline_o
# (wave921). Body = @bash scripts/filter_bootstrap_seed_pipeline_o.sh ensure $@
# (G.7 single body; script owns DEFAULT_OUT + ensure path).
# Migrated from 1 per-leaf Makefile recipe.
# Leaf: build_asm/bootstrap_seed_pipeline_filtered.o (Darwin product link primary).
# Do not re-list in Makefile or residual shells (G.7).
FILTER_PIPELINE_OBJS = build_asm/bootstrap_seed_pipeline_filtered.o

# pipeline_glue_standalone product leaf (also referenced by composites / export lists).
ASM_GLUE_STANDALONE_O = build_asm/pipeline_glue_standalone.o
