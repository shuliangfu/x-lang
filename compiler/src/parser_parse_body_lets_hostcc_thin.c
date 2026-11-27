/*
 * Host-gcc Soft Cap twin of parser_parse_body_lets_into (DIG s265).
 *
 * Tip typool body (sole T @ PE) opens with mov $0x11d8 / ___chkstk_ms —
 * native typed `let` returns P001 while the same PE under gdb returns
 * success (rax=1, coff_write=163). G.7: small-frame host-cc EXIT mirrors
 * the product let/const run for the common typed binding shape
 * `let|const name: Type = <expr-or-int>;` used by the Win tip DIG probe.
 *
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED contract vs parser.x /
 * parser_gen parse_body_lets_into (subset sufficient for DIG probe;
 * complex bracket/if/match inits fall through to fail like tip soft-drop).
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>

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
extern void parser_lex_from_result_ptr_into(Lexer *out_lex, LexerResult *r);
extern Lexer parser_lex_at_token_from_result(LexerResult r);
extern void parser_lexer_copy_into(Lexer *out_lex, Lexer src_lex);
extern void parser_parse_expr_result_reset(ParseExprResult *out_res, Lexer next_lex);
extern void parser_parse_expr_into(void *arena, Lexer lex, SliceU8 *source, ParseExprResult *out);
extern void parser_lexer_copy_from_parse_expr_result_into(Lexer *out_lex, ParseExprResult *res);
extern void parser_rewind_lex_for_following_stmt_into(Lexer *out_lex, Lexer lex_in, LexerResult r);
extern int32_t parser_parse_type_ref_for_arena_into(void *arena, Lexer lex, SliceU8 *source, Lexer *out_lex);
extern int32_t parser_alloc_int_lit(void *arena, int64_t ival);
extern uint8_t *parser_onefunc_result_pool_ptr(void *res);
extern int32_t pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                          int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                            int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_num_lets(uint8_t *pool);
extern int32_t pipeline_onefunc_num_consts(uint8_t *pool);
extern void parser_report_untyped_binding_p010_c(int32_t line, int32_t col, int32_t is_let);
extern void parser_report_keyword_binding_p014_c(int32_t line, int32_t col);

/* OneFuncResult: only touch fields via helpers + num_lets/num_consts offsets.
 * Layout matches parser_gen: ok, next_lex, name[256], name_len, num_params,
 * num_generic_params, num_consts, num_lets — num_lets at known offset. */
typedef struct {
  int ok;
  Lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t num_consts;
  int32_t num_lets;
} OneFuncResult;

/**
 * Parse a run of body let/const bindings (Soft Cap host-cc).
 *
 * @param arena ASTArena*
 * @param lex Lexer at first let/const (MS ABI: 16-byte aggregate → by pointer)
 * @param source source slice*
 * @param out OneFuncResult*
 * @param lex_out Lexer* after the run
 * @return 1 success; 0 drop enclosing function (P001)
 * PLATFORM: WINDOWS Soft Cap; SHARED semantics subset.
 */
