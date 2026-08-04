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

#ifndef AST_POOL_GROW
#define AST_POOL_GROW 4096
#endif

/**
 * Initial capacity (in elements) for newly-created GrowVec pools.
 *
 * Why: separate from AST_POOL_GROW (the linear grow step) so that freshly
 * initialized pools start small (avoiding ~4.3 MB of zerofill per ArenaSidecar
 * when only a handful of entries are ever used). Combined with the linear
 * grow step AST_POOL_GROW, this gives amortized O(1) appends while keeping
 * per-arena init cost low.
 *
 * Invariant: 0 < AST_POOL_INIT_CAP <= AST_POOL_GROW. The init path uses
 * calloc() (zerofill); grow path uses realloc() + memset() on the tail.
 *
 * Asm/Perf: ArenaSidecar init cost drops from 4.3 MB -> 270 KB per arena
 * (18 GrowVecs, weighted avg elem_sz ~200B). For 50 deps this cuts init
 * RSS from ~215 MB to ~14 MB. Pools that exceed INIT_CAP grow by
 * AST_POOL_GROW (4096) elements per realloc, preserving amortized cost.
 *
 * PLATFORM: SHARED — affects mac arm64 + Ubuntu x86_64 (any pipeline_x.o
 * rebuild; ast_pool.c is #included by pipeline_glue.c).
 */
#ifndef AST_POOL_INIT_CAP
#define AST_POOL_INIT_CAP 256
#endif

/** 多 Module 共用 elf_ctx 时分配 tail_join 等局部标签 scope（定义见本文件后部）。 */
void pipeline_elf_label_mod_scope_begin_module(void);

/** 无实际上限：grow 直至 OOM；cap API 仅兼容旧 .x 边界检查。 */
#define AST_POOL_NO_LIMIT 2147483647

/** Module import 槽（C 侧 grow pool；路径最长 255 字节）。 */
typedef struct {
  uint8_t path[256];
  int32_t path_len;
  int32_t kind;
  uint8_t binding_name[128];
  int32_t binding_name_len;
  /** import { a, b } 名称在 module 侧车 select 池中的起始下标 */
  int32_t select_base;
  int32_t select_count;
} ImportEntry;

/** match 单臂（Expr 侧车池）。
 * wave700: guard_ref — optional `pat if cond =>` guard expr (0 = none).
 * PLATFORM: SHARED — product match-guard Cap residual. */
typedef struct {
  int32_t result_ref;
  int32_t is_wildcard;
  int32_t lit_val;
  int32_t is_enum_variant;
  int32_t variant_index;
  int32_t guard_ref;
} MatchArmEntry;

/** struct literal 单字段（Expr 侧车池）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t init_ref;
} StructLitFieldEntry;

/** 函数形参槽（module/arena sidecar func_params 池）。
 * wave585 Cap residual: name[32]→[128] (content ≤127; match AST / let Cap).
 * PLATFORM: SHARED */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t type_ref;
} FuncParamEntry;

/** struct_layout 单字段槽（module sidecar struct_layout_fields 池）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t field_offset;
  int32_t type_ref;
  /** DOD-CL：字段最小对齐（align(N)）；0 表示仅按类型自然对齐。 */
  int32_t field_align;
} StructLayoutFieldEntry;

/**
 * wave467: struct layout type-param name (`struct Pair<T, U>`).
 * Sidecar only — no StructLayout ABI churn. PLATFORM: SHARED.
 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
} LayoutTypeParamEntry;

/** Meta per layout idx: base into struct_layout_type_params, count of params. */
typedef struct {
  int32_t base;  /* -1 = unset */
  int32_t count;
} LayoutTypeParamMeta;

/** 顶层 let/const 槽。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
  int32_t is_const;
  /** 1=`export const` / `export let`（顶层）；进入模块导出表。 */
  int32_t is_export;
} TopLevelLetEntry;

/** 顶层 type 别名槽：type Alias = Target;（纯 typeck 别名，codegen typedef）。 */
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t target_type_ref;
} TypeAliasEntry;

/** 顶层 enum 名槽；变体名在 parse 跳过 enum { A, B } 时登记，供 asm Color.Green 等发射 tag。 */
/**
 * TokenKind 等前端枚举已超过 64 变体（token.x 约 130+）。
 * 截断会导致 TOKEN_LPAREN 等 tag 查找失败 → tok.kind = TokenKind.X 报 found ?。
 */
