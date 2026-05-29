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

#ifndef AST_POOL_GROW
#define AST_POOL_GROW 64
#endif

/** 无实际上限：grow 直至 OOM；cap API 仅兼容旧 .su 边界检查。 */
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
} StructLayoutFieldEntry;

/** 顶层 let/const 槽。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t type_ref;
  int32_t init_ref;
  int32_t is_const;
} TopLevelLetEntry;

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
  GrowVec module_enums;
  GrowVec import_select_name_rows;
  GrowVec import_select_name_lens;
  GrowVec func_params;
  GrowVec struct_layout_fields;
} ModuleSidecar;

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

/** driver -su -E  argv 解析：DriverSuEmitState* 键控 lib_root grow 池。 */
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
      return &g_onefunc_sc[i];
    }
  }
  return NULL;
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
  if (!a || !(sc = arena_sidecar_get(a, 1)))
    return 0;
  if (grow_vec_push(&sc->funcs) < 0)
    return 0;
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
  if (ep)
    *ep = e;
}

/**
 * 在 C 侧初始化 EXPR_VAR，避免 SU→C 整结构 ast_arena_expr_set 拷贝导致 kind 等字段错位。
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
 * 在 C 侧初始化二元运算节点（kind 为 ast_ExprKind 序数值，与 .su ExprKind 一致）。
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
  if (bp)
    *bp = b;
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
  b->const_base = sc->consts.len;
  b->let_base = sc->lets.len;
  b->loop_base = sc->loops.len;
  b->for_loop_base = sc->for_loops.len;
  b->if_base = sc->ifs.len;
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
}

/** Module 侧分配新函数槽，返回 0-based 下标；失败返回 -1。 */
int32_t pipeline_module_func_alloc_slot(struct ast_Module *m) {
  ModuleSidecar *sc;
  int32_t idx;
  if (!m)
    return -1;
  sc = module_sidecar_get(m, 1);
  if (!sc)
    return -1;
  idx = grow_vec_push(&sc->funcs);
  if (idx < 0)
    return -1;
  grow_vec_push(&sc->func_refs);
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

/** 写 module 函数字段（替代 .su 直接写 module.funcs[i]）。 */
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

void pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n) {
  struct ast_Func *f = module_func_at(m, fi);
  if (f && n >= 0)
    f->num_params = n;
}

int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  f = module_func_at(m, func_index);
  return f ? (int32_t)f->num_params : 0;
}

int32_t pipeline_module_func_param_type_ref_for_name(struct ast_Module *m, int32_t func_index, uint8_t *var_name,
                                                     int32_t var_name_len) {
  struct ast_Func *f;
  int32_t n, i;
  FuncParamEntry *pe;
  if (!m || !var_name || func_index < 0 || func_index >= m->num_funcs)
    return 0;
  if (var_name_len <= 0 || var_name_len > 31)
    return 0;
  f = module_func_at(m, func_index);
  if (!f)
    return 0;
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

/** pipeline.su：读 module.num_funcs，避免 asm 对 Module 字段 FIELD_ACCESS。 */
int32_t pipeline_module_num_funcs(struct ast_Module *m) {
  return m ? (int32_t)m->num_funcs : 0;
}

/** pipeline.su：读 module.main_func_index。 */
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
 * strict asm 链：parse 前重置 arena/module（等价 parser.su parse_into_init）。
 * build_asm/parser.o 的 parse_into_init 不重置 sidecar grow 池，二次 parse 会累积 funcs。
 */
void pipeline_strict_parse_into_init(struct ast_ASTArena *arena, struct ast_Module *module) {
  ast_ast_arena_init(arena);
  ast_pool_module_reset(module);
  ast_pool_arena_reset(arena);
  if (module) {
    module->num_funcs = 0;
    module->main_func_index = -1;
    module->num_imports = 0;
    module->num_top_level_lets = 0;
    module->num_struct_layouts = 0;
    module->num_module_enums = 0;
  }
}

/** pipeline.su：读 arena.num_types（诊断 parse fail）。 */
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

/** Block 池 append/read — const */
int32_t pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                    int32_t type_ref, int32_t init_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  struct ast_ConstDecl *cd;
  int32_t idx;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = grow_vec_push(&sc->consts);
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
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = grow_vec_push(&sc->lets);
  if (idx < 0)
    return -1;
  ld = (struct ast_LetDecl *)grow_vec_at(&sc->lets, idx);
  memset(ld, 0, sizeof(*ld));
  if (name_len > 0 && name)
    memcpy(ld->name, name, (size_t)(name_len > 64 ? 64 : name_len));
  ld->name_len = name_len;
  ld->type_ref = type_ref;
  ld->init_ref = init_ref;
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
  idx = grow_vec_push(&sc->ifs);
  if (idx < 0)
    return -1;
  is = (struct ast_IfStmt *)grow_vec_at(&sc->ifs, idx);
  is->cond_ref = cond_ref;
  is->then_body_ref = then_ref;
  is->else_body_ref = else_ref;
  b->num_if_stmts++;
  return idx - b->if_base;
}

int32_t pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref) {
  ArenaSidecar *sc;
  struct ast_Block *b;
  int32_t idx;
  int32_t *pr;
  if (!a || !(sc = arena_sidecar_get(a, 1)) || !(b = block_at(a, br)))
    return -1;
  idx = grow_vec_push(&sc->expr_stmt_refs);
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
  idx = grow_vec_push(&sc->stmt_order);
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
  idx = grow_vec_push(&sc->loops);
  if (idx < 0)
    return -1;
  wl = (struct ast_WhileLoop *)grow_vec_at(&sc->loops, idx);
  if (!wl)
    return -1;
  wl->cond_ref = cond_ref;
  wl->body_ref = body_ref;
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
  idx = grow_vec_push(&sc->for_loops);
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
  idx = grow_vec_push(&sc->labeled_stmts);
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
 * 与 ast.su::ast_arena_patch_block_parent_links 一致；typeck 在 check_block 前调用。
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
  var_dbg = getenv("SHU_TYPECK_VAR");
  cur = block_ref;
  depth = 0;
  while (cur > 0 && cur <= a->num_blocks && depth < 128) {
    int32_t i;
    b = block_at(a, cur);
    if (!b)
      break;
    if (var_dbg) {
      fprintf(stderr, "shu: [SHU_TYPECK_VAR] block=%d parent=%d num_lets=%d depth=%d\n", (int)cur,
              (int)b->parent_block_ref, (int)b->num_lets, (int)depth);
    }
    for (i = 0; i < b->num_consts; i++) {
      struct ast_ConstDecl *cd = block_const_at(a, cur, i);
      if (cd && cd->type_ref != 0 && cd->name_len == vlen &&
          memcmp(cd->name, vname, (size_t)vlen) == 0)
        return (int32_t)cd->type_ref;
    }
    for (i = 0; i < b->num_lets; i++) {
      struct ast_LetDecl *ld = block_let_at(a, cur, i);
      if (ld && ld->type_ref != 0 && ld->name_len == vlen && memcmp(ld->name, vname, (size_t)vlen) == 0)
        return (int32_t)ld->type_ref;
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

/** 将 OneFunc 中 if 链批量写入 Block 池。 */
void pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
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

void pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  if (sl)
    sl->allow_padding = v;
}

int32_t pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx) {
  struct ast_StructLayout *sl = module_layout_at(m, idx);
  return sl ? sl->allow_padding : 0;
}

/** typeck.su：读 module.num_struct_layouts；勿 SU 内 Module 字段访问（check_block 失败）。 */
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
 * 将 module 顶层 let/const 按序并入 main 函数体块（作为块内 let），供 asm 后端在 main 栈槽初始化。
 * 完成后清空 num_top_level_lets，避免 C 路径重复 init_globals。
 */
void pipeline_module_hoist_top_level_lets_into_main(struct ast_Module *m, struct ast_ASTArena *a) {
  int32_t mi;
  int32_t br;
  int32_t tl;
  int32_t n;
  int32_t let_start_idx;
  uint8_t name_buf[64];
  int32_t name_len;
  int32_t k;
  ModuleSidecar *sc;
  TopLevelLetEntry *ent;
  struct ast_Block *main_blk;
  if (!m || !a || m->main_func_index < 0 || m->num_top_level_lets <= 0)
    return;
  mi = m->main_func_index;
  br = pipeline_module_func_body_ref_at(m, mi);
  if (br <= 0)
    return;
  sc = module_sidecar_get(m, 0);
  if (!sc)
    return;
  main_blk = block_at(a, br);
  let_start_idx = main_blk ? main_blk->num_lets : 0;
  n = m->num_top_level_lets;
  for (tl = 0; tl < n; tl++) {
    if (tl < 0 || tl >= sc->top_level_lets.len)
      break;
    ent = (TopLevelLetEntry *)grow_vec_at(&sc->top_level_lets, tl);
    if (!ent || ent->name_len <= 0 || ent->name_len > 64)
      continue;
    name_len = ent->name_len;
    for (k = 0; k < name_len; k++)
      name_buf[k] = ent->name[k];
    (void)pipeline_block_append_let(a, br, name_buf, name_len, ent->type_ref, ent->init_ref);
  }
  pipeline_block_stmt_order_prepend_lets(a, br, let_start_idx, n);
  sc->top_level_lets.len = 0;
  m->num_top_level_lets = 0;
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
    pipeline_block_append_while(a, br, pipeline_onefunc_while_cond_ref(out, i),
                                pipeline_onefunc_while_body_ref(out, i));
  }
}

void pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  int32_t i;
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

/** codegen.su：读 current_codegen_prefix_len，避免 asm 对大 PipelineDepCtx 字段 FIELD_ACCESS。 */
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

/** pipeline.su：返回 path_buf 首地址，供 fs_open_read 等 *u8 API。 */
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

/** pipeline.su：读 entry_dir_len。 */
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

/** CodegenOutBuf.len 读写（pipeline.su 避免 *CodegenOutBuf 字段 FIELD_ACCESS；layout 与 codegen.su 一致）。 */
struct codegen_CodegenOutBuf;

int32_t codegen_out_buf_len(struct codegen_CodegenOutBuf *out) {
  if (!out)
    return 0;
  return *(int32_t *)((uint8_t *)out + (ptrdiff_t)8388608);
}

void codegen_out_buf_set_len(struct codegen_CodegenOutBuf *out, int32_t n) {
  if (out)
    *(int32_t *)((uint8_t *)out + (ptrdiff_t)8388608) = n > 0 ? n : 0;
}

/** ---------- PipelineDepCtx 源缓冲堆分配（根因：避免 ctx 内嵌 4MiB×2 撑爆栈/asm emit） ---------- */

#define PIPELINE_SOURCE_BUF_CAP 4194304

/** 源缓冲内嵌于 ast.su PipelineDepCtx（loaded_buf/preprocess_buf 各 4MiB）；无需堆分配。 */
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

/** pipeline.su：返回 loaded_buf 首地址，供 fs_read 等 *u8 API。 */
uint8_t *pipeline_dep_ctx_loaded_buf_ptr(struct ast_PipelineDepCtx *ctx) {
  if (!ctx)
    return NULL;
  return ctx->loaded_buf;
}

/** pipeline.su：返回 preprocess_buf 首地址，供 dep parse_into_with_init_buf 使用。 */
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

/** shu check 标志在 runtime driver 槽；PipelineDepCtx 无该字段（与 ast.su 布局一致）。 */
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

/** 读 lib_root 路径第 off 字节；越界或无效返回 0（避免 pipeline.su 侧整段 copy 大缓冲）。 */
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

/** codegen 无名形参下标 grow 池（替代 PipelineDepCtx 内联 [16]i32）。 */
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

/** backend.su：import 限定符号解析时的 field 层栈（替代 [16][64] 栈数组）。 */
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

/** preprocess.su：#if/#else 嵌套栈（替代 [32]i32 固定栈）。 */
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

/** typeck.su：命名类型对齐/大小时复用的 64 字节 scratch（避免局部 [64]u8 在自 typecheck 时 check_block 失败）。 */
uint8_t *typeck_named_scratch64(void) {
  static uint8_t s[64];
  return s;
}

/** typeck.su：多槽 64 字节 scratch；嵌套 layout/struct_lit 路径须用不同 slot 避免覆盖。 */
static uint8_t g_typeck_scratch64[16][64];

uint8_t *typeck_scratch64_slot(int32_t slot) {
  if (slot < 0 || slot >= 16)
    return g_typeck_scratch64[0];
  return g_typeck_scratch64[slot];
}

/** typeck.su：CALL resolve 写 func 下标用；勿用栈上 &cfi（自举 pipeline 下可撕裂致 segfault）。 */
static int32_t g_typeck_call_resolve_func_idx;

int32_t *typeck_call_resolve_func_idx_slot(void) {
  return &g_typeck_call_resolve_func_idx;
}

/** typeck.su：struct_layout_metrics 写 out_sz/out_al；勿用栈上 &z/&al。 */
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

/**
 * platform/elf.su：ElfCodegenCtx 体量大，.su/asm 对 patches[pi].* / relocs[ri].* 字段写入 typeck 失败；
 * 布局须与 elf.su 中 ElfLabelEntry / ElfPatchEntry / ElfRelocEntry 前缀一致（改 elf.su 时同步）。
 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  int32_t offset;
} PipelineElfLabelEntry;

typedef struct {
  int32_t rel32_offset;
  uint8_t name[64];
  int32_t name_len;
  int32_t patch_imm_bits;
} PipelineElfPatchEntry;

typedef struct {
  int32_t offset;
  int32_t name_len;
} PipelineElfRelocEntry;

typedef struct {
  int32_t code_len;
  PipelineElfLabelEntry labels[2048];
  int32_t num_labels;
  PipelineElfPatchEntry patches[2048];
  int32_t num_patches;
  PipelineElfRelocEntry relocs[2048];
  uint8_t reloc_sym_names[2048][64];
  int32_t num_relocs;
} PipelineElfCtxAccess;

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

/** 追加或更新局部标签；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_add_label(uint8_t *ctx_bytes, uint8_t *name, int32_t name_len, int32_t offset) {
  PipelineElfCtxAccess *ctx;
  int32_t l;
  int32_t li;
  int32_t n;
  if (!ctx_bytes || !name || name_len < 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  l = 0;
  while (l < ctx->num_labels) {
    if (ctx->labels[l].name_len == name_len && name_len > 0 &&
        memcmp(ctx->labels[l].name, name, (size_t)name_len) == 0) {
      ctx->labels[l].offset = offset;
      return 0;
    }
    l = l + 1;
  }
  if (ctx->num_labels >= 2048)
    return -1;
  li = ctx->num_labels;
  n = name_len > 64 ? 64 : name_len;
  if (n > 0)
    memcpy(ctx->labels[li].name, name, (size_t)n);
  ctx->labels[li].name_len = name_len;
  ctx->labels[li].offset = offset;
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
  if (ctx->num_patches >= 2048) {
    fprintf(stderr, "shu: elf num_patches limit 2048 reached\n");
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
  ctx->num_patches = ctx->num_patches + 1;
  return 0;
}

/** 读取第 patch_idx 条补丁的 imm_bits；越界返回 0。 */
int32_t pipeline_elf_ctx_patch_imm_bits_at(uint8_t *ctx_bytes, int32_t patch_idx) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes || patch_idx < 0 || patch_idx >= 2048)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (patch_idx >= ctx->num_patches)
    return 0;
  return ctx->patches[patch_idx].patch_imm_bits;
}

