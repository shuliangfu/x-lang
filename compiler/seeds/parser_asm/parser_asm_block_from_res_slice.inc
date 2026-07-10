/**
 * parser_asm_block_from_res_slice.inc — fill_block_const_let_from_res / append_block_lets_from_res C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * OneFunc 侧车池 → block const/let 声明；Expr 按值初始化勿 X emit（曾 elf_ec=-1 / code 缓冲触顶）。
 */
#ifndef PARSER_ASM_BLOCK_FROM_RES_SLICE_INCLUDED
#define PARSER_ASM_BLOCK_FROM_RES_SLICE_INCLUDED

extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern struct ast_Expr ast_ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t pipeline_onefunc_num_consts(uint8_t *out);
extern int32_t pipeline_onefunc_num_lets(uint8_t *out);
extern int32_t pipeline_onefunc_const_init_val(uint8_t *out, int32_t i);
extern int32_t pipeline_onefunc_const_init_ref(uint8_t *out, int32_t i);
extern int32_t pipeline_onefunc_let_init_val(uint8_t *out, int32_t i);
extern int32_t pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i);
extern int32_t pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i);
extern int32_t pipeline_onefunc_const_type_ref(uint8_t *out, int32_t i);
extern void pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern void pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst);
extern int32_t pipeline_onefunc_const_name_len(uint8_t *out, int32_t i);
extern int32_t pipeline_onefunc_let_name_len(uint8_t *out, int32_t i);
extern int32_t pipeline_block_append_const(void *a, int32_t br, uint8_t *name, int32_t name_len, int32_t type_ref,
                                           int32_t init_ref);
extern int32_t pipeline_block_append_let(void *a, int32_t br, uint8_t *name, int32_t name_len, int32_t type_ref,
                                         int32_t init_ref);
extern uint8_t *parser_asm_onefunc_result_pool_ptr_c(struct parser_asm_onefunc_result *res);
extern int32_t parser_asm_stretch_block_bind_name_audit_c(const uint8_t *name, int32_t name_len);

/** expr_set_common_zeros：与 parser.x / parser_asm_thin_c.c 字段清零顺序一致。 */
static void parser_asm_block_expr_common_zeros_c(struct ast_Expr *e) {
  if (!e)
    return;
  e->resolved_type_ref = 0;
  e->binop_left_ref = 0;
  e->binop_right_ref = 0;
  e->unary_operand_ref = 0;
  e->if_cond_ref = 0;
  e->if_then_ref = 0;
  e->if_else_ref = 0;
  e->block_ref = 0;
  e->match_matched_ref = 0;
  e->match_arm_base = 0;
  e->match_num_arms = 0;
  e->enum_variant_tag = 0;
  e->field_access_base_ref = 0;
  e->field_access_field_len = 0;
  e->field_access_is_enum_variant = 0;
  e->field_access_offset = 0;
  e->index_base_ref = 0;
  e->index_index_ref = 0;
  e->index_base_is_slice = 0;
  e->call_callee_ref = 0;
  e->call_arg_base = 0;
  e->call_num_args = 0;
  e->method_call_base_ref = 0;
  e->method_call_name_len = 0;
  e->method_call_arg_base = 0;
  e->method_call_num_args = 0;
  e->const_folded_val = 0;
  e->const_folded_valid = 0;
  e->index_proven_in_bounds = 0;
  e->struct_lit_field_base = 0;
  e->struct_lit_num_fields = 0;
  e->array_lit_elem_base = 0;
  e->array_lit_num_elems = 0;
  e->as_operand_ref = 0;
  e->as_target_type_ref = 0;
  e->call_resolved_func_index = -1;
  e->call_resolved_dep_index = -1;
}

/**
 * 分配 EXPR_LIT 并写入 int_val；失败返回 0。
 */
static int32_t parser_asm_block_lit_init_ref_c(void *arena, int32_t type_ref, int32_t int_val) {
  int32_t ref;
  struct ast_Expr e;
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0)
    return 0;
  e = ast_ast_arena_expr_get(arena, ref);
  e.kind = 0; /* AST_EXPR_LIT */
  e.resolved_type_ref = type_ref;
  e.line = 0;
  e.col = 0;
  e.int_val = int_val;
  parser_asm_block_expr_common_zeros_c(&e);
  ast_ast_arena_expr_set(arena, ref, e);
  return ref;
}

/**
 * 解析 let 侧车条目：取 init_ref（无则造 EXPR_LIT）并 append 到 block。
 */