#define MODULE_ENUM_MAX_VARIANTS 256
typedef struct {
  uint8_t name[128];
  int32_t name_len;
  int32_t num_variants;
  uint8_t variant_name[MODULE_ENUM_MAX_VARIANTS][128];
  int32_t variant_name_len[MODULE_ENUM_MAX_VARIANTS];
  /** 1=`export enum`；类型名 ∈ E(M)。 */
  int32_t is_export;
} ModuleEnumEntry;

#include "pipeline_grow_vec.c"

/** M-3：region label { body } 侧车槽（与 C ASTRegionBlock 语义一致）。 */
typedef struct {
  uint8_t label[128];
  int32_t label_len;
  int32_t body_ref;
  /** MEM-C1：>0 表示 with_arena(cap) 块（cap 表达式 ref）；0 表示普通 region。 */
  int32_t with_arena_cap_ref;
} RegionBlockEntry;

/** 每个 ASTArena 的统一 sidecar：主池 + 块附属池。 */
typedef struct {
  struct ast_ASTArena *arena;
  int used;
  GrowVec types;
  GrowVec exprs;
  GrowVec blocks;
  GrowVec funcs;
  GrowVec consts;
  GrowVec lets;
  GrowVec ifs;
  GrowVec regions;
  GrowVec loops;
  GrowVec for_loops;
  GrowVec defer_block_refs;
  GrowVec labeled_stmts;
  GrowVec expr_stmt_refs;
  GrowVec stmt_order;
  /** Expr 变长附属：call/method 实参、match 臂、struct lit 字段、array lit 元素 */
  GrowVec expr_call_arg_refs;
  /**
   * wave452: CALL turbofish type-arg type_refs (flat pool).
   * Base per expr is in expr_call_type_arg_bases[expr_ref] (sidecar only —
   * avoids Expr layout / SHARED ABI churn). count remains Expr.call_num_type_args.
   * PLATFORM: SHARED — G.7 single authority with pipeline_expr_call_type_arg_* APIs.
   */
  GrowVec expr_call_type_arg_refs;
  /** Index by expr_ref; value is base into expr_call_type_arg_refs, or -1 if unset. */
  GrowVec expr_call_type_arg_bases;
  /**
   * wave467: TYPE_NAMED type-position args `Name<T,U>` (flat pool).
   * Base per type_ref in type_type_arg_bases; count remains Type.array_size for NAMED.
   * Slot0 also mirrored in Type.elem_type_ref (wave466 single-arg compat).
   * PLATFORM: SHARED — G.7 single authority with pipeline_type_type_arg_* APIs.
   */
  GrowVec type_type_arg_refs;
  /** Index by type_ref; value is base into type_type_arg_refs, or -1 if unset. */
  GrowVec type_type_arg_bases;
  /** Index by type_ref; number of type-pos args appended (wave467). */
  GrowVec type_type_arg_counts;
  GrowVec expr_method_call_arg_refs;
  GrowVec expr_match_arms;
  GrowVec expr_struct_lit_fields;
  GrowVec expr_array_lit_elem_refs;
  GrowVec func_params;
} ArenaSidecar;

/** 每个 Module 的动态池。 */
typedef struct {
  struct ast_Module *module;
  int used;
  GrowVec funcs;
  GrowVec func_refs;
  GrowVec imports;
  GrowVec struct_layouts;
  GrowVec top_level_lets;
  GrowVec type_aliases;
  GrowVec module_enums;
  GrowVec import_select_name_rows;
  GrowVec import_select_name_lens;
  GrowVec func_params;
  GrowVec struct_layout_fields;
  /**
   * wave467: layout type-param names (flat) + per-layout meta (base/count).
   * PLATFORM: SHARED — G.7 with pipeline_module_struct_layout_*_type_param_* APIs.
   */
  GrowVec struct_layout_type_params;
  GrowVec struct_layout_type_param_meta;
} ModuleSidecar;

/** M-3：OneFunc 侧车 region 条目。 */
typedef struct {
  uint8_t label[128];
  int32_t label_len;
  int32_t body_ref;
  /** MEM-C1：>0 表示 with_arena(cap)；LANG-007：-1 表示 unsafe { body }。 */
  int32_t with_arena_cap_ref;
} OneFuncRegionEntry;