/** platform_elf_ElfCodegenCtx 后缀字段偏移（须与 pipeline_gen.c struct 一致；前缀与 PipelineElfCtxAccess 同布局）。 */
enum {
  kPipelineElfCtxEMachineOff = 598040,
  kPipelineElfCtxCodeDataOff = 598056
};

/** 读 ctx.code_data 小端 u32；ctx 为完整 ElfCodegenCtx 字节视图。 */
static int32_t pipeline_elf_ctx_read_u32_le(uint8_t *ctx_bytes, int32_t off) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  if (!ctx_bytes || off < 0)
    return 0;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (off + 3 >= acc->code_len)
    return 0;
  code = ctx_bytes + kPipelineElfCtxCodeDataOff;
  return (int32_t)((unsigned)code[off] | ((unsigned)code[off + 1] << 8) | ((unsigned)code[off + 2] << 16) |
                   ((unsigned)code[off + 3] << 24));
}

/** 写 ctx.code_data 小端 u32。 */
static void pipeline_elf_ctx_write_u32_le(uint8_t *ctx_bytes, int32_t off, int32_t word) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  if (!ctx_bytes || off < 0)
    return;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (off + 3 >= acc->code_len)
    return;
  code = ctx_bytes + kPipelineElfCtxCodeDataOff;
  code[off] = (uint8_t)(word & 255);
  code[off + 1] = (uint8_t)((word >> 8) & 255);
  code[off + 2] = (uint8_t)((word >> 16) & 255);
  code[off + 3] = (uint8_t)((word >> 24) & 255);
}

/** 从占位指令推断 arm64/riscv patch 位宽；与 platform/elf.su elf_infer_patch_imm_bits_from_code 一致。 */
static int32_t pipeline_elf_ctx_infer_patch_imm_bits(uint8_t *ctx_bytes, int32_t rel32_offset) {
  PipelineElfCtxAccess *acc;
  uint8_t *code;
  int32_t op8;
  if (!ctx_bytes || rel32_offset < 0)
    return 0;
  acc = (PipelineElfCtxAccess *)ctx_bytes;
  if (rel32_offset + 3 >= acc->code_len)
    return 0;
  code = ctx_bytes + kPipelineElfCtxCodeDataOff;
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
    patch = &ctx->patches[p];
    rel32_offset = patch->rel32_offset;
    target_offset = -1;
    l = 0;
    while (l < ctx->num_labels) {
      if (pipeline_elf_ctx_name_eq(patch->name, patch->name_len, ctx->labels[l].name, ctx->labels[l].name_len) != 0) {
        target_offset = ctx->labels[l].offset;
        break;
      }
      l = l + 1;
    }
    if (target_offset < 0) {
      driver_diagnostic_asm_elf_unresolved_patch(patch->name, patch->name_len);
      pipeline_elf_log_unresolved_patch((struct platform_elf_ElfCodegenCtx *)ctx_bytes, p);
      return -1;
    }
    imm_bits = patch->patch_imm_bits;
    if (imm_bits == 0)
      imm_bits = pipeline_elf_ctx_infer_patch_imm_bits(ctx_bytes, rel32_offset);
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
      insn = pipeline_elf_ctx_read_u32_le(ctx_bytes, rel32_offset);
      imm = delta / 4;
      if (imm_bits == 26)
        insn = (insn & (int32_t)4293918720) | (imm & 67108863);
      else if (imm_bits == 19)
        insn = (insn & (int32_t)4278190175) | ((imm & 524287) << 5);
      pipeline_elf_ctx_write_u32_le(ctx_bytes, rel32_offset, insn);
    } else if (e_machine == 243 || imm_bits == 13 || imm_bits == 21) {
      int32_t insn;
      int32_t val;
      int32_t b_imm;
      int32_t j_imm;
      insn = pipeline_elf_ctx_read_u32_le(ctx_bytes, rel32_offset);
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
      pipeline_elf_ctx_write_u32_le(ctx_bytes, rel32_offset, insn);
    } else {
      pipeline_elf_ctx_write_u32_le(ctx_bytes, rel32_offset, delta);
    }
    p = p + 1;
  }
  return 0;
}

/** 追加一条外部重定位；ctx 为 *ElfCodegenCtx 转 *u8。 */
int32_t pipeline_elf_ctx_append_reloc(uint8_t *ctx_bytes, int32_t offset, uint8_t *name, int32_t name_len) {
  PipelineElfCtxAccess *ctx;
  int32_t ri;
  int32_t n;
  if (!ctx_bytes || !name || name_len <= 0 || name[0] == 0)
    return -1;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  if (ctx->num_relocs >= 2048) {
    fprintf(stderr, "shu: elf num_relocs limit 2048 reached\n");
    return -1;
  }
  ri = ctx->num_relocs;
  ctx->relocs[ri].offset = offset;
  memset(ctx->reloc_sym_names[ri], 0, 64);
  n = name_len > 64 ? 64 : name_len;
  memcpy(ctx->reloc_sym_names[ri], name, (size_t)n);
  ctx->relocs[ri].name_len = name_len;
  ctx->num_relocs = ctx->num_relocs + 1;
  return 0;
}

/** 返回 reloc_sym_names[idx] 首地址；越界返回 NULL。 */
uint8_t *pipeline_elf_ctx_reloc_sym_name_ptr(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes || idx < 0 || idx >= 2048)
    return NULL;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  return ctx->reloc_sym_names[idx];
}

/** 将 reloc_sym_names[idx] 拷入 dst（最多 63 字节 + NUL）。 */
void pipeline_elf_ctx_reloc_sym_name_copy64(uint8_t *ctx_bytes, int32_t idx, uint8_t *dst) {
  PipelineElfCtxAccess *ctx;
  int32_t k;
  if (!dst)
    return;
  memset(dst, 0, 64);
  if (!ctx_bytes || idx < 0 || idx >= 2048)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  for (k = 0; k < 64; k++)
    dst[k] = ctx->reloc_sym_names[idx][k];
}

/** 读 relocs[idx].name_len。 */
int32_t pipeline_elf_ctx_reloc_name_len(uint8_t *ctx_bytes, int32_t idx) {
  PipelineElfCtxAccess *ctx;
  if (!ctx_bytes || idx < 0 || idx >= 2048)
    return 0;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  return ctx->relocs[idx].name_len;
}

