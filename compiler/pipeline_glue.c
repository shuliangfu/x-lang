/**
 * pipeline_glue.c — 与 -E 产出的 pipeline_gen.c 同属一个翻译单元的 C 胶水代码。
 *
 * 用法：pipeline_gen.c 末尾有 #include "pipeline_glue.c"（由 runtime.c -E 或 build_patch 追加），
 * 编译 pipeline_gen.c 时由 cc 在同一 TU 内包含本文件，故可直接使用上方已定义的 ast_* / codegen_* 等类型。
 * 不单独编译；无补丁、无 sed，所有逻辑在此源文件内从根源提供。
 *
 * parser.su 聚合 -o 可执行时，runtime 在含入前 #define SHU_PARSER_EXE_PIPELINE_GLUE：省略依赖
 * platform_elf_ElfCodegenCtx 完整定义与 codegen.o 转发符号的片段，避免单文件 TU 编译失败。
 *
 * ── extern 消费者索引（10.4.2 自举；删函数前 grep 本表）────────────────────────────
 * | 符号 | 消费者 |
 * |------|--------|
 * | parser_slice_from_buf / lexer_parser_slice_from_buf / pipeline_source_slice | parser.su, lexer.su, pipeline.su |
 * | parser_lex_from_lexer_result_ptr_into | parser.su（*LexerResult → *Lexer，避 typeck 链式 FIELD_ACCESS） |
 * | pipeline_run_su_pipeline | runtime.c（C 包装 buf+len） |
 * | pipeline_sizeof_* / pipeline_arena_offset_num_types | parser.su, lsp_diag.su；**PipelineDepCtx 增字段时须同步** runtime.c / lsp_diag_pipeline_sizes.c / ast.su |
 * | pipeline_expr_ref_is_assign_lvalue | parser.su |
 * | compound_assign_token_to_expr_kind_from_glue | parser.su |
 * | pipeline_expr_* / ast_pipeline_expr_* / implicit_tail_expr_disallowed_by_glue | ast.su, typeck.su |
 * | pipeline_type_* / pipeline_module_struct_layout_* | typeck.su, codegen.su |
 * | pipeline_module_func_* / pipeline_arena_func_* | parser.su |
 * | pipeline_asm_array_lit_elem_type_ref | asm/backend.su |
 * | pipeline_module_func_is_extern_at / pipeline_module_func_body_ref_at / pipeline_module_func_name_len_at | asm/backend.su, arch/arm64.su |
 * | pipeline_backend_get_return_expr_ref_at / pipeline_arm64_get_return_lit_ref_at | asm/backend.su, arch/arm64.su |
 * | std_io_driver_submit_*_batch_buf | pipeline_gen.c 同 TU（io.o 批量读写） |
 * | driver_get_module_num_funcs / driver_get_module_main_func_index | runtime.c 烟测 |
 * | driver_diagnostic_entry_* | pipeline.su（日常 no-op） |
 * 原因：SU/asm 对大 struct 按值读写字段或 enum 比较易撕裂/ typeck 失败，暂保留 C 指针读池。
 */

/* struct shulang_slice_uint8_t 已由 -E 产出的 pipeline_gen.c 上方定义，不在此重复。 */
#include <stddef.h>
#include <string.h>

/** ast_pool.c 提供；须在下方 glue 之前声明（ast_pool.c 在文件末尾 #include）。 */
struct ast_Func *pipeline_module_func_ptr(struct ast_Module *m, int32_t func_index);
int32_t pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei);
struct ast_Type *pipeline_arena_type_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Expr *pipeline_arena_expr_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Block *pipeline_arena_block_ptr(struct ast_ASTArena *a, int32_t ref);
struct ast_Func *pipeline_arena_func_ptr(struct ast_ASTArena *a, int32_t ref);
int32_t pipeline_arena_type_alloc(struct ast_ASTArena *a);
int32_t pipeline_module_struct_layout_alloc(struct ast_Module *m);
void pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len);
void pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                              int32_t fname_len, int32_t ftype_ref, int32_t foff);
int32_t pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64);
int32_t pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx);
void pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf);
int32_t pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j);
int32_t pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j);
void pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64);
/** func 形参池读 API；glue 内 asm 转发在 ast_pool.c 定义之前调用。 */
int32_t pipeline_module_func_num_params_at(struct ast_Module *m, int32_t func_index);
int32_t pipeline_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index, int32_t param_index);
void pipeline_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index, int32_t param_index,
                                            uint8_t *dst);

/** 从 (data, len) 构造 slice，供 parser.su 内 parse_into_buf 调 parse_one_function_impl 时使用。 */
struct shulang_slice_uint8_t parser_slice_from_buf(uint8_t *data, int32_t len) {
  struct shulang_slice_uint8_t s;
  s.data = data;
  s.length = (size_t)(len >= 0 ? len : 0);
  return s;
}

/**
 * lexer.su 内的 extern：Codegen 会带 lexer_ 模块前缀，否则会链接到不存在的 lexer_parser_slice_from_buf。
 * 与 parser_slice_from_buf 等价，仅别名。
 */