/**
 * wave379: OneFunc scratch entry for `goto target;` / `label:` / `label: return expr`.
 * Mirrors `struct ast_LabeledStmt` (wave586 Cap: label 128B + is_goto + goto_target 128B + return_expr_ref).
 * PLATFORM: SHARED — filled into Block.labeled_stmts via fill_labeled_from_onefunc;
 * stmt_order kind=7 indexes this pool (G.7 single authority with parse_block path).
 */
typedef struct {
  uint8_t label[128];
  int32_t label_len;
  int32_t is_goto;
  uint8_t goto_target[128];
  int32_t goto_target_len;
  int32_t return_expr_ref;
} OneFuncLabeledEntry;

/** parse_one_function_impl 的 scratch 池，按 OneFuncResult* 键控。 */
typedef struct {
  void *onefunc;
  int used;
  GrowVec if_cond_refs;
  GrowVec if_then_body_refs;
  GrowVec if_else_body_refs;
  GrowVec const_names;
  GrowVec const_name_lens;
  GrowVec const_init_vals;
  GrowVec const_init_refs;
  GrowVec const_type_refs;
  GrowVec let_names;
  GrowVec let_name_lens;
  GrowVec let_init_vals;
  GrowVec let_init_refs;
  GrowVec let_type_refs;
  GrowVec src_stmt_kind;
  GrowVec src_stmt_idx;
  GrowVec src_body_expr_stmt_refs;
  GrowVec while_cond_refs;
  GrowVec while_body_refs;
  GrowVec for_init_refs;
  GrowVec for_cond_refs;
  GrowVec for_step_refs;
  GrowVec for_body_refs;
  /** 解析 scratch 形参（32 字节名 + type_ref）与 call 整型实参。 */
  GrowVec param_names;
  GrowVec param_name_lens;
  GrowVec param_type_refs;
  GrowVec call_arg_vals;
  /** M-3：region label { body } 暂存（parse_one_function_impl → Block 池）。 */
  GrowVec regions;
  /** MEM-B0：defer { body } 暂存（parse_one_function_impl → Block 池）。 */
  GrowVec defer_body_refs;
  /** wave379: goto/label labeled_stmts scratch → Block pool (stmt_order kind=7). */
  GrowVec labeleds;
} OneFuncSidecar;

/** PipelineDepCtx 侧车：dep 槽与 -L lib_root 动态 grow（ctx 指针作键）。 */
typedef struct {
  struct ast_PipelineDepCtx *ctx;
  int used;
  GrowVec dep_modules;
  GrowVec dep_arenas;
  GrowVec dep_path_rows;
  GrowVec dep_path_lens;
  GrowVec lib_root_rows;
  GrowVec lib_root_lens;
  /** codegen 无名形参 param 下标；backup 供 emit 函数内 save/restore。 */
  GrowVec empty_param_indices;
  GrowVec empty_param_backup;
} DepCtxSidecar;

/** driver -x -E / check compile argv: DriverCompileState* (or emit state) keyed lib_root pool.
 *
 * wave1243: slots were never released when heap `driver_compile_state_free_c` ran.
 * Directory `xlang check` allocs a unique state per file → after 32 files every
 * sidecar is occupied, `driver_emit_append_lib_root` fails, -L roots vanish, and
 * import resolve falls back to a stale/wrong entry_dir (often reporting paths under
 * `.../asm/http/...` as IMP001). PLATFORM: SHARED — mac + Ubuntu check matrix.
 */
typedef struct {
  void *state;
  int used;
  GrowVec lib_root_rows;
  GrowVec lib_root_lens;
} DriverEmitSidecar;

#include "ast_pool_sidecar_pool.c"

static struct ast_Block *block_at(struct ast_ASTArena *a, int32_t br) {
  ArenaSidecar *sc;
  if (!a || br <= 0 || br > a->num_blocks)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Block *)grow_vec_at(&sc->blocks, br - 1);
}

static struct ast_StructLayout *module_layout_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_struct_layouts)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return NULL;
  return (struct ast_StructLayout *)grow_vec_at(&sc->struct_layouts, idx);
}

static ImportEntry *module_import_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_imports)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return NULL;
  return (ImportEntry *)grow_vec_at(&sc->imports, idx);
}

/** 前向声明：pipeline_arena_block_alloc 在定义前调用。 */
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
 * core residual: backend asm wrappers + fill_* decls / path helpers / module enum … */

