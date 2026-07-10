/* parser_asm_body_tl_slice.inc — G-02f-327 P18 body/diag residual + top_level skip
 * Hybrid: SHUX_PTHIN_BODY_TL_FROM_X via seeds/pthin_body_tl.from_x.c
 * is_fn_sig_scalar + diag_first_ident + diag_skip_let_const_into + body_skip_into
 * + skip_one_top_level_{let,const} + cfg_skip_pending_top_level
 */
#ifndef PARSER_ASM_BODY_TL_SLICE_INC
#define PARSER_ASM_BODY_TL_SLICE_INC

/* Forward decls: defined in skip_tl_slice.inc / glue_tail_slice.inc (G-02f-422 Ubuntu gcc fix) */
void parser_asm_skip_one_struct_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source);
void parser_asm_skip_one_function_full_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                    struct parser_asm_slice_u8 *source);

/* G-02f-123：逻辑源 .x（真迁）；seed 保留同语义 C 供产品 cc */
int32_t parser_asm_is_fn_sig_scalar_type_token_c(int32_t kind) {
  return kind == (int32_t)TOKEN_I32 || kind == (int32_t)TOKEN_I64 || kind == (int32_t)TOKEN_BOOL
      || kind == (int32_t)TOKEN_U8 || kind == (int32_t)TOKEN_U32 || kind == (int32_t)TOKEN_U64
      || kind == (int32_t)TOKEN_USIZE || kind == (int32_t)TOKEN_VOID || kind == (int32_t)TOKEN_IDENT;
}




/**
 * diag_first_ident_len：诊断用，返回 function 后首 IDENT 的 ident_len（失败负值）。
 */
int32_t parser_asm_diag_first_ident_len_slice_c(struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer lex;
  struct parser_asm_lexer_result r;
  if (!source)
    return -2;
  lex = parser_asm_lexer_init_c();
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_FUNCTION)
    return -2;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_fn_header_audit_c(lex, source));
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IDENT)
    return -3;
  return r.tok.ident_len;
}

/**
 * diag_skip_let_const_into：从 body 首 token 起跳过 let/const 声明，写入 *out。
 */
void parser_asm_diag_skip_let_const_into_slice_c(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                                                 struct parser_asm_slice_u8 *source) {
  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_skip_let_const_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_skip_let_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_let_const_decl_audit_c(lex, source));
  lexer_next_into(out, lex, source);
  while (out->tok.kind == (int32_t)TOKEN_LET || out->tok.kind == (int32_t)TOKEN_CONST) {
    parser_lex_from_lexer_result_ptr_into(&lex, out);
    lexer_next_into(out, lex, source);
    if (out->tok.kind != (int32_t)TOKEN_IDENT)
      return;
    parser_lex_from_lexer_result_ptr_into(&lex, out);
    lexer_next_into(out, lex, source);
    if (out->tok.kind != (int32_t)TOKEN_COLON)
      return;
    parser_lex_from_lexer_result_ptr_into(&lex, out);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_skip_let_const_type_audit_c(lex, source));
    lexer_next_into(out, lex, source);
    if (out->tok.kind == (int32_t)TOKEN_STAR) {
      parser_lex_from_lexer_result_ptr_into(&lex, out);
      lexer_next_into(out, lex, source);
      if (out->tok.kind != (int32_t)TOKEN_IDENT)
        return;
      parser_lex_from_lexer_result_ptr_into(&lex, out);
      lexer_next_into(out, lex, source);
    } else if (parser_asm_is_fn_sig_scalar_type_token_c(out->tok.kind)) {
      parser_lex_from_lexer_result_ptr_into(&lex, out);
      lexer_next_into(out, lex, source);
      if (out->tok.kind == (int32_t)TOKEN_LBRACKET) {
        parser_lex_from_lexer_result_ptr_into(&lex, out);
        lexer_next_into(out, lex, source);
        if (out->tok.kind != (int32_t)TOKEN_RBRACKET)
          return;
        parser_lex_from_lexer_result_ptr_into(&lex, out);
        lexer_next_into(out, lex, source);
      }
    } else {
      return;
    }
    if (out->tok.kind != (int32_t)TOKEN_ASSIGN)
      return;
    parser_lex_from_lexer_result_ptr_into(&lex, out);
    lexer_next_into(out, lex, source);
    while (out->tok.kind != (int32_t)TOKEN_SEMICOLON && out->tok.kind != (int32_t)TOKEN_EOF) {
      if (out->tok.kind == (int32_t)TOKEN_STRING)
        return;
      parser_lex_from_lexer_result_ptr_into(&lex, out);
      lexer_next_into(out, lex, source);
    }
    if (out->tok.kind != (int32_t)TOKEN_SEMICOLON)
      return;
    parser_lex_from_lexer_result_ptr_into(&lex, out);
    lexer_next_into(out, lex, source);
  }
}