struct shulang_slice_uint8_t lexer_parser_slice_from_buf(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

/**
 * parser.su：从 *LexerResult 拷贝 next_lex 三字段到 *Lexer。
 * 避免 `r.next_lex.pos` 等 *T 链式 FIELD_ACCESS 在 typeck 上 RHS 解析为 ?。
 */
void parser_lex_from_lexer_result_ptr_into(struct lexer_Lexer *out, struct lexer_LexerResult *r) {
  if (out == NULL || r == NULL)
    return;
  out->pos = r->next_lex.pos;
  out->line = r->next_lex.line;
  out->col = r->next_lex.col;
}

/** CollectImportsResult.lex → *Lexer；嵌套字段 typeck 不落码时的 C 侧拷贝。 */
void parser_lex_copy_from_collect_imports(struct lexer_Lexer *out, struct parser_CollectImportsResult res) {
  if (out == NULL)
    return;
  out->pos = res.lex.pos;
  out->line = res.lex.line;
  out->col = res.lex.col;
}

/** LexerResult.next_lex → *Lexer。 */
void parser_lex_from_lexer_result_val_into(struct lexer_Lexer *out, struct lexer_LexerResult r) {
  if (out == NULL)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

/** *OneFuncResult.next_lex → *Lexer（OneFuncResult 过大，仅指针路径）。 */
void parser_lex_from_onefunc_result_ptr_into(struct lexer_Lexer *out, struct parser_OneFuncResult *res) {
  if (out == NULL || res == NULL)
    return;
  out->pos = res->next_lex.pos;
  out->line = res->next_lex.line;
  out->col = res->next_lex.col;
}

/** 供 pipeline.su run_su_pipeline_impl 使用：与 parser_slice_from_buf 相同，避免 -E 对 parser_* 符号双重前缀。 */
struct shulang_slice_uint8_t pipeline_source_slice(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

#ifndef SHU_PARSER_EXE_PIPELINE_GLUE
/* C 包装：以 (data, len) 形式调用 pipeline，impl 内用 parse_into_with_init_buf 解析，无需组 slice。 */
extern int32_t pipeline_run_su_pipeline_impl(struct ast_Module *module, struct ast_ASTArena *arena, uint8_t *source_data, size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx);

int32_t pipeline_run_su_pipeline(struct ast_Module *module, struct ast_ASTArena *arena, const uint8_t *source_data, size_t source_len, struct codegen_CodegenOutBuf *out_buf, struct ast_PipelineDepCtx *ctx) {
  return pipeline_run_su_pipeline_impl(module, arena, (uint8_t *)source_data, source_len, out_buf, ctx);
}
#endif /* !SHU_PARSER_EXE_PIPELINE_GLUE */

size_t pipeline_sizeof_arena(void) { return sizeof(struct ast_ASTArena); }
size_t pipeline_sizeof_module(void) { return sizeof(struct ast_Module); }
/** LSP / lsp_diag.su：PipelineDepCtx 体量大（含 4MiB×2 缓冲），一次性 calloc 后 memset 复用。 */
size_t pipeline_sizeof_dep_ctx(void) { return sizeof(struct ast_PipelineDepCtx); }
/** parser OneFuncResult 体量大（256×64 let 名等）；parse_block_into 堆分配 scratch，避免递归块解析栈溢出。 */
size_t pipeline_sizeof_onefunc_result(void) { return (size_t)8192; }
size_t pipeline_arena_offset_num_types(void) { return offsetof(struct ast_ASTArena, num_types); }
#ifndef SHU_PARSER_EXE_PIPELINE_GLUE
size_t pipeline_sizeof_elf_ctx(void) { return sizeof(struct platform_elf_ElfCodegenCtx); }
#else
/** parser 聚合 exe TU 不含 ElfCodegenCtx 定义：占位返回 0（该路径不调 asm 全流程 sizeof）。 */
size_t pipeline_sizeof_elf_ctx(void) { return (size_t)0; }
#endif /* SHU_PARSER_EXE_PIPELINE_GLUE */

#include <stdio.h>
void pipeline_debug_module_funcs(void *m) {
  struct ast_Module *mod = (struct ast_Module *)m;
  int i, n = (int)mod->num_funcs;
  for (i = 0; i < n; i++) {
    struct ast_Func *f = pipeline_module_func_ptr(mod, i);
    int len = f ? (int)f->name_len : 0;
    if (f)
      fprintf(stderr, "[DEBUG] module func[%d] name_len=%d name=%.*s\n", i, len,
              len > 0 && len <= 64 ? len : 0, f->name);
  }
}

/** 供 runtime.c 诊断：返回 module 的 num_funcs（需与 pipeline 同 TU 以用 ast_Module 布局）。 */
int driver_get_module_num_funcs(void *m) {
  return m ? (int)((struct ast_Module *)m)->num_funcs : 0;
}

/** 供 runtime.c 烟测摘要：解析后 module.main_func_index（无 main 为 -1，与 pipeline.su parse_into_set_main_index 一致）。 */
int driver_get_module_main_func_index(void *m) {
  return m ? (int)((struct ast_Module *)m)->main_func_index : -2;
}

/** 诊断：解析 entry 后打印 main 的 body_ref；日常构建关闭，排查 main 空体时取消下方注释。由 pipeline.su 在 parse 后 / codegen 前调用。 */
void driver_diagnostic_entry_module(struct ast_Module *mod, struct ast_ASTArena *a) {
  (void)a;
  (void)mod;
  /* if (mod && (mod->main_func_index >= 0 && mod->main_func_index < mod->num_funcs)) {
    int32_t br = mod->funcs[mod->main_func_index].body_ref;
    fprintf(stderr, "[diag] entry num_funcs=%d main_idx=%d body_ref=%d\n",
            (int)mod->num_funcs, (int)mod->main_func_index, (int)br);
  } else if (mod) {
    fprintf(stderr, "[diag] entry num_funcs=%d main_idx=%d (invalid)\n",
            (int)mod->num_funcs, (int)mod->main_func_index);
  } */
}

/** pipeline.su -E 产出 typeck_ 前缀；实现于 runtime.c。 */
extern void driver_diagnostic_after_entry_parse(int32_t num_funcs);

void typeck_driver_diagnostic_after_entry_parse(int32_t num_funcs) {
  driver_diagnostic_after_entry_parse(num_funcs);
}

/** 诊断：解析后打印 main 对应 body block 的 num_stmt_order（C 侧调用）；日常构建保留实现不调用，排查时在 runtime.c 恢复调用。 */
void driver_diagnostic_entry_block_after_parse(void *mod, void *arena) {
  struct ast_Module *m = (struct ast_Module *)mod;
  struct ast_ASTArena *a = (struct ast_ASTArena *)arena;
  if (!m || !a || m->main_func_index < 0 || m->main_func_index >= m->num_funcs)
    return;
  {
    struct ast_Func *mf = pipeline_module_func_ptr(m, m->main_func_index);
    int32_t br = mf ? (int32_t)mf->body_ref : 0;
    if (br <= 0 || br > a->num_blocks)
      return;
    (void)br;
    (void)a;
    /* struct ast_Block b = ast_ast_arena_block_get(a, br);
    fprintf(stderr, "[diag] after_parse body_ref=%d num_blocks=%d block.num_stmt_order=%d\n",
            (int)br, (int)a->num_blocks, (int)b.num_stmt_order); */
  }
}

/* std.io.driver 单次 _buf 声明与 inline 已由 -E 产出在 pipeline_gen.c 顶部（runtime.c -E 路径 preamble），此处仅保留批量读写桩。 */

/* std.io.driver 批量读写桩：pipeline_gen.c 同 TU 已定义 struct std_io_driver_Buffer；io.o 提供 io_read_batch_buf/io_write_batch_buf，供 shu_su 链接时解析。 */
extern ptrdiff_t io_read_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);
extern ptrdiff_t io_write_batch_buf(int fd, const struct std_io_driver_Buffer *bufs, int n, unsigned timeout_ms);

int32_t std_io_driver_submit_read_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_read_batch_buf((int)handle, bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}

int32_t std_io_driver_submit_write_batch_buf(size_t handle, struct std_io_driver_Buffer *bufs, int32_t n, uint32_t timeout_ms) {
  ptrdiff_t r = io_write_batch_buf((int)handle, bufs, n, timeout_ms);
  return (r < 0) ? -1 : (int32_t)r;
}

/** 读池中 expr.kind；仅供本文件与 glue 导出函数使用（SU 无法用 Expr 局部安全 typeck）。 */
static enum ast_ExprKind glue_arena_expr_kind_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return ast_ExprKind_EXPR_LIT;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex ? ex->kind : ast_ExprKind_EXPR_LIT;
}

/**
 * parser.su expr_ref_is_assign_lvalue：与 shu-c 生成码对 struct 直读一致。
 * SU 中对「let e: Expr = ast_arena_expr_get(...)」再写 e.kind == … 会在 .su typeck 路径失败（见 ast.su 注释）；由 C 从池读 kind / is_enum_variant。
 * 返回 1 表示可作为赋值左值，0 表示否。
 */
int32_t pipeline_expr_ref_is_assign_lvalue(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs) {
    return 0;
  }
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  if (kd == ast_ExprKind_EXPR_VAR || kd == ast_ExprKind_EXPR_INDEX) {
    return 1;
  }
  if (kd != ast_ExprKind_EXPR_FIELD_ACCESS) {
    return 0;
  }
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  return ex && ex->field_access_is_enum_variant == 0 ? 1 : 0;
}

/**
 * parser.su compound_assign_token_to_expr_kind：在 C 内完成 TokenKind→ExprKind 映射，
 * 避免 .su 中 `return ExprKind.*` 与枚举比较在 typeck 下失败；符号名供 parser extern 原样链接。
 */
enum ast_ExprKind compound_assign_token_to_expr_kind_from_glue(enum token_TokenKind kind) {
  if (kind == token_TokenKind_TOKEN_PLUS_EQ) return ast_ExprKind_EXPR_ADD_ASSIGN;
  if (kind == token_TokenKind_TOKEN_MINUS_EQ) return ast_ExprKind_EXPR_SUB_ASSIGN;
  if (kind == token_TokenKind_TOKEN_STAR_EQ) return ast_ExprKind_EXPR_MUL_ASSIGN;
  if (kind == token_TokenKind_TOKEN_SLASH_EQ) return ast_ExprKind_EXPR_DIV_ASSIGN;
  if (kind == token_TokenKind_TOKEN_PERCENT_EQ) return ast_ExprKind_EXPR_MOD_ASSIGN;
  if (kind == token_TokenKind_TOKEN_AMP_EQ) return ast_ExprKind_EXPR_BITAND_ASSIGN;
  if (kind == token_TokenKind_TOKEN_PIPE_EQ) return ast_ExprKind_EXPR_BITOR_ASSIGN;
  if (kind == token_TokenKind_TOKEN_CARET_EQ) return ast_ExprKind_EXPR_BITXOR_ASSIGN;
  if (kind == token_TokenKind_TOKEN_LSHIFT_EQ) return ast_ExprKind_EXPR_SHL_ASSIGN;
  return ast_ExprKind_EXPR_SHR_ASSIGN;
}

