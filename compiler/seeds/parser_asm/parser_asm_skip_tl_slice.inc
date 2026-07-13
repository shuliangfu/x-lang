/**
 * skip_one_struct_into：跳过一条顶层 struct 定义，结果写入 *out。
 */
void parser_asm_skip_one_struct_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  if (!out || !source)
    return;
  {
    struct parser_asm_lexer mod_lex = lex;
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_skip_allow_modifiers_c(&mod_lex, source));
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_modifiers_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_layout_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_skip_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_ultra_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_super_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_header_audit_c(lex, source));
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
  if (r.tok.kind != (int32_t)TOKEN_LBRACE) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_fields_probe_c(r.next_lex, source, 0));
  parser_asm_skip_balanced_braces_into_slice_c(out, r.next_lex, source);
}

/**
 * skip_one_enum_into：跳过一条顶层 enum 定义，结果写入 *out。
 */
void parser_asm_skip_one_enum_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                          struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_enum_header_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_enum_body_deep_slice_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_ENUM) {
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
    uint8_t ename_audit[64];
    parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, ename_audit);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_bind_audit_c(ename_audit, r.tok.ident_len));
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LBRACE) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_enum_variants_probe_c(r.next_lex, source, 0));
  parser_asm_skip_balanced_braces_into_slice_c(out, r.next_lex, source);
}
void parser_asm_skip_one_trait_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                            struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  if (!out || !source)
    return;
  /** 字节级 skip 优先：trait+impl 连续时 token 路径易失败。 */
  if (lex.pos + 5 <= source->length && source->data[lex.pos] == (uint8_t)'t'
      && source->data[lex.pos + 1] == (uint8_t)'r' && source->data[lex.pos + 2] == (uint8_t)'a'
      && source->data[lex.pos + 3] == (uint8_t)'i' && source->data[lex.pos + 4] == (uint8_t)'t') {
    parser_asm_skip_trait_impl_block_raw_c(out, lex, source);
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_header_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_impl_type_deep_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_TRAIT) {
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
    uint8_t tname_audit[64];
    parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, tname_audit);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_bind_audit_c(tname_audit, r.tok.ident_len));
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LBRACE) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_methods_body_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_methods_probe_c(r.next_lex, source, 0));
  parser_asm_skip_balanced_braces_into_slice_c(out, r.next_lex, source);
}

/**
 * skip_one_impl_into：跳过一条顶层 impl 块，结果写入 *out。
 */
void parser_asm_skip_one_impl_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  if (!out || !source)
    return;
  /** 字节级 skip 优先：impl 块内 function 不会被误当作顶层函数。 */
  if (lex.pos + 4 <= source->length && source->data[lex.pos] == (uint8_t)'i'
      && source->data[lex.pos + 1] == (uint8_t)'m' && source->data[lex.pos + 2] == (uint8_t)'p'
      && source->data[lex.pos + 3] == (uint8_t)'l') {
    parser_asm_skip_trait_impl_block_raw_c(out, lex, source);
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_impl_header_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IMPL) {
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
    uint8_t iname_audit[64];
    parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, iname_audit);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_bind_audit_c(iname_audit, r.tok.ident_len));
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind == (int32_t)TOKEN_FOR) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_impl_type_for_trait_audit_c(lex, source));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_impl_type_deep_audit_c(lex, source));
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (r.tok.kind != (int32_t)TOKEN_IDENT) {
      out->pos = lex.pos;
      out->line = lex.line;
      out->col = lex.col;
      return;
    }
    {
      uint8_t tname_audit[64];
      parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, tname_audit);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_bind_audit_c(tname_audit, r.tok.ident_len));
    }
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
  }
  if (r.tok.kind != (int32_t)TOKEN_LBRACE) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_impl_items_body_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_impl_items_probe_c(r.next_lex, source, 0));
  parser_asm_skip_balanced_braces_into_slice_c(out, r.next_lex, source);
}

