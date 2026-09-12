/* seeds/pthin_diag_pipeline.from_x.c — G-02f-325 P2 parser thin diag pipeline
 * Logic source: src/asm/pthin_diag_pipeline.x
 * Hybrid: XLANG_PTHIN_DIAG_PIPELINE_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_diag_pipeline_slice.inc (~914)
 * onefunc_wired + diag_parse_one_after_collect + parse_one_function_ok + module import getters + diag_lex_after
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"
#include "ast.h"

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

struct parser_asm_onefunc_result {
  int32_t ok;
  struct parser_asm_lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t num_consts;
  int32_t num_lets;
  int32_t has_if_expr;
  int32_t if_cond_true;
  int32_t if_then_val;
  int32_t if_else_val;
  int32_t if_cond_expr_ref;
  int32_t has_mul;
  int32_t mul_right_val;
  int32_t has_binop;
  int32_t binop_right_val;
  int32_t binop_left_param_idx;
  int32_t binop_right_param_idx;
  int32_t has_unary_neg;
  int32_t return_val;
  int32_t has_call_expr;
  uint8_t call_callee_name[256];
  int32_t call_callee_len;
  uint8_t return_var_name[256];
  int32_t return_var_name_len;
  int32_t return_expr_ref;
  int32_t has_final_expr;
  int32_t has_explicit_return_kw;
  int32_t call_num_args;
  int32_t num_loops;
  int32_t num_for_loops;
  int32_t num_if_stmts;
  int32_t num_src_stmt_order;
  int32_t num_src_body_expr_stmts;
  int32_t func_return_type_ref;
};


extern void parser_asm_collect_imports_slice_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source, void *module, struct parser_asm_collect_imports_result *out);
extern struct parser_asm_lexer parser_asm_lexer_init_c(void);
extern struct parser_asm_lexer parser_asm_skip_imports_slice_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_diag_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_after_collect_preamble_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_diag_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_fn_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_lex_after_imports_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_diag_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_parse_one_after_collect_imports_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_parse_one_collect_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_parse_one_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_parse_one_mega_full_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_parse_ultra_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_super_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_toplevel_after_imports_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_diag_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_ultra2_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_diag_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_vx_diag_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_parse_one_function_ok_for_pipeline_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_parse_one_function_ok_for_pipeline_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_parse_one_function_ok_pipeline_deep_buf_audit_c(void *lex_inout, uint8_t *data, int32_t len);
extern void parser_onefunc_res_wire_dummy_call_binop(struct parser_asm_onefunc_result *res, uint8_t *name64);
extern void parser_onefunc_res_wire_dummy_const_let(struct parser_asm_onefunc_result *res);
extern void parser_onefunc_res_wire_dummy_for_if(struct parser_asm_onefunc_result *res);
extern void parser_onefunc_res_wire_dummy_head(struct parser_asm_onefunc_result *res, struct parser_asm_lexer lex, uint8_t *name64);
extern void parser_onefunc_res_wire_dummy_if_mul(struct parser_asm_onefunc_result *res);
extern void parser_onefunc_res_wire_dummy_loop_call(struct parser_asm_onefunc_result *res);
extern struct parser_asm_onefunc_result parser_onefunc_scratch_empty(void);
extern void parser_parse_one_function_impl(struct parser_asm_onefunc_result *res, void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern void pipeline_module_import_path_copy(struct ASTModule *module, int32_t idx, uint8_t *dst, int32_t dst_cap);

#include "parser_asm_diag_pipeline_slice.inc"

int labi_pthin_diag_pipeline_slice_marker(void) {
  return 1;
}