/**
 * ast.su extern：块末若为 RETURN/PANIC/BREAK/CONTINUE，返回 1（禁止隐式尾）；非法 ref 视为 1。
 * 符号名 deliberately 无前缀，供 SU「extern function」原样映射，避免与其它 ast_ast_* extern 串联重复前缀。
 */
/** ast.su：池槽 CALL 解析占位 -1（避免 SU 对 Expr 尾字段 FIELD_ACCESS 缺 layout）。 */
void pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_func_index = -1;
  ex->call_resolved_dep_index = -1;
}

/** ast.su / typeck.su：typeck 命中后写入 call_resolved_*。 */
void pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                    int32_t func_ix) {
  struct ast_Expr *ex;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return;
  ex = pipeline_arena_expr_ptr(a, expr_ref);
  if (!ex)
    return;
  ex->call_resolved_dep_index = dep_ix;
  ex->call_resolved_func_index = func_ix;
}

/** parser.su expr_set_common_zeros：对堆/池上 Expr 指针写 call_resolved 占位。 */
void pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e) {
  if (!e)
    return;
  e->call_resolved_func_index = -1;
  e->call_resolved_dep_index = -1;
}

/** import ast 时 codegen 可能加 ast_ 前缀；转发到 pipeline_expr_* 裸符号。 */
void ast_pipeline_expr_ptr_init_call_resolve(struct ast_Expr *e) {
  pipeline_expr_ptr_init_call_resolve(e);
}

void ast_pipeline_expr_init_call_resolve_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  pipeline_expr_init_call_resolve_at_ref(a, expr_ref);
}

void ast_pipeline_expr_apply_call_resolve(struct ast_ASTArena *a, int32_t expr_ref, int32_t dep_ix,
                                         int32_t func_ix) {
  pipeline_expr_apply_call_resolve(a, expr_ref, dep_ix, func_ix);
}

int implicit_tail_expr_disallowed_by_glue(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return 1;
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  if (kd == ast_ExprKind_EXPR_RETURN || kd == ast_ExprKind_EXPR_PANIC ||
      kd == ast_ExprKind_EXPR_BREAK || kd == ast_ExprKind_EXPR_CONTINUE)
    return 1;
  return 0;
}

/**
 * 从 arena.types[ref-1] 拷贝整块 name[64] 到调用方缓冲区（memcpy），避免 ast_ast_arena_type_get
 * 在大 struct ast_Type 场景下按值返回时后端只传部分字段导致名段撕裂（如 AArch64 上布局查找失败）。
 * 返回 name_len；ref 无效或越界返回 0。
 */
int32_t pipeline_type_named_name_into(struct ast_ASTArena *arena, int32_t ref, uint8_t *out64) {
  struct ast_Type *t;
  if (!arena || !out64 || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  if (!t)
    return 0;
  memcpy(out64, t->name, sizeof(t->name));
  return t->name_len;
}

/**
 * 读取 arena.types[ref-1].kind 作为与 TypeKind ordinal 对齐的枚举序数。
 * ref 无效时返回 -1。
 */
int32_t pipeline_type_kind_ord_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return -1;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? (int32_t)t->kind : -1;
}

/**
 * 读取 arena.types[ref-1].elem_type_ref（指针指向元素类型、向量元素类型等）。
 * ref 无效时返回 0。
 */
int32_t pipeline_type_elem_ref_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? t->elem_type_ref : 0;
}

/**
 * asm/backend.su asm_expr_array_elem_store_sz_bytes：从数组字面量 expr 池 ref 取 TYPE_ARRAY 的 elem_type_ref。
 * 无效、非数组或 elem 缺失时返回 0。在 C 内读池，避免 .su 中 `let e: Expr = ast_arena_expr_get` 后字段访问触发 typeck 失败，
 * 亦避免 backend import codegen 时 pipeline_type_* 调用被编成 codegen_ 前缀导致链接未定义。
 */
int32_t pipeline_asm_array_lit_elem_type_ref(struct ast_ASTArena *arena, int32_t array_lit_expr_ref) {
  int32_t arr_tr;
  int32_t tk;
  struct ast_Expr *ex;
  if (!arena || array_lit_expr_ref <= 0 || array_lit_expr_ref > arena->num_exprs)
    return 0;
  ex = pipeline_arena_expr_ptr(arena, array_lit_expr_ref);
  if (!ex)
    return 0;
  arr_tr = ex->resolved_type_ref;
  if (arr_tr <= 0)
    return 0;
  tk = pipeline_type_kind_ord_at(arena, arr_tr);
  if (tk != 10)
    return 0;
  return pipeline_type_elem_ref_at(arena, arr_tr);
}

/**
 * 读取 arena.types[ref-1].array_size（数组长度、向量 lane 数等）。
 * ref 无效时返回 0。
 */
int32_t pipeline_type_array_size_at(struct ast_ASTArena *arena, int32_t ref) {
  struct ast_Type *t;
  if (!arena || ref <= 0 || ref > arena->num_types)
    return 0;
  t = pipeline_arena_type_ptr(arena, ref);
  return t ? t->array_size : 0;
}

/** func 形参 / arena copy_slot 实现见 ast_pool.c（#include 进本 TU）。 */

void pipeline_module_func_name_write(struct ast_Module *m, int32_t func_index, uint8_t *name_bytes,
                                     int32_t name_len) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return;
  if (name_len < 0 || name_len > 64)
    return;
  if (name_len > 0 && !name_bytes)
    return;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return;
  f->name_len = name_len;
  memset(f->name, 0, sizeof(f->name));
  if (name_len > 0)
    memcpy(f->name, name_bytes, (size_t)name_len);
}

/** 自举 codegen：将 module->funcs[fi].name[64] 拷入 dst，避免 .su 对嵌套大数组下标 typeck/asm GEP 失败。 */
void pipeline_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst) {
  struct ast_Func *f;
  if (!m || !dst || func_index < 0)
    return;
  if (func_index >= (int32_t)m->num_funcs)
    return;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return;
  memcpy(dst, f->name, (size_t)64);
}

int32_t pipeline_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->name_len : 0;
}

int32_t pipeline_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->is_extern : 0;
}

int32_t pipeline_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  struct ast_Func *f;
  if (!m || func_index < 0)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  return f ? (int32_t)f->body_ref : 0;
}

/** struct_layout / import / top_level / enum / func 形参池实现见 ast_pool.c（文件末尾 #include）。 */

/** 读 arena expr 槽；无效 ref 返回 NULL。 */
static struct ast_Expr *glue_arena_expr_at_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return NULL;
  return pipeline_arena_expr_ptr(a, expr_ref);
}

/** 读 struct_lit 字段数；避免 SU 内 `let e: Expr = ast_arena_expr_get` 后字段访问 typeck 失败。 */
int32_t pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->struct_lit_num_fields : 0;
}

/** 读 struct_lit 类型名长度。 */
int32_t pipeline_expr_struct_lit_type_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->struct_lit_struct_name_len : 0;
}

/** memcpy struct_lit 类型名到 out64。 */
void pipeline_expr_struct_lit_type_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, ex->struct_lit_struct_name, 64);
}

/** struct_lit 字段名/init 读 API 见 ast_pool.c（侧车池）。 */