/** ---------- Module import / struct_layout / top_level / enum 动态池 ---------- */

/** BC 8.3.2: module ImportEntry cold-twin accessors (same-TU thin). */
#include "ast_pool_module_import.c"

/** BC 8.3.2: module StructLayout cold accessors (same-TU thin). */
#include "ast_pool_struct_layout.c"

/** BC 8.3.2 wave980+993+994: TopLevelLetEntry + name_is_const/hoist + hoist_target/sum. */
#include "ast_pool_top_level.c"

/** BC 8.3.2: module TypeAliasEntry cold accessors (same-TU thin). */
#include "ast_pool_type_alias.c"

/** seed partial（build_seed_asm_host）导出的 mega 全量实现；勿与薄包装 backend_asm_codegen_ast 混调（会递归）。 */
extern int32_t backend_asm_codegen_ast_seed_mega(struct ast_Module *m, struct ast_ASTArena *a,
                                                 struct codegen_CodegenOutBuf *out,
                                                 struct ast_PipelineDepCtx *pipeline_ctx);
extern int32_t backend_asm_codegen_ast_to_elf_seed_mega(struct ast_Module *m, struct ast_ASTArena *a,
                                                        struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                        struct ast_PipelineDepCtx *pipeline_ctx);
extern void pipeline_asm_emit_set_elf_ctx(struct platform_elf_ElfCodegenCtx *elf_ctx);
extern void pipeline_asm_emit_set_dep_pipe(struct ast_PipelineDepCtx *ctx);
extern void pipeline_asm_emit_set_module(struct ast_Module *m);
extern void pipeline_asm_emit_set_arena(struct ast_ASTArena *arena);

/**
 * M8-tail：`asm_codegen_ast` 薄包装 C 委托；顶层 let hoist 后调 seed partial mega。
 */
int32_t pipeline_backend_asm_codegen_ast_c(struct ast_Module *m, struct ast_ASTArena *a,
                                            struct codegen_CodegenOutBuf *out,
                                            struct ast_PipelineDepCtx *pipeline_ctx) {
  if (!m || !a || !out || !pipeline_ctx)
    return -1;
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  return backend_asm_codegen_ast_seed_mega(m, a, out, pipeline_ctx);
}

/** skip .x typeck 时 dep/entry 各模块 emit 前补 ARRAY_LIT / SoA 字段类型（定义见 pipeline_glue.c 后部）。 */
void pipeline_fill_array_lit_types_for_skipped_typeck(struct ast_Module *m, struct ast_ASTArena *arena);
void pipeline_fill_soa_field_access_for_asm_emit(struct ast_Module *m, struct ast_ASTArena *arena);
extern void pipeline_debug_trace_named_func_bodies(const char *phase, void *module, void *arena);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                              struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);

/** EMIT_HEAVY parser 模块判定（定义见本文件后部 static 实现）。 */
static int32_t asm_module_is_parser_emit_heavy(struct ast_Module *m);

/**
 * M8-tail：`asm_codegen_ast_to_elf` 薄包装 C 委托；顶层 let hoist 后调 seed partial mega。
 */
