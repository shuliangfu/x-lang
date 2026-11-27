/*
 * Host-gcc Soft Cap twin of parser_parse_one_function_impl (DIG s271).
 *
 * Tip impl uses mov $0x2268 / ___chkstk_ms. DIG map (s268–s270): Soft Cap
 * body_lets appends typed let correctly (init/type refs OK); skip_append
 * greens native; any sidecar let → native P001 while gdb coff=163. Root:
 * tip 0x2268 lets-consume path Heisenbug after Soft Cap returns.
 *
 * Soft Cap owns DIG shapes in a small frame, then finishes via tip helpers:
 *   [export already consumed] function IDENT (): Type { body_lets return … }
 * Non-DIG → parser_parse_one_function_impl_tip (parser_x.o redefined).
 *
 * PLATFORM: WINDOWS Soft Cap; SHARED DIG contract vs parser.x / parser_gen.
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>

/**
 * DIG s271: Soft Cap one_function exit map. Remove after native typed let greens.
 * PLATFORM: WINDOWS.
 */
static void softcap_onefn_dig(const char *msg, int32_t a, int32_t b) {
  FILE *f;
  f = fopen("../tmp/from-x-lang-repo/s271/one_fn_dig.log", "a");
  if (f == 0) {
    f = fopen("tmp/from-x-lang-repo/s271/one_fn_dig.log", "a");
  }
  if (f == 0) {
    return;
  }
  fprintf(f, "%s a=%d b=%d\n", msg, (int)a, (int)b);
  fclose(f);
}

typedef struct {
  size_t pos;
  int32_t line;
  int32_t col;
} Lexer;

typedef struct {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
} Token;

typedef struct {
  Lexer next_lex;
  Token tok;
  size_t token_start;
} LexerResult;

typedef struct {
  int ok;
  int32_t expr_ref;
  Lexer next_lex;
} ParseExprResult;

typedef struct {
  uint8_t *data;
  size_t length;
} SliceU8;

extern void lexer_next_into(LexerResult *out, Lexer lex, SliceU8 *source);
extern void parser_lex_from_next_into(Lexer *out_lex, LexerResult r);
extern void parser_lex_from_result_ptr_into(Lexer *out_lex, LexerResult *r);
extern Lexer parser_lex_at_token_from_result(LexerResult r);
extern void parser_set_onefunc_fail(void *out, Lexer next_lex);
extern uint8_t *parser_onefunc_result_pool_ptr(void *res);
extern void ast_pool_onefunc_reset(uint8_t *out);
extern void parser_copy_onefunc_into(void *dst, void *src);
/*
 * OneFuncResult is tip-sized (~0x394+). Soft Cap opaque buffer ≥ tip sizeof.
 * Tip returns OneFuncResult by value (MS sret). PLATFORM: WINDOWS Soft Cap.
 */
enum { SOFTCAP_ONEFUNC_BYTES = 0x800 };
typedef struct {
  uint8_t bytes[SOFTCAP_ONEFUNC_BYTES];
} SoftcapOneFuncBuf;
extern SoftcapOneFuncBuf parser_onefunc_alloc_wired_for_parse(Lexer lex);
extern SoftcapOneFuncBuf parser_onefunc_scratch_empty(void);
extern void parser_onefunc_res_wire_dummy_head(void *res, Lexer lex, uint8_t *name64);
extern void parser_onefunc_res_wire_dummy_const_let(void *res);
extern void parser_onefunc_res_wire_dummy_if_mul(void *res);
extern void parser_onefunc_res_wire_dummy_call_binop(void *res, uint8_t *name64);
extern void parser_onefunc_res_wire_dummy_loop_call(void *res);
extern void parser_onefunc_res_wire_dummy_for_if(void *res);
extern void parser_copy_slice_to_name64(SliceU8 *source, size_t start, int32_t nlen, uint8_t *out);
extern int32_t parser_parse_type_ref_for_arena_into(void *arena, Lexer lex, SliceU8 *source, Lexer *out_lex);
extern int parser_parse_body_lets_into(void *arena, Lexer lex, SliceU8 *source, void *out, Lexer *lex_out);
extern int32_t pipeline_onefunc_num_lets(uint8_t *pool);
extern int32_t pipeline_onefunc_num_consts(uint8_t *pool);
extern int32_t pipeline_onefunc_push_stmt_order(uint8_t *out, uint8_t kind, int32_t idx);
extern void parser_onefunc_push_src_stmt(void *out, uint8_t kind, int32_t idx);
extern void parser_parse_expr_result_reset(ParseExprResult *out_res, Lexer next_lex);
extern void parser_parse_expr_into(void *arena, Lexer lex, SliceU8 *source, ParseExprResult *out);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_common_zeros_c(void *a, int32_t er);
extern void pipeline_expr_set_kind(void *a, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *a, int32_t er, int32_t line, int32_t col);
extern void pipeline_expr_set_int_val(void *a, int32_t er, int64_t v);
extern void parser_onefunc_finish_impl_to_out(void *out, void *snap, Lexer lex, uint8_t *name,
                                             int32_t name_len, int32_t ret_expr_storage);
