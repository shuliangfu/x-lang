/* seeds/pthin_imports.from_x.c — G-02f-320 P2 parser thin imports cluster
 * Logic source: src/asm/pthin_imports.x
 * Hybrid: XLANG_PTHIN_IMPORTS_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_imports_slice.inc (~1.8k)
 * skip_imports + try_skip_const_import + consume_path + collect_imports
 *
 * Hybrid P11b/P11c/P11d (XLANG_PTHIN_IMPORTS_BODIES_FROM_X): portable
 * skip_imports / consume_path / try_skip / collect_imports walks come
 * from pthin_imports.x; this TU keeps the by-value trampolines
 * (collect dest-buffers path/bind on the C stack; no file-statics).
 * Cold: no BODIES define, full .inc. Do not reuse
 * XLANG_PTHIN_IMPORTS_FROM_X for P11b/P11c/P11d bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"

/* PLATFORM: SHARED — 7.2.1 P11b/P11c/P11d B-minus (2026-09-13).
 * pthin_imports.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_CONST == 3, "imports.x TOKEN_CONST pin");
_Static_assert((int)TOKEN_ATTR_CFG == 24, "imports.x TOKEN_ATTR_CFG pin");
_Static_assert((int)TOKEN_IMPORT == 53, "imports.x TOKEN_IMPORT pin");
_Static_assert((int)TOKEN_IDENT == 59, "imports.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_LPAREN == 82, "imports.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_RPAREN == 83, "imports.x TOKEN_RPAREN pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "imports.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_ASSIGN == 117, "imports.x TOKEN_ASSIGN pin");
_Static_assert((int)TOKEN_STRING == 130, "imports.x TOKEN_STRING pin");

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

struct parser_asm_collect_imports_result {
  struct parser_asm_lexer lex;
};


/* same-TU order: try_skip_const_import 调用 consume_path（定义在后） */
int32_t parser_asm_collect_imports_consume_path(struct parser_asm_collect_imports_result *out,
                                                struct parser_asm_slice_u8 *source, uint8_t *path_buf,
                                                int32_t *path_len);

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *data);
extern void parser_asm_cfg_skip_pending_top_level_into_slice_c(struct parser_asm_lexer *lex, struct parser_asm_slice_u8 *source, int32_t *pending);
extern void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen, uint8_t *out);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_lexer_init_c(void);
extern int32_t parser_asm_stretch_collect_imports_bind_audit_c(const uint8_t *bind, int32_t bind_len);
extern int32_t parser_asm_stretch_collect_imports_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_collect_imports_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_collect_imports_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_collect_imports_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_collect_imports_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_collect_imports_post_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_collect_imports_preamble_audit_c(int32_t kind, int32_t next_kind, int32_t third_kind, void *source);
extern int32_t parser_asm_stretch_const_import_kw_audit_c(int32_t after_assign_kind);
extern int32_t parser_asm_stretch_diag_lex_after_imports_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_token_after_collect_imports_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_toplevel_after_imports_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_path_finalize_c(uint8_t *path_buf, int32_t path_len, const uint8_t *source, size_t source_len);
extern int32_t parser_asm_stretch_import_path_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_path_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_path_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_path_post_audit_c(uint8_t *path_buf, int32_t path_len, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_import_path_score_c(const uint8_t *path, int32_t path_len);
extern int32_t parser_asm_stretch_import_path_validate_c(const uint8_t *path, int32_t path_len);
extern int32_t parser_asm_stretch_import_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_select_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_stmt_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_stmt_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_stmt_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_super_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_super_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_ultra_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_ultra_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_import_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_import_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_import_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_import_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_peek_kind_chain_c(int32_t *kinds, int32_t max_peek, void *lex, void *source);
extern int32_t parser_asm_stretch_expr_binop_kinds_probe_c(const int32_t *kinds, int32_t num_kinds, void *lex, void *source);
extern int32_t parser_asm_stretch_skip_imports_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_skip_imports_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_skip_imports_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_toplevel_kind_peek_audit_c(void *lex_inout, void *source);
extern int32_t pipeline_module_import_alloc(void *module);
extern void pipeline_module_import_set_binding_name(void *module, int32_t idx, uint8_t *bytes, int32_t len);
extern void pipeline_module_import_set_kind(void *module, int32_t idx, int32_t kind);
extern void pipeline_module_import_set_path(void *module, int32_t idx, uint8_t *bytes, int32_t len);
extern void pipeline_module_import_set_select_count(void *module, int32_t idx, int32_t n);

#ifdef XLANG_PTHIN_IMPORTS_BODIES_FROM_X
/* .x product body (pointer ABI). C names stay on the trampolines. */
extern int32_t parser_asm_skip_imports_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_collect_imports_consume_path_into_c(void *lex_inout, void *source,
                                                             uint8_t *path_buf, int32_t *path_len);
extern int32_t parser_asm_try_skip_const_import_into_c(void *lex_inout, void *source,
                                                      uint8_t *path_buf, int32_t *path_len);
extern int32_t parser_asm_collect_imports_into_c(void *lex_inout, void *source, void *module,
                                                uint8_t *path_buf, uint8_t *bind_buf,
                                                int32_t *path_len);

/* Thin ABI adapter over P18 cfg_skip_pending (int32 pending in/out).
 * G.7: zero business logic; language has no address-of for a local i32. */
int32_t parser_asm_cfg_skip_pending_apply_c(void *lex, void *source, int32_t pending) {
  int32_t p = pending;
  if (!lex || !source || !p)
    return 0;
  parser_asm_cfg_skip_pending_top_level_into_slice_c((struct parser_asm_lexer *)lex,
                                                     (struct parser_asm_slice_u8 *)source, &p);
  return p;
}

struct parser_asm_lexer parser_asm_skip_imports_slice_c(struct parser_asm_lexer lex,
                                                      struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  cur = lex;
  if (source)
    parser_asm_skip_imports_into_c(&cur, source);
  return cur;
}

struct parser_asm_lexer parser_asm_skip_imports_buf_c(struct parser_asm_lexer lex, uint8_t *data,
                                                    int32_t len) {
  struct parser_asm_slice_u8 source;
  if (!data || len <= 0)
    return lex;
  source.data = data;
  source.length = (size_t)len;
  return parser_asm_skip_imports_slice_c(lex, &source);
}

/* Language has no local u8[128]; this trampoline owns the path scratch
 * and restores the C name. Null lex/source: 0, lexer unmoved. */
int32_t parser_asm_try_skip_const_import_stmt(struct parser_asm_lexer *lex,
                                             struct parser_asm_slice_u8 *source) {
  uint8_t path_buf[128];
  int32_t path_len = 0;
  if (!lex || !source)
    return 0;
  return parser_asm_try_skip_const_import_into_c(lex, source, path_buf, &path_len);
}

int32_t parser_asm_collect_imports_consume_path(struct parser_asm_collect_imports_result *out,
                                               struct parser_asm_slice_u8 *source, uint8_t *path_buf,
                                               int32_t *path_len) {
  if (!out || !source || !path_buf || !path_len)
    return 0;
  return parser_asm_collect_imports_consume_path_into_c(&out->lex, source, path_buf, path_len);
}

/* Language has no local u8[N]; this trampoline owns the 128-byte path
 * and binding scratches and restores the C name. Null source/out/module:
 * return unmoved. *out = cur after .x (no extra next; matches skip_imports). */
void parser_asm_collect_imports_slice_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source, void *module,
                                        struct parser_asm_collect_imports_result *out) {
  struct parser_asm_lexer cur;
  uint8_t path_buf[128];
  uint8_t bind_buf[128];
  int32_t path_len = 0;
  if (!source || !out || !module)
    return;
  memset(path_buf, 0, sizeof(path_buf));
  memset(bind_buf, 0, sizeof(bind_buf));
  cur = lex;
  (void)parser_asm_collect_imports_into_c(&cur, source, module, path_buf, bind_buf, &path_len);
  out->lex = cur;
}
#endif /* XLANG_PTHIN_IMPORTS_BODIES_FROM_X */

#include "parser_asm_imports_slice.inc"

int labi_pthin_imports_slice_marker(void) {
  return 1;
}