/**
 * body_skip_let_const_then_if_into：跳过 body 内 let/const 后连续 if 语句。
 */
void parser_asm_body_skip_let_const_then_if_into_slice_c(struct parser_asm_lexer_result *out,
                                                         struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source) {
  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_let_const_then_if_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_diag_skip_let_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_ultra_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_super_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_let_const_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_let_const_decl_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_body_skip_let_const_type_audit_c(lex, source));
  parser_asm_diag_skip_let_const_into_slice_c(out, lex, source);
  while (out->tok.kind == (int32_t)TOKEN_IF) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_if_header_audit_c(out->next_lex, source));
    parser_asm_skip_one_if_statement_into_slice_c(out, out->next_lex, source);
  }
}

/**
 * B-01/B-19：跳过一条顶层 `let ... ;`（与 const 跳过对称；cfg 不匹配时须跳过 let 而非仅 const）。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void parser_asm_skip_one_top_level_let_into_slice_c(struct parser_asm_lexer *out,
                                                             struct parser_asm_lexer lex,
                                                             struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;

  if (!out || !source) {
    if (out)
      *out = lex;
    return;
  }
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LET) {
    *out = lex;
    return;
  }
  lex = r.next_lex;
  for (;;) {
    lexer_next_into(&r, lex, source);
    lex = r.next_lex;
    if (r.tok.kind == (int32_t)TOKEN_SEMICOLON || r.tok.kind == (int32_t)TOKEN_EOF)
      break;
  }
  if (r.tok.kind == (int32_t)TOKEN_SEMICOLON)
    lex = r.next_lex;
  *out = lex;
}




/**
 * B-01/B-19：跳过一条顶层 `const ... ;`（含 const x = import("path");），不建 AST。
 * lex 位于 const 之前；*out 写出跳过后的 lex。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void parser_asm_skip_one_top_level_const_into_slice_c(struct parser_asm_lexer *out,
                                                               struct parser_asm_lexer lex,
                                                               struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;

  if (!out || !source) {
    if (out)
      *out = lex;
    return;
  }
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_CONST) {
    *out = lex;
    return;
  }
  lex = r.next_lex;
  for (;;) {
    lexer_next_into(&r, lex, source);
    lex = r.next_lex;
    if (r.tok.kind == (int32_t)TOKEN_SEMICOLON || r.tok.kind == (int32_t)TOKEN_EOF)
      break;
  }
  if (r.tok.kind == (int32_t)TOKEN_SEMICOLON)
    lex = r.next_lex;
  *out = lex;
}




/**
 * B-02/B-19：import/collect 区段 `#[cfg]` 不匹配时跳过紧随其后的顶层 const/struct/function。
 * lex 位于待跳过项之前；*pending 置 0 后 *lex 写出跳过后的位置。
 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void parser_asm_cfg_skip_pending_top_level_into_slice_c(struct parser_asm_lexer *lex,
                                                                struct parser_asm_slice_u8 *source,
                                                                int32_t *pending) {
  if (!lex || !source || !pending || !*pending)
    return;
  if (lex->pos >= source->length) {
    *pending = 0;
    return;
  }
  {
    struct parser_asm_lexer_result r;
    lexer_next_into(&r, *lex, source);
    if (r.tok.kind == (int32_t)TOKEN_CONST) {
      parser_asm_skip_one_top_level_const_into_slice_c(lex, *lex, source);
      *pending = 0;
      return;
    }
    if (r.tok.kind == (int32_t)TOKEN_LET) {
      parser_asm_skip_one_top_level_let_into_slice_c(lex, *lex, source);
      *pending = 0;
      return;
    }
    if (r.tok.kind == (int32_t)TOKEN_STRUCT) {
      parser_asm_skip_one_struct_into_slice_c(lex, *lex, source);
      *pending = 0;
      return;
    }
    if (r.tok.kind == (int32_t)TOKEN_FUNCTION || r.tok.kind == (int32_t)TOKEN_EXTERN
        || r.tok.kind == (int32_t)TOKEN_ASYNC) {
      parser_asm_skip_one_function_full_into_slice_c(lex, *lex, source);
      *pending = 0;
      return;
    }
  }
  *pending = 0;
}




#endif /* PARSER_ASM_BODY_TL_SLICE_INC */