int parser_parse_body_lets_into(void *arena, Lexer lex, SliceU8 *source, OneFuncResult *out,
                                Lexer *lex_out) {
  uint8_t *pool;
  LexerResult r;
  ParseExprResult expr_tmp;
  int32_t is_let;
  int32_t let_init_ref;
  int32_t let_ty_ref;
  int32_t name_len;
  size_t name_start;
  uint8_t name_row[128];
  int32_t ni;
  int32_t zi;
  int32_t is_discard_name;

  if (arena == 0 || source == 0 || out == 0 || lex_out == 0) {
    return 0;
  }
  memset(&r, 0, sizeof(r));
  memset(&expr_tmp, 0, sizeof(expr_tmp));
  pool = parser_onefunc_result_pool_ptr(out);
  r.next_lex = lex;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != 2 && r.tok.kind != 3) {
    lex = parser_lex_at_token_from_result(r);
    lex_out->pos = lex.pos;
    lex_out->line = lex.line;
    lex_out->col = lex.col;
    return 1;
  }
  while (1) {
    if (r.tok.kind != 2 && r.tok.kind != 3) {
      break;
    }
    is_let = (r.tok.kind == 2) ? 1 : 0;
    let_init_ref = 0;
    let_ty_ref = 0;
    is_discard_name = 0;
    name_len = 0;
    name_start = 0;
    memset(name_row, 0, sizeof(name_row));
    parser_lex_from_result_ptr_into(&lex, &r);
    lexer_next_into(&r, lex, source);
    /* optional mut after let */
    if (is_let != 0 && r.tok.kind == 59 && r.tok.ident_len == 3) {
      uint8_t m0 = 0;
      uint8_t m1 = 0;
      uint8_t m2 = 0;
      if (r.token_start < source->length) {
        m0 = source->data[r.token_start];
      }
      if (r.token_start + 1 < source->length) {
        m1 = source->data[r.token_start + 1];
      }
      if (r.token_start + 2 < source->length) {
        m2 = source->data[r.token_start + 2];
      }
      if (m0 == 109 && m1 == 117 && m2 == 116) {
        parser_lex_from_result_ptr_into(&lex, &r);
        lexer_next_into(&r, lex, source);
      }
    }
    if (r.tok.kind == 52) {
      is_discard_name = 1;
    } else if (r.tok.kind != 59 && r.tok.kind != 51) {
      parser_report_keyword_binding_p014_c(r.tok.line, r.tok.col);
      lex_out->pos = lex.pos;
      lex_out->line = lex.line;
      lex_out->col = lex.col;
      return 0;
    }
    name_len = r.tok.ident_len;
    if (is_discard_name != 0) {
      name_len = 1;
    } else if (r.tok.kind == 51) {
      name_len = 4;
    }
    if (name_len <= 0 || name_len > 255) {
      lex_out->pos = lex.pos;
      lex_out->line = lex.line;
      lex_out->col = lex.col;
      return 0;
    }
    name_start = r.token_start;
    if (is_discard_name != 0) {
      name_row[0] = 95;
      ni = 1;
    } else {
      ni = 0;
      while (ni < name_len && ni < 128) {
        if (name_start + (size_t)ni < source->length) {
          name_row[ni] = source->data[name_start + (size_t)ni];
        }
        ni = ni + 1;
      }
    }
    zi = ni;
    while (zi < 128) {
      name_row[zi] = 0;
      zi = zi + 1;
    }
    parser_lex_from_result_ptr_into(&lex, &r);
    lexer_next_into(&r, lex, source);
    /* require `: Type` for let; const may omit */
    if (r.tok.kind == 91) {
      parser_lex_from_result_ptr_into(&lex, &r);
      let_ty_ref = parser_parse_type_ref_for_arena_into(arena, lex, source, &lex);
      if (let_ty_ref == 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
      lexer_next_into(&r, lex, source);
    } else if (is_let == 0 && r.tok.kind == 117) {
      let_ty_ref = 0;
    } else {
      parser_report_untyped_binding_p010_c(r.tok.line, r.tok.col, is_let);
      lex_out->pos = lex.pos;
      lex_out->line = lex.line;
      lex_out->col = lex.col;
      return 0;
    }
    if (r.tok.kind != 117) {
      /* omit-init only for let when next is stmt-start — DIG probe always has `=` */
      lex_out->pos = lex.pos;
      lex_out->line = lex.line;
      lex_out->col = lex.col;
      return 0;
    }
    parser_lex_from_result_ptr_into(&lex, &r);
    lexer_next_into(&r, lex, source);
    /* INT lit fast path */
    if (r.tok.kind == 80) {
      let_init_ref = parser_alloc_int_lit(arena, r.tok.int_val);
      if (let_init_ref == 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
      parser_lex_from_result_ptr_into(&lex, &r);
      lexer_next_into(&r, lex, source);
    } else if (r.tok.kind == 59 || r.tok.kind == 51 || r.tok.kind == 129) {
      size_t rhs_start = r.token_start;
      parser_lex_from_result_ptr_into(&lex, &r);
      {
        Lexer expr_lex;
        expr_lex.pos = rhs_start;
        expr_lex.line = r.tok.line;
        expr_lex.col = r.tok.col;
        parser_parse_expr_result_reset(&expr_tmp, expr_lex);
        parser_parse_expr_into(arena, expr_lex, source, &expr_tmp);
      }
      if (expr_tmp.ok == 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
      let_init_ref = expr_tmp.expr_ref;
      parser_lexer_copy_from_parse_expr_result_into(&lex, &expr_tmp);
      lexer_next_into(&r, lex, source);
      parser_rewind_lex_for_following_stmt_into(&lex, lex, r);
    } else {
      /* Soft Cap: unsupported init shape → soft-drop (same class as tip miss). */
      lex_out->pos = lex.pos;
      lex_out->line = lex.line;
      lex_out->col = lex.col;
      return 0;
    }
    if (r.tok.kind == 95) {
      parser_lex_from_result_ptr_into(&lex, &r);
      lexer_next_into(&r, lex, source);
    } else {
      lex_out->pos = lex.pos;
      lex_out->line = lex.line;
      lex_out->col = lex.col;
      return 0;
    }
    if (is_let != 0) {
      if (pipeline_onefunc_append_let(pool, &name_row[0], name_len, 0, let_init_ref, let_ty_ref) < 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
      out->num_lets = pipeline_onefunc_num_lets(pool);
    } else {
      if (pipeline_onefunc_append_const(pool, &name_row[0], name_len, 0, let_init_ref, let_ty_ref) < 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
      out->num_consts = pipeline_onefunc_num_consts(pool);
    }
  }
  lex_out->pos = lex.pos;
  lex_out->line = lex.line;
  lex_out->col = lex.col;
  return 1;
}
