/*
 * Thin pure: wave287 pipeline_parser_result Cap residual leave (ALWAYS host-cc).
 * G.7: bodies match seeds/runtime_pipeline_abi.from_x.c
 * WAVE287_PARSER_RESULT_ALWAYS (slice/lex copy sidecars + onefunc/extern/
 * library/try_skip result helpers + collect_imports wrap). Local LE layout
 * structs (Lexer/Token/OneFuncResult/…). No file-local BSS. No FROM_X gate.
 * ensure injects via weaken leftover T then first-wins ld -r.
 * PLATFORM: SHARED host-cc parser_result Cap residual leave.
 */

/* XLANG_PABI_PARSER_RESULT_THIN_BEGIN */

#include <stdint.h>
#include <stddef.h>
#include <string.h>

/* Product LE layouts (local to this ALWAYS block; incomplete types elsewhere OK). */
#ifndef W287_LEXER_LAYOUT
#define W287_LEXER_LAYOUT 1
struct lexer_Lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};
struct token_Token {
  int kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};
struct lexer_LexerResult {
  struct lexer_Lexer next_lex;
  struct token_Token tok;
  size_t token_start;
};
struct parser_CollectImportsResult {
  struct lexer_Lexer lex;
};
/* Product OneFuncResult (parser_gen / parser.x allow(padding) name[128]). */
struct parser_OneFuncResult {
  int ok;
  struct lexer_Lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t num_consts;
  int32_t num_lets;
  int has_if_expr;
  int if_cond_true;
  int32_t if_then_val;
  int32_t if_else_val;
  int32_t if_cond_expr_ref;
  int has_mul;
  int32_t mul_right_val;
  int has_binop;
  int32_t binop_right_val;
  int32_t binop_left_param_idx;
  int32_t binop_right_param_idx;
  int has_unary_neg;
  int32_t return_val;
  int has_call_expr;
  uint8_t call_callee_name[256];
  int32_t call_callee_len;
  uint8_t return_var_name[256];
  int32_t return_var_name_len;
  int32_t return_expr_ref;
  int has_final_expr;
  int has_explicit_return_kw;
  int32_t call_num_args;
  int32_t num_loops;
  int32_t num_for_loops;
  int32_t num_if_stmts;
  int32_t num_src_stmt_order;
  int32_t num_src_body_expr_stmts;
  int32_t func_return_type_ref;
  /* Cap 10.7.1 language: 1 when param list ends with `, ...` (≡ parser.x / pin). */
  int32_t is_variadic;
};
struct parser_ExternParseResult {
  struct lexer_Lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  int32_t return_ty_ref;
  int32_t num_params;
  int32_t abi_kind;
  int32_t is_variadic;
};
struct parser_TrySkipAllowResult {
  struct lexer_Lexer lex;
  int32_t skipped;
  uint8_t _pad[4];
};
struct parser_LibraryParseResult {
  int ok;
  uint8_t _pad[4];
  struct lexer_Lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  uint8_t _pad_tail[4];
};
#endif /* W287_LEXER_LAYOUT */

/* Complete slice type (seed mega includes runtime_pipeline_abi.h at head). */
struct xlang_slice_uint8_t {
  uint8_t *data;
  size_t length;
};


/* xlang_slice_uint8_t complete above (thin TU; seed uses pipeline_abi.h). */
extern void pipeline_module_fill_u8_64_from_src_c(uint8_t *dst, const uint8_t *src, int32_t n, int32_t src_cap);

struct xlang_slice_uint8_t parser_slice_from_buf(uint8_t *data, int32_t len) {
  struct xlang_slice_uint8_t s;
  s.data = data;
  s.length = (size_t)(len >= 0 ? len : 0);
  return s;
}

size_t parser_lexer_pos_before(size_t end_pos, int32_t run_len) {
  if (run_len <= 0)
    return end_pos;
  return end_pos - (size_t)run_len;
}

