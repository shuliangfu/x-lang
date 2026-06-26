/**
 * parser_asm_primary_slice.c — parse_primary_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * INT/FLOAT/BOOL/break/continue/IDENT 后缀/paren/array/if/match/panic/@simd 与 parser.sx 一致。
 */
#ifndef PARSER_ASM_PRIMARY_SLICE_INCLUDED
#define PARSER_ASM_PRIMARY_SLICE_INCLUDED

/** 与 ast.sx ExprKind 序一致（primary 用到的子集；勿用 C ast.h 旧序 +32 误值）。 */
enum {
  PARSER_ASM_EXPR_LIT = 0,
  PARSER_ASM_EXPR_FLOAT_LIT = 1,
  PARSER_ASM_EXPR_BOOL_LIT = 2,
  PARSER_ASM_EXPR_VAR = 3,
  PARSER_ASM_EXPR_IF = 25,
  PARSER_ASM_EXPR_BREAK = 39,
  PARSER_ASM_EXPR_CONTINUE = 40,
  PARSER_ASM_EXPR_PANIC = 42,
  PARSER_ASM_EXPR_FIELD_ACCESS = 44,
  PARSER_ASM_EXPR_ARRAY_LIT = 46,
  PARSER_ASM_EXPR_INDEX = 47,
  PARSER_ASM_EXPR_CALL = 48,
  /** 与 ast.sx ExprKind.EXPR_METHOD_CALL 一致；`.method(...)` 后缀。 */
  PARSER_ASM_EXPR_METHOD_CALL = 49,
  /** 与 ast.h AST_EXPR_STRING_LIT 序一致；字符串字面量写入 var_name。 */
  PARSER_ASM_EXPR_STRING_LIT = 59
};

extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex,
                            struct parser_asm_slice_u8 *source);
extern void parse_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                            struct parser_asm_parse_expr_result *out);
extern void parser_parse_match_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                    struct parser_asm_parse_expr_result *out);
extern void parser_parse_if_expr_into(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                       int32_t type_ref, struct parser_asm_parse_expr_result *out);
extern void parser_parse_at_simd_builtin_into(void *arena, struct parser_asm_lexer_result r0,
                                              struct parser_asm_slice_u8 *source,
                                              struct parser_asm_parse_expr_result *out);
extern void parser_finish_struct_lit_from_type_ident_into_glue(void *arena, int32_t lit_ref,
                                                               struct parser_asm_lexer lex_in_brace,
                                                               struct parser_asm_slice_u8 *source,
                                                               struct parser_asm_parse_expr_result *out);
