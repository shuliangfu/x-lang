/* ast_pool_typedefs.c — AST pool entry + sidecar typedef domain (from ast_pool.c)
 *
 * Pool macros (AST_POOL_GROW / INIT_CAP / NO_LIMIT) + GrowVec typedef (wave271:
 * function bodies pure-owned in runtime_pipeline_abi) + entry slots (ImportEntry /
 * MatchArm / FuncParam / StructLayoutField / TopLevelLet / TypeAlias / ModuleEnum /
 * RegionBlock / OneFunc* / DepCtx / DriverEmit) + Arena/Module/OneFunc/DepCtx/
 * DriverEmit sidecar structs that embed GrowVec.
 *
 * Same-TU #include early (macros + GrowVec typedef + extern prototypes) and
 * BEFORE ast_pool_sidecar_pool.c (pool globals need these types).
 * PLATFORM: SHARED — host-cc residual; foundation for endgame .x authority.
 */

#ifndef AST_POOL_GROW
#define AST_POOL_GROW 4096
#endif

/**
 * Growable vector of fixed-size elements (typedef only).
 * wave271: bodies live in runtime_pipeline_abi pure (#[no_mangle] grow_vec_*).
 * Layout LE sizeof 32 on LP64: data*@0 | cap i32@8 | len i32@12 | elem_sz@16 |
 * mmap_backed i32@24. PLATFORM: SHARED — must match pure LE offsets.
 */
typedef struct {
  uint8_t *data;
  int32_t cap;
  int32_t len;
  size_t elem_sz;
  /** 1 = data from mmap(MAP_ANON); free via munmap. 0 = malloc/calloc/realloc. */
  int32_t mmap_backed;
} GrowVec;

/** Byte size at which GrowVec switches to mmap (1 MiB). */
#ifndef GROW_VEC_MMAP_THRESH
#define GROW_VEC_MMAP_THRESH ((size_t)(1024 * 1024))
#endif

/* wave271 pure-owned GrowVec faces (runtime_pipeline_abi T; residual U). */
int grow_vec_init(GrowVec *v, size_t elem_sz, int32_t initial_cap);
void grow_vec_free(GrowVec *v);
int grow_vec_ensure(GrowVec *v);
void *grow_vec_at(GrowVec *v, int32_t idx);
int32_t grow_vec_push(GrowVec *v);
void grow_vec_copy_append(GrowVec *dst, GrowVec *src);

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

/* wave275 pure-owned leave: process tables live in runtime_pipeline_abi pure
 * (g_pipe_*_sc_blob). Residual host-cc same-TU consumers use these Cap faces.
 * dual-export ban: pipeline_abi T · pipeline_x U. PLATFORM: SHARED freestanding. */
ArenaSidecar *arena_sidecar_get(struct ast_ASTArena *a, int create);
void arena_sidecar_free(ArenaSidecar *sc);
ModuleSidecar *module_sidecar_get(struct ast_Module *m, int create);
void module_sidecar_free(ModuleSidecar *sc);
OneFuncSidecar *onefunc_sidecar_get(uint8_t *out, int create);
void onefunc_sidecar_free(OneFuncSidecar *sc);

/* wave276 pure-owned leave: arena main-pool Cap faces live in runtime_pipeline_abi
 * (pure ptr/alloc/write + seed always-C by-value get/set_copy + float IEEE).
 * Residual same-TU consumers need these prototypes (host leaf deleted).
 * dual-export ban: pipeline_abi T · pipeline_x U. PLATFORM: SHARED freestanding. */
struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref);

/* wave278: expr_sidecar Cap faces live in runtime_pipeline_abi seed ALWAYS;
 * residual same-TU (pipeline_typeck_check_expr / emit / glue) needs prototypes. */