struct xlang_slice_uint8_t lexer_parser_slice_from_buf(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

void parser_lex_from_lexer_result_ptr_into(struct lexer_Lexer *out, struct lexer_LexerResult *r) {
  if (out == NULL || r == NULL)
    return;
  out->pos = r->next_lex.pos;
  out->line = r->next_lex.line;
  out->col = r->next_lex.col;
}

void parser_lex_copy_from_collect_imports(struct lexer_Lexer *out, struct parser_CollectImportsResult res) {
  if (out == NULL)
    return;
  out->pos = res.lex.pos;
  out->line = res.lex.line;
  out->col = res.lex.col;
}

void parser_lex_from_lexer_result_val_into(struct lexer_Lexer *out, struct lexer_LexerResult r) {
  if (out == NULL)
    return;
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
}

void parser_lex_from_onefunc_result_ptr_into(struct lexer_Lexer *out, struct parser_OneFuncResult *res) {
  if (out == NULL || res == NULL)
    return;
  out->pos = res->next_lex.pos;
  out->line = res->next_lex.line;
  out->col = res->next_lex.col;
}

void parser_lex_from_extern_parse_result_ptr_into(struct lexer_Lexer *out, void *res_raw) {
  struct parser_ExternParseResult *res = (struct parser_ExternParseResult *)res_raw;
  if (out == NULL || res == NULL)
    return;
  out->pos = res->next_lex.pos;
  out->line = res->next_lex.line;
  out->col = res->next_lex.col;
}

void pipeline_parser_extern_parse_set_fail_c(void *res_raw, struct lexer_Lexer lex) {
  struct parser_ExternParseResult *res = (struct parser_ExternParseResult *)res_raw;
  if (res == NULL)
    return;
  res->next_lex = lex;
  res->name_len = -1;
  res->return_ty_ref = 0;
  res->num_params = 0;
  res->abi_kind = 0;
  res->is_variadic = 0;
  memset(res->name, 0, sizeof(res->name));
}

void pipeline_parser_library_result_copy_into_c(void *out_raw, void *res_raw) {
  struct parser_LibraryParseResult *out = (struct parser_LibraryParseResult *)out_raw;
  struct parser_LibraryParseResult *res = (struct parser_LibraryParseResult *)res_raw;
  if (out == NULL || res == NULL)
    return;
  out->ok = res->ok;
  memcpy(out->_pad, res->_pad, sizeof(out->_pad));
  out->next_lex = res->next_lex;
  memcpy(out->name, res->name, sizeof(out->name));
  out->name_len = res->name_len;
  memcpy(out->_pad_tail, res->_pad_tail, sizeof(out->_pad_tail));
}

void pipeline_parser_try_skip_result_copy_into_c(void *out_raw, void *res_raw) {
  struct parser_TrySkipAllowResult *out = (struct parser_TrySkipAllowResult *)out_raw;
  struct parser_TrySkipAllowResult *res = (struct parser_TrySkipAllowResult *)res_raw;
  if (out == NULL || res == NULL)
    return;
  out->lex = res->lex;
  out->skipped = res->skipped;
  memcpy(out->_pad, res->_pad, sizeof(out->_pad));
}

void parser_lex_from_try_skip_result_val_into(struct lexer_Lexer *out, struct parser_TrySkipAllowResult t) {
  if (out == NULL)
    return;
  out->pos = t.lex.pos;
  out->line = t.lex.line;
  out->col = t.lex.col;
}

void parser_lex_from_library_result_val_into(struct lexer_Lexer *out, struct parser_LibraryParseResult lib) {
  if (out == NULL)
    return;
  out->pos = lib.next_lex.pos;
  out->line = lib.next_lex.line;
  out->col = lib.next_lex.col;
}

void pipeline_parser_set_onefunc_fail_c(void *out_raw, struct lexer_Lexer lex) {
  struct parser_OneFuncResult *out = (struct parser_OneFuncResult *)out_raw;
  if (out == NULL)
    return;
  out->ok = 0;
  out->next_lex = lex;
}

void pipeline_parser_onefunc_buf_into_set_success_c(void *out_raw, struct lexer_Lexer lex, const uint8_t *name,
                                                    int32_t name_len, int32_t ret_val) {
  struct parser_OneFuncResult *out = (struct parser_OneFuncResult *)out_raw;
  if (out == NULL)
    return;
  out->ok = 1;
  out->next_lex = lex;
  out->name_len = name_len;
  pipeline_module_fill_u8_64_from_src_c(out->name, name, name_len, 64);
  out->return_val = ret_val;
}

struct xlang_slice_uint8_t pipeline_source_slice(uint8_t *data, int32_t len) {
  return parser_slice_from_buf(data, len);
}

/**
 * Collect top-level import paths from source bytes into module (no function-body parse).
 * Thin wrap of parser_collect_imports_buf for runtime_pipeline_abi.x (*u8 ABI; no Lexer type).
 * Caller must parser_parse_into_init the module first so import sidecar is live.
 * @param module AST module; null -> no-op
 * @param data source bytes; null -> no-op
 * @param len byte length; <=0 or >INT32_MAX -> no-op
 * PLATFORM: SHARED — Darwin / Ubuntu product -o collect-deps; leftover PE rest ALWAYS T.
 */
extern struct lexer_Lexer lexer_init(void);
extern void parser_collect_imports_buf(struct lexer_Lexer lex, uint8_t *data, int32_t len, void *module,
                                       struct parser_CollectImportsResult *out);
void xlang_module_collect_imports_from_buf(void *module, uint8_t *data, int64_t len) {
  struct lexer_Lexer lex;
  struct parser_CollectImportsResult import_res;
  int32_t n;
  if (!module || !data || len <= 0)
    return;
  if (len > 2147483647)
    return;
  n = (int32_t)len;
  lex = lexer_init();
  import_res.lex = lex;
  parser_collect_imports_buf(lex, data, n, module, &import_res);
}

/* XLANG_PABI_PARSER_RESULT_THIN_END */