/** asm .o 失败诊断：打印 ElfCodegenCtx 前几项计数（与 PipelineElfCtxAccess 布局一致）。 */
void pipeline_elf_ctx_diag_stderr(uint8_t *ctx_bytes) {
  PipelineElfCtxAccess *ctx;
  int32_t l;
  if (!ctx_bytes)
    return;
  ctx = (PipelineElfCtxAccess *)ctx_bytes;
  fprintf(stderr,
          "shu: elf ctx code_len=%d num_labels=%d num_patches=%d num_relocs=%d\n",
          (int)ctx->code_len, (int)ctx->num_labels, (int)ctx->num_patches, (int)ctx->num_relocs);
  if (ctx->num_patches > 0) {
    PipelineElfPatchEntry *p = &ctx->patches[0];
    fprintf(stderr, "shu: elf first patch name_len=%d name='", (int)p->name_len);
    for (int32_t i = 0; i < p->name_len && i < 64; i++)
      fputc((char)p->name[i], stderr);
    fprintf(stderr, "'\n");
    l = 0;
    while (l < ctx->num_labels) {
      int32_t same = (ctx->labels[l].name_len == p->name_len);
      if (same && p->name_len > 0)
        same = (memcmp(ctx->labels[l].name, p->name, (size_t)p->name_len) == 0);
      if (same) {
        fprintf(stderr, "shu: elf label match at idx=%d offset=%d\n", (int)l,
                (int)ctx->labels[l].offset);
        return;
      }
      l = l + 1;
    }
    fprintf(stderr, "shu: elf no label match for first patch\n");
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
  fprintf(stderr, "shu: elf unresolved patch_idx=%d label_hits=%d num_labels=%d\n", (int)patch_idx,
          (int)hits, (int)acc->num_labels);
}

/** codegen.su：路径/前缀 scratch（避免 `[64]u8 = []` 在 asm emit 时 ExprKind=-1）。 */
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

/** codegen.su：TypeKind 内建类型 → C 类型名；返回长度，*out_ptr 指向静态串；不支持则 0。 */
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

/** codegen.su：将 TypeKind C 名写入 dst，返回字节数；-1 缓冲不足或不支持。 */
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

/** codegen.su：VECTOR 类型 C 名（elem_kind=TYPE_I32/U32，lanes=4/8/16）；无匹配 0。 */
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

/** codegen.su：VECTOR 类型 C 名写入 dst；无匹配 -1。 */
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

/** codegen.su：将 TypeKind C 名追加到 scratch[w..)，返回下一写位置；-1 溢出或不支持。 */
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

/**
 * codegen.su codegen_call_num_args_override：符号全名表（asm 不支持函数内 [N]u8 字面量）。
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

/** codegen.su / asm backend：拼接 prefix+name 后查表，避免 .su 内 [N]u8 字面量与 *u8 下标在 asm emit 失败。 */
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

/** codegen.su：std.io.driver 桥接名前缀表（asm 不支持函数内数组字面量）。 */
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

/** import 路径逐字节含末尾 NUL 比较（codegen.su asm 无数组字面量）。 */
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

/** codegen.su：import 路径是否为 std.io.driver（含 NUL，14 字节）。 */
int32_t pipeline_codegen_path_is_std_io_driver_bytes(uint8_t *path) {
  return codegen_path_bytes_eq(path, "std.io.driver\0", 14);
}

/** codegen.su：import 路径是否为 std.io.core（含 NUL，12 字节）。 */
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

/** codegen.su：std.io.core 与 io.o 重复的 shu_io_* 函数须跳过 emit。 */
int32_t pipeline_codegen_should_skip_emit_std_io_core_io_dup(uint8_t *dep_path, uint8_t *name, int32_t name_len) {
  if (!dep_path || !name)
    return 0;
  if (memcmp(dep_path, "std.io.core", 11) != 0)
    return 0;
  if ((name_len == 17 || name_len == 18) && codegen_name_prefix_eq(name, name_len, "shu_io_read_fixed", 17))
    return 1;
  if ((name_len == 18 || name_len == 19) && codegen_name_prefix_eq(name, name_len, "shu_io_write_fixed", 18))
    return 1;
  if ((name_len == 24 || name_len == 25) && codegen_name_prefix_eq(name, name_len, "shu_io_submit_read_batch", 24))
    return 1;
  if ((name_len == 25 || name_len == 26) && codegen_name_prefix_eq(name, name_len, "shu_io_submit_write_batch", 25))
    return 1;
  if ((name_len == 18 || name_len == 19) && codegen_name_prefix_eq(name, name_len, "shu_io_submit_read", 18))
    return 1;
  if ((name_len == 19 || name_len == 20) && codegen_name_prefix_eq(name, name_len, "shu_io_submit_write", 19))
    return 1;
  return 0;
}

/** codegen.su：std.io handle_* 字面量函数须跳过 emit；dep_path 为空时仅按 name 判断。 */
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

/** codegen.su：合并 driver_should_skip_emit 三套逻辑（原 codegen_should_skip_emit_func）。 */
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

/** codegen.su：entry 模块是否含 read_message（LSP io 入口探测）。 */
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

/** codegen.su：entry 模块是否含 lsp_main。 */
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

/** codegen.su：C 前缀是否为 std_io_driver 族（13 字节 + 可选第 14 字节 NUL/_）。 */
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

/** codegen.su：std_io_driver submit_*_batch_buf 首参强制 size_t。 */
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

/** codegen.su：std.io print_str 第二参强制 size_t（前缀须 std_io_）。 */
int32_t pipeline_codegen_force_param_size_t_std_io_print_str_second(uint8_t *prefix, int32_t prefix_len,
                                                                    uint8_t *name, int32_t name_len,
                                                                    int32_t param_index) {
  if (param_index != 1 || !name || name_len != 9)
    return 0;
  if (memcmp(name, "print_str", 9) != 0)
    return 0;
  if (!prefix || prefix_len < 7)
    return 0;
  return memcmp(prefix, "std_io_", 7) == 0 ? 1 : 0;
}

/** codegen.su：std_io_driver register/submit_read/submit_write 首参 ptrdiff_t。 */
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

/** codegen.su：std_io_driver 按名/下标强制 uint32_t（timeout_ms/nr）。 */
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

/** codegen.su：std.io.core shu_io_* 调用名追加 _buf。 */
int32_t pipeline_codegen_use_buf_wrapper(uint8_t *name, int32_t name_len, int32_t num_args) {
  if (!name || name_len <= 0)
    return 0;
  if (num_args == 1 && name_len == 15 && codegen_name_prefix_eq(name, name_len, "shu_io_register", 15))
    return 1;
  if (num_args == 2 && name_len == 18 && codegen_name_prefix_eq(name, name_len, "shu_io_submit_read", 18))
    return 1;
  if (num_args == 2 && name_len == 19 && codegen_name_prefix_eq(name, name_len, "shu_io_submit_write", 19))
    return 1;
  return 0;
}

/** codegen.su：driver extern io_* batch 由 preamble/io.o 提供，跳过 std_io_driver_io_* extern 声明。 */
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

/** codegen.su：占位/string 桩函数名跳过 emit（placeholder、string_new 等）。 */
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
  return 0;
}

/** codegen.su：submit_*_batch_buf 调用需补第 4 参 timeout_ms。 */
int32_t pipeline_codegen_is_submit_batch_buf_call(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len == 21 && codegen_name_prefix_eq(name, name_len, "submit_read_batch_buf", 21))
    return 1;
  if (name_len == 22 && codegen_name_prefix_eq(name, name_len, "submit_write_batch_buf", 22))
    return 1;
  return 0;
}

/** codegen.su：std.io.core 中 preamble/io.o 已提供的 shu_io_* 桥接名，跳过函数体 emit。 */
int32_t pipeline_codegen_should_skip_emit_func_core_read_ptr(uint8_t *name, int32_t name_len) {
  if (!name)
    return 0;
  if (name_len >= 19 && codegen_name_prefix_eq(name, name_len, "shu_io_read_ptr_len", 19))
    return 1;
  if (name_len == 15 && codegen_name_prefix_eq(name, name_len, "shu_io_read_ptr", 15))
    return 1;
  if (name_len == 15 && codegen_name_prefix_eq(name, name_len, "shu_io_register", 15))
    return 1;
  if (name_len == 23 && codegen_name_prefix_eq(name, name_len, "shu_io_register_buffers", 23))
    return 1;
  if (name_len == 25 && codegen_name_prefix_eq(name, name_len, "shu_io_unregister_buffers", 25))
    return 1;
  if (name_len == 20 && codegen_name_prefix_eq(name, name_len, "shu_io_wait_readable", 20))
    return 1;
  return 0;
}