int32_t pipeline_backend_asm_codegen_ast_to_elf_c(struct ast_Module *m, struct ast_ASTArena *a,
                                                   struct platform_elf_ElfCodegenCtx *elf_ctx,
                                                   struct ast_PipelineDepCtx *pipeline_ctx) {
  int32_t rc;
  if (!m || !a || !elf_ctx || !pipeline_ctx)
    return -1;
  pipeline_debug_trace_named_func_bodies("backend_pre_hoist_top_level_lets", m, a);
  if (m->num_top_level_lets > 0)
    pipeline_module_hoist_top_level_lets_into_main(m, a);
  pipeline_debug_trace_named_func_bodies("backend_post_hoist_top_level_lets", m, a);
  /** DOD-S3：skip .x typeck 时仍须 dep SoA layout 并入 entry + 全图升档，再 fill stride。 */
  pipeline_debug_trace_named_func_bodies("backend_pre_merge_dep_layouts", m, a);
  typeck_typeck_merge_dep_struct_layouts_into_entry(m, a, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_merge_dep_layouts", m, a);
  typeck_typeck_wpo_unify_soa_layouts(m, pipeline_ctx);
  pipeline_debug_trace_named_func_bodies("backend_post_unify_soa_layouts", m, a);
  /** dep co-emit 与 entry 均须 SoA stride / 形参类型 / FIELD_ACCESS 偏移，否则跨模块 call 链 SIGSEGV。 */
  pipeline_asm_emit_set_dep_pipe(pipeline_ctx);
  pipeline_fill_array_lit_types_for_skipped_typeck(m, a);
  pipeline_fill_soa_field_access_for_asm_emit(m, a);
  if (link_abi_getenv("XLANG_ASM_DEBUG"))
    fprintf(stderr, "xlang: backend_asm_codegen fill done, calling mega_body_c\n");
  glue_wpo_mono_reset_pending();
  /** dep+entry 顺序写入同一 elf_ctx：为 tail_join/loop 等局部标签分配唯一 scope。 */
  pipeline_elf_label_mod_scope_begin_module();
  /** WPO-S3：import struct FIELD_ACCESS 查 layout 时须可见 dep 池（backend.x mega 亦会设置）。 */
  pipeline_asm_emit_set_module(m);
  pipeline_asm_emit_set_arena(a);
  pipeline_asm_emit_set_elf_ctx(elf_ctx);
  if (link_abi_getenv("XLANG_ASM_DEBUG") && m && asm_module_is_parser_emit_heavy(m))
    fprintf(stderr, "xlang: seed_mega parser nfunc=%d elf_ctx=%p code_len=%d\n", (int)m->num_funcs, (void *)elf_ctx,
            elf_ctx ? (int)elf_ctx->code_len : -1);
  rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
  pipeline_asm_emit_set_elf_ctx(NULL);
  if (rc != 0)
    return rc;
  return pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
}

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

/** codegen.x：路径/前缀 scratch（避免 `u8[64] = []` 在 asm emit 时 ExprKind=-1）。 */
static uint8_t g_scratch64[4][128];
static uint8_t g_scratch128[2][128];
static uint8_t g_scratch256[2][256];

uint8_t *pipeline_scratch_buf64(void) {
  return g_scratch64[0];
}

uint8_t *pipeline_scratch_buf64_slot(int32_t slot) {
  if (slot < 0 || slot >= 4)
    return g_scratch64[0];
  return g_scratch64[slot];
}

uint8_t *pipeline_scratch_buf128(void) {
  return g_scratch128[0];
}

uint8_t *pipeline_scratch_buf128_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_scratch128[0];
  return g_scratch128[slot];
}

uint8_t *pipeline_scratch_buf96(void) {
  static uint8_t s[96];
  return s;
}

uint8_t *pipeline_scratch_buf256(void) {
  return g_scratch256[0];
}

uint8_t *pipeline_scratch_buf256_slot(int32_t slot) {
  if (slot < 0 || slot >= 2)
    return g_scratch256[0];
  return g_scratch256[slot];
}

#include "pipeline_codegen_type_to_c.c"

#include "pipeline_codegen_struct_emit.c"

#include "pipeline_codegen_skip_force.c"

#include "pipeline_codegen_residual.c"

#include "pipeline_asm_locals.c"

#include "pipeline_asm_slot_bytes.c"

#include "pipeline_asm_block_tree.c"

#include "pipeline_asm_ctx_loop.c"

/** 块树 const+let 槽超过此阈值时 asm 完整 emit 易在宿主栈溢出（lexer 前几项函数亦可能 <160 funcs）。 */
#define ASM_HEAVY_BODY_SLOT_THRESHOLD 48
/** EMIT_HEAVY 第二遍放宽槽位（layout helper）；仍低于 mega typecheck 体。 */
#define ASM_EMIT_HEAVY_SLOT_THRESHOLD 256
/** backend.x 自举（含 import 展开 ~219 func）：#87–218 索引桩；#0–86 小 helper 真 emit。 */
#define ASM_EMIT_HEAVY_BACKEND_INDEX_LO 87
#define ASM_EMIT_HEAVY_BACKEND_INDEX_HI 218
/** typeck.x ~173 func：#90–159 深 emit Abort；#0–89 layout/helper 与 #160+ 可真 emit 扩 __text。 */
#define ASM_EMIT_HEAVY_TYPECK_INDEX_LO 90
#define ASM_EMIT_HEAVY_TYPECK_INDEX_HI 159
/** pipeline.x ~56 func：编排入口 #53–#55 须真 emit；索引桩已移除，靠 pipeline_expr_* 消除 Expr 栈拷贝。 */
/** XLANG_ASM_EMIT_ABORT_LO/HI 默认（backend 二分调试）。 */
#define ASM_EMIT_HEAVY_LARGE_ENTRY_LO ASM_EMIT_HEAVY_BACKEND_INDEX_LO
#define ASM_EMIT_HEAVY_LARGE_ENTRY_HI ASM_EMIT_HEAVY_BACKEND_INDEX_HI