/** 读 expr.kind 序数；无效 ref 返回 -1。 */
int32_t pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref) {
  enum ast_ExprKind kd;
  if (!a || expr_ref <= 0 || expr_ref > a->num_exprs)
    return -1;
  kd = glue_arena_expr_kind_at_ref(a, expr_ref);
  return (int32_t)kd;
}

/**
 * 读 expr.unary_operand_ref；无效 ref 返回 0。
 * typeck.su check_block_impl 块末 `return;` 判定须用此 glue，勿 `let fin_ex: Expr = ast_arena_expr_get` 再读字段（自举 asm FIELD_ACCESS 失败）。
 */
int32_t pipeline_expr_unary_operand_ref_at(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->unary_operand_ref : 0;
}

/** FIELD_ACCESS 字段名 memcpy 到 out64。 */
void pipeline_expr_field_access_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, ex->field_access_field_name, 64);
}

/** FIELD_ACCESS 字段名长度；非 FIELD_ACCESS 或无效 ref 返回 0。 */
int32_t pipeline_expr_field_access_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_field_len;
}

/** FIELD_ACCESS base_ref；非 FIELD_ACCESS 返回 0。 */
int32_t pipeline_expr_field_access_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_FIELD_ACCESS)
    return 0;
  return ex->field_access_base_ref;
}

/** EXPR_VAR 变量名 memcpy 到 out64。 */
void pipeline_expr_var_name_into(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *out64) {
  struct ast_Expr *ex;
  if (!out64)
    return;
  ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex) {
    memset(out64, 0, 64);
    return;
  }
  memcpy(out64, ex->var_name, 64);
}

/** EXPR_VAR 名长度；非 VAR 或无效 ref 返回 0。 */
int32_t pipeline_expr_var_name_len(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  if (!ex || ex->kind != ast_ExprKind_EXPR_VAR)
    return 0;
  return ex->var_name_len;
}

static enum ast_TypeKind glue_type_kind_from_ord(int32_t ord) {
  if (ord < 0 || ord > 15)
    return ast_TypeKind_TYPE_I32;
  return (enum ast_TypeKind)ord;
}

/** 查找或分配仅含 kind 的 primitive type；避免 SU 内 ti.kind = TypeKind.* assignment typeck 失败。 */
int32_t pipeline_type_ensure_by_kind_ord(struct ast_ASTArena *a, int32_t kind_ord) {
  int32_t k;
  enum ast_TypeKind kind;
  struct ast_Type *t;
  if (!a || kind_ord < 0 || kind_ord > 15)
    return 0;
  kind = glue_type_kind_from_ord(kind_ord);
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == kind && t->name_len == 0 && t->elem_type_ref == 0 && t->array_size == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = kind;
  return k;
}

/** 查找或分配 TYPE_NAMED；name 经 memcpy 写入，避免 SU 对 Type 局部副本写字段。 */
int32_t pipeline_type_find_or_alloc_named(struct ast_ASTArena *a, uint8_t *name, int32_t name_len) {
  int32_t k;
  struct ast_Type *t;
  if (!a || !name || name_len <= 0 || name_len > 63)
    return 0;
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == ast_TypeKind_TYPE_NAMED && t->name_len == name_len &&
        memcmp(t->name, name, (size_t)name_len) == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = ast_TypeKind_TYPE_NAMED;
  t->name_len = name_len;
  memcpy(t->name, name, (size_t)name_len);
  return k;
}

/** 查找或分配 PTR/ARRAY/SLICE/VECTOR 等复合 type；kind_ord 与 type_kind_ordinal 一致。 */
int32_t pipeline_type_find_or_alloc_compound(struct ast_ASTArena *a, int32_t kind_ord, int32_t elem_ref,
                                             int32_t array_size) {
  int32_t k;
  enum ast_TypeKind kind;
  struct ast_Type *t;
  if (!a || kind_ord < 0 || kind_ord > 15)
    return 0;
  kind = glue_type_kind_from_ord(kind_ord);
  for (k = 1; k <= a->num_types; k++) {
    t = pipeline_arena_type_ptr(a, k);
    if (t && t->kind == kind && t->elem_type_ref == elem_ref && t->array_size == array_size && t->name_len == 0)
      return k;
  }
  k = pipeline_arena_type_alloc(a);
  if (k <= 0)
    return 0;
  t = pipeline_arena_type_ptr(a, k);
  if (!t)
    return 0;
  memset(t, 0, sizeof(*t));
  t->kind = kind;
  t->elem_type_ref = elem_ref;
  t->array_size = array_size;
  return k;
}

/**
 * backend.su get_return_expr_ref：在 C 内读 Block/LabeledStmt/Expr 池，避免 SU 自举 asm 对
 * stmt.is_goto / block.final_expr_ref 等 struct 字段 FIELD_ACCESS codegen 失败（fail_at=55）。
 */
int32_t pipeline_backend_get_return_expr_ref(struct ast_ASTArena *a, struct ast_Func *f) {
  struct ast_Block *blk;
  int32_t j;
  int32_t ei;
  if (!a || !f || f->body_ref <= 0 || f->body_ref > a->num_blocks)
    return 0;
  blk = pipeline_arena_block_ptr(a, f->body_ref);
  j = 0;
  while (blk && j < blk->num_labeled_stmts) {
    int32_t ret_ref = pipeline_block_labeled_return_expr_ref(a, f->body_ref, j);
    if (ret_ref != 0)
      return ret_ref;
    j++;
  }
  if (blk && blk->final_expr_ref != 0) {
    struct ast_Expr *e;
    if (blk->final_expr_ref <= 0 || blk->final_expr_ref > a->num_exprs)
      return blk->final_expr_ref;
    e = pipeline_arena_expr_ptr(a, blk->final_expr_ref);
    if (e && e->kind == ast_ExprKind_EXPR_RETURN && e->unary_operand_ref != 0)
      return e->unary_operand_ref;
    return blk->final_expr_ref;
  }
  if (!blk)
    return 0;
  ei = blk->num_expr_stmts - 1;
  while (ei >= 0) {
    int32_t ers = pipeline_block_expr_stmt_ref(a, f->body_ref, ei);
    if (ers != 0 && ers > 0 && ers <= a->num_exprs) {
      struct ast_Expr *es = pipeline_arena_expr_ptr(a, ers);
      if (es && es->kind == ast_ExprKind_EXPR_RETURN) {
        if (es->unary_operand_ref != 0)
          return es->unary_operand_ref;
        return 0;
      }
    }
    ei--;
  }
  return 0;
}

/** backend.su get_return_expr_ref：按 module 下标在 C 内读 Func.body_ref，勿传 SU 侧按值拷贝的 *Func。 */
int32_t pipeline_backend_get_return_expr_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                                int32_t func_index) {
  struct ast_Func *f;
  if (!a || !m || func_index < 0 || func_index >= (int32_t)m->num_funcs)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return 0;
  return pipeline_backend_get_return_expr_ref(a, f);
}

/**
 * arm64.su get_return_lit_ref：同上，最小集返回值 ref 查找。
 */
int32_t pipeline_arm64_get_return_lit_ref(struct ast_ASTArena *a, struct ast_Func *f) {
  struct ast_Block *blk;
  struct ast_Expr *e;
  struct ast_Expr *inner;
  if (!a || !f || f->body_ref <= 0 || f->body_ref > a->num_blocks)
    return 0;
  blk = pipeline_arena_block_ptr(a, f->body_ref);
  if (!blk || blk->final_expr_ref <= 0 || blk->final_expr_ref > a->num_exprs)
    return 0;
  e = pipeline_arena_expr_ptr(a, blk->final_expr_ref);
  if (!e)
    return 0;
  if (e->kind == ast_ExprKind_EXPR_LIT || e->kind == ast_ExprKind_EXPR_BOOL_LIT)
    return blk->final_expr_ref;
  if (e->kind == ast_ExprKind_EXPR_RETURN && e->unary_operand_ref != 0) {
    if (e->unary_operand_ref <= 0 || e->unary_operand_ref > a->num_exprs)
      return 0;
    inner = pipeline_arena_expr_ptr(a, e->unary_operand_ref);
    if (inner && (inner->kind == ast_ExprKind_EXPR_LIT || inner->kind == ast_ExprKind_EXPR_BOOL_LIT))
      return e->unary_operand_ref;
  }
  return 0;
}

