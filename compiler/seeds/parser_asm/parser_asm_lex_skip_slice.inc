/**
 * parser_asm_lex_skip_slice.inc — P1 lex/skip pure helpers (G-02f-281).
 * Included by parser_asm_thin_c.from_x.c or pthin_lex_skip.from_x.c.
 *
 * Hybrid P1b/P1c/P1d/P1e/P1f: XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X skips the portable
 * kind/copy/skip-walk region and the count walk (bodies in
 * src/asm/pthin_lex_skip.x + by-value trampolines in the seed TU).
 * P1d ASI and P1e peek-name / first_token C twins live in helpers.inc
 * (trampoline there). P1f copy_token_bytes buf-path lives here; the
 * historical slice name stays a trampoline in imports.inc.
 * g_gp_pending_* statics + register_pending stay here.
 * Cold: no define, this file is the full twin. Do not reuse
 * XLANG_PTHIN_LEX_SKIP_FROM_X for P1b/P1c/P1d/P1e/P1f bodies.
 */
#ifndef PARSER_ASM_LEX_SKIP_SLICE_INCLUDED
#define PARSER_ASM_LEX_SKIP_SLICE_INCLUDED

#ifndef XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X removed */
#endif /* !XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X */

#ifdef XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X
/* Hybrid P1b: stmt-boundary authority is pthin_lex_skip.x (was static here). */
extern int32_t parser_asm_angle_list_token_is_stmt_boundary_c(int32_t k);
#endif

/**
 * Same as skip_generic_angle_list_into, also counts top-level type args.
 * On boundary abort: *out = input lex, *count = 0 (caller must not treat as generic).
 * PLATFORM: SHARED — wave446 angle-list boundary gate (see sibling into_slice).
 */
/*
 * wave455: pending type-param names captured by the most recent angle-list
 * count walk (function decl `foo<T, U>`). Call-site turbofish walks also
 * overwrite this; callers that need decl names must snapshot immediately
 * after counting a function signature (see register_type_params).
 * PLATFORM: SHARED parser.
 */
#define XLANG_GP_PENDING_MAX 8
static uint8_t g_gp_pending_names[XLANG_GP_PENDING_MAX][64];
static int32_t g_gp_pending_lens[XLANG_GP_PENDING_MAX];
static int32_t g_gp_pending_n;

#ifdef XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X
extern int32_t parser_asm_skip_generic_angle_list_count_into_c(void *lex_inout, void *source, int32_t *count,
                                                              uint8_t *names, int32_t *lenses, int32_t *pending_n);

void parser_asm_skip_generic_angle_list_count_into_slice_c(struct parser_asm_lexer *out, int32_t *count,
                                                           struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  int32_t cnt = 0;
  int32_t pn = 0;
  int32_t lenses[XLANG_GP_PENDING_MAX];
  uint8_t names[XLANG_GP_PENDING_MAX][64];
  int32_t i;
  if (!out || !count || !source)
    return;
  cur = lex;
  memset(lenses, 0, sizeof(lenses));
  memset(names, 0, sizeof(names));
  (void)parser_asm_skip_generic_angle_list_count_into_c(&cur, source, &cnt, (uint8_t *)names, lenses, &pn);
  *out = cur;
  *count = cnt;
  g_gp_pending_n = pn < 0 ? 0 : (pn > XLANG_GP_PENDING_MAX ? XLANG_GP_PENDING_MAX : pn);
  memset(g_gp_pending_lens, 0, sizeof(g_gp_pending_lens));
  memset(g_gp_pending_names, 0, sizeof(g_gp_pending_names));
  for (i = 0; i < g_gp_pending_n; i++) {
    g_gp_pending_lens[i] = lenses[i];
    memcpy(g_gp_pending_names[i], names[i], 64);
  }
}
#else
void parser_asm_skip_generic_angle_list_count_into_slice_c(struct parser_asm_lexer *out, int32_t *count,
                                                           struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_start;
  int32_t depth;
  int32_t top_count;
  int32_t saw_any;
  int32_t expect_tp;
  if (!out || !count || !source)
    return;
  lex_start = lex;
  depth = 0;
  top_count = 0;
  saw_any = 0;
  expect_tp = 0;
  g_gp_pending_n = 0;
  memset(g_gp_pending_lens, 0, sizeof(g_gp_pending_lens));
  for (;;) {
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LT) {
      depth++;
      if (depth == 1)
        expect_tp = 1;
    } else if (r.tok.kind == (int32_t)TOKEN_GT) {
      depth--;
      if (depth <= 0) {
        out->pos = r.next_lex.pos;
        out->line = r.next_lex.line;
        out->col = r.next_lex.col;
        *count = saw_any ? (top_count + 1) : 0;
        return;
      }
    } else if (r.tok.kind == (int32_t)TOKEN_COMMA) {
      if (depth == 1) {
        top_count++;
        expect_tp = 1;
      }
    } else if (r.tok.kind == (int32_t)TOKEN_COLON) {
      if (depth == 1)
        expect_tp = 0; /* bound trait name follows — not a type-param name */
    } else if (r.tok.kind == (int32_t)TOKEN_IDENT && depth == 1 && expect_tp) {
      /* wave455: capture type-param IDENT at declaration position. */
      if (g_gp_pending_n < XLANG_GP_PENDING_MAX) {
        int32_t pl = r.tok.ident_len > 63 ? 63 : r.tok.ident_len;
        memset(g_gp_pending_names[g_gp_pending_n], 0, 64);
        if (pl > 0 && source->data) {
          size_t ts = r.token_start;
          if (ts == 0 && pl > 0 && r.next_lex.pos >= (size_t)pl)
            ts = r.next_lex.pos - (size_t)pl;
          if (ts + (size_t)pl <= source->length)
            memcpy(g_gp_pending_names[g_gp_pending_n], source->data + ts, (size_t)pl);
        }
        g_gp_pending_lens[g_gp_pending_n] = pl;
        g_gp_pending_n++;
      }
      expect_tp = 0;
      saw_any = 1;
    } else if (r.tok.kind == (int32_t)TOKEN_EOF
               || parser_asm_angle_list_token_is_stmt_boundary_c(r.tok.kind)
               || (depth == 1 && r.tok.kind == (int32_t)TOKEN_RPAREN)) {
      out->pos = lex_start.pos;
      out->line = lex_start.line;
      out->col = lex_start.col;
      *count = 0;
      g_gp_pending_n = 0;
      return;
    } else {
      if (depth == 1)
        saw_any = 1;
    }
    lex = r.next_lex;
  }
}
#endif /* XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X count walk */