/**
 * asm 路径：std.io.core 薄包装未编入 .o（由 io.o 提供）时，将 call 重定向到 extern io_* 符号。
 * name 可为裸 shu_io_* 或 std_io_core_shu_io_*；命中写 sym_out，返回长度；无匹配 0；缓冲不足 -1。
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
  if (blen == 23 && codegen_name_prefix_eq(bare, blen, "shu_io_register_buffers", 23)) {
    sym = "io_register_buffers_4";
    slen = 23;
  } else if (blen == 25 && codegen_name_prefix_eq(bare, blen, "shu_io_unregister_buffers", 25)) {
    sym = "io_unregister_buffers";
    slen = 21;
  } else if (blen == 15 && codegen_name_prefix_eq(bare, blen, "shu_io_register", 15)) {
    sym = "io_register_buffer";
    slen = 19;
  } else if (blen == 19 && codegen_name_prefix_eq(bare, blen, "shu_io_read_ptr_len", 19)) {
    sym = "io_read_ptr_len";
    slen = 15;
  } else if (blen == 15 && codegen_name_prefix_eq(bare, blen, "shu_io_read_ptr", 15)) {
    sym = "io_read_ptr";
    slen = 11;
  } else if (blen == 20 && codegen_name_prefix_eq(bare, blen, "shu_io_wait_readable", 20)) {
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

/** codegen.su：std.io driver 短名 register/submit_* 映射到 shu_io_*_buf；命中写 sym_out，返回符号长度；无匹配 0；缓冲不足 -1。 */
int32_t pipeline_codegen_io_driver_buf_call_sym(uint8_t *name, int32_t name_len, int32_t num_args, uint8_t *sym_out,
                                                int32_t sym_cap) {
  const char *sym;
  int32_t sym_len;
  if (!name || name_len <= 0)
    return 0;
  sym = NULL;
  sym_len = 0;
  if (num_args == 1 && name_len == 8 && codegen_name_prefix_eq(name, name_len, "register", 8)) {
    sym = "shu_io_register_buf";
    sym_len = 19;
  } else if (num_args == 2 && name_len == 11 && codegen_name_prefix_eq(name, name_len, "submit_read", 11)) {
    sym = "shu_io_submit_read_buf";
    sym_len = 22;
  } else if (num_args == 2 && name_len == 12 && codegen_name_prefix_eq(name, name_len, "submit_write", 12)) {
    sym = "shu_io_submit_write_buf";
    sym_len = 23;
  }
  if (!sym)
    return 0;
  if (!sym_out || sym_cap < sym_len)
    return -1;
  memcpy(sym_out, sym, (size_t)sym_len);
  return sym_len;
}

/** codegen.su：std_io read_fixed_fd/write_fixed_fd 须追加 _impl 后缀。 */
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

/** backend.su：AsmFuncCtx 局部变量 grow 池（替代 locals[24]）。 */
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

/** 清空某 AsmFuncCtx 的局部槽 grow 池。 */
void asm_ctx_local_reset(uint8_t *ctx) {
  AsmLocalsSidecar *sc = asm_locals_sidecar_get(ctx, 0);
  if (sc)
    sc->slots.len = 0;
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

/** backend.su：块 ref → 该块 const/let 在 sidecar 中的起始槽下标（树遍历 fill 时写入）。 */
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

/**
 * 懒登记 block 内 const/let 到 asm 局部 sidecar（C 实现，避免 .su 生成代码在 if+while 双路径组合时崩溃）。
 * inout_next_offset / inout_num_locals 对应 AsmFuncCtx.next_offset / num_locals。
 */
void asm_ctx_ensure_block_locals(uint8_t *ctx, struct ast_ASTArena *arena, int32_t block_ref,
                                 int32_t *inout_next_offset, int32_t *inout_num_locals) {
  struct ast_Block *b;
  int32_t i, off, base, nlen;
  uint8_t name_buf[64];
  if (!ctx || !arena || !inout_next_offset || !inout_num_locals || block_ref <= 0)
    return;
  if (asm_ctx_block_slot_get(ctx, block_ref) >= 0)
    return;
  b = block_at(arena, block_ref);
  if (!b)
    return;
  base = asm_ctx_local_count(ctx);
  asm_ctx_block_slot_set(ctx, block_ref, base);
  off = *inout_next_offset;
  for (i = 0; i < b->num_consts; i++) {
    nlen = pipeline_block_const_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    pipeline_block_const_name_copy64(arena, block_ref, i, name_buf);
    if (asm_ctx_local_append(ctx, name_buf, nlen, off) < 0)
      return;
    off += asm_local_slot_bytes(arena, pipeline_block_const_type_ref(arena, block_ref, i));
  }
  for (i = 0; i < b->num_lets; i++) {
    nlen = pipeline_block_let_name_len(arena, block_ref, i);
    if (nlen <= 0)
      continue;
    pipeline_block_let_name_copy64(arena, block_ref, i, name_buf);
    if (asm_ctx_local_append(ctx, name_buf, nlen, off) < 0)
      return;
    off += asm_local_slot_bytes(arena, pipeline_block_let_type_ref(arena, block_ref, i));
  }
  *inout_next_offset = off;
  *inout_num_locals = asm_ctx_local_count(ctx);
}

/**
 * 单个 const/let 在栈上的占用字节（标量 8；TYPE_VECTOR 为 lanes×元素宽，与 codegen 向量布局一致）。
 */
int32_t asm_local_slot_bytes(struct ast_ASTArena *arena, int32_t type_ref) {
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
  /* AST_TYPE_VECTOR == 12 */
  if ((int32_t)t->kind != 12)
    return 8;
  lanes = t->array_size > 0 ? t->array_size : 4;
  esz = 4;
  elem_ref = t->elem_type_ref;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if ((int32_t)et->kind == 2)
        esz = 1;
      else if ((int32_t)et->kind == 8 || (int32_t)et->kind == 4 || (int32_t)et->kind == 5 ||
               (int32_t)et->kind == 6 || (int32_t)et->kind == 14)
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

/** 块树遍历栈：压入待访问 block_ref（GrowVec，避免 .su 大栈数组在大模块 asm 单编时 SIGSEGV）。 */
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
    }
  }
  grow_vec_free(&stack);
  return total;
}

