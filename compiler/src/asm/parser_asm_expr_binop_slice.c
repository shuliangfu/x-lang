/**
 * parser_asm_expr_binop_slice.c — parse_term_into / parse_addsub_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * cast/unary/as_suffix 已 thin delegate；本 slice 处理 expr 左结合二元链至 compare。
 */
#ifndef PARSER_ASM_EXPR_BINOP_SLICE_INCLUDED
#define PARSER_ASM_EXPR_BINOP_SLICE_INCLUDED

enum {
  PARSER_ASM_EXPR_MUL = 6,
  PARSER_ASM_EXPR_DIV = 7,
  PARSER_ASM_EXPR_MOD = 8,
  PARSER_ASM_EXPR_ADD = 4,
  PARSER_ASM_EXPR_SUB = 5,
  PARSER_ASM_EXPR_SHL = 9,
  PARSER_ASM_EXPR_SHR = 10,
  PARSER_ASM_EXPR_EQ = 14,
  PARSER_ASM_EXPR_NE = 15,
  PARSER_ASM_EXPR_LT = 16,
  PARSER_ASM_EXPR_LE = 17,
  PARSER_ASM_EXPR_GT = 18,
  PARSER_ASM_EXPR_GE = 19,
  PARSER_ASM_EXPR_BITAND = 11,
  PARSER_ASM_EXPR_BITOR = 12,
  PARSER_ASM_EXPR_BITXOR = 13,
  PARSER_ASM_EXPR_LOGAND = 20,
  PARSER_ASM_EXPR_LOGOR = 21
};

extern void parser_parse_cast_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                   struct parser_asm_parse_expr_result *out);
extern void parser_parse_term_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                   struct parser_asm_parse_expr_result *out);
extern void parser_parse_addsub_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);
extern void parser_parse_shift_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                    struct parser_asm_parse_expr_result *out);
extern void parser_parse_relcompare_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out);
extern void parser_parse_compare_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                      struct parser_asm_parse_expr_result *out);
extern void parser_parse_bitand_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);
extern void parser_parse_bitxor_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);
extern void parser_parse_bitor_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                    struct parser_asm_parse_expr_result *out);
extern void parser_parse_logand_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                     struct parser_asm_parse_expr_result *out);

static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae);
static void parser_asm_expr_set_common_zeros_c(struct parser_asm_ast_expr *e);
static void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);

