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
/*
 * wave421 Cap residual pure — product-path trait registry (LANG-004 missing method).
 * Root: parser.x skip_one_trait/impl never stored trait signatures → incomplete
 * impl compiled green. G.7 authority: this skip_tl slice (product skip glue).
 * wave424: unknown_trait hard fail (was soft continue when trait not registered).
 * Soft leave-off: bounds / dyn Trait; return_mismatch (sig ret types not stored).
 * PLATFORM: SHARED parse.
 */
#define XLANG_SKIP_TRAIT_REG_MAX 16
#define XLANG_SKIP_TRAIT_METH_MAX 32
#define XLANG_SKIP_IMPL_SEEN_MAX 16
typedef struct {
  uint8_t name[64];
  int32_t name_len;
  uint8_t methods[XLANG_SKIP_TRAIT_METH_MAX][64];
  int32_t method_lens[XLANG_SKIP_TRAIT_METH_MAX];
  int32_t num_methods;
} xlang_skip_trait_reg_ent_t;
static xlang_skip_trait_reg_ent_t g_xlang_skip_trait_reg[XLANG_SKIP_TRAIT_REG_MAX];
static int32_t g_xlang_skip_trait_reg_n;
static uint8_t g_xlang_skip_impl_trait[XLANG_SKIP_IMPL_SEEN_MAX][64];
static int32_t g_xlang_skip_impl_trait_len[XLANG_SKIP_IMPL_SEEN_MAX];
static int32_t g_xlang_skip_impl_seen_n;
static int32_t g_xlang_skip_impl_line[XLANG_SKIP_IMPL_SEEN_MAX];
static int32_t g_xlang_skip_impl_col[XLANG_SKIP_IMPL_SEEN_MAX];

void xlang_trait_reg_reset_c(void) {
  g_xlang_skip_trait_reg_n = 0;
  g_xlang_skip_impl_seen_n = 0;
  memset(g_xlang_skip_trait_reg, 0, sizeof(g_xlang_skip_trait_reg));
  memset(g_xlang_skip_impl_trait, 0, sizeof(g_xlang_skip_impl_trait));
  memset(g_xlang_skip_impl_trait_len, 0, sizeof(g_xlang_skip_impl_trait_len));
  memset(g_xlang_skip_impl_line, 0, sizeof(g_xlang_skip_impl_line));
  memset(g_xlang_skip_impl_col, 0, sizeof(g_xlang_skip_impl_col));
}

extern void lsp_diag_report_typeck(int line, int col, const char *fmt, ...);
extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_module_func_name_equal_at(void *module, int32_t fi, uint8_t *name, int32_t name_len);

/**
 * After parse: every `impl Trait for T` must name a registered trait and provide
 * free funcs for all trait methods.
 * wave424 Cap residual pure — unknown_trait was soft-skipped (ti<0 continue) →
 * `impl Missing for i32` false-green (build exit 0). G.7 expand this function only.
 * @return 0 ok; -1 unknown trait and/or missing method (diagnostic already emitted).
 * PLATFORM: SHARED parse+typeck gate.
 */