/**
 * wave455: register pending type-param names under a function name into the
 * shared g_fn_gp_* table used by typeck ret fixup.
 * Must be called immediately after counting a function's angle list (before
 * body parse overwrites pending via call-site turbofish counts).
 * @return number of names registered, or -1 on full/overflow
 * PLATFORM: SHARED — twin of scan-time capture in skip_tl.
 */
#ifdef XLANG_PTHIN_LEX_SKIP_PENDING_FROM_X
/* PLATFORM: SHARED — P1g trampoline. Language has no file-local statics;
 * .x does null/empty guards then calls register_type_params_c. */
extern int32_t xlang_generic_func_register_pending_type_params_x_into_c(const uint8_t *fn_name,
                                                                       int32_t fn_name_len,
                                                                       const uint8_t *names,
                                                                       const int32_t *lens,
                                                                       int32_t pending_n);
int32_t xlang_generic_func_register_pending_type_params_c(const uint8_t *fn_name, int32_t fn_name_len) {
  return xlang_generic_func_register_pending_type_params_x_into_c(
      fn_name, fn_name_len, (const uint8_t *)g_gp_pending_names, g_gp_pending_lens, g_gp_pending_n);
}
#else
int32_t xlang_generic_func_register_pending_type_params_c(const uint8_t *fn_name, int32_t fn_name_len) {
  extern int32_t xlang_generic_func_register_type_params_c(const uint8_t *fn_name, int32_t fn_name_len,
                                                            const uint8_t names[][64], const int32_t *lens,
                                                            int32_t n);
  if (!fn_name || fn_name_len <= 0 || g_gp_pending_n <= 0)
    return 0;
  return xlang_generic_func_register_type_params_c(fn_name, fn_name_len, g_gp_pending_names,
                                                     g_gp_pending_lens, g_gp_pending_n);
}
#endif /* XLANG_PTHIN_LEX_SKIP_PENDING_FROM_X */

/** buf 路径：跳过 `<...>` 泛型列表。 */
void parser_skip_generic_angle_list_into_buf_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                  uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 source;
  if (!out || !data)
    return;
  source.data = data;
  source.length = len >= 0 ? (size_t)len : 0;
  parser_asm_skip_generic_angle_list_into_slice_c(out, lex, &source);
}

void parser_skip_generic_angle_list_count_into_glue(struct lexer_Lexer *out, int32_t *count, struct lexer_Lexer lex,
                                                    struct xlang_slice_uint8_t *source) {
  struct parser_asm_lexer aout;
  struct parser_asm_lexer alex;
  struct parser_asm_slice_u8 asrc;
  int32_t c = 0;
  if (!out || !count || !source)
    return;
  alex.pos = lex.pos;
  alex.line = lex.line;
  alex.col = lex.col;
  asrc.data = source->data;
  asrc.length = source->length;
  parser_asm_skip_generic_angle_list_count_into_slice_c(&aout, &c, alex, &asrc);
  out->pos = aout.pos;
  out->line = aout.line;
  out->col = aout.col;
  *count = c;
}

/** parser_gen / parser.x 用 lexer_Lexer ABI 跳过 `<...>` 泛型列表。 */
void parser_skip_generic_angle_list_into_glue(struct lexer_Lexer *out, struct lexer_Lexer lex,
                                            struct xlang_slice_uint8_t *source) {
  struct parser_asm_lexer aout;
  struct parser_asm_lexer alex;
  struct parser_asm_slice_u8 asrc;
  if (!out || !source)
    return;
  alex.pos = lex.pos;
  alex.line = lex.line;
  alex.col = lex.col;
  asrc.data = source->data;
  asrc.length = source->length;
  parser_asm_skip_generic_angle_list_into_slice_c(&aout, alex, &asrc);
  out->pos = aout.pos;
  out->line = aout.line;
  out->col = aout.col;
}

#ifndef XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X
#endif /* !XLANG_PTHIN_LEX_SKIP_BODIES_FROM_X */

#endif /* PARSER_ASM_LEX_SKIP_SLICE_INCLUDED */