extern int32_t parser_asm_stretch_expr_binop_lower_chain_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_binop_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_ultra_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_super_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_stmt_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                  struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_binop_full_chain_audit_c(struct parser_asm_lexer lex,
                                                                struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_binop_upper_chain_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_binop_mid_chain_audit_c(struct parser_asm_lexer lex,
                                                               struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_mul_binop_audit_c(struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_addsub_binop_audit_c(struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_shift_binop_audit_c(struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_rel_binop_audit_c(struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_eq_binop_audit_c(struct parser_asm_lexer lex,
                                                        struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_bitand_binop_audit_c(struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_bitxor_binop_audit_c(struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_bitor_binop_audit_c(struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_logand_binop_audit_c(struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_expr_logor_binop_audit_c(struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source);

/** 分配二元节点并写入 left/right/kind。 */
static int32_t parser_asm_binop_wrap_c(void *arena, struct parser_asm_parse_expr_result *out, int32_t kind,
                                       int32_t left_ref, int32_t right_ref) {
  int32_t bin_ref;
  struct parser_asm_ast_expr be;
  if (!arena || !out)
    return 0;
  bin_ref = ast_ast_arena_expr_alloc(arena);
  if (bin_ref == 0) {
    out->ok = 0;
    return 0;
  }
  be = parser_asm_arena_expr_get_c(arena, bin_ref);
  parser_asm_expr_set_common_zeros_c(&be);
  be.kind = kind;
  be.binop_left_ref = left_ref;
  be.binop_right_ref = right_ref;
  be.line = 0;
  be.col = 0;
  parser_asm_arena_expr_set_c(arena, bin_ref, be);
  out->expr_ref = bin_ref;
  return bin_ref;
}

/** parse_term_into：cast ( (*|/|%) cast )*。 */
void parser_asm_parse_term_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                        struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_cast_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_lower_chain_audit_c(out->next_lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_mul_binop_audit_c(out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    lexer_next_into(&r, lex_cur, source);
    kind = -1;
    if (r.tok.kind == (int32_t)TOKEN_STAR)
      kind = PARSER_ASM_EXPR_MUL;
    else if (r.tok.kind == (int32_t)TOKEN_SLASH)
      kind = PARSER_ASM_EXPR_DIV;
    else if (r.tok.kind == (int32_t)TOKEN_PERCENT)
      kind = PARSER_ASM_EXPR_MOD;
    else {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    parser_parse_cast_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_addsub_into：term ( (+|-) term )*。 */
void parser_asm_parse_addsub_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_term_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_addsub_binop_audit_c(out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    lexer_next_into(&r, lex_cur, source);
    kind = -1;
    if (r.tok.kind == (int32_t)TOKEN_PLUS)
      kind = PARSER_ASM_EXPR_ADD;
    else if (r.tok.kind == (int32_t)TOKEN_MINUS)
      kind = PARSER_ASM_EXPR_SUB;
    else {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    parser_parse_term_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_shift_into：addsub ( (<<|>>) addsub )*。 */
void parser_asm_parse_shift_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_addsub_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_shift_binop_audit_c(out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    lexer_next_into(&r, lex_cur, source);
    kind = -1;
    if (r.tok.kind == (int32_t)TOKEN_LSHIFT)
      kind = PARSER_ASM_EXPR_SHL;
    else if (r.tok.kind == (int32_t)TOKEN_RSHIFT)
      kind = PARSER_ASM_EXPR_SHR;
    else {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    parser_parse_addsub_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_relcompare_into：shift ( (<|<=|>|>=) shift )*。 */
void parser_asm_parse_relcompare_into_slice_c(void *arena, struct parser_asm_lexer lex,
                                              struct parser_asm_slice_u8 *source,
                                              struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_shift_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_upper_chain_audit_c(out->next_lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_rel_binop_audit_c(out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    lexer_next_into(&r, lex_cur, source);
    kind = -1;
    if (r.tok.kind == (int32_t)TOKEN_LT)
      kind = PARSER_ASM_EXPR_LT;
    else if (r.tok.kind == (int32_t)TOKEN_LE)
      kind = PARSER_ASM_EXPR_LE;
    else if (r.tok.kind == (int32_t)TOKEN_GT)
      kind = PARSER_ASM_EXPR_GT;
    else if (r.tok.kind == (int32_t)TOKEN_GE)
      kind = PARSER_ASM_EXPR_GE;
    else {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    parser_parse_shift_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_compare_into：relcompare ( (==|!=) relcompare )*。 */
void parser_asm_parse_compare_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                           struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t kind;
  int32_t left_ref;
  if (!out || !source)
    return;
  parser_parse_relcompare_into(arena, lex, source, out);
  if (!out->ok)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_eq_binop_audit_c(out->next_lex, source));
  lex_cur = out->next_lex;
  for (;;) {
    lexer_next_into(&r, lex_cur, source);
    kind = -1;
    if (r.tok.kind == (int32_t)TOKEN_EQ)
      kind = PARSER_ASM_EXPR_EQ;
    else if (r.tok.kind == (int32_t)TOKEN_NE)
      kind = PARSER_ASM_EXPR_NE;
    else {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    parser_parse_relcompare_into(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** 单 token 左结合二元链：首 operand 已由 lower 解析。 */
static void parser_asm_binop_single_tok_chain_c(void *arena, struct parser_asm_lexer lex,
                                                struct parser_asm_slice_u8 *source,
                                                struct parser_asm_parse_expr_result *out, int32_t tok_kind,
                                                int32_t expr_kind,
                                                void (*lower)(void *, struct parser_asm_lexer, struct parser_asm_slice_u8 *,
                                                              struct parser_asm_parse_expr_result *),
                                                int32_t (*audit_fn)(struct parser_asm_lexer,
                                                                    struct parser_asm_slice_u8 *)) {
  struct parser_asm_lexer_result r;
  struct parser_asm_lexer lex_cur;
  int32_t left_ref;
  if (!out || !source || !lower)
    return;
  lower(arena, lex, source, out);
  if (!out->ok)
    return;
  if (audit_fn)
    (void)audit_fn(out->next_lex, source);
  lex_cur = out->next_lex;
  for (;;) {
    lexer_next_into(&r, lex_cur, source);
    if (r.tok.kind != tok_kind) {
      out->next_lex = lex_cur;
      return;
    }
    left_ref = out->expr_ref;
    parser_asm_lex_from_result_val_into(&lex_cur, r);
    lower(arena, lex_cur, source, out);
    if (!out->ok)
      return;
    if (parser_asm_binop_wrap_c(arena, out, expr_kind, left_ref, out->expr_ref) == 0)
      return;
    lex_cur = out->next_lex;
  }
}

/** parse_bitand_into：compare ( & compare )*。 */
void parser_asm_parse_bitand_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_AMP, PARSER_ASM_EXPR_BITAND,
                                      parser_parse_compare_into, parser_asm_stretch_expr_bitand_binop_audit_c);
}

/** parse_bitxor_into：bitand ( ^ bitand )*。 */
void parser_asm_parse_bitxor_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_CARET, PARSER_ASM_EXPR_BITXOR,
                                      parser_parse_bitand_into, parser_asm_stretch_expr_bitxor_binop_audit_c);
}

/** parse_bitor_into：bitxor ( | bitxor )*。 */
void parser_asm_parse_bitor_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out) {
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_PIPE, PARSER_ASM_EXPR_BITOR,
                                      parser_parse_bitxor_into, parser_asm_stretch_expr_bitor_binop_audit_c);
}

/** parse_logand_into：bitor ( && bitor )*。 */
void parser_asm_parse_logand_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                          struct parser_asm_parse_expr_result *out) {
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_mid_chain_audit_c(lex, source));
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_AMPAMP, PARSER_ASM_EXPR_LOGAND,
                                      parser_parse_bitor_into, parser_asm_stretch_expr_logand_binop_audit_c);
}

/** parse_logor_into：logand ( || logand )*。 */
void parser_asm_parse_logor_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                         struct parser_asm_parse_expr_result *out) {
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_full_chain_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_binop_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_stmt_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_ultra_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_super_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_PIPEPIPE, PARSER_ASM_EXPR_LOGOR,
                                      parser_parse_logand_into, parser_asm_stretch_expr_logor_binop_audit_c);
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_expr_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  parser_asm_binop_single_tok_chain_c(arena, lex, source, out, (int32_t)TOKEN_PIPEPIPE, PARSER_ASM_EXPR_LOGOR,
                                      parser_parse_logand_into, parser_asm_stretch_expr_logor_binop_audit_c);
}

#endif /* PARSER_ASM_EXPR_BINOP_SLICE_INCLUDED */
