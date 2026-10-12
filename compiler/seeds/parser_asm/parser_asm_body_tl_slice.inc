/* parser_asm_body_tl_slice.inc — G-02f-327 P18 body/diag residual + top_level skip
 * Hybrid: XLANG_PTHIN_BODY_TL_FROM_X via seeds/pthin_body_tl.from_x.c
 * is_fn_sig_scalar + diag_first_ident + diag_skip_let_const_into + body_skip_into
 * + skip_one_top_level_{let,const} + cfg_skip_pending_top_level
 *
 * Hybrid P18b/P18c/P18d: XLANG_PTHIN_BODY_TL_BODIES_FROM_X skips the portable
 * skip walks, the scalar TOKEN table, cfg_skip, diag_first_ident,
 * P010–P014 reports, and onefunc_param_name_dup (bodies in
 * src/asm/pthin_body_tl.x + by-value trampolines in the seed TU).
 * Sticky / allow_bare_self / cur_module file-statics stay here.
 * Cold: no define, full twin. Do not reuse XLANG_PTHIN_BODY_TL_FROM_X
 * for P18b/P18c/P18d bodies.
 */
#ifndef PARSER_ASM_BODY_TL_SLICE_INC
#define PARSER_ASM_BODY_TL_SLICE_INC

/* Forward decls: defined in skip_tl_slice.inc / glue_tail_slice.inc (G-02f-422 Ubuntu gcc fix) */
void parser_asm_skip_one_struct_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source);
void parser_asm_skip_one_function_full_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                    struct parser_asm_slice_u8 *source);

/**
 * wave422/423 Cap residual pure: hard P010 for illegal binding forms.
 * Root (wave422): missing COLON returned false with no diag → function dropped → soft P001
 * "no functions" / BLD001 missing _main. docs/06 bans let type inference.
 * wave423: const may omit `: Type` when followed by `= init` (type inferred in typeck);
 * this helper is only called for illegal forms (let without `:`, const without `:`/`=`).
 * G.7 authority: this helper; parse_body_lets_into + top_level_let call it.
 * @param line 1-based source line of the unexpected token after the binding name
 * @param col  1-based column
 * @param is_let 1 = let (docs ban inference); 0 = const (needs `: Type` or `= init`)
 * PLATFORM: SHARED parse.
 */
const char *parser_body_tl_p0xx_msg_c(int32_t id);

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X removed */
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X p010 */

/*
 * wave676 Cap residual: hard P011 for untyped function formals / missing return type.
 * Root: parse_one_function set_onefunc_fail with no diag → function dropped from AST;
 * buf path accepted `fn(x): i32` (RPAREN without param `: Type`) → typeck/codegen green.
 * G.7 authority: this helper + call sites in parser.x / parser_gen / one_function_buf_slice.
 * Sticky flag: parse_into_buf must abort (ok=-2) instead of soft-skip+continue.
 * @param line 1-based source line of the unexpected token
 * @param col  1-based column
 * @param kind 0 = param missing `: Type`; 1 = function missing return `: Type`
 * PLATFORM: SHARED parse.
 */
static int32_t g_parser_sig_type_hard = 0;

void parser_sig_type_hard_reset_c(void) { g_parser_sig_type_hard = 0; }

int32_t parser_sig_type_hard_pending_c(void) { return g_parser_sig_type_hard; }

/*
 * Completes the reset/pending accessor family so hybrid P18d .x reports
 * can raise the sticky without a mutable file-local i32 (language ban).
 * on != 0 → 1; on == 0 → 0. Cold C twins also call this (single write).
 * PLATFORM: SHARED parse.
 */
void parser_sig_type_hard_set_c(int32_t on) { g_parser_sig_type_hard = on ? 1 : 0; }

/*
 * Interned P010–P014 diagnostic messages. Bootstrap STRING_LIT is 64
 * bytes; several product msgs exceed that, so hybrid P18d .x reports
 * fetch the text here instead of embedding the literal.
 * id: 0 P010 let, 1 P010 const, 2 P011 param, 3 P011 return,
 *     4 P012 param, 5 P012 field, 6 P012 top-level, 7 P013, 8 P014.
 * Unknown id → NULL.
 * PLATFORM: SHARED parse — message text authority (do not fork wording
 * in .x). Always compiled (cold C twins inlined the same strings).
 */
const char *parser_body_tl_p0xx_msg_c(int32_t id) {
  if (id == 0)
    return "let requires type annotation (no type inference; write let name: Type = ...)";
  if (id == 1)
    return "const requires ': Type = init' or '= init' (type inferred from init)";
  if (id == 2)
    return "function parameter requires type annotation (write name: Type)";
  if (id == 3)
    return "function requires return type annotation (write ): Type { ... })";
  if (id == 4)
    return "duplicate parameter name in function signature";
  if (id == 5)
    return "duplicate field name in struct definition";
  if (id == 6)
    return "duplicate top-level binding name (module already declares this let/const; rename one)";
  if (id == 7)
    return "do not write 'dyn Trait'; write the trait name (e.g. let x: Clone = a)";
  if (id == 8)
    return "binding name must be an identifier, not a keyword";
  return NULL;
}

/*
 * 4.2.1 / wave676: product P011 rejects untyped formals, including free/inherent
 * `function m(self)`. Trait default hoist re-parses `function get(self): T {…}`
 * via the buf onefunc path and must be allowed to leave param0 type_ref=0;
 * commit then stamps the impl for-type (wave477).
 * Set 1 only around that hoist parse; always clear afterwards.
 * PLATFORM: SHARED parse.
 */
static int32_t g_parser_allow_bare_self = 0;

void parser_allow_bare_self_set_c(int32_t on) { g_parser_allow_bare_self = on ? 1 : 0; }

int32_t parser_allow_bare_self_pending_c(void) { return g_parser_allow_bare_self; }

/*
 * 9.6.3: module pointer installed by parser_cur_module_set_c around each
 * function-body parse (parse_into / parse_into_buf), read by parse_block_into
 * to desugar a function-local `static let/const` into a module top-level let.
 * C-side static because the parser.x pin carries no module-scope pointer
 * global; same pattern as g_parser_sig_type_hard above.
 * PLATFORM: SHARED parse.
 */
static void *g_parser_cur_module = 0;

void parser_cur_module_set_c(void *m) { g_parser_cur_module = m; }

void *parser_cur_module_get_c(void) { return g_parser_cur_module; }

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X p011-p014-dup */

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X is_fn_sig_scalar */




#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X diag_first_ident_len */

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X diag_skip_let_const */

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X body_skip_let_const_then_if */

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X skip_one_top_level_let */

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X skip_one_top_level_const */

#ifndef XLANG_PTHIN_BODY_TL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_BODY_TL_BODIES_FROM_X cfg_skip_pending */

#endif /* PARSER_ASM_BODY_TL_SLICE_INC */
