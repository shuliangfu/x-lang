# x_source_deps.mk — wave823 · 11.3.1 B7B
#
# Single-authority inventories for *source path* make prereqs / STALE lists:
#   SRCS              — archaeology incomplete host-cc .c set (4 from_x)
#   MAIN_X_DEPS       — main.x -E-extern direct import modules (driver_gen)
#   PREPROCESS_X_DEPS — preprocess.x standalone -E-extern entry
#   PIPELINE_ASM_X_DEPS — wildcard asm subtree .x (backend/platform/arch)
#   PIPELINE_X_DEPS   — pipeline_gen / pipeline_x.o STALE + make prereqs
#
# Used by:
#   - compiler/Makefile: include only (wave823); no dual inventory
#   - scripts/ensure_driver_gen.sh: freshness vs MAIN_X_DEPS / PREPROCESS_X_DEPS
#   - scripts/ensure_gen_x_o.sh: PIPELINE_X_DEPS mk-load when env unset (wave886)
#   - driver_seed_obj_catalog.sh shell parse (0-make; G.7)
#
# G.7: Definitions live only here. Makefile must include, not re-assign the
# full inventory. Shell must not hardcode a second MAIN_X_DEPS /
# PIPELINE_X_DEPS list (parse this mk instead).
# 8.3.1+8.3.2: #include slices (ctfe/assign/.../soa + asm_emit_assign + ast_pool_module_import +
#   ast_pool_struct_layout + ast_pool_top_level + ast_pool_type_alias +
#   ast_pool_expr_sidecar + ast_pool_module_enum + ast_pool_onefunc +
#   ast_pool_dep_ctx + ast_pool_module_func + ast_pool_arena + ast_pool_block) enter STALE deps.
#
# wave823: moved out of compiler/Makefile inline body (list residual of
# b7b_lists_in_mk). NOT physical delete — thin edges + std_core product make
# graph still residual.
#
# PLATFORM: SHARED — source basenames are host-portable.
# Note: PIPELINE_ASM_X_DEPS uses GNU make $(wildcard); catalog stores the
# unexpanded $(PIPELINE_ASM_X_DEPS) token inside PIPELINE_X_DEPS (make expands
# at recipe/prereq time). Fixed multi-token authority COUNT for honesty:
#   SRCS 4 + MAIN_X_DEPS 4 + PREPROCESS_X_DEPS 1 + PIPELINE_X_DEPS fixed paths 48
#   = 57 (excludes the $(PIPELINE_ASM_X_DEPS) expansion token).
#   8.3.1+8.3.2: +38 #include slices (ctfe/assign/.../soa + asm_emit_index +
#     asm_emit_match + asm_emit_panic + asm_emit_field_access + asm_emit_binop +
#     asm_emit_cmp + asm_emit_call_args + asm_emit_struct_lit +
#     asm_emit_vector_let + asm_emit_vector_simd +
#     ast_pool_module_import + ast_pool_struct_layout +
#     ast_pool_top_level + ast_pool_type_alias + ast_pool_expr_sidecar +
#     ast_pool_module_enum + ast_pool_onefunc + ast_pool_dep_ctx +
#     ast_pool_module_func + ast_pool_arena + ast_pool_block) in PIPELINE_X_DEPS.

# Archaeology incomplete from_x .c inventory (historical host-cc core set).
# Makefile product path is g05 (wave786); this list remains for inventory /
# archaeology consumers (bootstrap.sh still has its own SRCS for cold stage).
SRCS = seeds/main.from_x.c seeds/runtime.from_x.c seeds/async_liveness.from_x.c seeds/async_cps_codegen.from_x.c

# main.x -E-extern direct imports; change → regen driver_gen.c / driver_x.o.
MAIN_X_DEPS = src/main.x src/codegen/codegen.x src/ast/ast.x src/preprocess/preprocess.x

# preprocess.x standalone -E-extern entry.
PREPROCESS_X_DEPS = src/preprocess/preprocess.x

# Must be defined before pipeline_x.o / bootstrap-pipeline consumers parse
# $(PIPELINE_X_DEPS). Wildcard covers asm backend/platform/arch churn so
# pipeline_gen.c / pipeline_x.o do not keep a stale snapshot.
PIPELINE_ASM_X_DEPS = $(wildcard src/asm/*.x src/asm/platform/*.x src/asm/arch/*.x)

# pipeline_x.o / pipeline_gen STALE set: frontend .x chain + glue/pool C + asm tree.
PIPELINE_X_DEPS = src/pipeline/pipeline.x src/codegen/codegen.x src/typeck/typeck.x src/parser/parser.x src/ast/ast.x src/lexer/lexer.x src/preprocess/preprocess.x $(PIPELINE_ASM_X_DEPS) pipeline_glue.c pipeline_typeck_ctfe.c pipeline_typeck_assign.c pipeline_typeck_coerce_init.c pipeline_typeck_method_call.c pipeline_typeck_check_block.c pipeline_typeck_region_assign.c pipeline_asm_emit_unary.c pipeline_asm_emit_as.c pipeline_asm_emit_return.c pipeline_asm_emit_logand.c pipeline_asm_emit_block_body.c pipeline_asm_emit_block_if_stmt.c pipeline_asm_emit_block_inits.c pipeline_asm_emit_assign.c pipeline_asm_emit_array_lit.c pipeline_asm_emit_index.c pipeline_asm_emit_match.c pipeline_asm_emit_panic.c pipeline_asm_emit_field_access.c pipeline_asm_emit_binop.c pipeline_asm_emit_cmp.c pipeline_asm_emit_call_args.c pipeline_asm_emit_struct_lit.c pipeline_asm_emit_vector_let.c pipeline_asm_emit_vector_simd.c pipeline_typeck_field_access.c pipeline_typeck_soa.c ast_pool.c ast_pool_module_import.c ast_pool_struct_layout.c ast_pool_top_level.c ast_pool_type_alias.c ast_pool_expr_sidecar.c ast_pool_module_enum.c ast_pool_onefunc.c ast_pool_dep_ctx.c ast_pool_module_func.c ast_pool_arena.c ast_pool_block.c ast_pool_bootstrap_glue.c
