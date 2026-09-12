/* seeds/pthin_skip_if.from_x.c — G-02f-323 P2 parser thin skip_if
 * Logic source: src/asm/pthin_skip_if.x
 * Hybrid: XLANG_PTHIN_SKIP_IF_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_skip_if_slice.inc (~955)
 * skip_trait_impl_block_raw + skip_one_if_core/statement + module_try_register_enum
 *
 * Hybrid P14b (XLANG_PTHIN_SKIP_IF_BODIES_FROM_X): portable skip walks
 * come from pthin_skip_if.x; this TU keeps by-value trampolines plus
 * enum-register C. Cold: no BODIES define, full .inc.
 * Do not reuse XLANG_PTHIN_SKIP_IF_FROM_X for P14b bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P14b B-minus (2026-09-13).
 * pthin_skip_if.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_EOF == 0, "skip_if.x TOKEN_EOF pin");
_Static_assert((int)TOKEN_IF == 4, "skip_if.x TOKEN_IF pin");
_Static_assert((int)TOKEN_ELSE == 5, "skip_if.x TOKEN_ELSE pin");
_Static_assert((int)TOKEN_TRAIT == 49, "skip_if.x TOKEN_TRAIT pin");
_Static_assert((int)TOKEN_IMPL == 50, "skip_if.x TOKEN_IMPL pin");
_Static_assert((int)TOKEN_LPAREN == 82, "skip_if.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_LBRACE == 84, "skip_if.x TOKEN_LBRACE pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "skip_if.x TOKEN_SEMICOLON pin");

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};




extern struct parser_asm_lexer_result lexer_next_buf(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *data);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_skip_balanced_braces_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern void parser_asm_skip_balanced_braces_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern struct parser_asm_lexer parser_asm_skip_balanced_parens_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern void parser_asm_skip_balanced_parens_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_cond_int_as_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_control_flow_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_super_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_ultra_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_else_if_chain_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_else_stmt_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_body_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_body_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_if_control_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_control_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_if_else_chain_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_else_chain_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_if_header_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_stmt_body_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_stmt_body_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_if_stmt_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_stmt_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_parse_cond_expr_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_skip_one_if_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_skip_one_if_core_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_skip_one_if_core_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_skip_one_if_else_chain_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_skip_one_if_else_chain_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t pipeline_module_enum_alloc(void *module);
extern uint8_t pipeline_module_enum_name_byte_at(void *module, int32_t idx, int32_t off);
extern int32_t pipeline_module_enum_name_len(void *module, int32_t idx);
extern void pipeline_module_enum_set_name(void *module, int32_t idx, uint8_t *bytes, int32_t len);

#ifdef XLANG_PTHIN_SKIP_IF_BODIES_FROM_X
/* .x product bodies (pointer ABI). C names stay on the trampolines. */
extern int32_t parser_asm_skip_trait_impl_block_raw_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_one_if_core_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_one_if_statement_into_c(void *lex_inout, void *source);

void parser_asm_skip_trait_impl_block_raw_c(struct parser_asm_lexer *out, struct parser_asm_lexer start,
                                            struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source || !source->data)
    return;
  cur = start;
  (void)parser_asm_skip_trait_impl_block_raw_into_c(&cur, source);
  *out = cur;
}

void parser_asm_skip_one_if_core_into_slice_c(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_skip_one_if_core_into_c(&cur, source);
  lexer_next_into(out, cur, source);
}

struct parser_asm_lexer_result parser_asm_skip_one_if_core_buf_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                int32_t len) {
  struct parser_asm_slice_u8 sl;
  struct parser_asm_lexer_result r;
  sl.data = data;
  sl.length = len >= 0 ? (size_t)len : 0;
  parser_asm_skip_one_if_core_into_slice_c(&r, lex, &sl);
  return r;
}

void parser_asm_skip_one_if_statement_into_slice_c(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                                                  struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_skip_one_if_statement_into_c(&cur, source);
  lexer_next_into(out, cur, source);
}

struct parser_asm_lexer_result parser_asm_skip_one_if_statement_buf_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                     int32_t len) {
  struct parser_asm_slice_u8 sl;
  struct parser_asm_lexer_result r;
  sl.data = data;
  sl.length = len >= 0 ? (size_t)len : 0;
  parser_asm_skip_one_if_statement_into_slice_c(&r, lex, &sl);
  return r;
}
#endif /* XLANG_PTHIN_SKIP_IF_BODIES_FROM_X */

#include "parser_asm_skip_if_slice.inc"

int labi_pthin_skip_if_slice_marker(void) {
  return 1;
}