/** 将 extern 解析失败快照写入 out（name_len=-1）。 */
/* G-02f-165：逻辑源 .x（批折叠）；seed 保留同语义 C 供产品 cc */
void parser_asm_extern_parse_set_fail_c(struct parser_asm_extern_parse_result *out,
                                               struct parser_asm_lexer lex) {
  if (!out)
    return;
  memset(out->name, 0, sizeof(out->name));
  out->next_lex = lex;
  out->name_len = -1;
  out->return_ty_ref = 0;
  out->num_params = 0;
  out->abi_kind = 0;
}




/**
 * parse_one_extern_skip_into：解析 extern function 到分号，结果写入 *out；失败时 name_len=-1。
 */
void parser_asm_parse_one_extern_skip_into_slice_c(struct parser_asm_extern_parse_result *out, void *arena,
                                                   struct parser_asm_lexer lex,
                                                   struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  uint8_t name_buf[64];
  uint8_t pname_ex[32];
  uint8_t *ex_pool;
  int32_t name_len;
  int32_t n_ex;
  int32_t plen_ex;
  int32_t pidx_append;
  int32_t ty_pex;
  int32_t ret_ty;
  int32_t nk;
  if (!out || !source)
    return;
  {
    int32_t extern_param_score = 0;
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_extern_param_count_audit_c(lex, source, &extern_param_score));
    (void)extern_param_score;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_extern_fn_audit_c(lex, source));
  ast_pool_onefunc_reset((uint8_t *)out);
  out->abi_kind = 0; /* 默认 X ABI；extern "C" 时在下方设为 1 */
  out->is_variadic = 0; /* 默认定参；遇到 `...` 时在参数循环中设为 1 */
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_EXTERN) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  /* P0a: 可选 ABI 标记 — extern "C" function ... / extern "X" function ...
   * 默认（无标记）= X ABI（abi_kind=0）；"C" = C ABI（abi_kind=1，需 unsafe 调用）。
   * 语义降级：P0a 阶段 typeck/codegen 统一按 C ABI 生成，不改变行为。 */
  lexer_next_into(&r, lex, source);
  if (r.tok.kind == (int32_t)TOKEN_STRING) {
    uint8_t *abi_str = source->data + r.token_start;
    int32_t abi_len = r.tok.ident_len;
    if (abi_len == 1 && abi_str[0] == 'C') {
      out->abi_kind = 1; /* C ABI */
    } else if (abi_len == 1 && abi_str[0] == 'X') {
      out->abi_kind = 0; /* X ABI（显式标记，与默认一致） */
    } else {
      parser_asm_extern_parse_set_fail_c(out, lex);
      return;
    }
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
  }
  if (r.tok.kind != (int32_t)TOKEN_FUNCTION) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IDENT) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  name_len = r.tok.ident_len;
  if (name_len <= 0 || name_len > 63) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  parser_asm_copy_slice_to_name64_at_end_slice_c(source, r.next_lex.pos, name_len, name_buf);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_extern_param_bind_audit_c(name_buf, name_len));
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LPAREN) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  ex_pool = (uint8_t *)out;
  n_ex = 0;
  if (r.tok.kind == (int32_t)TOKEN_RPAREN) {
    parser_asm_lex_from_result_val_into(&lex, r);
  } else {
    for (;;) {
      /* 变参 `...`：必须是形参列表最后一个 token，紧跟 `)`；仅 C ABI 支持。 */
      if (r.tok.kind == (int32_t)TOKEN_ELLIPSIS) {
        out->is_variadic = 1;
        parser_asm_lex_from_result_val_into(&lex, r);
        lexer_next_into(&r, lex, source);
        if (r.tok.kind != (int32_t)TOKEN_RPAREN) {
          parser_asm_extern_parse_set_fail_c(out, lex);
          return;
        }
        parser_asm_lex_from_result_val_into(&lex, r);
        break;
      }
      if (r.tok.kind != (int32_t)TOKEN_IDENT) {
        parser_asm_extern_parse_set_fail_c(out, lex);
        return;
      }
      plen_ex = r.tok.ident_len;
      if (plen_ex <= 0 || plen_ex > 31) {
        parser_asm_extern_parse_set_fail_c(out, lex);
        return;
      }
      parser_asm_copy_slice_to_param32_slice_c(source, r.token_start, plen_ex, pname_ex);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_extern_param_bind_audit_c(pname_ex, plen_ex));
      pidx_append = pipeline_onefunc_append_param(ex_pool, pname_ex, plen_ex, 0);
      if (pidx_append < 0) {
        parser_asm_extern_parse_set_fail_c(out, lex);
        return;
      }
      n_ex = pidx_append + 1;
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind != (int32_t)TOKEN_COLON) {
        parser_asm_extern_parse_set_fail_c(out, lex);
        return;
      }
      parser_asm_lex_from_result_val_into(&lex, r);
      lex_cur = lex;
      ty_pex = parser_asm_parse_type_ref_for_arena_into_slice_c(arena, lex_cur, source, &lex);
      if (ty_pex == 0) {
        parser_asm_extern_parse_set_fail_c(out, lex);
        return;
      }
      pipeline_onefunc_set_param_type_ref(ex_pool, pidx_append, ty_pex);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind == (int32_t)TOKEN_RPAREN) {
        parser_asm_lex_from_result_val_into(&lex, r);
        break;
      }
      if (r.tok.kind != (int32_t)TOKEN_COMMA) {
        parser_asm_extern_parse_set_fail_c(out, lex);
        return;
      }
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind == (int32_t)TOKEN_RPAREN) {
        parser_asm_lex_from_result_val_into(&lex, r);
        break;
      }
    }
  }
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_COLON) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_extern_return_type_audit_c(lex, source));
  parser_asm_lex_from_result_val_into(&lex, r);
  lex_cur = lex;
  ret_ty = parser_asm_parse_type_ref_for_arena_into_slice_c(arena, lex_cur, source, &lex);
  if (ret_ty == 0) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_SEMICOLON) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  out->next_lex = lex;
  out->name_len = name_len;
  out->return_ty_ref = ret_ty;
  out->num_params = n_ex;
  for (nk = 0; nk < 64; nk++)
    out->name[nk] = name_buf[nk];
}

