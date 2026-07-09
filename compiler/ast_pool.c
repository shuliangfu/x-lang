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
#include "diag.h"

#ifndef AST_POOL_GROW
#define AST_POOL_GROW 64
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
  uint8_t binding_name[64];
  int32_t binding_name_len;
  /** import { a, b } 名称在 module 侧车 select 池中的起始下标 */
  int32_t select_base;
  int32_t select_count;
} ImportEntry;

/** match 单臂（Expr 侧车池）。 */
typedef struct {
  int32_t result_ref;
  int32_t is_wildcard;
  int32_t lit_val;
  int32_t is_enum_variant;
  int32_t variant_index;
} MatchArmEntry;

/** struct literal 单字段（Expr 侧车池）。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t init_ref;
} StructLitFieldEntry;

/** 函数形参槽（module/arena sidecar func_params 池）。 */
typedef struct {
  uint8_t name[32];
  int32_t name_len;
  int32_t type_ref;
} FuncParamEntry;

/** struct_layout 单字段槽（module sidecar struct_layout_fields 池）。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t field_offset;
  int32_t type_ref;
  /** DOD-CL：字段最小对齐（align(N)）；0 表示仅按类型自然对齐。 */
  int32_t field_align;
} StructLayoutFieldEntry;

/** 顶层 let/const 槽。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
  int32_t is_const;
} TopLevelLetEntry;

/** 顶层 type 别名槽：type Alias = Target;（纯 typeck 别名，codegen typedef）。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t target_type_ref;
} TypeAliasEntry;

/** 顶层 enum 名槽；变体名在 parse 跳过 enum { A, B } 时登记，供 asm Color.Green 等发射 tag。 */
#define MODULE_ENUM_MAX_VARIANTS 32
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t num_variants;
  uint8_t variant_name[MODULE_ENUM_MAX_VARIANTS][64];
  int32_t variant_name_len[MODULE_ENUM_MAX_VARIANTS];
} ModuleEnumEntry;

/** 通用 grow 向量：元素大小 elem_sz，失败返回 0。 */
typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
} GrowVec;

static int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap) {
  v->data = NULL;
  v->cap = 0;
  v->len = 0;
  v->elem_sz = elem_sz;
  if (initial_cap <= 0)
    initial_cap = AST_POOL_GROW;
  v->data = (uint8_t *)calloc((size_t)initial_cap, elem_sz);
  if (!v->data)
    return 0;
  v->cap = initial_cap;
  return 1;
}

static void grow_vec_free(GrowVec *v) {
  if (v && v->data) {
    free(v->data);
    v->data = NULL;
  }
  if (v) {
    v->cap = 0;
    v->len = 0;
  }
}

/** 确保 len 可再追加 1 个元素；成功返回 1。 */
static int grow_vec_ensure(GrowVec *v) {
  int32_t need;
  int32_t nc;
  uint8_t *p;
  if (!v)
    return 0;
  need = v->len + 1;
  if (need <= v->cap)
    return 1;
  nc = v->cap > 0 ? v->cap : AST_POOL_GROW;
  while (nc < need)
    nc += AST_POOL_GROW;
  p = (uint8_t *)realloc(v->data, (size_t)nc * v->elem_sz);
  if (!p)
    return 0;
  memset(p + (size_t)v->cap * v->elem_sz, 0, (size_t)(nc - v->cap) * v->elem_sz);
  v->data = p;
  v->cap = nc;
  return 1;
}

static void *grow_vec_at(GrowVec *v, int32_t idx) {
  if (!v || !v->data || idx < 0 || idx >= v->len)
    return NULL;
  return v->data + (size_t)idx * v->elem_sz;
}

/** 追加零初始化元素，返回新下标；失败返回 -1。 */
static int32_t grow_vec_push(GrowVec *v) {
  int32_t idx;
  if (!grow_vec_ensure(v))
    return -1;
  idx = v->len;
  memset(v->data + (size_t)idx * v->elem_sz, 0, v->elem_sz);
  v->len++;
  return idx;
}

/** M-3：region label { body } 侧车槽（与 C ASTRegionBlock 语义一致）。 */
typedef struct {
  uint8_t label[64];
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
} ModuleSidecar;

/** M-3：OneFunc 侧车 region 条目。 */
typedef struct {
  uint8_t label[64];
  int32_t label_len;
  int32_t body_ref;
  /** MEM-C1：>0 表示 with_arena(cap)；LANG-007：-1 表示 unsafe { body }。 */
  int32_t with_arena_cap_ref;
} OneFuncRegionEntry;

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

/** driver -x -E  argv 解析：DriverXEmitState* 键控 lib_root grow 池。 */
typedef struct {
  void *state;
  int used;
  GrowVec lib_root_rows;
  GrowVec lib_root_lens;
} DriverEmitSidecar;

#define MAX_DRIVER_EMIT_SIDECARS 32

#define MAX_DEP_CTX_SIDECARS 64
#define MAX_ARENA_SIDECARS 512
#define MAX_MODULE_SIDECARS 512
#define MAX_ONEFUNC_SIDECARS 256

static ArenaSidecar g_arena_sc[MAX_ARENA_SIDECARS];
static ModuleSidecar g_module_sc[MAX_MODULE_SIDECARS];
static OneFuncSidecar g_onefunc_sc[MAX_ONEFUNC_SIDECARS];
static DepCtxSidecar g_depctx_sc[MAX_DEP_CTX_SIDECARS];
static DriverEmitSidecar g_driver_emit_sc[MAX_DRIVER_EMIT_SIDECARS];

static DepCtxSidecar *depctx_sidecar_get(struct ast_PipelineDepCtx *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (g_depctx_sc[i].used && g_depctx_sc[i].ctx == ctx)
      return &g_depctx_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DEP_CTX_SIDECARS; i++) {
    if (!g_depctx_sc[i].used) {
      g_depctx_sc[i].ctx = ctx;
      g_depctx_sc[i].used = 1;
      if (!grow_vec_init(&g_depctx_sc[i].dep_modules, sizeof(void *), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_depctx_sc[i].dep_arenas, sizeof(void *), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_depctx_sc[i].dep_path_rows, 64, AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_depctx_sc[i].dep_path_lens, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_depctx_sc[i].lib_root_rows, 256, AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_depctx_sc[i].lib_root_lens, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_depctx_sc[i].empty_param_indices, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_depctx_sc[i].empty_param_backup, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      return &g_depctx_sc[i];
    }
  }
  return NULL;
}

/** 确保 dep 侧车池至少有 idx+1 个槽。 */
static int depctx_ensure_slot(DepCtxSidecar *sc, int32_t idx) {
  int32_t need;
  void **pm;
  void **pa;
  uint8_t *row;
  int32_t *pl;
  if (!sc || idx < 0)
    return 0;
  need = idx + 1;
  while (sc->dep_modules.len < need) {
    if (grow_vec_push(&sc->dep_modules) < 0)
      return 0;
    pm = (void **)grow_vec_at(&sc->dep_modules, sc->dep_modules.len - 1);
    if (pm)
      *pm = NULL;
    if (grow_vec_push(&sc->dep_arenas) < 0)
      return 0;
    pa = (void **)grow_vec_at(&sc->dep_arenas, sc->dep_arenas.len - 1);
    if (pa)
      *pa = NULL;
    if (grow_vec_push(&sc->dep_path_rows) < 0)
      return 0;
    row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, sc->dep_path_rows.len - 1);
    if (row)
      memset(row, 0, 64);
    if (grow_vec_push(&sc->dep_path_lens) < 0)
      return 0;
    pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, sc->dep_path_lens.len - 1);
    if (pl)
      *pl = 0;
  }
  return 1;
}

static ArenaSidecar *arena_sidecar_get(struct ast_ASTArena *a, int create) {
  int i;
  if (!a)
    return NULL;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (g_arena_sc[i].used && g_arena_sc[i].arena == a)
      return &g_arena_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ARENA_SIDECARS; i++) {
    if (!g_arena_sc[i].used) {
      g_arena_sc[i].arena = a;
      g_arena_sc[i].used = 1;
      if (!grow_vec_init(&g_arena_sc[i].types, sizeof(struct ast_Type), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].exprs, sizeof(struct ast_Expr), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].blocks, sizeof(struct ast_Block), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].funcs, sizeof(struct ast_Func), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].consts, sizeof(struct ast_ConstDecl), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].lets, sizeof(struct ast_LetDecl), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].ifs, sizeof(struct ast_IfStmt), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].regions, sizeof(RegionBlockEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].loops, sizeof(struct ast_WhileLoop), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].for_loops, sizeof(struct ast_ForLoop), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].defer_block_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].labeled_stmts, sizeof(struct ast_LabeledStmt), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_stmt_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].stmt_order, sizeof(struct ast_StmtOrderItem), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_call_arg_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_method_call_arg_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_match_arms, sizeof(MatchArmEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_struct_lit_fields, sizeof(StructLitFieldEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].expr_array_lit_elem_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_arena_sc[i].func_params, sizeof(FuncParamEntry), AST_POOL_GROW))
        return NULL;
      return &g_arena_sc[i];
    }
  }
  return NULL;
}

static ModuleSidecar *module_sidecar_get(struct ast_Module *m, int create) {
  int i;
  if (!m)
    return NULL;
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (g_module_sc[i].used && g_module_sc[i].module == m)
      return &g_module_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_MODULE_SIDECARS; i++) {
    if (!g_module_sc[i].used) {
      g_module_sc[i].module = m;
      g_module_sc[i].used = 1;
      if (!grow_vec_init(&g_module_sc[i].funcs, sizeof(struct ast_Func), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].func_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].imports, sizeof(ImportEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layouts, sizeof(struct ast_StructLayout), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].top_level_lets, sizeof(TopLevelLetEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].type_aliases, sizeof(TypeAliasEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].module_enums, sizeof(ModuleEnumEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].import_select_name_rows, 64, AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].import_select_name_lens, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].func_params, sizeof(FuncParamEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_module_sc[i].struct_layout_fields, sizeof(StructLayoutFieldEntry), AST_POOL_GROW))
        return NULL;
      return &g_module_sc[i];
    }
  }
  return NULL;
}

static OneFuncSidecar *onefunc_sidecar_get(uint8_t *out, int create) {
  int i;
  if (!out)
    return NULL;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (g_onefunc_sc[i].used && g_onefunc_sc[i].onefunc == out)
      return &g_onefunc_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (!g_onefunc_sc[i].used) {
      g_onefunc_sc[i].onefunc = out;
      g_onefunc_sc[i].used = 1;
      if (!grow_vec_init(&g_onefunc_sc[i].if_cond_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].if_then_body_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].if_else_body_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_names, 64, AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_name_lens, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_init_vals, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_init_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].const_type_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_names, 64, AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_name_lens, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_init_vals, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_init_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].let_type_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_stmt_kind, sizeof(uint8_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_stmt_idx, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].src_body_expr_stmt_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].while_cond_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].while_body_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_init_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_cond_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_step_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].for_body_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].param_names, 32, AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].param_name_lens, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].param_type_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].call_arg_vals, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].regions, sizeof(OneFuncRegionEntry), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_onefunc_sc[i].defer_body_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      return &g_onefunc_sc[i];
    }
  }
  return NULL;
}

static void onefunc_sidecar_free(OneFuncSidecar *sc) {
  if (!sc)
    return;
  grow_vec_free(&sc->if_cond_refs);
  grow_vec_free(&sc->if_then_body_refs);
  grow_vec_free(&sc->if_else_body_refs);
  grow_vec_free(&sc->const_names);
  grow_vec_free(&sc->const_name_lens);
  grow_vec_free(&sc->const_init_vals);
  grow_vec_free(&sc->const_init_refs);
  grow_vec_free(&sc->const_type_refs);
  grow_vec_free(&sc->let_names);
  grow_vec_free(&sc->let_name_lens);
  grow_vec_free(&sc->let_init_vals);
  grow_vec_free(&sc->let_init_refs);
  grow_vec_free(&sc->let_type_refs);
  grow_vec_free(&sc->src_stmt_kind);
  grow_vec_free(&sc->src_stmt_idx);
  grow_vec_free(&sc->src_body_expr_stmt_refs);
  grow_vec_free(&sc->while_cond_refs);
  grow_vec_free(&sc->while_body_refs);
  grow_vec_free(&sc->for_init_refs);
  grow_vec_free(&sc->for_cond_refs);
  grow_vec_free(&sc->for_step_refs);
  grow_vec_free(&sc->for_body_refs);
  grow_vec_free(&sc->param_names);
  grow_vec_free(&sc->param_name_lens);
  grow_vec_free(&sc->param_type_refs);
  grow_vec_free(&sc->call_arg_vals);
  grow_vec_free(&sc->regions);
  grow_vec_free(&sc->defer_body_refs);
  memset(sc, 0, sizeof(*sc));
}

static struct ast_Block *block_at(struct ast_ASTArena *a, int32_t br) {
  ArenaSidecar *sc;
  if (!a || br <= 0 || br > a->num_blocks)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Block *)grow_vec_at(&sc->blocks, br - 1);
}

/** C/glue 用：主池元素指针；无效 ref 返回 NULL。 */
struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref) {
  ArenaSidecar *sc;
  if (!a || ref <= 0 || ref > a->num_types)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Type *)grow_vec_at(&sc->types, ref - 1);
}

struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref) {
  ArenaSidecar *sc;
  if (!a || ref <= 0 || ref > a->num_exprs)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Expr *)grow_vec_at(&sc->exprs, ref - 1);
}

struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref) {
  return block_at(a, ref);
}

struct ast_Func *pipeline_arena_func_ptr(struct ast_ASTArena *a, int32_t ref) {
  ArenaSidecar *sc;
  if (!a || ref <= 0 || ref > a->num_funcs)
    return NULL;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return NULL;
  return (struct ast_Func *)grow_vec_at(&sc->funcs, ref - 1);
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

/** 主池 alloc/get/set（无固定上限）。 */
int32_t pipeline_arena_type_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->types) < 0)
    return 0;
  a->num_types = sc->types.len;
  return a->num_types;
}

int32_t pipeline_arena_expr_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->exprs) < 0)
    return 0;
  a->num_exprs = sc->exprs.len;
  return a->num_exprs;
}

int32_t pipeline_arena_block_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  int32_t br;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->blocks) < 0)
    return 0;
  a->num_blocks = sc->blocks.len;
  br = a->num_blocks;
  ast_pool_block_on_alloc(a, br);
  return br;
}

int32_t pipeline_arena_func_alloc(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  struct ast_Func *f;
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->funcs) < 0)
    return 0;
  f = (struct ast_Func *)grow_vec_at(&sc->funcs, sc->funcs.len - 1);
  if (f)
    memset(f, 0, sizeof(*f));
  a->num_funcs = sc->funcs.len;
  return a->num_funcs;
}

struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Type empty;
  struct ast_Type *tp;
  memset(&empty, 0, sizeof(empty));
  tp = pipeline_arena_type_ptr(a, ref);
  return tp ? *tp : empty;
}

void pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  struct ast_Type *tp = pipeline_arena_type_ptr(a, ref);
  if (tp)
    *tp = t;
}

struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Expr empty;
  struct ast_Expr *ep;
  memset(&empty, 0, sizeof(empty));
  ep = pipeline_arena_expr_ptr(a, ref);
  return ep ? *ep : empty;
}

void pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  struct ast_Expr *ep = pipeline_arena_expr_ptr(a, ref);
  const char *trace_expr = getenv("SHUX_TRACE_EXPR_SET");
  const char *trace_name = getenv("SHUX_TRACE_EXPR_NAME");
  const char *trace_type = getenv("SHUX_TRACE_TYPE_REF");
  int trace_hit = 0;
  if (trace_expr && *trace_expr && atoi(trace_expr) == ref)
    trace_hit = 1;
  if (!trace_hit && trace_name && *trace_name && e.var_name_len > 0) {
    size_t want_len = strlen(trace_name);
    if ((int32_t)want_len == e.var_name_len && want_len < sizeof(e.var_name) &&
        memcmp(e.var_name, trace_name, want_len) == 0)
      trace_hit = 1;
  }
  if (!trace_hit && trace_type && *trace_type) {
    int trace_ty = atoi(trace_type);
    if (trace_ty != 0 && e.resolved_type_ref == trace_ty)
      trace_hit = 1;
  }
  if (trace_hit) {
    fprintf(stderr,
            "note: arena expr set debug: expr=%d kind=%d block=%d ty=%d left=%d right=%d name_len=%d name=%.*s\n",
            (int)ref, (int)e.kind, (int)e.block_ref, (int)e.resolved_type_ref, (int)e.binop_left_ref,
            (int)e.binop_right_ref, (int)e.var_name_len, (int)e.var_name_len, (const char *)e.var_name);
  }
  if (ep)
    *ep = e;
}

/**
 * 在 C 侧初始化 EXPR_VAR，避免 X→C 整结构 ast_arena_expr_set 拷贝导致 kind 等字段错位。
 */
void pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len) {
  struct ast_Expr *ep;
  int32_t n;
  if (!a || ref <= 0 || !name || name_len <= 0)
    return;
  ep = pipeline_arena_expr_ptr(a, ref);
  if (!ep)
    return;
  memset(ep, 0, sizeof(*ep));
  ep->kind = ast_ExprKind_EXPR_VAR;
  n = name_len;
  if (n > 63)
    n = 63;
  ep->var_name_len = n;
  memcpy(ep->var_name, name, (size_t)n);
  ep->call_resolved_func_index = -1;
  ep->call_resolved_dep_index = -1;
}

/**
 * 在 C 侧初始化二元运算节点（kind 为 ast_ExprKind 序数值，与 .x ExprKind 一致）。
 */
void pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                     int32_t right_ref) {
  struct ast_Expr *ep;
  if (!a || ref <= 0)
    return;
  ep = pipeline_arena_expr_ptr(a, ref);
  if (!ep)
    return;
  memset(ep, 0, sizeof(*ep));
  ep->kind = (enum ast_ExprKind)kind_ord;
  ep->binop_left_ref = left_ref;
  ep->binop_right_ref = right_ref;
  ep->call_resolved_func_index = -1;
  ep->call_resolved_dep_index = -1;
}

struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Block empty;
  struct ast_Block *bp;
  memset(&empty, 0, sizeof(empty));
  bp = pipeline_arena_block_ptr(a, ref);
  return bp ? *bp : empty;
}

void pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  struct ast_Block *bp = pipeline_arena_block_ptr(a, ref);
  const char *dbg_block_set = getenv("SHUX_DEBUG_BLOCK_SET");
  if (bp) {
    if (dbg_block_set && dbg_block_set[0] && atoi(dbg_block_set) == ref) {
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "block set debug: ref=%d old(c=%d l=%d if=%d reg=%d so=%d fin=%d) new(c=%d l=%d if=%d reg=%d so=%d fin=%d)",
                   (int)ref, (int)bp->num_consts, (int)bp->num_lets, (int)bp->num_if_stmts, (int)bp->num_regions,
                   (int)bp->num_stmt_order, (int)bp->final_expr_ref, (int)b.num_consts, (int)b.num_lets,
                   (int)b.num_if_stmts, (int)b.num_regions, (int)b.num_stmt_order, (int)b.final_expr_ref);
    }
    *bp = b;
  }
}

struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Func empty;
  struct ast_Func *fp;
  memset(&empty, 0, sizeof(empty));
  fp = pipeline_arena_func_ptr(a, ref);
  return fp ? *fp : empty;
}

void pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  struct ast_Func *fp = pipeline_arena_func_ptr(a, ref);
  if (fp)
    *fp = f;
}

static struct ast_Func *module_func_at(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc;
  if (!m || idx < 0 || idx >= m->num_funcs)
    return NULL;
  sc = module_sidecar_get(m, 0);
  if (!sc || idx >= sc->funcs.len)
    return NULL;
  return (struct ast_Func *)grow_vec_at(&sc->funcs, idx);
}

/** 将 src 侧车 func_params 中 n 个形参复制到 dst 侧车，并写 *dst_base。 */
static void copy_func_params_between_sidecars(GrowVec *dst, int32_t *dst_base, int32_t n, GrowVec *src,
                                              int32_t src_base) {
  int32_t i, abs_src, abs_dst;
  FuncParamEntry *se, *de;
  if (!dst || !src || n <= 0)
    return;
  *dst_base = dst->len;
  for (i = 0; i < n; i++) {
    abs_src = src_base + i;
    se = (FuncParamEntry *)grow_vec_at(src, abs_src);
    if (grow_vec_push(dst) < 0)
      break;
    abs_dst = dst->len - 1;
    de = (FuncParamEntry *)grow_vec_at(dst, abs_dst);
    if (se && de)
      *de = *se;
  }
}

/** 读/写 module 函数形参 sidecar 槽；create=1 时按需 grow。 */
static FuncParamEntry *module_func_param_entry(struct ast_Module *m, int32_t fi, int32_t pi, int create) {
  ModuleSidecar *sc;
  struct ast_Func *f;
  int32_t abs;
  if (!m || fi < 0 || pi < 0)
    return NULL;
  f = module_func_at(m, fi);
  if (!f)
    return NULL;
  sc = module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
  }
  if (f->param_base == 0 && (f->num_params == 0 || pi == 0))
    f->param_base = sc->func_params.len;
  abs = f->param_base + pi;
  while (sc->func_params.len <= abs) {
    if (grow_vec_push(&sc->func_params) < 0)
      return NULL;
  }
  if (pi + 1 > f->num_params)
    f->num_params = pi + 1;
  return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
}

/** 读/写 arena 函数形参 sidecar 槽；create=1 时按需 grow。 */
static FuncParamEntry *arena_func_param_entry(struct ast_ASTArena *a, int32_t func_ref, int32_t pi, int create) {
  ArenaSidecar *sc;
  struct ast_Func *f;
  int32_t abs;
  if (!a || func_ref <= 0 || func_ref > a->num_funcs || pi < 0)
    return NULL;
  f = pipeline_arena_func_ptr(a, func_ref);
  if (!f)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (pi >= f->num_params)
      return NULL;
    abs = f->param_base + pi;
    if (abs < 0 || abs >= sc->func_params.len)
      return NULL;
    return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
  }
  if (f->param_base == 0 && (f->num_params == 0 || pi == 0))
    f->param_base = sc->func_params.len;
  abs = f->param_base + pi;
  while (sc->func_params.len <= abs) {
    if (grow_vec_push(&sc->func_params) < 0)
      return NULL;
  }
  if (pi + 1 > f->num_params)
    f->num_params = pi + 1;
  return (FuncParamEntry *)grow_vec_at(&sc->func_params, abs);
}

/** 读/写 struct_layout 字段 sidecar 槽；create=1 时按需 grow。 */
static StructLayoutFieldEntry *module_layout_field_entry(struct ast_Module *m, int32_t li, int32_t j, int create) {
  ModuleSidecar *sc;
  struct ast_StructLayout *sl;
  int32_t abs;
  if (!m || li < 0 || j < 0)
    return NULL;
  sl = module_layout_at(m, li);
  if (!sl)
    return NULL;
  sc = module_sidecar_get(m, create ? 1 : 0);
  if (!sc)
    return NULL;
  if (!create) {
    if (j >= sl->num_fields)
      return NULL;
    abs = sl->field_base + j;
    if (abs < 0 || abs >= sc->struct_layout_fields.len)
      return NULL;
    return (StructLayoutFieldEntry *)grow_vec_at(&sc->struct_layout_fields, abs);
  }
  if (sl->field_base == 0 && (sl->num_fields == 0 || j == 0))
    sl->field_base = sc->struct_layout_fields.len;
  abs = sl->field_base + j;
  while (sc->struct_layout_fields.len <= abs) {
    if (grow_vec_push(&sc->struct_layout_fields) < 0)
      return NULL;
  }
  if (j + 1 > sl->num_fields)
    sl->num_fields = j + 1;
  return (StructLayoutFieldEntry *)grow_vec_at(&sc->struct_layout_fields, abs);
}

/** 新 Block 分配后记录各池 base 下标。 */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  if (!a || block_ref <= 0)
    return;
  sc = arena_sidecar_get(a, 1);
  if (!sc)
    return;
  b = block_at(a, block_ref);
  if (!b)
    return;
  /* 新块槽可能复用旧内存；先整体清零，避免 num_lets/num_stmt_order 等继承脏值污染后续写盘。 */
  memset(b, 0, sizeof(*b));
  b->const_base = sc->consts.len;
  b->let_base = sc->lets.len;
  b->loop_base = sc->loops.len;
  b->for_loop_base = sc->for_loops.len;
  b->if_base = sc->ifs.len;
  b->region_base = sc->regions.len;
  b->defer_base = sc->defer_block_refs.len;
  b->labeled_base = sc->labeled_stmts.len;
  b->expr_stmt_base = sc->expr_stmt_refs.len;
  b->stmt_order_base = sc->stmt_order.len;
}

/**
 * 复用同一 Module* 再次 parse 前清空 sidecar 动态池。
 * runtime 在 memset(module) 后仍保留指针对应的 sidecar，须显式 reset，否则 num_funcs 与 funcs.len 不一致导致重复 main。
 */
void ast_pool_module_reset(struct ast_Module *m) {
  ModuleSidecar *sc;
  if (!m)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  sc->funcs.len = 0;
  sc->func_refs.len = 0;
  sc->imports.len = 0;
  sc->struct_layouts.len = 0;
  sc->top_level_lets.len = 0;
  sc->type_aliases.len = 0;
  sc->module_enums.len = 0;
  sc->import_select_name_rows.len = 0;
  sc->import_select_name_lens.len = 0;
  sc->func_params.len = 0;
  sc->struct_layout_fields.len = 0;
}

/**
 * 复用同一 ASTArena* 再次 parse 前清空 sidecar 动态池（与 ast_arena_init 计数清零配对）。
 */
void ast_pool_arena_reset(struct ast_ASTArena *a) {
  ArenaSidecar *sc;
  if (!a)
    return;
  sc = arena_sidecar_get(a, 0);
  if (!sc)
    return;
  sc->types.len = 0;
  sc->exprs.len = 0;
  sc->blocks.len = 0;
  sc->funcs.len = 0;
  sc->consts.len = 0;
  sc->lets.len = 0;
  sc->ifs.len = 0;
  sc->regions.len = 0;
  sc->loops.len = 0;
  sc->for_loops.len = 0;
  sc->defer_block_refs.len = 0;
  sc->labeled_stmts.len = 0;
  sc->expr_stmt_refs.len = 0;
  sc->stmt_order.len = 0;
  sc->expr_call_arg_refs.len = 0;
  sc->expr_method_call_arg_refs.len = 0;
  sc->expr_match_arms.len = 0;
  sc->expr_struct_lit_fields.len = 0;
  sc->expr_array_lit_elem_refs.len = 0;
  sc->func_params.len = 0;
}

void ast_pool_onefunc_reset(uint8_t *out) {
  OneFuncSidecar *sc;
  if (!out)
    return;
  sc = onefunc_sidecar_get(out, 0);
  if (!sc)
    return;
  sc->if_cond_refs.len = 0;
  sc->if_then_body_refs.len = 0;
  sc->if_else_body_refs.len = 0;
  sc->const_names.len = 0;
  sc->const_name_lens.len = 0;
  sc->const_init_vals.len = 0;
  sc->const_init_refs.len = 0;
  sc->const_type_refs.len = 0;
  sc->let_names.len = 0;
  sc->let_name_lens.len = 0;
  sc->let_init_vals.len = 0;
  sc->let_init_refs.len = 0;
  sc->let_type_refs.len = 0;
  sc->src_stmt_kind.len = 0;
  sc->src_stmt_idx.len = 0;
  sc->src_body_expr_stmt_refs.len = 0;
  sc->while_cond_refs.len = 0;
  sc->while_body_refs.len = 0;
  sc->for_init_refs.len = 0;
  sc->for_cond_refs.len = 0;
  sc->for_step_refs.len = 0;
  sc->for_body_refs.len = 0;
  sc->param_names.len = 0;
  sc->param_name_lens.len = 0;
  sc->param_type_refs.len = 0;
  sc->call_arg_vals.len = 0;
  sc->regions.len = 0;
  sc->defer_body_refs.len = 0;
}

void ast_pool_onefunc_release(uint8_t *out) {
  int i;
  if (!out)
    return;
  for (i = 0; i < MAX_ONEFUNC_SIDECARS; i++) {
    if (g_onefunc_sc[i].used && g_onefunc_sc[i].onefunc == out) {
      onefunc_sidecar_free(&g_onefunc_sc[i]);
      return;
    }
  }
}

/** Module 侧分配新函数槽，返回 0-based 下标；失败返回 -1。 */
int32_t pipeline_module_func_alloc_slot(struct ast_Module *m) {
  ModuleSidecar *sc;
  struct ast_Func *f;
  int32_t *pr;
  int32_t idx;
  if (!m)
    return -1;
  sc = module_sidecar_get(m, 1);
  if (!sc)
    return -1;
  idx = grow_vec_push(&sc->funcs);
  if (idx < 0)
    return -1;
  f = (struct ast_Func *)grow_vec_at(&sc->funcs, idx);
  if (f)
    memset(f, 0, sizeof(*f));
  if (grow_vec_push(&sc->func_refs) >= 0) {
    pr = (int32_t *)grow_vec_at(&sc->func_refs, idx);
    if (pr)
      *pr = 0;
  }
  m->num_funcs = sc->funcs.len;
  return idx;
}

int32_t pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index) {
  ModuleSidecar *sc;
  int32_t *pr;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->func_refs, func_index);
  return pr ? *pr : 0;
}

void pipeline_module_func_ref_set(struct ast_Module *m, int32_t func_index, int32_t func_ref) {
  ModuleSidecar *sc;
  int32_t *pr;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  pr = (int32_t *)grow_vec_at(&sc->func_refs, func_index);
  if (pr)
    *pr = func_ref;
}

/** 从 arena func 池整槽拷贝到 module pool 新槽；返回 module 下标，失败 -1。 */
int32_t pipeline_module_func_register_from_arena(struct ast_Module *m, struct ast_ASTArena *arena,
                                                  int32_t func_ref) {
  int32_t fi;
  struct ast_Func *dst;
  struct ast_Func *src;
  ModuleSidecar *msc;
  ArenaSidecar *asc;
  if (!m || !arena || func_ref <= 0 || func_ref > arena->num_funcs)
    return -1;
  fi = pipeline_module_func_alloc_slot(m);
  if (fi < 0)
    return -1;
  dst = module_func_at(m, fi);
  src = pipeline_arena_func_ptr(arena, func_ref);
  msc = module_sidecar_get(m, 1);
  asc = arena_sidecar_get(arena, 0);
  if (!dst || !src || !msc || !asc)
    return -1;
  *dst = *src;
  copy_func_params_between_sidecars(&msc->func_params, &dst->param_base, src->num_params, &asc->func_params,
                                    src->param_base);
  pipeline_module_func_ref_set(m, fi, func_ref);
  return fi;
}

struct ast_Func *pipeline_module_func_ptr(struct ast_Module *m, int32_t func_index) {
  return module_func_at(m, func_index);
}

/** 写 module 函数字段（替代 .x 直接写 module.funcs[i]）。 */
void pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->return_type_ref = type_ref;
}

void pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->body_ref = body_ref;
}

void pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->body_expr_ref = body_expr_ref;
}

void pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->is_extern = is_extern;
}

/** 设置 module 第 fi 个函数是否为 async function（P2 语法原型）。 */
void pipeline_module_func_set_is_async(struct ast_Module *m, int32_t fi, int32_t is_async) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->is_async = is_async;
}

/** K10：设置 module 第 fi 个函数是否为 #[used]（不被 C 编译器消除，外部链接）。 */
void pipeline_module_func_set_is_used(struct ast_Module *m, int32_t fi, int32_t is_used) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f)
    f->is_used = is_used;
}

/** K10：读取 module 第 fi 个函数是否为 #[used]。 */
int32_t pipeline_module_func_is_used_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_used : 0;
}

/** K3：设置 module 第 fi 个函数是否为 #[naked]。 */
void pipeline_module_func_set_is_naked(struct ast_Module *m, int32_t fi, int32_t is_naked) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_naked = is_naked;
}
int32_t pipeline_module_func_is_naked_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_naked : 0;
}

/** K5：设置 module 第 fi 个函数是否为 #[entry]。 */
void pipeline_module_func_set_is_entry(struct ast_Module *m, int32_t fi, int32_t is_entry) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_entry = is_entry;
}
int32_t pipeline_module_func_is_entry_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_entry : 0;
}

/** L9：设置 module 第 fi 个函数是否为 #[no_mangle]。 */
void pipeline_module_func_set_is_no_mangle(struct ast_Module *m, int32_t fi, int32_t is_no_mangle) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_no_mangle = is_no_mangle;
}
int32_t pipeline_module_func_is_no_mangle_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_no_mangle : 0;
}

/** A1：设置 module 第 fi 个函数是否为 #[interrupt]。 */
void pipeline_module_func_set_is_interrupt(struct ast_Module *m, int32_t fi, int32_t is_interrupt) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f) f->is_interrupt = is_interrupt;
}
int32_t pipeline_module_func_is_interrupt_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs) return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_interrupt : 0;
}

int32_t pipeline_module_func_is_async_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->is_async : 0;
}

void pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f && n >= 0)
    f->num_params = n;
}

void pipeline_module_func_set_num_generic_params(struct ast_Module *m, int32_t fi, int32_t n) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f && n >= 0)
    f->num_generic_params = n;
  if (f && getenv("SHUX_DEBUG_FUNC_GENERIC_SLOT")) {
    fprintf(stderr, "shux: [SHUX_DEBUG_FUNC_GENERIC_SLOT] set fi=%d n=%d name=%.*s\n",
            (int)fi, (int)f->num_generic_params, (int)(f->name_len > 0 ? f->name_len : 0), (const char *)f->name);
    fflush(stderr);
  }
}

int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->num_params : 0;
}

int32_t pipeline_module_func_num_generic_params_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  if (!f)
    return 0;
  if (getenv("SHUX_DEBUG_FUNC_GENERIC_SLOT")) {
    fprintf(stderr, "shux: [SHUX_DEBUG_FUNC_GENERIC_SLOT] get fi=%d n=%d name=%.*s\n",
            (int)func_index, (int)f->num_generic_params, (int)(f->name_len > 0 ? f->name_len : 0),
            (const char *)f->name);
    fflush(stderr);
  }
  return (int32_t)f->num_generic_params;
}

int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *m, int32_t func_index, uint8_t *var_name,
                                                     int32_t var_name_len) {
  struct ast_Func *f;
  int32_t n, i;
  FuncParamEntry *pe;
  const char *var_dbg;
  if (!m || !var_name || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  if (var_name_len <= 0 || var_name_len > 31)
    return 0;
  f = module_func_at(m, func_index);
  if (!f)
    return 0;
  var_dbg = getenv("SHUX_TYPECK_VAR");
  if (var_dbg) {
    fprintf(stderr, "shux: [SHUX_TYPECK_VAR] func=%d name=%.*s lookup=%.*s num_params=%d\n",
            (int)func_index, (int)(f->name_len > 0 ? f->name_len : 0), (const char *)f->name,
            (int)var_name_len, (const char *)var_name, (int)f->num_params);
  }
  n = (int32_t)f->num_params;
  for (i = 0; i < n; i++) {
    pe = module_func_param_entry(m, func_index, i, 0);
    if (!pe || pe->type_ref == 0)
      continue;
    if ((int32_t)pe->name_len != var_name_len)
      continue;
    if (pe->name_len <= 0 || pe->name_len > 31)
      continue;
    if (memcmp(pe->name, var_name, (size_t)var_name_len) != 0)
      continue;
    if (var_dbg) {
      fprintf(stderr, "shux: [SHUX_TYPECK_VAR] param-match func=%d param=%d pname=%.*s type_ref=%d\n",
              (int)func_index, (int)i, (int)pe->name_len, (const char *)pe->name, (int)pe->type_ref);
    }
    return (int32_t)pe->type_ref;
  }
  return 0;
}

int32_t pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index, int32_t param_index) {
  FuncParamEntry *pe;
  if (!m || func_index < 0 || func_index >= m->num_funcs || param_index < 0)
    return 0;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  return pe ? (int32_t)pe->type_ref : 0;
}

void pipeline_module_func_param_write(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                      uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  FuncParamEntry *pe;
  if (!m || !name_bytes || func_index < 0 || param_index < 0)
    return;
  if (name_len < 0 || name_len > 31)
    return;
  pe = module_func_param_entry(m, func_index, param_index, 1);
  if (!pe)
    return;
  pe->name_len = name_len;
  pe->type_ref = type_ref;
  memset(pe->name, 0, sizeof(pe->name));
  if (name_len > 0)
    memcpy(pe->name, name_bytes, (size_t)name_len);
}

int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index) {
  FuncParamEntry *pe;
  if (!m || func_index < 0 || func_index >= m->num_funcs || param_index < 0)
    return 0;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  return pe ? (int32_t)pe->name_len : 0;
}

void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                            uint8_t *dst) {
  FuncParamEntry *pe;
  if (!m || !dst || func_index < 0 || func_index >= m->num_funcs || param_index < 0)
    return;
  pe = module_func_param_entry(m, func_index, param_index, 0);
  if (!pe) {
    memset(dst, 0, 32);
    return;
  }
  memcpy(dst, pe->name, (size_t)32);
}

void pipeline_arena_func_param_write(struct ast_ASTArena *arena, int32_t func_ref, int32_t param_index,
                                     uint8_t *name_bytes, int32_t name_len, int32_t type_ref) {
  FuncParamEntry *pe;
  if (!arena || !name_bytes || func_ref <= 0 || func_ref > arena->num_funcs || param_index < 0)
    return;
  if (name_len < 0 || name_len > 31)
    return;
  pe = arena_func_param_entry(arena, func_ref, param_index, 1);
  if (!pe)
    return;
  pe->name_len = name_len;
  pe->type_ref = type_ref;
  memset(pe->name, 0, sizeof(pe->name));
  if (name_len > 0)
    memcpy(pe->name, name_bytes, (size_t)name_len);
}

/** 将 module.funcs[fi] 标量槽 + 形参 sidecar 拷贝到 arena func 池（parse_into_buf 路径）。 */
void pipeline_arena_func_copy_slot_from_module(struct ast_ASTArena *arena, int32_t func_ref, struct ast_Module *m,
                                               int32_t fi) {
  struct ast_Func *src;
  struct ast_Func *dst;
  ModuleSidecar *msc;
  ArenaSidecar *asc;
  if (!arena || !m || func_ref <= 0 || func_ref > arena->num_funcs)
    return;
  if (fi < 0 || fi >= m->num_funcs)
    return;
  src = module_func_at(m, fi);
  dst = pipeline_arena_func_ptr(arena, func_ref);
  msc = module_sidecar_get(m, 0);
  asc = arena_sidecar_get(arena, 1);
  if (!src || !dst || !msc || !asc)
    return;
  *dst = *src;
  copy_func_params_between_sidecars(&asc->func_params, &dst->param_base, src->num_params, &msc->func_params,
                                    src->param_base);
}

int32_t pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f = module_func_at(m, fi);
  return f ? (int32_t)f->return_type_ref : 0;
}

/** 比较 module 函数名与外部 name 字节序列；相等返回 1。 */
int32_t pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len) {
  struct ast_Func *f;
  if (!m || !name || name_len <= 0 || name_len > 64)
    return 0;
  f = module_func_at(m, fi);
  if (!f || (int32_t)f->name_len != name_len)
    return 0;
  return memcmp(f->name, name, (size_t)name_len) == 0 ? 1 : 0;
}

/** pipeline.x：读 module.num_funcs，避免 asm 对 Module 字段 FIELD_ACCESS。 */
int32_t pipeline_module_num_funcs(struct ast_Module *m) {
  return m ? (int32_t)m->num_funcs : 0;
}

/** pipeline.x：读 module.main_func_index。 */
int32_t pipeline_module_main_func_index(struct ast_Module *m) {
  return m ? (int32_t)m->main_func_index : -1;
}

/**
 * strict asm 链：写 module.main_func_index（build_asm/parser.o 的 parse_into_set_main_index 为空桩）。
 */
void pipeline_module_set_main_func_index(struct ast_Module *m, int32_t idx) {
  if (m)
    m->main_func_index = idx;
}

/**
 * M8-tail：parser.x pipeline_module_reset_parse_counters 的 C 实现；SKIP/EMIT_HEAVY 薄包装 bl 目标。
 * 避免 *Module 字段 FIELD_ACCESS 在 shux_asm emit 失败。
 */
void pipeline_module_reset_parse_counters_c(struct ast_Module *module) {
  if (!module)
    return;
  module->num_funcs = 0;
  module->main_func_index = -1;
  module->num_imports = 0;
  module->num_top_level_lets = 0;
  module->num_struct_layouts = 0;
  module->num_module_enums = 0;
}

extern void parser_onefunc_result_layout_prime(void);
extern void parser_onefunc_result_layout_prime_b(void);
extern void parser_onefunc_result_layout_prime_c(void);
extern void parser_onefunc_result_layout_prime_d(void);
extern void parser_onefunc_result_layout_prime_d_b(void);
extern void parser_onefunc_result_layout_prime_e(void);
extern void parser_onefunc_result_layout_prime_f(void);
extern void ast_arena_init(struct ast_ASTArena *arena);
extern void pipeline_parser_set_match_module(struct ast_Module *m);

/**
 * strict asm 链：parse 前重置 arena/module（等价 parser.x parse_into_init）。
 * build_asm/parser.o 的 parse_into_init 不重置 sidecar grow 池，二次 parse 会累积 funcs。
 */
void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module) {
  ast_arena_init(arena);
  ast_pool_module_reset(module);
  ast_pool_arena_reset(arena);
  parser_onefunc_result_layout_prime();
  parser_onefunc_result_layout_prime_b();
  parser_onefunc_result_layout_prime_c();
  parser_onefunc_result_layout_prime_d();
  parser_onefunc_result_layout_prime_d_b();
  parser_onefunc_result_layout_prime_e();
  parser_onefunc_result_layout_prime_f();
  pipeline_module_reset_parse_counters_c(module);
  pipeline_parser_set_match_module(module);
  if (module) {
    module->num_funcs = 0;
    module->main_func_index = -1;
    module->num_imports = 0;
    module->num_top_level_lets = 0;
    module->num_struct_layouts = 0;
    module->pending_allow_padding = 0;
    module->pending_soa_struct = 0;
    module->pending_cfg_skip = 0;
    module->pending_repr_c_struct = 0;
    module->pending_repr_compatible_struct = 0;
    module->num_module_enums = 0;
  }
}

/** pipeline.x：读 arena.num_types（诊断 parse fail）。 */
int32_t pipeline_arena_num_types(struct ast_ASTArena *a) {
  return a ? (int32_t)a->num_types : 0;
}

/** 读取 module 函数名字节（0..name_len-1）；越界返回 0。 */
uint8_t pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i) {
  struct ast_Func *f;
  if (!m || i < 0 || i >= 64)
    return 0;
  f = module_func_at(m, fi);
  if (!f || i >= (int32_t)f->name_len)
    return 0;
  return f->name[i];
}

int32_t pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f = module_func_at(m, fi);
  return f ? (int32_t)f->body_expr_ref : 0;
}

/**
 * 维持 per-block 池条目连续性的核心辅助函数（insert-and-shift 策略）。
 *
 * 【Why 逻辑根源】block_let_at / block_const_at 等 reader 用 `base + li` 索引全局池，假设
 *   同一 block 的条目在池中物理连续。但嵌套 parse_block_into 递归会在父块首次 append 后、
 *   后续 append 前向池尾 push 子块条目，破坏父块连续性；导致父块 `base + li` 读到子块条目
 *   （数据错乱）或越界（SIGSEGV）。与 pipeline_block_stmt_order_insert_at 既有策略同源。
 *
 * 【Invariant 状态不变量】调用后，br 对应 block 的 `base .. base+num_before` 区间在池中物理连续，
 *   且同 arena 内所有 block 的对应 base 字段被同步修正以维持各自的连续性。
 *
 * 【Asm/Perf 性能预期】无间隙时 O(1)（仅 push）；有间隙时 O(N+M) memmove（N=被搬移条目数，
 *   M=同 arena block 数）。间隙仅在嵌套块交错追加时出现，属低频路径，热路径无影响。
 *
 * 参数：
 *   a          — ASTArena
 *   br         — 目标 block ref（1-based）
 *   pool       — 目标侧车池（&sc->lets / &sc->consts / ...）
 *   base_off   — block 内 base 字段的 offsetof 偏移（offsetof(struct ast_Block, let_base) 等）
 *   num_before — 调用前 block 内该类条目的已有数量（b->num_lets 等）
 * 返回：池中绝对下标（>=0）成功；-1 失败。调用方负责写入条目数据并递增 num_* 计数。
 */
static int32_t block_pool_append_pos(struct ast_ASTArena *a, int32_t br, GrowVec *pool,
                                     size_t base_off, int32_t num_before) {
  struct ast_Block *b;
  int32_t *base_field;
  int32_t abs_pos;
  if (!a || !pool || !(b = block_at(a, br)))
    return -1;
  base_field = (int32_t *)((uint8_t *)b + base_off);
  if (num_before == 0) {
    /* 首次追加：直接 push 到池尾并锚定 base；abs_pos 在尾后，不影响其他 block 的既有 base */
    abs_pos = grow_vec_push(pool);
    if (abs_pos < 0)
      return -1;
    *base_field = abs_pos;
    return abs_pos;
  }
  /* 后续追加：期望位置 = base + num_before（维持连续性的物理位置） */
  abs_pos = *base_field + num_before;
  if (abs_pos >= pool->len) {
    /* 无间隙：期望位置在池尾或超出，直接 push 即可，不破坏既有连续性 */
    abs_pos = grow_vec_push(pool);
    if (abs_pos < 0)
      return -1;
    return abs_pos;
  }
  /* 有间隙：abs_pos 处当前被嵌套块条目占据，须 insert-and-shift */
  {
    size_t esz;
    int32_t move_count;
    int32_t bi;
    if (!grow_vec_ensure(pool))
      return -1;
    esz = pool->elem_sz;
    move_count = pool->len - abs_pos;
    if (move_count > 0) {
      memmove(pool->data + (size_t)(abs_pos + 1) * esz,
              pool->data + (size_t)abs_pos * esz,
              (size_t)move_count * esz);
    }
    memset(pool->data + (size_t)abs_pos * esz, 0, esz);
    pool->len++;
    /* 修正同 arena 内所有 block 的同名字段：base >= abs_pos 者 +1（其条目被 memmove 推后一位） */
    for (bi = 1; bi <= a->num_blocks; bi++) {
      struct ast_Block *ob = block_at(a, bi);
      if (ob && bi != br) {
        int32_t *ob_field = (int32_t *)((uint8_t *)ob + base_off);
        if (*ob_field >= abs_pos)
          (*ob_field)++;
      }
    }
  }
  return abs_pos;
}

/** Block 池 append/read — const */
int32_t pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                    int32_t type_ref, int32_t init_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_ConstDecl *cd;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->consts, offsetof(struct ast_Block, const_base), b->num_consts);
  if (idx < 0)
    return -1;
  cd = (struct ast_ConstDecl *)grow_vec_at(&sc->consts, idx);
  memset(cd, 0, sizeof(*cd));
  if (name_len > 0 && name)
    memcpy(cd->name, name, (size_t)(name_len > 64 ? 64 : name_len));
  cd->name_len = name_len;
  cd->type_ref = type_ref;
  cd->init_ref = init_ref;
  b->num_consts++;
  return idx - b->const_base;
}

int32_t pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                 int32_t type_ref, int32_t init_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_LetDecl *ld;
  int32_t idx;
  const char *dbg_append_block;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  dbg_append_block = getenv("SHUX_DEBUG_APPEND_BLOCK");
  idx = block_pool_append_pos(a, br, &sc->lets, offsetof(struct ast_Block, let_base), b->num_lets);
  if (idx < 0)
    return -1;
  ld = (struct ast_LetDecl *)grow_vec_at(&sc->lets, idx);
  memset(ld, 0, sizeof(*ld));
  if (name_len > 0 && name)
    memcpy(ld->name, name, (size_t)(name_len > 64 ? 64 : name_len));
  ld->name_len = name_len;
  ld->type_ref = type_ref;
  ld->init_ref = init_ref;
  if (dbg_append_block && dbg_append_block[0] && atoi(dbg_append_block) == br) {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "append let debug: block=%d rel_idx=%d name=%.*s init_ref=%d init_kind=%d type_ref=%d",
                 (int)br, (int)b->num_lets, name_len > 0 ? (int)name_len : 0, (const char *)(name ? name : (uint8_t *)""),
                 (int)init_ref, (int)pipeline_expr_kind_ord_at(a, init_ref), (int)type_ref);
  }
  b->num_lets++;
  return idx - b->let_base;
}

int32_t pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                  int32_t else_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_IfStmt *is;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->ifs, offsetof(struct ast_Block, if_base), b->num_if_stmts);
  if (idx < 0)
    return -1;
  is = (struct ast_IfStmt *)grow_vec_at(&sc->ifs, idx);
  is->cond_ref = cond_ref;
  is->then_body_ref = then_ref;
  is->else_body_ref = else_ref;
  b->num_if_stmts++;
  return idx - b->if_base;
}

/** M-3：向块追加 region label { body }；返回块内 region 下标，失败 -1。 */
int32_t pipeline_block_append_region(struct ast_ASTArena *a, int32_t br, uint8_t *label, int32_t label_len,
                                     int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  RegionBlockEntry *rb;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || !label || label_len <= 0 || label_len > 63)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->regions, offsetof(struct ast_Block, region_base), b->num_regions);
  if (idx < 0)
    return -1;
  rb = (RegionBlockEntry *)grow_vec_at(&sc->regions, idx);
  memset(rb, 0, sizeof(*rb));
  memcpy(rb->label, label, (size_t)label_len);
  rb->label_len = label_len;
  rb->body_ref = body_ref;
  rb->with_arena_cap_ref = 0;
  b->num_regions++;
  return idx - b->region_base;
}

/**
 * MEM-C1：向块追加 with_arena(cap) { body }；复用 regions 池，with_arena_cap_ref>0 区分 region。
 * 返回块内下标（与 region 共用 idx 空间），失败 -1。
 */
int32_t pipeline_block_append_with_arena(struct ast_ASTArena *a, int32_t br, int32_t cap_ref, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  RegionBlockEntry *rb;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || cap_ref <= 0 || body_ref <= 0)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->regions, offsetof(struct ast_Block, region_base), b->num_regions);
  if (idx < 0)
    return -1;
  rb = (RegionBlockEntry *)grow_vec_at(&sc->regions, idx);
  memset(rb, 0, sizeof(*rb));
  rb->with_arena_cap_ref = cap_ref;
  rb->body_ref = body_ref;
  b->num_regions++;
  return idx - b->region_base;
}

/**
 * LANG-007 v2：向块追加 unsafe { body }；复用 regions 池，with_arena_cap_ref=-1 区分 region/with_arena。
 * 返回块内下标（与 region 共用 idx 空间），失败 -1。
 */
int32_t pipeline_block_append_unsafe(struct ast_ASTArena *a, int32_t br, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  RegionBlockEntry *rb;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || body_ref <= 0)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->regions, offsetof(struct ast_Block, region_base), b->num_regions);
  if (idx < 0)
    return -1;
  rb = (RegionBlockEntry *)grow_vec_at(&sc->regions, idx);
  memset(rb, 0, sizeof(*rb));
  rb->with_arena_cap_ref = -1;
  rb->body_ref = body_ref;
  b->num_regions++;
  return idx - b->region_base;
}

static RegionBlockEntry *block_region_at(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || ri < 0 || ri >= b->num_regions)
    return NULL;
  abs = b->region_base + ri;
  return (RegionBlockEntry *)grow_vec_at(&sc->regions, abs);
}

/** MEM-C1：块内第 ri 个 region/with_arena 条目的 cap ref；0 表示非 with_arena。 */
int32_t pipeline_block_region_with_arena_cap_ref(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb && rb->with_arena_cap_ref > 0 ? rb->with_arena_cap_ref : 0;
}

/** LANG-007 v2：块内第 ri 个条目是否为 unsafe { } 块（with_arena_cap_ref==-1）。 */
int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb && rb->with_arena_cap_ref == -1 ? 1 : 0;
}

/** M-3：读块内第 ri 个 region 的 body 块 ref；无效时 0。 */
int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb ? rb->body_ref : 0;
}

/** M-3：读块内 region 域标签长度；无效时 0。 */
int32_t pipeline_block_region_label_len(struct ast_ASTArena *a, int32_t br, int32_t ri) {
  RegionBlockEntry *rb = block_region_at(a, br, ri);
  return rb && rb->label_len > 0 ? rb->label_len : 0;
}

/** M-3：拷贝 region 域标签到 dst[64]（不保证 NUL 结尾）。 */
void pipeline_block_region_label_copy64(struct ast_ASTArena *a, int32_t br, int32_t ri, uint8_t *dst) {
  RegionBlockEntry *rb;
  if (!dst)
    return;
  rb = block_region_at(a, br, ri);
  if (!rb || rb->label_len <= 0) {
    memset(dst, 0, 64);
    return;
  }
  memset(dst, 0, 64);
  memcpy(dst, rb->label, (size_t)rb->label_len);
}

/** MEM-B0：向块追加 defer { body }；返回块内 defer 下标，失败 -1。 */
int32_t pipeline_block_append_defer(struct ast_ASTArena *a, int32_t br, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t idx;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || body_ref <= 0)
    return -1;
  idx = block_pool_append_pos(a, br, &sc->defer_block_refs, offsetof(struct ast_Block, defer_base), b->num_defers);
  if (idx < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->defer_block_refs, idx);
  *pr = body_ref;
  b->num_defers++;
  return idx - b->defer_base;
}

static int32_t block_defer_body_ref_at(struct ast_ASTArena *a, int32_t br, int32_t di) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)) || di < 0 || di >= b->num_defers)
    return 0;
  abs = b->defer_base + di;
  pr = (int32_t *)grow_vec_at(&sc->defer_block_refs, abs);
  return pr ? *pr : 0;
}

/** MEM-B0：读块内第 di 个 defer 的 body 块 ref；无效时 0。 */
int32_t pipeline_block_defer_body_ref(struct ast_ASTArena *a, int32_t br, int32_t di) {
  return block_defer_body_ref_at(a, br, di);
}

/** MEM-B0：OneFunc 侧车追加 defer body；返回 defer 下标，失败 -1。 */
int32_t pipeline_onefunc_append_defer(uint8_t *out, int32_t body_ref) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || body_ref <= 0 || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->defer_body_refs) < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->defer_body_refs, sc->defer_body_refs.len - 1);
  *pr = body_ref;
  return sc->defer_body_refs.len - 1;
}

int32_t pipeline_onefunc_num_defers(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->defer_body_refs.len : 0;
}

/** MEM-B0：将 OneFunc 中 defer 链批量写入 Block 池。 */
void pipeline_block_fill_defers_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  OneFuncSidecar *sc;
  int32_t *pr;
  int32_t i;
  if (!a || !out || !(sc = onefunc_sidecar_get(out, 0)))
    return;
  for (i = 0; i < count && i < sc->defer_body_refs.len; i++) {
    pr = (int32_t *)grow_vec_at(&sc->defer_body_refs, i);
    if (pr && *pr > 0)
      pipeline_block_append_defer(a, br, *pr);
  }
}

int32_t pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t idx;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->expr_stmt_refs, offsetof(struct ast_Block, expr_stmt_base), b->num_expr_stmts);
  if (idx < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->expr_stmt_refs, idx);
  *pr = expr_ref;
  b->num_expr_stmts++;
  return idx - b->expr_stmt_base;
}

int32_t pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx_val) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_StmtOrderItem *so;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->stmt_order, offsetof(struct ast_Block, stmt_order_base), b->num_stmt_order);
  if (idx < 0)
    return -1;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, idx);
  so->kind = kind;
  so->idx = idx_val;
  b->num_stmt_order++;
  return idx - b->stmt_order_base;
}

static struct ast_ConstDecl *block_const_at(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (ci < 0 || ci >= b->num_consts)
    return NULL;
  abs = b->const_base + ci;
  return (struct ast_ConstDecl *)grow_vec_at(&sc->consts, abs);
}

static struct ast_LetDecl *block_let_at(struct ast_ASTArena *a, int32_t br, int32_t li) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (li < 0 || li >= b->num_lets)
    return NULL;
  abs = b->let_base + li;
  return (struct ast_LetDecl *)grow_vec_at(&sc->lets, abs);
}

static struct ast_IfStmt *block_if_at(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (ii < 0 || ii >= b->num_if_stmts)
    return NULL;
  abs = b->if_base + ii;
  return (struct ast_IfStmt *)grow_vec_at(&sc->ifs, abs);
}

static struct ast_WhileLoop *block_while_at(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (wi < 0 || wi >= b->num_loops)
    return NULL;
  abs = b->loop_base + wi;
  return (struct ast_WhileLoop *)grow_vec_at(&sc->loops, abs);
}

static struct ast_ForLoop *block_for_at(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return NULL;
  if (fi < 0 || fi >= b->num_for_loops)
    return NULL;
  abs = b->for_loop_base + fi;
  return (struct ast_ForLoop *)grow_vec_at(&sc->for_loops, abs);
}

/** Block 池：追加 while 循环；返回块内相对下标，失败 -1。 */
int32_t pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_WhileLoop *wl;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->loops, offsetof(struct ast_Block, loop_base), b->num_loops);
  if (idx < 0)
    return -1;
  wl = (struct ast_WhileLoop *)grow_vec_at(&sc->loops, idx);
  if (!wl)
    return -1;
  memset(wl, 0, sizeof(*wl));
  wl->cond_ref = cond_ref;
  wl->body_ref = body_ref;
  if (getenv("SHUX_ASM_DEBUG"))
    fprintf(stderr, "shux: append_while br=%d cond=%d body=%d wi=%d\n", (int)br, (int)cond_ref, (int)body_ref,
            (int)(idx - b->loop_base));
  b->num_loops++;
  return idx - b->loop_base;
}

/** Block 池：追加 for 循环；返回块内相对下标，失败 -1。 */
int32_t pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                   int32_t step_ref, int32_t body_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_ForLoop *fl;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->for_loops, offsetof(struct ast_Block, for_loop_base), b->num_for_loops);
  if (idx < 0)
    return -1;
  fl = (struct ast_ForLoop *)grow_vec_at(&sc->for_loops, idx);
  if (!fl)
    return -1;
  fl->init_ref = init_ref;
  fl->cond_ref = cond_ref;
  fl->step_ref = step_ref;
  fl->body_ref = body_ref;
  b->num_for_loops++;
  return idx - b->for_loop_base;
}

int32_t pipeline_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  struct ast_WhileLoop *wl = block_while_at(a, br, wi);
  return wl ? (int32_t)wl->cond_ref : 0;
}

int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi) {
  struct ast_WhileLoop *wl = block_while_at(a, br, wi);
  return wl ? (int32_t)wl->body_ref : 0;
}

int32_t pipeline_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->init_ref : 0;
}

int32_t pipeline_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->cond_ref : 0;
}

int32_t pipeline_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->step_ref : 0;
}

int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi) {
  struct ast_ForLoop *fl = block_for_at(a, br, fi);
  return fl ? (int32_t)fl->body_ref : 0;
}

/** Block 池：追加 labeled 语句（label 可为空，用于 library 形态 return expr）。 */
int32_t pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                       int32_t goto_target_len, int32_t return_expr_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_LabeledStmt *ls;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = block_pool_append_pos(a, br, &sc->labeled_stmts, offsetof(struct ast_Block, labeled_base), b->num_labeled_stmts);
  if (idx < 0)
    return -1;
  ls = (struct ast_LabeledStmt *)grow_vec_at(&sc->labeled_stmts, idx);
  if (!ls)
    return -1;
  memset(ls, 0, sizeof(*ls));
  ls->label_len = label_len;
  ls->is_goto = is_goto;
  ls->goto_target_len = goto_target_len;
  ls->return_expr_ref = return_expr_ref;
  b->num_labeled_stmts++;
  return idx - b->labeled_base;
}

/** 取 block 内第 li 条 labeled 语句指针；无效返回 NULL。 */
struct ast_LabeledStmt *pipeline_block_labeled_ptr(struct ast_ASTArena *a, int32_t br, int32_t li) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return NULL;
  if (li < 0 || li >= b->num_labeled_stmts)
    return NULL;
  abs = b->labeled_base + li;
  return (struct ast_LabeledStmt *)grow_vec_at(&sc->labeled_stmts, abs);
}

int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_LabeledStmt *ls;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (li < 0 || li >= b->num_labeled_stmts)
    return 0;
  abs = b->labeled_base + li;
  ls = (struct ast_LabeledStmt *)grow_vec_at(&sc->labeled_stmts, abs);
  return ls ? (int32_t)ls->return_expr_ref : 0;
}

int32_t pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  struct ast_ConstDecl *cd = block_const_at(a, br, ci);
  return cd ? (int32_t)cd->init_ref : 0;
}

int32_t pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  struct ast_ConstDecl *cd = block_const_at(a, br, ci);
  return cd ? (int32_t)cd->type_ref : 0;
}

int32_t pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  struct ast_ConstDecl *cd = block_const_at(a, br, ci);
  return cd ? (int32_t)cd->name_len : 0;
}

void pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst) {
  struct ast_ConstDecl *cd;
  if (!dst)
    return;
  cd = block_const_at(a, br, ci);
  if (!cd) {
    memset(dst, 0, 64);
    return;
  }
  memcpy(dst, cd->name, 64);
}

int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LetDecl *ld = block_let_at(a, br, li);
  return ld ? (int32_t)ld->init_ref : 0;
}

int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LetDecl *ld = block_let_at(a, br, li);
  return ld ? (int32_t)ld->type_ref : 0;
}

int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li) {
  struct ast_LetDecl *ld = block_let_at(a, br, li);
  return ld ? (int32_t)ld->name_len : 0;
}

void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst) {
  struct ast_LetDecl *ld;
  if (!dst)
    return;
  ld = block_let_at(a, br, li);
  if (!ld) {
    memset(dst, 0, 64);
    return;
  }
  memcpy(dst, ld->name, 64);
}

int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (ei < 0 || ei >= b->num_expr_stmts)
    return 0;
  abs = b->expr_stmt_base + ei;
  pr = (int32_t *)grow_vec_at(&sc->expr_stmt_refs, abs);
  return pr ? *pr : 0;
}

uint8_t pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_StmtOrderItem *so;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (si < 0 || si >= b->num_stmt_order)
    return 0;
  abs = b->stmt_order_base + si;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs);
  return so ? so->kind : 0;
}

int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_StmtOrderItem *so;
  int32_t abs;
  if (!a || !(sc = arena_sidecar_get(a, 0)) || !(b = block_at(a, br)))
    return 0;
  if (si < 0 || si >= b->num_stmt_order)
    return 0;
  abs = b->stmt_order_base + si;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs);
  return so ? (int32_t)so->idx : 0;
}

int32_t pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  struct ast_IfStmt *is = block_if_at(a, br, ii);
  return is ? (int32_t)is->cond_ref : 0;
}

int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  struct ast_IfStmt *is = block_if_at(a, br, ii);
  return is ? (int32_t)is->then_body_ref : 0;
}

int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  struct ast_IfStmt *is = block_if_at(a, br, ii);
  return is ? (int32_t)is->else_body_ref : 0;
}

/**
 * 为嵌套块补 parent_block_ref（while/for/if 体）；显式栈遍历，避免递归栈溢出。
 * 与 ast.x::ast_arena_patch_block_parent_links 一致；typeck 在 check_block 前调用。
 */
void pipeline_patch_block_parent_links(struct ast_ASTArena *a, int32_t block_ref, int32_t parent_ref) {
  int32_t stack_blk[256];
  int32_t stack_par[256];
  int32_t sp;
  int32_t cur;
  int32_t par;
  int32_t i;
  struct ast_Block *b;
  int32_t wb;
  int32_t fb;
  int32_t tb;
  int32_t eb;
  int32_t rgb;
  if (!a || block_ref <= 0 || block_ref > a->num_blocks)
    return;
  sp = 0;
  stack_blk[sp] = block_ref;
  stack_par[sp] = parent_ref;
  sp++;
  while (sp > 0) {
    sp--;
    cur = stack_blk[sp];
    par = stack_par[sp];
    if (cur <= 0 || cur > a->num_blocks)
      continue;
    if (par != 0) {
      b = block_at(a, cur);
      if (b && b->parent_block_ref == 0) {
        b->parent_block_ref = par;
      }
    }
    b = block_at(a, cur);
    if (!b)
      continue;
    for (i = 0; i < b->num_loops; i++) {
      wb = pipeline_block_while_body_ref(a, cur, i);
      if (wb > 0 && sp < 256) {
        stack_blk[sp] = wb;
        stack_par[sp] = cur;
        sp++;
      }
    }
    for (i = 0; i < b->num_for_loops; i++) {
      fb = pipeline_block_for_body_ref(a, cur, i);
      if (fb > 0 && sp < 256) {
        stack_blk[sp] = fb;
        stack_par[sp] = cur;
        sp++;
      }
    }
    for (i = 0; i < b->num_if_stmts; i++) {
      tb = pipeline_block_if_then_body_ref(a, cur, i);
      if (tb > 0 && sp < 256) {
        stack_blk[sp] = tb;
        stack_par[sp] = cur;
        sp++;
      }
      eb = pipeline_block_if_else_body_ref(a, cur, i);
      if (eb > 0 && sp < 256) {
        stack_blk[sp] = eb;
        stack_par[sp] = cur;
        sp++;
      }
    }
    /** M-3：region 体块须挂 parent，否则块内可访问外层 let（如 region_block_escape 的 outer）。 */
    for (i = 0; i < b->num_regions; i++) {
      rgb = pipeline_block_region_body_ref(a, cur, i);
      if (rgb > 0 && sp < 256) {
        stack_blk[sp] = rgb;
        stack_par[sp] = cur;
        sp++;
      }
    }
  }
}

/** 按名查块内 const/let 类型 ref。 */
int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                             int32_t vlen) {
  struct ast_Block *b;
  int32_t cur;
  int32_t depth;
  const char *var_dbg;
  if (!a || !vname || vlen <= 0)
    return 0;
  var_dbg = getenv("SHUX_TYPECK_VAR");
  cur = block_ref;
  depth = 0;
  while (cur > 0 && cur <= a->num_blocks && depth < 128) {
    int32_t i;
    b = block_at(a, cur);
    if (!b)
      break;
    if (var_dbg) {
      fprintf(stderr, "shux: [SHUX_TYPECK_VAR] lookup=%.*s block=%d parent=%d num_lets=%d depth=%d\n",
              (int)vlen, (const char *)vname, (int)cur, (int)b->parent_block_ref, (int)b->num_lets, (int)depth);
    }
    for (i = 0; i < b->num_consts; i++) {
      struct ast_ConstDecl *cd = block_const_at(a, cur, i);
      if (cd && cd->type_ref != 0 && cd->name_len == vlen &&
          memcmp(cd->name, vname, (size_t)vlen) == 0) {
        if (var_dbg) {
          fprintf(stderr, "shux: [SHUX_TYPECK_VAR] const-match block=%d name=%.*s type_ref=%d\n",
                  (int)cur, (int)cd->name_len, (const char *)cd->name, (int)cd->type_ref);
        }
        return (int32_t)cd->type_ref;
      }
    }
    for (i = 0; i < b->num_lets; i++) {
      struct ast_LetDecl *ld = block_let_at(a, cur, i);
      if (ld && ld->type_ref != 0 && ld->name_len == vlen && memcmp(ld->name, vname, (size_t)vlen) == 0) {
        if (var_dbg) {
          fprintf(stderr, "shux: [SHUX_TYPECK_VAR] let-match block=%d name=%.*s type_ref=%d\n",
                  (int)cur, (int)ld->name_len, (const char *)ld->name, (int)ld->type_ref);
        }
        return (int32_t)ld->type_ref;
      }
    }
    cur = b->parent_block_ref;
    depth++;
  }
  return 0;
}

/**
 * 按名查块内 const/let 的**声明块** ref（自 block_ref 沿 parent 链向内层优先匹配）。
 * 与 pipeline_block_resolve_var_type_ref 遍历顺序一致，但返回 block ref 而非 type ref。
 */
int32_t pipeline_block_find_var_decl_block_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                               int32_t vlen) {
  struct ast_Block *b;
  int32_t cur;
  int32_t depth;
  if (!a || !vname || vlen <= 0)
    return 0;
  cur = block_ref;
  depth = 0;
  while (cur > 0 && cur <= a->num_blocks && depth < 128) {
    int32_t i;
    b = block_at(a, cur);
    if (!b)
      break;
    for (i = 0; i < b->num_consts; i++) {
      struct ast_ConstDecl *cd = block_const_at(a, cur, i);
      if (cd && cd->name_len == vlen && memcmp(cd->name, vname, (size_t)vlen) == 0)
        return cur;
    }
    for (i = 0; i < b->num_lets; i++) {
      struct ast_LetDecl *ld = block_let_at(a, cur, i);
      if (ld && ld->name_len == vlen && memcmp(ld->name, vname, (size_t)vlen) == 0)
        return cur;
    }
    cur = b->parent_block_ref;
    depth++;
  }
  return 0;
}

/** OneFunc scratch 池 API */
int32_t pipeline_onefunc_append_if(uint8_t *out, int32_t cond, int32_t then_ref, int32_t else_ref) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->if_cond_refs) < 0)
    return -1;
  if (grow_vec_push(&sc->if_then_body_refs) < 0)
    return -1;
  if (grow_vec_push(&sc->if_else_body_refs) < 0)
    return -1;
  p = (int32_t *)grow_vec_at(&sc->if_cond_refs, sc->if_cond_refs.len - 1);
  *p = cond;
  p = (int32_t *)grow_vec_at(&sc->if_then_body_refs, sc->if_then_body_refs.len - 1);
  *p = then_ref;
  p = (int32_t *)grow_vec_at(&sc->if_else_body_refs, sc->if_else_body_refs.len - 1);
  *p = else_ref;
  return sc->if_cond_refs.len - 1;
}

int32_t pipeline_onefunc_if_cond_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->if_cond_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->if_cond_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_if_then_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->if_then_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->if_then_body_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_if_else_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->if_else_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->if_else_body_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_num_if_stmts(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->if_cond_refs.len : 0;
}

/** M-3：OneFunc 侧车追加 region；返回 region 下标，失败 -1。 */
int32_t pipeline_onefunc_append_region(uint8_t *out, uint8_t *label, int32_t label_len, int32_t body_ref) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !label || label_len <= 0 || label_len > 63)
    return -1;
  if (grow_vec_push(&sc->regions) < 0)
    return -1;
  re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, sc->regions.len - 1);
  if (!re)
    return -1;
  memset(re, 0, sizeof(*re));
  memcpy(re->label, label, (size_t)label_len);
  re->label_len = label_len;
  re->body_ref = body_ref;
  re->with_arena_cap_ref = 0;
  return sc->regions.len - 1;
}

/** MEM-C1：OneFunc 侧车追加 with_arena(cap) { body }。 */
int32_t pipeline_onefunc_append_with_arena(uint8_t *out, int32_t cap_ref, int32_t body_ref) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || cap_ref <= 0 || body_ref <= 0)
    return -1;
  if (grow_vec_push(&sc->regions) < 0)
    return -1;
  re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, sc->regions.len - 1);
  if (!re)
    return -1;
  memset(re, 0, sizeof(*re));
  re->with_arena_cap_ref = cap_ref;
  re->body_ref = body_ref;
  return sc->regions.len - 1;
}

/** LANG-007 v2：OneFunc 侧车追加 unsafe { body }。 */
int32_t pipeline_onefunc_append_unsafe(uint8_t *out, int32_t body_ref) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || body_ref <= 0)
    return -1;
  if (grow_vec_push(&sc->regions) < 0)
    return -1;
  re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, sc->regions.len - 1);
  if (!re)
    return -1;
  memset(re, 0, sizeof(*re));
  re->with_arena_cap_ref = -1;
  re->body_ref = body_ref;
  return sc->regions.len - 1;
}

int32_t pipeline_onefunc_num_regions(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->regions.len : 0;
}

/** M-3：将 OneFunc 中 region 链批量写入 Block 池。 */
void pipeline_block_fill_regions_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  OneFuncSidecar *sc;
  OneFuncRegionEntry *re;
  int32_t i;
  if (!a || !out || !(sc = onefunc_sidecar_get(out, 0)))
    return;
  for (i = 0; i < count && i < sc->regions.len; i++) {
    re = (OneFuncRegionEntry *)grow_vec_at(&sc->regions, i);
    if (!re)
      continue;
    if (re->with_arena_cap_ref > 0)
      pipeline_block_append_with_arena(a, br, re->with_arena_cap_ref, re->body_ref);
    else if (re->with_arena_cap_ref == -1)
      pipeline_block_append_unsafe(a, br, re->body_ref);
    else if (re->label_len > 0)
      pipeline_block_append_region(a, br, re->label, re->label_len, re->body_ref);
  }
}

int32_t pipeline_onefunc_push_stmt_order(uint8_t *out, uint8_t kind, int32_t idx) {
  OneFuncSidecar *sc;
  uint8_t *pk;
  int32_t *pi;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->src_stmt_kind) < 0 || grow_vec_push(&sc->src_stmt_idx) < 0)
    return -1;
  pk = (uint8_t *)grow_vec_at(&sc->src_stmt_kind, sc->src_stmt_kind.len - 1);
  pi = (int32_t *)grow_vec_at(&sc->src_stmt_idx, sc->src_stmt_idx.len - 1);
  *pk = kind;
  *pi = idx;
  return sc->src_stmt_kind.len - 1;
}

int32_t pipeline_onefunc_num_src_stmt_order(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->src_stmt_kind.len : 0;
}

uint8_t pipeline_onefunc_src_stmt_kind(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  uint8_t *pk;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->src_stmt_kind.len)
    return 0;
  pk = (uint8_t *)grow_vec_at(&sc->src_stmt_kind, i);
  return pk ? *pk : 0;
}

int32_t pipeline_onefunc_src_stmt_idx(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pi;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->src_stmt_idx.len)
    return 0;
  pi = (int32_t *)grow_vec_at(&sc->src_stmt_idx, i);
  return pi ? *pi : 0;
}

int32_t pipeline_onefunc_push_body_expr_stmt(uint8_t *out, int32_t expr_ref) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->src_body_expr_stmt_refs) < 0)
    return -1;
  pr = (int32_t *)grow_vec_at(&sc->src_body_expr_stmt_refs, sc->src_body_expr_stmt_refs.len - 1);
  *pr = expr_ref;
  return sc->src_body_expr_stmt_refs.len - 1;
}

int32_t pipeline_onefunc_body_expr_stmt_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->src_body_expr_stmt_refs.len)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->src_body_expr_stmt_refs, i);
  return pr ? *pr : 0;
}

int32_t pipeline_onefunc_num_body_expr_stmts(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->src_body_expr_stmt_refs.len : 0;
}

/**
 * 将 OneFunc 中 if 链批量写入 Block 池。
 * 调用方勿预置 b->num_if_stmts（与 num_loops 相同）：否则 lazy_fix if_base 错位，
 * asm emit 读到错误 IfStmt，块内 if 被静默跳过（run-asm-binop-var #38）。
 */
void pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  struct ast_Block *b;
  if (a && br > 0 && (b = block_at(a, br)))
    b->num_if_stmts = 0;
  for (i = 0; i < count; i++) {
    pipeline_block_append_if(a, br, pipeline_onefunc_if_cond_ref(out, i),
                             pipeline_onefunc_if_then_body_ref(out, i),
                             pipeline_onefunc_if_else_body_ref(out, i));
  }
}

void pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  for (i = 0; i < count; i++) {
    pipeline_block_append_stmt_order(a, br, pipeline_onefunc_src_stmt_kind(out, i),
                                     pipeline_onefunc_src_stmt_idx(out, i));
  }
}

void pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  for (i = 0; i < count; i++) {
    pipeline_block_append_expr_stmt(a, br, pipeline_onefunc_body_expr_stmt_ref(out, i));
  }
}

/** 主池容量查询：无固定上限，返回 INT32_MAX 兼容旧边界检查。 */
int32_t pipeline_arena_type_cap(void) { return AST_POOL_NO_LIMIT; }
int32_t pipeline_arena_expr_cap(void) { return AST_POOL_NO_LIMIT; }
int32_t pipeline_arena_block_cap(void) { return AST_POOL_NO_LIMIT; }
int32_t pipeline_arena_func_cap(void) { return AST_POOL_NO_LIMIT; }

/** ---------- Module import / struct_layout / top_level / enum 动态池 ---------- */

int32_t pipeline_module_import_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->imports);
  if (idx < 0)
    return -1;
  m->num_imports = sc->imports.len;
  return idx;
}

void pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ImportEntry *ie;
  if (!bytes || len <= 0 || len > 255)
    return;
  ie = module_import_at(m, idx);
  if (!ie)
    return;
  ie->path_len = len;
  memset(ie->path, 0, sizeof(ie->path));
  memcpy(ie->path, bytes, (size_t)len);
}

int32_t pipeline_module_import_path_len(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->path_len : 0;
}

void pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap) {
  ImportEntry *ie;
  int32_t n;
  if (!dst || dst_cap <= 0)
    return;
  ie = module_import_at(m, idx);
  if (!ie) {
    dst[0] = 0;
    return;
  }
  n = ie->path_len;
  if (n >= dst_cap)
    n = dst_cap - 1;
  if (n > 0)
    memcpy(dst, ie->path, (size_t)n);
  dst[n] = 0;
}

uint8_t pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ImportEntry *ie;
  if (off < 0)
    return 0;
  ie = module_import_at(m, idx);
  if (!ie || off >= ie->path_len || off >= 256)
    return 0;
  return ie->path[off];
}

void pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind) {
  ImportEntry *ie = module_import_at(m, idx);
  if (ie)
    ie->kind = kind;
}

int32_t pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->kind : 0;
}

void pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ImportEntry *ie;
  if (!bytes || len <= 0 || len > 64)
    return;
  ie = module_import_at(m, idx);
  if (!ie)
    return;
  ie->binding_name_len = len;
  memset(ie->binding_name, 0, sizeof(ie->binding_name));
  memcpy(ie->binding_name, bytes, (size_t)len);
}

int32_t pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->binding_name_len : 0;
}

uint8_t pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ImportEntry *ie;
  if (off < 0 || off >= 64)
    return 0;
  ie = module_import_at(m, idx);
  if (!ie || off >= ie->binding_name_len)
    return 0;
  return ie->binding_name[off];
}

void pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n) {
  ImportEntry *ie = module_import_at(m, idx);
  if (ie)
    ie->select_count = n;
}

/** 向 import 槽追加一条 select 名称（动态 grow，无 8 条上限）。 */
int32_t pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  uint8_t *row;
  int32_t *pl;
  int32_t vi;
  int32_t n;
  if (!m || !bytes || len <= 0 || idx < 0 || !(sc = module_sidecar_get(m, 1)) || !(ie = module_import_at(m, idx)))
    return -1;
  if (ie->select_count == 0)
    ie->select_base = sc->import_select_name_rows.len;
  vi = grow_vec_push(&sc->import_select_name_rows);
  if (vi < 0 || grow_vec_push(&sc->import_select_name_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->import_select_name_rows, vi);
  pl = (int32_t *)grow_vec_at(&sc->import_select_name_lens, vi);
  if (!row || !pl)
    return -1;
  n = len > 63 ? 63 : len;
  memset(row, 0, 64);
  memcpy(row, bytes, (size_t)n);
  *pl = n;
  ie->select_count++;
  return ie->select_count - 1;
}

int32_t pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx) {
  ImportEntry *ie = module_import_at(m, idx);
  return ie ? ie->select_count : 0;
}

void pipeline_module_import_set_select_name(struct ast_Module *m, int32_t idx, int32_t sel, uint8_t *bytes,
                                            int32_t len) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  uint8_t *row;
  int32_t *pl;
  int32_t abs;
  int32_t n;
  if (!m || !bytes || len <= 0 || sel < 0 || !(sc = module_sidecar_get(m, 1)) || !(ie = module_import_at(m, idx)))
    return;
  while (ie->select_count <= sel) {
    if (pipeline_module_import_append_select_name(m, idx, bytes, len) < 0)
      return;
    if (sel < ie->select_count - 1)
      return;
  }
  abs = ie->select_base + sel;
  row = (uint8_t *)grow_vec_at(&sc->import_select_name_rows, abs);
  pl = (int32_t *)grow_vec_at(&sc->import_select_name_lens, abs);
  if (!row || !pl)
    return;
  n = len > 63 ? 63 : len;
  memset(row, 0, 64);
  memcpy(row, bytes, (size_t)n);
  *pl = n;
}

int32_t pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  int32_t *pl;
  int32_t abs;
  if (!m || sel < 0 || !(sc = module_sidecar_get(m, 0)) || !(ie = module_import_at(m, idx)))
    return 0;
  if (sel >= ie->select_count)
    return 0;
  abs = ie->select_base + sel;
  pl = (int32_t *)grow_vec_at(&sc->import_select_name_lens, abs);
  return pl ? *pl : 0;
}

uint8_t pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off) {
  ModuleSidecar *sc;
  ImportEntry *ie;
  uint8_t *row;
  int32_t abs;
  int32_t nlen;
  if (!m || sel < 0 || off < 0 || !(sc = module_sidecar_get(m, 0)) || !(ie = module_import_at(m, idx)))
    return 0;
  if (sel >= ie->select_count)
    return 0;
  abs = ie->select_base + sel;
  row = (uint8_t *)grow_vec_at(&sc->import_select_name_rows, abs);
  nlen = pipeline_module_import_select_name_len(m, idx, sel);
  if (!row || off >= nlen || off >= 64)
    return 0;
  return row[off];
}

int32_t pipeline_module_struct_layout_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->struct_layouts);
  if (idx < 0)
    return -1;
  memset(grow_vec_at(&sc->struct_layouts, idx), 0, sizeof(struct ast_StructLayout));
  m->num_struct_layouts = sc->struct_layouts.len;
  return idx;
}

void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    memset(sl, 0, sizeof(*sl));
}

void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  struct ast_StructLayout *sl;
  if (!bytes || len <= 0 || len > 63)
    return;
  sl = module_layout_at(m, idx);
  if (!sl)
    return;
  sl->name_len = len;
  memset(sl->name, 0, sizeof(sl->name));
  memcpy(sl->name, bytes, (size_t)len);
}

void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                             int32_t fname_len, int32_t ftype_ref, int32_t foff) {
  StructLayoutFieldEntry *fe;
  if (fname_len <= 0 || fname_len > 63 || j < 0)
    return;
  fe = module_layout_field_entry(m, li, j, 1);
  if (!fe)
    return;
  fe->name_len = fname_len;
  fe->type_ref = ftype_ref;
  fe->field_offset = foff;
  fe->field_align = 0;
  memset(fe->name, 0, sizeof(fe->name));
  if (fname_bytes)
    memcpy(fe->name, fname_bytes, (size_t)fname_len);
}

int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? (int32_t)sl->name_len : 0;
}

void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64) {
  struct ast_StructLayout *sl;
  if (!out64)
    return;
  sl = module_layout_at(m, idx);
  if (!sl) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, sl->name, 64);
}

int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->num_fields : 0;
}

void pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->num_fields = nf;
}

int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  return fe ? (int32_t)fe->type_ref : 0;
}

int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  int32_t fl;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  if (!fe)
    return 0;
  fl = fe->name_len;
  return (fl > 0 && fl <= 63) ? fl : 0;
}

void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64) {
  StructLayoutFieldEntry *fe;
  if (!out64 || j < 0) {
    if (out64)
      memset(out64, 0, 64);
    return;
  }
  fe = module_layout_field_entry(m, li, j, 0);
  if (!fe) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, fe->name, 64);
}

/** 读 struct_layout 槽名字节；越界返回 0。 */
uint8_t pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  struct ast_StructLayout *sl;
  if (off < 0 || off >= 64)
    return 0;
  sl = module_layout_at(m, idx);
  if (!sl || off >= sl->name_len)
    return 0;
  return sl->name[off];
}

/** 写字段 offset（set_field 已写；单独更新用）。 */
void pipeline_module_struct_layout_set_field_offset(struct ast_Module *m, int32_t li, int32_t j, int32_t foff) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return;
  fe = module_layout_field_entry(m, li, j, 0);
  if (fe)
    fe->field_offset = foff;
}

int32_t pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  return fe ? fe->field_offset : 0;
}

/** DOD-CL：读 struct 字段 align(N) 要求；0 表示未指定。 */
int32_t pipeline_module_struct_layout_field_align_at(struct ast_Module *m, int32_t li, int32_t j) {
  StructLayoutFieldEntry *fe;
  if (j < 0)
    return 0;
  fe = module_layout_field_entry(m, li, j, 0);
  return fe ? fe->field_align : 0;
}

/** DOD-CL：写 struct 字段 align(N) 要求（parser 在 set_field 之后调用）。 */
void pipeline_module_struct_layout_set_field_align(struct ast_Module *m, int32_t li, int32_t j, int32_t al) {
  StructLayoutFieldEntry *fe;
  if (j < 0 || al < 0)
    return;
  fe = module_layout_field_entry(m, li, j, 0);
  if (fe)
    fe->field_align = al;
}

void pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->allow_padding = v;
}

int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->allow_padding : 0;
}

/** DOD-S1：写 struct layout 的 soa 标记（parser `struct Name soa {`）。 */
void pipeline_module_struct_layout_set_soa(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->soa = v;
}

/** DOD-S1：读 struct layout 是否为 SoA 布局。 */
int32_t pipeline_module_struct_layout_soa_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->soa : 0;
}

/** 写 struct layout 的 packed 标记（parser `struct Name packed {`）。 */
void pipeline_module_struct_layout_set_packed(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->packed = v;
}

/** 读 struct layout 是否为 packed 布局。 */
int32_t pipeline_module_struct_layout_packed_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->packed : 0;
}

/** MOD-02：写 struct layout 的 #[repr(compatible)] 标记。 */
void pipeline_module_struct_layout_set_repr_compatible(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->repr_compatible = v;
}

/** MOD-02：读 struct layout 是否 #[repr(compatible)]。 */
int32_t pipeline_module_struct_layout_repr_compatible_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->repr_compatible : 0;
}

/** typeck.x：读 module.num_struct_layouts；勿 X 内 Module 字段访问（check_block 失败）。 */
int32_t pipeline_module_num_struct_layouts_at(struct ast_Module *m) {
  return m ? m->num_struct_layouts : 0;
}

int32_t pipeline_module_top_level_let_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->top_level_lets);
  if (idx < 0)
    return -1;
  m->num_top_level_lets = sc->top_level_lets.len;
  return idx;
}

void pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                       int32_t type_ref, int32_t init_ref, int32_t is_const) {
  TopLevelLetEntry *tl;
  ModuleSidecar *sc;
  if (!m || !name || name_len <= 0 || name_len > 64)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  if (!tl)
    return;
  tl->name_len = name_len;
  tl->type_ref = type_ref;
  tl->init_ref = init_ref;
  tl->is_const = is_const;
  memset(tl->name, 0, sizeof(tl->name));
  memcpy(tl->name, name, (size_t)name_len);
}

int32_t pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->name_len : 0;
}

uint8_t pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len || off < 0 || off >= 64)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl && off < tl->name_len ? tl->name[off] : 0;
}

int32_t pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->type_ref : 0;
}

int32_t pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->init_ref : 0;
}

int32_t pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TopLevelLetEntry *tl;
  if (!sc || idx < 0 || idx >= sc->top_level_lets.len)
    return 0;
  tl = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, idx);
  return tl ? tl->is_const : 0;
}

/** 分配 module 侧车 type 别名槽；返回 idx 或 -1。 */
int32_t pipeline_module_type_alias_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->type_aliases);
  if (idx < 0)
    return -1;
  return idx;
}

/** 写入 type 别名 name 与 target type ref。 */
void pipeline_module_type_alias_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                    int32_t target_type_ref) {
  TypeAliasEntry *ta;
  ModuleSidecar *sc;
  int32_t i;
  if (!m || !name || name_len <= 0 || name_len > 64)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc || idx < 0 || idx >= sc->type_aliases.len)
    return;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  if (!ta)
    return;
  for (i = 0; i < name_len; i++)
    ta->name[i] = name[i];
  for (i = name_len; i < 64; i++)
    ta->name[i] = 0;
  ta->name_len = name_len;
  ta->target_type_ref = target_type_ref;
  if (getenv("SHUX_DEBUG_PIPE") != NULL) {
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] type_alias_set idx=%d len=%d target=%d\n", (int)idx, (int)name_len,
            (int)target_type_ref);
  }
}

/** 读 type 别名名长度。 */
int32_t pipeline_module_type_alias_name_len(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TypeAliasEntry *ta;
  if (!sc || idx < 0 || idx >= sc->type_aliases.len)
    return 0;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  return ta ? ta->name_len : 0;
}

/** 读 type 别名名字节；越界返回 0。 */
uint8_t pipeline_module_type_alias_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TypeAliasEntry *ta;
  if (!sc || idx < 0 || idx >= sc->type_aliases.len || off < 0 || off >= 64)
    return 0;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  return ta ? ta->name[off] : 0;
}

/** 读 type 别名 target type ref。 */
int32_t pipeline_module_type_alias_target_ref(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  TypeAliasEntry *ta;
  if (!sc || idx < 0 || idx >= sc->type_aliases.len)
    return 0;
  ta = (TypeAliasEntry *)grow_vec_at(&sc->type_aliases, idx);
  return ta ? ta->target_type_ref : 0;
}

/** 读 module type 别名数量（glue 薄 struct 走 sidecar，勿读 module 字段）。 */
int32_t pipeline_module_num_type_aliases_at(struct ast_Module *m) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  if (!sc)
    return 0;
  return sc->type_aliases.len;
}

/**
 * 在 block 的 stmt_order 下标 pos 处插入 n_items 条记录，并修正同 arena 内后续 block 的 stmt_order_base。
 */
static void pipeline_block_stmt_order_insert_at(struct ast_ASTArena *a, int32_t br, int32_t pos,
                                                const struct ast_StmtOrderItem *items, int32_t n_items) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t abs;
  int32_t move_count;
  int32_t bi;
  size_t esz;
  uint8_t *data;
  int32_t i;
  if (!a || br <= 0 || !items || n_items <= 0 || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return;
  if (pos < 0)
    pos = 0;
  if (pos > b->num_stmt_order)
    pos = b->num_stmt_order;
  abs = b->stmt_order_base + pos;
  move_count = sc->stmt_order.len - abs;
  esz = sizeof(struct ast_StmtOrderItem);
  data = sc->stmt_order.data;
  for (i = 0; i < n_items; i++) {
    if (!grow_vec_ensure(&sc->stmt_order))
      return;
    data = sc->stmt_order.data;
  }
  if (move_count > 0 && data)
    memmove(data + (size_t)(abs + n_items) * esz, data + (size_t)abs * esz, (size_t)move_count * esz);
  for (i = 0; i < n_items; i++) {
    struct ast_StmtOrderItem *so = (struct ast_StmtOrderItem *)(data + (size_t)(abs + i) * esz);
    *so = items[i];
  }
  sc->stmt_order.len += n_items;
  b->num_stmt_order += n_items;
  for (bi = 1; bi <= a->num_blocks; bi++) {
    struct ast_Block *ob = block_at(a, bi);
    if (ob && bi != br && ob->stmt_order_base >= abs)
      ob->stmt_order_base += n_items;
  }
}

/**
 * 在 block 的 stmt_order 最前插入 count 条 let 初始化（kind=1，idx 为块内 let 下标）。
 */
static void pipeline_block_stmt_order_prepend_lets(struct ast_ASTArena *a, int32_t br, int32_t let_start_idx,
                                                   int32_t let_count) {
  struct ast_StmtOrderItem ins[64];
  int32_t li;
  if (!a || br <= 0 || let_count <= 0 || let_count > 64)
    return;
  for (li = 0; li < let_count; li++) {
    ins[li].kind = 1;
    ins[li].idx = let_start_idx + li;
  }
  pipeline_block_stmt_order_insert_at(a, br, 0, ins, let_count);
}

/**
 * 块首 parse_body_lets 产生的 let（idx < prefix_n）须在 stmt_order 中先于 if/loop；
 * parser 偶发乱序（with_arena 内连续 if）时原地重排，不改变条目数量。
 */
void pipeline_block_stmt_order_fix_prefix_lets(struct ast_ASTArena *a, int32_t br, int32_t prefix_n) {
  struct ast_Block *b;
  ArenaSidecar *sc;
  struct ast_StmtOrderItem old[512];
  struct ast_StmtOrderItem neu[512];
  int32_t nso;
  int32_t i;
  int32_t nn;
  int32_t pi;
  int32_t lets_seen;
  int32_t need_fix;
  int32_t abs;
  if (!a || br <= 0 || prefix_n <= 0 || prefix_n > 64)
    return;
  b = block_at(a, br);
  sc = arena_sidecar_get(a, 1);
  if (!b || !sc || b->num_stmt_order <= 0)
    return;
  nso = b->num_stmt_order;
  if (nso > 512)
    return;
  for (i = 0; i < nso; i++) {
    old[i].kind = pipeline_block_stmt_order_kind(a, br, i);
    old[i].idx = (int32_t)pipeline_block_stmt_order_idx(a, br, i);
  }
  need_fix = 0;
  lets_seen = 0;
  for (i = 0; i < nso; i++) {
    if (old[i].kind == 0)
      continue;
    if (old[i].kind == 1 && old[i].idx >= 0 && old[i].idx < prefix_n) {
      if (lets_seen != old[i].idx)
        need_fix = 1;
      lets_seen++;
      continue;
    }
    if (lets_seen < prefix_n)
      need_fix = 1;
    break;
  }
  if (!need_fix && lets_seen >= prefix_n)
    return;
  nn = 0;
  for (i = 0; i < nso; i++) {
    if (old[i].kind == 0)
      neu[nn++] = old[i];
  }
  for (pi = 0; pi < prefix_n; pi++) {
    neu[nn].kind = 1;
    neu[nn].idx = pi;
    nn++;
  }
  for (i = 0; i < nso; i++) {
    if (old[i].kind == 0)
      continue;
    if (old[i].kind == 1 && old[i].idx >= 0 && old[i].idx < prefix_n)
      continue;
    neu[nn++] = old[i];
  }
  if (nn != nso)
    return;
  abs = b->stmt_order_base;
  for (i = 0; i < nn; i++) {
    struct ast_StmtOrderItem *so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs + i);
    if (so)
      *so = neu[i];
  }
}

/**
 * with_arena 块：stmt_order 须含 kind=6(region) 供 asm init/body/deinit；
 * parse_one_function 偶发只把内层 let/if 扁平写入函数体 stmt_order 而漏 kind=6（with_arena_vec gate 仅 emit 前 2 条 push）。
 * 若本块有 with_arena region 且 stmt_order 无 kind=6，则改为仅保留 region 项（内层 body 块已由 parse_block_into 填好）。
 */
void pipeline_block_with_arena_fixup_stmt_order(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block *b;
  ArenaSidecar *sc;
  int32_t ri;
  int32_t wa_ri;
  int32_t inner;
  int32_t i;
  int32_t abs;
  struct ast_StmtOrderItem *so;
  if (!a || br <= 0)
    return;
  b = block_at(a, br);
  sc = arena_sidecar_get(a, 1);
  if (!b || !sc || b->num_regions <= 0)
    return;
  wa_ri = -1;
  inner = 0;
  for (ri = 0; ri < b->num_regions; ri++) {
    if (pipeline_block_region_with_arena_cap_ref(a, br, ri) > 0) {
      wa_ri = ri;
      inner = pipeline_block_region_body_ref(a, br, ri);
      break;
    }
  }
  if (wa_ri < 0 || inner <= 0 || inner == br) {
    if (getenv("SHUX_ASM_DEBUG") && b->num_regions > 0)
      fprintf(stderr, "shux: wa_fixup skip br=%d wa_ri=%d inner=%d nso=%d\n", (int)br, (int)wa_ri, (int)inner,
              (int)b->num_stmt_order);
    return;
  }
  for (i = 0; i < b->num_stmt_order; i++) {
    if (pipeline_block_stmt_order_kind(a, br, i) == 6) {
      if (getenv("SHUX_ASM_DEBUG")) {
        struct ast_Block *ib = inner > 0 ? block_at(a, inner) : NULL;
        fprintf(stderr, "shux: wa_fixup ok br=%d inner=%d in_nso=%d in_nif=%d\n", (int)br, (int)inner,
                ib ? (int)ib->num_stmt_order : -1, ib ? (int)ib->num_if_stmts : -1);
      }
      return;
    }
  }
  if (getenv("SHUX_ASM_DEBUG"))
    fprintf(stderr, "shux: wa_fixup apply br=%d wa_ri=%d inner=%d old_nso=%d\n", (int)br, (int)wa_ri, (int)inner,
            (int)b->num_stmt_order);
  abs = b->stmt_order_base;
  if (abs < 0)
    return;
  b->num_stmt_order = 1;
  so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs);
  if (!so)
    return;
  so->kind = 6;
  so->idx = wa_ri;
}

/**
 * 若 stmt_order 中 if(kind=5) 条目少于 num_if_stmts，按侧车池 0..n-1 重建（去掉误解析的 expr kind=2）。
 * with_arena 内层块 parse 偶发 `(push!=0)` expr + 仅前 2 条 if kind=5。
 */
void pipeline_block_stmt_order_rebuild_sparse_ifs(struct ast_ASTArena *a, int32_t br) {
  struct ast_Block *b;
  ArenaSidecar *sc;
  struct ast_StmtOrderItem neu[512];
  int32_t nso;
  int32_t nif;
  int32_t i;
  int32_t nn;
  int32_t if_in_order;
  int32_t abs;
  if (!a || br <= 0)
    return;
  b = block_at(a, br);
  sc = arena_sidecar_get(a, 1);
  if (!b || !sc || b->num_if_stmts <= 0)
    return;
  nso = b->num_stmt_order;
  nif = b->num_if_stmts;
  if (nso > 512)
    return;
  if_in_order = 0;
  for (i = 0; i < nso; i++) {
    if (pipeline_block_stmt_order_kind(a, br, i) == 5)
      if_in_order++;
  }
  if (if_in_order >= nif)
    return;
  nn = 0;
  for (i = 0; i < b->num_consts; i++) {
    neu[nn].kind = 0;
    neu[nn].idx = i;
    nn++;
  }
  for (i = 0; i < b->num_lets; i++) {
    neu[nn].kind = 1;
    neu[nn].idx = i;
    nn++;
  }
  for (i = 0; i < nif; i++) {
    neu[nn].kind = 5;
    neu[nn].idx = i;
    nn++;
  }
  for (i = 0; i < nso; i++) {
    uint8_t k = pipeline_block_stmt_order_kind(a, br, i);
    int32_t idx = pipeline_block_stmt_order_idx(a, br, i);
    if (k == 0 || k == 1 || k == 5)
      continue;
    if (k == 2)
      continue; /* 丢弃误解析 cond 片段 expr */
    neu[nn].kind = k;
    neu[nn].idx = idx;
    nn++;
  }
  abs = b->stmt_order_base;
  if (abs < 0)
    return;
  b->num_stmt_order = nn;
  for (i = 0; i < nn; i++) {
    struct ast_StmtOrderItem *so = (struct ast_StmtOrderItem *)grow_vec_at(&sc->stmt_order, abs + i);
    if (so)
      *so = neu[i];
  }
  if (getenv("SHUX_ASM_DEBUG"))
    fprintf(stderr, "shux: if_rebuild br=%d nif=%d old_if_in_order=%d new_nso=%d\n", (int)br, (int)nif, (int)if_in_order,
            (int)nn);
}

/** 对 module 全部函数体块执行 with_arena stmt_order 修补（parse 后/typeck 前调用）。 */
void pipeline_module_fixup_with_arena_stmt_orders(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t fi;
  if (!m || !a)
    return;
  for (fi = 0; fi < m->num_funcs; fi++) {
    int32_t br = pipeline_module_func_body_ref_at(m, fi);
    struct ast_Block *b;
    int32_t ri;
    if (br <= 0)
      continue;
    b = block_at(a, br);
    if (getenv("SHUX_ASM_DEBUG") && b && b->num_regions > 0)
      fprintf(stderr, "shux: wa_fixup scan fi=%d br=%d nreg=%d nso=%d\n", (int)fi, (int)br, (int)b->num_regions,
              (int)b->num_stmt_order);
    pipeline_block_with_arena_fixup_stmt_order(a, br);
    pipeline_block_stmt_order_rebuild_sparse_ifs(a, br);
    if (b) {
      for (ri = 0; ri < b->num_regions; ri++) {
        int32_t inner = pipeline_block_region_body_ref(a, br, ri);
        if (inner > 0 && inner != br) {
          pipeline_block_stmt_order_fix_prefix_lets(a, inner, block_at(a, inner) ? block_at(a, inner)->num_lets : 0);
          pipeline_block_stmt_order_rebuild_sparse_ifs(a, inner);
        }
      }
    }
  }
}

/**
 * 将 module 顶层 let/const 按序并入 main（或库模块首个 non extern 函数）体块，供 asm 栈槽初始化。
 * 保留 num_top_level_lets 供 emit 对其它函数做 module const 字面量回落（AF_INET as u16 等）。
 */
void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t mi;
  int32_t br;
  int32_t tl;
  int32_t fi;
  int32_t n;
  int32_t let_start_idx;
  uint8_t name_buf[64];
  int32_t name_len;
  int32_t k;
  ModuleSidecar *sc;
  TopLevelLetEntry *ent;
  const char *dbg_hoist;
  struct ast_Block *main_blk;
  if (!m || !a || m->num_top_level_lets <= 0)
    return;
  dbg_hoist = getenv("SHUX_DEBUG_TOPLEVEL_HOIST");
  mi = m->main_func_index;
  if (mi < 0) {
    /* 库模块 -o .o 无 main：并入首个可 emit 的非 extern 函数体（与 C static 全局等价）。 */
    mi = -1;
    for (fi = 0; fi < m->num_funcs; fi++) {
      if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 &&
          pipeline_module_func_body_ref_at(m, fi) > 0) {
        mi = fi;
        break;
      }
    }
    if (mi < 0)
      return;
  }
  br = pipeline_module_func_body_ref_at(m, mi);
  if (br <= 0)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  main_blk = block_at(a, br);
  let_start_idx = main_blk ? main_blk->num_lets : 0;
  n = m->num_top_level_lets;
  if (dbg_hoist && dbg_hoist[0] && dbg_hoist[0] != '0') {
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "hoist debug: target_fi=%d body_ref=%d top_level_lets=%d prior_block_lets=%d",
                 (int)mi, (int)br, (int)n, (int)let_start_idx);
  }
  for (tl = 0; tl < n; tl++) {
    if (tl < 0 || tl >= sc->top_level_lets.len)
      break;
    ent = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, tl);
    if (!ent || ent->name_len <= 0 || ent->name_len > 64)
      continue;
    if (dbg_hoist && dbg_hoist[0] && dbg_hoist[0] != '0' && tl < 40) {
      diag_reportf(NULL, 0, 0, "note", NULL,
                   "hoist debug: idx=%d const=%d name=%.*s init_ref=%d init_kind=%d",
                   (int)tl, (int)ent->is_const, (int)ent->name_len, (const char *)ent->name,
                   (int)ent->init_ref, (int)pipeline_expr_kind_ord_at(a, ent->init_ref));
    }
    name_len = ent->name_len;
    for (k = 0; k < name_len; k++)
      name_buf[k] = ent->name[k];
    (void)pipeline_block_append_let(a, br, name_buf, name_len, ent->type_ref, ent->init_ref);
  }
  pipeline_block_stmt_order_prepend_lets(a, br, let_start_idx, n);
}

/**
 * 返回 hoist 目标函数下标：main 或库模块首个非 extern 实现函数。
 */
int32_t pipeline_asm_hoist_target_func_index(struct ast_Module *m) {
  int32_t fi;
  if (!m)
    return -1;
  if (m->main_func_index >= 0)
    return m->main_func_index;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 &&
        pipeline_module_func_body_ref_at(m, fi) > 0)
      return fi;
  }
  return -1;
}

/**
 * 累加 module 顶层 let/const 栈占用（供非 hoist 目标函数的 frame_size 估算）。
 */
int32_t pipeline_asm_sum_module_top_level_lets_stack(struct ast_ASTArena *a, struct ast_Module *m, int32_t off) {
  ModuleSidecar *sc;
  int32_t tl;
  int32_t n;
  if (!a || !m || m->num_top_level_lets <= 0)
    return off;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return off;
  n = m->num_top_level_lets;
  for (tl = 0; tl < n; tl++) {
    TopLevelLetEntry *ent;
    int32_t type_ref;
    int32_t init_ref;
    if (tl < 0 || tl >= sc->top_level_lets.len)
      break;
    ent = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, tl);
    if (!ent || ent->type_ref <= 0)
      continue;
    type_ref = ent->type_ref;
    init_ref = ent->init_ref;
    (void)asm_local_slot_reg_offset(a, type_ref, off, &off);
    off += pipeline_asm_let_init_stack_reserve_bytes(a, type_ref, init_ref);
  }
  return off;
}

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
  if (getenv("SHUX_ASM_DEBUG"))
    fprintf(stderr, "shux: backend_asm_codegen fill done, calling mega_body_c\n");
  glue_wpo_mono_reset_pending();
  /** dep+entry 顺序写入同一 elf_ctx：为 tail_join/loop 等局部标签分配唯一 scope。 */
  pipeline_elf_label_mod_scope_begin_module();
  /** WPO-S3：import struct FIELD_ACCESS 查 layout 时须可见 dep 池（backend.x mega 亦会设置）。 */
  pipeline_asm_emit_set_module(m);
  pipeline_asm_emit_set_arena(a);
  pipeline_asm_emit_set_elf_ctx(elf_ctx);
  if (getenv("SHUX_ASM_DEBUG") && m && asm_module_is_parser_emit_heavy(m))
    fprintf(stderr, "shux: seed_mega parser nfunc=%d elf_ctx=%p code_len=%d\n", (int)m->num_funcs, (void *)elf_ctx,
            elf_ctx ? (int)elf_ctx->code_len : -1);
  rc = pipeline_backend_asm_codegen_ast_to_elf_mega_body_c(m, a, elf_ctx, pipeline_ctx);
  pipeline_asm_emit_set_elf_ctx(NULL);
  if (rc != 0)
    return rc;
  return pipeline_asm_emit_wpo_mono_thunks_elf_c(m, a, elf_ctx, pipeline_ctx);
}

int32_t pipeline_module_enum_alloc(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m || !(sc = module_sidecar_get(m, 1)))
    return -1;
  idx = grow_vec_push(&sc->module_enums);
  if (idx < 0)
    return -1;
  m->num_module_enums = sc->module_enums.len;
  return idx;
}

void pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ModuleEnumEntry *me;
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  if (!sc || !bytes || len <= 0 || len > 64 || idx < 0 || idx >= sc->module_enums.len)
    return;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me)
    return;
  me->name_len = len;
  me->num_variants = 0;
  memset(me->name, 0, sizeof(me->name));
  memcpy(me->name, bytes, (size_t)len);
}

/** 向 module 第 idx 个 enum 追加变体名；成功返回变体 tag（0..n-1），失败返回 -1。 */
int32_t pipeline_module_enum_append_variant(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  ModuleEnumEntry *me;
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  int32_t slot;
  if (!sc || !bytes || len <= 0 || len > 64 || idx < 0 || idx >= sc->module_enums.len)
    return -1;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me || me->num_variants >= MODULE_ENUM_MAX_VARIANTS)
    return -1;
  slot = me->num_variants;
  me->variant_name_len[slot] = len;
  memset(me->variant_name[slot], 0, 64);
  memcpy(me->variant_name[slot], bytes, (size_t)len);
  me->num_variants = slot + 1;
  return slot;
}

/** 按枚举类型名 + 变体名查 tag；未命中返回 -1。 */
int32_t pipeline_module_enum_variant_tag_for_names(struct ast_Module *m, uint8_t *enum_name, int32_t enum_len,
                                                   uint8_t *variant_name, int32_t variant_len) {
  ModuleSidecar *sc;
  int32_t ei;
  if (!m || !enum_name || enum_len <= 0 || !variant_name || variant_len <= 0)
    return -1;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return -1;
  for (ei = 0; ei < sc->module_enums.len; ei++) {
    ModuleEnumEntry *me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, ei);
    int32_t vi;
    if (!me || me->name_len != enum_len)
      continue;
    {
      int32_t j = 0;
      int match = 1;
      for (j = 0; j < enum_len; j++) {
        if (me->name[j] != enum_name[j]) {
          match = 0;
          break;
        }
      }
      if (!match)
        continue;
    }
    for (vi = 0; vi < me->num_variants; vi++) {
      if (me->variant_name_len[vi] != variant_len)
        continue;
      {
        int32_t j = 0;
        int match = 1;
        for (j = 0; j < variant_len; j++) {
          if (me->variant_name[vi][j] != variant_name[j]) {
            match = 0;
            break;
          }
        }
        if (match)
          return vi;
      }
    }
    return -1;
  }
  return -1;
}

/** 若 expr 为 TypeName.Variant（base=VAR），写入 is_enum_variant 与 enum_variant_tag。 */
void pipeline_expr_try_mark_enum_field_access(struct ast_Module *m, struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *e;
  struct ast_Expr *base;
  int32_t tag;
  uint8_t ename[64];
  uint8_t vname[64];
  int32_t elen;
  int32_t vlen;
  if (!m || !a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  e = pipeline_arena_expr_ptr(a, expr_ref);
  if (!e || e->kind != ast_ExprKind_EXPR_FIELD_ACCESS || e->field_access_is_enum_variant != 0)
    return;
  base = pipeline_arena_expr_ptr(a, e->field_access_base_ref);
  if (!base || base->kind != ast_ExprKind_EXPR_VAR || base->var_name_len <= 0)
    return;
  elen = base->var_name_len;
  if (elen > 63)
    elen = 63;
  memcpy(ename, base->var_name, (size_t)elen);
  vlen = e->field_access_field_len;
  if (vlen <= 0 || vlen > 63)
    return;
  memcpy(vname, e->field_access_field_name, (size_t)vlen);
  tag = pipeline_module_enum_variant_tag_for_names(m, ename, elen, vname, vlen);
  if (tag < 0)
    return;
  e->field_access_is_enum_variant = 1;
  e->enum_variant_tag = tag;
}

int32_t pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  return me ? me->name_len : 0;
}

uint8_t pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len || off < 0 || off >= 64)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  return me && off < me->name_len ? me->name[off] : 0;
}

int32_t pipeline_module_enum_num_variants(struct ast_Module *m, int32_t idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  return me ? me->num_variants : 0;
}

int32_t pipeline_module_enum_variant_name_len(struct ast_Module *m, int32_t idx, int32_t variant_idx) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me || variant_idx < 0 || variant_idx >= me->num_variants)
    return 0;
  return me->variant_name_len[variant_idx];
}

uint8_t pipeline_module_enum_variant_name_byte_at(struct ast_Module *m, int32_t idx, int32_t variant_idx, int32_t off) {
  ModuleSidecar *sc = module_sidecar_get(m, 0);
  ModuleEnumEntry *me;
  if (!sc || idx < 0 || idx >= sc->module_enums.len || off < 0 || off >= 64)
    return 0;
  me = (ModuleEnumEntry *)grow_vec_at(&sc->module_enums, idx);
  if (!me || variant_idx < 0 || variant_idx >= me->num_variants || off >= me->variant_name_len[variant_idx])
    return 0;
  return me->variant_name[variant_idx][off];
}

/** OneFunc const/let scratch 追加 API。 */
/**
 * 向 OneFunc 侧车池追加一条 const（与 append_let 对称；init_ref/type_ref 供 fill_block_const_let_from_res）。
 */
int32_t pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                      int32_t init_ref, int32_t type_ref) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t *pv;
  int32_t *pr;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !name || name_len <= 0 || name_len > 64)
    return -1;
  if (grow_vec_push(&sc->const_names) < 0 || grow_vec_push(&sc->const_name_lens) < 0 ||
      grow_vec_push(&sc->const_init_vals) < 0 || grow_vec_push(&sc->const_init_refs) < 0 ||
      grow_vec_push(&sc->const_type_refs) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->const_names, sc->const_names.len - 1);
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, sc->const_name_lens.len - 1);
  pv = (int32_t *)grow_vec_at(&sc->const_init_vals, sc->const_init_vals.len - 1);
  pr = (int32_t *)grow_vec_at(&sc->const_init_refs, sc->const_init_refs.len - 1);
  pt = (int32_t *)grow_vec_at(&sc->const_type_refs, sc->const_type_refs.len - 1);
  if (!row || !pl || !pv || !pr || !pt)
    return -1;
  memset(row, 0, 64);
  memcpy(row, name, (size_t)name_len);
  *pl = name_len;
  *pv = init_val;
  *pr = init_ref;
  *pt = type_ref;
  return sc->const_names.len - 1;
}

int32_t pipeline_onefunc_append_const_name(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val) {
  return pipeline_onefunc_append_const(out, name, name_len, init_val, 0, 0);
}

int32_t pipeline_onefunc_const_init_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_init_refs.len)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->const_init_refs, i);
  return pr ? *pr : 0;
}

int32_t pipeline_onefunc_const_type_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_type_refs.len)
    return 0;
  pt = (int32_t *)grow_vec_at(&sc->const_type_refs, i);
  return pt ? *pt : 0;
}

int32_t pipeline_onefunc_const_name_len(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_name_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, i);
  return pl ? *pl : 0;
}

uint8_t pipeline_onefunc_const_name_byte_at(uint8_t *out, int32_t i, int32_t off) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_names.len || off < 0 || off >= 64)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->const_names, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

int32_t pipeline_onefunc_const_init_val(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_init_vals.len)
    return 0;
  pv = (int32_t *)grow_vec_at(&sc->const_init_vals, i);
  return pv ? *pv : 0;
}

int32_t pipeline_onefunc_num_consts(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->const_name_lens.len : 0;
}

/** OneFunc 侧车 let_init_refs：-1 表示 `let x: T;` 无显式初值（栈零填，等价 u8[N]=[] / asm prologue 清零）。 */
#define PIPELINE_ONEFUNC_LET_INIT_OMITTED (-1)

int32_t pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                    int32_t type_ref) {
  OneFuncSidecar *sc;
  uint8_t *row;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !name || name_len <= 0 || name_len > 64)
    return -1;
  if (grow_vec_push(&sc->let_names) < 0 || grow_vec_push(&sc->let_name_lens) < 0 ||
      grow_vec_push(&sc->let_init_vals) < 0 || grow_vec_push(&sc->let_init_refs) < 0 ||
      grow_vec_push(&sc->let_type_refs) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->let_names, sc->let_names.len - 1);
  if (!row)
    return -1;
  memset(row, 0, 64);
  memcpy(row, name, (size_t)name_len);
  *((int32_t *)grow_vec_at(&sc->let_name_lens, sc->let_name_lens.len - 1)) = name_len;
  *((int32_t *)grow_vec_at(&sc->let_init_vals, sc->let_init_vals.len - 1)) = init_val;
  *((int32_t *)grow_vec_at(&sc->let_init_refs, sc->let_init_refs.len - 1)) = init_ref;
  *((int32_t *)grow_vec_at(&sc->let_type_refs, sc->let_type_refs.len - 1)) = type_ref;
  return sc->let_names.len - 1;
}

int32_t pipeline_onefunc_let_name_len(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_name_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->let_name_lens, i);
  return pl ? *pl : 0;
}

uint8_t pipeline_onefunc_let_name_byte_at(uint8_t *out, int32_t i, int32_t off) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_names.len || off < 0 || off >= 64)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->let_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->let_names, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

int32_t pipeline_onefunc_let_init_val(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_init_vals.len)
    return 0;
  pv = (int32_t *)grow_vec_at(&sc->let_init_vals, i);
  return pv ? *pv : 0;
}

int32_t pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pr;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_init_refs.len)
    return 0;
  pr = (int32_t *)grow_vec_at(&sc->let_init_refs, i);
  return pr ? *pr : 0;
}

int32_t pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_type_refs.len)
    return 0;
  pt = (int32_t *)grow_vec_at(&sc->let_type_refs, i);
  return pt ? *pt : 0;
}

int32_t pipeline_onefunc_num_lets(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->let_name_lens.len : 0;
}

/** 追加一条解析 scratch 形参；返回新下标，失败 -1。type_ref 可随后用 set_param_type_ref 填写。 */
int32_t pipeline_onefunc_append_param(uint8_t *out, uint8_t *name, int32_t name_len, int32_t type_ref) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t *pt;
  int32_t n;
  int32_t k;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !name || name_len <= 0 || name_len > 31)
    return -1;
  if (grow_vec_push(&sc->param_names) < 0 || grow_vec_push(&sc->param_name_lens) < 0 ||
      grow_vec_push(&sc->param_type_refs) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->param_names, sc->param_names.len - 1);
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, sc->param_name_lens.len - 1);
  pt = (int32_t *)grow_vec_at(&sc->param_type_refs, sc->param_type_refs.len - 1);
  if (!row || !pl || !pt)
    return -1;
  memset(row, 0, 32);
  n = name_len;
  for (k = 0; k < n; k++)
    row[k] = name[k];
  *pl = n;
  *pt = type_ref;
  return sc->param_name_lens.len - 1;
}

void pipeline_onefunc_set_param_type_ref(uint8_t *out, int32_t i, int32_t type_ref) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_type_refs.len)
    return;
  pt = (int32_t *)grow_vec_at(&sc->param_type_refs, i);
  if (pt)
    *pt = type_ref;
}

int32_t pipeline_onefunc_param_name_len(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_name_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, i);
  return pl ? *pl : 0;
}

uint8_t pipeline_onefunc_param_name_byte_at(uint8_t *out, int32_t i, int32_t off) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_names.len || off < 0 || off >= 32)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->param_names, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

void pipeline_onefunc_param_name_copy32(uint8_t *out, int32_t i, uint8_t *dst) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 32);
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_names.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->param_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->param_names, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 31)
    n = 31;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

int32_t pipeline_onefunc_param_type_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pt;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->param_type_refs.len)
    return 0;
  pt = (int32_t *)grow_vec_at(&sc->param_type_refs, i);
  return pt ? *pt : 0;
}

int32_t pipeline_onefunc_num_params_from_pool(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->param_name_lens.len : 0;
}

int32_t pipeline_onefunc_append_call_arg_val(uint8_t *out, int32_t val) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->call_arg_vals) < 0)
    return -1;
  pv = (int32_t *)grow_vec_at(&sc->call_arg_vals, sc->call_arg_vals.len - 1);
  if (!pv)
    return -1;
  *pv = val;
  return sc->call_arg_vals.len - 1;
}

int32_t pipeline_onefunc_call_arg_val_at(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->call_arg_vals.len)
    return 0;
  pv = (int32_t *)grow_vec_at(&sc->call_arg_vals, i);
  return pv ? *pv : 0;
}

void pipeline_onefunc_reset_call_args(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  if (sc)
    sc->call_arg_vals.len = 0;
}

/** 将 grow 向量 src 全部元素追加到 dst（先不清 dst，由调用方 reset）。 */
static void grow_vec_copy_append(GrowVec *dst, GrowVec *src) {
  int32_t i;
  if (!dst || !src)
    return;
  for (i = 0; i < src->len; i++) {
    void *ps = grow_vec_at(src, i);
    void *pd;
    if (grow_vec_push(dst) < 0)
      return;
    pd = grow_vec_at(dst, dst->len - 1);
    if (ps && pd)
      memcpy(pd, ps, src->elem_sz);
  }
}

/** 复制 OneFunc 侧车池（const/let/if/stmt_order 等）；dst 与 src 可为不同 OneFuncResult 地址。 */
void pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src) {
  OneFuncSidecar *dsc;
  OneFuncSidecar *ssc;
  if (!dst || !src || dst == src)
    return;
  if (!(ssc = onefunc_sidecar_get(src, 0)))
    return;
  ast_pool_onefunc_reset(dst);
  if (!(dsc = onefunc_sidecar_get(dst, 0)))
    return;
  grow_vec_copy_append(&dsc->if_cond_refs, &ssc->if_cond_refs);
  grow_vec_copy_append(&dsc->if_then_body_refs, &ssc->if_then_body_refs);
  grow_vec_copy_append(&dsc->if_else_body_refs, &ssc->if_else_body_refs);
  grow_vec_copy_append(&dsc->const_names, &ssc->const_names);
  grow_vec_copy_append(&dsc->const_name_lens, &ssc->const_name_lens);
  grow_vec_copy_append(&dsc->const_init_vals, &ssc->const_init_vals);
  grow_vec_copy_append(&dsc->const_init_refs, &ssc->const_init_refs);
  grow_vec_copy_append(&dsc->const_type_refs, &ssc->const_type_refs);
  grow_vec_copy_append(&dsc->let_names, &ssc->let_names);
  grow_vec_copy_append(&dsc->let_name_lens, &ssc->let_name_lens);
  grow_vec_copy_append(&dsc->let_init_vals, &ssc->let_init_vals);
  grow_vec_copy_append(&dsc->let_init_refs, &ssc->let_init_refs);
  grow_vec_copy_append(&dsc->let_type_refs, &ssc->let_type_refs);
  grow_vec_copy_append(&dsc->src_stmt_kind, &ssc->src_stmt_kind);
  grow_vec_copy_append(&dsc->src_stmt_idx, &ssc->src_stmt_idx);
  grow_vec_copy_append(&dsc->src_body_expr_stmt_refs, &ssc->src_body_expr_stmt_refs);
  grow_vec_copy_append(&dsc->while_cond_refs, &ssc->while_cond_refs);
  grow_vec_copy_append(&dsc->while_body_refs, &ssc->while_body_refs);
  grow_vec_copy_append(&dsc->for_init_refs, &ssc->for_init_refs);
  grow_vec_copy_append(&dsc->for_cond_refs, &ssc->for_cond_refs);
  grow_vec_copy_append(&dsc->for_step_refs, &ssc->for_step_refs);
  grow_vec_copy_append(&dsc->for_body_refs, &ssc->for_body_refs);
  grow_vec_copy_append(&dsc->param_names, &ssc->param_names);
  grow_vec_copy_append(&dsc->param_name_lens, &ssc->param_name_lens);
  grow_vec_copy_append(&dsc->param_type_refs, &ssc->param_type_refs);
  grow_vec_copy_append(&dsc->call_arg_vals, &ssc->call_arg_vals);
}

/** 将第 i 条 const 名拷入 64 字节缓冲（不足补 0）。 */
void pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 64);
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->const_names.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->const_names, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 64)
    n = 64;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** 将第 i 条 let 名拷入 64 字节缓冲（不足补 0）。 */
void pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 64);
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->let_names.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->let_name_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->let_names, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 64)
    n = 64;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** ---------- OneFunc while/for 侧车池 ---------- */

int32_t pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref) {
  OneFuncSidecar *sc;
  int32_t *pc;
  int32_t *pb;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->while_cond_refs) < 0 || grow_vec_push(&sc->while_body_refs) < 0)
    return -1;
  pc = (int32_t *)grow_vec_at(&sc->while_cond_refs, sc->while_cond_refs.len - 1);
  pb = (int32_t *)grow_vec_at(&sc->while_body_refs, sc->while_body_refs.len - 1);
  if (!pc || !pb)
    return -1;
  *pc = cond_ref;
  *pb = body_ref;
  return sc->while_cond_refs.len - 1;
}

int32_t pipeline_onefunc_while_cond_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->while_cond_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->while_cond_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_while_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->while_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->while_body_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_num_whiles(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->while_cond_refs.len : 0;
}

int32_t pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                     int32_t body_ref) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)))
    return -1;
  if (grow_vec_push(&sc->for_init_refs) < 0 || grow_vec_push(&sc->for_cond_refs) < 0 ||
      grow_vec_push(&sc->for_step_refs) < 0 || grow_vec_push(&sc->for_body_refs) < 0)
    return -1;
  p = (int32_t *)grow_vec_at(&sc->for_init_refs, sc->for_init_refs.len - 1);
  if (p)
    *p = init_ref;
  p = (int32_t *)grow_vec_at(&sc->for_cond_refs, sc->for_cond_refs.len - 1);
  if (p)
    *p = cond_ref;
  p = (int32_t *)grow_vec_at(&sc->for_step_refs, sc->for_step_refs.len - 1);
  if (p)
    *p = step_ref;
  p = (int32_t *)grow_vec_at(&sc->for_body_refs, sc->for_body_refs.len - 1);
  if (p)
    *p = body_ref;
  return sc->for_init_refs.len - 1;
}

int32_t pipeline_onefunc_for_init_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_init_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_init_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_for_cond_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_cond_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_cond_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_for_step_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_step_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_step_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_for_body_ref(uint8_t *out, int32_t i) {
  OneFuncSidecar *sc;
  int32_t *p;
  if (!out || !(sc = onefunc_sidecar_get(out, 0)) || i < 0 || i >= sc->for_body_refs.len)
    return 0;
  p = (int32_t *)grow_vec_at(&sc->for_body_refs, i);
  return p ? *p : 0;
}

int32_t pipeline_onefunc_num_fors(uint8_t *out) {
  OneFuncSidecar *sc = onefunc_sidecar_get(out, 0);
  return sc ? sc->for_init_refs.len : 0;
}

void pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  for (i = 0; i < count; i++) {
    int32_t cond_ref = pipeline_onefunc_while_cond_ref(out, i);
    int32_t body_ref = pipeline_onefunc_while_body_ref(out, i);
    if (getenv("SHUX_ASM_DEBUG"))
      fprintf(stderr, "shux: fill_while_from_onefunc i=%d cond=%d body=%d\n", (int)i, (int)cond_ref, (int)body_ref);
    pipeline_block_append_while(a, br, cond_ref, body_ref);
  }
}

void pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
  if (getenv("SHUX_ASM_DEBUG"))
    fprintf(stderr, "shux: fill_fors br=%d count=%d\n", (int)br, (int)count);
  for (i = 0; i < count; i++) {
    pipeline_block_append_for(a, br, pipeline_onefunc_for_init_ref(out, i), pipeline_onefunc_for_cond_ref(out, i),
                              pipeline_onefunc_for_step_ref(out, i), pipeline_onefunc_for_body_ref(out, i));
  }
}

/** ---------- Expr 变长附属（call/method/match/struct_lit/array_lit）动态池 ---------- */

static MatchArmEntry *expr_match_arm_at(struct ast_ASTArena *a, int32_t expr_ref, int32_t arm_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arm_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->match_arm_base + arm_idx;
  if (create) {
    while (sc->expr_match_arms.len <= abs) {
      if (grow_vec_push(&sc->expr_match_arms) < 0)
        return NULL;
    }
  } else if (arm_idx >= ex->match_num_arms || abs >= sc->expr_match_arms.len) {
    return NULL;
  }
  return (MatchArmEntry *)grow_vec_at(&sc->expr_match_arms, abs);
}

static StructLitFieldEntry *expr_struct_lit_field_at(struct ast_ASTArena *a, int32_t expr_ref, int32_t field_idx,
                                                     int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || field_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->struct_lit_field_base + field_idx;
  if (create) {
    while (sc->expr_struct_lit_fields.len <= abs) {
      if (grow_vec_push(&sc->expr_struct_lit_fields) < 0)
        return NULL;
    }
  } else if (field_idx >= ex->struct_lit_num_fields || abs >= sc->expr_struct_lit_fields.len) {
    return NULL;
  }
  return (StructLitFieldEntry *)grow_vec_at(&sc->expr_struct_lit_fields, abs);
}

static int32_t *expr_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arg_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->call_arg_base + arg_idx;
  if (create) {
    while (sc->expr_call_arg_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_call_arg_refs) < 0)
        return NULL;
    }
  } else if (arg_idx >= ex->call_num_args || abs >= sc->expr_call_arg_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_call_arg_refs, abs);
}

static int32_t *expr_method_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || arg_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->method_call_arg_base + arg_idx;
  if (create) {
    while (sc->expr_method_call_arg_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_method_call_arg_refs) < 0)
        return NULL;
    }
  } else if (arg_idx >= ex->method_call_num_args || abs >= sc->expr_method_call_arg_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_method_call_arg_refs, abs);
}

static int32_t *expr_array_lit_elem_slot(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_idx, int create) {
  ArenaSidecar *sc;
  struct ast_Expr *ex;
  int32_t abs;
  if (!a || expr_ref <= 0 || elem_idx < 0)
    return NULL;
  sc = arena_sidecar_get(a, create ? 1 : 0);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return NULL;
  abs = ex->array_lit_elem_base + elem_idx;
  if (create) {
    while (sc->expr_array_lit_elem_refs.len <= abs) {
      if (grow_vec_push(&sc->expr_array_lit_elem_refs) < 0)
        return NULL;
    }
  } else if (elem_idx >= ex->array_lit_num_elems || abs >= sc->expr_array_lit_elem_refs.len) {
    return NULL;
  }
  return (int32_t *)grow_vec_at(&sc->expr_array_lit_elem_refs, abs);
}

/**
 * CALL 节点刚分配后调用：立即固定 call_arg_base，避免嵌套实参解析时内层 CALL 与外层未写入槽位重叠。
 */
void pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  ArenaSidecar *sc;
  if (!a || expr_ref <= 0)
    return;
  sc = arena_sidecar_get(a, 1);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return;
  ex->call_arg_base = (int32_t)sc->expr_call_arg_refs.len;
}

/**
 * 解析每个 CALL 实参表达式前调用：grow 侧车池至 call_arg_base + call_num_args，使后续嵌套 CALL 的 base 落在外层 reserved 区间之后。
 */
int32_t pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  ArenaSidecar *sc;
  int32_t abs;
  if (!a || expr_ref <= 0)
    return -1;
  sc = arena_sidecar_get(a, 1);
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!sc || !ex)
    return -1;
  /* 兼容未调用 on_call_created 的旧路径：首个实参前 lazy 固定 base */
  if (ex->call_num_args == 0)
    pipeline_expr_on_call_created(a, expr_ref);
  abs = ex->call_arg_base + ex->call_num_args;
  while (sc->expr_call_arg_refs.len <= (size_t)abs) {
    if (grow_vec_push(&sc->expr_call_arg_refs) < 0)
      return -1;
  }
  return 0;
}

int32_t pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  struct ast_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (pipeline_expr_prepare_call_arg_slot(a, expr_ref) < 0)
    return -1;
  slot = expr_call_arg_slot(a, expr_ref, ex->call_num_args, 1);
  if (!slot)
    return -1;
  *slot = arg_ref;
  ex->call_num_args++;
  return ex->call_num_args - 1;
}

int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_call_arg_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->call_num_args : 0;
}

int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return 0;
  return ex->call_num_type_args;
}

int32_t pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  struct ast_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->method_call_num_args == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->method_call_arg_base = sc->expr_method_call_arg_refs.len;
  }
  slot = expr_method_call_arg_slot(a, expr_ref, ex->method_call_num_args, 1);
  if (!slot)
    return -1;
  *slot = arg_ref;
  ex->method_call_num_args++;
  return ex->method_call_num_args - 1;
}

int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_method_call_arg_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                       int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                       int32_t variant_index) {
  struct ast_Expr *ex;
  MatchArmEntry *arm;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->match_num_arms == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->match_arm_base = sc->expr_match_arms.len;
  }
  arm = expr_match_arm_at(a, expr_ref, ex->match_num_arms, 1);
  if (!arm)
    return -1;
  arm->result_ref = result_ref;
  arm->is_wildcard = is_wildcard;
  arm->lit_val = lit_val;
  arm->is_enum_variant = is_enum_variant;
  arm->variant_index = variant_index;
  ex->match_num_arms++;
  return ex->match_num_arms - 1;
}

int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->match_num_arms : 0;
}

int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->result_ref : 0;
}

int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->is_wildcard : 0;
}

int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->lit_val : 0;
}

int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->is_enum_variant : 0;
}

int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  return arm ? arm->variant_index : 0;
}

void pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->is_wildcard = v;
}

void pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm)
    arm->lit_val = v;
}

void pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t is_var,
                                              int32_t variant_index) {
  MatchArmEntry *arm = expr_match_arm_at(a, expr_ref, i, 0);
  if (arm) {
    arm->is_enum_variant = is_var;
    arm->variant_index = variant_index;
  }
}

int32_t pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                              int32_t name_len, int32_t init_ref) {
  struct ast_Expr *ex;
  StructLitFieldEntry *fe;
  int32_t n;
  if (!a || expr_ref <= 0 || !name_bytes || name_len <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->struct_lit_num_fields == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->struct_lit_field_base = sc->expr_struct_lit_fields.len;
  }
  fe = expr_struct_lit_field_at(a, expr_ref, ex->struct_lit_num_fields, 1);
  if (!fe)
    return -1;
  n = name_len > 63 ? 63 : name_len;
  memset(fe->name, 0, sizeof(fe->name));
  memcpy(fe->name, name_bytes, (size_t)n);
  fe->name_len = n;
  fe->init_ref = init_ref;
  ex->struct_lit_num_fields++;
  return ex->struct_lit_num_fields - 1;
}

int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  StructLitFieldEntry *fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  return fe ? fe->name_len : 0;
}

void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena *a, int32_t expr_ref, int32_t j,
                                              uint8_t *out64) {
  StructLitFieldEntry *fe;
  if (!out64) {
    return;
  }
  fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  if (!fe) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, fe->name, 64);
}

int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  StructLitFieldEntry *fe = expr_struct_lit_field_at(a, expr_ref, j, 0);
  return fe ? fe->init_ref : 0;
}

int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref) {
  struct ast_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->array_lit_num_elems == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->array_lit_elem_base = sc->expr_array_lit_elem_refs.len;
  }
  slot = expr_array_lit_elem_slot(a, expr_ref, ex->array_lit_num_elems, 1);
  if (!slot)
    return -1;
  *slot = elem_ref;
  ex->array_lit_num_elems++;
  return ex->array_lit_num_elems - 1;
}

int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  int32_t *slot = expr_array_lit_elem_slot(a, expr_ref, idx, 0);
  return slot ? *slot : 0;
}

int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->array_lit_num_elems : 0;
}

/** ---------- PipelineDepCtx dep / lib_root 动态池 ---------- */

void pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx)
    return;
  sc = depctx_sidecar_get(ctx, 0);
  if (!sc)
    return;
  sc->dep_modules.len = 0;
  sc->dep_arenas.len = 0;
  sc->dep_path_rows.len = 0;
  sc->dep_path_lens.len = 0;
  sc->lib_root_rows.len = 0;
  sc->lib_root_lens.len = 0;
  ctx->ndep = 0;
  ctx->num_lib_roots = 0;
}

void pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m) {
  DepCtxSidecar *sc;
  void **pm;
  if (!ctx || idx < 0)
    return;
  if (!(sc = depctx_sidecar_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
    return;
  pm = (void **)grow_vec_at(&sc->dep_modules, idx);
  if (pm)
    *pm = (void *)m;
  if (idx + 1 > ctx->ndep)
    ctx->ndep = idx + 1;
}

void pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a) {
  DepCtxSidecar *sc;
  void **pa;
  if (!ctx || idx < 0)
    return;
  if (!(sc = depctx_sidecar_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
    return;
  pa = (void **)grow_vec_at(&sc->dep_arenas, idx);
  if (pa)
    *pa = (void *)a;
}

struct ast_Module *pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  DepCtxSidecar *sc;
  void **pm;
  if (!ctx || idx < 0)
    return NULL;
  if (!(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_modules.len)
    return NULL;
  pm = (void **)grow_vec_at(&sc->dep_modules, idx);
  return pm ? (struct ast_Module *)*pm : NULL;
}

struct ast_ASTArena *pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  DepCtxSidecar *sc;
  void **pa;
  if (!ctx || idx < 0)
    return NULL;
  if (!(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_arenas.len)
    return NULL;
  pa = (void **)grow_vec_at(&sc->dep_arenas, idx);
  return pa ? (struct ast_ASTArena *)*pa : NULL;
}

void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  if (!ctx || idx < 0 || !bytes || len <= 0)
    return;
  if (!(sc = depctx_sidecar_get(ctx, 1)) || !depctx_ensure_slot(sc, idx))
    return;
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  if (!row || !pl)
    return;
  n = len > 63 ? 63 : len;
  memset(row, 0, 64);
  memcpy(row, bytes, (size_t)n);
  row[n] = 0;
  *pl = n;
}

int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || idx < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_path_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  return pl ? *pl : 0;
}

uint8_t pipeline_dep_ctx_import_path_byte_at(struct ast_PipelineDepCtx *ctx, int32_t idx, int32_t off) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!ctx || idx < 0 || off < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 64);
  if (!ctx || idx < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || idx >= sc->dep_path_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->dep_path_lens, idx);
  row = (uint8_t *)grow_vec_at(&sc->dep_path_rows, idx);
  if (!pl || !row)
    return;
  n = *pl;
  if (n > 64)
    n = 64;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

int32_t pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx)
    return 0;
  sc = depctx_sidecar_get(ctx, 0);
  if (sc && sc->dep_modules.len > ctx->ndep)
    ctx->ndep = sc->dep_modules.len;
  return ctx->ndep;
}

void pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n) {
  if (ctx)
    ctx->ndep = n > 0 ? n : 0;
}

/** codegen.x：读 current_codegen_prefix_len，避免 asm 对大 PipelineDepCtx 字段 FIELD_ACCESS。 */
int32_t pipeline_dep_ctx_codegen_prefix_len(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_prefix_len : 0;
}

/** 读 prefix_mirror[off]；越界或未设置返回 0。 */
uint8_t pipeline_dep_ctx_codegen_prefix_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  if (!ctx || off < 0 || off >= ctx->current_codegen_prefix_len || off >= 64)
    return 0;
  return ctx->current_codegen_prefix_mirror[off];
}

/** 将 prefix_mirror 拷入 dst（最多 cap-1 字节，末尾写 NUL）。 */
void pipeline_dep_ctx_codegen_prefix_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap) {
  int32_t n, k;
  if (!ctx || !dst || cap <= 0)
    return;
  n = ctx->current_codegen_prefix_len;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = ctx->current_codegen_prefix_mirror[k];
  dst[n] = 0;
}

/** 写入 current_codegen_prefix_mirror 与 len（最多 63 字节）。 */
void pipeline_dep_ctx_set_codegen_prefix_mirror(struct ast_PipelineDepCtx *ctx, uint8_t *bytes, int32_t len) {
  int32_t k, n;
  if (!ctx)
    return;
  n = len > 63 ? 63 : (len > 0 ? len : 0);
  ctx->current_codegen_prefix_len = 0;
  for (k = 0; k < n; k++)
    ctx->current_codegen_prefix_mirror[k] = bytes[k];
  ctx->current_codegen_prefix_mirror[n] = 0;
  ctx->current_codegen_prefix_len = n;
}

/** pipeline.x：返回 path_buf 首地址，供 fs_open_read 等 *u8 API。 */
uint8_t *pipeline_dep_ctx_path_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->path_buf : NULL;
}

/** 读 path_buf[off]；越界返回 0。 */
uint8_t pipeline_dep_ctx_path_buf_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  if (!ctx || off < 0 || off >= 512)
    return 0;
  return ctx->path_buf[off];
}

/** 写 path_buf[off]；越界忽略。 */
void pipeline_dep_ctx_set_path_buf_byte(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t b) {
  if (!ctx || off < 0 || off >= 512)
    return;
  ctx->path_buf[off] = b;
}

/** pipeline.x：读 entry_dir_len。 */
int32_t pipeline_dep_ctx_entry_dir_len(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->entry_dir_len : 0;
}

/** 将 entry_dir_buf 拷入 dst（最多 cap-1 字节，末尾写 NUL）。 */
void pipeline_dep_ctx_entry_dir_copy(struct ast_PipelineDepCtx *ctx, uint8_t *dst, int32_t cap) {
  int32_t n, k;
  if (!ctx || !dst || cap <= 0)
    return;
  n = ctx->entry_dir_len;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = ctx->entry_dir_buf[k];
  dst[n] = 0;
}

/**
 * M8-tail：path_append_from_buf_256 的 C 实现；SKIP/EMIT_HEAVY 薄包装 bl 目标。
 * 将 buf[0..len-1] 写入 ctx.path_buf[off..]，off 上限 508。
 */
int32_t pipeline_path_append_from_buf_256_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *buf,
                                             int32_t len) {
  int32_t k;
  if (!ctx || !buf || len <= 0)
    return off;
  k = 0;
  while (k < len && off < 508) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, buf[k]);
    off++;
    k++;
  }
  return off;
}

/** M8-tail：path_append_from_buf_512 的 C 实现（与 256 版相同逻辑，buf 由调用方保证容量）。 */
int32_t pipeline_path_append_from_buf_512_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *buf,
                                             int32_t len) {
  return pipeline_path_append_from_buf_256_c(ctx, off, buf, len);
}

/**
 * M8-tail：path_append_import_path 的 C 实现；'.' (46) 替换为 '/' (47) 后写入 path_buf。
 */
int32_t pipeline_path_append_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *import_path,
                                            int32_t path_len) {
  int32_t k;
  uint8_t b;
  if (!ctx || !import_path || path_len <= 0)
    return off;
  k = 0;
  while (k < path_len && off < 508) {
    b = import_path[k];
    if (b == 46)
      b = 47;
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, b);
    off++;
    k++;
  }
  return off;
}

/** M8-tail：resolve_path_import_has_dot 的 C 实现；import 路径含 '.' 返回 1，否则 0。 */
int32_t pipeline_resolve_path_import_has_dot_c(uint8_t *import_path, int32_t path_len) {
  int32_t k;
  if (!import_path || path_len <= 0)
    return 0;
  k = 0;
  while (k < path_len && k < 64) {
    if (import_path[k] == 46)
      return 1;
    k++;
  }
  return 0;
}

/** CodegenOutBuf.len 读写（pipeline.x 避免 *CodegenOutBuf 字段 FIELD_ACCESS；layout 与 codegen.x 一致）。 */
struct codegen_CodegenOutBuf;

/** 与 codegen.x CodegenOutBuf.data 维度一致；len 紧跟 data 之后。 */
#define PIPELINE_CODEGEN_OUTBUF_CAP 9437184

int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  if (!out)
    return 0;
  return *(int32_t *)((uint8_t *)out + (ptrdiff_t)PIPELINE_CODEGEN_OUTBUF_CAP);
}

void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  if (out)
    *(int32_t *)((uint8_t *)out + (ptrdiff_t)PIPELINE_CODEGEN_OUTBUF_CAP) = n > 0 ? n : 0;
}

/** ---------- PipelineDepCtx 源缓冲堆分配（根因：避免 ctx 内嵌 4MiB×2 撑爆栈/asm emit） ---------- */

#define PIPELINE_SOURCE_BUF_CAP 4194304

/** 源缓冲内嵌于 ast.x PipelineDepCtx（loaded_buf/preprocess_buf 各 4MiB）；无需堆分配。 */
int32_t pipeline_dep_ctx_ensure_source_buffers(struct ast_PipelineDepCtx *ctx) {
  return ctx ? 0 : -1;
}

/** 内嵌缓冲无堆释放；仅清零长度字段。 */
void pipeline_dep_ctx_free_source_buffers(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return;
  ctx->loaded_len = 0;
  ctx->preprocess_len = 0;
}

/** calloc 得到的 ctx：先释放堆缓冲再 free 结构体。 */
void pipeline_dep_ctx_heap_destroy(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return;
  pipeline_dep_ctx_free_source_buffers(ctx);
  free(ctx);
}

/** pipeline.x：返回 loaded_buf 首地址，供 fs_read 等 *u8 API。 */
uint8_t *pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return NULL;
  return ctx->loaded_buf;
}

/** pipeline.x：返回 preprocess_buf 首地址，供 dep parse_into_with_init_buf 使用。 */
uint8_t *pipeline_dep_ctx_preprocess_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return NULL;
  return ctx->preprocess_buf;
}

/** 写 loaded_len（isize）。 */
void pipeline_dep_ctx_set_loaded_len(struct ast_PipelineDepCtx *ctx, ptrdiff_t n) {
  if (ctx)
    ctx->loaded_len = n;
}

/** 读 entry_already_parsed。 */
int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->entry_already_parsed : 0;
}

int32_t pipeline_dep_ctx_asm_entry_module_only(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->asm_entry_module_only : 0;
}

extern int32_t driver_check_only_get(void);

/** shux check 标志在 runtime driver 槽；PipelineDepCtx 无该字段（与 ast.x 布局一致）。 */
int32_t pipeline_dep_ctx_check_only_mode(struct ast_PipelineDepCtx *ctx) {
  (void)ctx;
  return driver_check_only_get();
}

int32_t pipeline_dep_ctx_use_asm_backend(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->use_asm_backend : 0;
}

/** 读 use_macho_o；供 user_asm_seed_bridge 等勿自建截断 PipelineDepCtx 布局的 TU 使用。 */
int32_t pipeline_dep_ctx_use_macho_o(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->use_macho_o : 0;
}

/** 读 use_coff_o；Windows -target *-windows-* 且 -o .obj 时为 1。 */
int32_t pipeline_dep_ctx_use_coff_o(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->use_coff_o : 0;
}

/** 读 target_arch；供不暴露完整 PipelineDepCtx 定义的 TU 使用。 */
int32_t pipeline_dep_ctx_target_arch(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->target_arch : 0;
}

/** 读 entry_dir_buf[off]；越界返回 0。 */
uint8_t pipeline_dep_ctx_entry_dir_byte_at(struct ast_PipelineDepCtx *ctx, int32_t off) {
  if (!ctx || off < 0 || off >= ctx->entry_dir_len || off >= 512)
    return 0;
  return ctx->entry_dir_buf[off];
}

int32_t pipeline_dep_ctx_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_dep_index : -1;
}

struct ast_Module *pipeline_dep_ctx_current_codegen_module(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_module : NULL;
}

struct ast_ASTArena *pipeline_dep_ctx_current_codegen_arena(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_codegen_arena : NULL;
}

int32_t pipeline_dep_ctx_current_func_index(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_func_index : -1;
}

/** typeck EXPR_VAR：读 ctx.current_block_ref（EMIT_HEAVY 勿 X 直接写字段）。 */
int32_t pipeline_dep_ctx_current_block_ref_at(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->current_block_ref : 0;
}

void pipeline_dep_ctx_set_current_codegen_module(struct ast_PipelineDepCtx *ctx, struct ast_Module *m) {
  if (ctx)
    ctx->current_codegen_module = m;
}

void pipeline_dep_ctx_set_current_codegen_arena(struct ast_PipelineDepCtx *ctx, struct ast_ASTArena *a) {
  if (ctx)
    ctx->current_codegen_arena = a;
}

void pipeline_dep_ctx_set_current_codegen_dep_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  if (ctx)
    ctx->current_codegen_dep_index = ix;
}

void pipeline_dep_ctx_set_current_func_index(struct ast_PipelineDepCtx *ctx, int32_t ix) {
  if (ctx)
    ctx->current_func_index = ix;
}

int32_t pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!ctx || !path || len <= 0)
    return -1;
  if (!(sc = depctx_sidecar_get(ctx, 1)))
    return -1;
  idx = grow_vec_push(&sc->lib_root_rows);
  if (idx < 0 || grow_vec_push(&sc->lib_root_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, idx);
  if (!row || !pl)
    return -1;
  n = len > 255 ? 255 : len;
  memset(row, 0, 256);
  memcpy(row, path, (size_t)n);
  *pl = n;
  ctx->num_lib_roots = sc->lib_root_rows.len;
  return idx;
}

int32_t pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc = ctx ? depctx_sidecar_get(ctx, 0) : NULL;
  return sc ? sc->lib_root_rows.len : 0;
}

int32_t pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i) {
  DepCtxSidecar *sc;
  int32_t *pl;
  if (!ctx || i < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->lib_root_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  return pl ? *pl : 0;
}

void pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (!ctx || i < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->lib_root_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** std.fs 原语（pipeline resolve 探测仍用 open；read 走 B-20 shux_read_file_into_path）。 */
extern int32_t std_fs_fs_open_read(uint8_t *path);
extern int32_t std_fs_fs_close(int32_t fd);
extern ptrdiff_t std_fs_fs_read(int32_t fd, uint8_t *buf, size_t count);
/** B-20：POSIX 读文件到缓冲（runtime.c）；pipeline_read_file_x_impl_c 回退。 */
extern int shux_read_file_into_path(const char *path, void *buf, size_t cap);
/** pipeline_glue.c 在 #include ast_pool.c 之后定义；此处前向声明供 resolve C glue 调用。 */
int32_t pipeline_copy_lib_root_to_buf256(struct ast_PipelineDepCtx *ctx, int32_t lib_idx, uint8_t *dst);

/**
 * 在 ctx.path_buf 前缀后于 off 处尝试 `.x` 与 `/mod.x` 并 fs_open_read 探测。
 * 成功返回 0，失败返回 -1。
 */
static int32_t pipeline_resolve_path_probe_dot_x_and_mod_c(struct ast_PipelineDepCtx *ctx, int32_t off) {
  int32_t fd;

  if (!ctx)
    return -1;
  if (off + 4 <= 512) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 46);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 115);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 117);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 0);
    fd = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
    if (fd >= 0) {
      std_fs_fs_close(fd);
      return 0;
    }
    if (off + 8 <= 512) {
      pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 1, 109);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 2, 111);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 3, 100);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 4, 46);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 5, 115);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 6, 117);
      pipeline_dep_ctx_set_path_buf_byte(ctx, off + 7, 0);
      fd = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
      if (fd >= 0) {
        std_fs_fs_close(fd);
        return 0;
      }
    }
  }
  return -1;
}

/** EMIT_HEAVY X resolve 编排：path_buf off sidecar（避免 let off=CALL assign tear patch）。 */
static int32_t g_pipeline_resolve_path_off_sidecar;

/**
 * 读取 resolve path 编排 sidecar off（C glue 写入，X if(probe(ctx, get())) 用）。
 */
int32_t pipeline_resolve_path_last_off_get_c(void) {
  return g_pipeline_resolve_path_off_sidecar;
}

/**
 * lib_root[lib_idx] 写入 ctx.path_buf 并追加 '/'；更新 sidecar；失败返回 -1。
 */
int32_t pipeline_resolve_path_lib_root_prefix_off_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off;

  if (!ctx || lib_idx < 0)
    return -1;
  memset(lr_buf, 0, sizeof(lr_buf));
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off = 0;
  if (lr_len > 0)
    off = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  g_pipeline_resolve_path_off_sidecar = off;
  return off;
}

/**
 * 在 off 处追加 import_path 到 ctx.path_buf；更新 sidecar 并返回新 off，失败 -1。
 */
int32_t pipeline_path_append_import_path_sidecar_c(struct ast_PipelineDepCtx *ctx, int32_t off, uint8_t *import_path,
                                                    int32_t path_len) {
  int32_t new_off;

  if (!ctx || !import_path || off < 0)
    return -1;
  new_off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (new_off < 0)
    return -1;
  g_pipeline_resolve_path_off_sidecar = new_off;
  return new_off;
}

/**
 * entry_dir 写入 ctx.path_buf 前缀并追加 '/'；更新 sidecar；无效返回 -1。
 */
int32_t pipeline_resolve_path_entry_dir_prefix_off_c(struct ast_PipelineDepCtx *ctx) {
  int32_t ed_len;
  uint8_t ed_buf[512];
  int32_t off;

  if (!ctx)
    return -1;
  ed_len = pipeline_dep_ctx_entry_dir_len(ctx);
  if (ed_len <= 0)
    return -1;
  memset(ed_buf, 0, sizeof(ed_buf));
  pipeline_dep_ctx_entry_dir_copy(ctx, ed_buf, 512);
  off = pipeline_path_append_from_buf_512_c(ctx, 0, ed_buf, ed_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  g_pipeline_resolve_path_off_sidecar = off;
  return off;
}

/**
 * 扁平单段 import 路径 lib_root/name/name.x 写入 ctx.path_buf；0 成功 -1 失败。
 */
int32_t pipeline_flat_import_build_path_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx, uint8_t *import_path,
                                          int32_t path_len) {
  int32_t off_base;

  if (!ctx || !import_path || lib_idx < 0)
    return -1;
  if (pipeline_resolve_path_lib_root_prefix_off_c(ctx, lib_idx) < 0)
    return -1;
  off_base = g_pipeline_resolve_path_off_sidecar;
  if (pipeline_path_append_import_path_sidecar_c(ctx, off_base, import_path, path_len) < 0)
    return -1;
  off_base = g_pipeline_resolve_path_off_sidecar;
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    g_pipeline_resolve_path_off_sidecar = off_base + 1;
  }
  if (pipeline_path_append_import_path_sidecar_c(ctx, g_pipeline_resolve_path_off_sidecar, import_path, path_len) < 0)
    return -1;
  off_base = g_pipeline_resolve_path_off_sidecar;
  if (off_base + 4 > 512)
    return -1;
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117);
  pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0);
  return 0;
}

/**
 * 对 ctx.path_buf 当前路径做 fs_open_read 探测；可读返回 0，否则 -1。
 */
int32_t pipeline_flat_import_probe_open_c(struct ast_PipelineDepCtx *ctx) {
  int32_t fd_dir;

  if (!ctx)
    return -1;
  fd_dir = std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx));
  if (fd_dir >= 0) {
    std_fs_fs_close(fd_dir);
    return 0;
  }
  return -1;
}

/** X extern：resolve_path_probe_dot_x_and_mod 薄包装 bl 目标。 */
int32_t pipeline_resolve_path_probe_export_c(struct ast_PipelineDepCtx *ctx, int32_t off) {
  return pipeline_resolve_path_probe_dot_x_and_mod_c(ctx, off);
}

/** 单段 import 在 lib_root 下再试 lib_root/name/name.x。 */
static int32_t pipeline_resolve_path_try_flat_import_under_lib_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx,
                                                                  uint8_t *import_path, int32_t path_len) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off_base;

  if (!ctx || !import_path)
    return -1;
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off_base = 0;
  if (lr_len > 0)
    off_base = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    off_base = off_base + 1;
  }
  off_base = pipeline_path_append_import_path_c(ctx, off_base, import_path, path_len);
  if (off_base < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 47);
    off_base = off_base + 1;
  }
  off_base = pipeline_path_append_import_path_c(ctx, off_base, import_path, path_len);
  if (off_base + 4 <= 512) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base, 46);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 1, 115);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 2, 117);
    pipeline_dep_ctx_set_path_buf_byte(ctx, off_base + 3, 0);
    if (std_fs_fs_open_read(pipeline_dep_ctx_path_buf_ptr(ctx)) >= 0)
      return 0;
  }
  return -1;
}

/** 在单个 lib_root 下拼接 import 并探测 .x / mod.x / 扁平单段路径。 */
static int32_t pipeline_resolve_path_try_one_lib_root_c(struct ast_PipelineDepCtx *ctx, int32_t lib_idx,
                                                         uint8_t *import_path, int32_t path_len) {
  uint8_t lr_buf[256];
  int32_t lr_len;
  int32_t off;

  if (!ctx || !import_path)
    return -1;
  lr_len = pipeline_copy_lib_root_to_buf256(ctx, lib_idx, lr_buf);
  off = 0;
  if (lr_len > 0)
    off = pipeline_path_append_from_buf_256_c(ctx, 0, lr_buf, lr_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  if (pipeline_resolve_path_probe_dot_x_and_mod_c(ctx, off) == 0)
    return 0;
  if (path_len > 0 && path_len < 64 && pipeline_resolve_path_import_has_dot_c(import_path, path_len) == 0) {
    if (pipeline_resolve_path_try_flat_import_under_lib_c(ctx, lib_idx, import_path, path_len) == 0)
      return 0;
  }
  return -1;
}

/** 在 entry_dir 下拼接单段 import 并探测 .x / mod.x。 */
static int32_t pipeline_resolve_path_try_entry_dir_c(struct ast_PipelineDepCtx *ctx, uint8_t *import_path,
                                                    int32_t path_len) {
  int32_t ed_len;
  uint8_t ed_buf[512];
  int32_t off;

  if (!ctx || !import_path)
    return -1;
  ed_len = pipeline_dep_ctx_entry_dir_len(ctx);
  if (ed_len <= 0 || pipeline_resolve_path_import_has_dot_c(import_path, path_len) != 0)
    return -1;
  pipeline_dep_ctx_entry_dir_copy(ctx, ed_buf, 512);
  off = pipeline_path_append_from_buf_512_c(ctx, 0, ed_buf, ed_len);
  if (off < 509) {
    pipeline_dep_ctx_set_path_buf_byte(ctx, off, 47);
    off = off + 1;
  }
  off = pipeline_path_append_import_path_c(ctx, off, import_path, path_len);
  return pipeline_resolve_path_probe_dot_x_and_mod_c(ctx, off);
}

/** X 真 emit 或 weak 默认；_c 经此 dispatch（build_asm pipeline.o 强符号覆盖 weak）。 */
extern int32_t pipeline_resolve_path_x(struct ast_PipelineDepCtx *ctx, uint8_t import_path[64], int32_t path_len);
extern int32_t pipeline_read_file_x(struct ast_PipelineDepCtx *ctx);

/**
 * M8-tail strict 回退：`resolve_path_x` 按 lib_roots 与 entry_dir 解析 import 到 ctx.path_buf。
 */
int32_t pipeline_resolve_path_x_impl_c(struct ast_PipelineDepCtx *ctx, uint8_t import_path[64], int32_t path_len) {
  int32_t r;
  int32_t n_lib;

  if (!ctx || !import_path || path_len <= 0)
    return -1;
  n_lib = pipeline_ctx_lib_root_count(ctx);
  r = 0;
  while (r < n_lib) {
    if (pipeline_resolve_path_try_one_lib_root_c(ctx, r, import_path, path_len) == 0)
      return 0;
    r = r + 1;
  }
  if (pipeline_resolve_path_try_entry_dir_c(ctx, import_path, path_len) == 0)
    return 0;
  return -1;
}

/** M8-tail：优先 dispatch 至 pipeline_resolve_path_x（X 或 weak impl_c）。 */
int32_t pipeline_resolve_path_x_c(struct ast_PipelineDepCtx *ctx, uint8_t import_path[64], int32_t path_len) {
  return pipeline_resolve_path_x(ctx, import_path, path_len);
}

/** read_file_x X emit：单点 fs read + loaded_len（前向声明，供 read_file_x / impl_c 调用）。 */
int32_t pipeline_read_fd_into_loaded_buf(struct ast_PipelineDepCtx *ctx, int32_t fd);

/**
 * M8-tail strict 回退：`read_file_x` 读 ctx.path_buf 文件到 ctx.loaded_buf（B-20 POSIX，非 fopen）。
 */
int32_t pipeline_read_file_x_impl_c(struct ast_PipelineDepCtx *ctx) {
  int32_t n;

  if (!ctx)
    return -1;
  n = shux_read_file_into_path((const char *)pipeline_dep_ctx_path_buf_ptr(ctx),
                               pipeline_dep_ctx_loaded_buf_ptr(ctx),
                               (size_t)PIPELINE_SOURCE_BUF_CAP);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, (ptrdiff_t)n);
  return 0;
}

/** M8-tail：优先 dispatch 至 pipeline_read_file_x（X 或 weak impl_c）。 */
int32_t pipeline_read_file_x_c(struct ast_PipelineDepCtx *ctx) {
  return pipeline_read_file_x(ctx);
}

/**
 * read_file_x X emit：单点 fs read + loaded_len 写入（避免 X 侧 fs_posix_read_c 嵌套 ptr 实参 SIGSEGV）。
 */
int32_t pipeline_read_fd_into_loaded_buf(struct ast_PipelineDepCtx *ctx, int32_t fd) {
  ptrdiff_t n;

  if (!ctx || fd < 0)
    return -1;
  n = std_fs_fs_read(fd, pipeline_dep_ctx_loaded_buf_ptr(ctx), (size_t)PIPELINE_SOURCE_BUF_CAP);
  if (n < 0)
    return -1;
  pipeline_dep_ctx_set_loaded_len(ctx, n);
  return 0;
}

extern int32_t preprocess_x_buf(uint8_t *source_buf, ptrdiff_t source_len, uint8_t *out_buf,
                                              int32_t out_cap);
extern uint8_t *driver_dep_arena_buf(int32_t i);
extern uint8_t *driver_dep_module_buf(int32_t i);
extern int32_t driver_dep_seeded_get(int32_t i);
extern int32_t driver_dep_slot_for_path(uint8_t *path);
extern int32_t parser_copy_module_import_path64(struct ast_Module *module, int32_t i, uint8_t out[64]);

/** pipeline_load_import_from_disk X emit：读 ctx.preprocess_len（避免 FIELD_ACCESS emit 失败）。 */
int32_t pipeline_dep_ctx_preprocess_len_get(struct ast_PipelineDepCtx *ctx) {
  return ctx ? ctx->preprocess_len : -1;
}

/**
 * loaded_buf → preprocess_buf；成功返回 0，preprocess 失败返回 -9。
 */
int32_t pipeline_preprocess_loaded_into_ctx(struct ast_PipelineDepCtx *ctx) {
  int32_t out_len;

  if (!ctx)
    return -1;
  out_len = preprocess_x_buf(pipeline_dep_ctx_loaded_buf_ptr(ctx), ctx->loaded_len,
                                         pipeline_dep_ctx_preprocess_buf_ptr(ctx), PIPELINE_SOURCE_BUF_CAP);
  if (out_len < 0)
    return -9;
  ctx->preprocess_len = out_len;
  return 0;
}

/** import 槽绑定 driver dep arena/module 缓冲（指针 cast 须 C glue）。 */
void pipeline_bind_import_dep_buffers(struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  if (!ctx || import_idx < 0)
    return;
  pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
  pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
}

/**
 * 若 global_slot 或 import_idx 已由 driver seed，绑定 arena/module 槽并返回 1；未 seed 返回 0。
 * C glue：X 侧 (struct ast_ASTArena *)driver_dep_arena_buf 指针 cast 在 M8 asm 真 emit 时易 SIGSEGV。
 */
int32_t pipeline_try_bind_seeded_import(struct ast_PipelineDepCtx *ctx, int32_t import_idx, int32_t global_slot) {
  if (!ctx || import_idx < 0)
    return 0;
  if (global_slot >= 0 && driver_dep_seeded_get(global_slot) != 0) {
    pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(global_slot));
    pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(global_slot));
    return 1;
  }
  if (driver_dep_seeded_get(import_idx) != 0) {
    pipeline_dep_ctx_set_arena(ctx, import_idx, (struct ast_ASTArena *)driver_dep_arena_buf(import_idx));
    pipeline_dep_ctx_set_module(ctx, import_idx, (struct ast_Module *)driver_dep_module_buf(import_idx));
    return 1;
  }
  return 0;
}

/**
 * 将 dep_i 槽与 driver 全局 seed 槽对齐；C glue 单点指针 cast。
 */
int32_t pipeline_sync_one_dep_slot(struct ast_Module *module, struct ast_PipelineDepCtx *ctx, int32_t dep_i) {
  uint8_t sync_path[64];
  int32_t sync_slot;

  if (!module || !ctx || dep_i < 0)
    return -1;
  (void)parser_copy_module_import_path64(module, dep_i, sync_path);
  sync_slot = driver_dep_slot_for_path(sync_path);
  if (sync_slot < 0)
    sync_slot = dep_i;
  {
    int32_t pl = 0;
    while (pl < 64 && sync_path[pl] != 0)
      pl = pl + 1;
    if (pl > 0)
      pipeline_dep_ctx_set_import_path(ctx, dep_i, sync_path, pl);
  }
  pipeline_dep_ctx_set_module(ctx, dep_i, (struct ast_Module *)driver_dep_module_buf(sync_slot));
  pipeline_dep_ctx_set_arena(ctx, dep_i, (struct ast_ASTArena *)driver_dep_arena_buf(sync_slot));
  return 0;
}

extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_source_len(int32_t len);
extern void driver_diagnostic_parse_fail(int32_t main_idx, int32_t num_funcs, int32_t arena_num_types);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern void driver_diagnostic_typeck_fail(void);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern void parser_parse_into_set_main_index(struct ast_Module *module, int32_t main_idx);
extern struct parser_ParseIntoResult pipeline_parse_into_with_init_buf(struct ast_ASTArena *arena,
                                                                         struct ast_Module *module, uint8_t *data,
                                                                         int32_t len);
extern int32_t pipeline_should_skip_x_typeck(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_driver_asm_build_skip_typeck(void);
extern int32_t pipeline_driver_x_pipeline_skip_typeck(void);
extern int32_t driver_x_pipeline_skip_typeck_get(void);
extern struct parser_ParseIntoResult pipeline_parse_into_with_init_buf_impl_c(struct ast_ASTArena *arena,
                                                                               struct ast_Module *module,
                                                                               uint8_t *data, int32_t len);
extern int32_t typeck_typeck_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                    struct ast_PipelineDepCtx *ctx);
extern int32_t typeck_typeck_x_ast_library(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
/** WPO-S3：post-typeck struct 栈指针逃逸扫描（pipeline_glue.c）。 */
extern int32_t pipeline_typeck_scan_module_struct_stack_escape_c(struct ast_Module *module,
                                                                 struct ast_ASTArena *arena,
                                                                 struct ast_PipelineDepCtx *ctx);
extern void pipeline_typeck_set_active_ctx_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);

/** EMIT_HEAVY X 读 parse scalars 出参（sidecar；避免 X &local 导致 asm parse 0 func）。 */
static int32_t g_pipeline_parse_scalars_ok;
static int32_t g_pipeline_parse_scalars_main_idx;

int32_t pipeline_parse_scalars_ok_get(void) {
  return g_pipeline_parse_scalars_ok;
}

int32_t pipeline_parse_scalars_main_idx_get(void) {
  return g_pipeline_parse_scalars_main_idx;
}

/**
 * 单模块 asm -o 是否跳过 .x typeck：须 C glue（X emit 读 skip 标志/ctx 字段易错序）。
/**
 * 与 pipeline.x pipeline_should_skip_x_typeck 语义一致。
 * runtime 在 C 预检后设 driver_x_pipeline_skip_typeck 时须对用户 -o 程序生效（B-strict shux_asm hello 等）。
 */
int32_t pipeline_should_skip_x_typeck_c(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return 0;
  if (pipeline_driver_x_pipeline_skip_typeck() != 0)
    return 1;
  if (pipeline_dep_ctx_asm_entry_module_only(ctx) == 0)
    return 0;
  if (pipeline_driver_asm_build_skip_typeck() != 0)
    return 1;
  return 0;
}

/**
 * parse 失败时 stderr 诊断（EMIT_HEAVY 勿 X 真 emit driver_diagnostic_parse_fail 多实参）。
 */
void pipeline_parse_fail_diag_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena) {
  if (!module || !arena)
    return;
  driver_diagnostic_parse_fail(g_pipeline_parse_scalars_main_idx, pipeline_module_num_funcs(module),
                               pipeline_arena_num_types(arena));
}

/**
 * 从 parse scalars sidecar 构造 ParseIntoResult（EMIT_HEAVY 勿 X 按值拼装后 return）。
 */
struct parser_ParseIntoResult pipeline_parse_into_with_init_result_c(void) {
  struct parser_ParseIntoResult r;

  r.ok = g_pipeline_parse_scalars_ok;
  r.main_idx = g_pipeline_parse_scalars_main_idx;
  return r;
}

/**
 * parse_into_with_init_buf 的 ok/main_idx 出参版；避免 X 局部 ParseIntoResult 按值（EMIT_HEAVY SIGSEGV）。
 * out_ok/out_main_idx 非 NULL 时写入；并始终更新 sidecar 供 pipeline_parse_scalars_*_get。
 */
int32_t pipeline_parse_into_with_init_buf_scalars(struct ast_ASTArena *arena, struct ast_Module *module,
                                                   uint8_t *data, int32_t len, int32_t *out_ok,
                                                   int32_t *out_main_idx) {
  struct parser_ParseIntoResult r;

  if (!arena || !module || !data || len <= 0) {
    g_pipeline_parse_scalars_ok = 1;
    g_pipeline_parse_scalars_main_idx = -1;
    if (out_ok)
      *out_ok = g_pipeline_parse_scalars_ok;
    if (out_main_idx)
      *out_main_idx = g_pipeline_parse_scalars_main_idx;
    return 0;
  }
  r = pipeline_parse_into_with_init_buf_impl_c(arena, module, data, len);
  g_pipeline_parse_scalars_ok = r.ok;
  g_pipeline_parse_scalars_main_idx = r.main_idx;
  if (out_ok)
    *out_ok = r.ok;
  if (out_main_idx)
    *out_main_idx = r.main_idx;
  return 0;
}

/** X 薄包装：sidecar 版 scalars（无 *i32 出参，避免 asm 前端 parse 0 func）。 */
int32_t pipeline_parse_into_with_init_buf_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                          uint8_t *data, int32_t len) {
  return pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, NULL, NULL);
}

/**
 * u8[] slice 路径 sidecar：读 data/length 后复用 buf scalars（勿 X ParseIntoResult 按值 EMIT_HEAVY SIGSEGV）。
 * X 传 u8[] 时 ABI 为 shux_slice_uint8_t*。
 */
int32_t pipeline_parse_into_with_init_slice_scalars_sidecar(struct ast_ASTArena *arena, struct ast_Module *module,
                                                             struct shux_slice_uint8_t *source) {
  if (!source || !source->data || source->length == 0)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, NULL, 0, NULL, NULL);
  if (source->length > (size_t)2147483647)
    return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, 2147483647, NULL, NULL);
  return pipeline_parse_into_with_init_buf_scalars(arena, module, source->data, (int32_t)source->length, NULL, NULL);
}

/**
 * 读 sidecar ok/main_idx 写 module.main；parse 失败时 C glue 诊断并返回 -2。
 */
int32_t pipeline_parse_apply_main_from_scalars_c(struct ast_Module *module, struct ast_ASTArena *arena) {
  int32_t ok;
  int32_t main_idx;

  if (!module || !arena)
    return -2;
  ok = pipeline_parse_scalars_ok_get();
  main_idx = pipeline_parse_scalars_main_idx_get();
  if (ok != 0) {
    pipeline_parse_fail_diag_scalars_c(module, arena);
    return -2;
  }
  pipeline_module_set_main_func_index(module, main_idx);
  return 0;
}

/**
 * buf 路径 parse + set_main；C glue 回退（strict 无 pipeline.o 时；有 X 强符号则覆盖）。
 * EMIT_HEAVY 第二遍 pipeline.x 内 pipeline_parse_set_main_from_buf X 真 emit。
 */
int32_t pipeline_parse_set_main_from_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *data,
                                           int32_t len) {
  int32_t ok;
  int32_t main_idx;

  if (!module || !arena || !data || len <= 0)
    return -2;
  pipeline_parse_into_with_init_buf_scalars(arena, module, data, len, &ok, &main_idx);
  if (getenv("SHUX_DEBUG_PIPE"))
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] parse_set_main_from_buf_c ok=%d main_idx=%d num_funcs=%d\n", (int)ok,
            (int)main_idx, (int)pipeline_module_num_funcs(module));
  if (ok != 0) {
    driver_diagnostic_parse_fail(main_idx, pipeline_module_num_funcs(module), pipeline_arena_num_types(arena));
    return -2;
  }
  pipeline_module_set_main_func_index(module, main_idx);
  if (getenv("SHUX_DEBUG_PIPE"))
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] parse_set_main_from_buf_c stored_main_idx=%d\n",
            (int)pipeline_module_main_func_index(module));
  return 0;
}

/**
 * 已对 module 设好 main_idx：按 library / 可执行分派 typeck_x_ast*（与 pipeline.x 语义一致）。
 * fail_mapped 非 0 时 typeck 失败返回该码（LSP 用 -3）。
 */
int32_t pipeline_typeck_parsed_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct ast_PipelineDepCtx *ctx, int32_t fail_mapped) {
  if (!module || !arena || !ctx) {
    if (fail_mapped != 0)
      return fail_mapped;
    return -1;
  }
  /** parse 未产出任何函数时 main_func_index 可能仍为 0（memset）；强制走 library typeck 避免 typeck_x_ast -11。 */
  if (pipeline_module_num_funcs(module) == 0)
    pipeline_module_set_main_func_index(module, -1);
  if (getenv("SHUX_DEBUG_PIPE"))
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] typeck_parsed_module_c main_idx=%d num_funcs=%d\n",
            (int)pipeline_module_main_func_index(module), (int)pipeline_module_num_funcs(module));
  if (pipeline_module_main_func_index(module) < 0) {
    int32_t tc_lib = typeck_typeck_x_ast_library(module, arena, ctx);
    if (tc_lib != 0) {
      if (getenv("SHUX_DEBUG_PIPE"))
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] typeck library rc=%d ctx=%p ndep=%d\n", (int)tc_lib, (void *)ctx,
                (int)pipeline_dep_ctx_ndep(ctx));
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return tc_lib;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return -1;
    }
    return 0;
  }
  {
    int32_t tc = typeck_typeck_x_ast(module, arena, ctx);
    if (tc != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return tc;
    }
    if (pipeline_typeck_scan_module_struct_stack_escape_c(module, arena, ctx) != 0) {
      driver_diagnostic_typeck_fail();
      if (fail_mapped != 0)
        return fail_mapped;
      return -1;
    }
  }
  return 0;
}

/** 主流水线 entry typeck：library→parsed_module；可执行→typeck_x_ast（EMIT_HEAVY X emit）。 */
int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0);
}

extern int32_t pipeline_load_import_from_disk_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_load_import_from_disk_impl_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                      struct ast_PipelineDepCtx *ctx, int32_t import_idx);
extern int32_t pipeline_sync_dep_slots_from_driver_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_sync_dep_slots_from_driver_impl_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_merge_dep_struct_layouts_into_entry(struct ast_Module *mod, struct ast_ASTArena *arena,
                                                              struct ast_PipelineDepCtx *ctx);
extern void typeck_typeck_wpo_unify_soa_layouts(struct ast_Module *entry, struct ast_PipelineDepCtx *ctx);

/**
 * runtime 以传递闭包顺序 seed ctx.ndep/import_path 后，若与 entry 直接 import 数不一致则清零 ndep，
 * 触发 load_and_sync 按 entry import 下标重绑 seed 槽（避免 path=platform.coff 配 module=ast）。
 */
void pipeline_dep_ctx_realign_ndep_for_entry_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  int32_t n_imp;

  if (!module || !ctx)
    return;
  n_imp = parser_get_module_num_imports(module);
  if (pipeline_dep_ctx_ndep(ctx) != n_imp) {
    if (getenv("SHUX_DEBUG_PIPE"))
      fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] realign ndep %d -> entry imports %d\n",
              (int)pipeline_dep_ctx_ndep(ctx), (int)n_imp);
    pipeline_dep_ctx_set_ndep(ctx, 0);
  }
}

/**
 * 单 import resolve + read；C glue（X 侧 u8[64] 栈 + assign CALL EMIT_HEAVY 失败）。
 */
int32_t pipeline_load_import_resolve_read_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                            int32_t import_idx) {
  uint8_t path_buf[64];
  int32_t path_len;

  if (!module || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  path_len = parser_copy_module_import_path64(module, import_idx, path_buf);
  if (pipeline_resolve_path_x(ctx, path_buf, path_len) != 0)
    return -7;
  if (pipeline_read_file_x(ctx) != 0)
    return -8;
  return 0;
}

/**
 * 装载单个 import 槽：已 seed 则 bind，否则 load_import_from_disk；C glue。
 */
int32_t pipeline_load_one_import_slot_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                        struct ast_PipelineDepCtx *ctx, int32_t import_idx) {
  uint8_t path_buf[64];
  int32_t gs;

  if (!module || !arena || !ctx || import_idx < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, import_idx, path_buf);
  gs = driver_dep_slot_for_path(path_buf);
  if (pipeline_try_bind_seeded_import(ctx, import_idx, gs) != 0)
    return 0;
  return pipeline_load_import_from_disk_impl_c(module, arena, ctx, import_idx);
}

/**
 * run_x_pipeline_impl EMIT_HEAVY：同模块 pipeline_load_and_sync X CALL 在 let/assign asm emit 失败；
 * C 复刻 pipeline.x::pipeline_load_and_sync_direct_import_deps 逻辑。
 */
int32_t pipeline_load_and_sync_direct_import_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx) {
  int32_t n_imports;
  int32_t i;
  int32_t rc;
  int32_t sync_rc;
  uint8_t path_buf[64];

  if (!module || !arena || !ctx)
    return -1;
  n_imports = parser_get_module_num_imports(module);
  /*
   * driver 传递闭包 seed：按 entry import 路径 bind 全局槽后直接返回。
   * 须在 realign 之前：realign 会把 ndep(9) 清零，导致 typeck 找不到 encoding.utf8_*（ec=-5）。
   */
  if (n_imports > 0) {
    int32_t bound_any = 0;
    for (i = 0; i < n_imports; i++) {
      memset(path_buf, 0, sizeof(path_buf));
      (void)parser_copy_module_import_path64(module, i, path_buf);
      if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path(path_buf)) != 0)
        bound_any = 1;
    }
    if (bound_any) {
      pipeline_dep_ctx_set_ndep(ctx, n_imports);
      return 0;
    }
  }
  pipeline_dep_ctx_realign_ndep_for_entry_c(module, ctx);
  if (pipeline_dep_ctx_ndep(ctx) == 0) {
    if (n_imports > 0) {
      for (i = 0; i < n_imports; i++) {
        memset(path_buf, 0, sizeof(path_buf));
        (void)parser_copy_module_import_path64(module, i, path_buf);
        if (pipeline_try_bind_seeded_import(ctx, i, driver_dep_slot_for_path(path_buf)) != 0)
          continue;
        rc = pipeline_load_import_from_disk_c(module, arena, ctx, i);
        if (rc != 0)
          return rc;
      }
      pipeline_dep_ctx_set_ndep(ctx, n_imports);
    }
  }
  sync_rc = pipeline_sync_dep_slots_from_driver_c(module, ctx);
  if (sync_rc != 0)
    return sync_rc;
  /*
   * driver 已 seed 的 std/core dep：merge 在 parse-only 槽上 SIGSEGV；layout 由预编 .o / import fixup 承担。
   */
  {
    int32_t all_seeded = (n_imports > 0) ? 1 : 0;
    for (i = 0; i < n_imports; i++) {
      int32_t gs;
      memset(path_buf, 0, sizeof(path_buf));
      (void)parser_copy_module_import_path64(module, i, path_buf);
      gs = driver_dep_slot_for_path(path_buf);
      if ((gs < 0 || driver_dep_seeded_get(gs) == 0) && driver_dep_seeded_get(i) == 0) {
        all_seeded = 0;
        break;
      }
    }
    if (!all_seeded) {
      typeck_typeck_merge_dep_struct_layouts_into_entry(module, arena, ctx);
      typeck_typeck_wpo_unify_soa_layouts(module, ctx);
    }
  }
  return 0;
}

/**
 * run_x_pipeline_impl EMIT_HEAVY：typecheck entry 同模块 CALL asm emit 失败时走 C glue。
 */
int32_t run_x_pipeline_typecheck_entry_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                          struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

/**
 * run_x_pipeline_impl EMIT_HEAVY：if(CALL) 路径可 emit，let init CALL 会 tear patch；
 * 最近一次 phase C glue 返回值供 `return run_x_pipeline_last_rc_get()` 使用（避免重复 call）。
 */
static int32_t g_run_x_pipeline_last_rc;

/**
 * typeck 失败统一返回；C glue（X 内 fail_mapped 分支重复 emit 失败）。
 */
int32_t pipeline_typeck_fail_return_c(int32_t fail_mapped) {
  driver_diagnostic_typeck_fail();
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

/**
 * typeck 入口 null 检查失败返回；C glue（与 pipeline_typeck_parsed_module 语义一致）。
 */
int32_t pipeline_typeck_null_fail_return_c(int32_t fail_mapped) {
  if (fail_mapped != 0)
    return fail_mapped;
  return -1;
}

int32_t run_x_pipeline_last_rc_get(void) {
  return g_run_x_pipeline_last_rc;
}

/**
 * EMIT_HEAVY X 编排：写入 last_rc sidecar（避免 let rc=CALL assign tear patch）。
 */
void run_x_pipeline_last_rc_store_c(int32_t rc) {
  g_run_x_pipeline_last_rc = rc;
}

int32_t run_x_pipeline_load_deps_after_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                struct ast_PipelineDepCtx *ctx) {
  g_run_x_pipeline_last_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  return g_run_x_pipeline_last_rc;
}

int32_t run_x_pipeline_typecheck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                               struct ast_PipelineDepCtx *ctx) {
  g_run_x_pipeline_last_rc = run_x_pipeline_typecheck_entry_c(module, arena, ctx);
  return g_run_x_pipeline_last_rc;
}

/** LSP：load/sync + typeck（typeck 失败 -3）；C glue。 */
int32_t lsp_diag_typeck_after_load_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                     struct ast_PipelineDepCtx *ctx) {
  int32_t load_rc;

  if (!module || !arena || !ctx)
    return -1;
  load_rc = pipeline_load_and_sync_direct_import_deps_c(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, -3);
}

/** LSP entry parse：与 pipeline_parse_set_main_from_buf 同路径 C glue。 */
int32_t lsp_diag_parse_entry_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                   int32_t source_len) {
  return pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
}

/** C glue 经 pipeline_typeck_parsed_module_c 复用 typeck 分派。 */
extern int32_t pipeline_load_and_sync_direct_import_deps(struct ast_Module *module, struct ast_ASTArena *arena,
                                                         struct ast_PipelineDepCtx *ctx);

/**
 * LSP 全路径 C glue：set_main_c + load/sync + pipeline_typeck_parsed_module_c（typeck 失败 -3）。
 * typeck 深栈：在 256MiB pthread 上执行，避免 Alpine/ARM64 默认栈在 diag 时 SIGSEGV。
 */
extern void driver_run_on_large_stack_pthread(void *(*fn)(void *), void *arg);
extern int driver_is_large_stack_thread(void);

typedef struct LspDiagParseTypeckArgs {
  struct ast_Module *module;
  struct ast_ASTArena *arena;
  uint8_t *source_data;
  int32_t source_len;
  struct ast_PipelineDepCtx *ctx;
  int32_t result;
} LspDiagParseTypeckArgs;

static int32_t lsp_diag_parse_typeck_buf_impl(struct ast_Module *module, struct ast_ASTArena *arena,
                                            uint8_t *source_data, int32_t source_len,
                                            struct ast_PipelineDepCtx *ctx) {
  int32_t parse_rc;
  int32_t load_rc;

  if (!module || !arena || !ctx || !source_data || source_len <= 0)
    return -2;
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, source_len);
  if (parse_rc != 0)
    return parse_rc;
  load_rc = pipeline_load_and_sync_direct_import_deps(module, arena, ctx);
  if (load_rc != 0)
    return load_rc;
  return pipeline_typeck_parsed_module_c(module, arena, ctx, 0 - 3);
}

static void *lsp_diag_parse_typeck_thread_fn(void *arg) {
  LspDiagParseTypeckArgs *a = (LspDiagParseTypeckArgs *)arg;
  a->result = lsp_diag_parse_typeck_buf_impl(a->module, a->arena, a->source_data, a->source_len, a->ctx);
  return NULL;
}

int32_t lsp_diag_parse_typeck_buf_c(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data,
                                    int32_t source_len, struct ast_PipelineDepCtx *ctx) {
  /* LSP 主循环已在 256MiB pthread 内：直接 typeck，避免嵌套大栈分配在 Alpine 上 OOM/SIGSEGV。 */
  if (driver_is_large_stack_thread())
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  LspDiagParseTypeckArgs args;
  args.module = module;
  args.arena = arena;
  args.source_data = source_data;
  args.source_len = source_len;
  args.ctx = ctx;
  args.result = -99;
  driver_run_on_large_stack_pthread(lsp_diag_parse_typeck_thread_fn, &args);
  if (args.result == -99)
    return lsp_diag_parse_typeck_buf_impl(module, arena, source_data, source_len, ctx);
  return args.result;
}

/**
 * entry 尚未解析：parse_into_with_init_buf + set_main + 收尾诊断；C glue（scalars 路径）。
 */
int32_t run_x_pipeline_parse_entry_do_parse_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                              uint8_t *source_data, size_t source_len,
                                              struct ast_PipelineDepCtx *ctx) {
  int32_t len_i32 = (int32_t)source_len;
  int32_t parse_rc;

  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_source_len(len_i32);
  parse_rc = pipeline_parse_set_main_from_buf_c(module, arena, source_data, len_i32);
  if (parse_rc != 0)
    return parse_rc;
  driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
  extern void driver_diagnostic_after_entry_parse_module(struct ast_Module *module);
  driver_diagnostic_after_entry_parse_module(module);
  driver_diagnostic_entry_module(module, arena);
  return 0;
}

/**
 * entry typeck emit；C glue（skip 判定 + typeck 深栈 + module 字段读）。
 */
extern int32_t pipeline_typeck_dep_prerun_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                 struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_typeck_entry_module_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                            struct ast_PipelineDepCtx *ctx);
extern int32_t parser_get_module_num_imports(struct ast_Module *module);
int32_t run_x_pipeline_typecheck_entry_emit_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                               struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  if (getenv("SHUX_DEBUG_PIPE")) {
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] typecheck_entry_emit ctx=%p ndep=%d num_funcs=%d\n", (void *)ctx,
            (int)pipeline_dep_ctx_ndep(ctx), (int)pipeline_module_num_funcs(module));
    fflush(stderr);
  }
  /** 优先读 runtime 全局标志（C 预检后 set）；勿仅依赖 X pipeline_should_skip_x_typeck（strict 链 thin bl 偶发失效）。 */
    if (driver_x_pipeline_skip_typeck_get() != 0) {
    /*
     * 用户 asm -o 单文件：runtime 仍设 skip_typeck，但须全量 typeck 填 field_access_offset；
     * build_shux_asm（SHUX_ASM_BUILD_SKIP_TYPECK）多文件 import 入口仅 dep_prerun；
     * 用户 -o 有 import 时仍须全量 typeck（ERR-01 负例 result_try_bad 等）。
     */
    if (parser_get_module_num_imports(module) == 0 && driver_x_pipeline_skip_codegen_get() != 0)
      return pipeline_typeck_entry_module_c(module, arena, ctx);
    if (pipeline_driver_asm_build_skip_typeck() != 0)
      return pipeline_typeck_dep_prerun_module_c(module, arena, ctx);
    return pipeline_typeck_entry_module_c(module, arena, ctx);
  }
  if (pipeline_should_skip_x_typeck(ctx) != 0)
    return 0;
  return pipeline_typeck_entry_module_c(module, arena, ctx);
}

extern void driver_diagnostic_codegen_fail(int32_t dep_index, int32_t is_dep);
extern int32_t asm_asm_codegen_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                   struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);
extern int32_t codegen_codegen_x_ast(struct ast_Module *module, struct ast_ASTArena *arena,
                                      struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                      int32_t dep_index);
int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t *path);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);

static int pipeline_debug_name_eq_buf_lit(const uint8_t *buf, int32_t len, const char *lit) {
  size_t lit_len;
  if (!buf || !lit || len <= 0)
    return 0;
  lit_len = strlen(lit);
  return (int32_t)lit_len == len && memcmp(buf, lit, lit_len) == 0;
}

static void pipeline_debug_dump_std_heap_trace_call(struct ast_Module *dep_mod, struct ast_ASTArena *arena,
                                                    struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                                    uint8_t *dep_path_buf) {
  int32_t n_imp, j, expr_ref;
  if (!dep_mod || !arena || !ctx || !dep_path_buf)
    return;
  if (!getenv("SHUX_DEBUG_PIPE"))
    return;
  if (strcmp((const char *)dep_path_buf, "std.heap") != 0)
    return;
  n_imp = parser_get_module_num_imports(dep_mod);
  fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] std.heap probe dep_j=%d imports=%d ctx_ndep=%d arena_exprs=%d\n",
          (int)dep_j, (int)n_imp, (int)pipeline_dep_ctx_ndep(ctx), (int)arena->num_exprs);
  for (j = 0; j < pipeline_dep_ctx_ndep(ctx); j++) {
    uint8_t ctx_path_buf[64];
    int32_t ctx_path_len = pipeline_dep_ctx_import_path_len(ctx, j);
    struct ast_Module *ctx_mod = pipeline_dep_ctx_module_at(ctx, j);
    memset(ctx_path_buf, 0, sizeof(ctx_path_buf));
    if (ctx_path_len > 0)
      pipeline_dep_ctx_import_path_copy64(ctx, j, ctx_path_buf);
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] std.heap ctx dep[%d] path=%.*s funcs=%d mod=%p\n", (int)j,
            (int)ctx_path_len, (char *)ctx_path_buf, ctx_mod ? (int)pipeline_module_num_funcs(ctx_mod) : -1,
            (void *)ctx_mod);
  }
  for (j = 0; j < n_imp; j++) {
    uint8_t path_buf[64];
    uint8_t bind_buf[64];
    int32_t path_len = pipeline_module_import_path_len(dep_mod, j);
    int32_t bind_len = pipeline_module_import_binding_name_len(dep_mod, j);
    int32_t k;
    memset(path_buf, 0, sizeof(path_buf));
    memset(bind_buf, 0, sizeof(bind_buf));
    pipeline_module_import_path_copy(dep_mod, j, path_buf, (int32_t)sizeof(path_buf));
    for (k = 0; k < bind_len && k < (int32_t)sizeof(bind_buf) - 1; k++)
      bind_buf[k] = pipeline_module_import_binding_name_byte_at(dep_mod, j, k);
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] std.heap import idx=%d kind=%d path=%.*s bind=%.*s\n", (int)j,
            (int)pipeline_module_import_kind_at(dep_mod, j), (int)path_len, (char *)path_buf, (int)bind_len,
            (char *)bind_buf);
  }
  for (j = 0; j < pipeline_module_num_funcs(dep_mod); j++) {
    uint8_t fn_buf[64];
    int32_t fn_len = pipeline_module_func_name_len_at(dep_mod, j);
    int32_t body_ref;
    int32_t nso;
    int32_t si;
    memset(fn_buf, 0, sizeof(fn_buf));
    if (fn_len <= 0 || fn_len > 63)
      continue;
    pipeline_module_func_name_copy64(dep_mod, j, fn_buf);
    if (!pipeline_debug_name_eq_buf_lit(fn_buf, fn_len, "trace_on"))
      continue;
    body_ref = pipeline_module_func_body_ref_at(dep_mod, j);
    nso = body_ref > 0 ? ast_ast_block_num_stmt_order(arena, body_ref) : -1;
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] std.heap func fi=%d name=%.*s body_ref=%d nso=%d fin=%d\n", (int)j,
            (int)fn_len, (char *)fn_buf, (int)body_ref, (int)nso,
            body_ref > 0 ? (int)ast_ast_block_final_expr_ref(arena, body_ref) : -1);
    for (si = 0; body_ref > 0 && si < nso; si++) {
      int32_t so_idx = pipeline_block_stmt_order_idx(arena, body_ref, si);
      int32_t expr_stmt_ref = pipeline_block_expr_stmt_ref(arena, body_ref, so_idx);
      struct ast_Expr *expr_stmt = expr_stmt_ref > 0 ? pipeline_arena_expr_ptr(arena, expr_stmt_ref) : NULL;
      fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] std.heap func stmt si=%d kind=%u idx=%d\n", (int)si,
              (unsigned)pipeline_block_stmt_order_kind(arena, body_ref, si),
              (int)so_idx);
      fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] std.heap func expr_stmt si=%d expr_ref=%d expr_kind=%d\n", (int)si,
              (int)expr_stmt_ref, expr_stmt ? (int)expr_stmt->kind : -1);
      if (expr_stmt && expr_stmt->unary_operand_ref > 0) {
        struct ast_Expr *ret_op = pipeline_arena_expr_ptr(arena, expr_stmt->unary_operand_ref);
        fprintf(stderr,
                "shux: [SHUX_DEBUG_PIPE] std.heap func return_op si=%d op_ref=%d op_kind=%d callee=%d base=%d name_len=%d var=%.*s field=%.*s\n",
                (int)si, (int)expr_stmt->unary_operand_ref, ret_op ? (int)ret_op->kind : -1,
                ret_op ? (int)ret_op->call_callee_ref : -1, ret_op ? (int)ret_op->field_access_base_ref : -1,
                ret_op ? (int)ret_op->var_name_len : -1, ret_op ? (int)ret_op->var_name_len : 0,
                ret_op ? (const char *)ret_op->var_name : "",
                ret_op ? (int)ret_op->field_access_field_len : 0,
                ret_op ? (const char *)ret_op->field_access_field_name : "");
      }
    }
  }
  for (expr_ref = 1; expr_ref <= arena->num_exprs; expr_ref++) {
    struct ast_Expr *call_ex = pipeline_arena_expr_ptr(arena, expr_ref);
    struct ast_Expr *callee_ex;
    struct ast_Expr *base_ex;
    int32_t dep_ix;
    int32_t func_ix;
    uint8_t dep_resolved_path[64];
    if (!call_ex || call_ex->kind != ast_ExprKind_EXPR_CALL || call_ex->call_callee_ref <= 0)
      continue;
    callee_ex = pipeline_arena_expr_ptr(arena, call_ex->call_callee_ref);
    if (!callee_ex || callee_ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS || callee_ex->field_access_base_ref <= 0)
      continue;
    base_ex = pipeline_arena_expr_ptr(arena, callee_ex->field_access_base_ref);
    if (!base_ex || base_ex->kind != ast_ExprKind_EXPR_VAR)
      continue;
    if (!pipeline_debug_name_eq_buf_lit(base_ex->var_name, base_ex->var_name_len, "heap_libc"))
      continue;
    if (!pipeline_debug_name_eq_buf_lit(callee_ex->field_access_field_name, callee_ex->field_access_field_len,
                                        "heap_trace_enabled_c"))
      continue;
    dep_ix = pipeline_expr_call_resolved_dep_index_at(arena, expr_ref);
    func_ix = pipeline_expr_call_resolved_func_index_at(arena, expr_ref);
    memset(dep_resolved_path, 0, sizeof(dep_resolved_path));
    if (dep_ix >= 0 && dep_ix < pipeline_dep_ctx_ndep(ctx))
      pipeline_dep_ctx_import_path_copy64(ctx, dep_ix, dep_resolved_path);
    fprintf(stderr,
            "shux: [SHUX_DEBUG_PIPE] std.heap trace_on call expr=%d callee=%d dep_ix=%d func_ix=%d global_dep=%s\n",
            (int)expr_ref, (int)call_ex->call_callee_ref, (int)dep_ix, (int)func_ix,
            dep_ix >= 0 ? (char *)dep_resolved_path : "<none>");
  }
  for (expr_ref = 1; expr_ref <= arena->num_exprs; expr_ref++) {
    struct ast_Expr *ex = pipeline_arena_expr_ptr(arena, expr_ref);
    int hit = 0;
    if (!ex)
      continue;
    if (ex->kind == ast_ExprKind_EXPR_VAR &&
        pipeline_debug_name_eq_buf_lit(ex->var_name, ex->var_name_len, "heap_libc"))
      hit = 1;
    if (ex->kind == ast_ExprKind_EXPR_FIELD_ACCESS &&
        pipeline_debug_name_eq_buf_lit(ex->field_access_field_name, ex->field_access_field_len, "heap_trace_enabled_c"))
      hit = 1;
    if (!hit)
      continue;
    fprintf(stderr,
            "shux: [SHUX_DEBUG_PIPE] std.heap expr expr=%d kind=%d callee=%d base=%d name_len=%d var=%.*s field=%.*s dep_ix=%d func_ix=%d\n",
            (int)expr_ref, (int)ex->kind, (int)ex->call_callee_ref, (int)ex->field_access_base_ref,
            (int)ex->var_name_len, (int)ex->var_name_len, (const char *)ex->var_name, (int)ex->field_access_field_len,
            (const char *)ex->field_access_field_name, (int)ex->call_resolved_dep_index,
            (int)ex->call_resolved_func_index);
  }
}

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j);

/**
 * 对单个 dep 执行 asm/C codegen；C glue（dep_mod->num_funcs 读 + asm 深栈 emit 仍须 C）。
 */
int32_t run_x_pipeline_codegen_one_dep_emit(struct ast_Module *dep_mod, struct codegen_CodegenOutBuf *out_buf,
                                             struct ast_PipelineDepCtx *ctx, int32_t dep_j, int32_t skip_asm_dep_codegen,
                                             int32_t use_asm_backend) {
  uint8_t dep_path_buf[64];

  if (!out_buf || !ctx || dep_j < 0)
    return -1;
  if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, dep_j) != 0) {
    if (getenv("SHUX_DEBUG_PIPE")) {
      memset(dep_path_buf, 0, sizeof(dep_path_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
      fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] skip duplicate dep emit j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
    }
    return 0;
  }
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dep_path_buf);
  if (getenv("SHUX_DEBUG_PIPE"))
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep emit j=%d path=%s use_asm=%d funcs=%d\n", (int)dep_j,
            (char *)dep_path_buf, (int)use_asm_backend,
            dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
  pipeline_debug_dump_std_heap_trace_call(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), ctx, dep_j, dep_path_buf);
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    if (getenv("SHUX_DEBUG_PIPE"))
      fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] skip dep emit j=%d path=%s\n", (int)dep_j, (char *)dep_path_buf);
    return 0;
  }
  /** asm_entry_module_only / skip_asm_dep_codegen：dep 符号由并列 *.o 提供，勿 co-emit 进 entry 的 C/asm。 */
  if (skip_asm_dep_codegen != 0)
    return 0;
  if (dep_mod && pipeline_module_num_funcs(dep_mod) > 0) {
    if (use_asm_backend != 0) {
      if (skip_asm_dep_codegen == 0 &&
          asm_asm_codegen_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), out_buf, ctx) != 0) {
        if (getenv("SHUX_DEBUG_PIPE"))
          fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep emit asm fail j=%d path=%s\n", (int)dep_j,
                  (char *)dep_path_buf);
        return -6;
      }
    } else if (codegen_codegen_x_ast(dep_mod, pipeline_dep_ctx_arena_at(ctx, dep_j), out_buf, ctx, dep_j) != 0) {
      if (getenv("SHUX_DEBUG_PIPE")) {
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep emit c fail j=%d path=%s last_func_idx=%d out_len=%zu\n",
                (int)dep_j, (char *)dep_path_buf, (int)ctx->current_func_index, (size_t)out_buf->len);
      }
      return -6;
    }
  }
  return 0;
}

/**
 * entry module 最终 codegen emit；C glue（asm_asm_codegen_ast / codegen_codegen_x_ast 深栈保留 C）。
 */
int32_t run_x_pipeline_codegen_entry_emit(struct ast_Module *module, struct ast_ASTArena *arena,
                                           struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                           int32_t use_asm_backend) {
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  if (use_asm_backend != 0) {
    if (asm_asm_codegen_ast(module, arena, out_buf, ctx) != 0)
      return -6;
  } else if (codegen_codegen_x_ast(module, arena, out_buf, ctx, -1) != 0) {
    return -6;
  }
  return 0;
}

extern int32_t driver_skip_codegen_dep_0_get(void);
extern void driver_set_current_dep_path_for_codegen(uint8_t *path);
extern void driver_diagnostic_entry_already(int32_t v);
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);
extern void driver_diagnostic_entry_module(struct ast_Module *module, struct ast_ASTArena *arena);
extern int32_t pipeline_dep_ctx_entry_already_parsed(struct ast_PipelineDepCtx *ctx);
extern int32_t pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx);
extern void pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *path, int32_t len);
extern void pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *dst);

/** entry parse 薄编排 C glue（EMIT_HEAVY 勿 X let init CALL）。 */
int32_t run_x_pipeline_parse_entry_if_needed_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                uint8_t *source_data, size_t source_len,
                                                struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !ctx)
    return -1;
  driver_diagnostic_entry_already(pipeline_dep_ctx_entry_already_parsed(ctx));
  if (pipeline_dep_ctx_entry_already_parsed(ctx) != 0) {
    driver_diagnostic_after_entry_parse(pipeline_module_num_funcs(module));
    driver_diagnostic_entry_module(module, arena);
    return 0;
  }
  return run_x_pipeline_parse_entry_do_parse_c(module, arena, source_data, source_len, ctx);
}

/** dep 路径 buf 非空时写入 ctx import_path；C glue（X u8[64] 栈后单点 set）。 */
int32_t pipeline_fill_dep_import_path_from_buf_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *path_buf) {
  int32_t path_len = 0;

  if (!ctx || !path_buf || dep_j < 0)
    return -1;
  while (path_len < 64 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

/**
 * 扫描 buf64 长度后 resolve_path_x；C glue（X 栈 path + assign CALL emit 失败）。
 */
int32_t pipeline_resolve_path_x_from_buf64_c(struct ast_PipelineDepCtx *ctx, uint8_t *path_buf) {
  int32_t path_len = 0;

  if (!ctx || !path_buf)
    return -1;
  while (path_len < 64 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len <= 0)
    return -1;
  return pipeline_resolve_path_x(ctx, path_buf, path_len);
}

/** dep import 路径补全；C glue（X u8[64] 栈 + assign CALL）。 */
int32_t run_x_pipeline_fill_dep_import_path_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx,
                                                int32_t dep_j) {
  uint8_t path_buf[64];
  int32_t path_len;

  if (!module || !ctx || dep_j < 0)
    return -1;
  memset(path_buf, 0, sizeof(path_buf));
  (void)parser_copy_module_import_path64(module, dep_j, path_buf);
  path_len = 0;
  while (path_len < 64 && path_buf[path_len] != 0)
    path_len = path_len + 1;
  if (path_len > 0)
    pipeline_dep_ctx_set_import_path(ctx, dep_j, path_buf, path_len);
  return 0;
}

/** codegen 前设置 dep 符号前缀；C glue。 */
int32_t pipeline_prepare_dep_codegen_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j, uint8_t *dst) {
  if (!ctx || !dst || dep_j < 0)
    return -1;
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, dst);
  driver_set_current_dep_path_for_codegen(dst);
  return 0;
}

/** dep codegen 后清理前缀并打诊断；C glue。 */
int32_t pipeline_finish_dep_codegen_diag_c(int32_t dep_j, struct codegen_CodegenOutBuf *out_buf) {
  if (!out_buf)
    return -1;
  driver_diagnostic_after_dep_codegen(dep_j, (int32_t)out_buf->len);
  driver_set_current_dep_path_for_codegen(NULL);
  return 0;
}

/** 单 dep codegen 编排；C glue。 */
int32_t run_x_pipeline_codegen_one_dep_c(struct ast_Module *module, struct codegen_CodegenOutBuf *out_buf,
                                          struct ast_PipelineDepCtx *ctx, int32_t dep_j,
                                          int32_t skip_asm_dep_codegen) {
  uint8_t dep_path_buf[64];
  struct ast_Module *dep_mod;
  int32_t use_asm;

  if (!module || !out_buf || !ctx || dep_j < 0)
    return -1;
  if (dep_j == 0 && driver_skip_codegen_dep_0_get() != 0)
    return 0;
  if (run_x_pipeline_fill_dep_import_path_c(module, ctx, dep_j) != 0)
    return -1;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
  dep_mod = pipeline_dep_ctx_module_at(ctx, dep_j);
  if (getenv("SHUX_DEBUG_PIPE"))
    fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] dep codegen j=%d path=%s funcs=%d\n", (int)dep_j,
            (char *)dep_path_buf, dep_mod ? (int)pipeline_module_num_funcs(dep_mod) : -1);
  /** bootstrap partial：前端模块勿整库 C emit（符号由 *_x.o 提供）。 */
  if (pipeline_codegen_dep_skip_x_bootstrap_partial(dep_path_buf) != 0) {
    if (getenv("SHUX_DEBUG_PIPE"))
      fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] skip dep codegen j=%d path=%s\n", (int)dep_j,
              (char *)dep_path_buf);
    driver_set_current_dep_path_for_codegen(NULL);
    return 0;
  }
  use_asm = pipeline_dep_ctx_use_asm_backend(ctx);
  if (run_x_pipeline_codegen_one_dep_emit(dep_mod, out_buf, ctx, dep_j, skip_asm_dep_codegen, use_asm) != 0) {
    driver_diagnostic_codegen_fail(dep_j, 1);
    return -6;
  }
  pipeline_finish_dep_codegen_diag_c(dep_j, out_buf);
  return 0;
}

static int32_t pipeline_dep_ctx_has_earlier_same_import_path_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  int32_t path_len;
  int32_t prev_j;
  uint8_t path_buf[64];

  if (!ctx || dep_j <= 0)
    return 0;
  path_len = pipeline_dep_ctx_import_path_len(ctx, dep_j);
  if (path_len <= 0 || path_len > (int32_t)sizeof(path_buf))
    return 0;
  memset(path_buf, 0, sizeof(path_buf));
  pipeline_dep_ctx_import_path_copy64(ctx, dep_j, path_buf);
  prev_j = 0;
  while (prev_j < dep_j) {
    int32_t prev_len = pipeline_dep_ctx_import_path_len(ctx, prev_j);
    uint8_t prev_buf[64];
    if (prev_len == path_len && prev_len > 0 && prev_len <= (int32_t)sizeof(prev_buf)) {
      memset(prev_buf, 0, sizeof(prev_buf));
      pipeline_dep_ctx_import_path_copy64(ctx, prev_j, prev_buf);
      if (memcmp(prev_buf, path_buf, (size_t)path_len) == 0)
        return 1;
    }
    prev_j = prev_j + 1;
  }
  return 0;
}

/** 各 dep codegen while 循环；C glue。 */
int32_t run_x_pipeline_codegen_deps_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                       struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx,
                                       int32_t skip_asm_dep_codegen) {
  int32_t ndep;
  int32_t j;

  if (!module || !arena || !out_buf || !ctx)
    return -1;
  ndep = pipeline_dep_ctx_ndep(ctx);
  j = 0;
  while (j < ndep) {
    if (pipeline_dep_ctx_has_earlier_same_import_path_c(ctx, j) != 0) {
      if (getenv("SHUX_DEBUG_PIPE")) {
        uint8_t dup_path_buf[64];
        memset(dup_path_buf, 0, sizeof(dup_path_buf));
        pipeline_dep_ctx_import_path_copy64(ctx, j, dup_path_buf);
        fprintf(stderr, "shux: [SHUX_DEBUG_PIPE] skip duplicate dep codegen j=%d path=%s\n", (int)j,
                (char *)dup_path_buf);
      }
      j = j + 1;
      continue;
    }
    if (run_x_pipeline_codegen_one_dep_c(module, out_buf, ctx, j, skip_asm_dep_codegen) != 0)
      return -6;
    j = j + 1;
  }
  return 0;
}

/** entry module 最终 codegen 编排；C glue。 */
int32_t run_x_pipeline_codegen_entry_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                         struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  if (!module || !arena || !out_buf || !ctx)
    return -1;
  driver_diagnostic_entry_module(module, arena);
  if (run_x_pipeline_codegen_entry_emit(module, arena, out_buf, ctx,
                                         pipeline_dep_ctx_use_asm_backend(ctx)) != 0) {
    driver_diagnostic_codegen_fail(0, 0);
    return -6;
  }
  return 0;
}

/**
 * 有界循环 continue：idx < ndep 时返回 1（X while 裸 CALL 条件，勿 CALL==0 比较 emit 失败）。
 */
int32_t pipeline_loop_should_continue_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * 有界 import 循环 continue：idx < num_imports 时返回 1。
 */
int32_t pipeline_loop_should_continue_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 0;
  return idx < parser_get_module_num_imports(module) ? 1 : 0;
}

/**
 * 有界 lib_root 循环 continue：idx < lib_root_count 时返回 1（resolve_path_x X while）。
 */
int32_t pipeline_loop_should_continue_lib_root_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 0;
  return idx < pipeline_ctx_lib_root_count(ctx) ? 1 : 0;
}

/**
 * 有界循环 exit：idx >= ndep 时返回 1（X 用 if(CALL!=0)，勿 idx>=ndep(ctx) 比较 emit 失败）。
 */
int32_t pipeline_loop_index_at_or_beyond_ndep_c(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  if (!ctx)
    return 1;
  return idx >= pipeline_dep_ctx_ndep(ctx) ? 1 : 0;
}

/**
 * 有界 import 循环 exit：idx >= num_imports 时返回 1。
 */
int32_t pipeline_loop_index_at_or_beyond_imports_c(struct ast_Module *module, int32_t idx) {
  if (!module)
    return 1;
  return idx >= parser_get_module_num_imports(module) ? 1 : 0;
}

/** load_and_sync import 循环结束后写 ndep；C glue（勿 X stmt 内嵌双 CALL）。 */
void pipeline_load_and_sync_set_ndep_from_module_c(struct ast_Module *module, struct ast_PipelineDepCtx *ctx) {
  if (module && ctx)
    pipeline_dep_ctx_set_ndep(ctx, parser_get_module_num_imports(module));
}

/** one_dep codegen 前 prepare path prefix；C glue（X 侧 u8[64] 栈数组）。 */
int32_t run_x_pipeline_codegen_one_dep_prepare_c(struct ast_PipelineDepCtx *ctx, int32_t dep_j) {
  uint8_t dep_path_buf[64];

  if (!ctx || dep_j < 0)
    return -1;
  memset(dep_path_buf, 0, sizeof(dep_path_buf));
  return pipeline_prepare_dep_codegen_path_c(ctx, dep_j, dep_path_buf);
}

/** 读 lib_root 路径第 off 字节；越界或无效返回 0（避免 pipeline.x 侧整段 copy 大缓冲）。 */
uint8_t pipeline_ctx_lib_root_byte_at(struct ast_PipelineDepCtx *ctx, int32_t i, int32_t off) {
  DepCtxSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  if (!ctx || i < 0 || off < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->lib_root_rows.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row || off >= *pl)
    return 0;
  return row[off];
}

/** codegen 无名形参下标 grow 池（替代 PipelineDepCtx 内联 i32[16]）。 */
void pipeline_dep_ctx_empty_param_reset(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx)
    return;
  sc = depctx_sidecar_get(ctx, 0);
  if (sc)
    sc->empty_param_indices.len = 0;
  ctx->current_func_empty_param_count = 0;
}

int32_t pipeline_dep_ctx_empty_param_append(struct ast_PipelineDepCtx *ctx, int32_t pi) {
  DepCtxSidecar *sc;
  int32_t *slot;
  if (!ctx || !(sc = depctx_sidecar_get(ctx, 1)))
    return -1;
  if (grow_vec_push(&sc->empty_param_indices) < 0)
    return -1;
  slot = (int32_t *)grow_vec_at(&sc->empty_param_indices, sc->empty_param_indices.len - 1);
  if (!slot)
    return -1;
  *slot = pi;
  ctx->current_func_empty_param_count = sc->empty_param_indices.len;
  return sc->empty_param_indices.len - 1;
}

int32_t pipeline_dep_ctx_empty_param_at(struct ast_PipelineDepCtx *ctx, int32_t i) {
  DepCtxSidecar *sc;
  int32_t *slot;
  if (!ctx || i < 0 || !(sc = depctx_sidecar_get(ctx, 0)) || i >= sc->empty_param_indices.len)
    return -1;
  slot = (int32_t *)grow_vec_at(&sc->empty_param_indices, i);
  return slot ? *slot : -1;
}

void pipeline_dep_ctx_empty_param_backup(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx || !(sc = depctx_sidecar_get(ctx, 1)))
    return;
  sc->empty_param_backup.len = 0;
  grow_vec_copy_append(&sc->empty_param_backup, &sc->empty_param_indices);
}

void pipeline_dep_ctx_empty_param_restore(struct ast_PipelineDepCtx *ctx) {
  DepCtxSidecar *sc;
  if (!ctx || !(sc = depctx_sidecar_get(ctx, 0)))
    return;
  sc->empty_param_indices.len = 0;
  grow_vec_copy_append(&sc->empty_param_indices, &sc->empty_param_backup);
  ctx->current_func_empty_param_count = sc->empty_param_indices.len;
}

static DriverEmitSidecar *driver_emit_sidecar_get(uint8_t *state, int create) {
  int i;
  if (!state)
    return NULL;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (g_driver_emit_sc[i].used && g_driver_emit_sc[i].state == state)
      return &g_driver_emit_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_DRIVER_EMIT_SIDECARS; i++) {
    if (!g_driver_emit_sc[i].used) {
      g_driver_emit_sc[i].state = state;
      g_driver_emit_sc[i].used = 1;
      if (!grow_vec_init(&g_driver_emit_sc[i].lib_root_rows, 256, AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_driver_emit_sc[i].lib_root_lens, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      return &g_driver_emit_sc[i];
    }
  }
  return NULL;
}

void driver_emit_lib_root_reset(uint8_t *state) {
  DriverEmitSidecar *sc = driver_emit_sidecar_get(state, 0);
  if (!sc)
    return;
  sc->lib_root_rows.len = 0;
  sc->lib_root_lens.len = 0;
}

int32_t driver_emit_append_lib_root(uint8_t *state, uint8_t *path, int32_t len) {
  DriverEmitSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!state || !path || len <= 0)
    return -1;
  if (!(sc = driver_emit_sidecar_get(state, 1)))
    return -1;
  idx = grow_vec_push(&sc->lib_root_rows);
  if (idx < 0 || grow_vec_push(&sc->lib_root_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, idx);
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, idx);
  if (!row || !pl)
    return -1;
  n = len > 255 ? 255 : len;
  memset(row, 0, 256);
  memcpy(row, path, (size_t)n);
  *pl = n;
  return idx;
}

int32_t driver_emit_lib_root_count(uint8_t *state) {
  DriverEmitSidecar *sc = driver_emit_sidecar_get(state, 0);
  return sc ? sc->lib_root_rows.len : 0;
}

int32_t driver_emit_lib_root_len(uint8_t *state, int32_t i) {
  DriverEmitSidecar *sc;
  int32_t *pl;
  if (!state || i < 0 || !(sc = driver_emit_sidecar_get(state, 0)) || i >= sc->lib_root_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  return pl ? *pl : 0;
}

void driver_emit_lib_root_copy(uint8_t *state, int32_t i, uint8_t *dst, int32_t cap) {
  DriverEmitSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (!state || i < 0 || !(sc = driver_emit_sidecar_get(state, 0)) || i >= sc->lib_root_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&sc->lib_root_lens, i);
  row = (uint8_t *)grow_vec_at(&sc->lib_root_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** backend.x：import 限定符号解析时的 field 层栈（替代 [16][64] 栈数组）。 */
typedef struct {
  int inited;
  GrowVec layer_rows;
  GrowVec layer_lens;
} AsmQualSymScratch;

static AsmQualSymScratch g_asm_qual_sym;

/** 惰性初始化 asm 限定符号 scratch 池。 */
static void asm_qual_sym_scratch_ensure(void) {
  if (g_asm_qual_sym.inited)
    return;
  if (!grow_vec_init(&g_asm_qual_sym.layer_rows, 64, AST_POOL_GROW))
    return;
  if (!grow_vec_init(&g_asm_qual_sym.layer_lens, sizeof(int32_t), AST_POOL_GROW))
    return;
  g_asm_qual_sym.inited = 1;
}

/** 清空 field 层栈。 */
void asm_qual_sym_layer_reset(void) {
  asm_qual_sym_scratch_ensure();
  g_asm_qual_sym.layer_rows.len = 0;
  g_asm_qual_sym.layer_lens.len = 0;
}

/** 追加一层 field 名（最多 63 字节）；返回层下标，失败 -1。 */
int32_t asm_qual_sym_layer_push(uint8_t *bytes, int32_t len) {
  uint8_t *row;
  int32_t *pl;
  int32_t idx;
  int32_t n;
  if (!bytes || len <= 0)
    return -1;
  asm_qual_sym_scratch_ensure();
  if (!g_asm_qual_sym.inited)
    return -1;
  n = len > 63 ? 63 : len;
  idx = grow_vec_push(&g_asm_qual_sym.layer_rows);
  if (idx < 0 || grow_vec_push(&g_asm_qual_sym.layer_lens) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&g_asm_qual_sym.layer_rows, idx);
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, idx);
  if (!row || !pl)
    return -1;
  memset(row, 0, 64);
  memcpy(row, bytes, (size_t)n);
  *pl = n;
  return idx;
}

/** 当前层数。 */
int32_t asm_qual_sym_layer_count(void) {
  asm_qual_sym_scratch_ensure();
  return g_asm_qual_sym.inited ? g_asm_qual_sym.layer_rows.len : 0;
}

/** 第 i 层 field 名长度。 */
int32_t asm_qual_sym_layer_len(int32_t i) {
  int32_t *pl;
  if (i < 0 || !g_asm_qual_sym.inited || i >= g_asm_qual_sym.layer_lens.len)
    return 0;
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, i);
  return pl ? *pl : 0;
}

/** 拷贝第 i 层 field 名到 dst（cap 含 NUL 余量）。 */
void asm_qual_sym_layer_copy(int32_t i, uint8_t *dst, int32_t cap) {
  uint8_t *row;
  int32_t *pl;
  int32_t n;
  int32_t k;
  if (!dst || cap <= 0)
    return;
  memset(dst, 0, (size_t)cap);
  if (i < 0 || !g_asm_qual_sym.inited || i >= g_asm_qual_sym.layer_rows.len)
    return;
  pl = (int32_t *)grow_vec_at(&g_asm_qual_sym.layer_lens, i);
  row = (uint8_t *)grow_vec_at(&g_asm_qual_sym.layer_rows, i);
  if (!pl || !row)
    return;
  n = *pl;
  if (n >= cap)
    n = cap - 1;
  for (k = 0; k < n; k++)
    dst[k] = row[k];
}

/** preprocess.x：#if/#else 嵌套栈（替代 i32[32] 固定栈）。 */
static GrowVec g_preprocess_if_stack;
static int g_preprocess_if_inited;

static void preprocess_if_stack_ensure(void) {
  if (g_preprocess_if_inited)
    return;
  if (!grow_vec_init(&g_preprocess_if_stack, sizeof(int32_t), AST_POOL_GROW))
    return;
  g_preprocess_if_inited = 1;
}

/** 清空 #if 嵌套栈。 */
void preprocess_if_stack_reset(void) {
  preprocess_if_stack_ensure();
  g_preprocess_if_stack.len = 0;
}

/** 当前嵌套深度。 */
int32_t preprocess_if_stack_len(void) {
  preprocess_if_stack_ensure();
  return g_preprocess_if_inited ? g_preprocess_if_stack.len : 0;
}

/** 追加一层栈状态；失败 -1。 */
int32_t preprocess_if_stack_push(int32_t v) {
  int32_t *slot;
  preprocess_if_stack_ensure();
  if (!g_preprocess_if_inited)
    return -1;
  if (grow_vec_push(&g_preprocess_if_stack) < 0)
    return -1;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, g_preprocess_if_stack.len - 1);
  if (!slot)
    return -1;
  *slot = v;
  return 0;
}

/** 弹出一层（#endif）。 */
void preprocess_if_stack_pop(void) {
  preprocess_if_stack_ensure();
  if (g_preprocess_if_stack.len > 0)
    g_preprocess_if_stack.len--;
}

/** 读 stack[i]。 */
int32_t preprocess_if_stack_at(int32_t i) {
  int32_t *slot;
  if (i < 0 || !g_preprocess_if_inited || i >= g_preprocess_if_stack.len)
    return 0;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, i);
  return slot ? *slot : 0;
}

/** 写 stack[i]。 */
void preprocess_if_stack_set_at(int32_t i, int32_t v) {
  int32_t *slot;
  if (i < 0 || !g_preprocess_if_inited || i >= g_preprocess_if_stack.len)
    return;
  slot = (int32_t *)grow_vec_at(&g_preprocess_if_stack, i);
  if (slot)
    *slot = v;
}

/** typeck.x：命名类型对齐/大小时复用的 64 字节 scratch（避免局部 u8[64] 在自 typecheck 时 check_block 失败）。 */
uint8_t *typeck_named_scratch64(void) {
  static uint8_t s[64];
  return s;
}

/** typeck.x：多槽 64 字节 scratch；嵌套 layout/struct_lit 路径须用不同 slot 避免覆盖。 */
static uint8_t g_typeck_scratch64[16][64];

uint8_t *typeck_scratch64_slot(int32_t slot) {
  if (slot < 0 || slot >= 16)
    return g_typeck_scratch64[0];
  return g_typeck_scratch64[slot];
}

/** typeck.x：CALL resolve 写 func 下标用；勿用栈上 &cfi（自举 pipeline 下可撕裂致 segfault）。 */
static int32_t g_typeck_call_resolve_func_idx;
static int32_t g_typeck_call_resolve_dep_idx;

int32_t *typeck_call_resolve_func_idx_slot(void) {
  return &g_typeck_call_resolve_func_idx;
}

int32_t *typeck_call_resolve_dep_idx_slot(void) {
  return &g_typeck_call_resolve_dep_idx;
}

/** 读 CALL resolve dep scratch（X emit 勿 typeck_i32_ptr_read(slot()) 嵌套）。 */
int32_t typeck_call_resolve_dep_idx_peek(void) {
  return g_typeck_call_resolve_dep_idx;
}

/** 读 CALL resolve func scratch（X emit 勿 typeck_i32_ptr_read(slot()) 嵌套）。 */
int32_t typeck_call_resolve_func_idx_peek(void) {
  return g_typeck_call_resolve_func_idx;
}

/** 前向声明：binop arith infer C glue 读/写类型池。 */
extern int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref);
extern int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_array_size_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *a, int32_t type_ref);
extern int32_t pipeline_typeck_type_refs_equal_c(struct ast_ASTArena *arena, int32_t a, int32_t b);
extern int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord);

static int32_t typeck_integer_widen_ok_ord_c(int32_t dest_kind, int32_t src_kind) {
  if (dest_kind == src_kind)
    return dest_kind == 0 || dest_kind == 2 || dest_kind == 3 || dest_kind == 4 || dest_kind == 5 || dest_kind == 6;
  if (src_kind == 2)
    return dest_kind == 0 || dest_kind == 3 || dest_kind == 4 || dest_kind == 6;
  if (src_kind == 0)
    return dest_kind == 3 || dest_kind == 5 || dest_kind == 6;
  return src_kind == 3 && dest_kind == 4;
}

/**
 * 算术/位 binop 结果类型推导（typeck.x 同逻辑；X 单函 emit 触顶 reloc 8192，暂经 C glue）。
 * 假定 bop_l/bop_r 已 check；写 expr_ref.resolved_type_ref。
 */
void typeck_binop_arith_infer_type_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t bop_l,
                                     int32_t bop_r, int32_t expr_kind) {
  int32_t lk_expr;
  int32_t rk_expr;
  int32_t lt_ar;
  int32_t rt_ar;
  int32_t lko;
  int32_t rko;
  int32_t out_ar = 0;
  int32_t allow_i32_fallback = 0;
  if (!arena || expr_ref <= 0 || bop_l <= 0 || bop_r <= 0)
    return;
  lt_ar = pipeline_expr_resolved_type_ref(arena, bop_l);
  rt_ar = pipeline_expr_resolved_type_ref(arena, bop_r);
  if (lt_ar <= 0 || rt_ar <= 0 || lt_ar > arena->num_types || rt_ar > arena->num_types)
    return;
  lk_expr = pipeline_expr_kind_ord_at(arena, bop_l);
  rk_expr = pipeline_expr_kind_ord_at(arena, bop_r);
  lko = pipeline_type_kind_ord_at(arena, lt_ar);
  rko = pipeline_type_kind_ord_at(arena, rt_ar);
  /** ptr ± i32/usize/isize → ptr（与 typeck.x binop_arith 一致）。 */
  if (expr_kind >= 4 && expr_kind <= 5) {
    if (lko == 9 && (rko == 0 || rko == 6 || rko == 7))
      out_ar = lt_ar;
    else if (expr_kind == 4 && rko == 9 && (lko == 0 || lko == 6 || lko == 7))
      out_ar = rt_ar;
  }
  if (lko == 13 && rko == 13 && pipeline_type_array_size_at(arena, lt_ar) == pipeline_type_array_size_at(arena, rt_ar) &&
      pipeline_typeck_type_refs_equal_c(arena, pipeline_type_elem_ref_at(arena, lt_ar),
                                        pipeline_type_elem_ref_at(arena, rt_ar)) != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && (lko == 5 || rko == 5)) {
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 5);
  } else if (out_ar == 0 && (lko == 14 || rko == 14)) {
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 14);
  } else if (out_ar == 0 && (lko == 15 || rko == 15)) {
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 15);
  } else if (out_ar == 0 && pipeline_typeck_type_refs_equal_c(arena, lt_ar, rt_ar) != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && typeck_integer_widen_ok_ord_c(lko, rko)) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && typeck_integer_widen_ok_ord_c(rko, lko)) {
    out_ar = rt_ar;
  } else if (out_ar == 0 && lk_expr == 0 && rk_expr != 0) {
    out_ar = rt_ar;
  } else if (out_ar == 0 && rk_expr == 0 && lk_expr != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && lt_ar != 0) {
    out_ar = lt_ar;
  } else if (out_ar == 0 && rt_ar != 0) {
    out_ar = rt_ar;
  }
  if (expr_kind >= 4 && expr_kind <= 13)
    allow_i32_fallback = 1;
  if (out_ar == 0 && lko != 13 && rko != 13 && allow_i32_fallback)
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 0);
  if (allow_i32_fallback && lko != 9 && rko != 9 &&
      (pipeline_type_kind_ord_at(arena, lt_ar) == 1 || pipeline_type_kind_ord_at(arena, rt_ar) == 1))
    out_ar = pipeline_type_ensure_by_kind_ord(arena, 0);
  if (out_ar != 0)
    pipeline_expr_set_resolved_type_ref(arena, expr_ref, out_ar);
}

/**
 * packed struct 布局快路径：无隐式 padding；与 typeck.x typeck_struct_layout_metrics 一致。
 * 返回值：1=已写入 out_sz/out_al，0=非 packed 须走常规对齐路径，-1=字段尺寸错误。
 */
int32_t typeck_struct_layout_metrics_try_packed_c(struct ast_Module *module, struct ast_ASTArena *arena,
                                                int32_t li, int32_t depth, int32_t check_pad, int32_t *out_sz,
                                                int32_t *out_al) {
  int32_t nf;
  int32_t j;
  int32_t ftr;
  int32_t fsize;
  int32_t current;
  uint8_t layout_nm[64];
  uint8_t field_nm[64];
  int32_t layout_nlen;
  int32_t flen;
  extern int32_t typeck_x_type_size(struct ast_Module *module, struct ast_ASTArena *arena, int32_t ty_ref,
                                     int32_t depth);
  extern void driver_diagnostic_typeck_struct_field_bad_size(uint8_t *sname, int32_t sname_len, uint8_t *fname,
                                                             int32_t fname_len);
  (void)check_pad;
  if (!module || !arena || !out_sz || !out_al || li < 0)
    return 0;
  if (pipeline_module_struct_layout_packed_at(module, li) == 0)
    return 0;
  nf = pipeline_module_struct_layout_num_fields(module, li);
  current = 0;
  j = 0;
  while (j < nf) {
    ftr = pipeline_module_struct_layout_field_type_ref(module, li, j);
    pipeline_module_struct_layout_field_name_into(module, li, j, field_nm);
    flen = pipeline_module_struct_layout_field_name_len(module, li, j);
    fsize = typeck_x_type_size(module, arena, ftr, depth);
    if (fsize <= 0) {
      pipeline_module_struct_layout_name_into(module, li, layout_nm);
      layout_nlen = pipeline_module_struct_layout_name_len(module, li);
      driver_diagnostic_typeck_struct_field_bad_size(layout_nm, layout_nlen, field_nm, flen);
      return -1;
    }
    current = current + fsize;
    j = j + 1;
  }
  *out_sz = current;
  *out_al = 1;
  return 1;
}

/** typeck.x：struct_layout_metrics 写 out_sz/out_al；勿用栈上 &z/&al。 */
static int32_t g_typeck_layout_metrics_sz;
static int32_t g_typeck_layout_metrics_al;

int32_t *typeck_layout_metrics_sz_slot(void) {
  return &g_typeck_layout_metrics_sz;
}

int32_t *typeck_layout_metrics_al_slot(void) {
  return &g_typeck_layout_metrics_al;
}

/** 递归 metrics 用 depth 分槽（8 组），避免 align/size 共用单槽 tearing。 */
static int32_t g_typeck_layout_metrics_depth_scratch[8][2];

int32_t *typeck_layout_metrics_sz_slot_depth(int32_t depth) {
  int32_t s = depth;
  if (s < 0)
    s = 0;
  return &g_typeck_layout_metrics_depth_scratch[s % 8][0];
}

int32_t *typeck_layout_metrics_al_slot_depth(int32_t depth) {
  int32_t s = depth;
  if (s < 0)
    s = 0;
  return &g_typeck_layout_metrics_depth_scratch[s % 8][1];
}

/** ElfCodegenCtx 标签/补丁/重定位/符号表行数；与 platform/elf.x 内联数组维度一致（改须全链 rebuild）。
 * parser EMIT_HEAVY 真 emit 时 num_patches/labels 可上千；4096 与 elf.x 16384 漂移会导致 resolve_patches 失败。 */
#define PIPELINE_ELF_CTX_TABLE_CAP 16384
/** 堆 sidecar 扩 reloc 总上限（内联 16384 + heap 16384）。 */
#define PIPELINE_ELF_CTX_RELOC_TOTAL_CAP 32768
#define PIPELINE_ELF_CTX_RELOC_HEAP_CAP (PIPELINE_ELF_CTX_RELOC_TOTAL_CAP - PIPELINE_ELF_CTX_TABLE_CAP)

/**
 * platform/elf.x：ElfCodegenCtx 体量大，.x/asm 对 patches[pi].* / relocs[ri].* 字段写入 typeck 失败；
 * 布局须与 elf.x 中 ElfLabelEntry / ElfPatchEntry / ElfRelocEntry / ElfSymEntry 前缀一致（改 elf.x 时同步）。
 */
/** 与 elf.x ElfLabelEntry 布局一致（无 code_shndx；PGO 段索引见 sidecar）。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t offset;
} PipelineElfLabelEntry;

/** 与 elf.x ElfPatchEntry 布局一致。 */
typedef struct {
  int32_t rel32_offset;
  uint8_t name[64];
  int32_t name_len;
  int32_t patch_imm_bits;
} PipelineElfPatchEntry;

/** 与 elf.x ElfRelocEntry 布局一致。 */
typedef struct {
  int32_t offset;
  int32_t name_len;
} PipelineElfRelocEntry;

/** heap reloc sidecar 专用：内联 relocs[] 无 code_shndx 字段。 */
typedef struct {
  int32_t offset;
  int32_t name_len;
  int32_t code_shndx;
} PipelineElfRelocHeapEntry;

typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t offset;
  /** 符号所属段：1=.text，2=.text.hot，3=.text.unlikely。 */
  int32_t sym_shndx;
} PipelineElfSymEntry;

typedef struct {
  uint8_t bytes[64];
} PipelineElfRelocSymName64;

/** code_data 之前的完整前缀；glue 用 offsetof 取 e_machine / code_data，避免手算偏移漂移。 */
typedef struct {
  int32_t code_len;
  PipelineElfLabelEntry labels[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_labels;
  PipelineElfPatchEntry patches[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_patches;
  PipelineElfRelocEntry relocs[PIPELINE_ELF_CTX_TABLE_CAP];
  PipelineElfRelocSymName64 reloc_sym_names[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_relocs;
  PipelineElfSymEntry syms[PIPELINE_ELF_CTX_TABLE_CAP];
  int32_t num_syms;
  int32_t sym_name_len;
  int32_t e_machine;
  int32_t reloc_type_r_pc32;
  int32_t current_frame_size;
  int32_t macho_leading_underscore;
  /** PGO-Lite：.text.hot 已写字节数；与 code_data 之后的 code_hot_data 对应。 */
  int32_t code_hot_len;
  /** 当前 emit 段：0=.text，非 0=.text.hot（须 SHUX_WPO_PGO_HOT=1）。 */
  int32_t emit_hot;
} PipelineElfCtxAccess;

/** code_data 容量；与 elf.x ElfCodegenCtx.code_data 维度一致（8716288，勿用旧 8388608）。 */
#define PIPELINE_ELF_CTX_CODE_BUF_CAP 8716288
/** .text.hot 缓冲（用户程序热段通常远小于 cold；减小 ctx 体积避免 malloc/栈压力）。 */
#define PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP 1048576

/** platform_elf_ElfCodegenCtx 后缀字段偏移（须与 elf.x / pipeline_gen 一致）。 */
enum {
  kPipelineElfCtxEMachineOff = (int)offsetof(PipelineElfCtxAccess, e_machine),
  kPipelineElfCtxMachoUnderscoreOff = (int)offsetof(PipelineElfCtxAccess, macho_leading_underscore),
  kPipelineElfCtxCodeDataOff = (int)sizeof(PipelineElfCtxAccess),
  kPipelineElfCtxCodeHotDataOff = (int)sizeof(PipelineElfCtxAccess) + PIPELINE_ELF_CTX_CODE_BUF_CAP,
  kPipelineElfCtxSymNameDataOff =
      (int)sizeof(PipelineElfCtxAccess) + PIPELINE_ELF_CTX_CODE_BUF_CAP + PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP
};

/** 与 elf.x ElfCodegenCtx 前缀一致；漂移会导致 append_bytes 写穿 malloc 区。 */
_Static_assert(sizeof(PipelineElfLabelEntry) == 72, "PipelineElfLabelEntry must match elf.x ElfLabelEntry");
_Static_assert(sizeof(PipelineElfPatchEntry) == 76, "PipelineElfPatchEntry must match elf.x ElfPatchEntry");
_Static_assert(sizeof(PipelineElfRelocEntry) == 8, "PipelineElfRelocEntry must match elf.x ElfRelocEntry");
_Static_assert(sizeof(PipelineElfSymEntry) == 76, "PipelineElfSymEntry must match elf.x ElfSymEntry");
_Static_assert(kPipelineElfCtxCodeDataOff == (int)sizeof(PipelineElfCtxAccess),
               "PipelineElfCtxAccess prefix size drift vs elf.x");

/** SHUX_WPO_PGO_HOT=1 时启用 .text.hot 双段 emit。 */
int32_t pipeline_elf_pgo_hot_enabled(void) {
  const char *e = getenv("SHUX_WPO_PGO_HOT");
  if (!e || e[0] == '\0')
    return 0;
  if (e[0] == '0' && (e[1] == '\0' || e[1] == '\n'))
    return 0;
  return 1;
}

/** 设置当前函数 emit 目标段（backend 每函数 emit 前调用）。 */
void pipeline_elf_ctx_set_emit_hot(uint8_t *ctx_bytes, int32_t hot) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  ctx->emit_hot = hot != 0 ? 1 : 0;
}

/** .text + .text.hot 已编码字节总和（空 __text 拒绝用）。 */
int32_t pipeline_elf_ctx_total_code_len(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  return ctx->code_len + ctx->code_hot_len;
}

/** 当前 emit 段已写字节数（x86 call patch 的 rel32_at 须相对本段 code_len）。 */
int32_t pipeline_elf_ctx_emit_code_len(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx->emit_hot != 0)
    return ctx->code_hot_len;
  return ctx->code_len;
}

/** PGO-Lite ELF 段索引（与 write_elf_o_pgo 中 shdr 顺序一致）。 */
enum {
  PIPELINE_ELF_SHNX_TEXT = 1,
  PIPELINE_ELF_SHNX_TEXT_HOT = 2,
  PIPELINE_ELF_SHNX_TEXT_UNLIKELY = 3
};

/** 当前 emit 的 ELF 段索引：hot→2，PGO 冷路径→3，否则→1。 */
static int32_t pipeline_elf_ctx_current_shndx(PipelineElfCtxAccess *ctx) {
  if (!ctx)
    return PIPELINE_ELF_SHNX_TEXT;
  if (pipeline_elf_pgo_hot_enabled()) {
    if (ctx->emit_hot != 0)
      return PIPELINE_ELF_SHNX_TEXT_HOT;
    return PIPELINE_ELF_SHNX_TEXT_UNLIKELY;
  }
  return PIPELINE_ELF_SHNX_TEXT;
}

/** 按段索引取 code 缓冲指针（unlikely 与 legacy .text 共用 code_data）。 */
static uint8_t *pipeline_elf_ctx_code_buf(uint8_t *ctx_bytes, int32_t shndx) {
  if (shndx == PIPELINE_ELF_SHNX_TEXT_HOT)
    return ctx_bytes + kPipelineElfCtxCodeHotDataOff;
  return ctx_bytes + kPipelineElfCtxCodeDataOff;
}

/** 按段索引读已编码长度。 */
static int32_t pipeline_elf_ctx_section_len(PipelineElfCtxAccess *ctx, int32_t shndx) {
  if (!ctx)
    return 0;
  if (shndx == PIPELINE_ELF_SHNX_TEXT_HOT)
    return ctx->code_hot_len;
  return ctx->code_len;
}

/**
 * 向当前 emit 段追加机器码字节（append_elf_bytes 统一 C 路由，避免 partial .o 与 ctx 布局漂移）。
 * 返回 0 成功，-1 缓冲满。
 */
int32_t pipeline_elf_ctx_append_bytes(uint8_t *ctx_bytes, uint8_t *ptr, int32_t n) {
  PipelineElfCtxAccess *ctx;
  uint8_t *buf;
  int32_t *len_slot;
  int32_t i;
  if (!ctx_bytes || !ptr || n < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (pipeline_elf_pgo_hot_enabled() && ctx->emit_hot != 0) {
    buf = ctx_bytes + kPipelineElfCtxCodeHotDataOff;
    len_slot = &ctx->code_hot_len;
    if (*len_slot + n > (int32_t)PIPELINE_ELF_CTX_CODE_HOT_BUF_CAP)
      return -1;
  } else {
    buf = ctx_bytes + kPipelineElfCtxCodeDataOff;
    len_slot = &ctx->code_len;
    if (*len_slot + n > (int32_t)PIPELINE_ELF_CTX_CODE_BUF_CAP)
      return -1;
  }
  for (i = 0; i < n; i++)
    buf[*len_slot + i] = ptr[i];
  *len_slot = *len_slot + n;
  return 0;
}

/** num_relocs > TABLE_CAP 时的堆 sidecar（单 ctx 编译期有效；elf_ctx_reset 绑定 owner）。 */
static uint8_t *g_pipeline_elf_reloc_sidecar_owner;
static PipelineElfRelocHeapEntry g_pipeline_elf_reloc_heap[PIPELINE_ELF_CTX_RELOC_HEAP_CAP];
static uint8_t g_pipeline_elf_reloc_sym_heap[PIPELINE_ELF_CTX_RELOC_HEAP_CAP][64];

/** PGO 段索引 sidecar：内联 labels/patches/relocs 无 code_shndx 字段（与 elf.x 布局对齐）。 */
static uint8_t *g_pipeline_elf_shndx_sidecar_owner;
static int32_t g_pipeline_elf_label_shndx[PIPELINE_ELF_CTX_TABLE_CAP];
static int32_t g_pipeline_elf_patch_shndx[PIPELINE_ELF_CTX_TABLE_CAP];
static int32_t g_pipeline_elf_reloc_shndx[PIPELINE_ELF_CTX_TABLE_CAP];

/** 未显式记录时的默认 reloc 段索引。 */
static int32_t pipeline_elf_default_reloc_shndx(void) {
  return pipeline_elf_pgo_hot_enabled() ? PIPELINE_ELF_SHNX_TEXT_UNLIKELY : PIPELINE_ELF_SHNX_TEXT;
}

/** 重置 label/patch/reloc 段 sidecar（与 elf_ctx_reset 同步）。 */
static void pipeline_elf_shndx_sidecar_reset(uint8_t *ctx_bytes) {
  g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
  memset(g_pipeline_elf_label_shndx, 0, sizeof(g_pipeline_elf_label_shndx));
  memset(g_pipeline_elf_patch_shndx, 0, sizeof(g_pipeline_elf_patch_shndx));
  memset(g_pipeline_elf_reloc_shndx, 0, sizeof(g_pipeline_elf_reloc_shndx));
}

static int32_t pipeline_elf_label_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return PIPELINE_ELF_SHNX_TEXT;
  if (g_pipeline_elf_shndx_sidecar_owner != ctx_bytes || g_pipeline_elf_label_shndx[idx] == 0)
    return pipeline_elf_default_reloc_shndx();
  return g_pipeline_elf_label_shndx[idx];
}

static void pipeline_elf_label_shndx_set(uint8_t *ctx_bytes, int32_t idx, int32_t shndx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return;
  g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
  g_pipeline_elf_label_shndx[idx] = shndx;
}

static int32_t pipeline_elf_patch_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return PIPELINE_ELF_SHNX_TEXT;
  if (g_pipeline_elf_shndx_sidecar_owner != ctx_bytes || g_pipeline_elf_patch_shndx[idx] == 0)
    return pipeline_elf_default_reloc_shndx();
  return g_pipeline_elf_patch_shndx[idx];
}

static void pipeline_elf_patch_shndx_set(uint8_t *ctx_bytes, int32_t idx, int32_t shndx) {
  if (!ctx_bytes || idx < 0 || idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return;
  g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
  g_pipeline_elf_patch_shndx[idx] = shndx;
}

static void pipeline_elf_reloc_shndx_set(uint8_t *ctx_bytes, int32_t idx, int32_t shndx) {
  if (!ctx_bytes || idx < 0)
    return;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP) {
    g_pipeline_elf_shndx_sidecar_owner = ctx_bytes;
    g_pipeline_elf_reloc_shndx[idx] = shndx;
    return;
  }
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
  idx = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (idx >= 0 && idx < PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    g_pipeline_elf_reloc_heap[idx].code_shndx = shndx;
}

/** elf_ctx_reset：绑定 sidecar owner；num_relocs 清零后 heap 槽位可复用。 */
void pipeline_elf_ctx_reloc_sidecar_reset(uint8_t *ctx_bytes) {
  g_pipeline_elf_reloc_sidecar_owner = ctx_bytes;
  pipeline_elf_shndx_sidecar_reset(ctx_bytes);
}

/** 读第 idx 条 reloc 的 code offset（内联或 heap sidecar）。 */
int32_t pipeline_elf_ctx_reloc_offset_at(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return 0;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP)
    return ctx->relocs[idx].offset;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return 0;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return 0;
  return g_pipeline_elf_reloc_heap[hi].offset;
}

/** 读第 idx 条 reloc 的目标段（1=.text，2=.text.hot）。 */
int32_t pipeline_elf_ctx_reloc_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return 1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return PIPELINE_ELF_SHNX_TEXT;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP) {
    if (g_pipeline_elf_shndx_sidecar_owner == ctx_bytes && g_pipeline_elf_reloc_shndx[idx] != 0)
      return g_pipeline_elf_reloc_shndx[idx];
    return pipeline_elf_default_reloc_shndx();
  }
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return PIPELINE_ELF_SHNX_TEXT;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return PIPELINE_ELF_SHNX_TEXT;
  if (g_pipeline_elf_reloc_heap[hi].code_shndx != 0)
    return g_pipeline_elf_reloc_heap[hi].code_shndx;
  return pipeline_elf_default_reloc_shndx();
}

/** 读第 idx 个导出符号的 st_shndx（1=.text，2=.text.hot）。 */
int32_t pipeline_elf_ctx_sym_shndx_at(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes || idx < 0)
    return 1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_syms)
    return PIPELINE_ELF_SHNX_TEXT;
  if (ctx->syms[idx].sym_shndx != 0)
    return ctx->syms[idx].sym_shndx;
  return pipeline_elf_pgo_hot_enabled() ? PIPELINE_ELF_SHNX_TEXT_UNLIKELY : PIPELINE_ELF_SHNX_TEXT;
}

/** 返回 .text 机器码缓冲指针（glue 统一偏移；write_elf_o 须经此读，勿直接用 X code_data[]）。 */
uint8_t *pipeline_elf_ctx_code_data_ptr(uint8_t *ctx_bytes) {
  if (!ctx_bytes)
    return NULL;
  return pipeline_elf_ctx_code_buf(ctx_bytes, PIPELINE_ELF_SHNX_TEXT);
}

/** 向 CodegenOutBuf 追加字节；layout 与 codegen.x 一致。 */
static int32_t pipeline_elf_out_append(struct codegen_CodegenOutBuf *out, const uint8_t *p, int32_t n) {
  int32_t len;
  uint8_t *data;
  int32_t i;
  if (!out || !p || n < 0)
    return -1;
  len = codegen_out_buf_len(out);
  if (len + n > (int32_t)PIPELINE_CODEGEN_OUTBUF_CAP)
    return -1;
  data = (uint8_t *)out;
  for (i = 0; i < n; i++)
    data[len + i] = p[i];
  codegen_out_buf_set_len(out, len + n);
  return 0;
}

/** 第 sym_idx 个符号名在 sym_name_data 中的偏移。 */
static int32_t pipeline_elf_sym_name_off(PipelineElfCtxAccess *ctx, int32_t sym_idx) {
  int32_t off;
  int32_t i;
  off = 0;
  i = 0;
  while (i < sym_idx && i < ctx->num_syms) {
    off = off + ctx->syms[i].name_len;
    i = i + 1;
  }
  return off;
}

/** reloc 目标是否为已定义导出符号（非 UND）。 */
static int32_t pipeline_elf_reloc_is_defined(PipelineElfCtxAccess *ctx, uint8_t *ctx_bytes, int32_t reloc_idx,
                                             uint8_t *rname, int32_t rlen) {
  int32_t m;
  int32_t off;
  uint8_t *sym_pool;
  if (!ctx || !ctx_bytes || !rname || rlen <= 0)
    return 0;
  sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
  for (m = 0; m < ctx->num_syms; m++) {
    off = pipeline_elf_sym_name_off(ctx, m);
    if (ctx->syms[m].name_len == rlen && rlen > 0 &&
        memcmp(sym_pool + off, rname, (size_t)rlen) == 0)
      return 1;
  }
  return 0;
}

/** x86_64 ELF call 重定位类型：本 TU 已定义符号用 PC32；UND 外部（如 libc putchar）须 PLT32 方能 -pie 链接。 */
static int32_t pipeline_elf_call_reloc_type(PipelineElfCtxAccess *ctx, uint8_t *ctx_bytes, int32_t reloc_idx,
                                            uint8_t *rname, int32_t rlen) {
  if (!ctx)
    return 2;
  if (ctx->e_machine == 62 && !pipeline_elf_reloc_is_defined(ctx, ctx_bytes, reloc_idx, rname, rlen))
    return 4; /* R_X86_64_PLT32 */
  return ctx->reloc_type_r_pc32;
}

#define PIPELINE_ELF_UNDEF_SYM_CAP 256

/** 向 ELF64 Rela 条目 bytes[16..23] 写入 signed 64-bit r_addend（须全 8 字节符号扩展，勿只写低 32 位）。 */
static void pipeline_elf_rela_set_addend64(uint8_t *rela_buf, int64_t addend) {
  rela_buf[16] = (uint8_t)(addend & 255);
  rela_buf[17] = (uint8_t)((addend >> 8) & 255);
  rela_buf[18] = (uint8_t)((addend >> 16) & 255);
  rela_buf[19] = (uint8_t)((addend >> 24) & 255);
  rela_buf[20] = (uint8_t)((addend >> 32) & 255);
  rela_buf[21] = (uint8_t)((addend >> 40) & 255);
  rela_buf[22] = (uint8_t)((addend >> 48) & 255);
  rela_buf[23] = (uint8_t)((addend >> 56) & 255);
}

/**
 * 标准单 .text ELF64 ET_REL .o 写出（非 PGO）；从 glue code_data 偏移读机器码。
 * 替代 seed partial 内 write_elf_o_to_buf 对 X code_data[] 的错误偏移读（导致 __text 全零）。
 */
int32_t pipeline_elf_write_o_standard_to_buf_c(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  PipelineElfCtxAccess *ctx;
  uint8_t *code;
  int32_t code_len;
  int32_t strtab_off;
  int32_t num_undef;
  uint8_t undef_names[PIPELINE_ELF_UNDEF_SYM_CAP][64];
  int32_t undef_lens[PIPELINE_ELF_UNDEF_SYM_CAP];
  int32_t strtab_size;
  int32_t symtab_ents;
  int32_t symtab_size;
  int32_t rela_size;
  int32_t align4;
  int32_t off_text;
  int32_t off_strtab;
  int32_t off_shstrtab;
  int32_t off_symtab;
  int32_t off_rela;
  int32_t off_shdr;
  static const uint8_t shstrtab_std[46] = {
      0, '.', 't', 'e', 'x', 't', 0, '.', 's', 'y', 'm', 't', 'a', 'b', 0,
      '.', 's', 't', 'r', 't', 'a', 'b', 0, '.', 's', 'h', 's', 't', 'r', 't', 'a', 'b', 0,
      '.', 'r', 'e', 'l', 'a', '.', 't', 'e', 'x', 't', 0};
  uint8_t ehdr[64];
  uint8_t z0[1];
  int32_t s;
  int32_t r0;
  int32_t r;
  int32_t e_machine;
  int32_t reloc_type;
  uint8_t *sym_pool;

  if (!ctx_bytes || !out)
    return -1;
  if (pipeline_elf_pgo_hot_enabled())
    return pipeline_elf_write_o_pgo_to_buf(ctx_bytes, out);
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  code = pipeline_elf_ctx_code_data_ptr(ctx_bytes);
  code_len = ctx->code_len;
  e_machine = ctx->e_machine;
  reloc_type = ctx->reloc_type_r_pc32;
  num_undef = 0;
  r0 = 0;
  while (r0 < ctx->num_relocs) {
    uint8_t rname[64];
    int32_t rlen;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r0, rname);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r0);
    if (pipeline_elf_reloc_is_defined(ctx, ctx_bytes, r0, rname, rlen) == 0) {
      int32_t u0;
      int32_t dup;
      dup = 0;
      u0 = 0;
      while (u0 < num_undef) {
        if (undef_lens[u0] == rlen && rlen > 0 && memcmp(undef_names[u0], rname, (size_t)rlen) == 0) {
          dup = 1;
          break;
        }
        u0 = u0 + 1;
      }
      if (dup == 0 && num_undef < PIPELINE_ELF_UNDEF_SYM_CAP) {
        if (rlen > 64)
          rlen = 64;
        if (rlen > 0)
          memcpy(undef_names[num_undef], rname, (size_t)rlen);
        undef_lens[num_undef] = rlen;
        num_undef = num_undef + 1;
      }
    }
    r0 = r0 + 1;
  }
  strtab_off = 1;
  s = 0;
  while (s < ctx->num_syms) {
    strtab_off = strtab_off + ctx->syms[s].name_len + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    strtab_off = strtab_off + undef_lens[s] + 1;
    s = s + 1;
  }
  strtab_size = strtab_off;
  symtab_ents = 1 + ctx->num_syms + num_undef;
  symtab_size = symtab_ents * 24;
  rela_size = ctx->num_relocs * 24;
  align4 = (code_len + 3) & ~3;
  off_text = 64;
  off_strtab = off_text + align4;
  off_shstrtab = off_strtab + strtab_size;
  off_symtab = off_shstrtab + 46;
  off_rela = off_symtab + symtab_size;
  off_shdr = off_rela + rela_size;
  memset(ehdr, 0, sizeof(ehdr));
  ehdr[0] = 127;
  ehdr[1] = 69;
  ehdr[2] = 76;
  ehdr[3] = 70;
  ehdr[4] = 2;
  ehdr[5] = 1;
  ehdr[6] = 1;
  ehdr[16] = 1;
  ehdr[18] = (uint8_t)(e_machine & 255);
  ehdr[19] = (uint8_t)((e_machine >> 8) & 255);
  /* ET_REL：e_phoff@32 等为 0；e_ehsize@52=64、e_shentsize@58=64（勿写 ehdr[32]=64 误作 phoff）。 */
  ehdr[40] = (uint8_t)(off_shdr & 255);
  ehdr[41] = (uint8_t)((off_shdr >> 8) & 255);
  ehdr[42] = (uint8_t)((off_shdr >> 16) & 255);
  ehdr[43] = (uint8_t)((off_shdr >> 24) & 255);
  ehdr[52] = 64;
  ehdr[58] = 64;
  ehdr[60] = 6;
  ehdr[62] = 4;
  codegen_out_buf_set_len(out, 0);
  if (pipeline_elf_out_append(out, ehdr, 64) != 0)
    return -1;
  if (code_len > 0 && code && pipeline_elf_out_append(out, code, code_len) != 0)
    return -1;
  z0[0] = 0;
  s = code_len;
  while (s < align4) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (pipeline_elf_out_append(out, z0, 1) != 0)
    return -1;
  sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
  s = 0;
  while (s < ctx->num_syms) {
    int32_t nlen;
    nlen = ctx->syms[s].name_len;
    if (nlen > 0 && pipeline_elf_out_append(out, sym_pool + pipeline_elf_sym_name_off(ctx, s), nlen) != 0)
      return -1;
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    if (undef_lens[s] > 0 && pipeline_elf_out_append(out, undef_names[s], undef_lens[s]) != 0)
      return -1;
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (pipeline_elf_out_append(out, shstrtab_std, 46) != 0)
    return -1;
  {
    uint8_t sym_sect[24];
    memset(sym_sect, 0, sizeof(sym_sect));
    sym_sect[4] = 3;
    sym_sect[6] = 1;
    sym_sect[8] = (uint8_t)(code_len & 255);
    sym_sect[9] = (uint8_t)((code_len >> 8) & 255);
    sym_sect[10] = (uint8_t)((code_len >> 16) & 255);
    sym_sect[11] = (uint8_t)((code_len >> 24) & 255);
    if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
      return -1;
  }
  {
    int32_t str_off;
    str_off = 1;
    s = 0;
    while (s < ctx->num_syms) {
      uint8_t ent[24];
      memset(ent, 0, sizeof(ent));
      ent[4] = 18;
      ent[6] = 1;
      ent[0] = (uint8_t)(str_off & 255);
      ent[1] = (uint8_t)((str_off >> 8) & 255);
      ent[2] = (uint8_t)((str_off >> 16) & 255);
      ent[3] = (uint8_t)((str_off >> 24) & 255);
      ent[8] = (uint8_t)(ctx->syms[s].offset & 255);
      ent[9] = (uint8_t)((ctx->syms[s].offset >> 8) & 255);
      ent[10] = (uint8_t)((ctx->syms[s].offset >> 16) & 255);
      ent[11] = (uint8_t)((ctx->syms[s].offset >> 24) & 255);
      if (pipeline_elf_out_append(out, ent, 24) != 0)
        return -1;
      str_off = str_off + ctx->syms[s].name_len + 1;
      s = s + 1;
    }
    s = 0;
    while (s < num_undef) {
      uint8_t uent[24];
      memset(uent, 0, sizeof(uent));
      uent[4] = 18;
      uent[0] = (uint8_t)(str_off & 255);
      uent[1] = (uint8_t)((str_off >> 8) & 255);
      uent[2] = (uint8_t)((str_off >> 16) & 255);
      uent[3] = (uint8_t)((str_off >> 24) & 255);
      if (pipeline_elf_out_append(out, uent, 24) != 0)
        return -1;
      str_off = str_off + undef_lens[s] + 1;
      s = s + 1;
    }
  }
  r = 0;
  while (r < ctx->num_relocs) {
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t r_sym_buf[64];
    int32_t rlen;
    uint8_t rela_buf[24];
    int32_t roff;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    sym_idx = 0;
    m = 0;
    while (m < ctx->num_syms) {
      int32_t off;
      off = pipeline_elf_sym_name_off(ctx, m);
      if (ctx->syms[m].name_len == rlen && rlen > 0 &&
          memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
        sym_idx = m + 1;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      u = 0;
      while (u < num_undef) {
        if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = ctx->num_syms + 1 + u;
          break;
        }
        u = u + 1;
      }
    }
    memset(rela_buf, 0, sizeof(rela_buf));
    pipeline_elf_rela_set_addend64(rela_buf, -4);
    roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    rela_buf[0] = (uint8_t)(roff & 255);
    rela_buf[1] = (uint8_t)((roff >> 8) & 255);
    rela_buf[2] = (uint8_t)((roff >> 16) & 255);
    rela_buf[3] = (uint8_t)((roff >> 24) & 255);
    {
      int32_t rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
    }
    rela_buf[12] = (uint8_t)(sym_idx & 255);
    rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
    rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
    rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
    if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
      return -1;
    r = r + 1;
  }
  {
    uint8_t shdr0[64];
    uint8_t shdr_text[64];
    uint8_t shdr_sym[64];
    uint8_t shdr_str[64];
    uint8_t shdr_shstr[64];
    uint8_t shdr_rela[64];
    memset(shdr0, 0, sizeof(shdr0));
    if (pipeline_elf_out_append(out, shdr0, 64) != 0)
      return -1;
    memset(shdr_text, 0, sizeof(shdr_text));
    shdr_text[0] = 1;
    shdr_text[4] = 1;
    shdr_text[8] = 6;
    shdr_text[24] = (uint8_t)(off_text & 255);
    shdr_text[25] = (uint8_t)((off_text >> 8) & 255);
    shdr_text[26] = (uint8_t)((off_text >> 16) & 255);
    shdr_text[27] = (uint8_t)((off_text >> 24) & 255);
    shdr_text[32] = (uint8_t)(code_len & 255);
    shdr_text[33] = (uint8_t)((code_len >> 8) & 255);
    shdr_text[34] = (uint8_t)((code_len >> 16) & 255);
    shdr_text[35] = (uint8_t)((code_len >> 24) & 255);
    if (pipeline_elf_out_append(out, shdr_text, 64) != 0)
      return -1;
    memset(shdr_sym, 0, sizeof(shdr_sym));
    shdr_sym[0] = 8;
    shdr_sym[4] = 2;
    shdr_sym[24] = (uint8_t)(off_symtab & 255);
    shdr_sym[25] = (uint8_t)((off_symtab >> 8) & 255);
    shdr_sym[26] = (uint8_t)((off_symtab >> 16) & 255);
    shdr_sym[27] = (uint8_t)((off_symtab >> 24) & 255);
    shdr_sym[32] = (uint8_t)(symtab_size & 255);
    shdr_sym[33] = (uint8_t)((symtab_size >> 8) & 255);
    shdr_sym[34] = (uint8_t)((symtab_size >> 16) & 255);
    shdr_sym[35] = (uint8_t)((symtab_size >> 24) & 255);
    shdr_sym[40] = 3;
    shdr_sym[44] = 1;
    shdr_sym[56] = 24;
    if (pipeline_elf_out_append(out, shdr_sym, 64) != 0)
      return -1;
    memset(shdr_str, 0, sizeof(shdr_str));
    shdr_str[0] = 16;
    shdr_str[4] = 3;
    shdr_str[24] = (uint8_t)(off_strtab & 255);
    shdr_str[25] = (uint8_t)((off_strtab >> 8) & 255);
    shdr_str[26] = (uint8_t)((off_strtab >> 16) & 255);
    shdr_str[27] = (uint8_t)((off_strtab >> 24) & 255);
    shdr_str[32] = (uint8_t)(strtab_size & 255);
    shdr_str[33] = (uint8_t)((strtab_size >> 8) & 255);
    shdr_str[34] = (uint8_t)((strtab_size >> 16) & 255);
    shdr_str[35] = (uint8_t)((strtab_size >> 24) & 255);
    shdr_str[48] = 1;
    if (pipeline_elf_out_append(out, shdr_str, 64) != 0)
      return -1;
    memset(shdr_shstr, 0, sizeof(shdr_shstr));
    shdr_shstr[0] = 24;
    shdr_shstr[4] = 3;
    shdr_shstr[24] = (uint8_t)(off_shstrtab & 255);
    shdr_shstr[25] = (uint8_t)((off_shstrtab >> 8) & 255);
    shdr_shstr[26] = (uint8_t)((off_shstrtab >> 16) & 255);
    shdr_shstr[27] = (uint8_t)((off_shstrtab >> 24) & 255);
    shdr_shstr[32] = 46;
    shdr_shstr[48] = 1;
    if (pipeline_elf_out_append(out, shdr_shstr, 64) != 0)
      return -1;
    memset(shdr_rela, 0, sizeof(shdr_rela));
    shdr_rela[0] = 34;
    shdr_rela[4] = 4;
    shdr_rela[8] = 2;
    shdr_rela[16] = 64;
    shdr_rela[24] = (uint8_t)(off_rela & 255);
    shdr_rela[25] = (uint8_t)((off_rela >> 8) & 255);
    shdr_rela[26] = (uint8_t)((off_rela >> 16) & 255);
    shdr_rela[27] = (uint8_t)((off_rela >> 24) & 255);
    shdr_rela[32] = (uint8_t)(rela_size & 255);
    shdr_rela[33] = (uint8_t)((rela_size >> 8) & 255);
    shdr_rela[34] = (uint8_t)((rela_size >> 16) & 255);
    shdr_rela[35] = (uint8_t)((rela_size >> 24) & 255);
    shdr_rela[40] = 2;
    shdr_rela[44] = 1;
    shdr_rela[56] = 24;
    if (pipeline_elf_out_append(out, shdr_rela, 64) != 0)
      return -1;
  }
  return codegen_out_buf_len(out);
}

/**
 * PGO-Lite：写出 .text（空）/ .text.hot / .text.unlikely 三代码段 ELF64 ET_REL .o。
 * code_data→unlikely，code_hot_data→hot；冷/热/空 rela 分表。
 */
int32_t pipeline_elf_write_o_pgo_to_buf(uint8_t *ctx_bytes, struct codegen_CodegenOutBuf *out) {
  PipelineElfCtxAccess *ctx;
  uint8_t *unlikely;
  uint8_t *hot;
  int32_t code_unlikely_len;
  int32_t code_hot_len;
  int32_t strtab_off;
  int32_t strtab_size;
  int32_t num_undef;
  uint8_t undef_names[32][64];
  int32_t undef_lens[32];
  int32_t num_text_rela;
  int32_t num_hot_rela;
  int32_t num_unlikely_rela;
  int32_t symtab_ents;
  int32_t symtab_size;
  int32_t align_hot;
  int32_t align_unlikely;
  int32_t off_text;
  int32_t off_hot;
  int32_t off_unlikely;
  int32_t off_strtab;
  int32_t off_shstrtab;
  int32_t off_symtab;
  int32_t off_rela_text;
  int32_t off_rela_hot;
  int32_t off_rela_unlikely;
  int32_t off_shdr;
  /** shstrtab：.text / .text.hot / .text.unlikely / symtab / strtab / shstrtab / rela×3 */
  static const uint8_t shstrtab_pgo[107] = {
      0,
      46, 116, 101, 120, 116, 0,
      46, 116, 101, 120, 116, 46, 104, 111, 116, 0,
      46, 116, 101, 120, 116, 46, 117, 110, 108, 105, 107, 101, 108, 121, 0,
      46, 115, 121, 109, 116, 97, 98, 0,
      46, 115, 116, 114, 116, 97, 98, 0,
      46, 115, 104, 115, 116, 114, 116, 97, 98, 0,
      46, 114, 101, 108, 97, 46, 116, 101, 120, 116, 0,
      46, 114, 101, 108, 97, 46, 116, 101, 120, 116, 46, 104, 111, 116, 0,
      46, 114, 101, 108, 97, 46, 116, 101, 120, 116, 46, 117, 110, 108, 105, 107, 101, 108, 121, 0};
  uint8_t ehdr[64];
  uint8_t z0[1];
  int32_t s;
  int32_t r0;
  int32_t r;
  int32_t e_machine;
  int32_t reloc_type;
  if (!ctx_bytes || !out)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  unlikely = ctx_bytes + kPipelineElfCtxCodeDataOff;
  hot = ctx_bytes + kPipelineElfCtxCodeHotDataOff;
  code_unlikely_len = ctx->code_len;
  code_hot_len = ctx->code_hot_len;
  e_machine = ctx->e_machine;
  reloc_type = ctx->reloc_type_r_pc32;
  num_undef = 0;
  num_text_rela = 0;
  num_hot_rela = 0;
  num_unlikely_rela = 0;
  r0 = 0;
  while (r0 < ctx->num_relocs) {
    uint8_t rname[64];
    int32_t rlen;
    int32_t rsh;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r0, rname);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r0);
    if (pipeline_elf_reloc_is_defined(ctx, ctx_bytes, r0, rname, rlen) == 0) {
      int32_t u0;
      int32_t dup;
      dup = 0;
      u0 = 0;
      while (u0 < num_undef) {
        if (undef_lens[u0] == rlen && rlen > 0 && memcmp(undef_names[u0], rname, (size_t)rlen) == 0) {
          dup = 1;
          break;
        }
        u0 = u0 + 1;
      }
      if (dup == 0 && num_undef < 32) {
        if (rlen > 64)
          rlen = 64;
        if (rlen > 0)
          memcpy(undef_names[num_undef], rname, (size_t)rlen);
        undef_lens[num_undef] = rlen;
        num_undef = num_undef + 1;
      }
    }
    rsh = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r0);
    if (rsh == PIPELINE_ELF_SHNX_TEXT_HOT)
      num_hot_rela = num_hot_rela + 1;
    else if (rsh == PIPELINE_ELF_SHNX_TEXT_UNLIKELY)
      num_unlikely_rela = num_unlikely_rela + 1;
    else
      num_text_rela = num_text_rela + 1;
    r0 = r0 + 1;
  }
  strtab_off = 1;
  s = 0;
  while (s < ctx->num_syms) {
    strtab_off = strtab_off + ctx->syms[s].name_len + 1;
    s = s + 1;
  }
  s = 0;
  while (s < num_undef) {
    strtab_off = strtab_off + undef_lens[s] + 1;
    s = s + 1;
  }
  strtab_size = strtab_off;
  symtab_ents = 3 + ctx->num_syms + num_undef;
  symtab_size = symtab_ents * 24;
  align_hot = (code_hot_len + 3) & ~3;
  align_unlikely = (code_unlikely_len + 3) & ~3;
  off_text = 64;
  off_hot = off_text;
  off_unlikely = off_hot + align_hot;
  off_strtab = off_unlikely + align_unlikely;
  off_shstrtab = off_strtab + strtab_size;
  off_symtab = off_shstrtab + 107;
  off_rela_text = off_symtab + symtab_size;
  off_rela_hot = off_rela_text + num_text_rela * 24;
  off_rela_unlikely = off_rela_hot + num_hot_rela * 24;
  off_shdr = off_rela_unlikely + num_unlikely_rela * 24;
  memset(ehdr, 0, sizeof(ehdr));
  ehdr[0] = 127;
  ehdr[1] = 69;
  ehdr[2] = 76;
  ehdr[3] = 70;
  ehdr[4] = 2;
  ehdr[5] = 1;
  ehdr[6] = 1;
  ehdr[16] = 1;
  ehdr[18] = (uint8_t)(e_machine & 255);
  ehdr[19] = (uint8_t)((e_machine >> 8) & 255);
  /* ET_REL PGO：e_phoff@32 等为 0（同 pipeline_elf_write_o_standard_to_buf_c）。 */
  ehdr[40] = (uint8_t)(off_shdr & 255);
  ehdr[41] = (uint8_t)((off_shdr >> 8) & 255);
  ehdr[42] = (uint8_t)((off_shdr >> 16) & 255);
  ehdr[43] = (uint8_t)((off_shdr >> 24) & 255);
  ehdr[52] = 64;
  ehdr[58] = 64;
  ehdr[60] = 10;
  ehdr[62] = 6;
  codegen_out_buf_set_len(out, 0);
  if (pipeline_elf_out_append(out, ehdr, 64) != 0)
    return -1;
  if (code_hot_len > 0 && pipeline_elf_out_append(out, hot, code_hot_len) != 0)
    return -1;
  z0[0] = 0;
  s = code_hot_len;
  while (s < align_hot) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (code_unlikely_len > 0 && pipeline_elf_out_append(out, unlikely, code_unlikely_len) != 0)
    return -1;
  s = code_unlikely_len;
  while (s < align_unlikely) {
    if (pipeline_elf_out_append(out, z0, 1) != 0)
      return -1;
    s = s + 1;
  }
  if (pipeline_elf_out_append(out, z0, 1) != 0)
    return -1;
  {
    uint8_t *sym_pool;
    int32_t str_off;
    sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
    s = 0;
    while (s < ctx->num_syms) {
      int32_t nlen;
      nlen = ctx->syms[s].name_len;
      if (nlen > 0 && pipeline_elf_out_append(out, sym_pool + pipeline_elf_sym_name_off(ctx, s), nlen) != 0)
        return -1;
      if (pipeline_elf_out_append(out, z0, 1) != 0)
        return -1;
      s = s + 1;
    }
    s = 0;
    while (s < num_undef) {
      if (undef_lens[s] > 0 && pipeline_elf_out_append(out, undef_names[s], undef_lens[s]) != 0)
        return -1;
      if (pipeline_elf_out_append(out, z0, 1) != 0)
        return -1;
      s = s + 1;
    }
    if (pipeline_elf_out_append(out, shstrtab_pgo, 107) != 0)
      return -1;
    {
      uint8_t sym_sect[24];
      memset(sym_sect, 0, sizeof(sym_sect));
      sym_sect[4] = 3;
      sym_sect[6] = PIPELINE_ELF_SHNX_TEXT;
      if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
        return -1;
      sym_sect[6] = PIPELINE_ELF_SHNX_TEXT_HOT;
      sym_sect[8] = (uint8_t)(code_hot_len & 255);
      sym_sect[9] = (uint8_t)((code_hot_len >> 8) & 255);
      sym_sect[10] = (uint8_t)((code_hot_len >> 16) & 255);
      sym_sect[11] = (uint8_t)((code_hot_len >> 24) & 255);
      if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
        return -1;
      sym_sect[6] = PIPELINE_ELF_SHNX_TEXT_UNLIKELY;
      sym_sect[8] = (uint8_t)(code_unlikely_len & 255);
      sym_sect[9] = (uint8_t)((code_unlikely_len >> 8) & 255);
      sym_sect[10] = (uint8_t)((code_unlikely_len >> 16) & 255);
      sym_sect[11] = (uint8_t)((code_unlikely_len >> 24) & 255);
      if (pipeline_elf_out_append(out, sym_sect, 24) != 0)
        return -1;
    }
    str_off = 1;
    s = 0;
    while (s < ctx->num_syms) {
      uint8_t ent[24];
      int32_t shndx;
      memset(ent, 0, sizeof(ent));
      shndx = pipeline_elf_ctx_sym_shndx_at(ctx_bytes, s);
      ent[0] = (uint8_t)(str_off & 255);
      ent[1] = (uint8_t)((str_off >> 8) & 255);
      ent[2] = (uint8_t)((str_off >> 16) & 255);
      ent[3] = (uint8_t)((str_off >> 24) & 255);
      ent[4] = 18;
      ent[6] = (uint8_t)(shndx & 255);
      ent[7] = (uint8_t)((shndx >> 8) & 255);
      ent[8] = (uint8_t)(ctx->syms[s].offset & 255);
      ent[9] = (uint8_t)((ctx->syms[s].offset >> 8) & 255);
      ent[10] = (uint8_t)((ctx->syms[s].offset >> 16) & 255);
      ent[11] = (uint8_t)((ctx->syms[s].offset >> 24) & 255);
      if (pipeline_elf_out_append(out, ent, 24) != 0)
        return -1;
      str_off = str_off + ctx->syms[s].name_len + 1;
      s = s + 1;
    }
    s = 0;
    while (s < num_undef) {
      uint8_t uent[24];
      memset(uent, 0, sizeof(uent));
      uent[0] = (uint8_t)(str_off & 255);
      uent[1] = (uint8_t)((str_off >> 8) & 255);
      uent[2] = (uint8_t)((str_off >> 16) & 255);
      uent[3] = (uint8_t)((str_off >> 24) & 255);
      uent[4] = 18;
      if (pipeline_elf_out_append(out, uent, 24) != 0)
        return -1;
      str_off = str_off + undef_lens[s] + 1;
      s = s + 1;
    }
  }
  /** 写出 rela 表（按 shndx 分三段；sym index 含 3 个 STT_SECTION 占位）。 */
  for (r = 0; r < ctx->num_relocs; r++) {
    int32_t want_sh;
    int32_t roff;
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t rela_buf[24];
    uint8_t r_sym_buf[64];
    int32_t rlen;
    want_sh = pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r);
    if (want_sh != PIPELINE_ELF_SHNX_TEXT)
      continue;
    memset(rela_buf, 0, sizeof(rela_buf));
    rela_buf[16] = 252;
    rela_buf[17] = 255;
    rela_buf[18] = 255;
    rela_buf[19] = 255;
    rela_buf[20] = 255;
    rela_buf[21] = 255;
    rela_buf[22] = 255;
    rela_buf[23] = 255;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    sym_idx = 0;
    m = 0;
    while (m < ctx->num_syms) {
      int32_t off;
      uint8_t *sym_pool;
      sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
      off = pipeline_elf_sym_name_off(ctx, m);
      if (ctx->syms[m].name_len == rlen && rlen > 0 && memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
        sym_idx = m + 3;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      u = 0;
      while (u < num_undef) {
        if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = ctx->num_syms + 3 + u;
          break;
        }
        u = u + 1;
      }
    }
    roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    rela_buf[0] = (uint8_t)(roff & 255);
    rela_buf[1] = (uint8_t)((roff >> 8) & 255);
    rela_buf[2] = (uint8_t)((roff >> 16) & 255);
    rela_buf[3] = (uint8_t)((roff >> 24) & 255);
    {
      int32_t rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
    }
    rela_buf[12] = (uint8_t)(sym_idx & 255);
    rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
    rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
    rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
    if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
      return -1;
  }
  for (r = 0; r < ctx->num_relocs; r++) {
    int32_t roff;
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t rela_buf[24];
    uint8_t r_sym_buf[64];
    int32_t rlen;
    if (pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r) != PIPELINE_ELF_SHNX_TEXT_HOT)
      continue;
    memset(rela_buf, 0, sizeof(rela_buf));
    rela_buf[16] = 252;
    rela_buf[17] = 255;
    rela_buf[18] = 255;
    rela_buf[19] = 255;
    rela_buf[20] = 255;
    rela_buf[21] = 255;
    rela_buf[22] = 255;
    rela_buf[23] = 255;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    sym_idx = 0;
    m = 0;
    while (m < ctx->num_syms) {
      int32_t off;
      uint8_t *sym_pool;
      sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
      off = pipeline_elf_sym_name_off(ctx, m);
      if (ctx->syms[m].name_len == rlen && rlen > 0 && memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
        sym_idx = m + 3;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      u = 0;
      while (u < num_undef) {
        if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = ctx->num_syms + 3 + u;
          break;
        }
        u = u + 1;
      }
    }
    roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    rela_buf[0] = (uint8_t)(roff & 255);
    rela_buf[1] = (uint8_t)((roff >> 8) & 255);
    rela_buf[2] = (uint8_t)((roff >> 16) & 255);
    rela_buf[3] = (uint8_t)((roff >> 24) & 255);
    {
      int32_t rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
    }
    rela_buf[12] = (uint8_t)(sym_idx & 255);
    rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
    rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
    rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
    if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
      return -1;
  }
  for (r = 0; r < ctx->num_relocs; r++) {
    int32_t roff;
    int32_t sym_idx;
    int32_t m;
    int32_t u;
    uint8_t rela_buf[24];
    uint8_t r_sym_buf[64];
    int32_t rlen;
    if (pipeline_elf_ctx_reloc_shndx_at(ctx_bytes, r) != PIPELINE_ELF_SHNX_TEXT_UNLIKELY)
      continue;
    memset(rela_buf, 0, sizeof(rela_buf));
    rela_buf[16] = 252;
    rela_buf[17] = 255;
    rela_buf[18] = 255;
    rela_buf[19] = 255;
    rela_buf[20] = 255;
    rela_buf[21] = 255;
    rela_buf[22] = 255;
    rela_buf[23] = 255;
    pipeline_elf_ctx_reloc_sym_name_copy64(ctx_bytes, r, r_sym_buf);
    rlen = pipeline_elf_ctx_reloc_name_len(ctx_bytes, r);
    sym_idx = 0;
    m = 0;
    while (m < ctx->num_syms) {
      int32_t off;
      uint8_t *sym_pool;
      sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
      off = pipeline_elf_sym_name_off(ctx, m);
      if (ctx->syms[m].name_len == rlen && rlen > 0 && memcmp(sym_pool + off, r_sym_buf, (size_t)rlen) == 0) {
        sym_idx = m + 3;
        break;
      }
      m = m + 1;
    }
    if (sym_idx == 0) {
      u = 0;
      while (u < num_undef) {
        if (undef_lens[u] == rlen && rlen > 0 && memcmp(undef_names[u], r_sym_buf, (size_t)rlen) == 0) {
          sym_idx = ctx->num_syms + 3 + u;
          break;
        }
        u = u + 1;
      }
    }
    roff = pipeline_elf_ctx_reloc_offset_at(ctx_bytes, r);
    rela_buf[0] = (uint8_t)(roff & 255);
    rela_buf[1] = (uint8_t)((roff >> 8) & 255);
    rela_buf[2] = (uint8_t)((roff >> 16) & 255);
    rela_buf[3] = (uint8_t)((roff >> 24) & 255);
    {
      int32_t rtype = pipeline_elf_call_reloc_type(ctx, ctx_bytes, r, r_sym_buf, rlen);
      rela_buf[8] = (uint8_t)(rtype & 255);
      rela_buf[9] = (uint8_t)((rtype >> 8) & 255);
      rela_buf[10] = (uint8_t)((rtype >> 16) & 255);
      rela_buf[11] = (uint8_t)((rtype >> 24) & 255);
    }
    rela_buf[12] = (uint8_t)(sym_idx & 255);
    rela_buf[13] = (uint8_t)((sym_idx >> 8) & 255);
    rela_buf[14] = (uint8_t)((sym_idx >> 16) & 255);
    rela_buf[15] = (uint8_t)((sym_idx >> 24) & 255);
    if (pipeline_elf_out_append(out, rela_buf, 24) != 0)
      return -1;
  }
  {
    uint8_t shdr0[64];
    uint8_t shdr_text[64];
    uint8_t shdr_hot[64];
    uint8_t shdr_unlikely[64];
    uint8_t shdr_sym[64];
    uint8_t shdr_str[64];
    uint8_t shdr_shstr[64];
    uint8_t shdr_rela_text[64];
    uint8_t shdr_rela_hot[64];
    uint8_t shdr_rela_unlikely[64];
    memset(shdr0, 0, sizeof(shdr0));
    memset(shdr_text, 0, sizeof(shdr_text));
    memset(shdr_hot, 0, sizeof(shdr_hot));
    memset(shdr_unlikely, 0, sizeof(shdr_unlikely));
    memset(shdr_sym, 0, sizeof(shdr_sym));
    memset(shdr_str, 0, sizeof(shdr_str));
    memset(shdr_shstr, 0, sizeof(shdr_shstr));
    memset(shdr_rela_text, 0, sizeof(shdr_rela_text));
    memset(shdr_rela_hot, 0, sizeof(shdr_rela_hot));
    memset(shdr_rela_unlikely, 0, sizeof(shdr_rela_unlikely));
    shdr_text[0] = 1;
    shdr_text[4] = 1;
    shdr_text[8] = 6;
    shdr_text[24] = (uint8_t)(off_text & 255);
    shdr_text[25] = (uint8_t)((off_text >> 8) & 255);
    shdr_text[26] = (uint8_t)((off_text >> 16) & 255);
    shdr_text[27] = (uint8_t)((off_text >> 24) & 255);
    shdr_hot[0] = 7;
    shdr_hot[4] = 1;
    shdr_hot[8] = 6;
    shdr_hot[24] = (uint8_t)(off_hot & 255);
    shdr_hot[25] = (uint8_t)((off_hot >> 8) & 255);
    shdr_hot[26] = (uint8_t)((off_hot >> 16) & 255);
    shdr_hot[27] = (uint8_t)((off_hot >> 24) & 255);
    shdr_hot[32] = (uint8_t)(code_hot_len & 255);
    shdr_hot[33] = (uint8_t)((code_hot_len >> 8) & 255);
    shdr_hot[34] = (uint8_t)((code_hot_len >> 16) & 255);
    shdr_hot[35] = (uint8_t)((code_hot_len >> 24) & 255);
    shdr_unlikely[0] = 17;
    shdr_unlikely[4] = 1;
    shdr_unlikely[8] = 6;
    shdr_unlikely[24] = (uint8_t)(off_unlikely & 255);
    shdr_unlikely[25] = (uint8_t)((off_unlikely >> 8) & 255);
    shdr_unlikely[26] = (uint8_t)((off_unlikely >> 16) & 255);
    shdr_unlikely[27] = (uint8_t)((off_unlikely >> 24) & 255);
    shdr_unlikely[32] = (uint8_t)(code_unlikely_len & 255);
    shdr_unlikely[33] = (uint8_t)((code_unlikely_len >> 8) & 255);
    shdr_unlikely[34] = (uint8_t)((code_unlikely_len >> 16) & 255);
    shdr_unlikely[35] = (uint8_t)((code_unlikely_len >> 24) & 255);
    shdr_sym[0] = 32;
    shdr_sym[4] = 2;
    shdr_sym[24] = (uint8_t)(off_symtab & 255);
    shdr_sym[25] = (uint8_t)((off_symtab >> 8) & 255);
    shdr_sym[26] = (uint8_t)((off_symtab >> 16) & 255);
    shdr_sym[27] = (uint8_t)((off_symtab >> 24) & 255);
    shdr_sym[32] = (uint8_t)(symtab_size & 255);
    shdr_sym[33] = (uint8_t)((symtab_size >> 8) & 255);
    shdr_sym[34] = (uint8_t)((symtab_size >> 16) & 255);
    shdr_sym[35] = (uint8_t)((symtab_size >> 24) & 255);
    shdr_sym[40] = 5;
    shdr_sym[44] = 1;
    shdr_sym[56] = 24;
    shdr_str[0] = 40;
    shdr_str[4] = 3;
    shdr_str[24] = (uint8_t)(off_strtab & 255);
    shdr_str[25] = (uint8_t)((off_strtab >> 8) & 255);
    shdr_str[26] = (uint8_t)((off_strtab >> 16) & 255);
    shdr_str[27] = (uint8_t)((off_strtab >> 24) & 255);
    shdr_str[32] = (uint8_t)(strtab_size & 255);
    shdr_str[33] = (uint8_t)((strtab_size >> 8) & 255);
    shdr_str[34] = (uint8_t)((strtab_size >> 16) & 255);
    shdr_str[35] = (uint8_t)((strtab_size >> 24) & 255);
    shdr_str[48] = 1;
    shdr_shstr[0] = 48;
    shdr_shstr[4] = 3;
    shdr_shstr[24] = (uint8_t)(off_shstrtab & 255);
    shdr_shstr[25] = (uint8_t)((off_shstrtab >> 8) & 255);
    shdr_shstr[26] = (uint8_t)((off_shstrtab >> 16) & 255);
    shdr_shstr[27] = (uint8_t)((off_shstrtab >> 24) & 255);
    shdr_shstr[32] = 107;
    shdr_shstr[48] = 1;
    shdr_rela_text[0] = 58;
    shdr_rela_text[4] = 4;
    shdr_rela_text[24] = (uint8_t)(off_rela_text & 255);
    shdr_rela_text[25] = (uint8_t)((off_rela_text >> 8) & 255);
    shdr_rela_text[26] = (uint8_t)((off_rela_text >> 16) & 255);
    shdr_rela_text[27] = (uint8_t)((off_rela_text >> 24) & 255);
    shdr_rela_text[32] = (uint8_t)((num_text_rela * 24) & 255);
    shdr_rela_text[33] = (uint8_t)(((num_text_rela * 24) >> 8) & 255);
    shdr_rela_text[34] = (uint8_t)(((num_text_rela * 24) >> 16) & 255);
    shdr_rela_text[35] = (uint8_t)(((num_text_rela * 24) >> 24) & 255);
    shdr_rela_text[40] = 4;
    shdr_rela_text[44] = 1;
    shdr_rela_text[56] = 24;
    shdr_rela_hot[0] = 71;
    shdr_rela_hot[4] = 4;
    shdr_rela_hot[24] = (uint8_t)(off_rela_hot & 255);
    shdr_rela_hot[25] = (uint8_t)((off_rela_hot >> 8) & 255);
    shdr_rela_hot[26] = (uint8_t)((off_rela_hot >> 16) & 255);
    shdr_rela_hot[27] = (uint8_t)((off_rela_hot >> 24) & 255);
    shdr_rela_hot[32] = (uint8_t)((num_hot_rela * 24) & 255);
    shdr_rela_hot[33] = (uint8_t)(((num_hot_rela * 24) >> 8) & 255);
    shdr_rela_hot[34] = (uint8_t)(((num_hot_rela * 24) >> 16) & 255);
    shdr_rela_hot[35] = (uint8_t)(((num_hot_rela * 24) >> 24) & 255);
    shdr_rela_hot[40] = 4;
    shdr_rela_hot[44] = 2;
    shdr_rela_hot[56] = 24;
    shdr_rela_unlikely[0] = 86;
    shdr_rela_unlikely[4] = 4;
    shdr_rela_unlikely[24] = (uint8_t)(off_rela_unlikely & 255);
    shdr_rela_unlikely[25] = (uint8_t)((off_rela_unlikely >> 8) & 255);
    shdr_rela_unlikely[26] = (uint8_t)((off_rela_unlikely >> 16) & 255);
    shdr_rela_unlikely[27] = (uint8_t)((off_rela_unlikely >> 24) & 255);
    shdr_rela_unlikely[32] = (uint8_t)((num_unlikely_rela * 24) & 255);
    shdr_rela_unlikely[33] = (uint8_t)(((num_unlikely_rela * 24) >> 8) & 255);
    shdr_rela_unlikely[34] = (uint8_t)(((num_unlikely_rela * 24) >> 16) & 255);
    shdr_rela_unlikely[35] = (uint8_t)(((num_unlikely_rela * 24) >> 24) & 255);
    shdr_rela_unlikely[40] = 4;
    shdr_rela_unlikely[44] = 3;
    shdr_rela_unlikely[56] = 24;
    if (pipeline_elf_out_append(out, shdr0, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_text, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_hot, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_unlikely, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_sym, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_str, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_shstr, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_rela_text, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_rela_hot, 64) != 0)
      return -1;
    if (pipeline_elf_out_append(out, shdr_rela_unlikely, 64) != 0)
      return -1;
  }
  return codegen_out_buf_len(out);
}

/** 写第 idx 条 reloc 的 code offset（内联或 heap sidecar）。 */
void pipeline_elf_ctx_reloc_offset_set(uint8_t *ctx_bytes, int32_t idx, int32_t offset) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP) {
    ctx->relocs[idx].offset = offset;
    return;
  }
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return;
  g_pipeline_elf_reloc_heap[hi].offset = offset;
}

struct platform_elf_ElfCodegenCtx;

/**
 * 多 Module 顺序写入同一 ElfCodegenCtx 时，为 `.Lf<scope>_<n>` 提供跨 Module 唯一 scope。
 * 每 Module 占 256 个 func 槽；elf_ctx_reset 时清零。
 */
static int32_t g_pipeline_elf_label_mod_scope_base;

void pipeline_elf_label_mod_scope_reset(void) {
  g_pipeline_elf_label_mod_scope_base = 0;
}

int32_t pipeline_elf_label_mod_scope_next_module(void) {
  int32_t base = g_pipeline_elf_label_mod_scope_base;
  g_pipeline_elf_label_mod_scope_base = g_pipeline_elf_label_mod_scope_base + 256;
  return base;
}

/** 当前 Module 写入共享 ElfCodegenCtx 时的标签 scope（与 pipeline_asm_emit_next_label_c 对齐）。 */
static int32_t g_pipeline_elf_label_mod_scope_active;

/**
 * 每个 Module 开始 asm_codegen_ast_to_elf 前调用一次，避免多 Module 共用 elf_ctx 时 `.L_0` 标签名碰撞。
 */
void pipeline_elf_label_mod_scope_begin_module(void) {
  g_pipeline_elf_label_mod_scope_active = pipeline_elf_label_mod_scope_next_module();
}

/** 返回当前 emit 模块的 ELF 局部标签 scope。 */
int32_t pipeline_elf_label_mod_scope_active(void) {
  return g_pipeline_elf_label_mod_scope_active;
}

/** 追加或更新局部标签；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_add_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset) {
  PipelineElfCtxAccess *ctx;
  int32_t l;
  int32_t li;
  int32_t n;
  int32_t shndx;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  shndx = pipeline_elf_ctx_current_shndx(ctx);
  l = 0;
  while (l < ctx->num_labels) {
    if (ctx->labels[l].name_len == name_len && name_len > 0 &&
        memcmp(ctx->labels[l].name, name, (size_t)name_len) == 0) {
      ctx->labels[l].offset = offset;
      pipeline_elf_label_shndx_set(ctx_bytes, l, shndx);
      return 0;
    }
    l = l + 1;
  }
  if (ctx->num_labels >= PIPELINE_ELF_CTX_TABLE_CAP)
    return -1;
  li = ctx->num_labels;
  n = name_len > 64 ? 64 : name_len;
  if (n > 0)
    memcpy(ctx->labels[li].name, name, (size_t)n);
  ctx->labels[li].name_len = name_len;
  ctx->labels[li].offset = offset;
  pipeline_elf_label_shndx_set(ctx_bytes, li, shndx);
  ctx->num_labels = ctx->num_labels + 1;
  return 0;
}

/** 前向跳转占位标签（offset=-1）；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_ensure_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len) {
  PipelineElfCtxAccess *ctx;
  int32_t l;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  l = 0;
  while (l < ctx->num_labels) {
    if (ctx->labels[l].name_len == name_len && name_len > 0 &&
        memcmp(ctx->labels[l].name, name, (size_t)name_len) == 0) {
      return 0;
    }
    l = l + 1;
  }
  return pipeline_elf_ctx_add_label(ctx_bytes, name, name_len, -1);
}

/** Mach-O/ELF 函数入口 4 字节对齐；端口 elf.x elf_pad_code_to_4。 */
int32_t pipeline_elf_ctx_pad_code_to_4(uint8_t *ctx_bytes) {
  uint8_t pad[1] = {0};
  if (!ctx_bytes)
    return -1;
  while (pipeline_elf_ctx_emit_code_len(ctx_bytes) % 4 != 0) {
    if (pipeline_elf_ctx_append_bytes(ctx_bytes, pad, 1) != 0)
      return -1;
  }
  return 0;
}

/** 记录导出符号；端口 elf.x elf_add_sym。 */
int32_t pipeline_elf_ctx_add_sym(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset) {
  PipelineElfCtxAccess *ctx;
  uint8_t *sym_pool;
  int32_t copy_len;
  int32_t k;
  int32_t shndx;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->num_syms >= PIPELINE_ELF_CTX_TABLE_CAP)
    return -1;
  copy_len = name_len;
  if (copy_len > 64)
    copy_len = 64;
  if (copy_len < 0)
    copy_len = 0;
  if (ctx->sym_name_len + copy_len > 131072)
    return -1;
  sym_pool = ctx_bytes + kPipelineElfCtxSymNameDataOff;
  k = 0;
  while (k < copy_len) {
    sym_pool[ctx->sym_name_len + k] = name[k];
    k = k + 1;
  }
  ctx->sym_name_len = ctx->sym_name_len + copy_len;
  ctx->syms[ctx->num_syms].name_len = copy_len;
  ctx->syms[ctx->num_syms].offset = offset;
  if (pipeline_elf_pgo_hot_enabled() != 0 && ctx->emit_hot != 0)
    shndx = PIPELINE_ELF_SHNX_TEXT_HOT;
  else if (pipeline_elf_pgo_hot_enabled() != 0)
    shndx = PIPELINE_ELF_SHNX_TEXT_UNLIKELY;
  else
    shndx = PIPELINE_ELF_SHNX_TEXT;
  ctx->syms[ctx->num_syms].sym_shndx = shndx;
  ctx->num_syms = ctx->num_syms + 1;
  return 0;
}

/** 读 ElfCodegenCtx.macho_leading_underscore（Darwin call/reloc 前缀 `_`）。 */
int32_t pipeline_elf_ctx_macho_leading_underscore(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  return ctx->macho_leading_underscore;
}

/** 追加一条 rel32 补丁槽；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_append_patch(uint8_t *ctx_bytes, int32_t rel32_offset, uint8_t *name, int32_t name_len,
                                      int32_t imm_bits) {
  PipelineElfCtxAccess *ctx;
  PipelineElfPatchEntry *ent;
  int32_t pi;
  int32_t n;
  int32_t bits;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->num_patches >= PIPELINE_ELF_CTX_TABLE_CAP) {
    fprintf(stderr, "shux: elf num_patches limit %d reached\n", PIPELINE_ELF_CTX_TABLE_CAP);
    return -1;
  }
  bits = imm_bits;
  /*
   * arm64 enc_jz 应传 imm_bits=19；偶发仍为 0 时 elf_resolve_patches 误走 x86 rel32，
   * 把 cbz 占位 0x34xxxxxx 写成 udf 非法指令（Mach-O 烟测 SIGILL）。
   */
#if defined(__APPLE__) && defined(__aarch64__)
  if (bits == 0)
    bits = 19;
#endif
  pi = ctx->num_patches;
  ent = &ctx->patches[pi];
  ent->rel32_offset = rel32_offset;
  n = name_len > 64 ? 64 : name_len;
  if (n > 0)
    memcpy(ent->name, name, (size_t)n);
  ent->name_len = name_len;
  ent->patch_imm_bits = bits;
  pipeline_elf_patch_shndx_set(ctx_bytes, pi, pipeline_elf_ctx_current_shndx(ctx));
  ctx->num_patches = ctx->num_patches + 1;
  return 0;
}

/** 读取第 patch_idx 条补丁的 imm_bits；越界返回 0。 */
int32_t pipeline_elf_ctx_patch_imm_bits_at(uint8_t *ctx_bytes, int32_t patch_idx) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes || patch_idx < 0 || patch_idx >= PIPELINE_ELF_CTX_TABLE_CAP)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (patch_idx >= ctx->num_patches)
    return 0;
  return ctx->patches[patch_idx].patch_imm_bits;
}

/** 读 ctx 指定段 code 小端 u32；ctx 为完整 ElfCodegenCtx 字节视图。 */
static int32_t pipeline_elf_ctx_read_u32_le(uint8_t *ctx_bytes, int32_t shndx, int32_t off) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  if (!ctx_bytes || off < 0)
    return 0;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (off + 3 >= pipeline_elf_ctx_section_len(acc, shndx))
    return 0;
  code = pipeline_elf_ctx_code_buf(ctx_bytes, shndx);
  return (int32_t)((unsigned)code[off] | ((unsigned)code[off + 1] << 8) | ((unsigned)code[off + 2] << 16) |
                   ((unsigned)code[off + 3] << 24));
}

/** 写 ctx 指定段 code 小端 u32。 */
static void pipeline_elf_ctx_write_u32_le(uint8_t *ctx_bytes, int32_t shndx, int32_t off, int32_t word) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  if (!ctx_bytes || off < 0)
    return;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (off + 3 >= pipeline_elf_ctx_section_len(acc, shndx))
    return;
  code = pipeline_elf_ctx_code_buf(ctx_bytes, shndx);
  code[off] = (uint8_t)(word & 255);
  code[off + 1] = (uint8_t)((word >> 8) & 255);
  code[off + 2] = (uint8_t)((word >> 16) & 255);
  code[off + 3] = (uint8_t)((word >> 24) & 255);
}

/** 从占位指令推断 arm64/riscv patch 位宽；与 platform/elf.x elf_infer_patch_imm_bits_from_code 一致。 */
static int32_t pipeline_elf_ctx_infer_patch_imm_bits(uint8_t *ctx_bytes, int32_t shndx, int32_t rel32_offset) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  int32_t op8;
  if (!ctx_bytes || rel32_offset < 0)
    return 0;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (rel32_offset + 3 >= pipeline_elf_ctx_section_len(acc, shndx))
    return 0;
  code = pipeline_elf_ctx_code_buf(ctx_bytes, shndx);
  op8 = (int32_t)(code[rel32_offset + 3] & 255);
  if (op8 == 52 || op8 == 53 || op8 == 84)
    return 19;
  if (op8 == 20 || op8 == 148)
    return 26;
  if (op8 == 99 || op8 == 103)
    return 13;
  if (op8 == 111)
    return 21;
  return 0;
}

/** 标签名相等比较（pool 固定 64 字节槽）。 */
static int32_t pipeline_elf_ctx_name_eq(const uint8_t *a, int32_t a_len, const uint8_t *b, int32_t b_len) {
  int32_t i;
  if (a_len != b_len)
    return 0;
  i = 0;
  while (i < a_len) {
    if (a[i] != b[i])
      return 0;
    i = i + 1;
  }
  return 1;
}

/**
 * 解析 ctx 内 cbz/b/rel32 补丁（与 append_patch 共用 PipelineElfCtxAccess 视图）。
 * AArch64 分支 PC 相对当前指令；x86 rel32 相对下一条。返回 0 成功，-1 未解析标签。
 */
int32_t pipeline_elf_ctx_resolve_patches(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  int32_t e_machine;
  int32_t p;
  if (!ctx_bytes)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  e_machine = *(int32_t *)(ctx_bytes + kPipelineElfCtxEMachineOff);
  p = 0;
  while (p < ctx->num_patches) {
    PipelineElfPatchEntry *patch;
    int32_t rel32_offset;
    int32_t target_offset;
    int32_t imm_bits;
    int32_t delta;
    int32_t l;
    int32_t patch_shndx;
    int32_t target_shndx;
    patch = &ctx->patches[p];
    rel32_offset = patch->rel32_offset;
    patch_shndx = pipeline_elf_patch_shndx_at(ctx_bytes, p);
    target_offset = -1;
    target_shndx = patch_shndx;
    l = 0;
    while (l < ctx->num_labels) {
      if (pipeline_elf_ctx_name_eq(patch->name, patch->name_len, ctx->labels[l].name, ctx->labels[l].name_len) != 0) {
        target_offset = ctx->labels[l].offset;
        target_shndx = pipeline_elf_label_shndx_at(ctx_bytes, l);
        break;
      }
      l = l + 1;
    }
    if (target_offset < 0) {
      driver_diagnostic_asm_elf_unresolved_patch(patch->name, patch->name_len);
      pipeline_elf_log_unresolved_patch((struct platform_elf_ElfCodegenCtx *)ctx_bytes, p);
      return -1;
    }
    /*
     * PGO 关闭时仅 .text（code_data）；sidecar shndx 偶发与 append 段不一致，但 rel32/label
     * offset 仍同在 code_data — 勿因此误杀 resolve（with_arena_vec / 多 if 烟测）。
     */
    if (patch_shndx != target_shndx) {
      if (!pipeline_elf_pgo_hot_enabled()) {
        patch_shndx = PIPELINE_ELF_SHNX_TEXT;
        target_shndx = PIPELINE_ELF_SHNX_TEXT;
      } else if (rel32_offset >= 0 && rel32_offset + 4 <= ctx->code_len && target_offset >= 0 &&
                 target_offset <= ctx->code_len) {
        patch_shndx = PIPELINE_ELF_SHNX_TEXT;
        target_shndx = PIPELINE_ELF_SHNX_TEXT;
      } else if (rel32_offset >= 0 && rel32_offset + 4 <= ctx->code_hot_len && target_offset >= 0 &&
                 target_offset <= ctx->code_hot_len) {
        patch_shndx = PIPELINE_ELF_SHNX_TEXT_HOT;
        target_shndx = PIPELINE_ELF_SHNX_TEXT_HOT;
      } else {
        if (getenv("SHUX_ASM_DEBUG")) {
          fprintf(stderr,
                  "shux: elf patch shndx mismatch p=%d patch_sh=%d target_sh=%d rel=%d tgt=%d code_len=%d hot=%d\n",
                  (int)p, (int)patch_shndx, (int)target_shndx, (int)rel32_offset, (int)target_offset,
                  (int)ctx->code_len, (int)ctx->code_hot_len);
        }
        driver_diagnostic_asm_elf_unresolved_patch(patch->name, patch->name_len);
        return -1;
      }
    }
    imm_bits = patch->patch_imm_bits;
    if (imm_bits == 0)
      imm_bits = pipeline_elf_ctx_infer_patch_imm_bits(ctx_bytes, patch_shndx, rel32_offset);
    /*
     * x86 rel32：相对下一条；AArch64 B/BL/CBZ/CBNZ：相对当前 PC（ARM ARM）。
     * 误用 next_insn 作 arm64 基准会把 imm 少 1 → cbz 跳自身（asm 编排 smoke SIGSEGV）。
     */
    if (e_machine == 183 || imm_bits == 19 || imm_bits == 26)
      delta = target_offset - rel32_offset;
    else
      delta = target_offset - (rel32_offset + 4);
    if (e_machine == 183 || imm_bits == 19 || imm_bits == 26) {
      int32_t insn;
      int32_t imm;
      insn = pipeline_elf_ctx_read_u32_le(ctx_bytes, patch_shndx, rel32_offset);
      imm = delta / 4;
      if (imm_bits == 26)
        insn = (insn & (int32_t)4293918720) | (imm & 67108863);
      else if (imm_bits == 19)
        insn = (insn & (int32_t)4278190175) | ((imm & 524287) << 5);
      pipeline_elf_ctx_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, insn);
    } else if (e_machine == 243 || imm_bits == 13 || imm_bits == 21) {
      int32_t insn;
      int32_t val;
      int32_t b_imm;
      int32_t j_imm;
      insn = pipeline_elf_ctx_read_u32_le(ctx_bytes, patch_shndx, rel32_offset);
      val = delta >> 1;
      if (imm_bits == 13) {
        b_imm = val & 8191;
        insn = (insn & 2097183) | ((b_imm & 4096) << 19) | ((b_imm & 4032) << 20) | ((b_imm & 30) << 7) |
               ((b_imm & 2048) >> 4);
      } else if (imm_bits == 21) {
        j_imm = val & 2097151;
        insn = (insn & 4095) | ((j_imm & 524288) << 11) | ((j_imm & 1023) << 21) | ((j_imm & 1024) << 8) |
               ((j_imm & 522240) << 1);
      }
      pipeline_elf_ctx_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, insn);
    } else {
      pipeline_elf_ctx_write_u32_le(ctx_bytes, patch_shndx, rel32_offset, delta);
    }
    p = p + 1;
  }
  return 0;
}

/** 追加一条外部重定位；ctx 为 *ElfCodegenCtx 转 *u8；超 TABLE_CAP 写入 heap sidecar。 */
int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len) {
  PipelineElfCtxAccess *ctx;
  int32_t ri;
  int32_t hi;
  int32_t n;
  PipelineElfRelocEntry *ent;
  PipelineElfRelocHeapEntry *hent;
  uint8_t *sym_row;
  if (!ctx_bytes || !name || name_len <= 0 || name[0] == 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->num_relocs >= PIPELINE_ELF_CTX_RELOC_TOTAL_CAP) {
    fprintf(stderr, "shux: elf num_relocs limit %d reached\n", PIPELINE_ELF_CTX_RELOC_TOTAL_CAP);
    return -1;
  }
  ri = ctx->num_relocs;
  if (ri < PIPELINE_ELF_CTX_TABLE_CAP) {
    ent = &ctx->relocs[ri];
    sym_row = ctx->reloc_sym_names[ri].bytes;
    hent = NULL;
  } else {
    if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
      pipeline_elf_ctx_reloc_sidecar_reset(ctx_bytes);
    hi = ri - PIPELINE_ELF_CTX_TABLE_CAP;
    if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
      return -1;
    hent = &g_pipeline_elf_reloc_heap[hi];
    ent = NULL;
    sym_row = g_pipeline_elf_reloc_sym_heap[hi];
  }
  if (ent) {
    ent->offset = offset;
    ent->name_len = name_len;
  } else if (hent) {
    hent->offset = offset;
    hent->name_len = name_len;
  }
  pipeline_elf_reloc_shndx_set(ctx_bytes, ri, pipeline_elf_ctx_current_shndx(ctx));
  memset(sym_row, 0, 64);
  n = name_len > 64 ? 64 : name_len;
  memcpy(sym_row, name, (size_t)n);
  if (ent)
    ent->name_len = name_len;
  else if (hent)
    hent->name_len = name_len;
  ctx->num_relocs = ctx->num_relocs + 1;
  return 0;
}

/** 返回 reloc_sym_names[idx] 首地址；越界返回 NULL（含 heap sidecar）。 */
uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return NULL;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return NULL;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP)
    return ctx->reloc_sym_names[idx].bytes;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return NULL;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return NULL;
  return g_pipeline_elf_reloc_sym_heap[hi];
}

/** 将 reloc_sym_names[idx] 拷入 dst（最多 63 字节 + NUL）；含 heap sidecar。 */
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst) {
  PipelineElfCtxAccess *ctx;
  int32_t k;
  uint8_t *src;
  if (!dst)
    return;
  memset(dst, 0, 64);
  src = pipeline_elf_ctx_reloc_sym_name_ptr(ctx_bytes, idx);
  if (!src)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (!ctx || idx < 0 || idx >= ctx->num_relocs)
    return;
  for (k = 0; k < 64; k++)
    dst[k] = src[k];
}

/** 读 relocs[idx].name_len（内联或 heap sidecar）。 */
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  int32_t hi;
  if (!ctx_bytes || idx < 0)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (idx >= ctx->num_relocs)
    return 0;
  if (idx < PIPELINE_ELF_CTX_TABLE_CAP)
    return ctx->relocs[idx].name_len;
  if (g_pipeline_elf_reloc_sidecar_owner != ctx_bytes)
    return 0;
  hi = idx - PIPELINE_ELF_CTX_TABLE_CAP;
  if (hi < 0 || hi >= PIPELINE_ELF_CTX_RELOC_HEAP_CAP)
    return 0;
  return g_pipeline_elf_reloc_heap[hi].name_len;
}

/** asm .o 失败诊断：打印 ElfCodegenCtx 前几项计数（与 PipelineElfCtxAccess 布局一致）。 */
void pipeline_elf_ctx_diag_stderr(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  int32_t l;
  char namebuf[65];
  if (!ctx_bytes)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  diag_reportf(NULL, 0, 0, "note", NULL,
               "elf ctx code_len=%d num_labels=%d num_patches=%d num_relocs=%d",
               (int)ctx->code_len, (int)ctx->num_labels, (int)ctx->num_patches, (int)ctx->num_relocs);
  if (ctx->num_patches > 0) {
    PipelineElfPatchEntry *p = &ctx->patches[0];
    int32_t name_len = p->name_len > 64 ? 64 : p->name_len;
    if (name_len < 0)
      name_len = 0;
    for (int32_t i = 0; i < name_len; i++)
      namebuf[i] = (char)p->name[i];
    namebuf[name_len] = '\0';
    diag_reportf(NULL, 0, 0, "note", NULL,
                 "elf first patch name_len=%d name='%s'", (int)p->name_len, namebuf);
    l = 0;
    while (l < ctx->num_labels) {
      int32_t same = (ctx->labels[l].name_len == p->name_len);
      if (same && p->name_len > 0)
        same = (memcmp(ctx->labels[l].name, p->name, (size_t)p->name_len) == 0);
      if (same) {
        diag_reportf(NULL, 0, 0, "note", NULL,
                     "elf label match at idx=%d offset=%d",
                     (int)l, (int)ctx->labels[l].offset);
        return;
      }
      l = l + 1;
    }
    diag_report(NULL, 0, 0, "note", "elf no label match for first patch", NULL);
  }
}

void pipeline_elf_log_unresolved_patch(struct platform_elf_ElfCodegenCtx *ctx, int32_t patch_idx) {
  PipelineElfCtxAccess *acc;
  PipelineElfPatchEntry *p;
  int32_t l;
  int32_t hits;
  if (!ctx || patch_idx < 0)
    return;
  acc = (PipelineElfCtxAccess *)(uint8_t *)ctx;
  if (patch_idx >= acc->num_patches)
    return;
  p = &acc->patches[patch_idx];
  hits = 0;
  l = 0;
  while (l < acc->num_labels) {
    int32_t same = (acc->labels[l].name_len == p->name_len);
    if (same && p->name_len > 0)
      same = (memcmp(acc->labels[l].name, p->name, (size_t)p->name_len) == 0);
    if (same)
      hits = hits + 1;
    l = l + 1;
  }
  diag_reportf(NULL, 0, 0, "note", NULL,
               "elf unresolved patch_idx=%d label_hits=%d num_labels=%d",
               (int)patch_idx, (int)hits, (int)acc->num_labels);
}

/** codegen.x：路径/前缀 scratch（避免 `u8[64] = []` 在 asm emit 时 ExprKind=-1）。 */
static uint8_t g_scratch64[4][64];
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

/** codegen.x：TypeKind 内建类型 → C 类型名；返回长度，*out_ptr 指向静态串；不支持则 0。 */
int32_t pipeline_codegen_type_kind_cstr(int32_t kind, uint8_t **out_ptr) {
  static const char *k_i32 = "int32_t";
  static const char *k_i64 = "int64_t";
  static const char *k_bool = "int";
  static const char *k_u8 = "uint8_t";
  static const char *k_u32 = "uint32_t";
  static const char *k_u64 = "uint64_t";
  static const char *k_f32 = "float";
  static const char *k_f64 = "double";
  static const char *k_void = "void";
  static const char *k_usize = "size_t";
  static const char *k_isize = "ssize_t";
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  switch (kind) {
  case 0:
    *out_ptr = (uint8_t *)k_i32;
    return 7;
  case 1:
    *out_ptr = (uint8_t *)k_bool;
    return 3;
  case 2:
    *out_ptr = (uint8_t *)k_u8;
    return 7;
  case 3:
    *out_ptr = (uint8_t *)k_u32;
    return 8;
  case 4:
    *out_ptr = (uint8_t *)k_u64;
    return 8;
  case 5:
    *out_ptr = (uint8_t *)k_i64;
    return 7;
  case 6:
    *out_ptr = (uint8_t *)k_usize;
    return 6;
  case 7:
    *out_ptr = (uint8_t *)k_isize;
    return 7;
  case 11:
    *out_ptr = (uint8_t *)k_f32;
    return 5;
  case 12:
    *out_ptr = (uint8_t *)k_f64;
    return 6;
  case 13:
    *out_ptr = (uint8_t *)k_void;
    return 4;
  default:
    return 0;
  }
}

/** codegen.x：将 TypeKind C 名写入 dst，返回字节数；-1 缓冲不足或不支持。 */
int32_t pipeline_codegen_type_kind_copy(uint8_t *dst, int32_t cap, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return n <= 0 ? -1 : -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

/** codegen.x：VECTOR 类型 C 名（elem_kind=TYPE_I32/U32，lanes=4/8/16）；无匹配 0。 */
int32_t pipeline_codegen_vector_type_cstr(int32_t elem_kind, int32_t lanes, uint8_t **out_ptr) {
  if (!out_ptr)
    return 0;
  *out_ptr = NULL;
  if (elem_kind == 0) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"i32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"i32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"i32x16_t";
      return 8;
    }
  }
  if (elem_kind == 3) {
    if (lanes == 4) {
      *out_ptr = (uint8_t *)"u32x4_t";
      return 7;
    }
    if (lanes == 8) {
      *out_ptr = (uint8_t *)"u32x8_t";
      return 7;
    }
    if (lanes == 16) {
      *out_ptr = (uint8_t *)"u32x16_t";
      return 8;
    }
  }
  return 0;
}

/** codegen.x：VECTOR 类型 C 名写入 dst；无匹配 -1。 */
int32_t pipeline_codegen_vector_type_copy(uint8_t *dst, int32_t cap, int32_t elem_kind, int32_t lanes) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_vector_type_cstr(elem_kind, lanes, &s);
  if (n <= 0 || !s || !dst || cap < n)
    return -1;
  for (i = 0; i < n; i++)
    dst[i] = s[i];
  return n;
}

/** codegen.x：将 TypeKind C 名追加到 scratch[w..)，返回下一写位置；-1 溢出或不支持。 */
int32_t pipeline_codegen_type_kind_append(uint8_t *scratch, int32_t cap, int32_t w, int32_t kind) {
  uint8_t *s;
  int32_t n;
  int32_t i;
  n = pipeline_codegen_type_kind_cstr(kind, &s);
  if (n <= 0 || !s)
    return -1;
  for (i = 0; i < n; i++) {
    if (w >= cap - 1)
      return -1;
    scratch[w++] = s[i];
  }
  return w;
}

/** 前向声明：TYPE_NAMED 名写入 out64。 */
extern int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64);

/**
 * codegen.x type_to_c_repr 递归核心：经 pipeline_* 读类型池，写入 scratch（无 NUL）。
 * 对齐 codegen.x / codegen.c c_type_to_buf 的简化子集；返回字节数，-1 缓冲不足。
 */
static int32_t pipeline_codegen_type_to_c_repr_inner(struct ast_ASTArena *arena, uint8_t *scratch, int32_t cap,
                                                     int32_t type_ref, uint8_t *struct_prefix,
                                                     int32_t struct_prefix_len) {
  static uint8_t inner[256];
  static uint8_t eb[256];
  int32_t tk;
  int32_t elem_ref;
  int32_t arr_sz;
  int32_t elem_kind;
  int32_t n;
  int32_t j;
  int32_t sp;
  int32_t plen;
  int32_t pi;
  int32_t hi;
  int32_t w;
  int32_t h;
  int32_t name_len;
  uint8_t nm[64];
  int32_t sn;

  if (cap < 16)
    return -1;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    if (cap < 7)
      return -1;
    for (j = 0; j < 7; j++)
      scratch[j] = k_i32[j];
    return 7;
  }
  tk = pipeline_type_kind_ord_at(arena, type_ref);
  elem_ref = pipeline_type_elem_ref_at(arena, type_ref);
  arr_sz = pipeline_type_array_size_at(arena, type_ref);
  if (tk == 9 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, inner, 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n + 2 >= cap)
      return -1;
    for (j = 0; j < n; j++)
      scratch[j] = inner[j];
    scratch[n] = (uint8_t)' ';
    scratch[n + 1] = (uint8_t)'*';
    return n + 2;
  }
  if (tk == 10 && elem_ref > 0)
    return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  if (tk == 13 && elem_ref > 0) {
    elem_kind = pipeline_type_kind_ord_at(arena, elem_ref);
    n = pipeline_codegen_vector_type_copy(scratch, cap, elem_kind, arr_sz);
    if (n >= 0)
      return n;
    return pipeline_codegen_type_kind_copy(scratch, cap, 0);
  }
  if (tk == 12 && elem_ref > 0)
    return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, elem_ref, struct_prefix, struct_prefix_len);
  if (tk == 11 && elem_ref > 0) {
    n = pipeline_codegen_type_to_c_repr_inner(arena, eb, 256, elem_ref, struct_prefix, struct_prefix_len);
    if (n < 0 || n >= 256)
      return -1;
    sp = 0;
    if (n >= 7 && eb[0] == 's' && eb[1] == 't' && eb[2] == 'r' && eb[3] == 'u' && eb[4] == 'c' && eb[5] == 't'
        && eb[6] == ' ') {
      sp = 7;
      while (sp < n && eb[sp] == ' ')
        sp++;
    }
    plen = n - sp;
    if (plen <= 0 || 21 + plen >= cap)
      return -1;
    {
      static const uint8_t hdr[21] = {'s', 't', 'r', 'u', 'c', 't', ' ', 's', 'h', 'u',
                                      'l', 'a', 'n', 'g', '_', 's', 'l', 'i', 'c', 'e', '_'};
      for (hi = 0; hi < 21; hi++)
        scratch[hi] = hdr[hi];
    }
    for (pi = 0; pi < plen; pi++)
      scratch[21 + pi] = eb[sp + pi];
    return 21 + plen;
  }
  name_len = pipeline_type_named_name_into(arena, type_ref, nm);
  if (tk == 8 && name_len > 0) {
    static const uint8_t hdr2[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
    w = 0;
    for (h = 0; h < 7; h++) {
      if (w >= cap - 1)
        return -1;
      scratch[w++] = hdr2[h];
    }
    if (struct_prefix && struct_prefix_len > 0) {
      for (pi = 0; pi < struct_prefix_len; pi++) {
        if (w >= cap - 1)
          return -1;
        scratch[w++] = struct_prefix[pi];
      }
    } else {
      static const uint8_t ast_p[4] = {'a', 's', 't', '_', 0};
      for (pi = 0; pi < 4; pi++) {
        if (w >= cap - 1)
          return -1;
        scratch[w++] = ast_p[pi];
      }
    }
    for (pi = 0; pi < name_len && pi < 64; pi++) {
      if (w >= cap - 1)
        return -1;
      scratch[w++] = nm[pi];
    }
    return w;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, cap, tk);
  if (sn > 0)
    return sn;
  return pipeline_codegen_type_kind_copy(scratch, cap, 0);
}

/**
 * codegen.x type_to_c_repr 的 C glue：dep prerun 全量 typeck 时避免 X 大函数 check_block 失败。
 */
int32_t pipeline_codegen_type_to_c_repr(struct ast_ASTArena *arena, uint8_t *scratch, int32_t cap, int32_t type_ref,
                                        uint8_t *struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_type_to_c_repr_inner(arena, scratch, cap, type_ref, struct_prefix, struct_prefix_len);
}

/** 前向声明：CodegenOutBuf 追加（layout 与 codegen.x 一致）。 */
struct codegen_CodegenOutBuf;

/** 向 CodegenOutBuf 追加字节；0 成功，-1 溢出。 */
static int32_t pipeline_codegen_out_append_bytes(struct codegen_CodegenOutBuf *out, const uint8_t *p, int32_t n) {
  int32_t len;
  uint8_t *data;
  int32_t i;
  if (!out || !p || n < 0)
    return -1;
  len = codegen_out_buf_len(out);
  if (len + n > (int32_t)PIPELINE_CODEGEN_OUTBUF_CAP)
    return -1;
  data = (uint8_t *)out;
  for (i = 0; i < n; i++)
    data[len + i] = p[i];
  codegen_out_buf_set_len(out, len + n);
  return 0;
}

/** 向 CodegenOutBuf 追加单字节。 */
static int32_t pipeline_codegen_out_append_byte(struct codegen_CodegenOutBuf *out, uint8_t b) {
  return pipeline_codegen_out_append_bytes(out, &b, 1);
}

/** 向 CodegenOutBuf 追加十进制整数。 */
static int32_t pipeline_codegen_out_format_int(struct codegen_CodegenOutBuf *out, int32_t val) {
  char buf[16];
  int n;
  if (!out)
    return -1;
  n = snprintf(buf, sizeof(buf), "%d", (int)val);
  if (n <= 0 || n >= (int)sizeof(buf))
    return -1;
  return pipeline_codegen_out_append_bytes(out, (const uint8_t *)buf, n);
}

/** emit_struct_field_type_via_pipeline 递归核心（ord 与 ast.x TypeKind 一致）。 */
static int32_t pipeline_codegen_emit_struct_field_type_inner(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                             int32_t type_ref, uint8_t *struct_prefix,
                                                             int32_t struct_prefix_len) {
  static uint8_t scratch[256];
  int32_t ord;
  int32_t inner;
  int32_t asz;
  int32_t ik;
  int32_t lanes_v;
  int32_t nl;
  int32_t sn;
  uint8_t nm[64];

  ord = pipeline_type_kind_ord_at(arena, type_ref);
  if (!arena || type_ref <= 0 || ord < 0) {
    static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
    return pipeline_codegen_out_append_bytes(out, k_i32, 7);
  }
  if (ord == 9) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte(out, (uint8_t)' ') != 0)
      return -1;
    return pipeline_codegen_out_append_byte(out, (uint8_t)'*');
  }
  if (ord == 10) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    asz = pipeline_type_array_size_at(arena, type_ref);
    if (pipeline_codegen_emit_struct_field_type_inner(arena, out, inner, struct_prefix, struct_prefix_len) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int(out, asz) != 0)
      return -1;
    return pipeline_codegen_out_append_byte(out, (uint8_t)']');
  }
  if (ord == 8) {
    static const uint8_t hdr[7] = {'s', 't', 'r', 'u', 'c', 't', ' '};
    nl = pipeline_type_named_name_into(arena, type_ref, nm);
    if (nl <= 0) {
      static const uint8_t k_i32[7] = {'i', 'n', 't', '3', '2', '_', 't'};
      return pipeline_codegen_out_append_bytes(out, k_i32, 7);
    }
    if (pipeline_codegen_out_append_bytes(out, hdr, 7) != 0)
      return -1;
    if (struct_prefix && struct_prefix_len > 0) {
      if (pipeline_codegen_out_append_bytes(out, struct_prefix, struct_prefix_len) != 0)
        return -1;
    } else {
      static const uint8_t ast_p[4] = {'a', 's', 't', '_'};
      if (pipeline_codegen_out_append_bytes(out, ast_p, 4) != 0)
        return -1;
    }
    return pipeline_codegen_out_append_bytes(out, nm, nl);
  }
  if (ord == 11) {
    nl = pipeline_codegen_type_to_c_repr_inner(arena, scratch, 256, type_ref, struct_prefix, struct_prefix_len);
    if (nl <= 0)
      return -1;
    return pipeline_codegen_out_append_bytes(out, scratch, nl);
  }
  if (ord == 12) {
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    return pipeline_codegen_emit_struct_field_type_inner(arena, out, inner, struct_prefix, struct_prefix_len);
  }
  if (ord == 13) {
    lanes_v = pipeline_type_array_size_at(arena, type_ref);
    inner = pipeline_type_elem_ref_at(arena, type_ref);
    ik = pipeline_type_kind_ord_at(arena, inner);
    sn = pipeline_codegen_vector_type_copy(scratch, 256, ik, lanes_v);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes(out, scratch, sn);
    sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
    if (sn > 0)
      return pipeline_codegen_out_append_bytes(out, scratch, sn);
    return -1;
  }
  sn = pipeline_codegen_type_kind_copy(scratch, 256, ord);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes(out, scratch, sn);
  sn = pipeline_codegen_type_kind_copy(scratch, 256, 0);
  if (sn > 0)
    return pipeline_codegen_out_append_bytes(out, scratch, sn);
  return -1;
}

/**
 * codegen.x emit_struct_field_type_via_pipeline 的 C glue：dep prerun 全量 typeck 时避免 X 大函数失败。
 */
int32_t pipeline_codegen_emit_struct_field_type(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                              int32_t type_ref, uint8_t *struct_prefix, int32_t struct_prefix_len) {
  return pipeline_codegen_emit_struct_field_type_inner(arena, out, type_ref, struct_prefix, struct_prefix_len);
}

/**
 * 结构体字段声明发射：
 * - 普通字段：`type name`
 * - 数组字段：`type name[n][m]`
 * 仅剥离最外层数组链，保留内层类型（如指针）由原 type emitter 输出。
 */
int32_t pipeline_codegen_emit_struct_field_decl(struct ast_ASTArena *arena, struct codegen_CodegenOutBuf *out,
                                                int32_t type_ref, uint8_t *field_name, int32_t field_name_len,
                                                uint8_t *struct_prefix, int32_t struct_prefix_len) {
  int32_t base_type_ref;
  int32_t dims[8];
  int32_t ndim;
  int32_t i;

  if (!arena || !out || type_ref <= 0 || !field_name || field_name_len <= 0)
    return -1;

  base_type_ref = type_ref;
  ndim = 0;
  while (base_type_ref > 0 && pipeline_type_kind_ord_at(arena, base_type_ref) == 10 && ndim < 8) {
    dims[ndim] = pipeline_type_array_size_at(arena, base_type_ref);
    base_type_ref = pipeline_type_elem_ref_at(arena, base_type_ref);
    ndim++;
  }

  if (pipeline_codegen_emit_struct_field_type_inner(arena, out, base_type_ref, struct_prefix, struct_prefix_len) != 0)
    return -1;
  if (pipeline_codegen_out_append_byte(out, (uint8_t)' ') != 0)
    return -1;
  if (pipeline_codegen_out_append_bytes(out, field_name, field_name_len) != 0)
    return -1;
  for (i = 0; i < ndim; i++) {
    if (pipeline_codegen_out_append_byte(out, (uint8_t)'[') != 0)
      return -1;
    if (pipeline_codegen_out_format_int(out, dims[i]) != 0)
      return -1;
    if (pipeline_codegen_out_append_byte(out, (uint8_t)']') != 0)
      return -1;
  }
  return 0;
}

/**
 * codegen.x codegen_call_num_args_override：符号全名表（asm 不支持函数内 u8[N] 字面量）。
 * 命中返回 override 后的 num_args；未命中返回原 num_args。
 */
typedef struct {
  const char *sym;
  int32_t sym_len;
  int32_t override_nargs;
} CodegenCallOverrideEntry;

static const CodegenCallOverrideEntry k_codegen_call_overrides[] = {
    {"vec_len_empty", 13, 0},
    {"std_vec_vec_len_empty", 21, 0},
    {"alloc_size_zero", 15, 0},
    {"std_heap_alloc_size_zero", 24, 0},
    {"runtime_ready", 13, 0},
    {"std_runtime_runtime_ready", 25, 0},
    {"string_new", 10, 0},
    {"std_string_string_new", 21, 0},
    {"placeholder", 11, 0},
    {"std_string_placeholder", 22, 0},
    {"thread_self", 11, 0},
    {"std_thread_thread_self", 22, 0},
    {"thread_dummy_entry_ptr", 22, 0},
    {"std_thread_thread_dummy_entry_ptr", 33, 0},
    {"now_monotonic_ns", 16, 0},
    {"std_time_now_monotonic_ns", 25, 0},
    {"now_monotonic_ms", 16, 0},
    {"std_time_now_monotonic_ms", 25, 0},
    {"fmt_i32", 7, 1},
    {"core_fmt_fmt_i32", 16, 1},
    {"print_i32", 9, 1},
    {"std_io_print_i32", 16, 1},
    {"print_u32", 9, 1},
    {"std_io_print_u32", 16, 1},
    {"print_i64", 9, 1},
    {"std_io_print_i64", 16, 1},
    {"std_fmt_println", 14, 2},
    {"std_fmt_print", 13, 2},
    {"std_debug_println", 16, 2},
    {"std_debug_print", 14, 2},
    {"ok_i32", 6, 1},
    {"core_result_ok_i32", 18, 1},
    {"err_i32", 7, 1},
    {"core_result_err_i32", 19, 1},
};

int32_t pipeline_codegen_call_num_args_override_lookup(uint8_t *buf, int32_t full, int32_t num_args) {
  int i, n;
  if (!buf || full <= 0 || num_args <= 0)
    return num_args;
  n = (int)(sizeof(k_codegen_call_overrides) / sizeof(k_codegen_call_overrides[0]));
  for (i = 0; i < n; i++) {
    if (full == k_codegen_call_overrides[i].sym_len &&
        memcmp(buf, k_codegen_call_overrides[i].sym, (size_t)full) == 0)
      return k_codegen_call_overrides[i].override_nargs;
  }
  return num_args;
}

/** codegen.x / asm backend：拼接 prefix+name 后查表，避免 .x 内 u8[N] 字面量与 *u8 下标在 asm emit 失败。 */
int32_t pipeline_codegen_call_num_args_override(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                                int32_t num_args) {
  uint8_t buf[96];
  int32_t full = 0;
  int32_t i;
  if (num_args <= 0)
    return num_args;
  if (prefix && prefix_len > 0) {
    for (i = 0; i < prefix_len && full < 96; i++)
      buf[full++] = prefix[i];
  }
  if (name && name_len > 0) {
    for (i = 0; i < name_len && full < 96; i++)
      buf[full++] = name[i];
  }
  return pipeline_codegen_call_num_args_override_lookup(buf, full, num_args);
}

/** codegen.x：std.io.driver 桥接名前缀表（asm 不支持函数内数组字面量）。 */
static int codegen_name_prefix_eq(uint8_t *name, int32_t name_len, const char *pfx, int32_t plen) {
  if (!name || name_len < plen)
    return 0;
  return memcmp(name, pfx, (size_t)plen) == 0 ? 1 : 0;
}

int32_t pipeline_codegen_is_std_io_driver_bridge_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if ((name_len == 8 || name_len == 9) && codegen_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if ((name_len == 11 || name_len == 12) && codegen_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if ((name_len == 12 || name_len == 13) && codegen_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && codegen_name_prefix_eq(name, name_len, "wait_readable", 13))
    return 1;
  if ((name_len == 22 || name_len == 23) && codegen_name_prefix_eq(name, name_len, "register_fixed_buffers", 22))
    return 1;
  if ((name_len == 17 || name_len == 18) && codegen_name_prefix_eq(name, name_len, "submit_read_batch", 17))
    return 1;
  if ((name_len == 18 || name_len == 19) && codegen_name_prefix_eq(name, name_len, "submit_write_batch", 18))
    return 1;
  if ((name_len == 33 || name_len == 34) && codegen_name_prefix_eq(name, name_len, "submit_register_fixed_buffers_buf", 33))
    return 1;
  if ((name_len == 21 || name_len == 22) && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if ((name_len == 22 || name_len == 23) && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

/** import 路径逐字节含末尾 NUL 比较（codegen.x asm 无数组字面量）。 */
static int codegen_path_bytes_eq(uint8_t *path, const char *expect, int32_t len_with_nul) {
  int32_t i;
  if (!path)
    return 0;
  for (i = 0; i < len_with_nul; i++)
    if (path[i] != (uint8_t)expect[i])
      return 0;
  return 1;
}

/** prefix+name 拼接是否等于 full（总长须一致）。 */
static int codegen_prefix_name_bytes_eq(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                        const char *full, int32_t full_len) {
  int32_t pi;
  int32_t ni;
  if (!prefix || !name || prefix_len <= 0 || name_len <= 0)
    return 0;
  if (prefix_len + name_len != full_len)
    return 0;
  for (pi = 0; pi < prefix_len; pi++)
    if (prefix[pi] != (uint8_t)full[pi])
      return 0;
  for (ni = 0; ni < name_len; ni++)
    if (name[ni] != (uint8_t)full[prefix_len + ni])
      return 0;
  return 1;
}

/** codegen.x：import 路径是否为 std.io.driver（含 NUL，14 字节）。 */
int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
  return codegen_path_bytes_eq(path, "std.io.driver\0", 14);
}

/** codegen.x：import 路径是否为 std.io.core（含 NUL，12 字节）。 */
int32_t pipeline_codegen_path_is_std_io_core_bytes(uint8_t *path) {
  return codegen_path_bytes_eq(path, "std.io.core\0", 12);
}

/**
 * seed 用户程序 asm：std.io 族模块由 io.o + user_asm_seed_bridge 桩提供，勿整模块 emit（易宿主栈 Abort）。
 * 匹配 std.io、std.io.core、std.io.driver 等。
 */
int32_t pipeline_codegen_dep_skip_asm_user_std_io(uint8_t *path) {
  if (!path)
    return 0;
  if (pipeline_codegen_path_is_std_io_core_bytes(path) != 0)
    return 1;
  if (memcmp(path, "std.io", 6) != 0)
    return 0;
  if (path[6] == 0 || path[6] == '.')
    return 1;
  return 0;
}

/**
 * bootstrap -E / asm partial：compiler 前端模块符号已由 *_x.o 链入，勿整库 X C codegen（ast 等大库 emit 失败）。
 * 精确匹配 import 路径（如 ast、codegen、parser.x→parser）。
 */
int32_t pipeline_codegen_dep_skip_x_bootstrap_partial(uint8_t *path) {
  static const char *const k_exact[] = {
      "ast", "codegen", "parser", "typeck", "lexer", "preprocess", "pipeline", "lsp", "lsp.diag", "lsp.io",
      "driver", "driver.check", "driver.compile", "driver.emit", "driver.fmt", "driver.test", "driver.build",
      "driver.run", "asm.types", NULL};
  int32_t i;
  if (!path)
    return 0;
  for (i = 0; k_exact[i]; i++) {
    if (codegen_path_bytes_eq(path, k_exact[i], (int32_t)strlen(k_exact[i])))
      return 1;
  }
  return 0;
}

/** codegen.x：std.io.core 与 io.o 重复的 shux_io_* 函数须跳过 emit。 */
int32_t pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!dep_path || !name)
    return 0;
  if (memcmp(dep_path, "std.io.core", 11) != 0)
    return 0;
  if ((name_len == 17 || name_len == 18) && codegen_name_prefix_eq(name, name_len, "shux_io_read_fixed", 17))
    return 1;
  if ((name_len == 18 || name_len == 19) && codegen_name_prefix_eq(name, name_len, "shux_io_write_fixed", 18))
    return 1;
  if ((name_len == 24 || name_len == 25) && codegen_name_prefix_eq(name, name_len, "shux_io_submit_read_batch", 24))
    return 1;
  if ((name_len == 25 || name_len == 26) && codegen_name_prefix_eq(name, name_len, "shux_io_submit_write_batch", 25))
    return 1;
  if ((name_len == 18 || name_len == 19) && codegen_name_prefix_eq(name, name_len, "shux_io_submit_read", 18))
    return 1;
  if ((name_len == 19 || name_len == 20) && codegen_name_prefix_eq(name, name_len, "shux_io_submit_write", 19))
    return 1;
  return 0;
}

/** codegen.x：std.io handle_* 字面量函数须跳过 emit；dep_path 为空时仅按 name 判断。 */
int32_t pipeline_codegen_should_skip_emit_std_io_trivial_handle(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (dep_path && !codegen_path_bytes_eq(dep_path, "std.io\0", 7))
    return 0;
  if ((name_len == 12 || name_len == 13) && codegen_name_prefix_eq(name, name_len, "handle_stdin", 12))
    return 1;
  if ((name_len == 13 || name_len == 14) && codegen_name_prefix_eq(name, name_len, "handle_stdout", 13))
    return 1;
  if ((name_len == 13 || name_len == 14) && codegen_name_prefix_eq(name, name_len, "handle_stderr", 13))
    return 1;
  if ((name_len == 15 || name_len == 16) && codegen_name_prefix_eq(name, name_len, "handle_from_fd", 15))
    return 1;
  return 0;
}

/** codegen.x：合并 driver_should_skip_emit 三套逻辑（原 codegen_should_skip_emit_func）。 */
int32_t pipeline_codegen_should_skip_emit_func(uint8_t *dep_path, uint8_t *prefix, int32_t prefix_len,
                                               uint8_t *name, int32_t name_len) {
  int32_t ok_path;
  if (prefix && prefix_len > 0 && name && name_len > 0) {
    if (codegen_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr_len", 33))
      return 1;
    if (codegen_prefix_name_bytes_eq(prefix, prefix_len, name, name_len, "std_io_driver_driver_read_ptr", 29))
      return 1;
  }
  if (dep_path) {
    ok_path = codegen_path_bytes_eq(dep_path, "std.io.driver\0", 14);
    if (!ok_path)
      ok_path = codegen_path_bytes_eq(dep_path, "std.io\0", 7);
    if (ok_path && name) {
      if ((name_len == 19 || name_len == 20) &&
          codegen_name_prefix_eq(name, name_len, "driver_read_ptr_len", 19))
        return 1;
      if ((name_len == 15 || name_len == 16) && codegen_name_prefix_eq(name, name_len, "driver_read_ptr", 15))
        return 1;
    }
  }
  if (prefix && prefix_len == 14 && name &&
      codegen_name_prefix_eq(prefix, prefix_len, "std_io_driver_", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (dep_path && name && codegen_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
      pipeline_codegen_is_std_io_driver_bridge_name(name, name_len))
    return 1;
  if (prefix && prefix_len == 14 && name &&
      pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
    return 1;
  if (dep_path && name) {
    if (pipeline_codegen_should_skip_emit_std_io_core_io_dup(dep_path, name, name_len))
      return 1;
    if (codegen_path_bytes_eq(dep_path, "std.io.driver\0", 14) &&
        pipeline_codegen_should_skip_emit_std_io_trivial_handle(0, name, name_len))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 read_message（LSP io 入口探测）。 */
int32_t pipeline_codegen_entry_is_lsp_io_module(struct ast_Module *module) {
  static const uint8_t rd[] = "read_message";
  int32_t i;
  int32_t n;
  if (!module)
    return 0;
  n = (int32_t)module->num_funcs;
  for (i = 0; i < n; i++) {
    if (pipeline_module_func_name_equal_at(module, i, (uint8_t *)rd, 12))
      return 1;
  }
  return 0;
}

/** codegen.x：entry 模块是否含 lsp_main。 */
int32_t pipeline_codegen_entry_is_lsp_main_module(struct ast_Module *module) {
  static const uint8_t main_nm[] = "lsp_main";
  int32_t i;
  int32_t n;
  if (!module)
    return 0;
  n = (int32_t)module->num_funcs;
  for (i = 0; i < n; i++) {
    if (pipeline_module_func_name_equal_at(module, i, (uint8_t *)main_nm, 8))
      return 1;
  }
  return 0;
}

/** codegen.x：C 前缀是否为 std_io_driver 族（13 字节 + 可选第 14 字节 NUL/_）。 */
int32_t pipeline_codegen_force_param_std_io_driver_prefix_ok(uint8_t *prefix, int32_t prefix_len) {
  static const char exp13[] = "std_io_driver";
  int32_t i;
  if (!prefix || prefix_len < 13)
    return 0;
  for (i = 0; i < 13; i++)
    if (prefix[i] != (uint8_t)exp13[i])
      return 0;
  if (prefix_len > 13) {
    uint8_t b14 = prefix[13];
    if (b14 != 0 && b14 != 95)
      return 0;
  }
  return 1;
}

/** codegen.x：std_io_driver submit_*_batch_buf 首参强制 size_t。 */
int32_t pipeline_codegen_force_param_size_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                            int32_t param_index) {
  if (param_index != 0)
    return 0;
  if (!pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len))
    return 0;
  if (!name)
    return 0;
  if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

/** codegen.x：std.io print 第二参强制 size_t（前缀须 std_io_）。 */
int32_t pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                    uint8_t *name, int32_t name_len,
                                                                    int32_t param_index) {
  if (param_index != 1 || !name || name_len != 5)
    return 0;
  if (memcmp(name, "print", 5) != 0)
    return 0;
  if (!prefix || prefix_len < 7)
    return 0;
  return memcmp(prefix, "std_io_", 7) == 0 ? 1 : 0;
}

/** codegen.x：std_io_driver register/submit_read/submit_write 首参 ptrdiff_t。 */
int32_t pipeline_codegen_force_param_ptrdiff_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                               int32_t param_index) {
  if (param_index != 0 || !pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) || !name)
    return 0;
  if (name_len == 8 && codegen_name_prefix_eq(name, name_len, "register", 8))
    return 1;
  if (name_len == 11 && codegen_name_prefix_eq(name, name_len, "submit_read", 11))
    return 1;
  if (name_len == 12 && codegen_name_prefix_eq(name, name_len, "submit_write", 12))
    return 1;
  return 0;
}

/** codegen.x：std_io_driver 按名/下标强制 uint32_t（timeout_ms/nr）。 */
int32_t pipeline_codegen_force_param_uint32_t(uint8_t *prefix, int32_t prefix_len, uint8_t *name, int32_t name_len,
                                              int32_t param_index) {
  if (!pipeline_codegen_force_param_std_io_driver_prefix_ok(prefix, prefix_len) || !name)
    return 0;
  if (param_index == 1) {
    if (name_len == 11 && codegen_name_prefix_eq(name, name_len, "submit_read", 11))
      return 1;
    if (name_len == 12 && codegen_name_prefix_eq(name, name_len, "submit_write", 12))
      return 1;
    if (name_len == 33 && codegen_name_prefix_eq(name, name_len, "submit_register_fixed_buffers_buf", 33))
      return 1;
    return 0;
  }
  if (param_index == 3) {
    if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
      return 1;
    if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
      return 1;
  }
  return 0;
}

/** codegen.x：std.io.core shux_io_* 调用名追加 _buf。 */
int32_t pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args) {
  if (!name || name_len <= 0)
    return 0;
  if (num_args == 1 && name_len == 15 && codegen_name_prefix_eq(name, name_len, "shux_io_register", 15))
    return 1;
  if (num_args == 2 && name_len == 18 && codegen_name_prefix_eq(name, name_len, "shux_io_submit_read", 18))
    return 1;
  if (num_args == 2 && name_len == 19 && codegen_name_prefix_eq(name, name_len, "shux_io_submit_write", 19))
    return 1;
  return 0;
}

/** codegen.x：driver extern io_* batch 由 preamble/io.o 提供，跳过 std_io_driver_io_* extern 声明。 */
int32_t pipeline_codegen_skip_emit_extern_io_batch_buf(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 17 && memcmp(name, "io_read_batch_buf", 17) == 0)
    return 1;
  if (name_len == 18 && memcmp(name, "io_write_batch_buf", 18) == 0)
    return 1;
  if (name_len == 23 && memcmp(name, "io_register_buffers_buf", 23) == 0)
    return 1;
  return 0;
}

/** codegen.x：占位/string 桩函数名跳过 emit（placeholder、string_new 等）。 */
int32_t pipeline_codegen_should_skip_emit_func_by_name(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 11 && codegen_name_prefix_eq(name, name_len, "placeholder", 11))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "std_string_placeholder", 22))
    return 1;
  if (name_len == 10 && codegen_name_prefix_eq(name, name_len, "string_new", 10))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "std_string_string_new", 22))
    return 1;
  if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "std_string_string_new", 21))
    return 1;
  /** bootstrap -E：seed_mega 体过大；SHUX_EMIT_SEED_MEGA=1 时仍尝试 X emit（build_seed_asm_host）。 */
  if (!getenv("SHUX_EMIT_SEED_MEGA")) {
    if (name_len == 25 && memcmp(name, "asm_codegen_ast_seed_mega", 25) == 0)
      return 1;
    if (name_len == 32 && memcmp(name, "asm_codegen_ast_to_elf_seed_mega", 32) == 0)
      return 1;
  }
  return 0;
}

/** codegen.x：SHUX_EMIT_SEED_MEGA=1 时 bootstrap -E 仍 emit seed_mega。 */
int32_t pipeline_codegen_emit_seed_mega_enabled(void) {
  const char *e = getenv("SHUX_EMIT_SEED_MEGA");
  return (e && e[0] && e[0] != '0') ? 1 : 0;
}

/** codegen.x：submit_*_batch_buf 调用需补第 4 参 timeout_ms。 */
int32_t pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

/** codegen.x：std.io.core 中 preamble/io.o 已提供的 shux_io_* 桥接名，跳过函数体 emit。 */
int32_t pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len >= 19 && codegen_name_prefix_eq(name, name_len, "shux_io_read_ptr_len", 19))
    return 1;
  if (name_len == 15 && codegen_name_prefix_eq(name, name_len, "shux_io_read_ptr", 15))
    return 1;
  if (name_len == 15 && codegen_name_prefix_eq(name, name_len, "shux_io_register", 15))
    return 1;
  if (name_len == 23 && codegen_name_prefix_eq(name, name_len, "shux_io_register_buffers", 23))
    return 1;
  if (name_len == 25 && codegen_name_prefix_eq(name, name_len, "shux_io_unregister_buffers", 25))
    return 1;
  if (name_len == 20 && codegen_name_prefix_eq(name, name_len, "shux_io_wait_readable", 20))
    return 1;
  return 0;
}

/**
 * asm 路径：std.io.core 薄包装未编入 .o（由 io.o 提供）时，将 call 重定向到 extern io_* 符号。
 * name 可为裸 shux_io_* 或 std_io_core_shux_io_*；命中写 sym_out，返回长度；无匹配 0；缓冲不足 -1。
 */
int32_t pipeline_asm_io_core_extern_callee_sym(uint8_t *name, int32_t name_len, uint8_t *sym_out, int32_t sym_cap) {
  uint8_t *bare;
  int32_t blen;
  const char *sym;
  int32_t slen;
  if (!name || name_len <= 0 || !sym_out || sym_cap <= 0)
    return 0;
  bare = name;
  blen = name_len;
  if (name_len > 12 && memcmp(name, "std_io_core_", 12) == 0) {
    bare = name + 12;
    blen = name_len - 12;
  }
  sym = NULL;
  slen = 0;
  if (blen == 23 && codegen_name_prefix_eq(bare, blen, "shux_io_register_buffers", 23)) {
    sym = "io_register_buffers_4";
    slen = 23;
  } else if (blen == 25 && codegen_name_prefix_eq(bare, blen, "shux_io_unregister_buffers", 25)) {
    sym = "io_unregister_buffers";
    slen = 21;
  } else if (blen == 15 && codegen_name_prefix_eq(bare, blen, "shux_io_register", 15)) {
    sym = "io_register_buffer";
    slen = 19;
  } else if (blen == 19 && codegen_name_prefix_eq(bare, blen, "shux_io_read_ptr_len", 19)) {
    sym = "io_read_ptr_len";
    slen = 15;
  } else if (blen == 15 && codegen_name_prefix_eq(bare, blen, "shux_io_read_ptr", 15)) {
    sym = "io_read_ptr";
    slen = 11;
  } else if (blen == 20 && codegen_name_prefix_eq(bare, blen, "shux_io_wait_readable", 20)) {
    sym = "io_wait_readable";
    slen = 17;
  }
  if (!sym)
    return 0;
  if (sym_cap < slen)
    return -1;
  memcpy(sym_out, sym, (size_t)slen);
  return slen;
}

/** codegen.x：std.io driver 短名 register/submit_* 映射到 shux_io_*_buf；命中写 sym_out，返回符号长度；无匹配 0；缓冲不足 -1。 */
int32_t pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args, uint8_t *sym_out,
                                                int32_t sym_cap) {
  const char *sym;
  int32_t sym_len;
  if (!name || name_len <= 0)
    return 0;
  sym = NULL;
  sym_len = 0;
  if (num_args == 1 && name_len == 8 && codegen_name_prefix_eq(name, name_len, "register", 8)) {
    sym = "shux_io_register_buf";
    sym_len = 19;
  } else if (num_args == 2 && name_len == 11 && codegen_name_prefix_eq(name, name_len, "submit_read", 11)) {
    sym = "shux_io_submit_read_buf";
    sym_len = 22;
  } else if (num_args == 2 && name_len == 12 && codegen_name_prefix_eq(name, name_len, "submit_write", 12)) {
    sym = "shux_io_submit_write_buf";
    sym_len = 23;
  }
  if (!sym)
    return 0;
  if (!sym_out || sym_cap < sym_len)
    return -1;
  memcpy(sym_out, sym, (size_t)sym_len);
  return sym_len;
}

/** codegen.x：std_io read_fixed_fd/write_fixed_fd 须追加 _impl 后缀。 */
int32_t pipeline_codegen_std_io_fixed_fd_emit_impl(uint8_t *prefix, int32_t prefix_len, uint8_t *name,
                                                   int32_t name_len) {
  if (!prefix || !name || prefix_len < 7 || name_len <= 0)
    return 0;
  if (!codegen_name_prefix_eq(prefix, prefix_len, "std_io_", 7))
    return 0;
  if (name_len >= 13 && codegen_name_prefix_eq(name, name_len, "read_fixed_fd", 13))
    return 1;
  if (name_len >= 14 && codegen_name_prefix_eq(name, name_len, "write_fixed_fd", 14))
    return 1;
  return 0;
}

/** backend.x：AsmFuncCtx 局部变量 grow 池（替代 locals[24]）。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t offset;
} AsmLocalSlotEntry;

typedef struct {
  void *ctx;
  int used;
  GrowVec slots;
} AsmLocalsSidecar;

#define MAX_ASM_LOCALS_SIDECARS 64

static AsmLocalsSidecar g_asm_locals_sc[MAX_ASM_LOCALS_SIDECARS];

static AsmLocalsSidecar *asm_locals_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_locals_sc[i].used && g_asm_locals_sc[i].ctx == (void *)ctx)
      return &g_asm_locals_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_locals_sc[i].used) {
      g_asm_locals_sc[i].ctx = (void *)ctx;
      g_asm_locals_sc[i].used = 1;
      if (!grow_vec_init(&g_asm_locals_sc[i].slots, sizeof(AsmLocalSlotEntry), AST_POOL_GROW))
        return NULL;
      return &g_asm_locals_sc[i];
    }
  }
  return NULL;
}

/** 前向声明：块→slot_base 表与 locals 同生命周期，ctx_reset 须一并清空。 */
void asm_ctx_block_slot_reset(uint8_t *ctx);

/** 清空某 AsmFuncCtx 的局部槽 grow 池；同步清空 block_slot 以免跨函数/跨 dep 模块 block_ref 碰撞误跳过 fill。 */
void asm_ctx_local_reset(uint8_t *ctx) {
  AsmLocalsSidecar *sc = asm_locals_sidecar_get(ctx, 0);
  if (sc)
    sc->slots.len = 0;
  asm_ctx_block_slot_reset(ctx);
}

/** 局部槽数量。 */
int32_t asm_ctx_local_count(uint8_t *ctx) {
  AsmLocalsSidecar *sc = asm_locals_sidecar_get(ctx, 0);
  return sc ? sc->slots.len : 0;
}

/** 追加局部槽；返回下标，失败 -1。 */
int32_t asm_ctx_local_append(uint8_t *ctx, uint8_t *name, int32_t name_len, int32_t offset) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  int32_t idx;
  int32_t n;
  int32_t k;
  if (!ctx || !name || name_len <= 0)
    return -1;
  if (!(sc = asm_locals_sidecar_get(ctx, 1)))
    return -1;
  idx = grow_vec_push(&sc->slots);
  if (idx < 0)
    return -1;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  if (!ent)
    return -1;
  memset(ent, 0, sizeof(*ent));
  n = name_len > 63 ? 63 : name_len;
  for (k = 0; k < n; k++)
    ent->name[k] = name[k];
  ent->name_len = name_len;
  ent->offset = offset;
  return idx;
}

int32_t asm_ctx_local_name_len(uint8_t *ctx, int32_t idx) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  if (idx < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return 0;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  return ent ? ent->name_len : 0;
}

uint8_t asm_ctx_local_name_byte_at(uint8_t *ctx, int32_t idx, int32_t off) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  if (idx < 0 || off < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return 0;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  if (!ent || off >= ent->name_len)
    return 0;
  return ent->name[off];
}

void asm_ctx_local_name_copy64(uint8_t *ctx, int32_t idx, uint8_t *dst) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 64);
  if (idx < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  if (!ent)
    return;
  for (k = 0; k < ent->name_len && k < 63; k++)
    dst[k] = ent->name[k];
}

int32_t asm_ctx_local_offset_at(uint8_t *ctx, int32_t idx) {
  AsmLocalsSidecar *sc;
  AsmLocalSlotEntry *ent;
  if (idx < 0 || !(sc = asm_locals_sidecar_get(ctx, 0)) || idx >= sc->slots.len)
    return 0;
  ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, idx);
  return ent ? ent->offset : 0;
}

/** 自后向前查局部名，返回栈偏移；未找到返回 -1（内层块同名覆盖外层）。 */
int32_t asm_ctx_local_find_offset(uint8_t *ctx, uint8_t *name, int32_t name_len) {
  AsmLocalsSidecar *sc;
  int32_t i;
  int32_t k;
  AsmLocalSlotEntry *ent;
  if (!ctx || !name || name_len <= 0)
    return -1;
  if (!(sc = asm_locals_sidecar_get(ctx, 0)))
    return -1;
  for (i = sc->slots.len - 1; i >= 0; i--) {
    ent = (AsmLocalSlotEntry *)grow_vec_at(&sc->slots, i);
    if (!ent || ent->name_len != name_len)
      continue;
    for (k = 0; k < name_len; k++) {
      if (ent->name[k] != name[k])
        break;
    }
    if (k == name_len)
      return ent->offset;
  }
  return -1;
}

struct backend_AsmFuncCtx;

/**
 * backend.x local_offset 的 C 实现（含零字节占位名回退）；M8-tail 薄包装 bl 目标。
 */
int32_t pipeline_asm_local_offset_c(struct backend_AsmFuncCtx *ctx, uint8_t *name, int32_t name_len) {
  uint8_t *key;
  int32_t nloc;
  int32_t i;
  int32_t k;
  int32_t eq;
  int32_t j;
  int32_t all_zero;
  if (!ctx || !name || name_len <= 0)
    return -1;
  key = (uint8_t *)ctx;
  nloc = asm_ctx_local_count(key);
  for (i = 0; i < nloc; i++) {
    if (asm_ctx_local_name_len(key, i) == name_len) {
      eq = 1;
      for (k = 0; k < name_len && eq != 0; k++) {
        if (name[k] != asm_ctx_local_name_byte_at(key, i, k))
          eq = 0;
      }
      if (eq != 0)
        return asm_ctx_local_offset_at(key, i);
    }
  }
  /** 与 backend.x 一致：name_len<=32 且 sidecar 槽名为全零时仍匹配（自举 tear 修复路径）。 */
  if (name_len > 0 && name_len <= 32) {
    for (j = 0; j < nloc; j++) {
      if (asm_ctx_local_name_len(key, j) == name_len) {
        all_zero = 1;
        for (k = 0; k < name_len && all_zero != 0; k++) {
          if (asm_ctx_local_name_byte_at(key, j, k) != 0)
            all_zero = 0;
        }
        if (all_zero != 0)
          return asm_ctx_local_offset_at(key, j);
      }
    }
  }
  return -1;
}

/** backend.x：块 ref → 该块 const/let 在 sidecar 中的起始槽下标（树遍历 fill 时写入）。 */
typedef struct {
  void *ctx;
  int used;
  GrowVec block_refs;
  GrowVec slot_bases;
} AsmBlockSlotSidecar;

static AsmBlockSlotSidecar g_asm_block_slot_sc[MAX_ASM_LOCALS_SIDECARS];

static AsmBlockSlotSidecar *asm_block_slot_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_block_slot_sc[i].used && g_asm_block_slot_sc[i].ctx == (void *)ctx)
      return &g_asm_block_slot_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_block_slot_sc[i].used) {
      g_asm_block_slot_sc[i].ctx = (void *)ctx;
      g_asm_block_slot_sc[i].used = 1;
      if (!grow_vec_init(&g_asm_block_slot_sc[i].block_refs, sizeof(int32_t), AST_POOL_GROW))
        return NULL;
      if (!grow_vec_init(&g_asm_block_slot_sc[i].slot_bases, sizeof(int32_t), AST_POOL_GROW)) {
        grow_vec_free(&g_asm_block_slot_sc[i].block_refs);
        return NULL;
      }
      return &g_asm_block_slot_sc[i];
    }
  }
  return NULL;
}

/** 清空某 AsmFuncCtx 的块槽基址表（与 asm_ctx_local_reset 同生命周期）。 */
void asm_ctx_block_slot_reset(uint8_t *ctx) {
  AsmBlockSlotSidecar *sc = asm_block_slot_sidecar_get(ctx, 0);
  if (sc) {
    sc->block_refs.len = 0;
    sc->slot_bases.len = 0;
  }
}

/** 记录 block_ref 在 sidecar 中的起始槽下标（fill 前调用）。 */
void asm_ctx_block_slot_set(uint8_t *ctx, int32_t block_ref, int32_t slot_base) {
  AsmBlockSlotSidecar *sc;
  int32_t *pr;
  int32_t *pb;
  if (!ctx || block_ref <= 0)
    return;
  if (!(sc = asm_block_slot_sidecar_get(ctx, 1)))
    return;
  if (grow_vec_push(&sc->block_refs) < 0 || grow_vec_push(&sc->slot_bases) < 0)
    return;
  pr = (int32_t *)grow_vec_at(&sc->block_refs, sc->block_refs.len - 1);
  pb = (int32_t *)grow_vec_at(&sc->slot_bases, sc->slot_bases.len - 1);
  if (pr)
    *pr = block_ref;
  if (pb)
    *pb = slot_base;
}

/** 查 block_ref 的起始槽下标；未登记返回 -1。 */
int32_t asm_ctx_block_slot_get(uint8_t *ctx, int32_t block_ref) {
  AsmBlockSlotSidecar *sc;
  int32_t i;
  int32_t *pr;
  int32_t *pb;
  if (!ctx || block_ref <= 0)
    return -1;
  if (!(sc = asm_block_slot_sidecar_get(ctx, 0)))
    return -1;
  for (i = sc->block_refs.len - 1; i >= 0; i--) {
    pr = (int32_t *)grow_vec_at(&sc->block_refs, i);
    if (!pr || *pr != block_ref)
      continue;
    pb = (int32_t *)grow_vec_at(&sc->slot_bases, i);
    return pb ? *pb : -1;
  }
  return -1;
}

/** 前向声明：实现在下文（ensure_block_locals 须按类型步进栈槽）。 */
int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref);
extern struct ast_Module *pipeline_asm_glue_emit_module_ref(void);
extern int32_t asm_bump_off_before_struct_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
extern int32_t asm_bump_off_align_for_local(struct ast_ASTArena *arena, int32_t type_ref, int32_t off);
extern int32_t asm_local_slot_reg_offset(struct ast_ASTArena *arena, int32_t type_ref, int32_t off,
                                         int32_t *inout_off);
extern int32_t pipeline_asm_let_init_stack_reserve_bytes(struct ast_ASTArena *arena, int32_t type_ref,
                                                         int32_t init_ref);
extern int32_t typeck_soa_array_storage_size_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                  int32_t elem_type_ref, int32_t array_len, int32_t depth);
extern int32_t typeck_x_type_size_from_layout_glue(struct ast_Module *module, struct ast_ASTArena *arena,
                                                    int32_t li, int32_t depth);
extern struct ast_PipelineDepCtx *pipeline_asm_emit_dep_pipe_c(void);

static int32_t asm_local_slot_bytes_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod);

/**
 * 在指定模块内查 TYPE_NAMED struct layout 的栈槽字节数。
 * 【Why】typeck skip 时入口模块无 dep struct（如 PageMmapHeap）的 layout，须遍历 dep_ctx 查找；
 *       否则栈槽算成默认 8B，实际 24B，struct 末字段（off）越界覆盖相邻局部变量。
 * 【Invariant】仅查 mod 的 num_struct_layouts；返回 >0 表示命中并对齐到 8 字节，0 表示未命中。
 * 【Asm/Perf】dep_ctx 遍历仅在入口模块未命中时触发，热路径（入口模块 struct）零开销。
 */
static int32_t asm_slot_bytes_named_in_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod) {
  uint8_t name[64];
  int32_t nlen;
  int32_t k;
  if (!arena || type_ref <= 0 || !mod)
    return 0;
  nlen = pipeline_type_named_name_into(arena, type_ref, name);
  if (nlen <= 0 || nlen > 63)
    return 0;
  for (k = 0; k < (int32_t)mod->num_struct_layouts; k++) {
    int32_t ln = pipeline_module_struct_layout_name_len(mod, k);
    int32_t j;
    int32_t eq = 1;
    int32_t sz;
    if (ln != nlen)
      continue;
    for (j = 0; j < nlen; j++) {
      if (pipeline_module_struct_layout_name_byte_at(mod, k, j) != name[j]) {
        eq = 0;
        break;
      }
    }
    if (!eq)
      continue;
    sz = typeck_x_type_size_from_layout_glue(mod, arena, k, 0);
    if (sz <= 0) {
      int32_t nf = pipeline_module_struct_layout_num_fields(mod, k);
      if (nf > 0) {
        int32_t last = nf - 1;
        int32_t foff = pipeline_module_struct_layout_field_offset_at(mod, k, last);
        int32_t fty = pipeline_module_struct_layout_field_type_ref(mod, k, last);
        int32_t fsz = asm_local_slot_bytes_mod(arena, fty, mod);
        if (fsz <= 0)
          fsz = 4;
        sz = foff + fsz;
      }
    }
    if (sz > 0) {
      if (sz % 8 != 0)
        sz += 8 - (sz % 8);
      return sz;
    }
  }
  return 0;
}

/**
 * T[N] 定长数组总字节宽：SoA 列主序或 AoS N×struct layout（与 typeck typeck_x_type_size 一致）。
 * 非 struct 元素或 layout 未命中时返回 0，由调用方回落 esz 启发式。
 */
static int32_t asm_fixed_array_total_bytes_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t soa_sz;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t || pipeline_type_kind_ord_at(arena, type_ref) != 10 || t->array_size <= 0)
    return 0;
  elem_ref = t->elem_type_ref;
  if (elem_ref <= 0)
    return 0;
  if (!mod)
    mod = pipeline_asm_glue_emit_module_ref();
  if (!mod || pipeline_type_kind_ord_at(arena, elem_ref) != 8)
    return 0;
  soa_sz = typeck_soa_array_storage_size_glue(mod, arena, elem_ref, t->array_size, 0);
  if (soa_sz > 0)
    return soa_sz;
  {
    uint8_t ename[64];
    int32_t elen = pipeline_type_named_name_into(arena, elem_ref, ename);
    if (elen > 0 && elen <= 63) {
      int32_t lk;
      for (lk = 0; lk < (int32_t)mod->num_struct_layouts; lk++) {
        int32_t ln = pipeline_module_struct_layout_name_len(mod, lk);
        int32_t j;
        int32_t eq = 1;
        int32_t es;
        if (ln != elen)
          continue;
        for (j = 0; j < elen; j++) {
          if (pipeline_module_struct_layout_name_byte_at(mod, lk, j) != ename[j]) {
            eq = 0;
            break;
          }
        }
        if (!eq)
          continue;
        es = typeck_x_type_size_from_layout_glue(mod, arena, lk, 0);
        if (es > 0)
          return t->array_size * es;
      }
    }
  }
  return 0;
}

/**
 * 从 AsmFuncCtx 前缀读取 module_ref（偏移 16，与 backend.x / pipeline_glue 布局一致）。
 * fill_block_locals_tree 早于 emit 设置 global 时仍可按 layout 算 struct 栈槽宽。
 */
static struct ast_Module *asm_ctx_module_ref(uint8_t *ctx) {
  if (!ctx)
    return NULL;
  return *(struct ast_Module **)(ctx + 16);
}

/**
 * 单个 const/let 栈槽字节；mod 优先，否则回落 g_pipeline_asm_emit_module。
 */
static int32_t asm_local_slot_bytes_mod(struct ast_ASTArena *arena, int32_t type_ref, struct ast_Module *mod) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t esz;
  int32_t lanes;
  int32_t bytes;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 8;
  t = pipeline_arena_type_ptr(arena, type_ref);
  if (!t)
    return 8;
  /** 与 pipeline_type_kind_ord_at / glue_type_size_simple 一致，勿直接读 t->kind。 */
  if (pipeline_type_kind_ord_at(arena, type_ref) == 8) {
    if (!mod)
      mod = pipeline_asm_glue_emit_module_ref();
    {
      int32_t sz = asm_slot_bytes_named_in_mod(arena, type_ref, mod);
      if (sz > 0) {
        if (getenv("SHUX_ASM_EMIT_TRACE")) {
          uint8_t nm[64];
          int32_t nl = pipeline_type_named_name_into(arena, type_ref, nm);
          fprintf(stderr, "shux: local_slot struct %.*s sz=%d\n", (int)nl, nm, (int)sz);
        }
        return sz;
      }
    }
    /** 【Why】typeck skip 时入口模块无 dep struct 的 layout（PageMmapHeap 定义在
     *  std.heap.page_mmap），须遍历 dep_ctx 查找；否则栈槽算成默认 8B，实际 24B，
     *  struct 末字段（off）越界覆盖相邻局部变量（path 数组被 h.off 破坏）。
     * 【Invariant】仅入口模块未命中时触发；dep 模块按 import 顺序线性扫描。
     * 【Asm/Perf】dep struct 局部变量为低频路径（freestanding gate），遍历开销可忽略。 */
    {
      struct ast_PipelineDepCtx *dep = pipeline_asm_emit_dep_pipe_c();
      if (dep) {
        int32_t nd = pipeline_dep_ctx_ndep(dep);
        int32_t di;
        for (di = 0; di < nd; di++) {
          struct ast_Module *dm = pipeline_dep_ctx_module_at(dep, di);
          if (!dm || dm == mod)
            continue;
          {
            int32_t sz = asm_slot_bytes_named_in_mod(arena, type_ref, dm);
            if (sz > 0)
              return sz;
          }
        }
      }
    }
  }
  /** 定长数组 T[N] 按值内联栈槽；SoA 列主序 / AoS N×layout，勿误用 esz=8 指针宽。 */
  if (pipeline_type_kind_ord_at(arena, type_ref) == 10 && t->array_size > 0) {
    elem_ref = t->elem_type_ref;
    {
      int32_t arr_sz = asm_fixed_array_total_bytes_mod(arena, type_ref, mod);
      if (arr_sz > 0) {
        if (arr_sz % 8 != 0)
          arr_sz += 8 - (arr_sz % 8);
        return arr_sz;
      }
    }
    esz = 4;
    if (elem_ref > 0 && elem_ref <= arena->num_types) {
      struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
      if (et) {
        if ((int32_t)et->kind == 2)
          esz = 1;
        else if ((int32_t)et->kind == 14)
          esz = 4;
        else if ((int32_t)et->kind == 8 || (int32_t)et->kind == 4 || (int32_t)et->kind == 5 ||
                 (int32_t)et->kind == 6)
          esz = 8;
      }
    }
    bytes = t->array_size * esz;
    if (bytes < 8)
      bytes = 8;
    if (bytes % 8 != 0)
      bytes = bytes + (8 - (bytes % 8));
    return bytes;
  }
  /** T[] 切片：{ data: *T, length: usize } 16 字节（对齐 codegen.c AST_TYPE_SLICE size）。 */
  if (pipeline_type_kind_ord_at(arena, type_ref) == 11)
    return 16;
  /* TYPE_VECTOR ord==13；或 NAMED i32x4 等拼写（lex IDENT 回落）。 */
  if (!asm_type_is_simd_vector_spelling(arena, type_ref) && pipeline_type_kind_ord_at(arena, type_ref) != 13)
    return 8;
  if (pipeline_type_kind_ord_at(arena, type_ref) != 13) {
    /** NAMED 拼写：lane 数由类型名 x4/x8/x16 或 Vec8i 推断。 */
    lanes = 4;
    if (t->name_len == 5 && t->name[4] == 56)
      lanes = 8;
    if (t->name_len == 6 && t->name[4] == 49 && t->name[5] == 54)
      lanes = 16;
    if (t->name_len == 5 && memcmp(t->name, "Vec8i", 5) == 0)
      lanes = 8;
    esz = 4;
    bytes = lanes * esz;
    if (bytes < 8)
      bytes = 8;
    if (bytes % 8 != 0)
      bytes = bytes + (8 - (bytes % 8));
    return bytes;
  }
  lanes = t->array_size > 0 ? t->array_size : 4;
  esz = 4;
  elem_ref = t->elem_type_ref;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if ((int32_t)et->kind == 2)
        esz = 1;
      else if ((int32_t)et->kind == 14)
        esz = 4;
      else if ((int32_t)et->kind == 8 || (int32_t)et->kind == 4 || (int32_t)et->kind == 5 ||
               (int32_t)et->kind == 6)
        esz = 8;
    }
  }
  bytes = lanes * esz;
  if (bytes < 8)
    bytes = 8;
  if (bytes % 8 != 0)
    bytes = bytes + (8 - (bytes % 8));
  return bytes;
}

/** 公开入口：无 ctx 时仅依赖 g_pipeline_asm_emit_module。 */
int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref) {
  return asm_local_slot_bytes_mod(arena, type_ref, NULL);
}

/**
 * 懒登记 block 内 const/let 到 asm 局部 sidecar（C 实现，避免 .x 生成代码在 if+while 双路径组合时崩溃）。
 * inout_next_offset / inout_num_locals 对应 AsmFuncCtx.next_offset / num_locals。
 * 与 pipeline_asm_fill_local_slots 一致：struct 前 16 字节对齐 + layout 真实槽宽。
 */
void asm_ctx_ensure_block_locals(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                 int32_t *inout_next_offset, int32_t *inout_num_locals) {
  struct ast_Block *b;
  struct ast_Module *mod;
  int32_t i, off, base, nlen, type_ref, init_ref;
  uint8_t name_buf[64];
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  if (asm_ctx_block_slot_get(ctx, block_ref) >= 0)
    return;
  b = block_at(arena, block_ref);
  if (!b)
    return;
  mod = asm_ctx_module_ref(ctx);
  if (!mod)
    mod = pipeline_asm_glue_emit_module_ref();
  base = asm_ctx_local_count(ctx);
  asm_ctx_block_slot_set(ctx, block_ref, base);
  off = *inout_next_offset;
  for (i = 0; i < b->num_consts; i++) {
    nlen = pipeline_block_const_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    pipeline_block_const_name_copy64(arena, block_ref, i, name_buf);
    type_ref = pipeline_block_const_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append(ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    init_ref = pipeline_block_const_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  for (i = 0; i < b->num_lets; i++) {
    nlen = pipeline_block_let_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    pipeline_block_let_name_copy64(arena, block_ref, i, name_buf);
    type_ref = pipeline_block_let_type_ref(arena, block_ref, i);
    {
      int32_t slot_off = asm_local_slot_reg_offset(arena, type_ref, off, &off);
      if (asm_ctx_local_append(ctx, name_buf, nlen, slot_off) < 0)
        return;
    }
    init_ref = pipeline_block_let_init_ref(arena, block_ref, i);
    off += pipeline_asm_let_init_stack_reserve_bytes(arena, type_ref, init_ref);
  }
  *inout_next_offset = off;
  *inout_num_locals = asm_ctx_local_count(ctx);
}

/** 块树遍历栈：压入待访问 block_ref（GrowVec，避免 .x 大栈数组在大模块 asm 单编时 SIGSEGV）。 */
static void asm_block_tree_push_ref(GrowVec *stack, int32_t block_ref) {
  int32_t *slot;
  if (!stack || block_ref <= 0)
    return;
  if (grow_vec_push(stack) < 0)
    return;
  slot = (int32_t *)grow_vec_at(stack, stack->len - 1);
  if (slot)
    *slot = block_ref;
}

/** 将 cur 的 while/for/if 子块压入遍历栈。 */
static void asm_block_tree_push_children(struct ast_ASTArena *arena, GrowVec *stack, int32_t cur) {
  struct ast_Block *b;
  int32_t i, ch;
  if (!arena || !stack || cur <= 0 || !(b = block_at(arena, cur)))
    return;
  for (i = 0; i < b->num_loops; i++) {
    ch = pipeline_block_while_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
  for (i = 0; i < b->num_for_loops; i++) {
    ch = pipeline_block_for_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
  for (i = 0; i < b->num_if_stmts; i++) {
    ch = pipeline_block_if_then_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
    ch = pipeline_block_if_else_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
}

/** 将 cur 的 region/with_arena 子块压入遍历栈（cfg/while/for/if 子块由 asm_block_tree_push_children 处理）。 */
static void asm_block_tree_push_region_children(struct ast_ASTArena *arena, GrowVec *stack, int32_t cur) {
  struct ast_Block *b;
  int32_t i;
  int32_t ch;
  if (!arena || !stack || cur <= 0 || !(b = block_at(arena, cur)))
    return;
  for (i = 0; i < b->num_regions; i++) {
    ch = pipeline_block_region_body_ref(arena, cur, i);
    asm_block_tree_push_ref(stack, ch);
  }
}

/**
 * 函数体块树中全部 const/let 栈槽字节总和（含嵌套 if/while/for 体）；供 compute_frame_size。
 */
int32_t asm_sum_block_local_slot_bytes(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  int32_t i;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_GROW))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      for (i = 0; i < b->num_consts; i++)
        total += asm_local_slot_bytes(arena, pipeline_block_const_type_ref(arena, cur, i));
      for (i = 0; i < b->num_lets; i++)
        total += asm_local_slot_bytes(arena, pipeline_block_let_type_ref(arena, cur, i));
      asm_block_tree_push_children(arena, &stack, cur);
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  return total;
}

/**
 * 统计函数体块树中全部 const/let 槽位数（含 if-then/else、while/for 嵌套体）。
 * 供 backend.x compute_frame_size 使用；C 显式栈避免 .x DFS 栈溢出。
 */
int32_t asm_count_block_stack_slots(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_GROW))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      total += b->num_consts + b->num_lets;
      asm_block_tree_push_children(arena, &stack, cur);
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  return total;
}

/**
 * 定长数组 let 在栈 temp 区占用字节（与 pipeline_glue.c glue_fixed_array_temp_bytes 一致）。
 */
static int32_t asm_fixed_array_temp_bytes(struct ast_ASTArena *arena, int32_t type_ref) {
  struct ast_Type *t;
  int32_t elem_ref;
  int32_t esz;
  int32_t bytes;
  if (!arena || type_ref <= 0 || type_ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, type_ref);
  /* TYPE_ARRAY 序数为 10（与 ast.h AST_TYPE_ARRAY / ast.x TypeKind 一致）；误用 9 会当成 TYPE_PTR 导致 frame 未预留 temp。 */
  if (!t || (int32_t)t->kind != 10 || t->array_size <= 0)
    return 0;
  bytes = asm_fixed_array_total_bytes_mod(arena, type_ref, NULL);
  if (bytes > 0)
    return bytes;
  elem_ref = t->elem_type_ref;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if ((int32_t)et->kind == 2)
        esz = 1;
      else if ((int32_t)et->kind == 14)
        esz = 4;
      else if ((int32_t)et->kind == 8 || (int32_t)et->kind == 4 || (int32_t)et->kind == 5 ||
               (int32_t)et->kind == 6)
        esz = 8;
    }
  }
  bytes = t->array_size * esz;
  return bytes > 0 ? bytes : 0;
}

/**
 * 函数体块树中全部定长数组 let 的 temp 区总字节数；供 compute_frame_size 预留栈空间。
 */
int32_t asm_sum_block_array_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_GROW))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      {
        int32_t li;
        for (li = 0; li < b->num_lets; li++) {
          int32_t tref = pipeline_block_let_type_ref(arena, cur, li);
          total += asm_fixed_array_temp_bytes(arena, tref);
        }
      }
      asm_block_tree_push_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  return total;
}

/**
 * MEM-C1：函数体块树中全部 with_arena 临时 Arena64 栈字节（每 scope 24B，总和对 8 取整）。
 * 供 compute_frame_size 在 array temp 之后预留 wa 区。
 */
int32_t asm_sum_block_wa_temp_bytes(struct ast_ASTArena *arena, int32_t block_ref) {
  GrowVec stack;
  int32_t total = 0;
  int32_t sp;
  int32_t cur;
  struct ast_Block *b;
  int32_t *pref;
  if (!arena || block_ref <= 0)
    return 0;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_GROW))
    return 0;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks || !(b = block_at(arena, cur)))
        continue;
      visits++;
      if (visits > 8192)
        break;
      {
        int32_t ri;
        for (ri = 0; ri < b->num_regions; ri++) {
          if (pipeline_block_region_with_arena_cap_ref(arena, cur, ri) > 0)
            total += 24;
        }
      }
      asm_block_tree_push_children(arena, &stack, cur);
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
  if (total > 0 && total % 8 != 0)
    total += 8 - (total % 8);
  return total;
}

/** 调试：asm 单编大模块时在 stderr 打印当前函数名（SHUX_ASM_FUNC_TRACE=1）。 */
void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len);

void asm_diag_trace_func(uint8_t *name, int32_t name_len) {
  asm_diag_trace_func_idx(-1, name, name_len);
}

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
/** SHUX_ASM_EMIT_ABORT_LO/HI 默认（backend 二分调试）。 */
#define ASM_EMIT_HEAVY_LARGE_ENTRY_LO ASM_EMIT_HEAVY_BACKEND_INDEX_LO
#define ASM_EMIT_HEAVY_LARGE_ENTRY_HI ASM_EMIT_HEAVY_BACKEND_INDEX_HI

/** 大入口 backend（num_funcs>=175）EMIT_HEAVY 槽位阈值（较默认 256 收紧，避免 codegen 宿主栈 Abort）。 */
#define ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD 96
/** backend helper 白名单真 emit 时块树槽位上限（过大仍走索引桩）。 */
#define ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX 48
/** typeck layout helper 允许略大栈帧（merge_dep 双循环 ~110 slot；仍远小于 check_block mega）。 */
#define ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX 128

/** 读 SHUX_ASM_EMIT_ABORT_LO/HI：调试二分定位 Abort 区间（默认见上常量）。 */
static int32_t asm_emit_heavy_abort_lo(void) {
  const char *e = getenv("SHUX_ASM_EMIT_ABORT_LO");
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
  const char *e = getenv("SHUX_ASM_EMIT_ABORT_HI");
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
#ifndef SHUX_PIPELINE_GLUE_STANDALONE_TU
/** runtime.c：dep 模块 asm codegen 时设置的当前 import 逻辑路径（常规 pipeline_x 链）。 */
extern const char *driver_get_current_dep_path_for_codegen(void);
#endif

/**
 * 供 backend.x 读取 dep 路径（避免经 codegen 模块名修饰导致链接符号不一致）。
 * B-strict standalone TU 下 driver_get 由 pipeline_glue_types.inc 声明为 uint8_t *。
 */
uint8_t *asm_driver_current_dep_path_for_codegen(void) {
#ifndef SHUX_PIPELINE_GLUE_STANDALONE_TU
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

/** SHUX_ASM_BUILD_SKIP_TYPECK=1 时 build_shux_asm 走桩路径，避免无 typeck 的大模块 asm emit 栈溢出。 */
static int32_t asm_env_build_skip_typeck(void) {
  const char *e = getenv("SHUX_ASM_BUILD_SKIP_TYPECK");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** SHUX_ASM_STRICT_ORCHESTRATION=1 时 C 编排链才跳过 pipeline 大函数 emit（默认 build_asm 须落真机器码）。 */
static int32_t asm_env_strict_orchestration(void) {
  const char *e = getenv("SHUX_ASM_STRICT_ORCHESTRATION");
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
 * SKIP_TYPECK 全桩模式下仍须保留真实机器码的入口（实验 asm-only 链与 shux_asm 烟囱测试依赖）。
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
      {"run_x_pipeline_impl", 20, 1},
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
      {"typeck_x_ast", 13, 0},
      {"typeck_x_ast_library", 21, 0},
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
   * SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1：experimental 编 parser_parse_bootstrap.o 须 parse_into* 真 emit。
   */
  if (asm_module_is_parser_selfhost(m)) {
    if (getenv("SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") != NULL) {
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
      if (getenv("SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
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
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 20))
    return 1;
  return 0;
}

/** 当前 asm codegen 的 PipelineDepCtx；backend.x 在 emit 循环前设置，供 ENTRY_MODULE_ONLY 入口 -o 判定。 */
static struct ast_PipelineDepCtx *g_asm_skip_pipeline_ctx;

void asm_skip_heavy_set_pipeline_ctx(struct ast_PipelineDepCtx *ctx) {
  g_asm_skip_pipeline_ctx = ctx;
}

/** SHUX_ASM_ENTRY_EMIT_HEAVY=1 时 ENTRY_MODULE_ONLY 真 emit（typeck 第二遍）；仅跳过 pipeline typecheck。 */
static int32_t asm_env_entry_emit_heavy(void) {
  const char *e = getenv("SHUX_ASM_ENTRY_EMIT_HEAVY");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/**
 * 模块内非 extern 函数个数。
 * typeck.x 声明大量 extern pipeline/driver 符号时 num_funcs≈175，可 emit 体仅 ~78。
 */
static int32_t asm_module_num_defined_funcs(struct ast_Module *m) {
  int32_t i, n = 0;
  if (!m)
    return 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      n++;
  }
  return n;
}

/**
 * func_index 在「已定义（非 extern）」函数中的序号（0..ndef-1）；index 为 extern 时返回 -1。
 * EMIT_HEAVY 瘦 typeck 的 #0–#35 须按此序号，勿用含 extern 占位的 raw func_index。
 */
static int32_t asm_module_defined_func_ordinal(struct ast_Module *m, int32_t func_index) {
  int32_t i, ord = 0;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return -1;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return -1;
  for (i = 0; i < func_index; i++) {
    if (pipeline_asm_module_func_is_extern_at(m, i) == 0)
      ord++;
  }
  return ord;
}

/** 模块是否 backend.x 自举单元（asm_codegen_ast 或 M8-tail 薄包装探针）。 */
static int32_t asm_module_is_backend_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 80)
    return 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
  }
  /** 瘦 backend（~100 func）仍含 emit_expr_elf / fill_param_slots 等薄包装符号。 */
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"emit_expr_elf", 13))
      return 1;
  }
  return 0;
}

/** 模块是否 typeck.x 自举单元（含 typeck_x_ast 或合并 glue 后约 168–180 func）。 */
static int32_t asm_module_is_typeck_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 40)
    return 0;
  /** ast.x ndef 规模与 typeck 重叠；须排除 ast_arena_init/ast_placeholder 标记。 */
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_arena_init", 14))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_placeholder", 15))
      return 0;
  }
  /** parser.x ndef≈130–200 勿落入下方 75–155 启发式（误判则走 typeck EMIT 路径）。 */
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      return 0;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      return 0;
  }
  if (pipeline_module_func_name_equal_at(m, 0, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"typeck_x_ast", 13))
      return 1;
  }
  /** ENTRY_MODULE_ONLY 编 typeck.x：按已定义 func 规模识别（extern 占位不计入）。 */
  {
    int32_t ndef = asm_module_num_defined_funcs(m);
    if (ndef >= 75 && ndef <= 155)
      return 1;
    if (ndef >= 160 && ndef <= 180)
      return 1;
  }
  return 0;
}

/**
 * 模块是否 pipeline.x 自举单元（含 extern 占位时 num_funcs 可达 ~70；按 resolve_path_x 等符号名判定）。
 */
static int32_t asm_module_is_pipeline_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_resolve;
  int32_t has_marker;
  if (!m || m->num_funcs < 12)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m))
    return 0;
  has_resolve = 0;
  has_marker = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"resolve_path_x", 15))
      has_resolve = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
      has_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"path_append_from_buf_256", 24))
      has_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"read_file_x", 12))
      has_marker = 1;
  }
  return has_resolve != 0 && has_marker != 0;
}

/**
 * 模块是否 main.x 驱动单元（~28 func；entry + run_compiler_x_path_impl）。
 * build_asm/main.o 须走 SKIP 桩 + WPO，勿当用户程序全量 emit（9460B）。
 */
static int32_t asm_module_is_main_driver_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_entry;
  int32_t has_run_path;
  int32_t ndef;
  if (!m)
    return 0;
  ndef = asm_module_num_defined_funcs(m);
  if (ndef < 12 || ndef > 48)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m) ||
      asm_module_is_pipeline_selfhost(m) || asm_module_is_parser_selfhost(m))
    return 0;
  has_entry = 0;
  has_run_path = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"entry", 5))
      has_entry = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_x_path_impl", 25))
      has_run_path = 1;
  }
  return has_entry != 0 && has_run_path != 0;
}

/**
 * 模块是否 driver/compile.x 自举单元（~26 func；compile_dispatch_* 可能未进 module 表，用 parse_argv + entry 判定）。
 */
static int32_t asm_module_is_driver_compile_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_parse_argv;
  int32_t has_entry;
  if (!m || m->num_funcs < 8 || m->num_funcs > 48)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_typeck_selfhost(m) ||
      asm_module_is_pipeline_selfhost(m) || asm_module_is_parser_selfhost(m))
    return 0;
  has_parse_argv = 0;
  has_entry = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"driver_compile_parse_argv", 25))
      has_parse_argv = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"run_compiler_full_x", 20))
      has_entry = 1;
    /** gen.o 路径可能注册 dispatch；单编 compile.x 时常缺失，作可选辅助。 */
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"compile_dispatch_asm_backend", 28))
      has_parse_argv = 1;
  }
  return has_parse_argv != 0 && has_entry != 0;
}

/**
 * 模块是否 parser.x 自举单元（~288 func；parse_into_buf 可能未进 module 表，用 parse_into_init 等判定）。
 * strict 链 parse_into_* 真机码由 pipeline_x partial / C alias 提供；func 数 >200 时仍须识别，否则
 * whitelist 会对 parse_into_buf 真 emit → .L_* 未解析 / code_len 截断。
 */
static int32_t asm_module_is_parser_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_parse_marker;
  int32_t has_reset;
  if (!m || m->num_funcs < 150 || m->num_funcs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  has_parse_marker = 0;
  has_reset = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      has_reset = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_init", 15))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"parse_into_set_main_index", 25))
      has_parse_marker = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"skip_one_struct_into_buf", 24))
      has_parse_marker = 1;
  }
  /** reset 已足够识别 parser.x；勿被 typeck ndef 启发式抢先（2026-06-14）。 */
  if (has_reset != 0 && has_parse_marker == 0 && m->num_funcs >= 200)
    has_parse_marker = 1;
  if (has_reset == 0)
    return 0;
  if (asm_module_is_typeck_selfhost(m) && has_parse_marker == 0)
    return 0;
  return has_parse_marker != 0;
}

/** EMIT_HEAVY 第二遍：parser.x 识别（reset 计数器存在即可；marker 偶发缺失时仍走 parser 路径）。 */
static int32_t asm_module_is_parser_emit_heavy(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 150 || m->num_funcs > 1450)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m))
    return 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"pipeline_module_reset_parse_counters", 36))
      return 1;
  }
  return asm_module_is_parser_selfhost(m);
}

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

/** typeck EMIT_HEAVY 第二遍：按名判定可安全真 emit 的小 helper（扩 __text 过 8KiB）。 */
static int32_t asm_typeck_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"name_equal", 10))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "ensure_", 7))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "find_or_alloc_", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_name", 18))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_field_name", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_path_slice", 24))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_binding_name", 26))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_import_select_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_top_level_let_name", 25))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_find_layout_idx", 22))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_x_named_builtin_", 24))
    return 1;
  /** §11.1 align/size：layout 命中走 C glue，X 真 emit 递归/array 分支（勿 metrics depth slot）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 1;
  /** §11.1 metrics：scratch 预绑定 + typeck_i32_ptr_store 写 out；槽位≤96 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_struct_layout_metrics", 28))
    return 1;
  /** import 合并 / struct_lit 登记：scratch 预绑定 + glue 读 num_struct_layouts。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ensure_primitive_by_kind_ord", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_find_or_alloc_compound_type_ref", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ensure_struct_layout_from_struct_lit", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_dep_return_type_in_caller_arena", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"dep_return_type_to_caller_arena", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_offset_from_layout_deps", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"get_field_type_ref_from_layout_deps", 35))
    return 1;
  /** FIELD_ACCESS 内联池字段 / Expr 标量回落：小 helper X 真 emit（layout_deps/name_fallback 已真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_inline_u8_64_array_field_type_ref", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_inline_array_field_type_ref", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_field_access_fallback_scalar_type_ref", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_field_access_lexer_wrapper_fallback", 42))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry_module_find_struct_layout_index", 37))
    return 1;
  /** ord>45 小 helper：import 路径分段 / diag 追加 / 隐式 return 判定 / parent 链 patch。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_path_segment_count", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_segment_at", 24))
    return 1;
  /** ord>58：diag 缓冲追加（小循环体；fmt_* 仍 mega 桩）。 */
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_diag_append_", 19))
    return 1;
  /** diag fmt 族：glue 读类型池 + 局部序数；勿 ast_arena_type_get 按值 Type。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_at", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_into", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_or_question", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_resolve_scan_dep_with_apply", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_return_type", 31))
    return 1;
  /** 隐式尾返回判定：tail ref 扫描 + ast_expr_disallows_implicit_tail（patch 4096 后 X 真 emit）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_tail_expr_ref_for_implicit_rule", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_has_implicit_return_tail", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_cmp", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_method_call_arg", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_as", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_struct_lit_field", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_field_access", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_const", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_let", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_while", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_for", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_one_if", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_final", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_binop_arith", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module_by_name", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_whole_import_qualified_call_return_type", 47))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_binding_import_return_type", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_select_import_return_type", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_local_module", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_whole_import", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_try_binding_import", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_scan_dep", 28))
    return 1;
  /** S2 X 真 emit：expr/type 小 helper（glue 指针读池；勿 Type 按值 ast_arena_type_get）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_type_ref", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool_impl", 21))
    return 1;
  /** type_refs_equal 薄包装可 X emit；拆分 named/same_kind/impl 逐步 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_impl", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_return_operand_matches", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_integer_widen_ok", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_var_name_equal_func", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_to_expect_i32", 40))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_widen", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_expr_to_decl", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_named", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_same_kind", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_lit_to_decl", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_enum_field_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_float_lit_to_decl", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_named_call_to_decl", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_array_vector_lit_to_decl", 43))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_vector_binop_to_decl", 39))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_slice_from_array", 35))
    return 1;
  /** validate 薄循环：metrics/align/size 仍 mega/thin stub（独立 X emit SIGSEGV）；本函数 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_validate_struct_layouts_zero_padding", 43))
    return 1;
  /** typeck_x_ast 薄入口见 mega_entry；check_block 薄 guard 仍 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_as_loop_body", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_push", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_loop_depth_pop", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_patch_all_body_parent_links", 34))
    return 1;
  /** check_expr/check_block 薄 guard→check_*_impl；impl/mega 走 asm_skip_heavy_typeck_mega_entry 桩。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10))
    return 1;
  /** check_expr mega 分派子 helper（assign/index/unary/addr/deref/var/return/panic）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_expr_is_any_assign_kind", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_assign", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_index", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_unary", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_addr_of", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_deref", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_var", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_return", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_panic", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_break_continue", 32))
    return 1;
  /** check_block_impl 编排子 helper（stmt_order/impl 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_consts", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_lets", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_whiles", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_fors", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_ifs", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_legacy_expr_stmts", 36))
    return 1;
  /** check_expr_impl 小 kind 子 helper（impl/mega 主体 mega 桩）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_int_lit", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_bool_lit", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_float_lit", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_enum_variant", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_block", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_if_ternary", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_match_arm", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_arg", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_expr_call_resolve", 30))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  return 0;
}

/**
 * pipeline EMIT_HEAVY 第二遍：编排 helper X 真 emit；parse/typecheck 关键路径 thin→C（strict smoke）。
 * S3：resolve/read 经 weak→强符号 dispatch（build_asm 覆盖 impl_c）。
 */
static int32_t asm_pipeline_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"parse_one_function_ok", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_loaded_buf_cap", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_if_needed", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_entry", 31))
    return 1;
  /** parse set_main + typeck 分派：if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_parse_set_main_from_buf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_parsed_module", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_typeck_entry_module", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_fill_dep_import_path", 36))
    return 1;
  /** import 路径含 '.' 探测：纯 while，无 let=CALL。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_import_has_dot", 27))
    return 1;
  /** 单 import resolve+read：X 栈 path + if(CALL!=0) return。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_resolve_read", 33))
    return 1;
  /** 单 import 全链 resolve/read/preprocess/parse；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_import_from_disk", 30))
    return 1;
  /** 单 import 槽 bind 或 load_from_disk；X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_one_import_slot", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_prepare_dep_codegen_path", 33))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_finish_dep_codegen_diag", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_parse_entry_do_parse", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_one_dep", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_entry", 29))
    return 1;
  /** sync 入口：null 检查 + 有界 while(CALL!=0) + if(sync_one) X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_sync_dep_slots_from_driver", 35))
    return 1;
  /** dep 批量 codegen：有界 while + run_x_pipeline_codegen_one_dep X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_codegen_deps", 28))
    return 1;
  /** load/sync deps：import 有界 while + sync/typeck merge X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"pipeline_load_and_sync_direct_import_deps", 41))
    return 1;
  /** resolve 编排：lib_root while + try_* CALL（try_* 仍 thin→C）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_x", 15))
    return 1;
  /** resolve try_*：sidecar off + if(CALL) 模式 X 真 emit。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_one_lib_root", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_entry_dir", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_path_try_flat_import_under_lib", 38))
    return 1;
  /** 完整流水线编排：run_x_pipeline_impl X 真 emit（if(CALL)+last_rc_get 模式）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_impl", 20))
    return 1;
  /** load/typecheck phase 编排 + last_rc sidecar。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_load_deps_after_parse", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_x_pipeline_typecheck_after_load", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_typeck_after_load", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"lsp_diag_parse_typeck_buf", 25))
    return 1;
  return 0;
}

/**
 * driver/compile.x EMIT_HEAVY 第二遍：argv 分 helper + dispatch X 真 emit；post_parse / run_compiler_full_x 仍桩。
 */
static int32_t asm_driver_compile_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_asm_backend", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compile_dispatch_emit_c_path", 28))
    return 1;
  /** driver_compile_gen.o 导出带 driver_ 前缀；module 表多为裸名，二者均匹配。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_asm_backend", 35))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_dispatch_emit_c_path", 35))
    return 1;
  /** run_compiler_full_x* 大栈/复杂分派：EMIT_HEAVY 堆 state + post_parse/dispatch X 真 emit（thin 表已空）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_state_key", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_ensure_default_lib", 29))
    return 1;
  /** parse_argv 分 helper：init/step/loop/finalize/入口 X 真 emit（单函数双 512 栈数组 SIGSEGV）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_init", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_step", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_loop", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_finalize", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_compile_parse_argv_scan_c", 31))
    return 0;
  /** run_compiler_full_x / post_parse：堆 state + dispatch X 真 emit（勿 thin→impl_c）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_compiler_full_x_post_parse", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"driver_run_compiler_full_x_post_parse", 38))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"path_ends_x", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"target_has_arm", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "eq_", 3))
    return 1;
  return 0;
}

/**
 * backend EMIT_HEAVY 第二遍：按符号名保留小 helper 真 emit（覆盖 #87+ 索引桩；219 func 模块中 arch_emit/enc 常在 #87 之后）。
 * M8-tail：fold_/asm_import_ 等前缀体 + 薄包装 C 委托函数按名放行。
 */
static int32_t asm_skip_heavy_backend_m8_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_M8_HLP_PREFIX(pfx, plen)                                                                                  \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  ASMB_M8_HLP_PREFIX("asm_import_", 11);
  ASMB_M8_HLP_PREFIX("asm_build_import_", 17);
  ASMB_M8_HLP_PREFIX("asm_c_prefix_", 13);
  ASMB_M8_HLP_PREFIX("fold_", 5);
  ASMB_M8_HLP_PREFIX("asm_module_named_", 17);
  ASMB_M8_HLP_PREFIX("asm_expr_binop_", 15);
  ASMB_M8_HLP_PREFIX("asm_field_access_", 17);
#undef ASMB_M8_HLP_PREFIX
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_push_loop_labels", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_pop_loop_labels", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_hoist_top_level_lets_for_codegen", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ctx_reset", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  /** M8-tail：形参/局部槽与 ELF/text 块体薄包装（单行 C 委托），扩 backend.o __text。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  return 0;
}

/** 旧名别名：arch_emit_/enc_ 前缀 helper。 */
static int32_t asm_skip_heavy_backend_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_KEEP_PREFIX(pfx)                                                                                            \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(sizeof(pfx) - 1)))                     \
      return 1;                                                                                                        \
  } while (0)
  ASMB_KEEP_PREFIX("arch_emit_");
  ASMB_KEEP_PREFIX("enc_");
#undef ASMB_KEEP_PREFIX
  return 0;
}

/**
 * M8-tail：backend.x 薄包装 X 名 → C glue/partial 委托符号。
 * 首遍 SKIP 桩路径 emit bl（非 ret0），扩 build_asm/backend.o __text。
 */
typedef struct {
  const char *x_name;
  int32_t x_len;
  const char *c_name;
  int32_t c_len;
} AsmBackendThinDelegateRow;

static const AsmBackendThinDelegateRow k_asm_backend_thin_delegate[] = {
    {"fill_param_slots", 16, "pipeline_asm_fill_param_slots", 29},
    {"fill_local_slots", 16, "pipeline_asm_fill_local_slots", 29},
    {"compute_frame_size", 18, "pipeline_asm_compute_frame_size_c", 33},
    {"emit_block_body_elf", 19, "backend_emit_block_body_sync_elf", 32},
    {"emit_block_inits_elf", 20, "pipeline_asm_emit_block_inits_elf_c", 35},
    {"emit_if_then_block_body_elf", 27, "pipeline_asm_emit_if_then_block_body_elf_c", 42},
    {"emit_while_loop_elf", 18, "pipeline_asm_emit_while_loop_elf_c", 34},
    {"emit_for_loop_elf", 16, "pipeline_asm_emit_for_loop_elf_c", 32},
    {"emit_loop_body_content", 22, "pipeline_asm_emit_loop_body_content_c", 35},
    {"emit_loop_body_content_elf", 26, "pipeline_asm_emit_loop_body_content_elf_c", 39},
    {"emit_next_label", 15, "pipeline_asm_emit_next_label_c", 30},
    {"format_label_id", 15, "pipeline_asm_format_label_id_c", 30},
    {"emit_expr_elf_call", 18, "pipeline_asm_emit_call_elf_c", 28},
    {"emit_expr_elf_method_call", 25, "pipeline_asm_emit_method_call_elf_c", 35},
    {"asm_emit_call_args_elf", 22, "pipeline_asm_emit_call_args_elf_c", 33},
    {"emit_block_inits", 16, "pipeline_asm_emit_block_inits_c", 31},
    {"emit_block_body", 15, "pipeline_asm_emit_block_body_c", 30},
    {"emit_while_loop", 15, "pipeline_asm_emit_while_loop_c", 30},
    {"emit_for_loop", 13, "pipeline_asm_emit_for_loop_c", 28},
    {"emit_if_then_block_body_text", 28, "pipeline_asm_emit_if_then_block_body_text_c", 43},
    {"emit_expr", 9, "pipeline_asm_emit_expr_c", 24},
    {"emit_expr_call", 14, "pipeline_asm_emit_expr_call_c", 29},
    {"emit_expr_method_call", 21, "pipeline_asm_emit_expr_method_call_c", 36},
    {"emit_expr_elf", 13, "pipeline_asm_emit_expr_elf_c", 28},
    {"emit_index_eff_addr_text", 24, "pipeline_asm_emit_index_eff_addr_text_c", 39},
    {"emit_index_eff_addr_elf", 23, "pipeline_asm_emit_index_eff_addr_elf_c", 38},
    {"emit_lvalue_eff_addr_text", 25, "pipeline_asm_emit_lvalue_eff_addr_text_c", 40},
    {"emit_lvalue_eff_addr_elf", 24, "pipeline_asm_emit_lvalue_eff_addr_elf_c", 39},
    {"asm_emit_call_args_text", 23, "pipeline_asm_emit_call_args_text_c", 33},
    {"local_offset", 12, "pipeline_asm_local_offset_c", 27},
    {"asm_resolve_whole_import_qualified_symbol", 41, "pipeline_asm_resolve_whole_import_qualified_symbol_c", 52},
    {"emit_skip_heavy_stub_elf", 24, "pipeline_asm_emit_skip_heavy_stub_elf_c", 39},
    {"simd_try_inline_shuffle_call_elf", 32, "pipeline_asm_simd_try_inline_shuffle_call_elf_c", 47},
    {"simd_try_inline_select_call_elf", 31, "pipeline_asm_simd_try_inline_select_call_elf_c", 46},
    {"simd_try_inline_binop2_call_elf", 31, "pipeline_asm_simd_try_inline_binop2_call_elf_c", 46},
    {"simd_try_inline_fma3_call_elf", 29, "pipeline_asm_simd_try_inline_fma3_call_elf_c", 46},
    {"asm_codegen_ast", 15, "pipeline_backend_asm_codegen_ast_c", 34},
    {"asm_codegen_ast_to_elf", 22, "pipeline_backend_asm_codegen_ast_to_elf_c", 41},
};

/**
 * 查 backend 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_backend_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                  int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_backend_thin_delegate) / sizeof(k_asm_backend_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_backend_thin_delegate[i].x_name,
                                           k_asm_backend_thin_delegate[i].x_len)) {
      if (k_asm_backend_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_backend_thin_delegate[i].c_name, (size_t)k_asm_backend_thin_delegate[i].c_len);
      out[k_asm_backend_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_backend_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** M8-tail：parse/typecheck entry 薄 bl→C（do_parse 仍 X emit 调 set_main thin→C）。 */
static const AsmBackendThinDelegateRow k_asm_pipeline_thin_delegate[] = {
    {"pipeline_parse_set_main_from_buf", 32, "pipeline_parse_set_main_from_buf_c", 34},
    {"pipeline_should_skip_x_typeck", 30, "pipeline_should_skip_x_typeck_c", 32},
    {"run_x_pipeline_typecheck_entry", 31, "run_x_pipeline_typecheck_entry_emit_c", 36},
};

/**
 * 查 pipeline 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_pipeline_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                   int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_pipeline_thin_delegate) / sizeof(k_asm_pipeline_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_pipeline_thin_delegate[i].x_name,
                                           k_asm_pipeline_thin_delegate[i].x_len)) {
      if (k_asm_pipeline_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_pipeline_thin_delegate[i].c_name, (size_t)k_asm_pipeline_thin_delegate[i].c_len);
      out[k_asm_pipeline_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_pipeline_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** M8-tail：parser.x 薄包装 X 名 → parser_asm_thin_c.c *_glue 或 pipeline_glue *_c（EMIT_HEAVY bl 扩 __text）。
 * slot_fallback / safe_helper 真 emit：collect_imports_buf / parse_one_function_library_buf 等。 */
static const AsmBackendThinDelegateRow k_asm_parser_thin_delegate[] = {
    {"collect_imports_buf", 19, "parser_collect_imports_buf_glue", 31},
    {"advance_past_cond_rparen_into", 29, "parser_advance_past_cond_rparen_into_glue", 41},
    {"advance_past_stmt_semicolon_into", 32, "parser_advance_past_stmt_semicolon_into_glue", 44},
    {"alloc_pointee_type_ref_from_tok", 31, "parser_alloc_pointee_type_ref_from_tok_glue", 43},
    {"append_block_lets_from_res", 26, "parser_append_block_lets_from_res_glue", 38},
    {"body_skip_let_const_then_if_buf", 31, "parser_body_skip_let_const_then_if_buf_glue", 43},
    {"body_skip_let_const_then_if", 27, "parser_body_skip_let_const_then_if_glue", 39},
    {"body_skip_let_const_then_if_into", 32, "parser_body_skip_let_const_then_if_into_glue", 44},
    {"collect_imports", 15, "parser_collect_imports_glue", 27},
    {"copy_lex_from_import_into", 25, "parser_lex_copy_from_import_into_glue", 38},
    {"consume_qualified_type_ident_name", 33, "parser_consume_qualified_type_ident_name_glue", 45},
    {"diag_after_imports_then_structs", 31, "parser_diag_after_imports_then_structs_glue", 43},
    {"diag_fail_at_token_kind", 23, "parser_diag_fail_at_token_kind_glue", 35},
    {"diag_first_ident_len", 20, "parser_diag_first_ident_len_glue", 32},
    {"diag_lex_after_imports", 22, "parser_diag_lex_after_imports_glue", 34},
    {"diag_skip_let_const_buf", 23, "parser_diag_skip_let_const_buf_glue", 35},
    {"diag_skip_let_const", 19, "parser_diag_skip_let_const_glue", 31},
    {"diag_skip_let_const_into", 24, "parser_diag_skip_let_const_into_glue", 36},
    {"expr_set_common_zeros", 21, "parser_expr_set_common_zeros_glue", 33},
    {"fill_block_const_let_from_res", 29, "parser_fill_block_const_let_from_res_glue", 41},
    {"finish_struct_lit_from_type_ident_into", 38, "parser_finish_struct_lit_from_type_ident_into_glue", 50},
    {"first_token_kind", 16, "parser_first_token_kind_glue", 28},
    {"lex_at_token_from_result", 24, "parser_lex_at_token_from_result_glue", 36},
    {"lex_from_library", 16, "parser_lex_from_library_glue", 28},
    {"lex_from_library_into", 21, "parser_lex_from_library_into_glue", 33},
    {"lex_from_onefunc_next_into", 26, "parser_lex_from_onefunc_next_into_glue", 38},
    {"lex_from_next_into", 18, "parser_lex_from_next_into_glue", 30},
    {"lex_from_result_ptr_into", 24, "parser_lex_from_result_ptr_into_glue", 36},
    {"lex_from_try_skip", 17, "parser_lex_from_try_skip_glue", 29},
    {"lex_from_try_skip_into", 22, "parser_lex_from_try_skip_into_glue", 34},
    {"module_append_enum_variants_and_skip_body_into", 46, "parser_module_append_enum_variants_and_skip_body_into_glue", 58},
    {"parse_addsub_into", 17, "parser_parse_addsub_into_glue", 29},
    {"parse_as_suffix_into", 20, "parser_parse_as_suffix_into_glue", 32},
    {"parse_assign_into", 17, "parser_parse_assign_into_glue", 29},
    {"parse_at_simd_builtin_into", 26, "parser_parse_at_simd_builtin_into_glue", 38},
    {"parse_bitand_into", 17, "parser_parse_bitand_into_glue", 29},
    {"parse_bitor_into", 16, "parser_parse_bitor_into_glue", 28},
    {"parse_bitxor_into", 17, "parser_parse_bitxor_into_glue", 29},
    {"parse_body_let_bracket_compound_init_ref", 40, "parser_parse_body_let_bracket_compound_init_ref_glue", 52},
    {"parse_cast_into", 15, "parser_parse_cast_into_glue", 27},
    {"parse_compare_into", 18, "parser_parse_compare_into_glue", 30},
    {"parse_cond_expr_into", 20, "parser_parse_cond_expr_into_glue", 32},
    {"parse_if_expr_into", 18, "parser_parse_if_expr_into_glue", 30},
    {"parse_if_stmt_into", 18, "parser_parse_if_stmt_into_glue", 30},
    {"parse_into_try_skip_allow_buf", 29, "parser_parse_into_try_skip_allow_buf_glue", 41},
    {"parse_into_try_skip_allow", 25, "parser_parse_into_try_skip_allow_glue", 37},
    {"parse_into_try_skip_allow_into_buf", 34, "parser_parse_into_try_skip_allow_into_buf_glue", 46},
    {"parse_into_try_skip_allow_into", 30, "parser_parse_into_try_skip_allow_into_glue", 42},
    {"parse_into_set_main_index", 25, "parser_parse_into_set_main_index_glue", 37},
    {"parse_logand_into", 17, "parser_parse_logand_into_glue", 29},
    {"parse_logor_into", 16, "parser_parse_logor_into_glue", 28},
    {"parse_match_into", 16, "parser_parse_match_into_glue", 28},
    {"parse_match_subject_into", 24, "parser_parse_match_subject_into_glue", 36},
    {"parse_one_extern_and_add_into_buf", 33, "parser_parse_one_extern_and_add_into_buf_glue", 45},
    {"parse_one_extern_and_add_into", 29, "parser_parse_one_extern_and_add_into_glue", 41},
    {"parse_one_extern_skip_into", 26, "parser_parse_one_extern_skip_into_glue", 38},
    {"parse_one_function_buf_into", 27, "parser_parse_one_function_buf_into_glue", 39},
    {"parse_one_function_library", 26, "parser_parse_one_function_library_glue", 38},
    {"parse_one_function_library_into", 31, "parser_parse_one_function_library_into_glue", 43},
    {"parse_one_function_library_scan", 31, "parser_parse_one_function_library_scan_glue", 43},
    {"parse_one_top_level_let_into", 28, "parser_parse_one_top_level_let_into_glue", 40},
    {"parse_primary_into", 18, "parser_parse_primary_into_glue", 30},
    {"parse_relcompare_into", 21, "parser_parse_relcompare_into_glue", 33},
    {"parse_shift_into", 16, "parser_parse_shift_into_glue", 28},
    {"parse_struct_record_layout_into", 31, "parser_parse_struct_record_layout_into_glue", 43},
    {"parse_term_into", 15, "parser_parse_term_into_glue", 27},
    {"parse_ternary_into", 18, "parser_parse_ternary_into_glue", 30},
    {"parse_type_ref_for_arena_into", 29, "parser_parse_type_ref_for_arena_into_glue", 41},
    {"parse_unary_into", 16, "parser_parse_unary_into_glue", 28},
    {"parser_rewind_lex_for_following_stmt", 36, "parser_parser_rewind_lex_for_following_stmt_glue", 48},
    {"parser_vector_type_ref_from_ident_spelling", 42, "parser_parser_vector_type_ref_from_ident_spelling_glue", 54},
    {"skip_balanced_braces_buf", 24, "parser_skip_balanced_braces_buf_glue", 36},
    {"skip_balanced_braces", 20, "parser_skip_balanced_braces_glue", 32},
    {"skip_balanced_braces_into", 25, "parser_skip_balanced_braces_into_glue", 37},
    {"skip_balanced_parens_buf", 24, "parser_skip_balanced_parens_buf_glue", 36},
    {"skip_balanced_parens", 20, "parser_skip_balanced_parens_glue", 32},
    {"skip_balanced_parens_into", 25, "parser_skip_balanced_parens_into_glue", 37},
    {"skip_imports", 12, "parser_skip_imports_glue", 24},
    {"skip_one_enum_buf", 17, "parser_skip_one_enum_buf_glue", 29},
    {"skip_one_enum", 13, "parser_skip_one_enum_glue", 25},
    {"skip_one_enum_into", 18, "parser_skip_one_enum_into_glue", 30},
    {"skip_one_enum_into_buf", 22, "parser_skip_one_enum_into_buf_glue", 34},
    {"skip_one_enum_register_into_buf", 31, "parser_skip_one_enum_register_into_buf_glue", 43},
    {"skip_one_enum_register_into", 27, "parser_skip_one_enum_register_into_glue", 39},
    {"skip_one_extern_buf", 19, "parser_skip_one_extern_buf_glue", 31},
    {"skip_one_extern", 15, "parser_skip_one_extern_glue", 27},
    {"skip_one_extern_into_buf", 24, "parser_skip_one_extern_into_buf_glue", 36},
    {"skip_one_extern_into", 20, "parser_skip_one_extern_into_glue", 32},
    {"skip_one_function_full_buf", 26, "parser_skip_one_function_full_buf_glue", 38},
    {"skip_one_function_full", 22, "parser_skip_one_function_full_glue", 34},
    {"skip_one_function_full_into_buf", 31, "parser_skip_one_function_full_into_buf_glue", 43},
    {"skip_one_function_full_into", 27, "parser_skip_one_function_full_into_glue", 39},
    {"skip_one_if_core_buf", 20, "parser_skip_one_if_core_buf_glue", 32},
    {"skip_one_if_core", 16, "parser_skip_one_if_core_glue", 28},
    {"skip_one_if_core_into", 21, "parser_skip_one_if_core_into_glue", 33},
    {"skip_one_if_statement_buf", 25, "parser_skip_one_if_statement_buf_glue", 37},
    {"skip_one_if_statement", 21, "parser_skip_one_if_statement_glue", 33},
    {"skip_one_if_statement_into", 26, "parser_skip_one_if_statement_into_glue", 38},
    {"skip_one_impl_buf", 17, "parser_skip_one_impl_buf_glue", 29},
    {"skip_one_impl", 13, "parser_skip_one_impl_glue", 25},
    {"skip_one_impl_into_buf", 22, "parser_skip_one_impl_into_buf_glue", 34},
    {"skip_one_impl_into", 18, "parser_skip_one_impl_into_glue", 30},
    {"skip_one_struct_buf", 19, "parser_skip_one_struct_buf_glue", 31},
    {"skip_one_struct", 15, "parser_skip_one_struct_glue", 27},
    {"skip_one_struct_into_buf", 24, "parser_skip_one_struct_into_buf_glue", 36},
    {"skip_one_struct_into", 20, "parser_skip_one_struct_into_glue", 32},
    {"skip_one_trait_buf", 18, "parser_skip_one_trait_buf_glue", 30},
    {"skip_one_trait", 14, "parser_skip_one_trait_glue", 26},
    {"skip_one_trait_into_buf", 23, "parser_skip_one_trait_into_buf_glue", 35},
    {"skip_one_trait_into", 19, "parser_skip_one_trait_into_glue", 31},
    {"struct_field_name_from_tok", 26, "parser_struct_field_name_from_tok_glue", 38},
    {"parser_token_is_label_start", 27, "parser_token_is_label_start_glue", 32},
    {"parser_should_wrap_func_tail_in_return", 38, "parser_should_wrap_func_tail_in_return_glue", 43},
    {"pipeline_module_reset_parse_counters", 36, "pipeline_module_reset_parse_counters_c", 38},
    {"try_skip_allow_padding_struct_buf", 33, "parser_try_skip_allow_padding_struct_buf_glue", 45},
    {"try_skip_allow_padding_struct", 29, "parser_try_skip_allow_padding_struct_glue", 41},
};


/** parser EMIT_HEAVY 第二遍：槽位 fallback 上限（>16 无增量；2026-06-14 提至 16）。 */
#define ASM_EMIT_HEAVY_PARSER_SLOT_MAX 16

/** SHUX_ASM_DEBUG=1 时打印 parser EMIT_HEAVY 真 emit 决策（定位 seed_mega SIGSEGV）。 */
static void asm_parser_emit_heavy_dbg_real(struct ast_Module *m, int32_t fi, const char *why) {
  uint8_t fn[64];
  int32_t fl;
  if (!getenv("SHUX_ASM_DEBUG") || !m || fi < 0 || !why)
    return;
  fl = pipeline_module_func_name_len_at(m, fi);
  pipeline_module_func_name_copy64(m, fi, fn);
  fprintf(stderr, "shux: parser REAL_EMIT fi=%d fn=%.*s why=%s\n", fi, (int)(fl > 63 ? 63 : fl), fn, why);
  fflush(stderr);
}

/** 调试/二分：SHUX_PARSER_EMIT_HEAVY_BISECT_N=N 上限 func_index；STUB_ONLY=1 仅 delegate 桩。 */
static int32_t asm_parser_emit_heavy_bisect_max_index(void) {
  const char *stub = getenv("SHUX_PARSER_EMIT_HEAVY_STUB_ONLY");
  char *end = NULL;
  long v;
  const char *e;
  if (stub != NULL && stub[0] != '\0' && stub[0] != '0')
    return 0;
  e = getenv("SHUX_PARSER_EMIT_HEAVY_BISECT_N");
  if (!e || e[0] == '\0')
    return 2147483647;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 2147483647;
  if (v > 2147483647L)
    return 2147483647;
  return (int32_t)v;
}

/** SHUX_PARSER_EMIT_HEAVY_SLOT_MAX=N 覆盖槽位 fallback 上限（默认 8）。 */
static int32_t asm_parser_emit_heavy_slot_max(void) {
  const char *e = getenv("SHUX_PARSER_EMIT_HEAVY_SLOT_MAX");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
  if (v > 512)
    return 512;
  return (int32_t)v;
}

/**
 * SHUX_ASM_PARSER_MEGA_BISECT=<name>：单项 mega 跳过 ret0 桩以 X 真 emit（bisect 门禁用）。
 */
static int32_t asm_parser_mega_bisect_skip_stub(struct ast_Module *m, int32_t func_index, const char *name,
                                                int32_t len) {
  const char *b;
  size_t blen;
  if (!m || func_index < 0 || !name || len <= 0)
    return 0;
  b = getenv("SHUX_ASM_PARSER_MEGA_BISECT");
  if (!b || b[0] == '\0')
    return 0;
  blen = strlen(b);
  if ((int32_t)blen != len)
    return 0;
  if (memcmp(b, name, (size_t)len) != 0)
    return 0;
  return pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)name, len);
}

/**
 * PARSE_BOOTSTRAP_EMIT 时 mega 入口是否允许 X 真 emit；MINIMAL 仅 parse_into_init / set_main_index。
 */
static int32_t asm_parser_bootstrap_mega_emit_allowed(struct ast_Module *m, int32_t func_index, const char *name,
                                                      int32_t len) {
  static const asm_boot_parse_sym_t k_min[] = {
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
  };
  static const asm_boot_parse_sym_t k_full[] = {
      {"parse_into_buf", 14},
      {"parse_into", 10},
      {"parse_into_init", 15},
      {"parse_into_set_main_index", 25},
      {"collect_imports_buf", 19},
  };
  const asm_boot_parse_sym_t *k;
  int32_t kn;
  int32_t i;
  if (!m || func_index < 0 || getenv("SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT") == NULL)
    return 0;
  if (!pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)name, len))
    return 0;
  if (getenv("SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT_MINIMAL") != NULL) {
    k = k_min;
    kn = (int32_t)(sizeof(k_min) / sizeof(k_min[0]));
  } else {
    k = k_full;
    kn = (int32_t)(sizeof(k_full) / sizeof(k_full[0]));
  }
  for (i = 0; i < kn; i++) {
    if (k[i].len == len && memcmp(k[i].name, name, (size_t)len) == 0)
      return 1;
  }
  return 0;
}

/**
 * parser.x EMIT_HEAVY 第二遍：巨型 parse_into/expr 入口 ret0 桩（strict 链由 parser.o / C alias 提供）。
 * SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1：experimental 重链用 ./shux 编 parser 真 parse_into*（仅 bootstrap .o，非 gate EMIT_HEAVY）。
 */
static int32_t asm_skip_heavy_parser_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_MEGA_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (asm_parser_mega_bisect_skip_stub(m, func_index, (n), (l)))                                                     \
      break;                                                                                                           \
    if (asm_parser_bootstrap_mega_emit_allowed(m, func_index, (n), (l)))                                               \
      break;                                                                                                           \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_MEGA_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  PARSER_MEGA_EQ("parse_into_buf", 14);
  PARSER_MEGA_EQ("parse_into", 10);
  PARSER_MEGA_EQ("parse", 5);
  PARSER_MEGA_EQ("parse_one_function_impl", 23);
  PARSER_MEGA_EQ("parse_expr_into", 15);
  PARSER_MEGA_EQ("parse_block_into", 16);
  PARSER_MEGA_EQ("parse_body_lets_into", 20);
  /** parse_at_simd_builtin / finish_struct_lit / leading_int_as glue 已迁 tier4c safe。 */
  /** parse_if_* / parse_match_* glue 薄包装已迁 tier4 safe；勿 mega ret0 桩。 */
  /** 表达式 precedence 链（parse_primary/addsub/…_into）走 thin delegate 或 X 真 emit；勿 PFX mega ret0 桩。 */
#undef PARSER_MEGA_EQ
#undef PARSER_MEGA_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：须 ret0 桩（X 真 emit Segfault / code_len 爆炸）；勿 safe_helper 白名单。
 */
static int32_t asm_parser_emit_heavy_force_stub(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_STUB_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
#define PARSER_STUB_PFX(pfx, plen)                                                                                     \
  do {                                                                                                                 \
    if (pipeline_module_func_name_has_prefix_at(m, func_index, (pfx), (int32_t)(plen)))                                \
      return 1;                                                                                                        \
  } while (0)
  PARSER_STUB_PFX("copy_onefunc_", 13);
  PARSER_STUB_PFX("onefunc_", 8);
  PARSER_STUB_PFX("set_onefunc_", 12);
  PARSER_STUB_EQ("wrap_block_ref_as_expr", 22);
  PARSER_STUB_EQ("parser_alloc_true_bool_lit", 26);
  PARSER_STUB_EQ("parser_alloc_float_lit", 22);
  PARSER_STUB_EQ("parser_expr_wrap_in_return", 26);
  PARSER_STUB_EQ("try_skip_allow_padding_struct", 29);
  PARSER_STUB_EQ("try_skip_allow_padding_struct_buf", 33);
  /** parse_peek_function_name_buf 已迁 tier4 safe（单行 bl→glue X emit OK）。 */
  /** parser_token_is_label_start：勿入 safe_helper（单独即 elf_ec=-1）；仅 thin_delegate→glue。 */
#undef PARSER_STUB_EQ
#undef PARSER_STUB_PFX
  return 0;
}

/**
 * parser EMIT_HEAVY 第二遍：按名判定可安全 X 真 emit 的小 helper（扩 __text；名长须与 module 表一致）。
 */
static int32_t asm_parser_emit_heavy_safe_helper(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_SAFE_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
  PARSER_SAFE_EQ("get_module_num_imports", 22);
  PARSER_SAFE_EQ("expr_ref_is_assign_lvalue", 25);
  PARSER_SAFE_EQ("copy_slice_to_name64", 20);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end", 27);
  PARSER_SAFE_EQ("copy_slice_to_param32", 21);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end", 28);
  PARSER_SAFE_EQ("copy_slice_to_name64_buf", 24);
  PARSER_SAFE_EQ("copy_slice_to_name64_at_end_buf", 31);
  PARSER_SAFE_EQ("copy_slice_to_param32_at_end_buf", 32);
  PARSER_SAFE_EQ("copy_slice_to_param32_buf", 25);
  PARSER_SAFE_EQ("get_module_import_path", 22);
  PARSER_SAFE_EQ("copy_module_import_path64", 25);
  PARSER_SAFE_EQ("parse_one_function_library_buf", 30);
  PARSER_SAFE_EQ("parse_one_function_library_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_buf_into", 27);
  PARSER_SAFE_EQ("parse_into_init", 15);
  PARSER_SAFE_EQ("parse_one_function_library_into", 31);
  PARSER_SAFE_EQ("pipeline_module_reset_parse_counters", 36);
  PARSER_SAFE_EQ("extern_parse_set_fail", 21);
  PARSER_SAFE_EQ("extern_parse_pool_ptr", 21);
  PARSER_SAFE_EQ("onefunc_result_pool_ptr", 23);
  PARSER_SAFE_EQ("set_onefunc_fail", 16);
  /** LexerResult/CollectImportsResult 字段读：slice 路径须 glue bl（X 真 emit 内调 lexer_next_into → elf_ec=-1）。 */
  PARSER_SAFE_EQ("copy_lex_from_import_into", 25);
  PARSER_SAFE_EQ("lex_from_next_into", 18);
  PARSER_SAFE_EQ("lex_from_result_ptr_into", 24);
  PARSER_SAFE_EQ("lex_from_onefunc_next_into", 26);
  PARSER_SAFE_EQ("write_extern_params_to_pools", 28);
  PARSER_SAFE_EQ("module_register_arena_func", 26);
  PARSER_SAFE_EQ("is_pointee_type_token", 21);
  PARSER_SAFE_EQ("compound_assign_token_to_expr_kind", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_copy", 28);
  PARSER_SAFE_EQ("parser_alloc_vector_type_ref", 28);
  /** tier4 selective X emit：单行 bl→glue（alloc/wrap_in_return X 真 emit → elf_ec=-1）。 */
  PARSER_SAFE_EQ("parse_peek_function_name_buf", 28);
  PARSER_SAFE_EQ("lexer_pos_before_run", 20);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before", 34);
  PARSER_SAFE_EQ("import_path_dot_segment_len", 27);
  PARSER_SAFE_EQ("is_compound_assign_token", 24);
  PARSER_SAFE_EQ("struct_field_name_tok_kind", 26);
  PARSER_SAFE_EQ("struct_field_continues_tok_kind", 31);
  PARSER_SAFE_EQ("module_try_register_enum_name", 29);
  PARSER_SAFE_EQ("struct_layout_name_exists_arr", 29);
  PARSER_SAFE_EQ("struct_layout_first_name_match_idx", 34);
  PARSER_SAFE_EQ("struct_layout_placeholder_idx", 29);
  PARSER_SAFE_EQ("lexer_token_run_len", 19);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into_buf", 50);
  PARSER_SAFE_EQ("skip_balanced_parens_into_buf", 29);
  PARSER_SAFE_EQ("skip_balanced_braces_into_buf", 29);
  /** *_into_buf：parser_slice_from_buf + bl *_into（13al；勿 lexer_next_buf X 深循环）。 */
  PARSER_SAFE_EQ("skip_one_enum_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_struct_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_trait_into_buf", 23);
  PARSER_SAFE_EQ("skip_one_impl_into_buf", 22);
  PARSER_SAFE_EQ("skip_one_extern_into_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_into_buf", 31);
  PARSER_SAFE_EQ("skip_one_enum_register_into_buf", 31);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into_buf", 33);
  /** *_buf：parser_slice_from_buf + bl slice 路径（13bc；深循环仍在 C glue）。 */
  PARSER_SAFE_EQ("diag_skip_let_const_buf", 23);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_buf", 31);
  PARSER_SAFE_EQ("skip_balanced_parens_buf", 24);
  PARSER_SAFE_EQ("skip_balanced_braces_buf", 24);
  PARSER_SAFE_EQ("skip_one_function_full_buf", 26);
  PARSER_SAFE_EQ("skip_one_if_core_buf", 20);
  PARSER_SAFE_EQ("skip_one_if_statement_buf", 25);
  PARSER_SAFE_EQ("skip_one_enum_buf", 17);
  PARSER_SAFE_EQ("skip_one_trait_buf", 18);
  PARSER_SAFE_EQ("skip_one_impl_buf", 17);
  PARSER_SAFE_EQ("skip_one_extern_buf", 19);
  PARSER_SAFE_EQ("skip_one_struct_buf", 19);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_buf", 29);
  PARSER_SAFE_EQ("try_skip_allow_padding_struct_buf", 33);
  /** slice 兼容包装 / glue 单行桩（扩 __text 有限；勿 lexer_next_into X 体）。 */
  PARSER_SAFE_EQ("lex_from_library_into", 21);
  PARSER_SAFE_EQ("lex_from_try_skip_into", 22);
  PARSER_SAFE_EQ("lex_from_library", 16);
  PARSER_SAFE_EQ("lex_from_try_skip", 17);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into", 32);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into", 29);
  PARSER_SAFE_EQ("first_token_kind", 16);
  PARSER_SAFE_EQ("diag_first_ident_len", 20);
  PARSER_SAFE_EQ("parser_rewind_lex_for_following_stmt", 36);
  PARSER_SAFE_EQ("lex_at_token_from_result", 24);
  PARSER_SAFE_EQ("struct_field_name_from_tok", 26);
  PARSER_SAFE_EQ("diag_skip_let_const_into", 24);
  PARSER_SAFE_EQ("diag_skip_let_const", 19);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into", 32);
  PARSER_SAFE_EQ("body_skip_let_const_then_if", 27);
  PARSER_SAFE_EQ("skip_one_if_statement_into", 26);
  PARSER_SAFE_EQ("skip_one_if_core_into", 21);
  PARSER_SAFE_EQ("skip_one_if_statement", 21);
  PARSER_SAFE_EQ("skip_one_if_core", 16);
  PARSER_SAFE_EQ("skip_one_enum_into", 18);
  PARSER_SAFE_EQ("skip_one_impl_into", 18);
  PARSER_SAFE_EQ("skip_one_trait_into", 19);
  PARSER_SAFE_EQ("skip_one_extern_into", 20);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into", 30);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_into_buf", 34);
  PARSER_SAFE_EQ("parse_into_set_main_index", 25);
  PARSER_SAFE_EQ("diag_token_after_collect_imports", 32);
  PARSER_SAFE_EQ("diag_parse_one_after_collect_imports", 36);
  PARSER_SAFE_EQ("parse_one_function_ok_for_pipeline", 34);
  PARSER_SAFE_EQ("skip_imports", 12);
  PARSER_SAFE_EQ("skip_one_struct", 15);
  PARSER_SAFE_EQ("skip_one_struct_into", 20);
  PARSER_SAFE_EQ("parse_one_extern_skip_into", 26);
  PARSER_SAFE_EQ("skip_one_enum", 13);
  PARSER_SAFE_EQ("skip_one_trait", 14);
  PARSER_SAFE_EQ("skip_one_impl", 13);
  PARSER_SAFE_EQ("skip_one_extern", 15);
  PARSER_SAFE_EQ("skip_one_function_full", 22);
  PARSER_SAFE_EQ("collect_imports", 15);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name", 33);
  PARSER_SAFE_EQ("expr_set_common_zeros", 21);
  PARSER_SAFE_EQ("fill_block_const_let_from_res", 29);
  PARSER_SAFE_EQ("append_block_lets_from_res", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs", 31);
  PARSER_SAFE_EQ("diag_fail_at_token_kind", 23);
  PARSER_SAFE_EQ("diag_lex_after_imports", 22);
  PARSER_SAFE_EQ("skip_balanced_parens", 20);
  PARSER_SAFE_EQ("skip_balanced_parens_into", 25);
  PARSER_SAFE_EQ("skip_balanced_braces", 20);
  PARSER_SAFE_EQ("skip_balanced_braces_into", 25);
  /** tier3a（21 项）：slice 非 _buf；+1180B __text。 */
  PARSER_SAFE_EQ("parse_primary_into", 18);
  PARSER_SAFE_EQ("parse_unary_into", 16);
  PARSER_SAFE_EQ("parse_cast_into", 15);
  PARSER_SAFE_EQ("parse_term_into", 15);
  PARSER_SAFE_EQ("parse_addsub_into", 17);
  PARSER_SAFE_EQ("parse_shift_into", 16);
  PARSER_SAFE_EQ("parse_relcompare_into", 21);
  PARSER_SAFE_EQ("parse_compare_into", 18);
  PARSER_SAFE_EQ("parse_bitand_into", 17);
  PARSER_SAFE_EQ("parse_bitor_into", 16);
  PARSER_SAFE_EQ("parse_bitxor_into", 17);
  PARSER_SAFE_EQ("parse_logand_into", 17);
  PARSER_SAFE_EQ("parse_logor_into", 16);
  PARSER_SAFE_EQ("parse_ternary_into", 18);
  PARSER_SAFE_EQ("parse_assign_into", 17);
  PARSER_SAFE_EQ("parse_as_suffix_into", 20);
  PARSER_SAFE_EQ("parse_one_function_library", 26);
  PARSER_SAFE_EQ("parse_one_function_library_scan", 31);
  PARSER_SAFE_EQ("parse_into_try_skip_allow", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_into", 29);
  PARSER_SAFE_EQ("parse_one_top_level_let_into", 28);
  /** tier3b（69 项）：跳过 parser_token_is_label_start（elf_ec=-1）；+936B __text。 */
  PARSER_SAFE_EQ("parser_should_wrap_func_tail_in_return", 38);
  PARSER_SAFE_EQ("skip_one_enum_register_into", 27);
  PARSER_SAFE_EQ("skip_one_function_full_into", 27);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok", 31);
  PARSER_SAFE_EQ("parse_struct_record_layout_into", 31);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into", 29);
  PARSER_SAFE_EQ("parse_cond_expr_into", 20);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_into", 46);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref", 40);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling", 42);
  PARSER_SAFE_EQ("collect_imports_buf", 19);
  PARSER_SAFE_EQ("skip_imports_buf", 16);
  PARSER_SAFE_EQ("diag_skip_let_const_into_buf", 28);
  PARSER_SAFE_EQ("body_skip_let_const_then_if_into_buf", 36);
  PARSER_SAFE_EQ("skip_one_if_core_into_buf", 25);
  PARSER_SAFE_EQ("skip_one_if_statement_into_buf", 30);
  PARSER_SAFE_EQ("first_token_kind_buf", 20);
  PARSER_SAFE_EQ("diag_first_ident_len_buf", 24);
  PARSER_SAFE_EQ("diag_lex_after_imports_buf", 26);
  PARSER_SAFE_EQ("diag_after_imports_then_structs_buf", 35);
  PARSER_SAFE_EQ("diag_fail_at_token_kind_buf", 27);
  PARSER_SAFE_EQ("parse_one_extern_skip_into_buf", 30);
  PARSER_SAFE_EQ("consume_qualified_type_ident_name_buf", 37);
  PARSER_SAFE_EQ("advance_past_stmt_semicolon_into_buf", 36);
  PARSER_SAFE_EQ("advance_past_cond_rparen_into_buf", 33);
  PARSER_SAFE_EQ("parse_primary_into_buf", 22);
  PARSER_SAFE_EQ("parse_unary_into_buf", 20);
  PARSER_SAFE_EQ("parse_cast_into_buf", 19);
  PARSER_SAFE_EQ("parse_term_into_buf", 19);
  PARSER_SAFE_EQ("parse_addsub_into_buf", 21);
  PARSER_SAFE_EQ("parse_shift_into_buf", 20);
  PARSER_SAFE_EQ("parse_relcompare_into_buf", 25);
  PARSER_SAFE_EQ("parse_compare_into_buf", 22);
  PARSER_SAFE_EQ("parse_bitand_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitxor_into_buf", 21);
  PARSER_SAFE_EQ("parse_bitor_into_buf", 20);
  PARSER_SAFE_EQ("parse_logand_into_buf", 21);
  PARSER_SAFE_EQ("parse_logor_into_buf", 20);
  PARSER_SAFE_EQ("parse_ternary_into_buf", 22);
  PARSER_SAFE_EQ("parse_assign_into_buf", 21);
  PARSER_SAFE_EQ("parse_expr_into_buf", 19);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into_buf", 42);
  PARSER_SAFE_EQ("parse_cond_expr_into_buf", 24);
  PARSER_SAFE_EQ("parse_if_stmt_into_buf", 22);
  /** tier4b：mega→safe glue 薄包装（if/match slice 路径）。 */
  PARSER_SAFE_EQ("parse_if_stmt_into", 18);
  PARSER_SAFE_EQ("parse_if_expr_into", 18);
  PARSER_SAFE_EQ("parse_match_into", 16);
  PARSER_SAFE_EQ("parse_match_subject_into", 24);
  /** tier4c：mega→safe glue 薄包装（simd / struct_lit / leading_int_as）。 */
  PARSER_SAFE_EQ("parse_at_simd_builtin_into", 26);
  PARSER_SAFE_EQ("finish_struct_lit_from_type_ident_into", 38);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into", 35);
  PARSER_SAFE_EQ("parse_block_into_buf", 20);
  PARSER_SAFE_EQ("parse_if_expr_into_buf", 22);
  PARSER_SAFE_EQ("parse_match_subject_into_buf", 28);
  PARSER_SAFE_EQ("parse_match_into_buf", 20);
  PARSER_SAFE_EQ("parse_at_simd_builtin_into_buf", 30);
  PARSER_SAFE_EQ("parse_as_suffix_into_buf", 24);
  PARSER_SAFE_EQ("parse_type_ref_for_arena_into_buf", 33);
  PARSER_SAFE_EQ("parse_body_let_bracket_compound_init_ref_buf", 44);
  PARSER_SAFE_EQ("parse_struct_record_layout_into_buf", 35);
  PARSER_SAFE_EQ("parse_one_function_library_scan_buf", 35);
  PARSER_SAFE_EQ("alloc_pointee_type_ref_from_tok_buf", 35);
  PARSER_SAFE_EQ("parser_vector_type_ref_from_ident_spelling_buf", 46);
  PARSER_SAFE_EQ("parse_one_top_level_let_into_buf", 32);
  PARSER_SAFE_EQ("import_path_dot_segment_copy_buf", 32);
  PARSER_SAFE_EQ("parser_match_kw_immediately_before_buf", 38);
  PARSER_SAFE_EQ("struct_field_name_from_tok_buf", 30);
  PARSER_SAFE_EQ("parse_expr_with_leading_int_as_into_buf", 39);
  PARSER_SAFE_EQ("skip_one_enum_register_buf", 26);
  PARSER_SAFE_EQ("skip_balanced_parens_slice_into_buf", 35);
  PARSER_SAFE_EQ("skip_balanced_braces_slice_into_buf", 35);
  PARSER_SAFE_EQ("module_append_enum_variants_and_skip_body_slice_into_buf", 56);
  PARSER_SAFE_EQ("parse_one_extern_skip_buf", 25);
  PARSER_SAFE_EQ("parse_one_extern_and_add_buf", 28);
  PARSER_SAFE_EQ("parse_one_function_library_from_buf", 35);
  PARSER_SAFE_EQ("parse_into_try_skip_allow_from_buf", 34);
#undef PARSER_SAFE_EQ
  return 0;
}

/** delegate 表内仍有 X 体：强制真 emit（须先于 thin_delegate）；当前全禁（experimental emit SIGSEGV）。 */
static int32_t asm_parser_emit_heavy_x_body_keep(struct ast_Module *m, int32_t func_index) {
  (void)m;
  (void)func_index;
  return 0;
#if 0
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
#define PARSER_KEEP_EQ(n, l)                                                                                           \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(n), (l)))                                        \
      return 1;                                                                                                        \
  } while (0)
  PARSER_KEEP_EQ("struct_layout_first_name_match_idx", 34);
  PARSER_KEEP_EQ("struct_layout_name_exists_arr", 29);
  PARSER_KEEP_EQ("struct_layout_placeholder_idx", 29);
#undef PARSER_KEEP_EQ
  return 0;
#endif
}

/** 槽位 fallback：小体 X 真 emit（>ASM_EMIT_HEAVY_PARSER_SLOT_MAX 仍桩化）。 */
static int32_t asm_parser_emit_heavy_slot_fallback_ok(struct ast_ASTArena *arena, int32_t body_ref, int32_t slots) {
  (void)arena;
  if (body_ref <= 0)
    return 0;
  return slots <= ASM_EMIT_HEAVY_PARSER_SLOT_MAX;
}

/** 查 func 是否在 k_asm_parser_thin_delegate 表（EMIT_HEAVY bl→C glue）。 */
static int32_t asm_parser_func_is_thin_delegate(struct ast_Module *m, int32_t func_index) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_parser_thin_delegate) / sizeof(k_asm_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_parser_thin_delegate[i].x_name,
                                           k_asm_parser_thin_delegate[i].x_len))
      return 1;
  }
  return 0;
}

/**
 * 查 parser 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_parser_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  /** 表内均为 parser.x 符号；勿绑 asm_module_is_parser_selfhost（marker 偶发缺失时 delegate 仍须 bl）。 */
  nrows = (int32_t)(sizeof(k_asm_parser_thin_delegate) / sizeof(k_asm_parser_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_parser_thin_delegate[i].x_name,
                                           k_asm_parser_thin_delegate[i].x_len)) {
      if (k_asm_parser_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_parser_thin_delegate[i].c_name, (size_t)k_asm_parser_thin_delegate[i].c_len);
      out[k_asm_parser_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_parser_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/**
 * parser EMIT_HEAVY：同模块 X 真 emit 调 skip/delegate 目标时重定向 bl glue（避免 U x 名）。
 * 成功写 out/out_len 并返回 1。
 */
int32_t asm_parser_emit_heavy_resolve_call_to_glue(struct ast_Module *m, uint8_t *name, int32_t name_len,
                                                    uint8_t *out, int32_t out_cap, int32_t *out_len) {
  int32_t fi;
  if (!m || !name || name_len <= 0 || !out || !out_len || out_cap <= 0)
    return 0;
  *out_len = 0;
  if (!asm_module_is_parser_emit_heavy(m))
    return 0;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (asm_parser_m8_tail_thin_delegate_c_name(m, fi, out, out_cap, out_len) != 0)
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_module_reset_parse_counters", 36)) {
      const char *c = "pipeline_module_reset_parse_counters_c";
      int32_t n = 38;
      if (n >= out_cap)
        return 0;
      memcpy(out, c, (size_t)n);
      out[n] = 0;
      *out_len = n;
      return 1;
    }
    return 0;
  }
  return 0;
}

/**
 * parser EMIT_HEAVY：callee 为本模块已定义（非 extern）func 时返回 1。
 * X 真 emit 调 stub/同模块 helper 应 enc_call→patch，勿 elf_add_reloc 产生 unexpected U。
 */
int32_t asm_parser_emit_heavy_callee_is_same_module_local(struct ast_Module *m, uint8_t *name, int32_t name_len) {
  int32_t fi;
  if (!m || !name || name_len <= 0 || !asm_module_is_parser_emit_heavy(m))
    return 0;
  for (fi = 0; fi < m->num_funcs; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, name, name_len) == 0)
      continue;
    if (pipeline_asm_module_func_is_extern_at(m, fi) != 0)
      return 0;
    return 1;
  }
  return 0;
}

/** M8-tail：driver compile 薄 bl 表已空；run_compiler_full_x* 堆 state + X post_parse 真 emit。 */
static const AsmBackendThinDelegateRow k_asm_driver_thin_delegate[] = {
};

/**
 * 查 driver/compile.x 薄包装 func 的 C 委托符号；成功写 out/out_len 并返回 1。
 */
int32_t asm_driver_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0 || !asm_module_is_driver_compile_selfhost(m))
    return 0;
  nrows = (int32_t)(sizeof(k_asm_driver_thin_delegate) / sizeof(k_asm_driver_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_driver_thin_delegate[i].x_name,
                                           k_asm_driver_thin_delegate[i].x_len)) {
      if (k_asm_driver_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_driver_thin_delegate[i].c_name, (size_t)k_asm_driver_thin_delegate[i].c_len);
      out[k_asm_driver_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_driver_thin_delegate[i].c_len;
      return 1;
    }
  }
  return 0;
}

/** typeck EMIT_HEAVY 薄委托：仅剩须 C 维持的入口（typeck 主体已 X emit）。 */
static const AsmBackendThinDelegateRow k_asm_typeck_thin_delegate[] = {
};

/**
 * typeck EMIT_HEAVY 第二遍：SKIP 桩路径 bl→C 委托或 typeck_x.o 同名实现（首遍 SKIP 仍 ret0）。
 * 实参已在 ABI 寄存器；Mach-O 由 backend_enc_call_arch 加 leading `_`。
 */
int32_t asm_typeck_m8_tail_thin_delegate_c_name(struct ast_Module *m, int32_t func_index, uint8_t *out,
                                                 int32_t out_cap, int32_t *out_len) {
  int32_t i;
  int32_t nrows;
  int32_t nl;

  if (!m || func_index < 0 || !out || !out_len || out_cap <= 0)
    return 0;
  if (!asm_module_is_typeck_selfhost(m) || asm_env_entry_emit_heavy() == 0)
    return 0;
  if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
    return 0;
  nrows = (int32_t)(sizeof(k_asm_typeck_thin_delegate) / sizeof(k_asm_typeck_thin_delegate[0]));
  for (i = 0; i < nrows; i++) {
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)k_asm_typeck_thin_delegate[i].x_name,
                                           k_asm_typeck_thin_delegate[i].x_len)) {
      if (k_asm_typeck_thin_delegate[i].c_len >= out_cap)
        return 0;
      memcpy(out, k_asm_typeck_thin_delegate[i].c_name, (size_t)k_asm_typeck_thin_delegate[i].c_len);
      out[k_asm_typeck_thin_delegate[i].c_len] = 0;
      *out_len = k_asm_typeck_thin_delegate[i].c_len;
      return 1;
    }
  }
  nl = pipeline_module_func_name_len_at(m, func_index);
  if (nl <= 0 || nl >= out_cap)
    return 0;
  pipeline_asm_module_func_name_copy64(m, func_index, out);
  out[nl] = 0;
  *out_len = nl;
  return 1;
}

/**
 * M8-tail：backend 薄包装 helper 按名真 emit，须先于 #87+ 索引桩（emit_block_body_elf #179 等）。
 * 不含 fold_/asm_import_ 等前缀体，避免 Abort 带内误放行大函数。
 */
static int32_t asm_skip_heavy_backend_m8_tail_thin_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_param_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"fill_local_slots", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"compute_frame_size", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body_elf", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits_elf", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_elf", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop_elf", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop_elf", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_loop_body_content_elf", 26))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_next_label", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"format_label_id", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_call", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_elf_method_call", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_elf", 22))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_inits", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_block_body", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_while_loop", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_for_loop", 13))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_if_then_block_body_text", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr", 9))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_call", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_expr_method_call", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_text", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_index_eff_addr_elf", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_text", 25))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_lvalue_eff_addr_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_emit_call_args_text", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"local_offset", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_resolve_whole_import_qualified_symbol", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"emit_skip_heavy_stub_elf", 24))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_shuffle_call_elf", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_select_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_binop2_call_elf", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"simd_try_inline_fma3_call_elf", 29))
    return 1;
  return 0;
}

/**
 * typeck EMIT_HEAVY 第二遍：layout/diag 小 helper 真 emit（ExprKind=51 已修；槽位过大仍走 mega/默认桩）。
 */
static int32_t asm_skip_heavy_typeck_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_typeck_selfhost(m))
    return 0;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 0;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
    return 0;
  return 0;
}

/**
 * backend 第二遍 EMIT_HEAVY：按符号名桩化 mega codegen/emit 入口（expr 树递归、块体、入口 asm_codegen_ast）。
 * 小 helper（arch_emit_*、try_fold_*、fill_param_slots 等）仍真 emit，扩 backend.o __text 且避免宿主栈 Abort。
 */
static int32_t asm_skip_heavy_backend_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
#define ASMB_MEGA(name, nlen)                                                                                          \
  do {                                                                                                                 \
    if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)(name), (nlen)))                                  \
      return 1;                                                                                                        \
  } while (0)
  ASMB_MEGA("asm_codegen_ast", 15);
  ASMB_MEGA("asm_codegen_ast_to_elf", 22);
  ASMB_MEGA("asm_codegen_ast_seed_mega", 25);
  ASMB_MEGA("asm_codegen_ast_to_elf_seed_mega", 32);
  /** emit_expr / emit_block_* / loop / if-then / fill_* / call / local_offset：thin_keep 真 emit（C/partial 委托）。 */
  /** extern/C sidecar glue：.x 体含 ExprKind 54 等 asm 未支持形态，须桩化。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"asm_ctx_key", 11))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_local_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_block_", 14))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_loop_", 13))
    return 1;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "asm_ctx_ensure_", 15))
    return 1;
  return 0;
}

/** typeck 第二遍 emit：桩化巨型 typecheck/diag/implicit-return 入口；layout/helper 须真 emit 过 8KiB。 */
static int32_t asm_skip_heavy_typeck_mega_entry(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0)
    return 0;
  if (/** typeck_skip_heavy_selfhost 等 mega 入口仍桩化。 */
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_skip_heavy_selfhost_func_body", 36))
    return 1;
  /**
   * check_* mega：宿主编译器真 emit 会 SIGSEGV；EMIT_HEAVY 第二遍 ret0 桩。
   * 子 helper 经 asm_typeck_emit_heavy_safe_helper 分片 X 真 emit。
   */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl_mega", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_check_block_stmt_order_one", 33))
    return 1;
  /** 遍历全模块函数：槽位高；EMIT_HEAVY 第二遍 ret0 桩（子 helper check_one_func 仍 X）。 */
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_impl", 18))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_library", 21))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_all_funcs_loop", 34))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast_check_one_func", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_ast", 13))
    return 1;
  /** type_kind_ordinal 在瘦 typeck #0 须真 emit；勿在此 mega 桩。 */
  return 0;
}

/**
 * out 至少 24 字节；*out_len 为 NUL 终止名长（不含 NUL）。
 */
void asm_empty_text_stub_label(struct ast_Module *m, uint8_t *out, int32_t out_cap, int32_t *out_len) {
  uint32_t h = 2166136261u;
  int32_t i, k, nl, pos, d, nd;
  uint32_t v;
  uint8_t digits[16];
  static const uint8_t prefix[] = "_shux_asm_stu_";
  if (!out || out_cap < 24 || !out_len) {
    if (out_len)
      *out_len = 0;
    return;
  }
  if (m && m->num_funcs > 0) {
    for (i = 0; i < m->num_funcs; i++) {
      nl = pipeline_module_func_name_len_at(m, i);
      for (k = 0; k < nl; k++)
        h = (uint32_t)((h ^ (uint8_t)pipeline_module_func_name_byte_at(m, i, k)) * 16777619u);
    }
  } else {
    h ^= (uint32_t)(m ? m->num_imports : 0);
    h *= 16777619u;
  }
  memcpy(out, prefix, sizeof(prefix) - 1);
  pos = (int32_t)(sizeof(prefix) - 1);
  nd = 0;
  v = h;
  if (v == 0)
    digits[nd++] = (uint8_t)'0';
  else {
    while (v > 0 && nd < 16) {
      digits[nd++] = (uint8_t)('0' + (v % 10));
      v /= 10;
    }
  }
  for (d = nd - 1; d >= 0; d--)
    out[pos++] = digits[d];
  out[pos] = 0;
  *out_len = pos;
}

/**
 * 模块是否 ast.x 自举单元（~40–222 func；须桩化首遍 emit，否则 seed shux 全量真 emit 极慢）。
 * 须先于 typeck ndef 启发式识别（ast ndef≈75–155 会被误判为 typeck.x）。
 */
static int32_t asm_module_is_ast_selfhost(struct ast_Module *m) {
  int32_t i;
  int32_t has_arena_init;
  int32_t has_placeholder;
  if (!m || m->num_funcs < 15 || m->num_funcs > 250)
    return 0;
  has_arena_init = 0;
  has_placeholder = 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_arena_init", 14))
      has_arena_init = 1;
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"ast_placeholder", 15))
      has_placeholder = 1;
  }
  if (has_arena_init == 0 || has_placeholder == 0)
    return 0;
  if (asm_module_is_backend_selfhost(m) || asm_module_is_pipeline_selfhost(m) ||
      asm_module_is_parser_selfhost(m))
    return 0;
  return 1;
}

/** 模块是否为 compiler .x 自举单元；用户小程序（pool-limits / 普通 -o）不在此列。 */
static int32_t asm_module_is_compiler_selfhost(struct ast_Module *m) {
  return asm_module_is_ast_selfhost(m) || asm_module_is_backend_selfhost(m) ||
         asm_module_is_typeck_selfhost(m) || asm_module_is_pipeline_selfhost(m) ||
         asm_module_is_parser_selfhost(m) || asm_module_is_parser_emit_heavy(m) ||
         asm_module_is_driver_compile_selfhost(m) || asm_module_is_main_driver_selfhost(m);
}

int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index) {
  int32_t body_ref;
  int32_t slots;
  int32_t slot_threshold;
  if (!m || func_index < 0)
    return 0;
  /**
   * 用户程序（非 parser/typeck/backend/pipeline/driver 自举模块）：须完整 emit 真机码。
   * 须先于 SHUX_ASM_BUILD_SKIP_TYPECK 桩分支；否则 return42 等单文件 -o 被 ret0 桩化或 WPO 跳过。
   */
  if (!asm_module_is_compiler_selfhost(m))
    return 0;
  /**
   * ast.x 首遍 SKIP：除 whitelist 外一律 ret0 桩（含 extern 占位；真符号由 ast_pool/pipeline_x 提供）。
   */
  if (asm_module_is_ast_selfhost(m) && asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  /**
   * 用户 import+exe（asm_entry_module_only、非大入口）：须完整 emit 入口模块，禁止 ret0 桩。
   * build_shux_asm（SHUX_ASM_BUILD_SKIP_TYPECK）同为 ENTRY_MODULE_ONLY，须走下方白名单/桩路径，勿全量 emit。
   */
  if (g_asm_skip_pipeline_ctx != NULL &&
      pipeline_dep_ctx_asm_entry_module_only(g_asm_skip_pipeline_ctx) != 0 &&
      pipeline_dep_ctx_use_asm_backend(g_asm_skip_pipeline_ctx) != 0 &&
      driver_typeck_skip_large_entry() == 0 &&
      asm_env_build_skip_typeck() == 0 &&
      asm_env_entry_emit_heavy() == 0) {
    return 0;
  }
  /**
   * build_shux_asm：SHUX_ASM_BUILD_SKIP_TYPECK 默认桩 emit（非 extern/非白名单 ret 0）。
   * SHUX_ASM_ENTRY_EMIT_HEAVY=1 时仅跳过 pipeline typecheck，emit 仍走槽位阈值真机码。
   */
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
      return 0;
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  /* 小模块（lexer 等 ~21 func）：首遍 SKIP 桩前 10 项；EMIT_HEAVY 第二遍改走 driver/pipeline 按名白名单。 */
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0 && m->num_funcs > 0 &&
      m->num_funcs <= 32 && func_index < 10)
    return 1;
  /** 首遍 SKIP 桩：mega check_* 勿真 emit；EMIT_HEAVY 第二遍改走下方按名/索引桩。 */
  if (asm_env_entry_emit_heavy() == 0 &&
      (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11) ||
       pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16)))
    return 1;
  /**
   * ENTRY_EMIT_HEAVY 第二遍：放宽槽位阈值；桩化 mega typecheck/diag 入口（按符号名）。
   * typeck 大入口：#90–117 Abort 区间（索引+按名桩）；#118+ 真 emit。
   * backend 大入口：#87–189 索引桩 + emit_expr/asm_codegen_ast 等按名 mega 桩；其余 helper 真 emit。
   * 非 typeck/backend 大模块且 func≥160：func#72+ 仍粗筛桩化。
   */
  if (asm_env_entry_emit_heavy() != 0) {
    int32_t typeck_ndef = asm_module_is_typeck_selfhost(m) ? asm_module_num_defined_funcs(m) : 0;
    int32_t typeck_ord = asm_module_defined_func_ordinal(m, func_index);
    /**
     * parser.x EMIT_HEAVY 第二遍：须先于 typeck ndef 启发式（parser ndef≈130 与 typeck 重叠）。
     */
    if (asm_module_is_parser_emit_heavy(m)) {
      if (asm_skip_heavy_parser_mega_entry(m, func_index) != 0)
        return 1;
      /** STUB_ONLY / BISECT_N=0：仅 thin delegate 桩。 */
      if (asm_parser_emit_heavy_bisect_max_index() == 0)
        return 1;
      /**
       * safe_helper 须先于 force_stub：onefunc_result_pool_ptr 等被 onefunc_ 前缀误桩，
       * 白名单内小 helper 仍须 X 真 emit 扩 __text。
       */
      if (asm_parser_emit_heavy_safe_helper(m, func_index) != 0) {
        asm_parser_emit_heavy_dbg_real(m, func_index, "safe_helper");
        return 0;
      }
      if (asm_parser_emit_heavy_force_stub(m, func_index) != 0)
        return 1;
      /** thin delegate：薄包装 bl→C glue。 */
      if (asm_parser_func_is_thin_delegate(m, func_index) != 0)
        return 1;
      if (func_index >= asm_parser_emit_heavy_bisect_max_index())
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 1;
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > asm_parser_emit_heavy_slot_max())
        return 1;
      asm_parser_emit_heavy_dbg_real(m, func_index, "slot_fallback");
      /** 槽位 fallback：≤SLOT_MAX 小函数 X 真 emit（ExprKind 序已对齐 primary_slice）。 */
      return 0;
    }
    /**
     * typeck.x 合并 glue 后 ~160–180 已定义 func：#0–89 glue 桩；#90–117 按名小 helper；
     * #118–159 check_* 桩；#160+ typeck_x_ast mega 桩（序号均按非 extern ordinal）。
     */
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 160 && typeck_ndef <= 180) {
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      /** safe_helper 须先于 ord #118–159 粗筛，否则 expr_type_ref 等无法 X 真 emit。 */
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord >= 118 && typeck_ord <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
        return 1;
      /** 按名放行 layout/小 helper（须在 ordinal<90 粗筛之前，type_kind_ordinal 在 #0）。 */
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      if (typeck_ord < 90)
        return 1;
      return 1;
    }
    /** 瘦 typeck：safe_helper 白名单 + 槽位过关 X 真 emit；上限随 block helper 扩容（2026-06 ndef≈130）。 */
    if (typeck_ndef >= 75 && typeck_ndef <= 200 && !asm_module_is_backend_selfhost(m) &&
        !asm_module_is_parser_emit_heavy(m)) {
      int32_t body_ref_thin;
      int32_t slots_thin;
      if (typeck_ord < 0)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      /** merge_dep 须先于 safe_helper 粗筛（双循环槽位高；按名强制 X 真 emit）。 */
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
        return 0;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) == 0)
        return 1;
      body_ref_thin = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref_thin <= 0)
        return 1;
      slots_thin = asm_count_block_stack_slots(arena, body_ref_thin);
      if (slots_thin > ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX)
        return 1;
      return 0;
    }
    /**
     * pipeline.x：编排经 asm_pipeline_emit_heavy_safe_helper 真 emit；C mega 仅 ast_pool/pipeline_glue 回退。
     * safe_helper 小函数 X 真 emit（S3 起步）。
     */
    if (asm_module_is_pipeline_selfhost(m)) {
      if (asm_pipeline_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /**
     * main.x：仅 entry 真 emit；其余 helper 走 SKIP 桩 + WPO 从 entry 建 reach。
     */
    if (asm_module_is_main_driver_selfhost(m)) {
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"entry", 5))
        return 0;
      return 1;
    }
    /**
     * driver/compile.x：parse_argv 分 helper + dispatch X 真 emit；run_compiler_full_x* 薄 bl→runtime impl_c。
     */
    if (asm_module_is_driver_compile_selfhost(m)) {
      if (asm_driver_compile_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /**
     * M8-tail：backend 薄包装 EMIT_HEAVY 仍 skip 桩 + bl→C（与 SKIP 首遍一致；勿真 emit 单行 X）。
     */
    if (asm_module_is_backend_selfhost(m) && asm_skip_heavy_backend_m8_tail_thin_keep(m, func_index) != 0)
      return 1;
    /**
     * 白名单须先于 mega/索引桩：layout/arch helper 按名保留真 emit（小槽位体）。
     * 合并 glue 后 num_funcs>150（~285 func）时勿 #0–86 真 emit，否则宿主编 backend.x SIGSEGV。
     */
    if (asm_module_is_backend_selfhost(m) && m->num_funcs <= 150 &&
        (asm_skip_heavy_backend_helper_keep(m, func_index) != 0 ||
         asm_skip_heavy_backend_m8_helper_keep(m, func_index) != 0)) {
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0 ||
          asm_count_block_stack_slots(arena, body_ref) <= ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX)
        return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && asm_skip_heavy_typeck_helper_keep(m, func_index) != 0) {
      /** layout/metrics 小 helper 先于 Abort 索引带真 emit（合并 glue 后 #90 即为 type_kind_ordinal）。 */
      if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
        return 1;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_align", 20) ||
          pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_x_type_size", 19))
        return 1;
      if (func_index >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO && func_index <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
        return 1;
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0)
        return 0;
      if (asm_count_block_stack_slots(arena, body_ref) <= ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX)
        return 0;
    }
    if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
      return 1;
    if (asm_skip_heavy_backend_mega_entry(m, func_index) != 0)
      return 1;
    /** typeck.x：ordinal #90–159 Abort 区间 ret0 桩（safe_helper 已 X 真 emit 的除外）。 */
    if (asm_module_is_typeck_selfhost(m) && typeck_ndef >= 90 && typeck_ord >= 0 &&
        typeck_ord >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO && typeck_ord <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /** backend.x ~100 func：勿要求 num_funcs>=175，否则 #87+ 全走真 emit → 宿主栈 Abort。 */
    if (asm_module_is_backend_selfhost(m) && m->num_funcs >= 80) {
      int32_t be_hi = asm_emit_heavy_abort_hi();
      if (be_hi >= m->num_funcs)
        be_hi = m->num_funcs - 1;
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= be_hi)
        return 1;
    } else if (driver_typeck_skip_large_entry() != 0 && m->num_funcs >= 175) {
      if (func_index >= asm_emit_heavy_abort_lo() && func_index <= asm_emit_heavy_abort_hi())
        return 1;
    } else if (m->num_funcs >= 160 && func_index >= 72 && !asm_module_is_backend_selfhost(m) &&
               !asm_module_is_typeck_selfhost(m) && !asm_module_is_parser_emit_heavy(m)) {
      return 1;
    }
    body_ref = pipeline_module_func_body_ref_at(m, func_index);
    slot_threshold = ASM_EMIT_HEAVY_SLOT_THRESHOLD;
    /** backend #0–86 小 helper：放宽槽位；#87+ 索引/mega 桩后再收紧槽位阈值。 */
    if (asm_module_is_backend_selfhost(m) && func_index < ASM_EMIT_HEAVY_BACKEND_INDEX_LO) {
      slot_threshold = ASM_EMIT_HEAVY_SLOT_THRESHOLD;
    } else if ((asm_module_is_backend_selfhost(m) && m->num_funcs >= 80) ||
               (driver_typeck_skip_large_entry() != 0 && m->num_funcs >= 175))
      slot_threshold = ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD;
    if (arena && body_ref > 0) {
      slots = asm_count_block_stack_slots(arena, body_ref);
      if (slots > slot_threshold)
        return 1;
    }
    /** backend/typeck 第二遍：backend 默认 ret0 桩；typeck 槽位过关则真 emit。 */
    if (asm_module_is_backend_selfhost(m))
      return 1;
    if (asm_module_is_typeck_selfhost(m)) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 0;
    }
    return 0;
  }
  /** 默认大模块：func_index>=72 粗筛（非 EMIT_HEAVY 第二遍；仅 compiler 自举）。 */
  if (m->num_funcs >= 160 && func_index >= 72)
    return 1;
  body_ref = pipeline_module_func_body_ref_at(m, func_index);
  if (arena && body_ref > 0) {
    slots = asm_count_block_stack_slots(arena, body_ref);
    if (slots > ASM_HEAVY_BODY_SLOT_THRESHOLD)
      return 1;
  }
  return 0;
}

/**
 * 读 SHUX_ASM_START_FUNC：跳过 module 中前 N 个函数（调试大模块 asm 单编 139）。
 * build_shux_asm 须 env -u SHUX_ASM_START_FUNC；若 N>=num_funcs 则整模块无机器码、仅 8B 空 __text 桩。
 * SHUX_ASM_ALLOW_START_FUNC=1 时 build 路径也生效（手工二分 emit 用）。
 */
int32_t asm_diag_start_func_skip(void) {
  const char *e = getenv("SHUX_ASM_START_FUNC");
  const char *allow = getenv("SHUX_ASM_ALLOW_START_FUNC");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 0;
  /* build_shux_asm 默认清除 START_FUNC；未显式 ALLOW 时 ENTRY skip 模式忽略，避免 pipeline 56 func 全跳过。 */
  if ((allow == NULL || allow[0] == '\0' || allow[0] == '0') && asm_env_build_skip_typeck() != 0 &&
      getenv("SHUX_ASM_ENTRY_MODULE_ONLY") != NULL) {
    const char *em = getenv("SHUX_ASM_ENTRY_MODULE_ONLY");
    if (em && em[0] != '\0' && em[0] != '0')
      return 0;
  }
  v = strtol(e, &end, 10);
  if (end == e || v < 0)
    return 0;
  if (v > 100000)
    return 100000;
  return (int32_t)v;
}

/** SHUX_ASM_BODY_TRACE=1 时打印函数体块规模，定位错误 body_ref 导致 fill/emit 崩溃。 */
void asm_diag_trace_func_body(struct ast_ASTArena *arena, int32_t body_ref) {
  const char *trace;
  struct ast_Block *b;
  if (!arena || body_ref <= 0)
    return;
  trace = getenv("SHUX_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  b = block_at(arena, body_ref);
  if (!b) {
    fprintf(stderr, "asm_body: ref=%d invalid\n", (int)body_ref);
    return;
  }
  fprintf(stderr,
          "asm_body: ref=%d consts=%d lets=%d loops=%d for=%d ifs=%d stmt_order=%d final_expr=%d\n",
          (int)body_ref, (int)b->num_consts, (int)b->num_lets, (int)b->num_loops, (int)b->num_for_loops,
          (int)b->num_if_stmts, (int)b->num_stmt_order, (int)b->final_expr_ref);
  fflush(stderr);
}

/** SHUX_ASM_BODY_TRACE=1：仅打印 body_ref 数值（在 pipeline_asm_module_func_body_ref_at 前后对照）。 */
void asm_diag_trace_body_ref(int32_t body_ref) {
  const char *trace = getenv("SHUX_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_body_ref=%d\n", (int)body_ref);
  fflush(stderr);
}

/** SHUX_ASM_BODY_TRACE=1：emit 阶段标记（1=fill 后 2=prologue 后 3=emit_body 后）。 */
void asm_diag_trace_emit_phase(int32_t phase) {
  const char *trace = getenv("SHUX_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_emit_phase=%d\n", (int)phase);
  fflush(stderr);
}

void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len) {
  const char *trace;
  int32_t i;
  if (!name || name_len <= 0)
    return;
  trace = getenv("SHUX_ASM_FUNC_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  if (func_idx >= 0)
    fprintf(stderr, "asm_trace: #%d ", (int)func_idx);
  else
    fprintf(stderr, "asm_trace: ");
  for (i = 0; i < name_len && i < 64; i++)
    fputc(name[i], stderr);
  fputc('\n', stderr);
  fflush(stderr);
}

void asm_ctx_fill_locals_block_tree(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                   int32_t *inout_next_offset, int32_t *inout_num_locals) {
  GrowVec stack;
  int32_t sp;
  int32_t cur;
  int32_t *pref;
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  if (!grow_vec_init(&stack, sizeof(int32_t), AST_POOL_GROW))
    return;
  {
    int32_t visits = 0;
    asm_block_tree_push_ref(&stack, block_ref);
    while (stack.len > 0) {
      sp = stack.len - 1;
      pref = (int32_t *)grow_vec_at(&stack, sp);
      if (!pref)
        break;
      cur = *pref;
      stack.len = sp;
      if (cur <= 0 || cur > arena->num_blocks)
        continue;
      visits++;
      if (visits > 8192)
        break;
      asm_ctx_ensure_block_locals(ctx, arena, cur, inout_next_offset, inout_num_locals);
      asm_block_tree_push_children(arena, &stack, cur);
      /** MEM-C1：with_arena / region 子块 let 须与 wa 临时区同序登记，避免 arena@8 与 Vec 局部重叠。 */
      asm_block_tree_push_region_children(arena, &stack, cur);
    }
  }
  grow_vec_free(&stack);
}

/** backend.x：嵌套循环 break/continue 标签栈 sidecar（替代 AsmFuncCtx 内 512×2 字节数组，减栈帧）。 */
typedef struct {
  void *ctx;
  int used;
  int32_t depth;
  uint8_t break_stack[512];
  int32_t break_lens[8];
  uint8_t continue_stack[512];
  int32_t continue_lens[8];
} AsmLoopLabelsSidecar;

static AsmLoopLabelsSidecar g_asm_loop_sc[MAX_ASM_LOCALS_SIDECARS];

static AsmLoopLabelsSidecar *asm_loop_sidecar_get(uint8_t *ctx, int create) {
  int i;
  if (!ctx)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (g_asm_loop_sc[i].used && g_asm_loop_sc[i].ctx == (void *)ctx)
      return &g_asm_loop_sc[i];
  }
  if (!create)
    return NULL;
  for (i = 0; i < MAX_ASM_LOCALS_SIDECARS; i++) {
    if (!g_asm_loop_sc[i].used) {
      g_asm_loop_sc[i].ctx = (void *)ctx;
      g_asm_loop_sc[i].used = 1;
      g_asm_loop_sc[i].depth = 0;
      return &g_asm_loop_sc[i];
    }
  }
  return NULL;
}

/** 清空某 AsmFuncCtx 的循环标签栈。 */
void asm_ctx_loop_reset(uint8_t *ctx) {
  AsmLoopLabelsSidecar *sc = asm_loop_sidecar_get(ctx, 0);
  if (sc)
    sc->depth = 0;
}

/** 压入一层 break/continue 标签；depth>=8 时返回 -1。 */
int32_t asm_ctx_loop_push(uint8_t *ctx, uint8_t *exit_buf, int32_t exit_len, uint8_t *loop_buf, int32_t loop_len) {
  AsmLoopLabelsSidecar *sc;
  int32_t d, base, k, n, m;
  if (!ctx || !exit_buf || !loop_buf || exit_len < 0 || loop_len < 0)
    return -1;
  if (!(sc = asm_loop_sidecar_get(ctx, 1)))
    return -1;
  d = sc->depth;
  if (d >= 8)
    return -1;
  base = d * 64;
  n = exit_len > 64 ? 64 : exit_len;
  for (k = 0; k < n; k++)
    sc->break_stack[base + k] = exit_buf[k];
  sc->break_lens[d] = exit_len;
  m = loop_len > 64 ? 64 : loop_len;
  for (k = 0; k < m; k++)
    sc->continue_stack[base + k] = loop_buf[k];
  sc->continue_lens[d] = loop_len;
  sc->depth = d + 1;
  return 0;
}

/** 弹出一层；若仍有外层则把其 break/continue 写入 out（长度经 *len_out 返回）。 */
void asm_ctx_loop_pop(uint8_t *ctx, uint8_t *break_out, int32_t break_cap, int32_t *break_len_out,
                      uint8_t *cont_out, int32_t cont_cap, int32_t *cont_len_out) {
  AsmLoopLabelsSidecar *sc;
  int32_t d, prev, base, k, bl, cl, bn, cn;
  if (break_len_out)
    *break_len_out = 0;
  if (cont_len_out)
    *cont_len_out = 0;
  if (!ctx || !(sc = asm_loop_sidecar_get(ctx, 0)) || sc->depth <= 0)
    return;
  sc->depth--;
  d = sc->depth;
  if (d <= 0)
    return;
  prev = d - 1;
  base = prev * 64;
  bl = sc->break_lens[prev];
  cl = sc->continue_lens[prev];
  if (break_out && break_len_out && break_cap > 0) {
    bn = bl > break_cap - 1 ? break_cap - 1 : bl;
    for (k = 0; k < bn; k++)
      break_out[k] = sc->break_stack[base + k];
    *break_len_out = bl;
  }
  if (cont_out && cont_len_out && cont_cap > 0) {
    cn = cl > cont_cap - 1 ? cont_cap - 1 : cl;
    for (k = 0; k < cn; k++)
      cont_out[k] = sc->continue_stack[base + k];
    *cont_len_out = cl;
  }
}

/** 当前循环标签栈深度。 */
int32_t asm_ctx_loop_depth(uint8_t *ctx) {
  AsmLoopLabelsSidecar *sc = asm_loop_sidecar_get(ctx, 0);
  return sc ? sc->depth : 0;
}

/**
 * emit_block_body 迭代续延：if-then 后挂起 (block_ref, stmt_i) 与 end 标签，避免 emit_block_body↔if-then 递归。
 */
typedef struct {
  int32_t block_ref;
  int32_t stmt_i;
  int32_t end_label_len;
  uint8_t end_label[64];
} AsmBlockEmitCont;

static AsmBlockEmitCont g_asm_be_cont[24];
static int32_t g_asm_be_cont_depth;

/** 清空 if 续延栈（每个顶层 emit_block_body 入口调用一次）。 */
void asm_be_cont_reset(void) {
  g_asm_be_cont_depth = 0;
}

/**
 * 挂起当前块在 stmt_i 处，保存 if end 标签；随后切换至 then 块 stmt_i=0。
 * end_len 须 <= 64；end_len==0 表示 then 结束后不 jmp merge（由 resume 直接恢复 stmt_i）。栈满返回 -1。
 */
int32_t asm_be_cont_suspend(int32_t block_ref, int32_t stmt_i, uint8_t *end_lbl, int32_t end_len) {
  AsmBlockEmitCont *c;
  int32_t k, n;
  if (g_asm_be_cont_depth >= 24 || !end_lbl || end_len < 0)
    return -1;
  c = &g_asm_be_cont[g_asm_be_cont_depth++];
  c->block_ref = block_ref;
  c->stmt_i = stmt_i;
  if (end_len == 0) {
    c->end_label_len = 0;
    return 0;
  }
  n = end_len > 64 ? 64 : end_len;
  for (k = 0; k < n; k++)
    c->end_label[k] = end_lbl[k];
  c->end_label_len = end_len;
  return 0;
}

/**
 * 弹出最内层续延；out_block 与 out_stmt_i 为恢复点；end 标签写入 out_end（cap 字节，out_end_len 为原长）。
 * 无续延返回 0；有续延返回 1。
 */
int32_t asm_be_cont_resume(int32_t *out_block, int32_t *out_stmt_i, uint8_t *out_end, int32_t end_cap, int32_t *out_end_len) {
  AsmBlockEmitCont *c;
  int32_t k, n;
  if (g_asm_be_cont_depth <= 0)
    return 0;
  c = &g_asm_be_cont[--g_asm_be_cont_depth];
  if (out_block)
    *out_block = c->block_ref;
  if (out_stmt_i)
    *out_stmt_i = c->stmt_i;
  if (out_end_len)
    *out_end_len = c->end_label_len;
  if (out_end && end_cap > 0 && out_end_len) {
    n = c->end_label_len;
    if (n > end_cap - 1)
      n = end_cap - 1;
    for (k = 0; k < n; k++)
      out_end[k] = c->end_label[k];
  }
  return 1;
}

/** 当前 if 续延栈深度（调试）。 */
int32_t asm_be_cont_depth(void) {
  return g_asm_be_cont_depth;
}

/**
 * WPO v0（asm 后端 DCE）：按 typeck 解析后的 call graph 标记 reachable，emit 时跳过 dead export。
 * 与 codegen.c 的 codegen_wpo_reach 语义对齐，但 keyed by (ast_Module*, func_index) 供 .x asm 后端查询。
 */
#define ASM_WPO_MAX_FUNCS 1024
#define ASM_WPO_MAX_MODS 64
#define ASM_WPO_MAX_EDGES 4096

/** WPO call 边解析：与 backend emit_call 同读 pipeline_expr_*（勿裸 *Expr 字段，避免池布局偏差）。 */
extern int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
extern void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out);
extern int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
extern int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);

typedef struct {
  int32_t valid;
  struct ast_Module *entry;
  struct ast_PipelineDepCtx *dep_ctx;
  struct ast_Module *mods[ASM_WPO_MAX_MODS];
  struct ast_ASTArena *arenas[ASM_WPO_MAX_MODS];
  int32_t nmods;
  struct ast_Module *func_mod[ASM_WPO_MAX_FUNCS];
  int32_t func_fi[ASM_WPO_MAX_FUNCS];
  int32_t nfuncs;
  int32_t root_id;
  unsigned char reachable[ASM_WPO_MAX_FUNCS];
  struct {
    int32_t from;
    int32_t to;
  } edges[ASM_WPO_MAX_EDGES];
  int32_t nedges;
} AsmWpoReachState;

static AsmWpoReachState g_asm_wpo;
/** PGO-Lite：root + 直接 callee（BFS depth≤1）标记为 hot emit 候选。 */
static unsigned char g_asm_wpo_pgo_hot[ASM_WPO_MAX_FUNCS];
/** PGO-Lite S2：自 root 的静态 call-depth（BFS）；未 reach 保持 -1。 */
static int32_t g_asm_wpo_pgo_depth[ASM_WPO_MAX_FUNCS];
/** 当前 module 的 emit 顺序（func_index 表；PGO 时按 depth 升序）。 */
static struct ast_Module *g_asm_wpo_pgo_emit_mod;
static int32_t g_asm_wpo_pgo_emit_order[ASM_WPO_MAX_FUNCS];
static int32_t g_asm_wpo_pgo_emit_n;

/** 清空 asm WPO 状态；elf emit 结束或失败时调用。 */
void pipeline_asm_wpo_reach_clear(void) {
  memset(&g_asm_wpo, 0, sizeof(g_asm_wpo));
  memset(g_asm_wpo_pgo_hot, 0, sizeof(g_asm_wpo_pgo_hot));
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  g_asm_wpo_pgo_emit_mod = NULL;
  g_asm_wpo_pgo_emit_n = 0;
}

/** 在 mods[] 中查找 module 下标；未注册返回 -1。 */
static int32_t asm_wpo_mod_index(struct ast_Module *m) {
  int32_t i;
  if (!m)
    return -1;
  for (i = 0; i < g_asm_wpo.nmods; i++) {
    if (g_asm_wpo.mods[i] == m)
      return i;
  }
  return -1;
}

/** 注册 module+arena；已存在则仅返回下标。 */
static int32_t asm_wpo_register_mod(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t ix;
  if (!m || !a)
    return -1;
  ix = asm_wpo_mod_index(m);
  if (ix >= 0)
    return ix;
  if (g_asm_wpo.nmods >= ASM_WPO_MAX_MODS)
    return -1;
  g_asm_wpo.mods[g_asm_wpo.nmods] = m;
  g_asm_wpo.arenas[g_asm_wpo.nmods] = a;
  return g_asm_wpo.nmods++;
}

/** (module, func_index) → 全局 func id；未注册返回 -1。 */
static int32_t asm_wpo_func_id_of(struct ast_Module *m, int32_t fi) {
  int32_t i;
  if (!m || fi < 0)
    return -1;
  for (i = 0; i < g_asm_wpo.nfuncs; i++) {
    if (g_asm_wpo.func_mod[i] == m && g_asm_wpo.func_fi[i] == fi)
      return i;
  }
  return -1;
}

/** 登记单个非 extern 函数节点。 */
static int32_t asm_wpo_register_func(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f;
  int32_t id;
  if (!m || fi < 0 || g_asm_wpo.nfuncs >= ASM_WPO_MAX_FUNCS)
    return -1;
  f = module_func_at(m, fi);
  if (!f || f->is_extern)
    return -1;
  id = asm_wpo_func_id_of(m, fi);
  if (id >= 0)
    return id;
  id = g_asm_wpo.nfuncs;
  g_asm_wpo.func_mod[id] = m;
  g_asm_wpo.func_fi[id] = fi;
  g_asm_wpo.nfuncs++;
  return id;
}

/** 按函数名在指定 module 已注册节点中查找 id；未命中返回 -1。 */
static int32_t asm_wpo_func_id_in_module(struct ast_Module *m, uint8_t *name, int32_t name_len) {
  int32_t nf;
  int32_t fi;
  int32_t id;
  if (!m || !name || name_len <= 0)
    return -1;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (!pipeline_module_func_name_equal_at(m, fi, name, name_len))
      continue;
    id = asm_wpo_func_id_of(m, fi);
    if (id >= 0)
      return id;
  }
  return -1;
}

/** 按函数名在已注册图中查找 id（跨模块）；重名时取首个。 */
static int32_t asm_wpo_func_id_by_name(uint8_t *name, int32_t name_len) {
  int32_t i;
  int32_t fi;
  if (!name || name_len <= 0)
    return -1;
  for (i = 0; i < g_asm_wpo.nfuncs; i++) {
    fi = g_asm_wpo.func_fi[i];
    if (pipeline_module_func_name_equal_at(g_asm_wpo.func_mod[i], fi, name, name_len))
      return i;
  }
  return -1;
}

/** 去重登记 from→to 边。 */
static void asm_wpo_add_edge(int32_t from, int32_t to) {
  int32_t i;
  if (from < 0 || to < 0 || from >= g_asm_wpo.nfuncs || to >= g_asm_wpo.nfuncs)
    return;
  for (i = 0; i < g_asm_wpo.nedges; i++) {
    if (g_asm_wpo.edges[i].from == from && g_asm_wpo.edges[i].to == to)
      return;
  }
  if (g_asm_wpo.nedges >= ASM_WPO_MAX_EDGES)
    return;
  g_asm_wpo.edges[g_asm_wpo.nedges].from = from;
  g_asm_wpo.edges[g_asm_wpo.nedges].to = to;
  g_asm_wpo.nedges++;
}

/**
 * 从 CALL 的 callee expr 取函数名（pipeline_expr_* 优先；kind 非 VAR 时回退裸 var_name 槽）。
 * 返回名长度；0 表示无可用名。
 */
static int32_t asm_wpo_call_callee_name(struct ast_ASTArena *a, int32_t callee_ref, uint8_t *cname) {
  struct ast_Expr *callee_ex;
  int32_t clen;
  if (!a || callee_ref <= 0 || !cname)
    return 0;
  callee_ex = pipeline_arena_expr_ptr(a, callee_ref);
  /** import 限定 callee（vec.vec_u8_new / heap.alloc）：取字段名，勿误用 binding 基名。 */
  if (callee_ex && callee_ex->kind == ast_ExprKind_EXPR_FIELD_ACCESS) {
    clen = pipeline_expr_field_access_name_len(a, callee_ref);
    if (clen > 0 && clen <= 63) {
      pipeline_expr_field_access_name_into(a, callee_ref, cname);
      return clen;
    }
  }
  clen = pipeline_expr_var_name_len(a, callee_ref);
  if (clen > 0 && clen <= 63) {
    pipeline_expr_var_name_into(a, callee_ref, cname);
    return clen;
  }
  if (!callee_ex || callee_ex->var_name_len <= 0 || callee_ex->var_name_len > 63)
    return 0;
  clen = callee_ex->var_name_len;
  memcpy(cname, callee_ex->var_name, (size_t)clen);
  return clen;
}

/** 解析 CALL 的 func id（callee 名与 emit bl 一致；再回退 typeck call_resolved_*，须与名一致）。 */
static int32_t asm_wpo_call_callee_id(struct ast_ASTArena *a, int32_t call_expr_ref, struct ast_Module *caller_mod,
                                      struct ast_PipelineDepCtx *ctx) {
  struct ast_Module *callee_mod;
  int32_t dep_ix;
  int32_t func_ix;
  int32_t callee_ref;
  int32_t cid;
  int32_t clen;
  uint8_t cname[64];
  if (!a || call_expr_ref <= 0)
    return -1;
  callee_ref = pipeline_expr_call_callee_ref_at(a, call_expr_ref);
  clen = asm_wpo_call_callee_name(a, callee_ref, cname);
  /** overload：须按实参分派，勿仅按名取首个 pick。 */
  if (clen > 0 && caller_mod) {
    int32_t ov_n = 0;
    int32_t fi_ov;
    int32_t nf_ov = pipeline_module_num_funcs(caller_mod);
    for (fi_ov = 0; fi_ov < nf_ov; fi_ov++) {
      if (pipeline_asm_module_func_is_extern_at(caller_mod, fi_ov) != 0)
        continue;
      if (pipeline_module_func_name_equal_at(caller_mod, fi_ov, cname, clen))
        ov_n++;
    }
    if (ov_n > 1) {
      int32_t picked = pipeline_typeck_pick_overload_func_index_for_call_c(caller_mod, a, call_expr_ref);
      if (picked >= 0) {
        cid = asm_wpo_func_id_of(caller_mod, picked);
        if (cid >= 0)
          return cid;
      }
    }
  }
  if (clen > 0) {
    cid = asm_wpo_func_id_in_module(caller_mod, cname, clen);
    if (cid < 0)
      cid = asm_wpo_func_id_by_name(cname, clen);
    if (cid >= 0)
      return cid;
  }
  func_ix = pipeline_expr_call_resolved_func_index_at(a, call_expr_ref);
  if (func_ix >= 0) {
    dep_ix = pipeline_expr_call_resolved_dep_index_at(a, call_expr_ref);
    callee_mod = caller_mod;
    if (dep_ix >= 0 && ctx)
      callee_mod = pipeline_dep_ctx_module_at(ctx, dep_ix);
    /** dep import / qualified callee：typeck resolved 为准；cname 与 FIELD_ACCESS 基名常不一致。 */
    if (clen > 0 && callee_mod && dep_ix < 0 &&
        pipeline_expr_kind_ord_at(a, callee_ref) != (int32_t)ast_ExprKind_EXPR_FIELD_ACCESS &&
        !pipeline_module_func_name_equal_at(callee_mod, func_ix, cname, clen))
      return -1;
    if (callee_mod) {
      cid = asm_wpo_func_id_of(callee_mod, func_ix);
      if (cid >= 0)
        return cid;
    }
  }
  return -1;
}

/** 前向声明：块内 call 边收集（collect_edges 与 collect_from_block 互递归）。 */
static void asm_wpo_collect_from_block(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                       struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx);

/** 递归收集表达式中的 call 边（depth 上限防栈溢出）。 */
static void asm_wpo_collect_edges_from_expr(struct ast_ASTArena *a, int32_t expr_ref, int32_t caller_id,
                                            struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx, int32_t depth) {
  struct ast_Expr *ex;
  int32_t i;
  int32_t cid;
  int32_t *arg_slot;
  if (!a || expr_ref <= 0 || caller_id < 0 || depth > 64)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  if (ex->kind == ast_ExprKind_EXPR_CALL) {
    cid = asm_wpo_call_callee_id(a, expr_ref, caller_mod, ctx);
    if (cid >= 0)
      asm_wpo_add_edge(caller_id, cid);
    for (i = 0; i < ex->call_num_args; i++) {
      arg_slot = expr_call_arg_slot(a, expr_ref, i, 0);
      if (arg_slot && *arg_slot > 0)
        asm_wpo_collect_edges_from_expr(a, *arg_slot, caller_id, caller_mod, ctx, depth + 1);
    }
    if (ex->call_callee_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->call_callee_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_RETURN || ex->kind == ast_ExprKind_EXPR_PANIC || ex->kind == ast_ExprKind_EXPR_NEG ||
      ex->kind == ast_ExprKind_EXPR_BITNOT || ex->kind == ast_ExprKind_EXPR_LOGNOT || ex->kind == ast_ExprKind_EXPR_ADDR_OF ||
      ex->kind == ast_ExprKind_EXPR_DEREF || ex->kind == ast_ExprKind_EXPR_AWAIT || ex->kind == ast_ExprKind_EXPR_RUN ||
      ex->kind == ast_ExprKind_EXPR_SPAWN) {
    {
      int32_t uop = pipeline_expr_unary_operand_ref_at(a, expr_ref);
      if (uop > 0)
        asm_wpo_collect_edges_from_expr(a, uop, caller_id, caller_mod, ctx, depth + 1);
    }
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_AS) {
    if (ex->as_operand_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->as_operand_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_IF || ex->kind == ast_ExprKind_EXPR_TERNARY) {
    if (ex->if_cond_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_cond_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->if_then_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_then_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->if_else_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->if_else_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->kind == ast_ExprKind_EXPR_BLOCK) {
    if (ex->block_ref > 0)
      asm_wpo_collect_from_block(a, ex->block_ref, caller_id, caller_mod, ctx);
    return;
  }
  if (ex->binop_left_ref > 0 || ex->binop_right_ref > 0) {
    if (ex->binop_left_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->binop_left_ref, caller_id, caller_mod, ctx, depth + 1);
    if (ex->binop_right_ref > 0)
      asm_wpo_collect_edges_from_expr(a, ex->binop_right_ref, caller_id, caller_mod, ctx, depth + 1);
    return;
  }
  if (ex->field_access_base_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->field_access_base_ref, caller_id, caller_mod, ctx, depth + 1);
  if (ex->index_base_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->index_base_ref, caller_id, caller_mod, ctx, depth + 1);
  if (ex->index_index_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->index_index_ref, caller_id, caller_mod, ctx, depth + 1);
  if (ex->method_call_base_ref > 0)
    asm_wpo_collect_edges_from_expr(a, ex->method_call_base_ref, caller_id, caller_mod, ctx, depth + 1);
}

/**
 * stmt_order 单步：按 kind 分派 const/let/expr/loop/for/if/region（与 typeck/codegen 一致）。
 * 现代 parser 以 stmt_order 为源码序权威；仅扫 legacy 池会漏 return/expr 边（WPO-S4 warm_mid UND）。
 */
static void asm_wpo_collect_from_stmt_order_one(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                              struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx,
                                              int32_t si) {
  struct ast_Block *b;
  uint8_t sk;
  int32_t idx;
  int32_t er;
  if (!a || block_ref <= 0 || caller_id < 0)
    return;
  b = pipeline_arena_block_ptr(a, block_ref);
  if (!b || si < 0 || si >= b->num_stmt_order)
    return;
  sk = pipeline_block_stmt_order_kind(a, block_ref, si);
  idx = pipeline_block_stmt_order_idx(a, block_ref, si);
  if (sk == 0 && idx >= 0 && idx < b->num_consts) {
    er = pipeline_block_const_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 1 && idx >= 0 && idx < b->num_lets) {
    er = pipeline_block_let_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 2 && idx >= 0 && idx < b->num_expr_stmts) {
    er = pipeline_block_expr_stmt_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  } else if (sk == 3 && idx >= 0 && idx < b->num_loops) {
    er = pipeline_block_while_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_while_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 4 && idx >= 0 && idx < b->num_for_loops) {
    er = pipeline_block_for_init_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_step_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_for_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 5 && idx >= 0 && idx < b->num_if_stmts) {
    er = pipeline_block_if_cond_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    er = pipeline_block_if_then_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    er = pipeline_block_if_else_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  } else if (sk == 6) {
    er = pipeline_block_region_body_ref(a, block_ref, idx);
    if (er > 0)
      asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
  }
}

/** 收集块内全部 call 边。 */
static void asm_wpo_collect_from_block(struct ast_ASTArena *a, int32_t block_ref, int32_t caller_id,
                                       struct ast_Module *caller_mod, struct ast_PipelineDepCtx *ctx) {
  struct ast_Block *b;
  int32_t i;
  int32_t er;
  struct ast_LabeledStmt *ls;
  if (!a || block_ref <= 0 || caller_id < 0)
    return;
  b = pipeline_arena_block_ptr(a, block_ref);
  if (!b)
    return;
  /** num_stmt_order>0 时按源码序 walk（与 backend emit_block 一致）；否则回退 legacy 池扫描。 */
  if (b->num_stmt_order > 0) {
    for (i = 0; i < b->num_stmt_order; i++)
      asm_wpo_collect_from_stmt_order_one(a, block_ref, caller_id, caller_mod, ctx, i);
    /** stmt_order 与 expr_stmt 池偶发不同步；再扫 expr_stmt 兜底（WPO-S4 return warm_mid 漏边）。 */
    for (i = 0; i < b->num_expr_stmts; i++) {
      er = pipeline_block_expr_stmt_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
  } else {
    for (i = 0; i < b->num_consts; i++) {
      er = pipeline_block_const_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
    for (i = 0; i < b->num_lets; i++) {
      er = pipeline_block_let_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
    for (i = 0; i < b->num_loops; i++) {
      er = pipeline_block_while_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_while_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_for_loops; i++) {
      er = pipeline_block_for_init_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_step_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_for_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_if_stmts; i++) {
      er = pipeline_block_if_cond_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
      er = pipeline_block_if_then_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
      er = pipeline_block_if_else_body_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_from_block(a, er, caller_id, caller_mod, ctx);
    }
    for (i = 0; i < b->num_expr_stmts; i++) {
      er = pipeline_block_expr_stmt_ref(a, block_ref, i);
      if (er > 0)
        asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
    }
  }
  /** C parser return 进 labeled 池且不进 stmt_order；须单独扫。 */
  for (i = 0; i < b->num_labeled_stmts; i++) {
    ls = pipeline_block_labeled_ptr(a, block_ref, i);
    if (!ls || ls->is_goto)
      continue;
    er = (int32_t)ls->return_expr_ref;
    if (er > 0)
      asm_wpo_collect_edges_from_expr(a, er, caller_id, caller_mod, ctx, 0);
  }
  if (b->final_expr_ref > 0)
    asm_wpo_collect_edges_from_expr(a, b->final_expr_ref, caller_id, caller_mod, ctx, 0);
}

/** 用户单文件 + SHUX_WPO_PGO_HOT：非自举 compiler 模块（pgo_hot_smoke 等）。 */
static int32_t asm_wpo_is_user_single_file_pgo_entry(void) {
  if (!pipeline_elf_pgo_hot_enabled() || !g_asm_wpo.entry || g_asm_wpo.nmods != 1)
    return 0;
  if (asm_module_is_main_driver_selfhost(g_asm_wpo.entry))
    return 0;
  if (asm_module_is_pipeline_selfhost(g_asm_wpo.entry) || asm_module_is_typeck_selfhost(g_asm_wpo.entry) ||
      asm_module_is_backend_selfhost(g_asm_wpo.entry) || asm_module_is_parser_selfhost(g_asm_wpo.entry))
    return 0;
  return 1;
}

/** 前向声明：user_program_entry 判定须查 main 的 WPO id。 */
static int32_t asm_wpo_user_main_func_id(void);

/**
 * 用户可执行/单测 .x（非 compiler 自举模块且含 main）：WPO root/reach 须从 main 出发。
 * main_func_index 误指 #0/mk 时若 root 从 mk 起算，main 虽 force emit 但 get_a 等 callee 会被 DCE。
 */
static int32_t asm_wpo_is_user_program_entry(void) {
  if (!g_asm_wpo.entry || g_asm_wpo.nmods != 1)
    return 0;
  if (asm_module_is_main_driver_selfhost(g_asm_wpo.entry))
    return 0;
  if (asm_module_is_pipeline_selfhost(g_asm_wpo.entry) || asm_module_is_typeck_selfhost(g_asm_wpo.entry) ||
      asm_module_is_backend_selfhost(g_asm_wpo.entry) || asm_module_is_parser_selfhost(g_asm_wpo.entry))
    return 0;
  return asm_wpo_user_main_func_id() >= 0 ? 1 : 0;
}

/** 用户程序 main 的 WPO func id；未找到返回 -1。 */
static int32_t asm_wpo_user_main_func_id(void) {
  static const uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  int32_t nf;
  int32_t fi;
  int32_t id;
  if (!g_asm_wpo.entry)
    return -1;
  nf = pipeline_module_num_funcs(g_asm_wpo.entry);
  for (fi = 0; fi < nf; fi++) {
    if (!pipeline_module_func_name_equal_at(g_asm_wpo.entry, fi, main_nm, 4))
      continue;
    id = asm_wpo_func_id_of(g_asm_wpo.entry, fi);
    if (id >= 0)
      return id;
  }
  return -1;
}

/** 扫描单函数体中的 call 边（caller_id 固定为图节点 id）。 */
static void asm_wpo_scan_func_body_calls(struct ast_ASTArena *a, struct ast_Module *mod, int32_t func_fi,
                                         int32_t caller_id, struct ast_PipelineDepCtx *ctx) {
  struct ast_Func *f;
  if (!a || !mod || caller_id < 0 || func_fi < 0)
    return;
  f = module_func_at(mod, func_fi);
  if (!f)
    return;
  if (f->body_ref > 0)
    asm_wpo_collect_from_block(a, f->body_ref, caller_id, mod, ctx);
  else if (f->body_expr_ref > 0)
    asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, caller_id, mod, ctx, 0);
}

/** BFS 前预收集全模块 call 边（避免 root 误指 #0 时漏扫 main 体）。 */
static void asm_wpo_precollect_all_func_edges(void) {
  int32_t fid;
  int32_t mi;
  struct ast_ASTArena *a;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    mi = asm_wpo_mod_index(g_asm_wpo.func_mod[fid]);
    a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
    asm_wpo_scan_func_body_calls(a, g_asm_wpo.func_mod[fid], g_asm_wpo.func_fi[fid], fid, g_asm_wpo.dep_ctx);
  }
}

/**
 * 用户 PGO：强制补 main 尾 return/expr_stmt 的直接 call 边；返回 callee func id 或 -1。
 */
static int32_t asm_wpo_user_pgo_force_main_callee_edge(struct ast_Module *entry, struct ast_ASTArena *a) {
  int32_t main_id;
  int32_t main_fi;
  struct ast_Func *f;
  struct ast_Block *b;
  int32_t er;
  int32_t op;
  int32_t cid;
  int32_t ko;
  if (!entry || !a)
    return -1;
  main_id = asm_wpo_user_main_func_id();
  if (main_id < 0)
    return -1;
  main_fi = g_asm_wpo.func_fi[main_id];
  f = module_func_at(entry, main_fi);
  if (!f || f->body_ref <= 0)
    return -1;
  b = pipeline_arena_block_ptr(a, f->body_ref);
  if (!b)
    return -1;
  er = 0;
  if (b->num_expr_stmts > 0)
    er = pipeline_block_expr_stmt_ref(a, f->body_ref, b->num_expr_stmts - 1);
  if (er <= 0 && b->final_expr_ref > 0)
    er = b->final_expr_ref;
  if (er <= 0)
    return -1;
  ko = pipeline_expr_kind_ord_at(a, er);
  if (ko == (int32_t)ast_ExprKind_EXPR_RETURN) {
    op = pipeline_expr_unary_operand_ref_at(a, er);
    if (op <= 0)
      return -1;
    er = op;
  }
  if (pipeline_expr_kind_ord_at(a, er) != (int32_t)ast_ExprKind_EXPR_CALL)
    return -1;
  cid = asm_wpo_call_callee_id(a, er, entry, g_asm_wpo.dep_ctx);
  if (cid >= 0)
    asm_wpo_add_edge(main_id, cid);
  return cid;
}

/** 用户 PGO：删除 main 上除 legit_to 外的误边（main 体误指 warm_mid 块时 main→hot_add）。 */
static void asm_wpo_user_pgo_prune_main_edges(int32_t main_id, int32_t legit_to) {
  int32_t ei;
  if (main_id < 0 || legit_to < 0)
    return;
  ei = 0;
  while (ei < g_asm_wpo.nedges) {
    if (g_asm_wpo.edges[ei].from == main_id && g_asm_wpo.edges[ei].to != legit_to) {
      g_asm_wpo.edges[ei] = g_asm_wpo.edges[g_asm_wpo.nedges - 1];
      g_asm_wpo.nedges--;
      continue;
    }
    ei++;
  }
}

/**
 * 在已有 reachable 集合上反复补边 + BFS 扩展（至多 16 轮）。
 * SKIP_TYPECK 自举模块 call graph 首轮常不完整，须 fixpoint 才能保留编排链 callee。
 */
static void asm_wpo_reach_fixpoint_expand(void) {
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t pass;
  int32_t fid;
  int32_t expanded;
  struct ast_Module *m;
  struct ast_ASTArena *a;
  struct ast_Func *f;
  int32_t mi;
  int32_t fi;
  int32_t ei;
  int32_t to;

  for (pass = 0; pass < 16; pass++) {
    expanded = 0;
    for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
      if (!g_asm_wpo.reachable[(size_t)fid])
        continue;
      m = g_asm_wpo.func_mod[fid];
      fi = g_asm_wpo.func_fi[fid];
      mi = asm_wpo_mod_index(m);
      a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
      f = module_func_at(m, fi);
      if (!a || !f)
        continue;
      if (f->body_ref > 0)
        asm_wpo_collect_from_block(a, f->body_ref, fid, m, g_asm_wpo.dep_ctx);
      else if (f->body_expr_ref > 0)
        asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, fid, m, g_asm_wpo.dep_ctx, 0);
    }
    qh = 0;
    qt = 0;
    for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
      if (g_asm_wpo.reachable[(size_t)fid] && qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = fid;
    }
    while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
      fid = queue[qh++];
      for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
        if (g_asm_wpo.edges[ei].from != fid)
          continue;
        to = g_asm_wpo.edges[ei].to;
        if (to < 0 || to >= g_asm_wpo.nfuncs)
          continue;
        if (!g_asm_wpo.reachable[(size_t)to]) {
          g_asm_wpo.reachable[(size_t)to] = 1;
          expanded = 1;
          if (qt < ASM_WPO_MAX_FUNCS)
            queue[qt++] = to;
        }
      }
    }
    if (!expanded)
      break;
  }
}

/** 从 root 起 BFS 标记 reachable 并补全边（与 codegen WPO 同语义）。 */
static void asm_wpo_build_reach(void) {
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  struct ast_Module *m;
  struct ast_ASTArena *a;
  struct ast_Func *f;
  int32_t mi;
  int32_t fi;
  int32_t ei;
  int32_t to;
  int32_t user_pgo;
  if (g_asm_wpo.root_id < 0 || g_asm_wpo.root_id >= g_asm_wpo.nfuncs)
    return;
  user_pgo = asm_wpo_is_user_single_file_pgo_entry();
  /** 预收集全图边 + 用户 PGO 补 main→直接 callee 并修剪误边（warm_mid UND / hot_add 误 hot）。 */
  asm_wpo_precollect_all_func_edges();
  if (user_pgo && g_asm_wpo.entry && g_asm_wpo.nmods > 0) {
    int32_t main_callee = asm_wpo_user_pgo_force_main_callee_edge(g_asm_wpo.entry, g_asm_wpo.arenas[0]);
    int32_t main_id = asm_wpo_user_main_func_id();
    if (main_id >= 0 && main_callee >= 0)
      asm_wpo_user_pgo_prune_main_edges(main_id, main_callee);
  }
  qh = 0;
  qt = 0;
  g_asm_wpo.reachable[(size_t)g_asm_wpo.root_id] = 1;
  queue[qt++] = g_asm_wpo.root_id;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    m = g_asm_wpo.func_mod[fid];
    fi = g_asm_wpo.func_fi[fid];
    mi = asm_wpo_mod_index(m);
    a = (mi >= 0) ? g_asm_wpo.arenas[mi] : NULL;
    f = module_func_at(m, fi);
    if (a && f) {
      if (f->body_ref > 0)
        asm_wpo_collect_from_block(a, f->body_ref, fid, m, g_asm_wpo.dep_ctx);
      else if (f->body_expr_ref > 0)
        asm_wpo_collect_edges_from_expr(a, f->body_expr_ref, fid, m, g_asm_wpo.dep_ctx, 0);
    }
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to]) {
        g_asm_wpo.reachable[(size_t)to] = 1;
        if (qt < ASM_WPO_MAX_FUNCS)
          queue[qt++] = to;
      }
    }
  }
  asm_wpo_reach_fixpoint_expand();
}

/**
 * 模块是否含 allocator_kind_heap（std.heap 特征 export）。
 */
static int32_t asm_wpo_mod_is_std_heap(struct ast_Module *m) {
  int32_t fi;
  int32_t nf;
  if (!m)
    return 0;
  nf = pipeline_module_num_funcs(m);
  for (fi = 0; fi < nf; fi++) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"allocator_kind_heap", 19))
      return 1;
  }
  return 0;
}

/**
 * std.heap allocator_* 同模块 helpers 偶发漏边（return-in-if）；reachable 时强制保留 alloc/arena64_alloc/realloc。
 */
static void asm_wpo_close_std_heap_helpers(void) {
  int32_t fid;
  struct ast_Module *heap_mod;
  heap_mod = 0;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    if (!g_asm_wpo.reachable[(size_t)fid])
      continue;
    if (asm_wpo_mod_is_std_heap(g_asm_wpo.func_mod[fid])) {
      heap_mod = g_asm_wpo.func_mod[fid];
      break;
    }
  }
  if (!heap_mod)
    return;
  for (fid = 0; fid < g_asm_wpo.nfuncs; fid++) {
    uint8_t fn[64];
    int32_t fl;
    int32_t fi;
    if (g_asm_wpo.func_mod[fid] != heap_mod)
      continue;
    fi = g_asm_wpo.func_fi[fid];
    fl = pipeline_module_func_name_len_at(heap_mod, fi);
    if (fl <= 0 || fl > 63)
      continue;
    pipeline_module_func_name_copy64(heap_mod, fi, fn);
    if (pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"alloc", 5) ||
        pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"arena64_alloc", 11) ||
        pipeline_module_func_name_equal_at(heap_mod, fi, (uint8_t *)"realloc", 7))
      g_asm_wpo.reachable[(size_t)fid] = 1;
  }
  {
    static const uint8_t *hc_names[3];
    static const int32_t hc_lens[3] = {20, 12, 15};
    int32_t hj;
    hc_names[0] = (const uint8_t *)"heap_arena64_alloc_c";
    hc_names[1] = (const uint8_t *)"heap_alloc_c";
    hc_names[2] = (const uint8_t *)"heap_realloc_c";
    for (hj = 0; hj < 3; hj++) {
      int32_t cid2 = asm_wpo_func_id_by_name((uint8_t *)hc_names[hj], hc_lens[hj]);
      if (cid2 >= 0)
        g_asm_wpo.reachable[(size_t)cid2] = 1;
    }
  }
}

/** SHUX_WPO_PGO_HOT=1 时：root 与其直接 callee 标记 hot（静态 call-depth 代理）。 */
static void asm_wpo_mark_pgo_hot(void) {
  int32_t root;
  int32_t ei;
  int32_t to;
  int32_t nf;
  int32_t fi;
  int32_t mid;
  static const uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  memset(g_asm_wpo_pgo_hot, 0, sizeof(g_asm_wpo_pgo_hot));
  if (!pipeline_elf_pgo_hot_enabled())
    return;
  root = g_asm_wpo.root_id;
  if (root < 0 || root >= g_asm_wpo.nfuncs)
    return;
  g_asm_wpo_pgo_hot[(size_t)root] = 1;
  /** 用户 PGO：main + 其 return 直接 callee 进 .text.hot（勿用误扫的 main→hot_add 边）。 */
  if (asm_wpo_is_user_single_file_pgo_entry()) {
    int32_t main_id = asm_wpo_user_main_func_id();
    int32_t main_callee;
    if (main_id >= 0) {
      g_asm_wpo_pgo_hot[(size_t)main_id] = 1;
      if (g_asm_wpo.entry && g_asm_wpo.nmods > 0) {
        main_callee = asm_wpo_user_pgo_force_main_callee_edge(g_asm_wpo.entry, g_asm_wpo.arenas[0]);
        if (main_callee >= 0 && g_asm_wpo.reachable[(size_t)main_callee])
          g_asm_wpo_pgo_hot[(size_t)main_callee] = 1;
      }
    }
    return;
  }
  /** 用户程序：入口 main 须进 .text.hot（root 误指 #0 占位符时兜底，与 should_emit main 保留配套）。 */
  if (g_asm_wpo.entry && !asm_module_is_main_driver_selfhost(g_asm_wpo.entry)) {
    nf = pipeline_module_num_funcs(g_asm_wpo.entry);
    for (fi = 0; fi < nf; fi++) {
      if (!pipeline_module_func_name_equal_at(g_asm_wpo.entry, fi, main_nm, 4))
        continue;
      mid = asm_wpo_func_id_of(g_asm_wpo.entry, fi);
      if (mid >= 0)
        g_asm_wpo_pgo_hot[(size_t)mid] = 1;
    }
  }
  for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
    if (g_asm_wpo.edges[ei].from != root)
      continue;
    to = g_asm_wpo.edges[ei].to;
    if (to < 0 || to >= g_asm_wpo.nfuncs)
      continue;
    if (g_asm_wpo.reachable[(size_t)to])
      g_asm_wpo_pgo_hot[(size_t)to] = 1;
  }
}

/** PGO-Lite S2：自 root BFS 标记 call-depth（供 .text.hot / unlikely emit 排序）。 */
static void asm_wpo_mark_pgo_depth_user_from_main(void) {
  int32_t main_id;
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  int32_t ei;
  int32_t to;
  int32_t nd;
  main_id = asm_wpo_user_main_func_id();
  if (main_id < 0 || main_id >= g_asm_wpo.nfuncs)
    return;
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  g_asm_wpo_pgo_depth[(size_t)main_id] = 0;
  qh = 0;
  qt = 1;
  queue[0] = main_id;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    nd = g_asm_wpo_pgo_depth[(size_t)fid];
    if (nd < 0)
      continue;
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to])
        continue;
      if (g_asm_wpo_pgo_depth[(size_t)to] >= 0)
        continue;
      g_asm_wpo_pgo_depth[(size_t)to] = nd + 1;
      if (qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = to;
    }
  }
}

/** PGO-Lite S2：自 root BFS 标记 call-depth（供 .text.hot / unlikely emit 排序）。 */
static void asm_wpo_mark_pgo_depth(void) {
  int32_t root;
  int32_t queue[ASM_WPO_MAX_FUNCS];
  int32_t qh;
  int32_t qt;
  int32_t fid;
  int32_t ei;
  int32_t to;
  int32_t nd;
  memset(g_asm_wpo_pgo_depth, 0xff, sizeof(g_asm_wpo_pgo_depth));
  if (!pipeline_elf_pgo_hot_enabled() || !g_asm_wpo.valid)
    return;
  /** 用户 PGO 单文件：depth 恒以 main 为根（勿用误 root 导致 warm_mid depth0 先于 main emit）。 */
  if (asm_wpo_is_user_single_file_pgo_entry()) {
    asm_wpo_mark_pgo_depth_user_from_main();
    return;
  }
  root = g_asm_wpo.root_id;
  if (root < 0 || root >= g_asm_wpo.nfuncs)
    return;
  g_asm_wpo_pgo_depth[(size_t)root] = 0;
  qh = 0;
  qt = 1;
  queue[0] = root;
  while (qh < qt && qh < ASM_WPO_MAX_FUNCS) {
    fid = queue[qh++];
    nd = g_asm_wpo_pgo_depth[(size_t)fid];
    if (nd < 0)
      continue;
    for (ei = 0; ei < g_asm_wpo.nedges; ei++) {
      if (g_asm_wpo.edges[ei].from != fid)
        continue;
      to = g_asm_wpo.edges[ei].to;
      if (to < 0 || to >= g_asm_wpo.nfuncs)
        continue;
      if (!g_asm_wpo.reachable[(size_t)to])
        continue;
      if (g_asm_wpo_pgo_depth[(size_t)to] >= 0)
        continue;
      g_asm_wpo_pgo_depth[(size_t)to] = nd + 1;
      if (qt < ASM_WPO_MAX_FUNCS)
        queue[qt++] = to;
    }
  }
}

/** 取 (module, fi) 的 PGO call-depth；未知/不可达返回 9999。 */
static int32_t asm_wpo_pgo_depth_of(struct ast_Module *m, int32_t fi) {
  int32_t id;
  int32_t d;
  if (!m || fi < 0)
    return 9999;
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 9999;
  d = g_asm_wpo_pgo_depth[(size_t)id];
  if (d < 0)
    return 9999;
  return d;
}

/** 读 SHUX_ASM_WPO_DCE：未设或非 "0" 时启用 asm WPO DCE；设为 0 时关闭（A/B __text bench）。
 * SHUX_WPO_NO_FOLD=1 时亦关闭：对照 bench 须保留 lane0/scale 等 callee 定义，避免 reach 漏边导致 UNDEF。 */
static int32_t asm_wpo_dce_env_enabled(void) {
  if (getenv("SHUX_WPO_NO_FOLD"))
    return 0;
  const char *e = getenv("SHUX_ASM_WPO_DCE");
  if (!e || e[0] == '\0')
    return 1;
  if (e[0] == '0' && (e[1] == '\0' || e[1] == '\n'))
    return 0;
  return 1;
}

/** 在 asm_codegen_elf_o 入口：登记 entry+deps 全部函数并构建 WPO reach。 */
void pipeline_asm_wpo_reach_compute_for_elf(struct ast_Module *entry, struct ast_ASTArena *entry_arena,
                                            struct ast_PipelineDepCtx *ctx) {
  int32_t ndep;
  int32_t j;
  struct ast_Module *dm;
  struct ast_ASTArena *da;
  int32_t mi;
  int32_t nf;
  int32_t fi;
  int32_t main_ix;
  uint8_t main_nm[5] = {'m', 'a', 'i', 'n', 0};
  pipeline_asm_wpo_reach_clear();
  if (!entry || !entry_arena)
    return;
  /** A/B bench：SHUX_ASM_WPO_DCE=0 时不构图，emit 全量函数。 */
  if (!asm_wpo_dce_env_enabled())
    return;
  /**
   * 用户库 module .o（无 main、无 entry）：须全量 export 进 .o，勿 WPO 误留 emit_n=1 空壳。
   */
  main_ix = pipeline_module_main_func_index(entry);
  if (main_ix < 0) {
    static const uint8_t entry_nm[6] = {'e', 'n', 't', 'r', 'y', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, entry_nm, 5))
        break;
    }
    if (fi >= nf)
      return;
  }
  /**
   * build_shux_asm EMIT_HEAVY 第二遍：全 compiler 自举模块均可 WPO（root 按模块名设置）。
   * pipeline/typeck/backend 分别以 run_x_pipeline_impl / typeck_x_ast / asm_codegen_ast 为 root。
   */
  g_asm_wpo.entry = entry;
  g_asm_wpo.dep_ctx = ctx;
  if (asm_wpo_register_mod(entry, entry_arena) < 0)
    return;
  if (ctx) {
    ndep = pipeline_dep_ctx_ndep(ctx);
    for (j = 0; j < ndep; j++) {
      dm = pipeline_dep_ctx_module_at(ctx, j);
      da = pipeline_dep_ctx_arena_at(ctx, j);
      if (!dm || !da || dm == entry)
        continue;
      (void)asm_wpo_register_mod(dm, da);
    }
  }
  for (mi = 0; mi < g_asm_wpo.nmods; mi++) {
    nf = pipeline_module_num_funcs(g_asm_wpo.mods[mi]);
    for (fi = 0; fi < nf; fi++)
      (void)asm_wpo_register_func(g_asm_wpo.mods[mi], fi);
  }
  /** driver main.x 可执行入口为 entry；须优先于 main_func_index（常误指 #0 占位符 → 32B 错杀 entry）。 */
  {
    static const uint8_t entry_nm[6] = {'e', 'n', 't', 'r', 'y', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, entry_nm, 5)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** 用户程序 root 为 main；须先于 main_func_index（首函数 mk/占位常误设 #0）。 */
  if (g_asm_wpo.root_id < 0) {
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, main_nm, 4)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** pipeline.x 编排根：run_x_pipeline_impl（优于 main_func_index #0 占位符）。 */
  if (g_asm_wpo.root_id < 0 && asm_module_is_pipeline_selfhost(entry)) {
    static const uint8_t pipe_impl_nm[21] = {'r', 'u', 'n', '_', 's', 'u', '_', 'p', 'i', 'p', 'e', 'l', 'i', 'n', 'e', '_', 'i', 'm', 'p', 'l', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, (uint8_t *)pipe_impl_nm, 20)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** typeck.x 编排根：typeck_x_ast（S2 gate + pipeline typecheck 入口）。 */
  if (g_asm_wpo.root_id < 0 && asm_module_is_typeck_selfhost(entry)) {
    static uint8_t typeck_root_nm[14] = {'t', 'y', 'p', 'e', 'c', 'k', '_', 's', 'u', '_', 'a', 's', 't', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, typeck_root_nm, 13)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  /** backend.x 编排根：asm_codegen_ast（pipeline codegen 入口；mega 仍 EMIT_HEAVY 桩）。 */
  if (g_asm_wpo.root_id < 0 && asm_module_is_backend_selfhost(entry)) {
    static uint8_t backend_root_nm[16] = {'a', 's', 'm', '_', 'c', 'o', 'd', 'e', 'g', 'e', 'n', '_', 'a', 's', 't', 0};
    nf = pipeline_module_num_funcs(entry);
    for (fi = 0; fi < nf; fi++) {
      if (pipeline_module_func_name_equal_at(entry, fi, backend_root_nm, 15)) {
        g_asm_wpo.root_id = asm_wpo_func_id_of(entry, fi);
        break;
      }
    }
  }
  main_ix = pipeline_module_main_func_index(entry);
  /** main_func_index 仅当其确实指向名为 main 的函数时作 fallback（勿用 #0 误根）。 */
  if (g_asm_wpo.root_id < 0 && main_ix >= 0 &&
      pipeline_module_func_name_equal_at(entry, main_ix, main_nm, 4))
    g_asm_wpo.root_id = asm_wpo_func_id_of(entry, main_ix);
  if (g_asm_wpo.root_id < 0 || g_asm_wpo.nfuncs <= 0)
    return;
  /** 用户程序：root 强制 main（#0/mk 误根会导致 main 所调 get_a 等 callee UND）。 */
  if (asm_wpo_is_user_program_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.root_id = user_main;
  } else if (asm_wpo_is_user_single_file_pgo_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.root_id = user_main;
  }
  asm_wpo_build_reach();
  asm_wpo_close_std_heap_helpers();
  /** main force emit 时须纳入 reach 闭包，fixpoint 从 main 补全 callee 边。 */
  if (asm_wpo_is_user_program_entry()) {
    int32_t user_main = asm_wpo_user_main_func_id();
    if (user_main >= 0)
      g_asm_wpo.reachable[(size_t)user_main] = 1;
  }
  asm_wpo_reach_fixpoint_expand();
  g_asm_wpo.valid = 1;
  asm_wpo_mark_pgo_hot();
  asm_wpo_mark_pgo_depth();
}

/** 前向声明：emit 顺序构建须过滤 WPO dead export。 */
int32_t pipeline_asm_wpo_should_emit_func(struct ast_Module *m, int32_t fi);

/**
 * 为 module 构建 emit 顺序表：WPO 过滤后按 call-depth 升序（同 depth 按 func_index）。
 * asm_codegen_ast_to_elf 每 Module 入口调用一次。
 */
void pipeline_asm_wpo_pgo_emit_order_prepare(struct ast_Module *m) {
  int32_t nf;
  int32_t fi;
  int32_t n;
  int32_t a;
  int32_t b;
  int32_t tmp;
  int32_t da;
  int32_t db;
  if (!m) {
    g_asm_wpo_pgo_emit_mod = NULL;
    g_asm_wpo_pgo_emit_n = 0;
    return;
  }
  g_asm_wpo_pgo_emit_mod = m;
  n = 0;
  nf = pipeline_module_num_funcs(m);
  fi = 0;
  while (fi < nf) {
    if (pipeline_asm_module_func_is_extern_at(m, fi) == 0 && pipeline_asm_wpo_should_emit_func(m, fi) != 0) {
      if (n < ASM_WPO_MAX_FUNCS)
        g_asm_wpo_pgo_emit_order[n] = fi;
      n = n + 1;
    }
    fi = fi + 1;
  }
  /**
   * asm -o 不能让 WPO/reach 误判把待 emit 集合裁成空集，否则 backend 连当前函数名都拿不到，
   * 最终只会以 empty __text / func unknown 的形式失败。仅在空集合时保守退回全部非 extern 函数。
   */
  if (n == 0 && nf > 0) {
    fi = 0;
    while (fi < nf) {
      if (pipeline_asm_module_func_is_extern_at(m, fi) == 0) {
        if (n < ASM_WPO_MAX_FUNCS)
          g_asm_wpo_pgo_emit_order[n] = fi;
        n = n + 1;
      }
      fi = fi + 1;
    }
  }
  if (pipeline_elf_pgo_hot_enabled() && g_asm_wpo.valid) {
    a = 0;
    while (a < n) {
      b = a + 1;
      while (b < n) {
        da = asm_wpo_pgo_depth_of(m, g_asm_wpo_pgo_emit_order[a]);
        db = asm_wpo_pgo_depth_of(m, g_asm_wpo_pgo_emit_order[b]);
        if (da > db || (da == db && g_asm_wpo_pgo_emit_order[a] > g_asm_wpo_pgo_emit_order[b])) {
          tmp = g_asm_wpo_pgo_emit_order[a];
          g_asm_wpo_pgo_emit_order[a] = g_asm_wpo_pgo_emit_order[b];
          g_asm_wpo_pgo_emit_order[b] = tmp;
        }
        b = b + 1;
      }
      a = a + 1;
    }
  }
  g_asm_wpo_pgo_emit_n = n;
}

/** 返回 module 待 emit 函数个数（须先 prepare 或 lazy prepare）。 */
int32_t pipeline_asm_wpo_pgo_emit_order_count(struct ast_Module *m) {
  if (m != g_asm_wpo_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  return g_asm_wpo_pgo_emit_n;
}

/** 第 order_index 个待 emit 函数的 func_index；越界返回 -1。 */
int32_t pipeline_asm_wpo_pgo_emit_order_at(struct ast_Module *m, int32_t order_index) {
  if (m != g_asm_wpo_pgo_emit_mod)
    pipeline_asm_wpo_pgo_emit_order_prepare(m);
  if (order_index < 0 || order_index >= g_asm_wpo_pgo_emit_n)
    return -1;
  return g_asm_wpo_pgo_emit_order[order_index];
}

/**
 * PGO-Lite emit 查询：1=写入 .text.hot，0=写入 .text；未启用 SHUX_WPO_PGO_HOT 时恒 0。
 */
int32_t pipeline_asm_wpo_pgo_is_hot_func(struct ast_Module *m, int32_t fi) {
  int32_t id;
  if (!pipeline_elf_pgo_hot_enabled())
    return 0;
  if (!g_asm_wpo.valid)
    return 1;
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 0;
  return g_asm_wpo_pgo_hot[(size_t)id] ? 1 : 0;
}

/** pipeline.x WPO：strict 编排链 export 须保留（SKIP_TYPECK 时 call graph 兜底）。 */
static int32_t asm_wpo_pipeline_strict_preserve_emit(struct ast_Module *m, int32_t fi) {
  if (!m || fi < 0 || !asm_module_is_pipeline_selfhost(m))
    return 0;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_impl", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_parse_entry_if_needed", 37))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_parse_entry_do_parse", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_typecheck_entry", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_deps", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_entry", 29))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"run_x_pipeline_codegen_one_dep", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_typeck_entry_module", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_typeck_parsed_module", 27))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"resolve_path_x", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_should_skip_x_typeck", 30))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"read_file_x", 12))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_load_and_sync_direct_import_deps", 41))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_parse_into_buf", 23))
    return 1;
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"pipeline_parse_set_main_from_buf", 32))
    return 1;
  return 0;
}

/**
 * asm emit 前查询：1=应发射，0= WPO dead export 跳过；未启用 WPO 或 extern 保守保留。
 */
int32_t pipeline_asm_wpo_should_emit_func(struct ast_Module *m, int32_t fi) {
  struct ast_Func *f;
  int32_t id;
  if (!g_asm_wpo.valid)
    return 1;
  f = module_func_at(m, fi);
  if (!f || f->is_extern)
    return 1;
  /** 入口模块的 entry 符号须保留（CLI / crt0 / bridge 链）。 */
  if (m == g_asm_wpo.entry && pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"entry", 5))
    return 1;
  /** 用户程序须 export main（WPO root 误指 #0/mk 时兜底，与 root 按名 main 优先配套）。 */
  if (m == g_asm_wpo.entry && !asm_module_is_main_driver_selfhost(m) &&
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"main", 4))
    return 1;
  /**
   * build_asm/main.o 生产链：WPO 启用时仅 export entry（~512B 内），
   * 其余 driver helper 由 runtime_driver / driver_*_x.o 提供。
   */
  if (m == g_asm_wpo.entry && asm_module_is_main_driver_selfhost(m))
    return 0;
  /**
   * build_asm/driver_compile.o WPO 压缩：仅保留 WPO reach 内 export（~145B，常为 compile_dispatch_asm_backend）；
   * parse_argv / run_compiler_full_x 由 driver_compile_emit_heavy.o + link.o 提供。
   */
  if (m == g_asm_wpo.entry && asm_module_is_driver_compile_selfhost(m))
    return 0;
  /**
   * pipeline.x WPO：gate/strict 关键 export 须保留；其余走 reach DCE（勿 blanket return 0）。
   */
  if (asm_wpo_pipeline_strict_preserve_emit(m, fi))
    return 1;
  if (m == g_asm_wpo.entry && asm_module_is_pipeline_selfhost(m)) {
    /* 遗留显式名单已由 asm_wpo_pipeline_strict_preserve_emit 覆盖；保留 reach 路径。 */
  }
  /**
   * typeck.x WPO：S2 gate 关键 export + pipeline merge 须保留；其余走 reach DCE。
   */
  if (m == g_asm_wpo.entry && asm_module_is_typeck_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_x_ast", 13))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_x_ast_library", 21))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"check_block", 11))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"check_expr", 10))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_merge_dep_struct_layouts_into_entry", 42))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"typeck_wpo_unify_soa_layouts", 28))
      return 1;
  }
  /**
   * backend.x WPO：codegen 入口 export 须保留；其余走 reach DCE（M8-tail 薄包装 bl→C）。
   */
  if (m == g_asm_wpo.entry && asm_module_is_backend_selfhost(m)) {
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"asm_codegen_ast_to_elf", 22))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"emit_expr_elf", 13))
      return 1;
    if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"emit_block_body_elf", 19))
      return 1;
  }
  id = asm_wpo_func_id_of(m, fi);
  if (id < 0)
    return 1;
  /**
   * std.heap：allocator_* reach 时 co-emit default_alloc/allocator_heap（薄模块缺 alloc 等，由 call redirect→libc）。
   */
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"default_alloc", 13) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_alloc", 14) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"alloc", 5) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"arena64_alloc", 11) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"realloc", 7)) {
    int32_t j;
    for (j = 0; j < g_asm_wpo.nfuncs; j++) {
      int32_t jfi;
      struct ast_Module *jm;
      if (!g_asm_wpo.reachable[(size_t)j])
        continue;
      jm = g_asm_wpo.func_mod[j];
      jfi = g_asm_wpo.func_fi[j];
      if (!jm || jfi < 0)
        continue;
      if (pipeline_module_func_name_equal_at(jm, jfi, (uint8_t *)"alloc", 5) ||
          pipeline_module_func_name_equal_at(jm, jfi, (uint8_t *)"realloc", 7))
        return 1;
    }
  }
  /** heap_libc：std.heap allocator 已 reach 时 co-emit heap_*_c 桥。 */
  if (pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_arena64_alloc_c", 20) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_alloc_c", 12) ||
      pipeline_module_func_name_equal_at(m, fi, (uint8_t *)"heap_realloc_c", 15)) {
    int32_t j;
    for (j = 0; j < g_asm_wpo.nfuncs; j++) {
      struct ast_Module *hm;
      int32_t jfi;
      if (!g_asm_wpo.reachable[(size_t)j])
        continue;
      hm = g_asm_wpo.func_mod[j];
      if (!asm_wpo_mod_is_std_heap(hm))
        continue;
      jfi = g_asm_wpo.func_fi[j];
      if (pipeline_module_func_name_equal_at(hm, jfi, (uint8_t *)"alloc", 5) ||
          pipeline_module_func_name_equal_at(hm, jfi, (uint8_t *)"realloc", 7))
        return 1;
    }
  }
  return g_asm_wpo.reachable[(size_t)id] ? 1 : 0;
}

/** bootstrap 链接 glue：pipeline 编排 / asm scope / typeck 指针写槽（误 revert 后补全）。 */
#include "ast_pool_bootstrap_glue.c"