/** arm64.su get_return_lit_ref：按 module 下标在 C 内读 Func.body_ref。 */
int32_t pipeline_arm64_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                             int32_t func_index) {
  struct ast_Func *f;
  if (!a || !m || func_index < 0 || func_index >= (int32_t)m->num_funcs)
    return 0;
  if (func_index >= (int32_t)m->num_funcs)
    return 0;
  f = pipeline_module_func_ptr(m, func_index);
  if (!f)
    return 0;
  return pipeline_arm64_get_return_lit_ref(a, f);
}

/** INDEX 元素字节宽；避免 backend.su asm_index_elem_byte_sz 内 Type 局部副本自举 asm 失败。 */
int32_t pipeline_asm_index_elem_byte_sz(struct ast_ASTArena *a, int32_t index_expr_ref) {
  struct ast_Expr *ix;
  int32_t tr;
  enum ast_TypeKind k;
  if (!a || index_expr_ref <= 0 || index_expr_ref > a->num_exprs)
    return 4;
  ix = pipeline_arena_expr_ptr(a, index_expr_ref);
  if (!ix)
    return 4;
  tr = ix->resolved_type_ref;
  if (tr <= 0 || tr > a->num_types)
    return 4;
  {
    struct ast_Type *tp = pipeline_arena_type_ptr(a, tr);
    if (!tp)
      return 4;
    k = tp->kind;
  }
  if (k == ast_TypeKind_TYPE_U8)
    return 1;
  if (k == ast_TypeKind_TYPE_PTR || k == ast_TypeKind_TYPE_I64 || k == ast_TypeKind_TYPE_U64 ||
      k == ast_TypeKind_TYPE_USIZE || k == ast_TypeKind_TYPE_ISIZE || k == ast_TypeKind_TYPE_F64)
    return 8;
  return 4;
}

/** EXPR 池槽 index_base_ref / index_index_ref / resolved_type_ref / field_access_*。 */
int32_t pipeline_expr_index_base_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_base_ref : 0;
}

int32_t pipeline_expr_index_index_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->index_index_ref : 0;
}

int32_t pipeline_expr_resolved_type_ref(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->resolved_type_ref : 0;
}

int32_t pipeline_expr_field_access_offset(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_offset : 0;
}

int32_t pipeline_expr_field_access_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref) {
  struct ast_Expr *ex = glue_arena_expr_at_ref(a, expr_ref);
  return ex ? ex->field_access_is_enum_variant : 0;
}

/** backend.su 专用：避免 extern pipeline_type_kind_ord_at 被链接器解析为 codegen_ 前缀。 */
int32_t pipeline_backend_type_kind_ord_at(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_type_kind_ord_at(a, ref);
}

/**
 * backend.su asm 主循环 / fill_param_slots：仅 backend 模块声明 extern，转发至无前缀 pipeline_module_func_*，
 * 避免经 codegen import 产生 codegen_ 前缀未定义符号。
 */
int32_t pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_is_extern_at(m, func_index);
}

int32_t pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_body_ref_at(m, func_index);
}

int32_t pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_name_len_at(m, func_index);
}

void pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index, uint8_t *dst) {
  pipeline_module_func_name_copy64(m, func_index, dst);
}

int32_t pipeline_asm_module_func_num_params_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_num_params_at(m, func_index);
}

int32_t pipeline_asm_module_func_param_name_len_at(struct ast_Module *m, int32_t func_index,
                                                    int32_t param_index) {
  return pipeline_module_func_param_name_len_at(m, func_index, param_index);
}

void pipeline_asm_module_func_param_name_copy32(struct ast_Module *m, int32_t func_index,
                                                int32_t param_index, uint8_t *dst) {
  pipeline_module_func_param_name_copy32(m, func_index, param_index, dst);
}

int32_t pipeline_asm_get_return_expr_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                            int32_t func_index) {
  return pipeline_backend_get_return_expr_ref_at(a, m, func_index);
}

int32_t pipeline_asm_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                            int32_t func_index) {
  return pipeline_arm64_get_return_lit_ref_at(a, m, func_index);
}

/** build_asm/arm64.o 单模块编译时 arm64 模块前缀转发（与 backend 同源 glue）。 */
int32_t arch_arm64_pipeline_asm_module_func_is_extern_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_is_extern_at(m, func_index);
}

int32_t arch_arm64_pipeline_asm_module_func_body_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_body_ref_at(m, func_index);
}

int32_t arch_arm64_pipeline_asm_module_func_name_len_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_asm_module_func_name_len_at(m, func_index);
}

void arch_arm64_pipeline_asm_module_func_name_copy64(struct ast_Module *m, int32_t func_index,
                                                     uint8_t *dst) {
  pipeline_asm_module_func_name_copy64(m, func_index, dst);
}

int32_t arch_arm64_pipeline_asm_get_return_lit_ref_at(struct ast_ASTArena *a, struct ast_Module *m,
                                                      int32_t func_index) {
  return pipeline_asm_get_return_lit_ref_at(a, m, func_index);
}

#include "ast_pool.c"

/*
 * ast.su 中 extern pipeline_* 经 codegen 调用时带 ast_ 模块前缀（如 ast_pipeline_block_append_if），
 * 实现体在 ast_pool.c 为无前缀 C 符号；此处转发以满足链接。
 */
