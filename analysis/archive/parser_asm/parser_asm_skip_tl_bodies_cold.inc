/* Class BX: skip_tl BODIES cold twin — tip uses pthin_skip_tl.x */
#ifndef XLANG_PTHIN_SKIP_TL_BODIES_FROM_X
/**
 * skip_one_struct_into：跳过一条顶层 struct 定义，结果写入 *out。
 */
void parser_asm_skip_one_struct_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  if (!out || !source)
    return;
  /* wave439: stash full-file source for generic-bound scan. */
  xlang_generic_bound_stash_source_c(source);
  {
    struct parser_asm_lexer mod_lex = lex;
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_skip_allow_modifiers_c(&mod_lex, source));
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_modifiers_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_layout_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_skip_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_ultra_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_super_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(&lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_struct_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(&lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_header_audit_c(&lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_STRUCT) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IDENT) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  {
    uint8_t sname_audit[64];
    parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, sname_audit);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_bind_audit_c(sname_audit, r.tok.ident_len));
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  /*
   * wave466: `struct Name<T> { ... }` — skip type-param angle list so skip
   * reaches the body braces (same contract as parse_struct_record_layout).
   * PLATFORM: SHARED — without this, skip stalled on TOKEN_LT and left the
   * brace body in the top-level stream after a failed layout parse.
   */
  if (r.tok.kind == (int32_t)TOKEN_LT) {
    parser_asm_skip_generic_angle_list_into_slice_c(&lex, lex, source);
    lexer_next_into(&r, lex, source);
  }
  if (r.tok.kind != (int32_t)TOKEN_LBRACE) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_fields_probe_c(&r.next_lex, source, 0));
  parser_asm_skip_balanced_braces_into_slice_c(out, r.next_lex, source);
}

#endif /* !XLANG_PTHIN_SKIP_TL_BODIES_FROM_X skip_one_struct */
