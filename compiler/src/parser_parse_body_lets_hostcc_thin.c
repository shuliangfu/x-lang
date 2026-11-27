/*
 * Host-gcc Soft Cap twin of parser_parse_body_lets_into (DIG s265/s266).
 *
 * Tip typool body opens with mov $0x11d8 / ___chkstk_ms. Win DIG: native
 * typed `let` always P001; the same PE under gdb (ASLR on or off, with or
 * without breakpoints) returns body_lets rax=1 and coff_write=163. Not an
 * ASLR bug — giant-frame/chkstk Heisenbug. G.7: small-frame host-cc EXIT
 * (sub $0x1c8) mirrors the product typed binding shape
 * `let|const name: Type = <expr-or-int>` (`;` optional before stmt-start) for the Win tip DIG probe.
 *
 * ABI: tip callers pass Lexer* in RDX (movdqu (%rdx)); Token 48B /
 * LexerResult 72B match seed. lexer_next_into Soft Cap accepts pointer
 * path (RDX>=0x10000).
 *
 * PLATFORM: WINDOWS host-cc Soft Cap; SHARED contract vs parser.x /
 * parser_gen parse_body_lets_into (subset sufficient for DIG probe;
 * complex bracket/if/match inits fall through to fail like tip soft-drop).
 */
#include <stdint.h>
#include <stddef.h>
#include <string.h>
#include <stdio.h>

/**
 * DIG s266b: native Soft Cap exit map (gdb let greens; native P001).
 * Remove after native typed let greens. PLATFORM: WINDOWS.
 */
static void softcap_body_lets_dig(const char *msg, int32_t a, int32_t b) {
  FILE *f;
  f = fopen("../tmp/from-x-lang-repo/s266/body_lets_dig.log", "a");
  if (f == 0) {
    f = fopen("tmp/from-x-lang-repo/s266/body_lets_dig.log", "a");
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
  softcap_body_lets_dig("enter", 0, 0);
  if (arena == 0 || source == 0 || out == 0 || lex_out == 0) {
    softcap_body_lets_dig("null",0,0);
    return 0;
  }
  memset(&r, 0, sizeof(r));
  memset(&expr_tmp, 0, sizeof(expr_tmp));
  pool = parser_onefunc_result_pool_ptr(out);
  r.next_lex = lex;
  lexer_next_into(&r, lex, source);
  softcap_body_lets_dig("first", r.tok.kind, 0);
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
    /*
     * Tip (parser.x): after plain INT init, `;` may be omitted when the next
     * token is a stmt-start (RETURN=11, LET=2, CONST=3, IF=4, WHILE=6,
     * FOR=8, LBRACE=85). DIG s266: Soft Cap required SEMI → no_semi on
     * `let x: i32 = 1\n  return x` (kind=11). PLATFORM: SHARED.
     */
    if (r.tok.kind == 95) {
      /* Consume `;`, then land lex/r on the following stmt token (tip twin). */
      parser_lex_from_result_ptr_into(&lex, &r);
      lexer_next_into(&r, lex, source);
      lex = parser_lex_at_token_from_result(r);
      lexer_next_into(&r, lex, source);
    } else if (r.tok.kind == 2 || r.tok.kind == 3 || r.tok.kind == 11
               || r.tok.kind == 4 || r.tok.kind == 6 || r.tok.kind == 8
               || r.tok.kind == 85) {
      /* Omit `;`: leave r on stmt-start; point lex at that token. */
      lex = parser_lex_at_token_from_result(r);
    } else {
      lex_out->pos = lex.pos;
      lex_out->line = lex.line;
      softcap_body_lets_dig("semi_fail", r.tok.kind, 0);
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
      softcap_body_lets_dig("appended", out->num_lets, r.tok.kind);
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
  softcap_body_lets_dig("ok", out->num_lets, r.tok.kind);
  return 1;
}