void pipeline_expr_set_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref);
int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_on_call_created(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_prepare_call_arg_slot(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
int32_t pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
int32_t pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_num_type_args_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_append_call_type_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t type_ref);
int32_t pipeline_expr_call_type_arg_ref_at(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
int32_t pipeline_type_append_type_arg(struct ast_ASTArena *a, int32_t type_ref, int32_t arg_ref);
int32_t pipeline_type_type_arg_ref_at(struct ast_ASTArena *a, int32_t type_ref, int32_t idx);
int32_t pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref);
int32_t pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix, int32_t func_ix);
void pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e);
int32_t pipeline_expr_call_resolved_dep_index_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_resolved_func_index_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_call_callee_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_method_call_base_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_method_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_method_call_name_len(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_method_call_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);
int32_t pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref, int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant, int32_t variant_index);
int32_t pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
void pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v);
void pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t is_var, int32_t variant_index);
void pipeline_expr_match_arm_set_guard_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t guard_ref);
int32_t pipeline_expr_match_arm_guard_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i);
int32_t pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes, int32_t name_len, int32_t init_ref);
int32_t pipeline_expr_struct_lit_field_name_len(struct ast_ASTArena *a, int32_t expr_ref, int32_t j);
void pipeline_expr_struct_lit_field_name_into(struct ast_ASTArena *a, int32_t expr_ref, int32_t j, uint8_t *out64);
int32_t pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j);
int32_t pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref);
int32_t pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx);
int32_t pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_as_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_as_target_type_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_enum_variant_tag_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_if_cond_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_if_then_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_if_else_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_block_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_match_matched_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_const_folded_valid_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_const_folded_val_at(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_set_const_folded(struct ast_ASTArena *a, int32_t expr_ref, int32_t valid, int32_t val);
int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_set_index_base_is_slice(struct ast_ASTArena *a, int32_t expr_ref, int32_t v);
void pipeline_expr_set_index_proven_in_bounds(struct ast_ASTArena *a, int32_t expr_ref, int32_t v);
int32_t pipeline_expr_index_base_is_slice_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_index_proven_in_bounds_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_line_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_col_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_set_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref, int32_t offset);
int32_t pipeline_expr_field_access_soa_stride(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_int_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int64_t pipeline_expr_int64_val_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);
int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64);
int32_t pipeline_expr_var_name_len_for_string_lit_c(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_is_null_keyword_c(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_tag_null_keyword_c(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_left_ref_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_binop_right_ref_at(struct ast_ASTArena *a, int32_t expr_ref);

struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Func *pipeline_arena_func_ptr(struct ast_ASTArena *a, int32_t ref);
int32_t pipeline_arena_type_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_expr_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_block_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_func_alloc(struct ast_ASTArena *a);
int32_t pipeline_arena_num_types(struct ast_ASTArena *a);
int32_t pipeline_arena_type_cap(void);
int32_t pipeline_arena_expr_cap(void);
int32_t pipeline_arena_block_cap(void);
int32_t pipeline_arena_func_cap(void);
void pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len);
void pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                     int32_t right_ref);
struct ast_Type pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
void pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
struct ast_Expr pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
void pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
struct ast_Block pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
void pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
struct ast_Func pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
void pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref);
void ast_pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref);
void ast_pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
void ast_pipeline_arena_expr_write_var(struct ast_ASTArena *a, int32_t ref, uint8_t *name, int32_t name_len);
void ast_pipeline_arena_expr_write_binop(struct ast_ASTArena *a, int32_t ref, int32_t kind_ord, int32_t left_ref,
                                         int32_t right_ref);
struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref);
void ast_pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref);
void ast_pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena *a, int32_t ref);
void ast_ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref);
void ast_ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena *a, int32_t ref);
void ast_ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena *a, int32_t ref);
void ast_ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
struct ast_Type ast_arena_type_get(struct ast_ASTArena *a, int32_t ref);
void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t);
struct ast_Expr ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref);
void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e);
struct ast_Block ast_arena_block_get(struct ast_ASTArena *a, int32_t ref);
void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b);
struct ast_Func ast_arena_func_get(struct ast_ASTArena *a, int32_t ref);
void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f);
int ast_ref_is_null(int32_t ref);
void ast_expr_layout_prime_call_resolved(void);
void ast_ast_arena_init(struct ast_ASTArena *arena);
int32_t ast_ast_arena_type_alloc(struct ast_ASTArena *a);
int32_t ast_ast_arena_expr_alloc(struct ast_ASTArena *a);
int32_t ast_ast_arena_block_alloc(struct ast_ASTArena *a);
int32_t ast_ast_arena_func_alloc(struct ast_ASTArena *a);
int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap);
void pipeline_parser_library_init_bool_type_c(struct ast_ASTArena *arena, int32_t type_ref);
void pipeline_parser_library_init_named_type_c(struct ast_ASTArena *arena, int32_t type_ref, const uint8_t *name,
                                               int32_t name_len);