static int32_t parser_asm_block_append_one_let_c(void *arena, int32_t block_ref, uint8_t *pool, int32_t src_i,
                                                 int32_t type_ref) {
  int32_t let_decl_ty;
  int32_t init_ref;
  uint8_t lname_buf[64];
  let_decl_ty = type_ref;
  if (pipeline_onefunc_let_type_ref(pool, src_i) != 0)
    let_decl_ty = pipeline_onefunc_let_type_ref(pool, src_i);
  init_ref = pipeline_onefunc_let_init_ref(pool, src_i);
  /** -1：let x: T; 无初值；block 留 init_ref=0，勿合成 EXPR_LIT(0)（会与 let x: i32 = 0 混淆）。 */
  if (init_ref == -1) {
    init_ref = 0;
  } else if (init_ref == 0) {
    init_ref = parser_asm_block_lit_init_ref_c(arena, let_decl_ty, pipeline_onefunc_let_init_val(pool, src_i));
    if (init_ref == 0)
      return 0;
  }
  memset(lname_buf, 0, sizeof(lname_buf));
  pipeline_onefunc_let_name_copy64(pool, src_i, lname_buf);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_block_bind_name_audit_c(lname_buf, pipeline_onefunc_let_name_len(pool, src_i)));
  if (pipeline_block_append_let(arena, block_ref, lname_buf, pipeline_onefunc_let_name_len(pool, src_i), let_decl_ty,
                                init_ref) < 0)
    return 0;
  return 1;
}

/**
 * fill_block_const_let_from_res：按 OneFuncResult 侧车填写 block 的 const/let 声明。
 */
int32_t parser_asm_fill_block_const_let_from_res_c(void *arena, int32_t block_ref, struct parser_asm_onefunc_result *res,
                                                   int32_t type_ref) {
  uint8_t *pool;
  int32_t const_i;
  int32_t nc;
  int32_t let_i;
  int32_t nl;
  int32_t cinit_ref;
  int32_t const_decl_ty;
  uint8_t cname_buf[64];
  if (!arena || !res)
    return 0;
  pool = parser_asm_onefunc_result_pool_ptr_c(res);
  const_i = 0;
  nc = pipeline_onefunc_num_consts(pool);
  while (const_i < nc) {
    /** 与 let 分支一致：须用侧车 const 声明类型，勿误传 fill 入参 type_ref（常为 0 或函数返回类型）。 */
    const_decl_ty = type_ref;
    if (pipeline_onefunc_const_type_ref(pool, const_i) != 0)
      const_decl_ty = pipeline_onefunc_const_type_ref(pool, const_i);
    /** 与 let 分支一致：优先侧车 init_ref（如 `const B = A + 2`）；无 ref 时再按 init_val 合成 EXPR_LIT。 */
    cinit_ref = pipeline_onefunc_const_init_ref(pool, const_i);
    if (cinit_ref == 0)
      cinit_ref = parser_asm_block_lit_init_ref_c(arena, const_decl_ty, pipeline_onefunc_const_init_val(pool, const_i));
    if (cinit_ref == 0)
      return 0;
    memset(cname_buf, 0, sizeof(cname_buf));
    pipeline_onefunc_const_name_copy64(pool, const_i, cname_buf);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_block_bind_name_audit_c(cname_buf, pipeline_onefunc_const_name_len(pool, const_i)));
    if (pipeline_block_append_const(arena, block_ref, cname_buf, pipeline_onefunc_const_name_len(pool, const_i),
                                    const_decl_ty, cinit_ref) < 0)
      return 0;
    const_i = const_i + 1;
  }
  res->num_consts = nc;
  let_i = 0;
  nl = pipeline_onefunc_num_lets(pool);
  while (let_i < nl) {
    if (!parser_asm_block_append_one_let_c(arena, block_ref, pool, let_i, type_ref))
      return 0;
    let_i = let_i + 1;
  }
  res->num_lets = nl;
  return 1;
}

/**
 * append_block_lets_from_res：在已有块上追加 res 中 let（从 let_base 起）。
 */
int32_t parser_asm_append_block_lets_from_res_c(void *arena, int32_t block_ref, struct parser_asm_onefunc_result *res,
                                                int32_t let_base, int32_t type_ref) {
  uint8_t *pool;
  int32_t src_i;
  int32_t nl;
  if (!arena || !res)
    return 0;
  pool = parser_asm_onefunc_result_pool_ptr_c(res);
  src_i = let_base;
  nl = pipeline_onefunc_num_lets(pool);
  while (src_i < nl) {
    if (!parser_asm_block_append_one_let_c(arena, block_ref, pool, src_i, type_ref))
      return 0;
    src_i = src_i + 1;
  }
  res->num_lets = nl;
  return 1;
}

#endif /* PARSER_ASM_BLOCK_FROM_RES_SLICE_INCLUDED */