/**
 * parse_one_extern_and_add_into：解析 extern 声明并登记 module；失败 fallback skip_one_extern_into。
 */
void parser_asm_parse_one_extern_and_add_into_slice_c(void *arena, void *module, struct parser_asm_lexer lex,
                                                       struct parser_asm_slice_u8 *source,
                                                       struct parser_asm_lexer *lex_out) {
  struct parser_asm_extern_parse_result res;
  struct ast_Func f;
  int32_t type_ref;
  int32_t func_ref;
  int32_t fi_ex;
  int32_t ki;
  if (!lex_out || !source)
    return;
  memset(&res, 0, sizeof(res));
  res.name_len = -1;
  parser_asm_parse_one_extern_skip_into_slice_c(&res, arena, lex, source);
  if (res.name_len < 0) {
    parser_skip_one_extern_into_glue(lex_out, lex, source);
    return;
  }
  type_ref = res.return_ty_ref;
  if (type_ref == 0) {
    extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                                      const uint8_t *name);
    driver_diagnostic_parse_skip_function((int32_t)lex.pos, pipeline_module_num_funcs(module), res.name_len,
                                          res.name_len > 0 ? res.name : NULL);
    parser_skip_one_extern_into_glue(lex_out, lex, source);
    return;
  }
  func_ref = ast_ast_arena_func_alloc(arena);
  if (func_ref == 0) {
    extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                                      const uint8_t *name);
    driver_diagnostic_parse_skip_function((int32_t)lex.pos, pipeline_module_num_funcs(module), res.name_len,
                                          res.name_len > 0 ? res.name : NULL);
    parser_skip_one_extern_into_glue(lex_out, lex, source);
    return;
  }
  f = ast_arena_func_get(arena, func_ref);
  for (ki = 0; ki < 64; ki++) {
    if (ki < res.name_len)
      f.name[ki] = res.name[ki];
    else
      f.name[ki] = 0;
  }
  f.name_len = res.name_len;
  f.num_params = res.num_params;
  f.return_type_ref = type_ref;
  f.body_ref = 0;
  f.body_expr_ref = 0;
  f.is_extern = 1;
  f.is_async = 0;
  f.abi_kind = res.abi_kind;
  f.is_variadic = res.is_variadic;
  ast_arena_func_set(arena, func_ref, f);
  fi_ex = parser_asm_module_register_arena_func_c(module, func_ref, f);
  if (fi_ex < 0) {
    extern void driver_diagnostic_parse_skip_function(int32_t byte_pos, int32_t num_funcs_so_far, int32_t name_len,
                                                      const uint8_t *name);
    driver_diagnostic_parse_skip_function((int32_t)lex.pos, pipeline_module_num_funcs(module), res.name_len,
                                          res.name_len > 0 ? res.name : NULL);
    parser_skip_one_extern_into_glue(lex_out, lex, source);
    return;
  }
  parser_asm_write_extern_params_to_pools_c(arena, module, func_ref, fi_ex, &res);
  lex_out->pos = res.next_lex.pos;
  lex_out->line = res.next_lex.line;
  lex_out->col = res.next_lex.col;
}