void pipeline_parser_library_init_var_expr_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t type_ref,
                                             const uint8_t *param_name, int32_t param_name_len);
void pipeline_parser_library_init_field_access_expr_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t base_ref,
                                                      const uint8_t *field_name, int32_t field_len);
void pipeline_parser_library_init_enum_variant_expr_c(struct ast_ASTArena *arena, int32_t expr_ref);
void pipeline_parser_library_init_eq_expr_c(struct ast_ASTArena *arena, int32_t expr_ref, int32_t bool_type_ref,
                                            int32_t left_ref, int32_t right_ref);
int32_t pipeline_parser_library_init_labeled_block_c(struct ast_ASTArena *arena, int32_t block_ref, int32_t eq_ref);
int32_t pipeline_parser_extern_init_arena_func_and_register_c(struct ast_ASTArena *arena, struct ast_Module *module,
                                                              int32_t func_ref, const uint8_t *name, int32_t name_len,
                                                              int32_t num_params, int32_t return_ty_ref);
struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_float_bits_lo_at(struct ast_ASTArena *a, int32_t expr_ref);
int32_t pipeline_expr_float_bits_hi_at(struct ast_ASTArena *a, int32_t expr_ref);
void pipeline_expr_typeck_set_float_bits_from_val(struct ast_ASTArena *a, int32_t expr_ref);
int32_t glue_ieee_f64_bits_to_f32_bits(int32_t lo, int32_t hi);
int32_t glue_ieee_f32_bits_to_f64_lo(int32_t fb);
int32_t glue_ieee_f32_bits_to_f64_hi(int32_t fb);
int32_t glue_i32_to_f32_bits(int32_t v);
int32_t glue_i64_to_f32_bits(int64_t v);
void glue_i64_to_f64_bits(int64_t v, int32_t *lo, int32_t *hi);


/* wave279: lifecycle Cap faces live in runtime_pipeline_abi seed ALWAYS
 * (block_on_alloc / module|arena reset|release / drop_bodies / onefunc reset|release).
 * Residual same-TU consumers need these prototypes (host leaf deleted).
 * dual-export ban: pipeline_abi T · pipeline_x U. PLATFORM: SHARED freestanding. */
void ast_pool_block_on_alloc(struct ast_ASTArena *a, int32_t block_ref);
void ast_pool_module_reset(struct ast_Module *m);
void ast_pool_arena_reset(struct ast_ASTArena *a);
void ast_pool_arena_release(struct ast_ASTArena *a);
void ast_pool_module_release(struct ast_Module *m);
void ast_pool_drop_bodies_for_check(struct ast_ASTArena *a, struct ast_Module *m);
void ast_pool_onefunc_reset(uint8_t *out);
void ast_pool_onefunc_release(uint8_t *out);

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

/* wave277: ast_pool_block host leaf deleted — Cap residual faces live in
 * runtime_pipeline_abi seed ALWAYS. Residual same-TU callers (onefunc fill_*,
 * glue) need these prototypes. dual-export ban: pipeline_abi T · pipeline_x U.
 * PLATFORM: SHARED freestanding. */
int32_t pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                    int32_t type_ref, int32_t init_ref);
int32_t pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                  int32_t type_ref, int32_t init_ref);
int32_t pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                 int32_t else_ref);
int32_t pipeline_block_append_region(struct ast_ASTArena *a, int32_t br, uint8_t *label, int32_t label_len,
                                     int32_t body_ref);
