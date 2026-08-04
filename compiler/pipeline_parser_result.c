/**
 * pipeline_parser_result.c — Parser result copy/lex/slice helper domain (BC 8.3.1).
 *
 * Same-TU #include from pipeline_glue.c (itself #include'd into pipeline_gen.c
 * via -E / build_patch). Not a separate .o.
 *
 * Domain (parser result C sidecars for X typeck/codegen gaps):
 * - parser_slice_from_buf / lexer_parser_slice_from_buf / pipeline_source_slice
 *   (slice construction from (data, len) — avoids -E parser_* symbol double-prefix)
 * - parser_lexer_pos_before (usize backtrack — asm typecheck usize/i32 mix fail)
 * - parser_lex_from_lexer_result_ptr_into / _val_into (LexerResult.next_lex → *Lexer)
 * - parser_lex_copy_from_collect_imports (CollectImportsResult.lex → *Lexer)
 * - parser_lex_from_onefunc_result_ptr_into (OneFuncResult.next_lex → *Lexer)
 * - parser_lex_from_extern_parse_result_ptr_into (ExternParseResult.next_lex → *Lexer)
 * - pipeline_parser_extern_parse_set_fail_c (write fail snapshot to ExternParseResult)
 * - pipeline_parser_library_result_copy_into_c (copy LibraryParseResult struct)
 * - pipeline_parser_try_skip_result_copy_into_c (copy TrySkipAllowResult struct)
 * - parser_lex_from_try_skip_result_val_into (TrySkipAllowResult.lex → *Lexer)
 * - parser_lex_from_library_result_val_into (LibraryParseResult.next_lex → *Lexer)
 * - pipeline_parser_set_onefunc_fail_c (write fail OneFuncResult)
 * - pipeline_parser_onefunc_buf_into_set_success_c (write success OneFuncResult)
 *
 * Glue-local typedefs (moved with their consumers):
 * - pipeline_glue_ExternParseResult (matches parser.x ExternParseResult layout)
 * - pipeline_glue_LibraryParseResult (matches parser.x LibraryParseResult layout)
 * - pipeline_glue_TrySkipAllowResult (matches parser.x TrySkipAllowResult layout)
 * - pipeline_glue_OneFuncResult (matches parser.x OneFuncResult layout)
 *
 * Why colocate: all functions here exist solely to work around X typeck gaps
 * (chain FIELD_ACCESS RHS resolving to ?, INDEX ASSIGN asm fail, usize/i32 mix).
 * They form a cohesive "parser result C sidecar" domain — slice construction,
 * lex field extraction, and result struct copy/init for parser result types.
 *
 * Depends on (visible at #include site in pipeline_glue.c):
 * - struct xlang_slice_uint8_t (defined at glue.c L57)
 * - struct lexer_Lexer / lexer_LexerResult (from token.h / lexer headers)
 * - struct parser_OneFuncResult / parser_CollectImportsResult (from seed headers)
 * - pipeline_module_fill_u8_64_from_src_c (forward-declared at glue.c L229,
 *   defined at glue.c L2133 / ast_pool_arena.c L408 fwd)
 * - memset / memcpy (from <string.h> included at glue.c L34)
 *
 * PLATFORM: SHARED — parser.x / lexer.x / pipeline.x call these via extern;
 * host-cc via pipeline_glue.c TU.
 * Wave: 1185 · no semantic change · pin stays 77b334842.
 */

/* Forward decl: pipeline_module_fill_u8_64_from_src_c is defined later in the
 * same TU (pipeline_glue.c L2133). Already forward-declared at glue.c L229,
 * but repeated here for clarity when reading this domain slice standalone. */
extern void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap);

/** Construct a slice from (data, len) for parser.x parse_into_buf / parse_one_function_impl. */
struct xlang_slice_uint8_t parser_slice_from_buf(uint8_t *data, int32_t len) {
  struct xlang_slice_uint8_t s;
  s.data = data;
  s.length = (size_t)(len >= 0 ? len : 0);
  return s;
}

/** parser.x: usize start backtrack; asm typeck fails on usize/i32 mix, keep thin C sidecar. */
size_t parser_lexer_pos_before(size_t end_pos, int32_t run_len) {
  if (run_len <= 0)
    return end_pos;
  return end_pos - (size_t)run_len;
}