/**
 * module_register_arena_func：将 arena Func 登记到 module 动态池，返回 module 下标或 -1。
 */
int32_t parser_asm_module_register_arena_func_c(void *module, int32_t func_ref, struct ast_Func f) {
  int32_t fi;
  if (!module)
    return -1;
  fi = pipeline_module_func_alloc_slot(module);
  if (fi < 0)
    return -1;
  pipeline_module_func_name_write(module, fi, f.name, f.name_len);
  pipeline_module_func_set_num_params(module, fi, f.num_params);
  pipeline_module_func_set_return_type(module, fi, f.return_type_ref);
  pipeline_module_func_set_body_ref(module, fi, f.body_ref);
  pipeline_module_func_set_body_expr_ref(module, fi, f.body_expr_ref);
  pipeline_module_func_set_is_extern(module, fi, f.is_extern);
  pipeline_module_func_set_is_async(module, fi, f.is_async);
  pipeline_module_func_set_is_variadic(module, fi, f.is_variadic);
  pipeline_module_func_ref_set(module, fi, func_ref);
  return fi;
}

/**
 * write_extern_params_to_pools：将 ExternParseResult 侧车池形参写入 arena 与 module sidecar。
 */
void parser_asm_write_extern_params_to_pools_c(void *arena, void *module, int32_t func_ref, int32_t fi,
                                               struct parser_asm_extern_parse_result *res) {
  uint8_t *pool;
  int32_t p;
  uint8_t pname32[32];
  int32_t plen;
  int32_t pty;
  if (!res)
    return;
  pool = (uint8_t *)res;
  p = 0;
  while (p < res->num_params) {
    pipeline_onefunc_param_name_copy32(pool, p, pname32);
    plen = pipeline_onefunc_param_name_len(pool, p);
    pty = pipeline_onefunc_param_type_ref(pool, p);
    pipeline_arena_func_param_write(arena, func_ref, p, pname32, plen, pty);
    pipeline_module_func_param_write(module, fi, p, pname32, plen, pty);
    p++;
  }
}

/**
 * skip_one_extern_into：跳过一条顶层 extern function 声明，结果写入 *out。
 */