/** 大入口 backend（num_funcs>=175）EMIT_HEAVY 槽位阈值（较默认 256 收紧，避免 codegen 宿主栈 Abort）。 */
#define ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD 96
/** backend helper 白名单真 emit 时块树槽位上限（过大仍走索引桩）。 */
#define ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX 48
/** typeck layout helper 允许略大栈帧（merge_dep 双循环 ~110 slot；仍远小于 check_block mega）。 */
#define ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX 128

/** 读 XLANG_ASM_EMIT_ABORT_LO/HI：调试二分定位 Abort 区间（默认见上常量）。 */
static int32_t asm_emit_heavy_abort_lo(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_LO");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_LARGE_ENTRY_LO;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_LARGE_ENTRY_LO;
  return (int32_t)v;
}

static int32_t asm_emit_heavy_abort_hi(void) {
  const char *e = link_abi_getenv("XLANG_ASM_EMIT_ABORT_HI");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_LARGE_ENTRY_HI;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_LARGE_ENTRY_HI;
  return (int32_t)v;
}

/**
 * 与 typeck.x::typeck_skip_heavy_selfhost_func_body 对齐，并据块树槽位数自动跳过超大函数体。
 * 库模块 -backend asm -o 时改发最小 ret 0 桩，保证 __text 非空且编译不 SIGSEGV。
 */
/**
 * 模块顶层 let/const 若为整型字面量初始化，返回 1 并写入 *out_imm（供 asm EXPR_VAR 直接 mov imm）。
 */
#ifndef XLANG_PIPELINE_GLUE_STANDALONE_TU
/** runtime.c：dep 模块 asm codegen 时设置的当前 import 逻辑路径（常规 pipeline_x 链）。 */
extern const char *driver_get_current_dep_path_for_codegen(void);
#endif

/**
 * 供 backend.x 读取 dep 路径（避免经 codegen 模块名修饰导致链接符号不一致）。
 * B-strict standalone TU 下 driver_get 由 pipeline_glue_types.inc 声明为 uint8_t *。
 */
uint8_t *asm_driver_current_dep_path_for_codegen(void) {
#ifndef XLANG_PIPELINE_GLUE_STANDALONE_TU
  const char *p = driver_get_current_dep_path_for_codegen();
  return (uint8_t *)(p ? p : "");
#else
  uint8_t *p = driver_get_current_dep_path_for_codegen();
  return p ? p : (uint8_t *)"";
#endif
}

/**
 * 将 import 路径转为 C 符号前缀（与 codegen.c::import_path_to_c_prefix 一致）。
 */
void asm_import_path_to_c_prefix_into(uint8_t *path, uint8_t *buf, int32_t buf_cap) {
  int32_t off = 0;
  int32_t pi = 0;
  if (!buf || buf_cap <= 0)
    return;
  if (!path) {
    buf[0] = '\0';
    return;
  }
  while (path[pi] != 0 && off + 2 < buf_cap) {
    buf[off++] = (uint8_t)(path[pi] == '.' ? '_' : path[pi]);
    pi++;
  }
  if (off + 1 < buf_cap)
    buf[off++] = '_';
  buf[off] = 0;
}

int32_t asm_module_top_level_const_lit_i32(struct ast_Module *m, struct ast_ASTArena *a, uint8_t *name,
    int32_t name_len, int32_t *out_imm) {
  int32_t tl;
  int32_t nl;
  int32_t k;
  int32_t init_ref;
  if (!m || !a || !name || name_len <= 0 || !out_imm)
    return 0;
  for (tl = 0; tl < m->num_top_level_lets; tl++) {
    nl = pipeline_module_top_level_let_name_len(m, tl);
    if (nl != name_len || nl <= 0)
      continue;
    for (k = 0; k < name_len; k++) {
      if (pipeline_module_top_level_let_name_byte_at(m, tl, k) != name[k])
        break;
    }
    if (k != name_len)
      continue;
    init_ref = pipeline_module_top_level_let_init_ref(m, tl);
    if (init_ref <= 0 || init_ref > a->num_exprs)
      continue;
    k = pipeline_expr_kind_ord_at(a, init_ref);
    if (k == 0 || k == 2) {
      *out_imm = pipeline_expr_int_val_at(a, init_ref);
      return 1;
    }
  }
  return 0;
}

