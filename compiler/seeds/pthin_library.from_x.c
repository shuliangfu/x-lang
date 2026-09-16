/* seeds/pthin_library.from_x.c — G-02f-324 P2 parser thin library parse
 * Logic source: src/asm/pthin_library.x
 * Hybrid: XLANG_PTHIN_LIBRARY_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_library_wrap_slice.inc (~1.8k)
 * (not library_slice.inc — that is P6 core parse_one_function_library_slice_c)
 * parse_one_function_library_{into,buf,scan} + lex_from_{lr,try_skip,library}
 *
 * Hybrid P15b (XLANG_PTHIN_LIBRARY_BODIES_FROM_X): portable library_scan
 * walk comes from pthin_library.x; this TU keeps the by-value trampoline
 * plus into/buf parse and lex_from_* C. Cold: no BODIES define, full
 * .inc. Do not reuse XLANG_PTHIN_LIBRARY_FROM_X for P15b bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P15b B-minus (2026-09-13).
 * pthin_library.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_FUNCTION == 1, "library.x TOKEN_FUNCTION pin");
_Static_assert((int)TOKEN_RETURN == 11, "library.x TOKEN_RETURN pin");
_Static_assert((int)TOKEN_SPAWN == 58, "library.x TOKEN_SPAWN pin");
_Static_assert((int)TOKEN_IDENT == 59, "library.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_BOOL == 61, "library.x TOKEN_BOOL pin");
_Static_assert((int)TOKEN_LPAREN == 82, "library.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_RPAREN == 83, "library.x TOKEN_RPAREN pin");
_Static_assert((int)TOKEN_LBRACE == 84, "library.x TOKEN_LBRACE pin");
_Static_assert((int)TOKEN_RBRACE == 85, "library.x TOKEN_RBRACE pin");
_Static_assert((int)TOKEN_COLON == 91, "library.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_DOT == 92, "library.x TOKEN_DOT pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "library.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_EQ == 118, "library.x TOKEN_EQ pin");

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

struct parser_asm_library_parse_result {
  uint8_t ok;
  uint8_t _pad[4];
  struct parser_asm_lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  uint8_t _pad_tail[4];
};

struct parser_asm_library_parse_scan_result {
  uint8_t ok;
  uint8_t _pad[4];
  struct parser_asm_lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  uint8_t param_name[256];
  int32_t param_name_len;
  uint8_t param_type_name[256];
  int32_t param_type_len;
  uint8_t field_name[256];
  int32_t field_len;
  uint8_t _pad_tail[4];
  uint8_t _pad_tail2[4];
};

struct parser_asm_try_skip_allow_result {
  struct parser_asm_lexer lex;
  int32_t skipped;
  uint8_t _pad[4];
};




extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *data);
extern void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos, int32_t nlen, uint8_t *out);
extern void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen, uint8_t *out);
extern void parser_asm_copy_slice_to_param32_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen, uint8_t *out);
extern struct parser_asm_library_parse_result parser_asm_parse_one_function_library_slice_c( void *arena, void *module, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_function_name_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_library_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_field_bind_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_library_fn_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_fn_shape_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_fn_shape_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_param_bind_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_library_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_return_type_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_scan_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_scan_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_scan_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_scan_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_scan_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_super_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_super_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_ultra_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_ultra_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_library_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_library_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_library_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_library_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_spawn_kw_audit_c(int32_t after_function_kind);

#ifdef XLANG_PTHIN_LIBRARY_BODIES_FROM_X
/* .x product body (pointer ABI). C name stays on the trampoline. */
extern int32_t parser_asm_parse_one_function_library_scan_into_c(
    void *lex_inout, void *source, uint8_t *data, int32_t slen, uint8_t *name, int32_t *name_len,
    uint8_t *param_name, int32_t *param_name_len, uint8_t *param_type_name, int32_t *param_type_len,
    uint8_t *field_name, int32_t *field_len);

int32_t parser_asm_parse_one_function_library_scan_slice_c(struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source,
                                                            struct parser_asm_library_parse_scan_result *result) {
  struct parser_asm_lexer cur;
  int32_t ok;
  int32_t slen;
  if (!result || !source)
    return 0;
  result->ok = 0;
  cur = lex;
  slen = source->length > 0x7fffffffULL ? (int32_t)0x7fffffff : (int32_t)source->length;
  ok = parser_asm_parse_one_function_library_scan_into_c(
      &cur, source, source->data, slen, result->name, &result->name_len, result->param_name,
      &result->param_name_len, result->param_type_name, &result->param_type_len, result->field_name,
      &result->field_len);
  result->next_lex = cur;
  if (ok)
    result->ok = 1;
  return ok;
}
#endif /* XLANG_PTHIN_LIBRARY_BODIES_FROM_X */

#include "parser_asm_library_wrap_slice.inc"

int labi_pthin_library_slice_marker(void) {
  return 1;
}