int32_t ast_pipeline_module_func_alloc_slot(struct ast_Module *m) {
  return pipeline_module_func_alloc_slot(m);
}
void ast_pipeline_module_func_ref_set(struct ast_Module *m, int32_t fi, int32_t func_ref) {
  pipeline_module_func_ref_set(m, fi, func_ref);
}
void ast_pipeline_module_func_set_return_type(struct ast_Module *m, int32_t fi, int32_t type_ref) {
  pipeline_module_func_set_return_type(m, fi, type_ref);
}
void ast_pipeline_module_func_set_body_ref(struct ast_Module *m, int32_t fi, int32_t body_ref) {
  pipeline_module_func_set_body_ref(m, fi, body_ref);
}
void ast_pipeline_module_func_set_body_expr_ref(struct ast_Module *m, int32_t fi, int32_t body_expr_ref) {
  pipeline_module_func_set_body_expr_ref(m, fi, body_expr_ref);
}
void ast_pipeline_module_func_set_is_extern(struct ast_Module *m, int32_t fi, int32_t is_extern) {
  pipeline_module_func_set_is_extern(m, fi, is_extern);
}
void ast_pipeline_module_func_set_num_params(struct ast_Module *m, int32_t fi, int32_t n) {
  pipeline_module_func_set_num_params(m, fi, n);
}
int32_t ast_pipeline_module_func_return_type_at(struct ast_Module *m, int32_t fi) {
  return pipeline_module_func_return_type_at(m, fi);
}
int32_t ast_pipeline_module_func_name_equal_at(struct ast_Module *m, int32_t fi, uint8_t *name, int32_t name_len) {
  return pipeline_module_func_name_equal_at(m, fi, name, name_len);
}
uint8_t ast_pipeline_module_func_name_byte_at(struct ast_Module *m, int32_t fi, int32_t i) {
  return pipeline_module_func_name_byte_at(m, fi, i);
}
int32_t ast_pipeline_module_func_body_expr_ref_at(struct ast_Module *m, int32_t fi) {
  return pipeline_module_func_body_expr_ref_at(m, fi);
}
int32_t ast_pipeline_ctx_append_lib_root(struct ast_PipelineDepCtx *ctx, uint8_t *path, int32_t len) {
  return pipeline_ctx_append_lib_root(ctx, path, len);
}
void ast_pipeline_dep_ctx_reset(struct ast_PipelineDepCtx *ctx) {
  pipeline_dep_ctx_reset(ctx);
}
/** ast.su extern pipeline_dep_ctx_*；typeck 经 ast_pipeline_* 前缀调用（ast_pool.c 实现 pipeline_*）。 */
int32_t ast_pipeline_dep_ctx_ndep(struct ast_PipelineDepCtx *ctx) {
  return pipeline_dep_ctx_ndep(ctx);
}
struct ast_Module *ast_pipeline_dep_ctx_module_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_module_at(ctx, idx);
}
struct ast_ASTArena *ast_pipeline_dep_ctx_arena_at(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_arena_at(ctx, idx);
}
void ast_pipeline_dep_ctx_set_module(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_Module *m) {
  pipeline_dep_ctx_set_module(ctx, idx, m);
}
void ast_pipeline_dep_ctx_set_arena(struct ast_PipelineDepCtx *ctx, int32_t idx, struct ast_ASTArena *a) {
  pipeline_dep_ctx_set_arena(ctx, idx, a);
}
void ast_pipeline_dep_ctx_set_ndep(struct ast_PipelineDepCtx *ctx, int32_t n) {
  pipeline_dep_ctx_set_ndep(ctx, n);
}
void ast_pipeline_dep_ctx_set_import_path(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_dep_ctx_set_import_path(ctx, idx, bytes, len);
}
int32_t ast_pipeline_dep_ctx_import_path_len(struct ast_PipelineDepCtx *ctx, int32_t idx) {
  return pipeline_dep_ctx_import_path_len(ctx, idx);
}
void ast_pipeline_dep_ctx_import_path_copy64(struct ast_PipelineDepCtx *ctx, int32_t idx, uint8_t *dst) {
  pipeline_dep_ctx_import_path_copy64(ctx, idx, dst);
}
int32_t ast_pipeline_ctx_lib_root_count(struct ast_PipelineDepCtx *ctx) {
  return pipeline_ctx_lib_root_count(ctx);
}
int32_t ast_pipeline_ctx_lib_root_len(struct ast_PipelineDepCtx *ctx, int32_t i) {
  return pipeline_ctx_lib_root_len(ctx, i);
}
void ast_pipeline_ctx_lib_root_copy(struct ast_PipelineDepCtx *ctx, int32_t i, uint8_t *dst, int32_t cap) {
  pipeline_ctx_lib_root_copy(ctx, i, dst, cap);
}
int32_t ast_pipeline_block_append_const(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                        int32_t type_ref, int32_t init_ref) {
  return pipeline_block_append_const(a, br, name, name_len, type_ref, init_ref);
}
int32_t ast_pipeline_block_append_let(struct ast_ASTArena *a, int32_t br, uint8_t *name, int32_t name_len,
                                      int32_t type_ref, int32_t init_ref) {
  return pipeline_block_append_let(a, br, name, name_len, type_ref, init_ref);
}
int32_t ast_pipeline_block_append_if(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t then_ref,
                                     int32_t else_ref) {
  return pipeline_block_append_if(a, br, cond_ref, then_ref, else_ref);
}
int32_t ast_pipeline_block_append_while(struct ast_ASTArena *a, int32_t br, int32_t cond_ref, int32_t body_ref) {
  return pipeline_block_append_while(a, br, cond_ref, body_ref);
}
int32_t ast_pipeline_block_append_for(struct ast_ASTArena *a, int32_t br, int32_t init_ref, int32_t cond_ref,
                                      int32_t step_ref, int32_t body_ref) {
  return pipeline_block_append_for(a, br, init_ref, cond_ref, step_ref, body_ref);
}
int32_t ast_pipeline_module_import_alloc(struct ast_Module *m) {
  return pipeline_module_import_alloc(m);
}
void ast_pipeline_module_import_set_path(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_import_set_path(m, idx, bytes, len);
}
void ast_pipeline_module_import_set_kind(struct ast_Module *m, int32_t idx, int32_t kind) {
  pipeline_module_import_set_kind(m, idx, kind);
}
void ast_pipeline_module_import_set_binding_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_import_set_binding_name(m, idx, bytes, len);
}
void ast_pipeline_module_import_set_select_count(struct ast_Module *m, int32_t idx, int32_t n) {
  pipeline_module_import_set_select_count(m, idx, n);
}
void ast_pipeline_module_import_path_copy(struct ast_Module *m, int32_t idx, uint8_t *dst, int32_t dst_cap) {
  pipeline_module_import_path_copy(m, idx, dst, dst_cap);
}
int32_t ast_pipeline_module_enum_alloc(struct ast_Module *m) {
  return pipeline_module_enum_alloc(m);
}
void ast_pipeline_module_enum_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_enum_set_name(m, idx, bytes, len);
}
int32_t ast_pipeline_module_top_level_let_alloc(struct ast_Module *m) {
  return pipeline_module_top_level_let_alloc(m);
}
void ast_pipeline_module_top_level_let_set(struct ast_Module *m, int32_t idx, uint8_t *name, int32_t name_len,
                                           int32_t type_ref, int32_t init_ref, int32_t is_const) {
  pipeline_module_top_level_let_set(m, idx, name, name_len, type_ref, init_ref, is_const);
}
int32_t ast_pipeline_module_import_path_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_path_len(m, idx);
}
uint8_t ast_pipeline_module_import_path_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_import_path_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_import_kind_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_kind_at(m, idx);
}
int32_t ast_pipeline_module_import_binding_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_binding_name_len(m, idx);
}
uint8_t ast_pipeline_module_import_binding_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_import_binding_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_import_select_count_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_import_select_count_at(m, idx);
}
int32_t ast_pipeline_module_import_select_name_len(struct ast_Module *m, int32_t idx, int32_t sel) {
  return pipeline_module_import_select_name_len(m, idx, sel);
}
uint8_t ast_pipeline_module_import_select_name_byte_at(struct ast_Module *m, int32_t idx, int32_t sel, int32_t off) {
  return pipeline_module_import_select_name_byte_at(m, idx, sel, off);
}
int32_t ast_pipeline_module_struct_layout_alloc(struct ast_Module *m) {
  return pipeline_module_struct_layout_alloc(m);
}
void ast_pipeline_module_struct_layout_reset_slot(struct ast_Module *m, int32_t idx) {
  pipeline_module_struct_layout_reset_slot(m, idx);
}
void ast_pipeline_module_struct_layout_set_name(struct ast_Module *m, int32_t idx, uint8_t *bytes, int32_t len) {
  pipeline_module_struct_layout_set_name(m, idx, bytes, len);
}
void ast_pipeline_module_struct_layout_set_field(struct ast_Module *m, int32_t li, int32_t j, uint8_t *fname_bytes,
                                                 int32_t fname_len, int32_t ftype_ref, int32_t foff) {
  pipeline_module_struct_layout_set_field(m, li, j, fname_bytes, fname_len, ftype_ref, foff);
}
void ast_pipeline_module_struct_layout_set_num_fields(struct ast_Module *m, int32_t idx, int32_t nf) {
  pipeline_module_struct_layout_set_num_fields(m, idx, nf);
}
int32_t ast_pipeline_module_struct_layout_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_name_len(m, idx);
}
void ast_pipeline_module_struct_layout_name_into(struct ast_Module *m, int32_t idx, uint8_t *out64) {
  pipeline_module_struct_layout_name_into(m, idx, out64);
}
uint8_t ast_pipeline_module_struct_layout_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_struct_layout_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_struct_layout_num_fields(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_num_fields(m, idx);
}
int32_t ast_pipeline_module_struct_layout_field_name_len(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_name_len(m, li, j);
}
void ast_pipeline_module_struct_layout_field_name_into(struct ast_Module *m, int32_t li, int32_t j, uint8_t *out64) {
  pipeline_module_struct_layout_field_name_into(m, li, j, out64);
}
int32_t ast_pipeline_module_struct_layout_field_type_ref(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_type_ref(m, li, j);
}
int32_t ast_pipeline_module_struct_layout_field_offset_at(struct ast_Module *m, int32_t li, int32_t j) {
  return pipeline_module_struct_layout_field_offset_at(m, li, j);
}
void ast_pipeline_module_struct_layout_set_allow_padding(struct ast_Module *m, int32_t idx, int32_t v) {
  pipeline_module_struct_layout_set_allow_padding(m, idx, v);
}
int32_t ast_pipeline_module_struct_layout_allow_padding_at(struct ast_Module *m, int32_t idx) {
  return pipeline_module_struct_layout_allow_padding_at(m, idx);
}
int32_t ast_pipeline_module_top_level_let_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_name_len(m, idx);
}
uint8_t ast_pipeline_module_top_level_let_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_top_level_let_name_byte_at(m, idx, off);
}
int32_t ast_pipeline_module_top_level_let_type_ref(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_type_ref(m, idx);
}
int32_t ast_pipeline_module_top_level_let_init_ref(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_init_ref(m, idx);
}
int32_t ast_pipeline_module_top_level_let_is_const(struct ast_Module *m, int32_t idx) {
  return pipeline_module_top_level_let_is_const(m, idx);
}
int32_t ast_pipeline_module_enum_name_len(struct ast_Module *m, int32_t idx) {
  return pipeline_module_enum_name_len(m, idx);
}
uint8_t ast_pipeline_module_enum_name_byte_at(struct ast_Module *m, int32_t idx, int32_t off) {
  return pipeline_module_enum_name_byte_at(m, idx, off);
}
void ast_ast_pool_onefunc_reset(uint8_t *out) {
  ast_pool_onefunc_reset(out);
}
int32_t ast_pipeline_onefunc_num_consts(uint8_t *out) {
  return pipeline_onefunc_num_consts(out);
}
int32_t ast_pipeline_onefunc_num_lets(uint8_t *out) {
  return pipeline_onefunc_num_lets(out);
}
int32_t ast_pipeline_onefunc_num_whiles(uint8_t *out) {
  return pipeline_onefunc_num_whiles(out);
}
int32_t ast_pipeline_onefunc_num_fors(uint8_t *out) {
  return pipeline_onefunc_num_fors(out);
}
int32_t ast_pipeline_onefunc_const_name_len(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_name_len(out, i);
}
void ast_pipeline_onefunc_const_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  pipeline_onefunc_const_name_copy64(out, i, dst);
}
int32_t ast_pipeline_onefunc_const_init_val(uint8_t *out, int32_t i) {
  return pipeline_onefunc_const_init_val(out, i);
}
int32_t ast_pipeline_onefunc_let_name_len(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_name_len(out, i);
}
void ast_pipeline_onefunc_let_name_copy64(uint8_t *out, int32_t i, uint8_t *dst) {
  pipeline_onefunc_let_name_copy64(out, i, dst);
}
int32_t ast_pipeline_onefunc_let_init_val(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_init_val(out, i);
}
int32_t ast_pipeline_onefunc_let_init_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_init_ref(out, i);
}
int32_t ast_pipeline_onefunc_let_type_ref(uint8_t *out, int32_t i) {
  return pipeline_onefunc_let_type_ref(out, i);
}
int32_t ast_pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val, int32_t init_ref,
                                        int32_t type_ref) {
  return pipeline_onefunc_append_let(out, name, name_len, init_val, init_ref, type_ref);
}
int32_t ast_pipeline_onefunc_append_while(uint8_t *out, int32_t cond_ref, int32_t body_ref) {
  return pipeline_onefunc_append_while(out, cond_ref, body_ref);
}
int32_t ast_pipeline_onefunc_append_for(uint8_t *out, int32_t init_ref, int32_t cond_ref, int32_t step_ref,
                                        int32_t body_ref) {
  return pipeline_onefunc_append_for(out, init_ref, cond_ref, step_ref, body_ref);
}
void ast_pipeline_onefunc_copy_sidecar(uint8_t *dst, uint8_t *src) {
  pipeline_onefunc_copy_sidecar(dst, src);
}
int32_t ast_pipeline_block_append_expr_stmt(struct ast_ASTArena *a, int32_t br, int32_t expr_ref) {
  return pipeline_block_append_expr_stmt(a, br, expr_ref);
}
int32_t ast_pipeline_block_append_stmt_order(struct ast_ASTArena *a, int32_t br, uint8_t kind, int32_t idx) {
  return pipeline_block_append_stmt_order(a, br, kind, idx);
}
int32_t ast_pipeline_block_append_labeled(struct ast_ASTArena *a, int32_t br, int32_t label_len, int32_t is_goto,
                                           int32_t goto_target_len, int32_t return_expr_ref) {
  return pipeline_block_append_labeled(a, br, label_len, is_goto, goto_target_len, return_expr_ref);
}
int32_t ast_pipeline_block_labeled_return_expr_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_labeled_return_expr_ref(a, br, li);
}
void ast_pipeline_block_fill_ifs_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_ifs_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_whiles_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_whiles_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_fors_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_fors_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_stmt_order_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_stmt_order_from_onefunc(a, br, out, count);
}
void ast_pipeline_block_fill_expr_stmts_from_onefunc(struct ast_ASTArena *a, int32_t br, uint8_t *out, int32_t count) {
  pipeline_block_fill_expr_stmts_from_onefunc(a, br, out, count);
}
int32_t ast_pipeline_block_const_init_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_init_ref(a, br, ci);
}
int32_t ast_pipeline_block_const_type_ref(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_type_ref(a, br, ci);
}
int32_t ast_pipeline_block_let_init_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_init_ref(a, br, li);
}
int32_t ast_pipeline_block_let_type_ref(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_type_ref(a, br, li);
}
int32_t ast_pipeline_block_expr_stmt_ref(struct ast_ASTArena *a, int32_t br, int32_t ei) {
  return pipeline_block_expr_stmt_ref(a, br, ei);
}
uint8_t ast_pipeline_block_stmt_order_kind(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_kind(a, br, si);
}
int32_t ast_pipeline_block_stmt_order_idx(struct ast_ASTArena *a, int32_t br, int32_t si) {
  return pipeline_block_stmt_order_idx(a, br, si);
}
int32_t ast_pipeline_block_if_cond_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_cond_ref(a, br, ii);
}
int32_t ast_pipeline_block_if_then_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_then_body_ref(a, br, ii);
}
int32_t ast_pipeline_block_if_else_body_ref(struct ast_ASTArena *a, int32_t br, int32_t ii) {
  return pipeline_block_if_else_body_ref(a, br, ii);
}
int32_t ast_pipeline_block_const_name_len(struct ast_ASTArena *a, int32_t br, int32_t ci) {
  return pipeline_block_const_name_len(a, br, ci);
}
void ast_pipeline_block_const_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t ci, uint8_t *dst) {
  pipeline_block_const_name_copy64(a, br, ci, dst);
}
int32_t ast_pipeline_block_let_name_len(struct ast_ASTArena *a, int32_t br, int32_t li) {
  return pipeline_block_let_name_len(a, br, li);
}
void ast_pipeline_block_let_name_copy64(struct ast_ASTArena *a, int32_t br, int32_t li, uint8_t *dst) {
  pipeline_block_let_name_copy64(a, br, li, dst);
}
int32_t ast_pipeline_block_resolve_var_type_ref(struct ast_ASTArena *a, int32_t block_ref, uint8_t *vname,
                                                 int32_t vlen) {
  return pipeline_block_resolve_var_type_ref(a, block_ref, vname, vlen);
}
int32_t ast_pipeline_module_func_ref_at(struct ast_Module *m, int32_t func_index) {
  return pipeline_module_func_ref_at(m, func_index);
}
int32_t ast_pipeline_arena_type_cap(void) { return pipeline_arena_type_cap(); }
int32_t ast_pipeline_arena_expr_cap(void) { return pipeline_arena_expr_cap(); }
int32_t ast_pipeline_arena_block_cap(void) { return pipeline_arena_block_cap(); }
int32_t ast_pipeline_arena_func_cap(void) { return pipeline_arena_func_cap(); }
int32_t ast_pipeline_arena_type_alloc(struct ast_ASTArena *a) { return pipeline_arena_type_alloc(a); }
int32_t ast_pipeline_arena_expr_alloc(struct ast_ASTArena *a) { return pipeline_arena_expr_alloc(a); }
int32_t ast_pipeline_arena_block_alloc(struct ast_ASTArena *a) { return pipeline_arena_block_alloc(a); }
int32_t ast_pipeline_arena_func_alloc(struct ast_ASTArena *a) { return pipeline_arena_func_alloc(a); }