/** XLANG_ASM_BUILD_SKIP_TYPECK=1 时 build_xlang_asm 走桩路径，避免无 typeck 的大模块 asm emit 栈溢出。 */
static int32_t asm_env_build_skip_typeck(void) {
  const char *e = link_abi_getenv("XLANG_ASM_BUILD_SKIP_TYPECK");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** XLANG_ASM_STRICT_ORCHESTRATION=1 时 C 编排链才跳过 pipeline 大函数 emit（默认 build_asm 须落真机器码）。 */
static int32_t asm_env_strict_orchestration(void) {
  const char *e = link_abi_getenv("XLANG_ASM_STRICT_ORCHESTRATION");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** parser 自举白名单条目：{ name, len }，minimal/full 数组须同一 typedef（MSYS2 -Wincompatible-pointer-types）。 */
typedef struct {
  const char *name;
  int32_t len;
} asm_boot_parse_sym_t;

/** 非 0 表示入口源码过大，merge/library typeck 等应跳过（runtime.c）。 */
extern int32_t driver_typeck_skip_large_entry(void);

/** 前向声明：parser 自举判定（定义在 asm_module_is_pipeline_selfhost 之后）。 */
static int32_t asm_module_is_parser_selfhost(struct ast_Module *m);

/**
 * SKIP_TYPECK 全桩模式下仍须保留真实机器码的入口（实验 asm-only 链与 xlang_asm 烟囱测试依赖）。
 * 返回 1 表示该函数不应被 asm_skip_heavy 桩掉。
 * 大模块（如 backend.x）自身也定义 asm_codegen_ast，若对其完整 emit 会在宿主栈上 abort。
 */
static int32_t asm_skip_typeck_entry_whitelist(struct ast_Module *m, int32_t func_index) {
  static const struct {
    const char *name;
    int32_t len;
    int32_t allow_on_large_entry;
  } k_keep[] = {
      /** parse_into_with_init_buf 真 emit 深栈 SIGSEGV；build 链由 parser.o / C alias 提供。 */
      {"pipeline_impl_run_all", 21, 1},
      {"run_x_pipeline_impl", 19, 1},
      {"pipeline_impl_should_skip_codegen", 33, 1},
      {"pipeline_impl_phase_parse_load", 30, 1},
      {"pipeline_impl_phase_parse_only", 30, 1},
      {"pipeline_impl_phase_load_deps", 29, 1},
      /** typecheck 可单独 whitelist；phase_codegen 会 139。 */
      {"pipeline_impl_typecheck", 23, 1},
      {"pipeline_impl_codegen_deps", 26, 1},
      {"pipeline_impl_codegen_entry", 27, 1},
      /** codegen_chain 替代 phase_codegen（后者单独 emit 139）。 */
      {"pipeline_impl_codegen_chain", 27, 1},
      /** parser.x：strict 链 pipeline.parse_into_with_init_buf 依赖 parser.parse_into_buf 真机器码。 */
      {"parse_into_init", 15, 1},
      {"parse_into_set_main_index", 25, 1},
      {"collect_imports_buf", 19, 1},
      {"parse_into_buf", 14, 1},
      /** 大入口（>150KiB）上 typeck/asm 入口完整 emit 会栈溢出；SKIP 桩即可，编库不跑这些符号。 */
      {"typeck_x_ast", 12, 0},
      {"typeck_x_ast_library", 20, 0},
      {"asm_codegen_ast", 15, 0},
      /** main.x build_asm/main.o：entry 须真 emit（WPO root + crt0 链）。 */
      {"entry", 5, 1},
  };
  int32_t k;
  int32_t large_entry;
  if (!m || func_index < 0)
    return 0;
  /**
   * parser.x 自举编 module 时勿 whitelist 真 emit（parse_into_init 等会 expr emit 失败）；
   * strict 链 parse_into_* 由 pipeline_x partial / C alias 提供。
   * XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1：experimental 编 parser_parse_bootstrap.o 须 parse_into* 真 emit。
   */
  if (asm_module_is_parser_selfhost(m)) {
    if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") != NULL) {
      static const asm_boot_parse_sym_t k_boot_parse_minimal[] = {
          {"parse_into_init", 15},
          {"parse_into_set_main_index", 25},
      };
      static const asm_boot_parse_sym_t k_boot_parse_full[] = {
          {"parse_into_buf", 14},
          {"parse_into", 10},
          {"parse_into_init", 15},
          {"parse_into_set_main_index", 25},
          {"collect_imports_buf", 19},
      };
      const asm_boot_parse_sym_t *k_boot_parse;
      int32_t k_boot_n;
      int32_t bi;
      if (link_abi_getenv("XLANG_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
        k_boot_parse = k_boot_parse_minimal;
        k_boot_n = (int32_t)(sizeof(k_boot_parse_minimal) / sizeof(k_boot_parse_minimal[0]));
      } else {
        k_boot_parse = k_boot_parse_full;
        k_boot_n = (int32_t)(sizeof(k_boot_parse_full) / sizeof(k_boot_parse_full[0]));
      }
      for (bi = 0; bi < k_boot_n; bi++) {
        if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_boot_parse[bi].name, k_boot_parse[bi].len))
          return 1;
      }
    }
    return 0;
  }
  large_entry = driver_typeck_skip_large_entry();
  for (k = 0; k < (int32_t)(sizeof(k_keep) / sizeof(k_keep[0])); k++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_keep[k].name, k_keep[k].len)) {
      if (k_keep[k].allow_on_large_entry == 0 && large_entry != 0)
        return 0;
      return 1;
    }
  }
  return 0;
}