/**
 * 统计函数体块树中全部 const/let 槽位数（含 if-then/else、while/for 嵌套体）。
 * 供 backend.su compute_frame_size 使用；C 显式栈避免 .su DFS 栈溢出。
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
  /* TYPE_ARRAY 序数为 10（与 ast.h AST_TYPE_ARRAY / ast.su TypeKind 一致）；误用 9 会当成 TYPE_PTR 导致 frame 未预留 temp。 */
  if (!t || (int32_t)t->kind != 10 || t->array_size <= 0)
    return 0;
  elem_ref = t->elem_type_ref;
  esz = 4;
  if (elem_ref > 0 && elem_ref <= arena->num_types) {
    struct ast_Type *et = pipeline_arena_type_ptr(arena, elem_ref);
    if (et) {
      if ((int32_t)et->kind == 2)
        esz = 1;
      else if ((int32_t)et->kind == 8 || (int32_t)et->kind == 4 || (int32_t)et->kind == 5 ||
               (int32_t)et->kind == 6 || (int32_t)et->kind == 14)
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

/** 调试：asm 单编大模块时在 stderr 打印当前函数名（SHU_ASM_FUNC_TRACE=1）。 */
void asm_diag_trace_func_idx(int32_t func_idx, uint8_t *name, int32_t name_len);

void asm_diag_trace_func(uint8_t *name, int32_t name_len) {
  asm_diag_trace_func_idx(-1, name, name_len);
}

/** 块树 const+let 槽超过此阈值时 asm 完整 emit 易在宿主栈溢出（lexer 前几项函数亦可能 <160 funcs）。 */
#define ASM_HEAVY_BODY_SLOT_THRESHOLD 48
/** EMIT_HEAVY 第二遍放宽槽位（layout helper）；仍低于 mega typecheck 体。 */
#define ASM_EMIT_HEAVY_SLOT_THRESHOLD 256
/** backend.su 自举（含 import 展开 ~219 func）：#87–218 索引桩；#0–86 小 helper 真 emit。 */
#define ASM_EMIT_HEAVY_BACKEND_INDEX_LO 87
#define ASM_EMIT_HEAVY_BACKEND_INDEX_HI 218
/** typeck.su ~173 func：#90–159 深 emit Abort；#0–89 layout/helper 与 #160+ 可真 emit 扩 __text。 */
#define ASM_EMIT_HEAVY_TYPECK_INDEX_LO 90
#define ASM_EMIT_HEAVY_TYPECK_INDEX_HI 159
/** pipeline.su ~56 func：编排入口 #53–#55 须真 emit；索引桩已移除，靠 pipeline_expr_* 消除 Expr 栈拷贝。 */
/** SHU_ASM_EMIT_ABORT_LO/HI 默认（backend 二分调试）。 */
#define ASM_EMIT_HEAVY_LARGE_ENTRY_LO ASM_EMIT_HEAVY_BACKEND_INDEX_LO
#define ASM_EMIT_HEAVY_LARGE_ENTRY_HI ASM_EMIT_HEAVY_BACKEND_INDEX_HI

/** 大入口 backend（num_funcs>=175）EMIT_HEAVY 槽位阈值（较默认 256 收紧，避免 codegen 宿主栈 Abort）。 */
#define ASM_EMIT_HEAVY_LARGE_BACKEND_SLOT_THRESHOLD 96
/** backend helper 白名单真 emit 时块树槽位上限（过大仍走索引桩）。 */
#define ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX 48
/** typeck layout helper 允许略大栈帧（仍远小于 check_block mega）。 */
#define ASM_EMIT_HEAVY_TYPECK_LAYOUT_SLOT_MAX 96

/** 读 SHU_ASM_EMIT_ABORT_LO/HI：调试二分定位 Abort 区间（默认见上常量）。 */
static int32_t asm_emit_heavy_abort_lo(void) {
  const char *e = getenv("SHU_ASM_EMIT_ABORT_LO");
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
  const char *e = getenv("SHU_ASM_EMIT_ABORT_HI");
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
 * 与 typeck.su::typeck_skip_heavy_selfhost_func_body 对齐，并据块树槽位数自动跳过超大函数体。
 * 库模块 -backend asm -o 时改发最小 ret 0 桩，保证 __text 非空且编译不 SIGSEGV。
 */
/**
 * 模块顶层 let/const 若为整型字面量初始化，返回 1 并写入 *out_imm（供 asm EXPR_VAR 直接 mov imm）。
 */
#ifndef SHU_PIPELINE_GLUE_STANDALONE_TU
/** runtime.c：dep 模块 asm codegen 时设置的当前 import 逻辑路径（常规 pipeline_su 链）。 */
extern const char *driver_get_current_dep_path_for_codegen(void);
#endif

/**
 * 供 backend.su 读取 dep 路径（避免经 codegen 模块名修饰导致链接符号不一致）。
 * B-strict standalone TU 下 driver_get 由 pipeline_glue_types.inc 声明为 uint8_t *。
 */
uint8_t *asm_driver_current_dep_path_for_codegen(void) {
#ifndef SHU_PIPELINE_GLUE_STANDALONE_TU
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

/** SHU_ASM_BUILD_SKIP_TYPECK=1 时 build_shu_asm 走桩路径，避免无 typeck 的大模块 asm emit 栈溢出。 */
static int32_t asm_env_build_skip_typeck(void) {
  const char *e = getenv("SHU_ASM_BUILD_SKIP_TYPECK");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** SHU_ASM_STRICT_ORCHESTRATION=1 时 C 编排链才跳过 pipeline 大函数 emit（默认 build_asm 须落真机器码）。 */
static int32_t asm_env_strict_orchestration(void) {
  const char *e = getenv("SHU_ASM_STRICT_ORCHESTRATION");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** 非 0 表示入口源码过大，merge/library typeck 等应跳过（runtime.c）。 */
extern int32_t driver_typeck_skip_large_entry(void);

/**
 * SKIP_TYPECK 全桩模式下仍须保留真实机器码的入口（实验 asm-only 链与 shu_asm 烟囱测试依赖）。
 * 返回 1 表示该函数不应被 asm_skip_heavy 桩掉。
 * 大模块（如 backend.su）自身也定义 asm_codegen_ast，若对其完整 emit 会在宿主栈上 abort。
 */
static int32_t asm_skip_typeck_entry_whitelist(struct ast_Module *m, int32_t func_index) {
  static const struct {
    const char *name;
    int32_t len;
    int32_t allow_on_large_entry;
  } k_keep[] = {
      /** parse_into_with_init_buf 真 emit 深栈 SIGSEGV；build 链由 parser.o / C alias 提供。 */
      {"pipeline_impl_run_all", 21, 1},
      {"run_su_pipeline_impl", 20, 1},
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
      /** parser.su：strict 链 pipeline.parse_into_with_init_buf 依赖 parser.parse_into_buf 真机器码。 */
      {"parse_into_init", 15, 1},
      {"parse_into_set_main_index", 25, 1},
      {"collect_imports_buf", 19, 1},
      {"parse_into_buf", 14, 1},
      /** 大入口（>150KiB）上 typeck/asm 入口完整 emit 会栈溢出；SKIP 桩即可，编库不跑这些符号。 */
      {"typeck_su_ast", 13, 0},
      {"typeck_su_ast_library", 21, 0},
      {"asm_codegen_ast", 15, 0},
  };
  int32_t k;
  int32_t large_entry;
  if (!m || func_index < 0)
    return 0;
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
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"run_su_pipeline_impl", 20))
    return 1;
  return 0;
}

/** 当前 asm codegen 的 PipelineDepCtx；backend.su 在 emit 循环前设置，供 ENTRY_MODULE_ONLY 入口 -o 判定。 */
static struct ast_PipelineDepCtx *g_asm_skip_pipeline_ctx;

void asm_skip_heavy_set_pipeline_ctx(struct ast_PipelineDepCtx *ctx) {
  g_asm_skip_pipeline_ctx = ctx;
}

/** SHU_ASM_ENTRY_EMIT_HEAVY=1 时 ENTRY_MODULE_ONLY 真 emit（typeck 第二遍）；仅跳过 pipeline typecheck。 */
static int32_t asm_env_entry_emit_heavy(void) {
  const char *e = getenv("SHU_ASM_ENTRY_EMIT_HEAVY");
  return (e != NULL && e[0] != '\0' && e[0] != '0') ? 1 : 0;
}

/** 模块是否 backend.su 自举单元（asm_codegen_ast 符号探针）。 */
static int32_t asm_module_is_backend_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 150)
    return 0;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"asm_codegen_ast", 15))
      return 1;
  }
  return 0;
}