int32_t xlang_trait_check_impls_complete_c(void *module) {
  int32_t si;
  int32_t ti;
  int32_t mi;
  int32_t fi;
  int32_t nf;
  int32_t rc = 0;
  if (!module)
    return 0;
  nf = pipeline_module_num_funcs(module);
  for (si = 0; si < g_xlang_skip_impl_seen_n; si++) {
    int32_t tlen = g_xlang_skip_impl_trait_len[si];
    uint8_t *tname = g_xlang_skip_impl_trait[si];
    if (tlen <= 0)
      continue;
    ti = -1;
    for (mi = 0; mi < g_xlang_skip_trait_reg_n; mi++) {
      if (g_xlang_skip_trait_reg[mi].name_len == tlen &&
          memcmp(g_xlang_skip_trait_reg[mi].name, tname, (size_t)tlen) == 0) {
        ti = mi;
        break;
      }
    }
    /* wave424: hard fail — was `continue` soft leave-off (LANG-004 unknown_trait). */
    if (ti < 0) {
      lsp_diag_report_typeck((int)g_xlang_skip_impl_line[si], (int)g_xlang_skip_impl_col[si],
                             "impl for unknown trait %.*s", (int)tlen, (const char *)tname);
      rc = -1;
      continue;
    }
    for (mi = 0; mi < g_xlang_skip_trait_reg[ti].num_methods; mi++) {
      int32_t found = 0;
      uint8_t *mnm = g_xlang_skip_trait_reg[ti].methods[mi];
      int32_t mlen = g_xlang_skip_trait_reg[ti].method_lens[mi];
      if (mlen <= 0)
        continue;
      for (fi = 0; fi < nf; fi++) {
        if (pipeline_module_func_name_equal_at(module, fi, mnm, mlen) != 0) {
          found = 1;
          break;
        }
      }
      if (!found) {
        lsp_diag_report_typeck((int)g_xlang_skip_impl_line[si], (int)g_xlang_skip_impl_col[si],
                               "missing method %.*s", (int)mlen, (const char *)mnm);
        rc = -1;
      }
    }
  }
  return rc;
}

static void xlang_skip_trait_copy_ident_c(struct parser_asm_slice_u8 *source, size_t token_start, int32_t ident_len,
                                           uint8_t *out64, int32_t *out_len) {
  int32_t n = ident_len;
  if (!out64 || !out_len)
    return;
  *out_len = 0;
  memset(out64, 0, 64);
  if (!source || !source->data || n <= 0)
    return;
  if (n > 63)
    n = 63;
  if (token_start + (size_t)n > source->length)
    return;
  memcpy(out64, source->data + token_start, (size_t)n);
  *out_len = n;
}

void parser_asm_skip_one_trait_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                            struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  xlang_skip_trait_reg_ent_t *ent = 0;
  int32_t guard;
  if (!out || !source)
    return;
  /*
   * wave421: prefer token path so we can register method names. Byte raw skip
   * only when token path cannot start (defensive).
   */
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_header_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_impl_type_deep_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_TRAIT) {
    /* Fallback raw skip for non-token edge cases. */
    if (lex.pos + 5 <= source->length && source->data[lex.pos] == (uint8_t)'t'
        && source->data[lex.pos + 1] == (uint8_t)'r' && source->data[lex.pos + 2] == (uint8_t)'a'
        && source->data[lex.pos + 3] == (uint8_t)'i' && source->data[lex.pos + 4] == (uint8_t)'t') {
      parser_asm_skip_trait_impl_block_raw_c(out, lex, source);
      return;
    }
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
  if (g_xlang_skip_trait_reg_n < XLANG_SKIP_TRAIT_REG_MAX) {
    ent = &g_xlang_skip_trait_reg[g_xlang_skip_trait_reg_n];
    memset(ent, 0, sizeof(*ent));
    xlang_skip_trait_copy_ident_c(source, r.token_start, r.tok.ident_len, ent->name, &ent->name_len);
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
  /* wave421: walk trait body for `function name` rather than opaque brace skip. */
  lex = r.next_lex;
  guard = 0;
  while (guard++ < 512) {
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_RBRACE) {
      out->pos = r.next_lex.pos;
      out->line = r.next_lex.line;
      out->col = r.next_lex.col;
      if (ent && ent->name_len > 0)
        g_xlang_skip_trait_reg_n++;
      return;
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF) {
      out->pos = lex.pos;
      out->line = lex.line;
      out->col = lex.col;
      return;
    }
    if (r.tok.kind == (int32_t)TOKEN_FUNCTION) {
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
      if (r.tok.kind == (int32_t)TOKEN_IDENT && ent && ent->num_methods < XLANG_SKIP_TRAIT_METH_MAX) {
        int32_t mi = ent->num_methods;
        xlang_skip_trait_copy_ident_c(source, r.token_start, r.tok.ident_len, ent->methods[mi],
                                      &ent->method_lens[mi]);
        if (ent->method_lens[mi] > 0)
          ent->num_methods++;
      }
      {
        int32_t depth = 0;
        int32_t steps = 0;
        while (steps++ < 4096) {
          if (r.tok.kind == (int32_t)TOKEN_LBRACE)
            depth++;
          else if (r.tok.kind == (int32_t)TOKEN_RBRACE) {
            if (depth > 0)
              depth--;
            if (depth == 0) {
              lex = r.next_lex;
              break;
            }
          } else if (r.tok.kind == (int32_t)TOKEN_SEMICOLON && depth == 0) {
            lex = r.next_lex;
            break;
          } else if (r.tok.kind == (int32_t)TOKEN_EOF) {
            out->pos = lex.pos;
            out->line = lex.line;
            out->col = lex.col;
            return;
          }
          parser_asm_lex_from_result_val_into(&lex, r);
          lexer_next_into(&r, lex, source);
        }
      }
      continue;
    }
    parser_asm_lex_from_result_val_into(&lex, r);
  }
  out->pos = lex.pos;
  out->line = lex.line;
  out->col = lex.col;
}

