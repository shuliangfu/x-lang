/**
 * parser_asm_expr_binop_slice.inc — parse_term_into / parse_addsub_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * cast/unary/as_suffix 已 thin delegate；本 slice 处理 expr 左结合二元链至 compare。
 * P2 Darwin -o: 1-token peek cache (term…logor share one unconsumed token).
 * P2 Darwin -o: parse_logor had two identical || chains from the same start
 * lex (stretch padding → every expr parsed twice). Product keeps one.
 * single_tok_chain audit_fn uses PARSER_ASM_STRETCH_AUDIT_CALL (was un-gated).
 *
 * Hybrid P4bb: XLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X skips the portable
 * TOKEN→ExprKind table (body in pthin_expr_binop.x). wrap / parse / arena
 * stay here. Contiguous already-T AUDIT_CALL padding on parse_logor is
 * compiled only under XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is nop).
 * PLATFORM: SHARED. Do not assemble parser.x.
 */
#ifndef PARSER_ASM_EXPR_BINOP_SLICE_INCLUDED
#define PARSER_ASM_EXPR_BINOP_SLICE_INCLUDED

enum {
  PARSER_ASM_EXPR_MUL = 6,
  PARSER_ASM_EXPR_DIV = 7,
  PARSER_ASM_EXPR_MOD = 8,
  PARSER_ASM_EXPR_ADD = 4,
  PARSER_ASM_EXPR_SUB = 5,
  PARSER_ASM_EXPR_SHL = 9,
  PARSER_ASM_EXPR_SHR = 10,
  PARSER_ASM_EXPR_EQ = 14,
  PARSER_ASM_EXPR_NE = 15,
  PARSER_ASM_EXPR_LT = 16,
  PARSER_ASM_EXPR_LE = 17,
  PARSER_ASM_EXPR_GT = 18,
  PARSER_ASM_EXPR_GE = 19,
  PARSER_ASM_EXPR_BITAND = 11,
  PARSER_ASM_EXPR_BITOR = 12,
  PARSER_ASM_EXPR_BITXOR = 13,
  PARSER_ASM_EXPR_LOGAND = 20,
  PARSER_ASM_EXPR_LOGOR = 21
};

/* PLATFORM: SHARED — 7.2.1 P4bb. pthin_expr_binop.x EXPR_* pins. */
_Static_assert(PARSER_ASM_EXPR_ADD == 4, "binop.x EXPR_ADD pin");
_Static_assert(PARSER_ASM_EXPR_SUB == 5, "binop.x EXPR_SUB pin");
_Static_assert(PARSER_ASM_EXPR_MUL == 6, "binop.x EXPR_MUL pin");
_Static_assert(PARSER_ASM_EXPR_DIV == 7, "binop.x EXPR_DIV pin");
_Static_assert(PARSER_ASM_EXPR_MOD == 8, "binop.x EXPR_MOD pin");
_Static_assert(PARSER_ASM_EXPR_SHL == 9, "binop.x EXPR_SHL pin");
_Static_assert(PARSER_ASM_EXPR_SHR == 10, "binop.x EXPR_SHR pin");
_Static_assert(PARSER_ASM_EXPR_BITAND == 11, "binop.x EXPR_BITAND pin");
_Static_assert(PARSER_ASM_EXPR_BITOR == 12, "binop.x EXPR_BITOR pin");
_Static_assert(PARSER_ASM_EXPR_BITXOR == 13, "binop.x EXPR_BITXOR pin");
_Static_assert(PARSER_ASM_EXPR_EQ == 14, "binop.x EXPR_EQ pin");
_Static_assert(PARSER_ASM_EXPR_NE == 15, "binop.x EXPR_NE pin");
_Static_assert(PARSER_ASM_EXPR_LT == 16, "binop.x EXPR_LT pin");
_Static_assert(PARSER_ASM_EXPR_LE == 17, "binop.x EXPR_LE pin");
_Static_assert(PARSER_ASM_EXPR_GT == 18, "binop.x EXPR_GT pin");
_Static_assert(PARSER_ASM_EXPR_GE == 19, "binop.x EXPR_GE pin");
_Static_assert(PARSER_ASM_EXPR_LOGAND == 20, "binop.x EXPR_LOGAND pin");
_Static_assert(PARSER_ASM_EXPR_LOGOR == 21, "binop.x EXPR_LOGOR pin");

int32_t parser_asm_binop_token_to_expr_kind_c(int32_t kind);