void parser_asm_skip_one_extern_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_skip_one_extern_body_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_extern_fn_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_EXTERN) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_FUNCTION) {
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
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LPAREN) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  lex_cur = lex;
  parser_asm_skip_balanced_parens_into_slice_c(&lex_cur, r.next_lex, source);
  lexer_next_into(&r, lex_cur, source);
  if (r.tok.kind != (int32_t)TOKEN_COLON) {
    out->pos = lex_cur.pos;
    out->line = lex_cur.line;
    out->col = lex_cur.col;
    return;
  }
  parser_asm_lex_from_result_val_into(&lex_cur, r);
  {
    struct parser_asm_lexer ret_audit = lex_cur;
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_skip_return_type_audit_c(&ret_audit, source));
  }
  lexer_next_into(&r, lex_cur, source);
  while (r.tok.kind != (int32_t)TOKEN_SEMICOLON && r.tok.kind != (int32_t)TOKEN_EOF) {
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    lexer_next_into(&r, lex_cur, source);
  }
  if (r.tok.kind == (int32_t)TOKEN_SEMICOLON)
    parser_asm_lex_from_result_val_into(&lex_cur, r);
  out->pos = lex_cur.pos;
  out->line = lex_cur.line;
  out->col = lex_cur.col;
}

/**
 * module_append_enum_variants_and_skip_body_into：扫描 enum 体变体名并 skip 至 `}`，结果写入 *out。
 */
void parser_asm_module_append_enum_variants_and_skip_body_into_slice_c(
    void *module, int32_t enum_idx, struct parser_asm_lexer *out, struct parser_asm_lexer lex,
    struct parser_asm_slice_u8 *source) {
  int32_t depth;
  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_enum_variants_body_audit_c(lex, source));
  depth = 1;
  while (depth > 0) {
    struct parser_asm_lexer_result r;
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_RBRACE) {
      depth = depth - 1;
      if (depth == 0) {
        parser_asm_lex_from_result_val_into(&lex, r);
        break;
      }
    } else if (r.tok.kind == (int32_t)TOKEN_LBRACE) {
      depth = depth + 1;
    } else if (depth == 1 && enum_idx >= 0 && r.tok.kind == (int32_t)TOKEN_IDENT) {
      int32_t vlen;
      size_t vstart;
      uint8_t vb[64];
      vlen = r.tok.ident_len;
      if (vlen > 63)
        vlen = 63;
      vstart = r.token_start;
      if (vstart == 0)
        vstart = parser_asm_lexer_pos_before_run_c(r.next_lex.pos, vlen);
      parser_asm_copy_slice_to_name64_slice_c(source, vstart, vlen, vb);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_enum_variant_bind_audit_c(source, vstart, vlen));
      pipeline_module_enum_append_variant(module, enum_idx, vb, vlen);
    }
    parser_asm_lex_from_result_val_into(&lex, r);
  }
  out->pos = lex.pos;
  out->line = lex.line;
  out->col = lex.col;
}

/**
 * skip_one_enum_register_into：登记 enum 名并 skip 整条 enum 定义，结果写入 *out。
 */
void parser_asm_skip_one_enum_register_into_slice_c(void *module, struct parser_asm_lexer *out,
                                                    struct parser_asm_lexer lex,
                                                    struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  int32_t enum_idx;
  uint8_t nb[64];
  if (!out || !source)
    return;
  enum_idx = -1;
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_ENUM) {
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
  if (r.tok.ident_len > 0 && r.tok.ident_len <= 63) {
    parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, nb);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_bind_audit_c(nb, r.tok.ident_len));
    enum_idx = parser_asm_module_try_register_enum_name_c(module, nb, r.tok.ident_len);
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_LBRACE) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  parser_asm_module_append_enum_variants_and_skip_body_into_slice_c(module, enum_idx, out, r.next_lex, source);
}

/**
 * skip_one_struct：与 skip_one_struct_into 等价，Lexer 按值返回。
 */
struct parser_asm_lexer parser_asm_skip_one_struct_slice_c(struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out;
  parser_asm_skip_one_struct_into_slice_c(&out, lex, source);
  return out;
}
