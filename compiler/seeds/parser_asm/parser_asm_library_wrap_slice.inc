#ifndef PARSER_ASM_LIBRARY_WRAP_SLICE_INCLUDED
#define PARSER_ASM_LIBRARY_WRAP_SLICE_INCLUDED

/**
 * parser_asm_library_wrap_slice.inc — library into/buf/scan C.
 *
 * Hybrid P15b: XLANG_PTHIN_LIBRARY_BODIES_FROM_X skips the portable
 * library_scan walk (body in src/asm/pthin_library.x + slice trampoline
 * in the seed TU). into / buf parse / lex_from_* stay here. Contiguous
 * already-T AUDIT_CALL padding on into/buf is compiled only under
 * XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is nop). Cold: no
 * define, full twin. Do not reuse XLANG_PTHIN_LIBRARY_FROM_X for P15b
 * bodies.
 */

/**
 * parse_one_function_library_into：slice 路径，结果写入 *out（避免 LibraryParseResult 按值返回 ABI）。
 */
void parser_asm_parse_one_function_library_into_slice_c(struct parser_asm_library_parse_result *out, void *arena,
                                                        void *module, struct parser_asm_lexer lex,
                                                        struct parser_asm_slice_u8 *source) {
  if (!out)
    return;
#ifdef XLANG_PARSER_STRETCH_AUDIT
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_fn_shape_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_ultra_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_super_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
#endif /* XLANG_PARSER_STRETCH_AUDIT */
  *out = parser_asm_parse_one_function_library_slice_c(arena, module, lex, source);
}

/**
 * parse_one_function_library_buf：(data,len) 路径，按值返回 LibraryParseResult。
 * 直接调 C slice 实现，勿回调 X 以免 glue 递归。
 */
struct parser_asm_library_parse_result parser_asm_parse_one_function_library_buf_c(
    void *arena, void *module, struct parser_asm_lexer lex, uint8_t *data, int32_t len) {
  struct parser_asm_slice_u8 source;
  if (!data)
    return (struct parser_asm_library_parse_result){0};
#ifdef XLANG_PARSER_STRETCH_AUDIT
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_fn_shape_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_scan_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_scan_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_scan_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_fn_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_ultra_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_super_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_library_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_library_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
#endif /* XLANG_PARSER_STRETCH_AUDIT */
  source.data = data;
  source.length = len >= 0 ? (size_t)len : 0;
  return parser_asm_parse_one_function_library_slice_c(arena, module, lex, &source);
}

/** LexerResult.next_lex → 当前 Lexer（与 parser.x lex_from_next_into 一致）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void parser_asm_lex_from_lr_next_c(struct parser_asm_lexer *lex, struct parser_asm_lexer_result *r) {
  if (lex && r)
    *lex = r->next_lex;
}




#ifndef XLANG_PTHIN_LIBRARY_BODIES_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_PTHIN_LIBRARY_BODIES_FROM_X removed */
#endif /* !XLANG_PTHIN_LIBRARY_BODIES_FROM_X */

/**
 * lex_from_try_skip_into：从 TrySkipAllowResult.lex 写入 *out（避免 X emit 结构体字段链）。
 */
void parser_asm_lex_from_try_skip_into_c(struct parser_asm_lexer *out,
                                         struct parser_asm_try_skip_allow_result t) {
  if (!out)
    return;
  out->pos = t.lex.pos;
  out->line = t.lex.line;
  out->col = t.lex.col;
}

/**
 * lex_from_try_skip：按值返回 TrySkipAllowResult 内的 Lexer。
 */
struct parser_asm_lexer parser_asm_lex_from_try_skip_c(struct parser_asm_try_skip_allow_result t) {
  return t.lex;
}

/**
 * lex_from_library_into：从 LibraryParseResult.next_lex 写入 *out。
 */
void parser_asm_lex_from_library_into_c(struct parser_asm_lexer *out, struct parser_asm_library_parse_result lib) {
  if (!out)
    return;
  out->pos = lib.next_lex.pos;
  out->line = lib.next_lex.line;
  out->col = lib.next_lex.col;
}

/**
 * lex_from_library：按值返回 LibraryParseResult 内的 next_lex。
 */
struct parser_asm_lexer parser_asm_lex_from_library_c(struct parser_asm_library_parse_result lib) {
  return lib.next_lex;
}

#endif /* PARSER_ASM_LIBRARY_WRAP_SLICE_INCLUDED */