int32_t pipeline_block_append_with_arena(struct ast_ASTArena *a, int32_t br, int32_t cap_ref, int32_t body_ref);
int32_t pipeline_block_append_unsafe(struct ast_ASTArena *a, int32_t br, int32_t body_ref);
int32_t pipeline_block_append_defer(struct ast_ASTArena *a, int32_t br, int32_t body_ref);
int32_t pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref);
int32_t pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx_val);
int32_t pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref);
int32_t pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                  int32_t step_ref, int32_t body_ref);
int32_t pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                      int32_t goto_target_len, int32_t return_expr_ref);
int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                          int32_t goto_target_len, int32_t return_expr_ref);
struct ast_LabeledStmt *pipeline_block_labeled_ptr(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_region_with_arena_cap_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t pipeline_block_region_is_unsafe(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t pipeline_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t pipeline_block_region_label_len(struct ast_ASTArena *a, int32_t br, int32_t ri);
void pipeline_block_region_label_copy64(struct ast_ASTArena *a, int32_t br, int32_t ri, uint8_t *dst);
int32_t pipeline_block_defer_body_ref(struct ast_ASTArena *a, int32_t br, int32_t di);
int32_t pipeline_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t pipeline_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t pipeline_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t pipeline_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t pipeline_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t pipeline_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci);
void pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst);
int32_t pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_set_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li, int32_t type_ref);
int32_t pipeline_block_set_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci, int32_t type_ref);
int32_t pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
uint8_t pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t pipeline_block_num_labeled_stmts(struct ast_ASTArena *a, int32_t br);
int32_t pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_labeled_is_goto(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t pipeline_block_labeled_label_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_labeled_label_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
int32_t pipeline_block_labeled_goto_target_len(struct ast_ASTArena *a, int32_t br, int32_t li);
void pipeline_block_labeled_goto_target_copy32(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst);
void pipeline_patch_block_parent_links(struct ast_ASTArena *a, int32_t block_ref, int32_t parent_ref);
int32_t pipeline_block_set_parent_if_zero(struct ast_ASTArena *a, int32_t block_ref, int32_t parent_ref);
int32_t pipeline_block_parent_block_ref_at(struct ast_ASTArena *a, int32_t block_ref);
int32_t pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen);
int32_t pipeline_block_name_binding_kind(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen);
int32_t pipeline_block_local_name_redecl_c(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen,
                                           int32_t kind, int32_t idx, struct ast_Module *m, int32_t func_index);
int32_t pipeline_block_find_var_decl_block_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen);
void pipeline_block_stmt_order_prepend_lets(struct ast_ASTArena *a, int32_t br, int32_t let_start_idx, int32_t let_count);
void pipeline_block_stmt_order_fix_prefix_lets(struct ast_ASTArena *a, int32_t br, int32_t prefix_n);
void pipeline_block_with_arena_fixup_stmt_order(struct ast_ASTArena *a, int32_t br);
void pipeline_block_stmt_order_rebuild_sparse_ifs(struct ast_ASTArena *a, int32_t br);
void pipeline_module_fixup_with_arena_stmt_orders(struct ast_Module *m, struct ast_ASTArena *a);
void ast_ast_arena_patch_block_parent_links(struct ast_ASTArena *arena, int32_t block_ref, int32_t parent_ref);
int32_t ast_ast_block_num_consts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_lets(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_for_loops(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_if_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_regions(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_region_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ri);
int32_t ast_ast_block_num_expr_stmts(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_num_stmt_order(struct ast_ASTArena *a, int32_t br);
uint8_t ast_ast_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si);
int32_t ast_ast_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t ast_ast_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci);
int32_t ast_ast_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t ast_ast_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li);
int32_t ast_ast_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
int32_t ast_ast_block_final_expr_ref(struct ast_ASTArena *a, int32_t br);
int32_t ast_ast_block_while_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_while_body_ref(struct ast_ASTArena *a, int32_t br, int32_t wi);
int32_t ast_ast_block_for_init_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_step_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_for_body_ref(struct ast_ASTArena *a, int32_t br, int32_t fi);
int32_t ast_ast_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii);
int32_t ast_ast_block_resolve_var_to_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname, int32_t vlen);
int ast_ast_expr_disallows_implicit_tail(struct ast_ASTArena *a, int32_t expr_ref);
void ast_ast_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t call_expr_ref, int32_t dep_ix, int32_t func_ix);