/**
 * ast.su 中 ast_arena_*_get/set 仅作 extern 声明；实现在此，避免 shu-c -E 将 get 错误 lowering 为
 * arena->exprs[] / blocks[] 直访（slim ASTArena 已无内嵌数组）。
 * ast_ast_arena_* 供 ast 模块 hoisted 声明；ast_arena_* 供 import ast 的其他模块链接。
 */
struct ast_Type ast_ast_arena_type_get(struct ast_ASTArena *a, int32_t ref) {
  struct ast_Type empty;
  if (ref <= 0) {
    memset(&empty, 0, sizeof(empty));
    return empty;
  }
  return pipeline_arena_type_get_copy(a, ref);
}
void ast_ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}
struct ast_Expr ast_ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}
void ast_ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  pipeline_arena_expr_set_copy(a, ref, e);
}
struct ast_Block ast_ast_arena_block_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
void ast_ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
struct ast_Func ast_ast_arena_func_get(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
void ast_ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}
struct ast_Type ast_arena_type_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_type_get(a, ref);
}
void ast_arena_type_set(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  ast_ast_arena_type_set(a, ref, t);
}
struct ast_Expr ast_arena_expr_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_expr_get(a, ref);
}
void ast_arena_expr_set(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  ast_ast_arena_expr_set(a, ref, e);
}
struct ast_Block ast_arena_block_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_block_get(a, ref);
}
void ast_arena_block_set(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  ast_ast_arena_block_set(a, ref, b);
}
struct ast_Func ast_arena_func_get(struct ast_ASTArena *a, int32_t ref) {
  return ast_ast_arena_func_get(a, ref);
}
void ast_arena_func_set(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  ast_ast_arena_func_set(a, ref, f);
}

