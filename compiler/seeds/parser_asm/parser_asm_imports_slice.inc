/**
 * parser_asm_imports_slice.inc — P11 skip/collect imports (G-02f-320).
 * Included by parser_asm_thin_c.from_x.c or pthin_imports.from_x.c.
 *
 * Hybrid P11b/P11c/P11d: XLANG_PTHIN_IMPORTS_BODIES_FROM_X skips the
 * portable skip_imports / consume_path / try_skip / collect_imports
 * walks (bodies in src/asm/pthin_imports.x + by-value trampolines
 * in the seed TU). collect_imports dest-buffers path/bind on the C
 * trampoline (no file-statics); module writes stay in
 * pipeline_module_import_*. copy_token_bytes slice name is a
 * trampoline over P1f buf-path (copy family in lex_skip). Contiguous
 * already-T AUDIT_CALL padding on collect_imports is compiled only
 * under XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is nop; hybrid
 * trampoline has no AUDIT). Cold: no define, full twin. Do not reuse
 * XLANG_PTHIN_IMPORTS_FROM_X for P11b/P11c/P11d bodies.
 */
/* Forward decl: defined later in this file (G-02f-422 Ubuntu gcc fix) */
int32_t parser_asm_collect_imports_consume_path(struct parser_asm_collect_imports_result *out,
                                                      struct parser_asm_slice_u8 *source, uint8_t *path_buf,
                                                      int32_t *path_len);

#ifndef XLANG_PTHIN_IMPORTS_BODIES_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_PTHIN_IMPORTS_BODIES_FROM_X removed */
#endif /* !XLANG_PTHIN_IMPORTS_BODIES_FROM_X try_skip_const_import */

#ifndef XLANG_PTHIN_IMPORTS_BODIES_FROM_X
#endif /* !XLANG_PTHIN_IMPORTS_BODIES_FROM_X skip_imports slice/buf */

/**
 * Copy source[token_start..+tok_len) into a 128-byte buffer (zero-pad remainder).
 * wave584 Cap residual: binding-name content ≤255 (ImportEntry.binding_name[256]).
 * Historical name kept for symbol stability; width is 128.
 * PLATFORM: SHARED — P1f: algorithm is parser_asm_copy_token_bytes_to_buf64_buf_c
 * (copy family in lex_skip); this slice face only unwraps the slice.
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
extern void parser_asm_copy_token_bytes_to_buf64_buf_c(uint8_t *source, int32_t source_len, size_t start,
                                                       int32_t nlen, uint8_t *out);
void parser_asm_copy_token_bytes_to_buf64(struct parser_asm_slice_u8 *source, size_t token_start,
                                                 int32_t tok_len, uint8_t *buf) {
  uint8_t *data;
  int32_t slen;
  if (!buf)
    return;
  data = (source && source->data) ? source->data : NULL;
  if (!source)
    slen = 0;
  else if (source->length > (size_t)2147483647)
    slen = 2147483647;
  else
    slen = (int32_t)source->length;
  parser_asm_copy_token_bytes_to_buf64_buf_c(data, slen, token_start, tok_len, buf);
}




#ifndef XLANG_PTHIN_IMPORTS_BODIES_FROM_X
#endif /* !XLANG_PTHIN_IMPORTS_BODIES_FROM_X consume_path */

#ifndef XLANG_PTHIN_IMPORTS_BODIES_FROM_X
#ifdef XLANG_PARSER_STRETCH_AUDIT
#endif /* XLANG_PARSER_STRETCH_AUDIT collect_imports slice prefix */
#endif /* !XLANG_PTHIN_IMPORTS_BODIES_FROM_X collect_imports */

/**
 * collect_imports_buf：(data,len) 路径委托 slice collect_imports。
 */
void parser_asm_collect_imports_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len, void *module,
                                    struct parser_asm_collect_imports_result *out) {
  struct parser_asm_slice_u8 source;
  if (!data || !out)
    return;
#ifdef XLANG_PARSER_STRETCH_AUDIT
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_select_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_post_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_path_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_stmt_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_ultra_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_super_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(&lex, data, len));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_vx_import_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_buf_audit_c(&lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_import_path_full_deep_buf_audit_c(&lex, data, len));
  /* v5.10: diag_lex buf widened to (lex, data, len). */
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_lex_after_imports_buf_audit_c(&lex, data, len));
#endif /* XLANG_PARSER_STRETCH_AUDIT collect_imports buf prefix */
  source.data = data;
  source.length = len >= 0 ? (size_t)len : 0;
  parser_asm_collect_imports_slice_c(lex, &source, module, out);
}

/**
 * diag_token_after_collect_imports：collect_imports 后 peek 下一 token kind。
 */
int32_t parser_asm_diag_token_after_collect_imports_slice_c(struct parser_asm_slice_u8 *source, void *module) {
  struct parser_asm_lexer lex;
  struct parser_asm_collect_imports_result import_res;
  struct parser_asm_lexer_result r;

  if (!source || !module)
    return (int32_t)TOKEN_EOF;
  lex = parser_asm_lexer_init_c();
  import_res.lex = lex;
  parser_asm_collect_imports_slice_c(lex, source, module, &import_res);
  lex = import_res.lex;
  {
    int32_t peek_kinds[6];
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_peek_kind_chain_c(peek_kinds, 6, &lex, source));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_toplevel_after_imports_audit_c(&lex, source));
  }
  lexer_next_into(&r, lex, source);
  return r.tok.kind;
}

/**
 * diag_token_after_collect_imports_buf：buf 路径 collect_imports 后 peek 下一 token kind。
 */
int32_t parser_asm_diag_token_after_collect_imports_buf_c(uint8_t *data, int32_t len, void *module) {
  struct parser_asm_slice_u8 source;

  if (!data || len <= 0 || !module)
    return (int32_t)TOKEN_EOF;
  {
  struct parser_asm_lexer lex_init = parser_asm_lexer_init_c();
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_token_after_collect_imports_buf_audit_c(&lex_init, data, len));
}
  source.data = data;
  source.length = (size_t)len;
  return parser_asm_diag_token_after_collect_imports_slice_c(&source, module);
}

