/**
 * ast_pool.c — AST 块/模块/OneFunc 附属数据的 C 侧可增长池。
 *
 * Block 不再内嵌 const/let/if/expr_stmt/stmt_order 固定数组，仅保留 base+count；
 * Module.funcs 亦迁至可增长池。由 pipeline_glue.c #include 进同一 TU。
 */
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stddef.h>
#if defined(__APPLE__) || defined(__linux__)
#include <sys/mman.h>
#endif
#include <xlang_weak.h>
#include "diag.h"

/* wave246 G.7: env via public pure thin link_abi_getenv (wave222 → _impl host getenv);
 * not raw libc getenv. Cap residual host getenv stays only link_abi_getenv_impl.
 * PLATFORM: SHARED — product ast_pool residual raw getenv call sites migrate to this face
 * (DEBUG_PIPE / ASM_DEBUG / TRACE / WPO / emit-heavy / bootstrap-emit gates; same G.7
 * pattern as wave240 pipeline_glue). Textually #include'd into pipeline_glue /
 * pipeline_glue_standalone; redeclaration is compatible with glue's wave240 extern.
 */
extern char *link_abi_getenv(const char *name);

/* Pool grow policy macros must precede pipeline_grow_vec.c (uses AST_POOL_GROW /
 * AST_POOL_INIT_CAP). ifndef-guarded copies also live in ast_pool_typedefs.c for
 * readers of that domain file alone. PLATFORM: SHARED. */
#ifndef AST_POOL_GROW
#define AST_POOL_GROW 4096
#endif
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif

/* BC 8.3.2 wave1278: GrowVec leaf → pipeline_grow_vec.c (wave1275);
 * early typedef domain → ast_pool_typedefs.c; sidecar pool → ast_pool_sidecar_pool.c
 * (wave1276); core ptr_at accessors → ast_pool_ptr_at.c.
 * Order is load-bearing: macros → GrowVec type → entry/sidecar typedefs → pool
 * globals → ptr_at. PLATFORM: SHARED — same-TU #include into pipeline_glue / pipeline_x.
 */
#include "pipeline_grow_vec.c"
#include "ast_pool_typedefs.c"
#include "ast_pool_sidecar_pool.c"
#include "ast_pool_ptr_at.c"

/** Forward: pipeline_arena_block_alloc calls this before its definition in lifecycle. */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref);

/** BC 8.3.2: ASTArena main-pool cold accessors domain (same-TU thin). */
#include "ast_pool_arena.c"

/* wave1166 G.7: type pool cold accessors (read/write/find-or-alloc) —
 * migrated from pipeline_glue.c L1041-1153/L2216. Same TU via ast_pool.c
 * #include. Depends on pipeline_arena_type_ptr / pipeline_arena_type_alloc
 * (ast_pool_arena.c above). Forward decls retained in glue.c L761-762
 * (kind_ord_at / array_size_at) for callsites before this #include at
 * glue.c L5160.
 * PLATFORM: SHARED — host-cc Cap residual; parser/typeck/codegen call these. */
#include "ast_pool_type.c"


#include "ast_pool_lifecycle.c"


/** BC 8.3.2: Module Func cold accessors domain (same-TU thin). */
#include "ast_pool_module_func.c"


#include "pipeline_lint_meta.c"


/** BC 8.3.2 wave988–990 + wave992: block domain thin (append/region/defer +
 * loop/labeled/getters + parent/resolve + stmt_order rebuild/fixup) — same-TU. */
#include "ast_pool_block.c"

/* BC 8.3.2 wave991: onefunc fill residual lives in ast_pool_onefunc.c (include later).
 * BC 8.3.2 wave993+994: name_is_const + hoist + asm hoist_target / sum stack live in
 * ast_pool_top_level.c (include below; after block so static prepend_lets is visible).
 * BC 8.3.2 wave1280: emit-heavy env/thresholds + path helpers / whitelist →
 * pipeline_asm_emit_heavy_env.c (before selfhost). Shell residual: #include orchestration. */

/** ---------- Module import / struct_layout / top_level / enum 动态池 ---------- */

/** BC 8.3.2: module ImportEntry cold-twin accessors (same-TU thin). */
#include "ast_pool_module_import.c"

/** BC 8.3.2: module StructLayout cold accessors (same-TU thin). */
#include "ast_pool_struct_layout.c"

/** BC 8.3.2 wave980+993+994: TopLevelLetEntry + name_is_const/hoist + hoist_target/sum. */
#include "ast_pool_top_level.c"

/** BC 8.3.2: module TypeAliasEntry cold accessors (same-TU thin). */
#include "ast_pool_type_alias.c"

/* BC 8.3.2 wave1279: M8-tail backend asm thin wrappers → pipeline_backend_asm_wrapper.c
 * (after top_level hoist; before module_enum). PLATFORM: SHARED same-TU. */
#include "pipeline_backend_asm_wrapper.c"

#include "ast_pool_module_enum.c"



/** BC 8.3.2: OneFunc sidecar + fill_from_onefunc domain (wave984+991 same-TU thin). */
#include "ast_pool_onefunc.c"
/** BC 8.3.2: expr (+ type-pos) var-len sidecar domain (same-TU thin). */
#include "ast_pool_expr_sidecar.c"

/** BC 8.3.2: PipelineDepCtx cold accessors domain (same-TU thin). */
#include "ast_pool_dep_ctx.c"


#include "pipeline_resolve_path.c"

#include "pipeline_import_bind.c"

#include "pipeline_parse_typeck_dispatch.c"

#include "pipeline_run_x_pipeline.c"

#include "pipeline_codegen_dep.c"

#include "pipeline_loop_glue.c"


#include "pipeline_emit_sidecar.c"

#include "pipeline_preprocess_if.c"

#include "pipeline_typeck_slots.c"

#include "pipeline_elf_ctx.c"

/* BC 8.3.2 wave1279: codegen path/prefix scratch buffers → pipeline_scratch_bufs.c
 * (after elf_ctx; before type_to_c). PLATFORM: SHARED same-TU. */
#include "pipeline_scratch_bufs.c"

#include "pipeline_codegen_type_to_c.c"

#include "pipeline_codegen_struct_emit.c"

#include "pipeline_codegen_skip_force.c"

#include "pipeline_codegen_residual.c"

#include "pipeline_asm_locals.c"

#include "pipeline_asm_slot_bytes.c"

#include "pipeline_asm_block_tree.c"

#include "pipeline_asm_ctx_loop.c"

/* BC 8.3.2 wave1280: EMIT_HEAVY env/thresholds + path helpers + whitelist +
 * func-name prefix → pipeline_asm_emit_heavy_env.c (before selfhost so static
 * forward of asm_module_is_parser_selfhost resolves). PLATFORM: SHARED same-TU. */
#include "pipeline_asm_emit_heavy_env.c"

#include "pipeline_asm_selfhost.c"

#include "pipeline_asm_emit_heavy_safe_helper.c"


#include "pipeline_asm_thin_delegate.c"


#include "pipeline_asm_parser_emit_heavy.c"


#include "pipeline_asm_skip_dispatch.c"

#include "pipeline_asm_diag.c"

#include "pipeline_asm_wpo.c"

/** bootstrap 链接 glue：pipeline 编排 / asm scope / typeck 指针写槽（误 revert 后补全）。 */
#include "ast_pool_bootstrap_glue.c"