extern void parser_parse_cast_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                   struct parser_asm_parse_expr_result *out);
extern void parser_parse_term_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                   struct parser_asm_parse_expr_result *out);
extern void parser_parse_addsub_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);
extern void parser_parse_shift_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                    struct parser_asm_parse_expr_result *out);
extern void parser_parse_relcompare_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out);
extern void parser_parse_compare_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                      struct parser_asm_parse_expr_result *out);
extern void parser_parse_bitand_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);
extern void parser_parse_bitxor_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);
extern void parser_parse_bitor_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                    struct parser_asm_parse_expr_result *out);
extern void parser_parse_logand_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);

static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae);
void parser_asm_expr_set_common_zeros_c(struct parser_asm_ast_expr *e);
/* parser_asm_lex_from_result_val_into: provided by P1 lex_skip (non-static) */
struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);

extern int32_t parser_asm_stretch_expr_binop_lower_chain_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_binop_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_ultra_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_super_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_expr_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_stmt_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_binop_full_chain_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_binop_upper_chain_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_binop_mid_chain_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_mul_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_addsub_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_shift_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_rel_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_eq_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_bitand_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_bitxor_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_bitor_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_logand_binop_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_expr_logor_binop_audit_c(void *lex_inout, void *source);

/** 分配二元节点并写入 left/right/kind。 */
static int32_t parser_asm_binop_wrap_c(void *arena, struct parser_asm_parse_expr_result *out, int32_t kind,
                                       int32_t left_ref, int32_t right_ref) {
  int32_t bin_ref;
  struct parser_asm_ast_expr be;
  if (!arena || !out)
    return 0;
  bin_ref = ast_ast_arena_expr_alloc(arena);
  if (bin_ref == 0) {
    out->ok = 0;
    return 0;
  }
  be = parser_asm_arena_expr_get_c(arena, bin_ref);
  parser_asm_expr_set_common_zeros_c(&be);
  be.kind = kind;
  be.binop_left_ref = left_ref;
  be.binop_right_ref = right_ref;
  be.line = 0;
  be.col = 0;
  parser_asm_arena_expr_set_c(arena, bin_ref, be);
  out->expr_ref = bin_ref;
  return bin_ref;
}

/**
 * One-token peek cache for left-assoc binop chains in this slice.
 *
 * Produce: each precedence level calls lexer_next_into from the same
 * unconsumed lex pos after lower() already peeked-and-restored. A typical
 * primary (call / ident / lit) therefore re-lexes the following token once
 * per level (term, addsub, shift, rel, eq, bitand, bitxor, bitor, logand,
 * logor) — ten times for ')' / ',' / ';' / EOF.
 * Store: __thread last (source data/len + lex pos/line/col) → lexer result.
 * Consume: this slice's peek-and-restore loops. Matching an operator
 * invalidates; mismatch keeps the slot so the parent level hits.
 * PLATFORM: SHARED — TLS so large-stack / dep threads do not clobber.
 * Do not assemble parser.x; product authority is this .inc via
 * pthin_expr_binop.from_x.c (XLANG_PTHIN_EXPR_BINOP_FROM_X).
 */
static __thread int32_t g_pipe_binop_peek_ok;
static __thread uint8_t *g_pipe_binop_peek_data;
static __thread size_t g_pipe_binop_peek_len;
static __thread size_t g_pipe_binop_peek_pos;
static __thread int32_t g_pipe_binop_peek_line;
static __thread int32_t g_pipe_binop_peek_col;
static __thread struct parser_asm_lexer_result g_pipe_binop_peek_r;

static void parser_asm_binop_lex_peek_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                                           struct parser_asm_slice_u8 *source) {
  if (!out)
    return;
  if (source && g_pipe_binop_peek_ok != 0 && g_pipe_binop_peek_data == source->data &&
      g_pipe_binop_peek_len == source->length && g_pipe_binop_peek_pos == lex.pos &&
      g_pipe_binop_peek_line == lex.line && g_pipe_binop_peek_col == lex.col) {
    *out = g_pipe_binop_peek_r;
    return;
  }
  lexer_next_into(out, lex, source);
  if (!source)
    return;
  g_pipe_binop_peek_ok = 1;
  g_pipe_binop_peek_data = source->data;
  g_pipe_binop_peek_len = source->length;
  g_pipe_binop_peek_pos = lex.pos;
  g_pipe_binop_peek_line = lex.line;
  g_pipe_binop_peek_col = lex.col;
  g_pipe_binop_peek_r = *out;
}

static void parser_asm_binop_lex_advance_from_peek(struct parser_asm_lexer *lex_inout,
                                                   struct parser_asm_lexer_result r) {
  parser_asm_lex_from_result_val_into(lex_inout, r);
  g_pipe_binop_peek_ok = 0;
}