/** 模块是否 typeck.su 自举单元（含 typeck_su_ast 或合并 glue 后约 168–180 func）。 */
static int32_t asm_module_is_typeck_selfhost(struct ast_Module *m) {
  int32_t i;
  if (!m || m->num_funcs < 40)
    return 0;
  if (pipeline_module_func_name_equal_at(m, 0, (uint8_t *)"type_kind_ordinal", 17))
    return 1;
  for (i = 0; i < m->num_funcs; i++) {
    if (pipeline_module_func_name_equal_at(m, i, (uint8_t *)"typeck_su_ast", 13))
      return 1;
  }
  /** ENTRY_MODULE_ONLY 编 typeck.su 时 module 前置 pipeline glue func；按名或 func 规模识别。 */
  if (m->num_funcs >= 80 && m->num_funcs <= 120)
    return 1;
  if (m->num_funcs >= 168 && m->num_funcs <= 180)
    return 1;
  return 0;
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
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"name_equal", 10))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_type_align", 20) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_type_size", 19))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_path_slice_equal", 30) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_binding_name_equal", 32) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_import_select_name_equal", 31) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_top_level_let_name_equal", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_named_builtin_align", 29) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_named_builtin_size", 28))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_find_layout_idx_by_type_name", 35))
    return 1;
  if (func_index >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO)
    return 0;
  return 0;
}

/**
 * backend EMIT_HEAVY 第二遍：按符号名保留小 helper 真 emit（覆盖 #87+ 索引桩；219 func 模块中 arch_emit/enc 常在 #87 之后）。
 */
static int32_t asm_skip_heavy_backend_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_backend_selfhost(m))
    return 0;
  /** 仅保留薄包装 dispatch（arch→enc 一行转发）；大块 enc_/emit 仍走 mega/索引桩。 */
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
 * typeck EMIT_HEAVY 第二遍：layout/diag 小 helper 真 emit（ExprKind=51 已修；槽位过大仍走 mega/默认桩）。
 */
static int32_t asm_skip_heavy_typeck_helper_keep(struct ast_Module *m, int32_t func_index) {
  if (!m || func_index < 0 || !asm_module_is_typeck_selfhost(m))
    return 0;
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_type_align", 20) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_type_size", 19))
    return 1;
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
  ASMB_MEGA("asm_codegen_ast_to_elf", 21);
  ASMB_MEGA("emit_expr", 9);
  ASMB_MEGA("emit_expr_elf", 13);
  ASMB_MEGA("emit_expr_elf_slow", 17);
  ASMB_MEGA("emit_expr_call", 14);
  ASMB_MEGA("emit_expr_elf_call", 18);
  ASMB_MEGA("emit_expr_method_call", 21);
  ASMB_MEGA("emit_expr_elf_method_call", 25);
  ASMB_MEGA("emit_block_body", 14);
  ASMB_MEGA("emit_block_body_elf", 18);
  ASMB_MEGA("emit_block_body_driver", 21);
  ASMB_MEGA("emit_block_body_driver_elf", 25);
  ASMB_MEGA("emit_loop_body_content", 22);
  ASMB_MEGA("emit_loop_body_content_elf", 26);
  ASMB_MEGA("emit_while_loop", 14);
  ASMB_MEGA("emit_while_loop_elf", 18);
  ASMB_MEGA("emit_for_loop", 12);
  ASMB_MEGA("emit_for_loop_elf", 16);
  ASMB_MEGA("emit_if_then_block_body_text", 27);
  ASMB_MEGA("emit_if_then_block_body_elf", 27);
  ASMB_MEGA("emit_block_inits", 15);
  ASMB_MEGA("emit_block_inits_elf", 19);
  ASMB_MEGA("emit_field_access_base_addr", 27);
  ASMB_MEGA("emit_field_access_base_addr_elf", 31);
  ASMB_MEGA("emit_index_eff_addr_text", 22);
  ASMB_MEGA("emit_index_eff_addr_elf", 22);
  ASMB_MEGA("emit_lvalue_eff_addr_text", 23);
  ASMB_MEGA("emit_lvalue_eff_addr_elf", 23);
  ASMB_MEGA("emit_binop_add_text", 19);
  ASMB_MEGA("emit_binop_sub_text", 19);
  ASMB_MEGA("emit_binop_mul_text", 19);
  ASMB_MEGA("emit_binop_div_text", 19);
  ASMB_MEGA("emit_binop_mod_text", 19);
  ASMB_MEGA("emit_binop_add_elf", 18);
  ASMB_MEGA("emit_binop_sub_elf", 18);
  ASMB_MEGA("emit_binop_mul_elf", 18);
  ASMB_MEGA("emit_binop_div_elf", 18);
  ASMB_MEGA("emit_binop_mod_elf", 18);
  ASMB_MEGA("asm_emit_call_args_text", 23);
  ASMB_MEGA("asm_emit_call_args_elf", 22);
  ASMB_MEGA("asm_resolve_dep_var_call_symbol", 31);
  ASMB_MEGA("asm_resolve_whole_import_qualified_symbol", 41);
  ASMB_MEGA("get_dep_return_type_in_caller_arena", 35);
  ASMB_MEGA("ctx_reset", 9);
  ASMB_MEGA("block_slot_base_for", 19);
  ASMB_MEGA("compute_frame_size", 18);
  ASMB_MEGA("fill_param_slots", 16);
  ASMB_MEGA("fill_local_slots", 16);
  ASMB_MEGA("ensure_block_local_slots", 24);
  ASMB_MEGA("local_offset", 12);
  ASMB_MEGA("emit_next_label", 15);
  /** extern/C sidecar glue：.su 体含 ExprKind 54 等 asm 未支持形态，须桩化。 */
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
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_as_loop_body", 24) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_tail_expr_ref_for_implicit_rule", 41) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"func_body_has_implicit_return_tail", 34) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_ret_coerce_integral_to_expect_i32", 40) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_coerce_init_expr_to_decl", 31))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_whole_import_qualified_call_return_type", 47) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"resolve_call_callee_return_type", 31) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_type_ref_impl", 18) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_type_ref", 13) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool_impl", 21) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_ref_is_bool", 16) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal_impl", 20) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_refs_equal", 15))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_append_lit", 22) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_append_u32_dec", 26) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_at", 23) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_into", 25) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_diag_fmt_type_or_question", 32))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_ast", 13) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_ast_impl", 18) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_ast_library", 21) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_skip_heavy_selfhost_func_body", 36))
    return 1;
  /** layout 小 helper 改由 typeck_helper_keep 真 emit；仅 struct_layout 大入口仍 mega 桩。 */
  if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_struct_layout", 20))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"ensure_struct_layout_from_struct_lit", 36))
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"expr_var_name_equal_func", 24) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_field_access_lexer_wrapper_fallback", 42) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module_by_name", 39) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"find_func_return_type_in_module", 31))
    return 1;
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
  static const uint8_t prefix[] = "_shu_asm_stu_";
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

