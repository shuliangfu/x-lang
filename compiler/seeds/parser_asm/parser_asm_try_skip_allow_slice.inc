/**
 * parser_asm_try_skip_allow_slice.inc — write_result / padding / parse_into.
 *
 * Hybrid P13b/P13c: XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X skips the
 * portable padding_struct walk plus the write_result / parse_into bodies
 * (bodies in src/asm/pthin_try_skip_allow.x + by-value trampolines in the
 * seed TU). Cold: no BODIES define, this file is the full twin.
 * Do not reuse XLANG_PTHIN_TRY_SKIP_ALLOW_FROM_X for P13b/P13c bodies.
 */
#ifdef XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X
/* Hybrid P13c: layout store body in pthin_try_skip_allow.x (byte-wise LE,
 * offsetof pins in the seed TU). C name stays on this trampoline so the
 * cold-twin call sites (padding twins below) keep one path. */
extern void parser_asm_write_try_skip_allow_result_fields_c(void *out, size_t pos, int32_t line, int32_t col,
                                                            int32_t skipped);
void parser_asm_write_try_skip_allow_result(struct parser_asm_try_skip_allow_result *out,
                                                   struct parser_asm_lexer lex, int32_t skipped) {
  if (!out)
    return;
  parser_asm_write_try_skip_allow_result_fields_c(out, lex.pos, lex.line, lex.col, skipped);
}
#else
/** 写入 TrySkipAllowResult 三字段（_pad 清零）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void parser_asm_write_try_skip_allow_result(struct parser_asm_try_skip_allow_result *out,
                                                   struct parser_asm_lexer lex, int32_t skipped) {
  if (!out)
    return;
  out->lex = lex;
  out->skipped = skipped;
  memset(out->_pad, 0, sizeof(out->_pad));
}
#endif /* !XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X write_result */




#ifndef XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X
/* Hybrid P13b: padding walk in src/asm/pthin_try_skip_allow.x; this C twin
 * is cold fallback. Do not reuse XLANG_PTHIN_TRY_SKIP_ALLOW_FROM_X. */
/**
 * try_skip_allow_padding_struct（slice 路径）：allow(padding) 前缀跳过 `( ... )`。
 */
struct parser_asm_try_skip_allow_result parser_asm_try_skip_allow_padding_struct_slice_c(
    struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result lr;
  struct parser_asm_try_skip_allow_result out;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_paren_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_ultra_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_super_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  lexer_next_into(&lr, lex, source);
  if (lr.tok.kind != (int32_t)TOKEN_LPAREN) {
    parser_asm_write_try_skip_allow_result(&out, lex, 0);
    return out;
  }
  parser_asm_write_try_skip_allow_result(&out, parser_asm_skip_balanced_parens_slice_c(lr.next_lex, source), 1);
  return out;
}

/**
 * try_skip_allow_padding_struct_buf：buf 路径等价实现。
 */
struct parser_asm_try_skip_allow_result parser_asm_try_skip_allow_padding_struct_buf_c(
    struct parser_asm_lexer lex, uint8_t *data, int32_t len) {
  struct parser_asm_lexer_result lr;
  struct parser_asm_try_skip_allow_result out;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_paren_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_ultra_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_super_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_try_skip_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
  lr = lexer_next_buf(lex, data, len);
  if (lr.tok.kind != (int32_t)TOKEN_LPAREN) {
    parser_asm_write_try_skip_allow_result(&out, lex, 0);
    return out;
  }
  parser_asm_write_try_skip_allow_result(&out, parser_asm_skip_balanced_parens_buf_c(lr.next_lex, data, len), 1);
  return out;
}
#endif /* !XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X */

/**
 * parse_into_try_skip_allow_into：主循环 allow(padding) 包装；结果写入 *out。
 * Hybrid P13c: gate + walk body in pthin_try_skip_allow.x (tri-state
 * core_c over the pointer ABI); this trampoline only adapts the by-value
 * lexer_result and writes the result via the P13c fields store.
 */
#ifdef XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X
extern int32_t parser_asm_parse_into_try_skip_allow_core_c(void *lex_inout, void *source, int32_t tok_kind,
                                                           int32_t tok_ident_len);
void parser_asm_parse_into_try_skip_allow_into_slice_c(struct parser_asm_try_skip_allow_result *out,
                                                       struct parser_asm_lexer lex,
                                                       struct parser_asm_lexer_result r,
                                                       struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  int32_t rc;
  if (!out)
    return;
  cur = r.next_lex;
  rc = parser_asm_parse_into_try_skip_allow_core_c(&cur, source, r.tok.kind, r.tok.ident_len);
  if (rc < 0) {
    parser_asm_write_try_skip_allow_result(out, lex, 0);
    return;
  }
  parser_asm_write_try_skip_allow_result(out, cur, rc);
}
#else
void parser_asm_parse_into_try_skip_allow_into_slice_c(struct parser_asm_try_skip_allow_result *out,
                                                       struct parser_asm_lexer lex,
                                                       struct parser_asm_lexer_result r,
                                                       struct parser_asm_slice_u8 *source) {
  struct parser_asm_try_skip_allow_result res;
  if (!out)
    return;
  if (r.tok.kind != (int32_t)TOKEN_IDENT || r.tok.ident_len != 5) {
    parser_asm_write_try_skip_allow_result(out, lex, 0);
    return;
  }
  /* v5.16: allow_kw_paren widened to pointer ABI; lex is the pre-token cursor
   * that produced r (peek-from-lex ≡ historical by-val r). */
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_allow_kw_paren_audit_c(&lex, source));
  res = parser_asm_try_skip_allow_padding_struct_slice_c(r.next_lex, source);
  *out = res;
}
#endif /* XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X parse_into slice */

/**
 * parse_into_try_skip_allow_into_buf：buf 路径；结果写入 *out。
 * Hybrid P13c: wraps the slice trampoline over (data,len), same as the
 * cold twin's padding_struct_buf_c delegation.
 */
#ifdef XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X
void parser_asm_parse_into_try_skip_allow_into_buf_c(struct parser_asm_try_skip_allow_result *out,
                                                   struct parser_asm_lexer lex,
                                                   struct parser_asm_lexer_result r, uint8_t *data,
                                                   int32_t len) {
  struct parser_asm_slice_u8 source;
  source.data = data;
  source.length = (len < 0) ? (size_t)0 : (size_t)len;
  parser_asm_parse_into_try_skip_allow_into_slice_c(out, lex, r, &source);
}
#else
void parser_asm_parse_into_try_skip_allow_into_buf_c(struct parser_asm_try_skip_allow_result *out,
                                                   struct parser_asm_lexer lex,
                                                   struct parser_asm_lexer_result r, uint8_t *data,
                                                   int32_t len) {
  struct parser_asm_try_skip_allow_result res;
  if (!out)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_try_skip_allow_deep_buf_audit_c(&r.next_lex, data, len));
  if (r.tok.kind != (int32_t)TOKEN_IDENT || r.tok.ident_len != 5) {
    parser_asm_write_try_skip_allow_result(out, lex, 0);
    return;
  }
  /* v5.16: allow_kw_paren_buf widened to (lex, data, len). */
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_allow_kw_paren_buf_audit_c(&lex, data, len));
  res = parser_asm_try_skip_allow_padding_struct_buf_c(r.next_lex, data, len);
  *out = res;
}
#endif /* XLANG_PTHIN_TRY_SKIP_ALLOW_BODIES_FROM_X parse_into buf */