#ifndef XLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X
/**
 * Map binary-operator token → ExprKind ordinal, or -1.
 * PLATFORM: SHARED — G.7 single TOKEN→ExprKind table for binary ops.
 * Do not merge with unary_token_to_expr_kind (STAR/AMP/MINUS differ).
 */
int32_t parser_asm_binop_token_to_expr_kind_c(int32_t kind) {
  if (kind == (int32_t)TOKEN_STAR)
    return PARSER_ASM_EXPR_MUL;
  if (kind == (int32_t)TOKEN_SLASH)
    return PARSER_ASM_EXPR_DIV;
  if (kind == (int32_t)TOKEN_PERCENT)
    return PARSER_ASM_EXPR_MOD;
  if (kind == (int32_t)TOKEN_PLUS)
    return PARSER_ASM_EXPR_ADD;
  if (kind == (int32_t)TOKEN_MINUS)
    return PARSER_ASM_EXPR_SUB;
  if (kind == (int32_t)TOKEN_LSHIFT)
    return PARSER_ASM_EXPR_SHL;
  if (kind == (int32_t)TOKEN_RSHIFT)
    return PARSER_ASM_EXPR_SHR;
  if (kind == (int32_t)TOKEN_AMP)
    return PARSER_ASM_EXPR_BITAND;
  if (kind == (int32_t)TOKEN_PIPE)
    return PARSER_ASM_EXPR_BITOR;
  if (kind == (int32_t)TOKEN_CARET)
    return PARSER_ASM_EXPR_BITXOR;
  if (kind == (int32_t)TOKEN_EQ)
    return PARSER_ASM_EXPR_EQ;
  if (kind == (int32_t)TOKEN_NE)
    return PARSER_ASM_EXPR_NE;
  if (kind == (int32_t)TOKEN_LT)
    return PARSER_ASM_EXPR_LT;
  if (kind == (int32_t)TOKEN_LE)
    return PARSER_ASM_EXPR_LE;
  if (kind == (int32_t)TOKEN_GT)
    return PARSER_ASM_EXPR_GT;
  if (kind == (int32_t)TOKEN_GE)
    return PARSER_ASM_EXPR_GE;
  if (kind == (int32_t)TOKEN_AMPAMP)
    return PARSER_ASM_EXPR_LOGAND;
  if (kind == (int32_t)TOKEN_PIPEPIPE)
    return PARSER_ASM_EXPR_LOGOR;
  return -1;
}
#endif /* !XLANG_PTHIN_EXPR_BINOP_BODIES_FROM_X */

