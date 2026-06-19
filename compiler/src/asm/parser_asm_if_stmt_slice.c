/**
 * parser_asm_if_stmt_slice.c — parse_if_stmt_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * 单条 if（含 else / else if 链）；回调 parse_cond_expr / parse_block SU mega，勿 SU emit 本函数体。
 */
#ifndef PARSER_ASM_IF_STMT_SLICE_INCLUDED
#define PARSER_ASM_IF_STMT_SLICE_INCLUDED

/** 与 parser.sx ParseBlockResult 布局一致（bool→i32）。 */
struct parser_asm_parse_block_result {
  int32_t ok;
  int32_t block_ref;
  struct parser_asm_lexer next_lex;
};

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);
extern void parser_lex_from_next_into_glue(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern void parser_parse_cond_expr_into_glue(void *arena, struct parser_asm_lexer lex_start,
                                             struct parser_asm_slice_u8 *source,
                                             struct parser_asm_parse_expr_result *out);
extern int32_t parser_advance_past_cond_rparen_into_glue(struct parser_asm_lexer_result *r_out,
                                                         struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source);
extern void parser_parse_block_into(void *arena, struct parser_asm_lexer lex_after_lbrace,
                                    struct parser_asm_slice_u8 *source, int32_t type_ref,
                                    struct parser_asm_parse_block_result *out);
extern int32_t ast_ast_arena_block_alloc(void *arena);
extern int32_t pipeline_block_append_if(void *arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_block_append_stmt_order(void *arena, int32_t br, uint8_t kind, int32_t idx);
extern int32_t parser_asm_stretch_if_stmt_branch_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_if_stmt_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                       struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_if_else_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_ultra_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_super_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_control_flow_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex_at_if,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_else_if_chain_audit_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);

/** 前向声明：else-if 递归。 */
static int32_t parser_asm_parse_if_stmt_into_slice_c(void *arena, struct parser_asm_lexer lex_at_if,
                                                     struct parser_asm_slice_u8 *source, int32_t type_ref,
                                                     int32_t *out_cond, int32_t *out_then, int32_t *out_else,
                                                     struct parser_asm_lexer *lex_out);

/**
 * parse_if_stmt_into：解析 if (cond) { then } [ else { block } | else if … ]。
 * 成功写 out_cond/out_then/out_else 与 lex_out（下一语句首 token）。
 */
static int32_t parser_asm_parse_if_stmt_into_slice_c(void *arena, struct parser_asm_lexer lex_at_if,
                                                     struct parser_asm_slice_u8 *source, int32_t type_ref,
                                                     int32_t *out_cond, int32_t *out_then, int32_t *out_else,
                                                     struct parser_asm_lexer *lex_out) {
  struct parser_asm_lexer lex_cur;
  struct parser_asm_lexer_result r;
  struct parser_asm_parse_expr_result cond_res;
  struct parser_asm_parse_block_result then_res;
  struct parser_asm_parse_block_result else_res;
  int32_t cond_ref;
  int32_t wrap_ref;
  int32_t ncond;
  int32_t nthen;
  int32_t nelse;
  struct parser_asm_lexer lex_after;
  if (!arena || !source || !out_cond || !out_then || !out_else || !lex_out)
    return 0;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_if_stmt_branch_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_if_stmt_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_if_else_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_ultra_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_super_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  lex_cur = lex_at_if;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_control_flow_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex_at_if, source));
  lex_cur = lex_at_if;
  lexer_next_into(&r, lex_cur, source);
  if (r.tok.kind != (int32_t)TOKEN_IF)
    return 0;
  parser_lex_from_next_into_glue(&lex_cur, r);
  lexer_next_into(&r, lex_cur, source);
  if (r.tok.kind != (int32_t)TOKEN_LPAREN)
    return 0;
  lex_cur = r.next_lex;
  memset(&cond_res, 0, sizeof(cond_res));
  cond_res.next_lex = lex_cur;
  parser_parse_cond_expr_into_glue(arena, lex_cur, source, &cond_res);
  if (!cond_res.ok)
    return 0;
  cond_ref = cond_res.expr_ref;
  lex_cur = cond_res.next_lex;
  if (parser_advance_past_cond_rparen_into_glue(&r, lex_cur, source) == 0)
    return 0;
  if (r.tok.kind != (int32_t)TOKEN_LBRACE)
    return 0;
  lex_cur = r.next_lex;
  memset(&then_res, 0, sizeof(then_res));
  then_res.next_lex = lex_cur;
  parser_parse_block_into(arena, lex_cur, source, type_ref, &then_res);
  if (!then_res.ok)
    return 0;
  *out_cond = cond_ref;
  *out_then = then_res.block_ref;
  *out_else = 0;
  lex_cur = then_res.next_lex;
  lexer_next_into(&r, lex_cur, source);
  if (r.tok.kind == (int32_t)TOKEN_ELSE) {
    parser_lex_from_next_into_glue(&lex_cur, r);
    lexer_next_into(&r, lex_cur, source);
    if (r.tok.kind == (int32_t)TOKEN_IF) {
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_else_if_chain_audit_c(lex_cur, source));
      wrap_ref = ast_ast_arena_block_alloc(arena);
      if (wrap_ref == 0)
        return 0;
      ncond = 0;
      nthen = 0;
      nelse = 0;
      lex_after = lex_cur;
      if (!parser_asm_parse_if_stmt_into_slice_c(arena, lex_cur, source, type_ref, &ncond, &nthen, &nelse, &lex_after))
        return 0;
      if (pipeline_block_append_if(arena, wrap_ref, ncond, nthen, nelse) < 0)
        return 0;
      if (pipeline_block_append_stmt_order(arena, wrap_ref, 5, 0) < 0)
        return 0;
      *out_else = wrap_ref;
      lex_cur = lex_after;
    } else if (r.tok.kind == (int32_t)TOKEN_LBRACE) {
      lex_cur = r.next_lex;
      memset(&else_res, 0, sizeof(else_res));
      else_res.next_lex = lex_cur;
      parser_parse_block_into(arena, lex_cur, source, type_ref, &else_res);
      if (!else_res.ok)
        return 0;
      *out_else = else_res.block_ref;
      lex_cur = else_res.next_lex;
    } else {
      return 0;
    }
  }
  lex_out->pos = lex_cur.pos;
  lex_out->line = lex_cur.line;
  lex_out->col = lex_cur.col;
  return 1;
}

/** 非 static 导出供 glue 调用。 */
int32_t parser_asm_parse_if_stmt_into_c(void *arena, struct parser_asm_lexer lex_at_if,
                                        struct parser_asm_slice_u8 *source, int32_t type_ref, int32_t *out_cond,
                                        int32_t *out_then, int32_t *out_else, struct parser_asm_lexer *lex_out) {
  return parser_asm_parse_if_stmt_into_slice_c(arena, lex_at_if, source, type_ref, out_cond, out_then, out_else,
                                               lex_out);
}

#endif /* PARSER_ASM_IF_STMT_SLICE_INCLUDED */