int32_t asm_skip_heavy_module_func_body(struct ast_Module *m, struct ast_ASTArena *arena, int32_t func_index) {
  int32_t body_ref;
  int32_t slots;
  int32_t slot_threshold;
  if (!m || func_index < 0)
    return 0;
  /**
   * 用户 import+exe（asm_entry_module_only、非大入口）：须完整 emit 入口模块，禁止 ret0 桩。
   * build_shu_asm（SHU_ASM_BUILD_SKIP_TYPECK）同为 ENTRY_MODULE_ONLY，须走下方白名单/桩路径，勿全量 emit。
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
   * build_shu_asm：SHU_ASM_BUILD_SKIP_TYPECK 默认桩 emit（非 extern/非白名单 ret 0）。
   * SHU_ASM_ENTRY_EMIT_HEAVY=1 时仅跳过 pipeline typecheck，emit 仍走槽位阈值真机码。
   */
  if (asm_env_build_skip_typeck() != 0 && asm_env_entry_emit_heavy() == 0) {
    if (pipeline_asm_module_func_is_extern_at(m, func_index) != 0)
      return 0;
    if (asm_skip_typeck_entry_whitelist(m, func_index) != 0)
      return 0;
    return 1;
  }
  /* 小模块（lexer 等 ~21 func）：前段函数体仍极大，完整 emit 会 139；仅 build_shu_asm 路径启用。 */
  if (asm_env_build_skip_typeck() != 0 && m->num_funcs > 0 && m->num_funcs <= 32 && func_index < 10)
    return 1;
  if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr", 10) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_expr_impl", 15) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block", 11) ||
      pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"check_block_impl", 16))
    return 1;
  /**
   * ENTRY_EMIT_HEAVY 第二遍：放宽槽位阈值；桩化 mega typecheck/diag 入口（按符号名）。
   * typeck 大入口：#90–117 Abort 区间（索引+按名桩）；#118+ 真 emit。
   * backend 大入口：#87–189 索引桩 + emit_expr/asm_codegen_ast 等按名 mega 桩；其余 helper 真 emit。
   * 非 typeck/backend 大模块且 func≥160：func#72+ 仍粗筛桩化。
   */
  if (asm_env_entry_emit_heavy() != 0) {
    /**
     * typeck.su 合并 glue 后 ~173 func：#0–89 glue 桩；#90–117 layout/小 helper 真 emit；#118–159 check_* 桩。
     */
    if (m->num_funcs >= 168 && m->num_funcs <= 180 && !asm_module_is_backend_selfhost(m)) {
      if (func_index < 90)
        return 1;
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      if (func_index >= 118 && func_index <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
        return 1;
      /** 按名放行 layout/小 helper（勿整段 #90–117 真 emit，易宿主栈 Abort）。 */
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"type_kind_ordinal", 17))
        return 0;
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    /** 瘦 typeck 单元（~83 func）：#1–#35 小 helper 真 emit。 */
    if (m->num_funcs >= 80 && m->num_funcs <= 90 && !asm_module_is_backend_selfhost(m)) {
      if (asm_skip_heavy_typeck_mega_entry(m, func_index) != 0)
        return 1;
      if (func_index > 35)
        return 1;
      return 0;
    }
    /** 白名单须先于 mega/索引桩：layout/arch helper 按名保留真 emit（小槽位体）。 */
    if (asm_module_is_backend_selfhost(m) && asm_skip_heavy_backend_helper_keep(m, func_index) != 0) {
      body_ref = pipeline_module_func_body_ref_at(m, func_index);
      if (!arena || body_ref <= 0 ||
          asm_count_block_stack_slots(arena, body_ref) <= ASM_EMIT_HEAVY_BACKEND_HELPER_SLOT_MAX)
        return 0;
    }
    if (asm_module_is_typeck_selfhost(m) && asm_skip_heavy_typeck_helper_keep(m, func_index) != 0) {
      /** layout/metrics 小 helper 先于 Abort 索引带真 emit（合并 glue 后 #90 即为 type_kind_ordinal）。 */
      if (pipeline_module_func_name_has_prefix_at(m, func_index, "typeck_layout_", 14))
        return 0;
      if (pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_type_align", 20) ||
          pipeline_module_func_name_equal_at(m, func_index, (uint8_t *)"typeck_su_type_size", 19))
        return 0;
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
    /** typeck.su：#90–159 Abort 区间 ret0 桩（helper_keep 已提前放行 layout）。 */
    if (asm_module_is_typeck_selfhost(m) && m->num_funcs >= 90 &&
        func_index >= ASM_EMIT_HEAVY_TYPECK_INDEX_LO && func_index <= ASM_EMIT_HEAVY_TYPECK_INDEX_HI)
      return 1;
    /** backend.su ~100 func：勿要求 num_funcs>=175，否则 #87+ 全走真 emit → 宿主栈 Abort。 */
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
               !asm_module_is_typeck_selfhost(m)) {
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
    /** backend/typeck 第二遍：backend 默认 ret0 桩；typeck 仅 safe helper 真 emit。 */
    if (asm_module_is_backend_selfhost(m))
      return 1;
    if (asm_module_is_typeck_selfhost(m)) {
      if (asm_typeck_emit_heavy_safe_helper(m, func_index) != 0)
        return 0;
      return 1;
    }
    return 0;
  }
  /** 默认大模块：func_index>=72 粗筛（非 EMIT_HEAVY 第二遍）。 */
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
 * 读 SHU_ASM_START_FUNC：跳过 module 中前 N 个函数（调试大模块 asm 单编 139）。
 * build_shu_asm 须 env -u SHU_ASM_START_FUNC；若 N>=num_funcs 则整模块无机器码、仅 8B 空 __text 桩。
 * SHU_ASM_ALLOW_START_FUNC=1 时 build 路径也生效（手工二分 emit 用）。
 */
int32_t asm_diag_start_func_skip(void) {
  const char *e = getenv("SHU_ASM_START_FUNC");
  const char *allow = getenv("SHU_ASM_ALLOW_START_FUNC");
  char *end = NULL;
  long v;
  if (!e || e[0] == '\0')
    return 0;
  /* build_shu_asm 默认清除 START_FUNC；未显式 ALLOW 时 ENTRY skip 模式忽略，避免 pipeline 56 func 全跳过。 */
  if ((allow == NULL || allow[0] == '\0' || allow[0] == '0') && asm_env_build_skip_typeck() != 0 &&
      getenv("SHU_ASM_ENTRY_MODULE_ONLY") != NULL) {
    const char *em = getenv("SHU_ASM_ENTRY_MODULE_ONLY");
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

/** SHU_ASM_BODY_TRACE=1 时打印函数体块规模，定位错误 body_ref 导致 fill/emit 崩溃。 */
void asm_diag_trace_func_body(struct ast_ASTArena *arena, int32_t body_ref) {
  const char *trace;
  struct ast_Block *b;
  if (!arena || body_ref <= 0)
    return;
  trace = getenv("SHU_ASM_BODY_TRACE");
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

/** SHU_ASM_BODY_TRACE=1：仅打印 body_ref 数值（在 pipeline_asm_module_func_body_ref_at 前后对照）。 */
void asm_diag_trace_body_ref(int32_t body_ref) {
  const char *trace = getenv("SHU_ASM_BODY_TRACE");
  if (!trace || trace[0] == '\0' || trace[0] == '0')
    return;
  fprintf(stderr, "asm_body_ref=%d\n", (int)body_ref);
  fflush(stderr);
}

/** SHU_ASM_BODY_TRACE=1：emit 阶段标记（1=fill 后 2=prologue 后 3=emit_body 后）。 */
void asm_diag_trace_emit_phase(int32_t phase) {
  const char *trace = getenv("SHU_ASM_BODY_TRACE");
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
  trace = getenv("SHU_ASM_FUNC_TRACE");
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
    }
  }
  grow_vec_free(&stack);
}

/** backend.su：嵌套循环 break/continue 标签栈 sidecar（替代 AsmFuncCtx 内 512×2 字节数组，减栈帧）。 */
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
 * 弹出最内层续延；*out_block/*out_stmt_i 为恢复点；end 标签写入 out_end（cap 字节，*out_end_len 为原长）。
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