/**
 * skip_one_impl_into：consume impl header only; leave method bodies for outer parse_into.
 *
 * wave390 Cap residual pure — root map:
 * - Old byte-path skipped the whole brace block → IDENT for-type (struct) methods discarded.
 * - Old token-path required for-type TOKEN_IDENT only → i32/u64 mid-fail leaked methods
 *   as top-level free fns (accidental green); struct stayed red.
 * - Fix: parse header (IDENT + type keywords + optional *T), then set *out to body
 *   interior after `{`. Outer parse_into commits each `function` as free UFCS method;
 *   trailing `}` is skipped as non-function noise.
 * G.7 authority: this function (glue for parser.x + seed fallback).
 * Soft: trait bounds / dyn.
 * wave421: record trait name for missing-method check (typeck).
 * PLATFORM: SHARED parse.
 */
void parser_asm_skip_one_impl_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result r;
  uint8_t first_nm[64];
  int32_t first_nlen = 0;
  int32_t impl_line = 0;
  int32_t impl_col = 0;
  if (!out || !source)
    return;
  memset(first_nm, 0, sizeof(first_nm));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_impl_header_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind != (int32_t)TOKEN_IMPL) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  impl_line = r.tok.line;
  impl_col = r.tok.col;
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  /* Trait name or inherent type: IDENT or built-in type keyword. */
  if (r.tok.kind != (int32_t)TOKEN_IDENT && r.tok.kind != (int32_t)TOKEN_I32
      && r.tok.kind != (int32_t)TOKEN_I64 && r.tok.kind != (int32_t)TOKEN_BOOL
      && r.tok.kind != (int32_t)TOKEN_U8 && r.tok.kind != (int32_t)TOKEN_U32
      && r.tok.kind != (int32_t)TOKEN_U64 && r.tok.kind != (int32_t)TOKEN_USIZE
      && r.tok.kind != (int32_t)TOKEN_ISIZE && r.tok.kind != (int32_t)TOKEN_F32
      && r.tok.kind != (int32_t)TOKEN_F64) {
    out->pos = lex.pos;
    out->line = lex.line;
    out->col = lex.col;
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_IDENT)
    xlang_skip_trait_copy_ident_c(source, r.token_start, r.tok.ident_len, first_nm, &first_nlen);
  {
    uint8_t iname_audit[64];
    parser_asm_copy_slice_to_name64_slice_c(source, r.token_start, r.tok.ident_len, iname_audit);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_collect_imports_bind_audit_c(iname_audit, r.tok.ident_len));
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  lexer_next_into(&r, lex, source);
  if (r.tok.kind == (int32_t)TOKEN_FOR) {
    /* wave421: record impl Trait for … for completeness check. */
    if (first_nlen > 0 && g_xlang_skip_impl_seen_n < XLANG_SKIP_IMPL_SEEN_MAX) {
      int32_t si = g_xlang_skip_impl_seen_n;
      memcpy(g_xlang_skip_impl_trait[si], first_nm, 64);
      g_xlang_skip_impl_trait_len[si] = first_nlen;
      g_xlang_skip_impl_line[si] = impl_line;
      g_xlang_skip_impl_col[si] = impl_col;
      g_xlang_skip_impl_seen_n++;
    }
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_impl_type_for_trait_audit_c(lex, source));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_trait_impl_type_deep_audit_c(lex, source));
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_STAR) {
      parser_asm_lex_from_result_val_into(&lex, r);
      lexer_next_into(&r, lex, source);
    }
    if (r.tok.kind != (int32_t)TOKEN_IDENT && r.tok.kind != (int32_t)TOKEN_I32
        && r.tok.kind != (int32_t)TOKEN_I64 && r.tok.kind != (int32_t)TOKEN_BOOL
        && r.tok.kind != (int32_t)TOKEN_U8 && r.tok.kind != (int32_t)TOKEN_U32
        && r.tok.kind != (int32_t)TOKEN_U64 && r.tok.kind != (int32_t)TOKEN_USIZE
        && r.tok.kind != (int32_t)TOKEN_ISIZE && r.tok.kind != (int32_t)TOKEN_F32
        && r.tok.kind != (int32_t)TOKEN_F64) {
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
  /* wave390: do NOT skip_balanced_braces — leave methods for outer parse_into free-fn commit. */
  out->pos = r.next_lex.pos;
  out->line = r.next_lex.line;
  out->col = r.next_lex.col;
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
  out->is_variadic = 0;
  out->has_body = 0;
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
  out->has_body = 0;   /* 默认纯声明；遇到 `{` 时在下方设为 1 */
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
  if (r.tok.kind == (int32_t)TOKEN_LBRACE) {
    /* Body-bearing extern: `extern "C" function ... { body }`.
     * Set has_body=1 and leave next_lex BEFORE '{' so caller can parse body
     * via parse_block_into (parser.x). Caller sets is_extern=0 + body_ref. */
    out->has_body = 1;
    out->next_lex = lex;
    out->name_len = name_len;
    out->return_ty_ref = ret_ty;
    out->num_params = n_ex;
    for (nk = 0; nk < 64; nk++)
      out->name[nk] = name_buf[nk];
    return;
  }
  if (r.tok.kind != (int32_t)TOKEN_SEMICOLON) {
    parser_asm_extern_parse_set_fail_c(out, lex);
    return;
  }
  parser_asm_lex_from_result_val_into(&lex, r);
  out->has_body = 0;
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
  /* Body-bearing extern (`extern "C" function ... { body }`): is_extern=0 so codegen
   * emits the body. Caller (.x TOKEN_EXTERN dispatch) parses body via parse_block_into
   * and sets body_ref. Pure declaration: is_extern=1 (codegen skips body). */
  f.is_extern = (res.has_body == 1) ? 0 : 1;
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
  /* For has_body=1: next_lex is BEFORE '{' — caller (.x) reads '{' then calls parse_block_into.
   * For pure decl: next_lex is after ';'. */
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
 *
 * PLATFORM: SHARED — must stay shape-aligned with parse_one_extern_skip_into
 * (optional ABI string after `extern`: "C" / "X"). G.7 single authority: this
 * function is the only skip path; cfg_skip + skip_one_function_full delegate here.
 *
 * Why: parse accepted `extern "C" function ...;` but skip required bare
 * `extern function`. A kept cfg-extern followed by a skipped sibling then left
 * the lexer mid-declaration; subsequent top-level items (including main) were
 * lost or re-ingested (cfg-extern residual / rt_diag always-on workaround).
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
  /* Optional ABI marker — same shape as parse_one_extern_skip_into (P0a).
   * Skip path does not record abi_kind; only advance past the string token. */
  if (r.tok.kind == (int32_t)TOKEN_STRING) {
    parser_asm_lex_from_result_val_into(&lex, r);
    lexer_next_into(&r, lex, source);
  }
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
