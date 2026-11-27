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

/**
 * DIG s269: tip parse_one_function_impl uses mov $0x2268 + ___chkstk_ms.
 * Soft Cap returns into that frame; native lets-path (num_lets>=1) P001 while
 * skip_append (same Soft Cap depth, num_lets=0) greens — likely uncommitted
 * stack pages for deeper tip locals. Touch ~0x3000 below the caller's frame
 * before Soft Cap returns so tip lets-path slots are committed.
 * PLATFORM: WINDOWS Soft Cap DIG; remove after native typed let greens.
 */
static void softcap_touch_caller_stack_pages(void) {
  volatile unsigned char *fp;
  size_t i;
  unsigned char sink;
  sink = 0;
  fp = (volatile unsigned char *)__builtin_frame_address(1);
  if (fp == 0) {
    softcap_body_lets_dig("touch_nofp", 0, 0);
    return;
  }
  /* Walk down toward older frames / deeper tip alloca (page size 0x1000). */
  for (i = 0; i < 0x3000; i += 0x1000) {
    sink = (unsigned char)(sink + fp[-((ptrdiff_t)i)]);
  }
  softcap_body_lets_dig("touch", (int32_t)sink, 0x3000);
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
/*
 * DIG s268: tip parser_alloc_int_lit is sub $0x9c0 (Expr by-value get/set).
 * Soft Cap INT init must NOT call that tip face — nested 0x9c0 from Soft Cap
 * is the Soft Cap-after native P001 Heisenbug candidate (gdb let green).
 * Use arena alloc + pipeline_expr_set_* thin writers (no Expr by-value).
 * PLATFORM: WINDOWS Soft Cap; SHARED ExprKind EXPR_LIT=0 contract.
 */
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern void pipeline_expr_set_common_zeros_c(void *a, int32_t er);
extern void pipeline_expr_set_kind(void *a, int32_t er, int32_t kind);
extern void pipeline_expr_set_line_col(void *a, int32_t er, int32_t line, int32_t col);
extern void pipeline_expr_set_int_val(void *a, int32_t er, int64_t v);
extern uint8_t *parser_onefunc_result_pool_ptr(void *res);
extern int32_t pipeline_onefunc_append_let(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                          int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_append_const(uint8_t *out, uint8_t *name, int32_t name_len, int32_t init_val,
                                            int32_t init_ref, int32_t type_ref);
extern int32_t pipeline_onefunc_num_lets(uint8_t *pool);
extern int32_t pipeline_onefunc_num_consts(uint8_t *pool);
extern void parser_report_untyped_binding_p010_c(int32_t line, int32_t col, int32_t is_let);
extern void parser_report_keyword_binding_p014_c(int32_t line, int32_t col);

/*
 * Soft Cap must NOT write OneFuncResult fields by offset (ok/num_lets/…).
 * Tip OneFuncResult is much larger (allow(padding) bool ok + many tails);
 * host-cc partial struct writes were a Heisenbug candidate (gdb let green,
 * native P001 after Soft Cap dig ok). Authority: pool append helpers only;
 * tip refreshes num_lets/num_consts from pool after Soft Cap returns.
 * PLATFORM: WINDOWS Soft Cap / SHARED OneFuncResult contract.
 */
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
  /* Tip append_let init_val face (INT lit); Soft Cap used to pass 0. PLATFORM: SHARED. */
  int32_t let_init_val;
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
    let_init_val = 0;
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
    /* INT lit fast path — thin alloc (avoid tip parser_alloc_int_lit 0x9c0). */
    if (r.tok.kind == 80) {
      let_init_ref = ast_ast_arena_expr_alloc(arena);
      if (let_init_ref == 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
      pipeline_expr_set_common_zeros_c(arena, let_init_ref);
      pipeline_expr_set_kind(arena, let_init_ref, 0); /* EXPR_LIT */
      pipeline_expr_set_int_val(arena, let_init_ref, r.tok.int_val);
      pipeline_expr_set_line_col(arena, let_init_ref, 0, 0);
      let_init_val = (int32_t)r.tok.int_val;
      softcap_body_lets_dig("int_thin", let_init_ref, let_init_val);
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
      if (pipeline_onefunc_append_let(pool, &name_row[0], name_len, let_init_val, let_init_ref,
                                      let_ty_ref) < 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
      softcap_body_lets_dig("appended", pipeline_onefunc_num_lets(pool), r.tok.kind);
    } else {
      if (pipeline_onefunc_append_const(pool, &name_row[0], name_len, let_init_val, let_init_ref,
                                        let_ty_ref) < 0) {
        lex_out->pos = lex.pos;
        lex_out->line = lex.line;
        lex_out->col = lex.col;
        return 0;
      }
    }
  }
  lex_out->pos = lex.pos;
  lex_out->line = lex.line;
  lex_out->col = lex.col;
  /* DIG: lex_out.pos + kind at exit (native vs gdb Heisenbug map). */
  softcap_body_lets_dig("ok_pos", (int32_t)lex_out->pos, r.tok.kind);
  softcap_body_lets_dig("ok_nlets", pipeline_onefunc_num_lets(pool), (int32_t)lex_out->line);
  /* Commit tip caller pages before returning into 0x2268 lets-path. */
  softcap_touch_caller_stack_pages();
  return 1;
}