extern void parser_onefunc_snap_set_return_path(void *snap, int has_call, uint8_t *ret_var,
                                               int32_t ret_var_len, int32_t ret_expr_ref);
extern void parser_parse_one_function_impl_tip(void *out, void *arena, Lexer lex, SliceU8 *source);

/**
 * Call real tip body after win_patch plants `jmp SoftCap` at tip entry (5 bytes).
 * Soft Cap non-DIG / dig-miss must not call tip symbol (that would recurse).
 * PLATFORM: WINDOWS Soft Cap + win_patch s271.
 */
static void softcap_call_tip_body(void *out, void *arena, Lexer lex, SliceU8 *source) {
  typedef void (*TipFn)(void *, void *, Lexer, SliceU8 *);
  uint8_t *tip_entry;
  TipFn tip_body;

  tip_entry = (uint8_t *)(void *)&parser_parse_one_function_impl_tip;
  /* Skip planted E9 rel32 at tip entry when present; else call tip as-is. */
  if (tip_entry[0] == 0xE9) {
    tip_body = (TipFn)(void *)(tip_entry + 5);
  } else {
    tip_body = (TipFn)(void *)tip_entry;
  }
  tip_body(out, arena, lex, source);
}

/*
 * Field offsets from Win MinGW sizeof OneFuncResult=920 dig (≡ parser_gen layout).
 * Soft Cap avoids full struct; tip finish/copy uses these scalars. PLATFORM: WINDOWS.
 */
enum {
  OF_OK = 0,
  OF_NUM_LETS = 0x124, /* may vary — Soft Cap uses tip push helpers, not raw writes */
  OF_RETURN_EXPR_REF = 876,
  OF_HAS_FINAL_EXPR = 880,
  OF_HAS_EXPLICIT_RETURN_KW = 884,
  OF_FUNC_RET_TY = 0x390 /* 912 */
};

/**
 * Write tip OneFuncResult.func_return_type_ref (offset from copy_onefunc dig).
 * Soft Cap avoids full struct field names. PLATFORM: WINDOWS Soft Cap.
 */
static void softcap_set_func_return_type_ref(void *out, int32_t ty) {
  *(int32_t *)((uint8_t *)out + OF_FUNC_RET_TY) = ty;
}

/**
 * Soft Cap DIG: parse `function IDENT (): Type { lets… return … }` without tip 0x2268.
 *
 * @return 1 handled; 0 fall through to tip (non-DIG / unsupported)
 * PLATFORM: WINDOWS Soft Cap DIG.
 */