/**
 * strict asm 编排：本 TU 不 emit 该函数体/标签，call 走 Mach-O/ELF reloc 链 C alias。
 * 若仍落本地符号，ld -r partial 内 bl 会绑定到错误 asm 实现（typecheck if/else 不完整 → null module）。
 */
int32_t asm_orchestration_extern_only_func(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  /** 默认 B-strict 链用 build_asm pipeline.o 真 emit；仅 C 编排实验链才 extern-only。 */
  if (asm_env_strict_orchestration() == 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_typecheck", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_into_with_init_buf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_phase_parse_load", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_impl_run_all", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 19))
    return 1;
  return 0;
}

/** 当前 asm codegen 的 PipelineDepCtx；backend.x 在 emit 循环前设置，供 ENTRY_MODULE_ONLY 入口 -o 判定。 */
static struct ast_PipelineDepCtx *g_asm_skip_pipeline_ctx;

void asm_skip_heavy_set_pipeline_ctx(struct ast_PipelineDepCtx *ctx) {
  g_asm_skip_pipeline_ctx = ctx;
}

/** XLANG_ASM_ENTRY_EMIT_HEAVY=1 时 ENTRY_MODULE_ONLY 真 emit（typeck 第二遍）；仅跳过 pipeline typecheck。 */
static int32_t asm_env_entry_emit_heavy(void) {
  const char *e = link_abi_getenv("XLANG_ASM_ENTRY_EMIT_HEAVY");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

#include "pipeline_asm_selfhost.c"

/** 函数名前缀匹配（module func 池按字节比较）。 */
static int32_t pipeline_module_func_name_has_prefix_at(struct ast_Module *m, int32_t fi, const char *pfx,
    int32_t plen) {
  int32_t nl;
  int32_t k;
  if (!m || fi < 0 || !pfx || plen <= 0)
    return 0;
  nl = pipeline_module_func_name_len_at(m, fi);
  if (nl < plen)
    return 0;
  for (k = 0; k < plen; k++) {
    if (pipeline_module_func_name_byte_at(m, fi, k) != (uint8_t)pfx[k])
      return 0;
  }
  return 1;
}

#include "pipeline_asm_emit_heavy_safe_helper.c"


#include "pipeline_asm_thin_delegate.c"


#include "pipeline_asm_parser_emit_heavy.c"


#include "pipeline_asm_skip_dispatch.c"

#include "pipeline_asm_diag.c"

#include "pipeline_asm_wpo.c"

/** bootstrap 链接 glue：pipeline 编排 / asm scope / typeck 指针写槽（误 revert 后补全）。 */
#include "ast_pool_bootstrap_glue.c"