/**
 * lexer.x extern: Codegen prepends lexer_ module prefix, otherwise would link
 * to non-existent lexer_parser_slice_from_buf. Equivalent to parser_slice_from_buf.
 */
struct xlang_slice_uint8_t lexer_parser_slice_from_buf(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

/**
 * parser.x: copy next_lex three fields from *LexerResult to *Lexer.
 * Avoids `r.next_lex.pos` etc. *T chain FIELD_ACCESS where typeck RHS resolves to ?.
 */
void parser_lex_from_lexer_result_ptr_into(struct lexer_Lexer *out, struct lexer_LexerResult *r) {
  if (out == NULL || r == NULL)
    return;
  out->pos = r->next_lex.pos;
  out->line = r->next_lex.line;
  out->col = r->next_lex.col;
}

/** CollectImportsResult.lex → *Lexer; C-side copy for nested field typeck gap. */
void parser_lex_copy_from_collect_imports(struct lexer_Lexer *out, struct parser_CollectImportsResult res) {
  if (out == NULL)
    return;
  out->pos = res.lex.pos;
  out->line = res.lex.line;
  out->col = res.lex.col;
}

/** LexerResult.next_lex → *Lexer (by-value parameter). */
void parser_lex_from_lexer_result_val_into(struct lexer_Lexer *out, struct lexer_LexerResult r) {
  if (out == NULL)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

/** *OneFuncResult.next_lex → *Lexer (OneFuncResult too large, pointer path only). */
void parser_lex_from_onefunc_result_ptr_into(struct lexer_Lexer *out, struct parser_OneFuncResult *res) {
  if (out == NULL || res == NULL)
    return;
  out->pos = res->next_lex.pos;
  out->line = res->next_lex.line;
  out->col = res->next_lex.col;
}

/** Matches parser.x ExternParseResult layout; glue-local typedef, do not mix with -E generated symbols. */
typedef struct {
  struct lexer_Lexer next_lex;
  uint8_t name[128];
  int32_t name_len;
  int32_t return_ty_ref;
  int32_t num_params;
  int32_t abi_kind; /**< ABI flag: 0=X ABI (default), 1=C ABI (extern "C") */
} pipeline_glue_ExternParseResult;

/** *ExternParseResult.next_lex → *Lexer; parse_one_extern_and_add_into X emit must not write lex_out.pos= (kind=28). */
void parser_lex_from_extern_parse_result_ptr_into(struct lexer_Lexer *out, void *res_raw) {
  pipeline_glue_ExternParseResult *res = (pipeline_glue_ExternParseResult *)res_raw;
  if (out == NULL || res == NULL)
    return;
  out->pos = res->next_lex.pos;
  out->line = res->next_lex.line;
  out->col = res->next_lex.col;
}

/** Write extern parse fail snapshot to out (name_len=-1); X `out.name[ni]=` INDEX ASSIGN would asm fail. */
void pipeline_parser_extern_parse_set_fail_c(void *res_raw, struct lexer_Lexer lex) {
  pipeline_glue_ExternParseResult *res = (pipeline_glue_ExternParseResult *)res_raw;
  if (res == NULL)
    return;
  res->next_lex = lex;
  res->name_len = -1;
  res->return_ty_ref = 0;
  res->num_params = 0;
  memset(res->name, 0, sizeof(res->name));
}

/** Matches parser.x LibraryParseResult layout (allow(padding)). */
typedef struct {
  int32_t ok;
  uint8_t _pad[4];
  struct lexer_Lexer next_lex;
  uint8_t name[128];
  int32_t name_len;
  uint8_t _pad_tail[4];
} pipeline_glue_LibraryParseResult;

/** Copy *LibraryParseResult from stack temp result; avoids X out.name[nli]=res.name[nli] INDEX ASSIGN. */
void pipeline_parser_library_result_copy_into_c(void *out_raw, void *res_raw) {
  pipeline_glue_LibraryParseResult *out = (pipeline_glue_LibraryParseResult *)out_raw;
  pipeline_glue_LibraryParseResult *res = (pipeline_glue_LibraryParseResult *)res_raw;
  if (out == NULL || res == NULL)
    return;
  out->ok = res->ok;
  memcpy(out->_pad, res->_pad, sizeof(out->_pad));
  out->next_lex = res->next_lex;
  memcpy(out->name, res->name, sizeof(out->name));
  out->name_len = res->name_len;
  memcpy(out->_pad_tail, res->_pad_tail, sizeof(out->_pad_tail));
}

/** Matches parser.x TrySkipAllowResult layout (allow(padding)). */
typedef struct {
  struct lexer_Lexer lex;
  int32_t skipped;
  uint8_t _pad[4];
} pipeline_glue_TrySkipAllowResult;

/** Copy *TrySkipAllowResult from stack temp result; avoids X out.lex.pos= / out._pad[i]= INDEX ASSIGN. */
void pipeline_parser_try_skip_result_copy_into_c(void *out_raw, void *res_raw) {
  pipeline_glue_TrySkipAllowResult *out = (pipeline_glue_TrySkipAllowResult *)out_raw;
  pipeline_glue_TrySkipAllowResult *res = (pipeline_glue_TrySkipAllowResult *)res_raw;
  if (out == NULL || res == NULL)
    return;
  out->lex = res->lex;
  out->skipped = res->skipped;
  memcpy(out->_pad, res->_pad, sizeof(out->_pad));
}

/** TrySkipAllowResult.lex → *Lexer (by-value param); lex_from_try_skip_into X emit must not write out.pos=. */
void parser_lex_from_try_skip_result_val_into(struct lexer_Lexer *out, pipeline_glue_TrySkipAllowResult t) {
  if (out == NULL)
    return;
  out->pos = t.lex.pos;
  out->line = t.lex.line;
  out->col = t.lex.col;
}

/** LibraryParseResult.next_lex → *Lexer (by-value param); lex_from_library_into X emit must not write out.pos=. */
void parser_lex_from_library_result_val_into(struct lexer_Lexer *out, pipeline_glue_LibraryParseResult lib) {
  if (out == NULL)
    return;
  out->pos = lib.next_lex.pos;
  out->line = lib.next_lex.line;
  out->col = lib.next_lex.col;
}

/** Matches parser.x OneFuncResult layout (allow(padding)); glue-internal only. */
typedef struct {
  int32_t ok;
  struct lexer_Lexer next_lex;
  uint8_t name[128];
  int32_t name_len;
  int32_t num_params;
  int32_t num_consts;
  int32_t num_lets;
  int32_t has_if_expr;
  int32_t if_cond_true;
  int32_t if_then_val;
  int32_t if_else_val;
  int32_t if_cond_expr_ref;
  int32_t has_mul;
  int32_t mul_right_val;
  int32_t has_binop;
  int32_t binop_right_val;
  int32_t binop_left_param_idx;
  int32_t binop_right_param_idx;
  int32_t has_unary_neg;
  int32_t return_val;
  int32_t has_call_expr;
  uint8_t call_callee_name[128];
  int32_t call_callee_len;
  uint8_t return_var_name[128];
  int32_t return_var_name_len;
  int32_t return_expr_ref;
  int32_t has_explicit_return_kw;
  int32_t call_num_args;
  int32_t num_loops;
  int32_t num_for_loops;
  int32_t num_if_stmts;
  int32_t num_src_stmt_order;
  int32_t num_src_body_expr_stmts;
  int32_t func_return_type_ref;
} pipeline_glue_OneFuncResult;

/** Write fail OneFuncResult (equivalent to set_onefunc_fail; force_stub must not X emit this body). */
void pipeline_parser_set_onefunc_fail_c(void *out_raw, struct lexer_Lexer lex) {
  pipeline_glue_OneFuncResult *out = (pipeline_glue_OneFuncResult *)out_raw;
  if (out == NULL)
    return;
  out->ok = 0;
  out->next_lex = lex;
}

/** parse_one_function_buf_into success path: write ok/next_lex/name/return_val, avoid X name[] INDEX ASSIGN. */
void pipeline_parser_onefunc_buf_into_set_success_c(void *out_raw, struct lexer_Lexer lex, const uint8_t *name,
                                                    int32_t name_len, int32_t ret_val) {
  pipeline_glue_OneFuncResult *out = (pipeline_glue_OneFuncResult *)out_raw;
  if (out == NULL)
    return;
  out->ok = 1;
  out->next_lex = lex;
  out->name_len = name_len;
  pipeline_module_fill_u8_64_from_src_c(out->name, name, name_len, 64);
  out->return_val = ret_val;
}

/** For pipeline.x run_x_pipeline_impl: same as parser_slice_from_buf, avoids -E parser_* symbol double-prefix. */
struct xlang_slice_uint8_t pipeline_source_slice(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}