static int softcap_try_dig_one_function(void *out, void *arena, Lexer lex, SliceU8 *source) {
  SoftcapOneFuncBuf clean_buf;
  SoftcapOneFuncBuf snap_buf;
  uint8_t dummy_name[256];
  LexerResult r;
  ParseExprResult expr;
  Lexer lex_cur;
  Lexer lex_tmp;
  uint8_t *pool;
  int32_t name_len;
  size_t name_start;
  int32_t ret_ty;
  int32_t nlets;
  int32_t nconsts;
  int32_t i;
  int32_t ret_ref;

  softcap_onefn_dig("try", 0, 0);
  if (out == 0 || arena == 0 || source == 0) {
    return 0;
  }
  memset(&clean_buf, 0, sizeof(clean_buf));
  memset(&snap_buf, 0, sizeof(snap_buf));
  memset(dummy_name, 0, sizeof(dummy_name));
  memset(&r, 0, sizeof(r));
  memset(&expr, 0, sizeof(expr));

  pool = parser_onefunc_result_pool_ptr(out);
  ast_pool_onefunc_reset(pool);
  clean_buf = parser_onefunc_alloc_wired_for_parse(lex);
  parser_copy_onefunc_into(out, &clean_buf);

  snap_buf = parser_onefunc_scratch_empty();
  ast_pool_onefunc_reset(parser_onefunc_result_pool_ptr(&snap_buf));
  parser_onefunc_res_wire_dummy_head(&snap_buf, lex, dummy_name);
  parser_onefunc_res_wire_dummy_const_let(&snap_buf);
  parser_onefunc_res_wire_dummy_if_mul(&snap_buf);
  parser_onefunc_res_wire_dummy_call_binop(&snap_buf, dummy_name);
  parser_onefunc_res_wire_dummy_loop_call(&snap_buf);
  parser_onefunc_res_wire_dummy_for_if(&snap_buf);

  lex_cur = lex;
  lexer_next_into(&r, lex_cur, source);
  /*
   * Entry contract (≡ tip parse_one_function_impl / parse_into):
   * parse_into consumes TOKEN_FUNCTION then calls with lex AFTER `function`,
   * so the first token is usually TOKEN_IDENT (name). Direct callers may still
   * pass lex AT TOKEN_FUNCTION. Accept both; reject other shapes → tip.
   * PLATFORM: SHARED DIG vs tip IDENT-first empty branch + FUNCTION path.
   */
  if (r.tok.kind == 1) {
    /* TOKEN_FUNCTION — consume then expect IDENT */
    parser_lex_from_next_into(&lex_cur, r);
    lexer_next_into(&r, lex_cur, source);
  }
  /* TOKEN_IDENT=59 */
  if (r.tok.kind != 59) {
    softcap_onefn_dig("no_name", r.tok.kind, 0);
    return 0;
  }
  name_len = r.tok.ident_len;
  if (name_len <= 0 || name_len > 255) {
    return 0;
  }
  name_start = r.next_lex.pos - (size_t)name_len;
  parser_copy_slice_to_name64(source, name_start, name_len, &dummy_name[0]);
  parser_lex_from_next_into(&lex_cur, r);
  lexer_next_into(&r, lex_cur, source);
  /* TOKEN_LPAREN=82 — DIG: no params */
  if (r.tok.kind != 82) {
    softcap_onefn_dig("no_lparen", r.tok.kind, 0);
    return 0;
  }
  parser_lex_from_next_into(&lex_cur, r);
  lexer_next_into(&r, lex_cur, source);
  if (r.tok.kind != 83) {
    softcap_onefn_dig("has_params", r.tok.kind, 0);
    return 0;
  }
  parser_lex_from_next_into(&lex_cur, r);
  lexer_next_into(&r, lex_cur, source);
  /* TOKEN_COLON=91 */
  if (r.tok.kind != 91) {
    softcap_onefn_dig("no_ret_colon", r.tok.kind, 0);
    return 0;
  }
  parser_lex_from_next_into(&lex_cur, r);
  lex_tmp = lex_cur;
  ret_ty = parser_parse_type_ref_for_arena_into(arena, lex_tmp, source, &lex_cur);
  if (ret_ty == 0) {
    softcap_onefn_dig("ret_ty0", 0, 0);
    return 0;
  }
  softcap_set_func_return_type_ref(out, ret_ty);
  lexer_next_into(&r, lex_cur, source);
  /* TOKEN_LBRACE=84 (token.x ordinal; Soft Cap body_lets omit list used 85=RBRACE) */
  if (r.tok.kind != 84) {
    softcap_onefn_dig("no_lbrace", r.tok.kind, 0);
    return 0;
  }
  parser_lex_from_next_into(&lex_cur, r);

  /* Soft Cap body_lets (already tip-landed). */
  if (!parser_parse_body_lets_into(arena, lex_cur, source, out, &lex_cur)) {
    softcap_onefn_dig("body_lets_fail", 0, 0);
    parser_set_onefunc_fail(out, lex_cur);
    return 1; /* handled fail — do not tip-retry */
  }
  pool = parser_onefunc_result_pool_ptr(out);
  nlets = pipeline_onefunc_num_lets(pool);
  nconsts = pipeline_onefunc_num_consts(pool);
  softcap_onefn_dig("after_lets", nlets, nconsts);
  i = 0;
  while (i < nconsts) {
    parser_onefunc_push_src_stmt(out, 0, i);
    i = i + 1;
  }
  i = 0;
  while (i < nlets) {
    parser_onefunc_push_src_stmt(out, 1, i);
    i = i + 1;
  }

  lexer_next_into(&r, lex_cur, source);
  /* TOKEN_RETURN=11 */
  if (r.tok.kind != 11) {
    softcap_onefn_dig("no_return", r.tok.kind, 0);
    return 0; /* mid-body non-return → tip */
  }
  parser_lex_from_next_into(&lex_cur, r);
  lexer_next_into(&r, lex_cur, source);
  ret_ref = 0;
  if (r.tok.kind == 80) {
    /* INT lit return */
    ret_ref = ast_ast_arena_expr_alloc(arena);
    if (ret_ref == 0) {
      parser_set_onefunc_fail(out, lex_cur);
      return 1;
    }
    pipeline_expr_set_common_zeros_c(arena, ret_ref);
    pipeline_expr_set_kind(arena, ret_ref, 0);
    pipeline_expr_set_int_val(arena, ret_ref, r.tok.int_val);
    pipeline_expr_set_line_col(arena, ret_ref, 0, 0);
    parser_lex_from_next_into(&lex_cur, r);
    lexer_next_into(&r, lex_cur, source);
  } else if (r.tok.kind == 59) {
    /* IDENT return — tip parse_expr */
    size_t id_start = r.token_start;
    Lexer expr_lex;
    expr_lex.pos = id_start;
    expr_lex.line = r.tok.line;
    expr_lex.col = r.tok.col;
    parser_parse_expr_result_reset(&expr, expr_lex);
    parser_parse_expr_into(arena, expr_lex, source, &expr);
    if (expr.ok == 0) {
      softcap_onefn_dig("ret_expr_fail", 0, 0);
      parser_set_onefunc_fail(out, lex_cur);
      return 1;
    }
    ret_ref = expr.expr_ref;
    lex_cur = expr.next_lex;
    lexer_next_into(&r, lex_cur, source);
  } else {
    softcap_onefn_dig("ret_shape", r.tok.kind, 0);
    return 0;
  }
  /* optional SEMI=95 */
  if (r.tok.kind == 95) {
    parser_lex_from_next_into(&lex_cur, r);
    lexer_next_into(&r, lex_cur, source);
  }
  /* TOKEN_RBRACE=85 */
  if (r.tok.kind != 85) {
    softcap_onefn_dig("no_rbrace", r.tok.kind, 0);
    return 0;
  }
  parser_lex_from_next_into(&lex_cur, r);

  /*
   * Tip return face sets has_explicit_return_kw + has_final_expr on snap before
   * finish (else typeck XT001 "must use explicit return"). Soft Cap must match.
   * PLATFORM: SHARED ≡ tip parse_one_function_impl return finish.
   */
  parser_onefunc_snap_set_return_path(&snap_buf, 0, &dummy_name[0], 0, ret_ref);
  *(int *)((uint8_t *)&snap_buf + OF_HAS_FINAL_EXPR) = 1;
  *(int *)((uint8_t *)&snap_buf + OF_HAS_EXPLICIT_RETURN_KW) = 1;
  parser_onefunc_finish_impl_to_out(out, &snap_buf, lex_cur, &dummy_name[0], name_len, ret_ref);
  softcap_onefn_dig("ok", name_len, ret_ref);
  softcap_onefn_dig("out_ok", *(int *)((uint8_t *)out + OF_OK),
                    *(int *)((uint8_t *)out + OF_HAS_EXPLICIT_RETURN_KW));
  softcap_onefn_dig("out_ret", *(int32_t *)((uint8_t *)out + OF_RETURN_EXPR_REF),
                    *(int32_t *)((uint8_t *)out + OF_FUNC_RET_TY));
  return 1;
}

/**
 * Soft Cap entry: DIG bare/typed-let one_function; else tip twin.
 *
 * @param out OneFuncResult*
 * @param arena ASTArena*
 * @param lex Lexer at function (MS ABI by pointer for 16B aggregate)
 * @param source source slice*
 * PLATFORM: WINDOWS Soft Cap.
 */
void parser_parse_one_function_impl(void *out, void *arena, Lexer lex, SliceU8 *source) {
  softcap_onefn_dig("enter", 0, 0);
  if (softcap_try_dig_one_function(out, arena, lex, source) != 0) {
    softcap_onefn_dig("dig_done", 0, 0);
    return;
  }
  softcap_onefn_dig("tip", 0, 0);
  softcap_call_tip_body(out, arena, lex, source);
}