extern int32_t parser_asm_stretch_primary_head_audit_c(struct parser_asm_lexer lex,
                                                       struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_expr_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_expr_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_ultra_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_super_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_mega_full_deep_audit_c(struct parser_asm_lexer lex,
                                                                 struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_expr_deep_audit_c(struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_call_deep_audit_c(struct parser_asm_lexer lex,
                                                            struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_panic_kw_audit_c(struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_if_expr_branch_audit_c(struct parser_asm_lexer lex_at_if,
                                                       struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_array_lit_head_audit_c(struct parser_asm_lexer lex,
                                                         struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_primary_suffix_chain_probe_c(struct parser_asm_lexer lex,
                                                             struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_field_access_name_audit_c(struct parser_asm_slice_u8 *source, size_t token_start,
                                                            int32_t name_len);
extern int32_t parser_asm_stretch_call_args_shape_probe_c(struct parser_asm_lexer lex,
                                                          struct parser_asm_slice_u8 *source,
                                                          int32_t *out_arg_count);
extern int32_t parser_asm_stretch_paren_expr_head_audit_c(struct parser_asm_lexer lex,
                                                          struct parser_asm_slice_u8 *source);
extern int32_t pipeline_expr_append_call_arg(void *arena, int32_t expr_ref, int32_t arg_ref);
extern int32_t pipeline_expr_append_method_call_arg(void *arena, int32_t expr_ref, int32_t arg_ref);
extern void parser_asm_skip_generic_angle_list_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                              struct parser_asm_slice_u8 *source);
extern int32_t pipeline_expr_append_array_lit_elem(void *arena, int32_t expr_ref, int32_t elem_ref);
extern int32_t ast_ast_arena_expr_alloc(void *arena);

extern struct parser_asm_lexer parser_asm_lex_at_token_from_result_c(struct parser_asm_lexer_result r);

/** 分配 EXPR_FLOAT_LIT 节点；与 parser.sx parser_alloc_float_lit 一致。 */
static int32_t parser_asm_alloc_float_lit_c(void *arena, double fval) {
  int32_t ref;
  struct parser_asm_ast_expr e;
  if (!arena)
    return 0;
  ref = ast_ast_arena_expr_alloc(arena);
  if (ref == 0)
    return 0;
  e = parser_asm_arena_expr_get_c(arena, ref);
  e.kind = PARSER_ASM_EXPR_FLOAT_LIT;
  e.float_val = fval;
  e.line = 0;
  e.col = 0;
  parser_asm_expr_set_common_zeros_c(&e);
  parser_asm_arena_expr_set_c(arena, ref, e);
  return ref;
}

static void parser_asm_arena_expr_set_c(void *arena, int32_t ref, struct parser_asm_ast_expr ae);
static void parser_asm_expr_set_common_zeros_c(struct parser_asm_ast_expr *e);
static void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
struct parser_asm_ast_expr parser_asm_arena_expr_get_c(void *arena, int32_t ref);

/** 从 source[token_start..] 拷贝 ident 到 e.var_name（最多 63 字节 + 零填充）。 */
static void parser_asm_primary_copy_ident_to_var_c(struct parser_asm_ast_expr *e, struct parser_asm_slice_u8 *source,
                                                   size_t start, int32_t len) {
  int32_t i;
  if (!e)
    return;
  if (len > 63)
    len = 63;
  e->var_name_len = len;
  for (i = 0; i < len; i++) {
    if (start + (size_t)i < source->length)
      e->var_name[i] = source->data[start + i];
    else
      e->var_name[i] = 0;
  }
  while (i < 64) {
    e->var_name[i] = 0;
    i++;
  }
}

/** IDENT 后 `.field` / `[idx]` / `(args)` 后缀链；失败时写 out.ok=0 或仅写 out.next_lex 后返回。 */
static void parser_asm_primary_ident_suffix_loop_c(void *arena, struct parser_asm_slice_u8 *source,
                                                   struct parser_asm_lexer *lex, struct parser_asm_lexer_result *r,
                                                   struct parser_asm_parse_expr_result *out, int32_t first_suffix) {
  struct parser_asm_parse_expr_result arg_res;
  int32_t base_ref;
  int32_t fa_ref;
  int32_t idx_ref;
  int32_t call_ref;
  int32_t callee_ref;
  struct parser_asm_ast_expr fe;
  struct parser_asm_ast_expr ie;
  struct parser_asm_ast_expr ce_init;
  int32_t fi;

  for (;;) {
    if (!first_suffix)
      lexer_next_into(r, *lex, source);
    first_suffix = 0;
    if (r->tok.kind == (int32_t)TOKEN_DOT) {
      int32_t mc_ref;
      int32_t mname_len;
      struct parser_asm_ast_expr me;
      parser_asm_lex_from_result_val_into(lex, *r);
      lexer_next_into(r, *lex, source);
      if (r->tok.kind != (int32_t)TOKEN_IDENT) {
        out->next_lex = *lex;
        return;
      }
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_field_access_name_audit_c(source, r->token_start, r->tok.ident_len));
      mname_len = r->tok.ident_len;
      if (mname_len > 63)
        mname_len = 63;
      {
        size_t mname_start = r->token_start;
        parser_asm_lex_from_result_val_into(lex, *r);
        lexer_next_into(r, *lex, source);
        /** `.name(` → EXPR_METHOD_CALL；否则 EXPR_FIELD_ACCESS。 */
        if (r->tok.kind == (int32_t)TOKEN_LPAREN) {
          mc_ref = ast_ast_arena_expr_alloc(arena);
          if (mc_ref == 0) {
            out->ok = 0;
            return;
          }
          me = parser_asm_arena_expr_get_c(arena, mc_ref);
          parser_asm_expr_set_common_zeros_c(&me);
          me.kind = PARSER_ASM_EXPR_METHOD_CALL;
          me.method_call_base_ref = out->expr_ref;
          me.method_call_name_len = mname_len;
          fi = 0;
          while (fi < mname_len && (mname_start + (size_t)fi) < source->length) {
            me.method_call_name[fi] = source->data[mname_start + (size_t)fi];
            fi++;
          }
          while (fi < 64) {
            me.method_call_name[fi] = 0;
            fi++;
          }
          me.line = 0;
          me.col = 0;
          parser_asm_arena_expr_set_c(arena, mc_ref, me);
          out->expr_ref = mc_ref;
          *lex = r->next_lex;
          lexer_next_into(r, *lex, source);
          if (r->tok.kind != (int32_t)TOKEN_RPAREN) {
            for (;;) {
              memset(&arg_res, 0, sizeof(arg_res));
              arg_res.next_lex = *lex;
              parse_expr_into(arena, *lex, source, &arg_res);
              if (!arg_res.ok) {
                out->ok = 0;
                return;
              }
              if (pipeline_expr_append_method_call_arg(arena, mc_ref, arg_res.expr_ref) < 0) {
                out->ok = 0;
                return;
              }
              *lex = arg_res.next_lex;
              lexer_next_into(r, *lex, source);
              if (r->tok.kind == (int32_t)TOKEN_COMMA) {
                *lex = r->next_lex;
                continue;
              }
              if (r->tok.kind == (int32_t)TOKEN_RPAREN) {
                *lex = r->next_lex;
                break;
              }
              out->ok = 0;
              return;
            }
          } else {
            *lex = r->next_lex;
          }
        } else {
          fa_ref = ast_ast_arena_expr_alloc(arena);
          if (fa_ref == 0) {
            out->ok = 0;
            return;
          }
          fe = parser_asm_arena_expr_get_c(arena, fa_ref);
          parser_asm_expr_set_common_zeros_c(&fe);
          fe.kind = PARSER_ASM_EXPR_FIELD_ACCESS;
          fe.field_access_base_ref = out->expr_ref;
          fe.field_access_field_len = mname_len;
          fi = 0;
          while (fi < fe.field_access_field_len && (mname_start + (size_t)fi) < source->length) {
            fe.field_access_field_name[fi] = source->data[mname_start + (size_t)fi];
            fi++;
          }
          while (fi < 64) {
            fe.field_access_field_name[fi] = 0;
            fi++;
          }
          fe.line = 0;
          fe.col = 0;
          parser_asm_arena_expr_set_c(arena, fa_ref, fe);
          out->expr_ref = fa_ref;
          *lex = r->next_lex;
        }
      }
    } else if (r->tok.kind == (int32_t)TOKEN_LT) {
      /** 泛型实例化 `id<i32>(...)`：跳过 `<...>` 后继续后缀链。 */
      struct parser_asm_lexer after_angle;
      parser_asm_skip_generic_angle_list_into_slice_c(&after_angle, *lex, source);
      *lex = after_angle;
    } else if (r->tok.kind == (int32_t)TOKEN_LBRACKET) {
      base_ref = out->expr_ref;
      parser_asm_lex_from_result_val_into(lex, *r);
      parse_expr_into(arena, *lex, source, out);
      if (!out->ok)
        return;
      fi = out->expr_ref;
      *lex = out->next_lex;
      lexer_next_into(r, *lex, source);
      if (r->tok.kind != (int32_t)TOKEN_RBRACKET) {
        out->ok = 0;
        return;
      }
      *lex = r->next_lex;
      idx_ref = ast_ast_arena_expr_alloc(arena);
      if (idx_ref == 0) {
        out->ok = 0;
        return;
      }
      ie = parser_asm_arena_expr_get_c(arena, idx_ref);
      parser_asm_expr_set_common_zeros_c(&ie);
      ie.kind = PARSER_ASM_EXPR_INDEX;
      ie.index_base_ref = base_ref;
      ie.index_index_ref = fi;
      ie.index_base_is_slice = 0;
      ie.line = 0;
      ie.col = 0;
      parser_asm_arena_expr_set_c(arena, idx_ref, ie);
      out->expr_ref = idx_ref;
    } else if (r->tok.kind == (int32_t)TOKEN_LPAREN) {
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_call_args_shape_probe_c(r->next_lex, source, 0));
      callee_ref = out->expr_ref;
      *lex = r->next_lex;
      call_ref = ast_ast_arena_expr_alloc(arena);
      if (call_ref == 0) {
        out->ok = 0;
        return;
      }
      ce_init = parser_asm_arena_expr_get_c(arena, call_ref);
      ce_init.kind = PARSER_ASM_EXPR_CALL;
      ce_init.line = 0;
      ce_init.col = 0;
      parser_asm_expr_set_common_zeros_c(&ce_init);
      ce_init.call_callee_ref = callee_ref;
      parser_asm_arena_expr_set_c(arena, call_ref, ce_init);
      lexer_next_into(r, *lex, source);
      if (r->tok.kind != (int32_t)TOKEN_RPAREN) {
        for (;;) {
          memset(&arg_res, 0, sizeof(arg_res));
          arg_res.next_lex = *lex;
          parse_expr_into(arena, *lex, source, &arg_res);
          if (!arg_res.ok) {
            out->ok = 0;
            return;
          }
          if (pipeline_expr_append_call_arg(arena, call_ref, arg_res.expr_ref) < 0) {
            out->ok = 0;
            return;
          }
          *lex = arg_res.next_lex;
          lexer_next_into(r, *lex, source);
          if (r->tok.kind == (int32_t)TOKEN_COMMA) {
            *lex = r->next_lex;
            continue;
          }
          if (r->tok.kind == (int32_t)TOKEN_RPAREN) {
            *lex = r->next_lex;
            break;
          }
          out->ok = 0;
          return;
        }
      } else {
        *lex = r->next_lex;
      }
      out->expr_ref = call_ref;
    } else {
      out->next_lex = *lex;
      return;
    }
  }
}

/** panic / panic(expr) primary。 */
static void parser_asm_primary_parse_panic_c(void *arena, struct parser_asm_slice_u8 *source,
                                             struct parser_asm_lexer *lex, struct parser_asm_lexer_result *r,
                                             struct parser_asm_parse_expr_result *out) {
  struct parser_asm_parse_expr_result arg_pr;
  int32_t panic_op;
  int32_t pref;
  struct parser_asm_ast_expr pe;

  parser_asm_lex_from_result_val_into(lex, *r);
  lexer_next_into(r, *lex, source);
  panic_op = 0;
  if (r->tok.kind == (int32_t)TOKEN_LPAREN) {
    parser_asm_lex_from_result_val_into(lex, *r);
    lexer_next_into(r, *lex, source);
    if (r->tok.kind != (int32_t)TOKEN_RPAREN) {
      memset(&arg_pr, 0, sizeof(arg_pr));
      arg_pr.next_lex = *lex;
      parse_expr_into(arena, *lex, source, &arg_pr);
      if (!arg_pr.ok) {
        out->ok = 0;
        return;
      }
      panic_op = arg_pr.expr_ref;
      *lex = arg_pr.next_lex;
      lexer_next_into(r, *lex, source);
      if (r->tok.kind != (int32_t)TOKEN_RPAREN) {
        out->ok = 0;
        return;
      }
    }
    parser_asm_lex_from_result_val_into(lex, *r);
  }
  pref = ast_ast_arena_expr_alloc(arena);
  if (pref == 0) {
    out->ok = 0;
    return;
  }
  pe = parser_asm_arena_expr_get_c(arena, pref);
  parser_asm_expr_set_common_zeros_c(&pe);
  pe.kind = PARSER_ASM_EXPR_PANIC;
  pe.unary_operand_ref = panic_op;
  pe.line = 0;
  pe.col = 0;
  parser_asm_arena_expr_set_c(arena, pref, pe);
  out->ok = 1;
  out->expr_ref = pref;
  out->next_lex = *lex;
}

/** `[ e0, ... ]` / `[]` 数组字面量 primary。 */
static void parser_asm_primary_parse_array_lit_c(void *arena, struct parser_asm_slice_u8 *source,
                                                 struct parser_asm_lexer *lex, struct parser_asm_lexer_result *r,
                                                 struct parser_asm_parse_expr_result *out) {
  struct parser_asm_parse_expr_result elem_res;
  struct parser_asm_lexer elem_lex;
  int32_t arr_ref;
  struct parser_asm_ast_expr ae0;

  parser_asm_lex_from_result_val_into(lex, *r);
  lexer_next_into(r, *lex, source);
  arr_ref = ast_ast_arena_expr_alloc(arena);
  if (arr_ref == 0) {
    out->ok = 0;
    return;
  }
  ae0 = parser_asm_arena_expr_get_c(arena, arr_ref);
  ae0.kind = PARSER_ASM_EXPR_ARRAY_LIT;
  ae0.resolved_type_ref = 0;
  ae0.line = 0;
  ae0.col = 0;
  parser_asm_expr_set_common_zeros_c(&ae0);
  parser_asm_arena_expr_set_c(arena, arr_ref, ae0);
  if (r->tok.kind != (int32_t)TOKEN_RBRACKET) {
    for (;;) {
      elem_lex = parser_asm_lex_at_token_from_result_c(*r);
      memset(&elem_res, 0, sizeof(elem_res));
      elem_res.next_lex = elem_lex;
      parse_expr_into(arena, elem_lex, source, &elem_res);
      if (!elem_res.ok || elem_res.expr_ref == 0) {
        out->ok = 0;
        return;
      }
      if (pipeline_expr_append_array_lit_elem(arena, arr_ref, elem_res.expr_ref) < 0) {
        out->ok = 0;
        return;
      }
      *lex = elem_res.next_lex;
      lexer_next_into(r, *lex, source);
      if (r->tok.kind == (int32_t)TOKEN_COMMA) {
        parser_asm_lex_from_result_val_into(lex, *r);
        lexer_next_into(r, *lex, source);
        if (r->tok.kind == (int32_t)TOKEN_RBRACKET)
          break;
        continue;
      }
      break;
    }
  }
  if (r->tok.kind == (int32_t)TOKEN_RBRACKET) {
    out->ok = 1;
    out->expr_ref = arr_ref;
    out->next_lex = r->next_lex;
    return;
  }
  out->ok = 0;
}

/**
 * parse_primary_into：INT | FLOAT | BOOL | break | continue | IDENT 后缀 | (expr) | [] | if | match | panic | @simd。
 */
void parser_asm_parse_primary_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source,
                                           struct parser_asm_parse_expr_result *out) {
  struct parser_asm_lexer_result r;
  struct parser_asm_ast_expr e;
  int32_t ref;
  int32_t fref;
  struct parser_asm_lexer if_lex;

  if (!out || !source)
    return;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_head_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_expr_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_call_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_expr_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_expr_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_ultra_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_super_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  /** 须在第二次 lexer_next 之前处理 TOKEN_STRING：否则 `foo("")` 实参被跳过、let 后 return if 落入 buf 回退失败。 */
  if (r.tok.kind == (int32_t)TOKEN_STRING) {
    size_t q0;
    size_t k;
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out->ok = 0;
      return;
    }
    e = parser_asm_arena_expr_get_c(arena, ref);
    parser_asm_expr_set_common_zeros_c(&e);
    e.kind = PARSER_ASM_EXPR_STRING_LIT;
    e.line = r.tok.line;
    e.col = r.tok.col;
    /** lexer.sx：TOKEN_STRING 的 token_start 已指向开引号后首字节，勿再 +1。 */
    q0 = r.token_start;
    e.var_name_len = r.tok.ident_len;
    if (e.var_name_len > 63)
      e.var_name_len = 63;
    if (e.var_name_len < 0)
      e.var_name_len = 0;
    for (k = 0; k < (size_t)e.var_name_len; k++)
      e.var_name[k] = source->data[q0 + k];
    if ((size_t)e.var_name_len < 64)
      e.var_name[e.var_name_len] = 0;
    parser_asm_arena_expr_set_c(arena, ref, e);
    out->ok = 1;
    out->expr_ref = ref;
    out->next_lex = r.next_lex;
    return;
  }
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(lex, source));
  lexer_next_into(&r, lex, source);
  if (r.tok.kind == (int32_t)TOKEN_AT) {
    parser_parse_at_simd_builtin_into(arena, r, source, out);
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_INT) {
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out->ok = 0;
      return;
    }
    e = parser_asm_arena_expr_get_c(arena, ref);
    e.kind = PARSER_ASM_EXPR_LIT;
    e.line = r.tok.line;
    e.col = r.tok.col;
    e.int_val = r.tok.int_val;
    parser_asm_expr_set_common_zeros_c(&e);
    parser_asm_arena_expr_set_c(arena, ref, e);
    out->ok = 1;
    out->expr_ref = ref;
    lex = r.next_lex;
    /** 与 IDENT 一致：先 lex 到 INT 后 token，再进后缀链（否则 r 仍为 TOKEN_INT）。 */
    lexer_next_into(&r, lex, source);
    /** 字面量后缀 `.method()` / `[i]` / 泛型 `<T>` 实例化须走与 IDENT 相同的后缀链。 */
    parser_asm_primary_ident_suffix_loop_c(arena, source, &lex, &r, out, 1);
    out->next_lex = lex;
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_FLOAT) {
    fref = parser_asm_alloc_float_lit_c(arena, r.tok.float_val);
    if (fref == 0) {
      out->ok = 0;
      return;
    }
    out->ok = 1;
    out->expr_ref = fref;
    out->next_lex = r.next_lex;
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_TRUE || r.tok.kind == (int32_t)TOKEN_FALSE) {
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out->ok = 0;
      return;
    }
    e = parser_asm_arena_expr_get_c(arena, ref);
    e.kind = PARSER_ASM_EXPR_BOOL_LIT;
    e.int_val = (r.tok.kind == (int32_t)TOKEN_TRUE) ? 1 : 0;
    e.line = 0;
    e.col = 0;
    parser_asm_expr_set_common_zeros_c(&e);
    parser_asm_arena_expr_set_c(arena, ref, e);
    out->ok = 1;
    out->expr_ref = ref;
    out->next_lex = r.next_lex;
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_BREAK || r.tok.kind == (int32_t)TOKEN_CONTINUE) {
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out->ok = 0;
      return;
    }
    e = parser_asm_arena_expr_get_c(arena, ref);
    e.kind = (r.tok.kind == (int32_t)TOKEN_BREAK) ? PARSER_ASM_EXPR_BREAK : PARSER_ASM_EXPR_CONTINUE;
    e.line = 0;
    e.col = 0;
    parser_asm_expr_set_common_zeros_c(&e);
    parser_asm_arena_expr_set_c(arena, ref, e);
    out->ok = 1;
    out->expr_ref = ref;
    out->next_lex = r.next_lex;
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_MATCH) {
    parser_parse_match_into(arena, parser_asm_lex_at_token_from_result_c(r), source, out);
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_PANIC) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_panic_kw_audit_c(parser_asm_lex_at_token_from_result_c(r), source));
    parser_asm_primary_parse_panic_c(arena, source, &lex, &r, out);
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_IDENT) {
    ref = ast_ast_arena_expr_alloc(arena);
    if (ref == 0) {
      out->ok = 0;
      return;
    }
    e = parser_asm_arena_expr_get_c(arena, ref);
    e.kind = PARSER_ASM_EXPR_VAR;
    parser_asm_primary_copy_ident_to_var_c(&e, source, r.token_start, r.tok.ident_len);
    e.line = r.tok.line;
    e.col = r.tok.col;
    parser_asm_expr_set_common_zeros_c(&e);
    parser_asm_arena_expr_set_c(arena, ref, e);
    out->ok = 1;
    out->expr_ref = ref;
    lex = r.next_lex;
    lexer_next_into(&r, lex, source);
    if (r.tok.kind == (int32_t)TOKEN_LBRACE) {
      parser_finish_struct_lit_from_type_ident_into_glue(arena, ref, r.next_lex, source, out);
      return;
    }
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_primary_suffix_chain_probe_c(lex, source));
    parser_asm_primary_ident_suffix_loop_c(arena, source, &lex, &r, out, 1);
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_LPAREN) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_paren_expr_head_audit_c(lex, source));
    parser_asm_lex_from_result_val_into(&lex, r);
    parse_expr_into(arena, lex, source, out);
    if (!out->ok)
      return;
    lex = out->next_lex;
    lexer_next_into(&r, lex, source);
    if (r.tok.kind != (int32_t)TOKEN_RPAREN) {
      out->ok = 0;
      return;
    }
    out->next_lex = r.next_lex;
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_LBRACKET) {
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_array_lit_head_audit_c(parser_asm_lex_at_token_from_result_c(r), source));
    parser_asm_primary_parse_array_lit_c(arena, source, &lex, &r, out);
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_IF) {
    if_lex = parser_asm_lex_at_token_from_result_c(r);
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_if_expr_branch_audit_c(if_lex, source));
    parser_parse_if_expr_into(arena, if_lex, source, 0, out);
    return;
  }
  if (r.tok.kind == (int32_t)TOKEN_LBRACE) {
    /** 匿名 struct 字面量 `{ fd, x: 1 }`（let p: PollFd = { ... }）。 */
    parser_asm_parse_anonymous_struct_lit_c(arena, r.next_lex, source, out);
    return;
  }
  out->ok = 0;
}

#endif /* PARSER_ASM_PRIMARY_SLICE_INCLUDED */