/** parse_term_into：cast ( (*|/|%) cast )*。 */
void parser_asm_parse_term_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                        struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_cast_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_lower_chain_audit_c(&out->next_lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_mul_binop_audit_c(&out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    parser_asm_binop_lex_peek_into(&r, lex_cur, source);
    kind = parser_asm_binop_token_to_expr_kind_c(r.tok.kind);
    if (kind != PARSER_ASM_EXPR_MUL && kind != PARSER_ASM_EXPR_DIV && kind != PARSER_ASM_EXPR_MOD) {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_binop_lex_advance_from_peek(&lex_cur, r);
    parser_parse_cast_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_addsub_into：term ( (+|-) term )*。 */
void parser_asm_parse_addsub_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_term_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_addsub_binop_audit_c(&out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    parser_asm_binop_lex_peek_into(&r, lex_cur, source);
    kind = parser_asm_binop_token_to_expr_kind_c(r.tok.kind);
    if (kind != PARSER_ASM_EXPR_ADD && kind != PARSER_ASM_EXPR_SUB) {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_binop_lex_advance_from_peek(&lex_cur, r);
    parser_parse_term_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_shift_into：addsub ( (<<|>>) addsub )*。 */
void parser_asm_parse_shift_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_addsub_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_shift_binop_audit_c(&out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    parser_asm_binop_lex_peek_into(&r, lex_cur, source);
    kind = parser_asm_binop_token_to_expr_kind_c(r.tok.kind);
    if (kind != PARSER_ASM_EXPR_SHL && kind != PARSER_ASM_EXPR_SHR) {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_binop_lex_advance_from_peek(&lex_cur, r);
    parser_parse_addsub_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_relcompare_into：shift ( (<|<=|>|>=) shift )*。 */
void parser_asm_parse_relcompare_into_slice_c(void *arena, struct parser_asm_lexer lex,
                                              struct parser_asm_slice_u8 *source,
                                              struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_shift_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_upper_chain_audit_c(&out->next_lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_rel_binop_audit_c(&out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    parser_asm_binop_lex_peek_into(&r, lex_cur, source);
    kind = parser_asm_binop_token_to_expr_kind_c(r.tok.kind);
    if (kind != PARSER_ASM_EXPR_LT && kind != PARSER_ASM_EXPR_LE && kind != PARSER_ASM_EXPR_GT
        && kind != PARSER_ASM_EXPR_GE) {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_binop_lex_advance_from_peek(&lex_cur, r);
    parser_parse_shift_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_compare_into：relcompare ( (==|!=) relcompare )*。 */
void parser_asm_parse_compare_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                           struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_relcompare_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_eq_binop_audit_c(&out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    parser_asm_binop_lex_peek_into(&r, lex_cur, source);
    kind = parser_asm_binop_token_to_expr_kind_c(r.tok.kind);
    if (kind != PARSER_ASM_EXPR_EQ && kind != PARSER_ASM_EXPR_NE) {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_binop_lex_advance_from_peek(&lex_cur, r);
    parser_parse_relcompare_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** 单 token 左结合二元链：首 operand 已由 lower 解析。 */
static void parser_asm_binop_single_tok_chain_c(void *arena, struct parser_asm_lexer lex,
                                                struct parser_asm_slice_u8 *source,
                                                struct parser_asm_parse_expr_result *out, int32_t tok_kind,
                                                int32_t expr_kind,
                                                void (*lower)(void *, struct parser_asm_lexer, struct parser_asm_slice_u8 *,
                                                              struct parser_asm_parse_expr_result *),
                                                int32_t (*audit_fn)(void *,
                                                                    void *)) { /* B-minus pointer ABI */
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t left_ref;
  if (!out || !source || !lower)
    return;
  lower(arena, lex, source, out);
  if (!out->ok)
    return;
  /* Stretch probes re-lex the next token. Product builds leave
   * XLANG_PARSER_STRETCH_AUDIT undefined so PARSER_ASM_STRETCH_AUDIT_CALL
   * is a no-op; this audit_fn path used to bypass that gate and extra-lex
   * every bitand…logor expression. Keep the call only when the gate is on.
   * PLATFORM: SHARED — same gate as sibling term/addsub/shift/rel/eq. */
  if (audit_fn)
    PARSER_ASM_STRETCH_AUDIT_CALL(audit_fn(&out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    parser_asm_binop_lex_peek_into(&r, lex_cur, source);
    if (r.tok.kind != tok_kind) {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_binop_lex_advance_from_peek(&lex_cur, r);
    lower(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, expr_kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_bitand_into：compare ( & compare )*。 */
void parser_asm_parse_bitand_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_AMP, PARSER_ASM_EXPR_BITAND,
                                      parser_parse_compare_into, parser_asm_stretch_expr_bitand_binop_audit_c);
}

/** parse_bitxor_into：bitand ( ^ bitand )*。 */
void parser_asm_parse_bitxor_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_CARET, PARSER_ASM_EXPR_BITXOR,
                                      parser_parse_bitand_into, parser_asm_stretch_expr_bitxor_binop_audit_c);
}

/** parse_bitor_into：bitxor ( | bitxor )*。 */
void parser_asm_parse_bitor_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out) {
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_PIPE, PARSER_ASM_EXPR_BITOR,
                                      parser_parse_bitxor_into, parser_asm_stretch_expr_bitor_binop_audit_c);
}

/** parse_logand_into：bitor ( && bitor )*。 */
void parser_asm_parse_logand_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_mid_chain_audit_c(&lex, source));
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_AMPAMP, PARSER_ASM_EXPR_LOGAND,
                                      parser_parse_bitor_into, parser_asm_stretch_expr_logand_binop_audit_c);
}

/** parse_logor_into：logand ( || logand )*。 */
void parser_asm_parse_logor_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out) {
#ifdef XLANG_PARSER_STRETCH_AUDIT
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_full_chain_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_stmt_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_ultra_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_super_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
#endif /* XLANG_PARSER_STRETCH_AUDIT */
  /* One || chain from the original lex. A second identical call was stretch
   * padding: it re-parsed every expression from the same start (logor is the
   * top of parse_expr) and overwrote out. Product hello -o sample was then
   * ~2× Pratt. Stretch audits above stay (no-op unless XLANG_PARSER_STRETCH_AUDIT).
   * PLATFORM: SHARED — do not assemble parser.x. */
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_PIPEPIPE, PARSER_ASM_EXPR_LOGOR,
                                      parser_parse_logand_into, parser_asm_stretch_expr_logor_binop_audit_c);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_expr_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
}

#endif /* PARSER_ASM_EXPR_BINOP_SLICE_INCLUDED */