struct ast_Type ast_pipeline_arena_type_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_type_get_copy(a, ref);
}
void ast_pipeline_arena_type_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Type t) {
  pipeline_arena_type_set_copy(a, ref, t);
}
struct ast_Expr ast_pipeline_arena_expr_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_expr_get_copy(a, ref);
}
void ast_pipeline_arena_expr_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Expr e) {
  pipeline_arena_expr_set_copy(a, ref, e);
}
struct ast_Block ast_pipeline_arena_block_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_block_get_copy(a, ref);
}
void ast_pipeline_arena_block_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Block b) {
  pipeline_arena_block_set_copy(a, ref, b);
}
struct ast_Func ast_pipeline_arena_func_get_copy(struct ast_ASTArena *a, int32_t ref) {
  return pipeline_arena_func_get_copy(a, ref);
}
void ast_pipeline_arena_func_set_copy(struct ast_ASTArena *a, int32_t ref, struct ast_Func f) {
  pipeline_arena_func_set_copy(a, ref, f);
}

int32_t codegen_pipeline_module_func_param_type_ref_at(struct ast_Module *m, int32_t func_index,
                                                       int32_t param_index) {
  return pipeline_module_func_param_type_ref_at(m, func_index, param_index);
}

/** ast.su / typeck / codegen / backend / parser 经 import 前缀调用的 Expr 侧车池符号转发。 */
int32_t ast_pipeline_expr_append_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_call_arg(a, expr_ref, arg_ref);
}
int32_t ast_pipeline_expr_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_call_num_args_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_call_num_args_at(a, expr_ref);
}
int32_t ast_pipeline_expr_append_method_call_arg(struct ast_ASTArena *a, int32_t expr_ref, int32_t arg_ref) {
  return pipeline_expr_append_method_call_arg(a, expr_ref, arg_ref);
}
int32_t ast_pipeline_expr_method_call_arg_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_method_call_arg_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_append_match_arm(struct ast_ASTArena *a, int32_t expr_ref, int32_t result_ref,
                                           int32_t is_wildcard, int32_t lit_val, int32_t is_enum_variant,
                                           int32_t variant_index) {
  return pipeline_expr_append_match_arm(a, expr_ref, result_ref, is_wildcard, lit_val, is_enum_variant,
                                        variant_index);
}
int32_t ast_pipeline_expr_match_num_arms_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_match_num_arms_at(a, expr_ref);
}
int32_t ast_pipeline_expr_match_arm_result_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_result_ref(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_wildcard(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_lit_val(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_is_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_is_enum_variant(a, expr_ref, i);
}
int32_t ast_pipeline_expr_match_arm_variant_index(struct ast_ASTArena *a, int32_t expr_ref, int32_t i) {
  return pipeline_expr_match_arm_variant_index(a, expr_ref, i);
}
void ast_pipeline_expr_match_arm_set_wildcard(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_wildcard(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_lit_val(struct ast_ASTArena *a, int32_t expr_ref, int32_t i, int32_t v) {
  pipeline_expr_match_arm_set_lit_val(a, expr_ref, i, v);
}
void ast_pipeline_expr_match_arm_set_enum_variant(struct ast_ASTArena *a, int32_t expr_ref, int32_t i,
                                                  int32_t is_var, int32_t variant_index) {
  pipeline_expr_match_arm_set_enum_variant(a, expr_ref, i, is_var, variant_index);
}
int32_t ast_pipeline_expr_append_struct_lit_field(struct ast_ASTArena *a, int32_t expr_ref, uint8_t *name_bytes,
                                                  int32_t name_len, int32_t init_ref) {
  return pipeline_expr_append_struct_lit_field(a, expr_ref, name_bytes, name_len, init_ref);
}
int32_t ast_pipeline_expr_append_array_lit_elem(struct ast_ASTArena *a, int32_t expr_ref, int32_t elem_ref) {
  return pipeline_expr_append_array_lit_elem(a, expr_ref, elem_ref);
}
int32_t ast_pipeline_expr_array_lit_elem_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t idx) {
  return pipeline_expr_array_lit_elem_ref(a, expr_ref, idx);
}
int32_t ast_pipeline_expr_array_lit_num_elems_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_array_lit_num_elems_at(a, expr_ref);
}
int32_t ast_pipeline_module_import_append_select_name(struct ast_Module *m, int32_t idx, uint8_t *bytes,
                                                      int32_t len) {
  return pipeline_module_import_append_select_name(m, idx, bytes, len);
}

/** backend import codegen 时 struct_lit glue 带 codegen_ 前缀。 */
int32_t codegen_pipeline_expr_kind_ord_at(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_kind_ord_at(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t codegen_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}
int32_t backend_pipeline_expr_struct_lit_num_fields(struct ast_ASTArena *a, int32_t expr_ref) {
  return pipeline_expr_struct_lit_num_fields(a, expr_ref);
}
int32_t backend_pipeline_expr_struct_lit_init_ref(struct ast_ASTArena *a, int32_t expr_ref, int32_t j) {
  return pipeline_expr_struct_lit_init_ref(a, expr_ref, j);
}
