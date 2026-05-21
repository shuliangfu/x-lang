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

/** 顶层 enum 名槽。 */
typedef struct {
  uint8_t name[64];
  int32_t name_len;
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

/** 按名查块内 const/let 类型 ref。 */
int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
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
  memset(me->name, 0, sizeof(me->name));
  memcpy(me->name, bytes, (size_t)len);
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
int32_t pipeline_onefunc_append_const_name(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val) {
  OneFuncSidecar *sc;
  uint8_t *row;
  int32_t *pl;
  int32_t *pv;
  if (!out || !(sc = onefunc_sidecar_get(out, 1)) || !name || name_len <= 0 || name_len > 64)
    return -1;
  if (grow_vec_push(&sc->const_names) < 0 || grow_vec_push(&sc->const_name_lens) < 0 ||
      grow_vec_push(&sc->const_init_vals) < 0)
    return -1;
  row = (uint8_t *)grow_vec_at(&sc->const_names, sc->const_names.len - 1);
  pl = (int32_t *)grow_vec_at(&sc->const_name_lens, sc->const_name_lens.len - 1);
  pv = (int32_t *)grow_vec_at(&sc->const_init_vals, sc->const_init_vals.len - 1);
  if (!row || !pl || !pv)
    return -1;
  memset(row, 0, 64);
  memcpy(row, name, (size_t)name_len);
  *pl = name_len;
  *pv = init_val;
  return sc->const_names.len - 1;
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

int32_t pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  struct ast_Expr *ex;
  int32_t *slot;
  if (!a || expr_ref <= 0)
    return -1;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return -1;
  if (ex->call_num_args == 0) {
    ArenaSidecar *sc = arena_sidecar_get(a, 1);
    if (!sc)
      return -1;
    ex->call_arg_base = sc->expr_call_arg_refs.len;
  }
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
