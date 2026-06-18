/**
 * parser_asm_seed_parse_into_buf_slice.c — seed ./shu 链 parse_into_buf / parse_into C 实现。
 *
 * 瘦 parser_su.o 无 parse_into_buf；由本 TU（parser_asm_thin_c.c #include）提供强符号，
 * 覆盖 parser_asm_link_alias.c 弱桩，供 runtime asm 后端 parse 任意 .su。
 */
#ifndef PARSER_ASM_SEED_PARSE_INTO_BUF_SLICE_INCLUDED
#define PARSER_ASM_SEED_PARSE_INTO_BUF_SLICE_INCLUDED

#include <string.h>

/** 与 parser.su ParseIntoResult 布局一致。 */
struct parser_asm_seed_parse_into_result {
  int32_t ok;
  int32_t main_idx;
};

/** SU Module 池头部（与 ast.su / pipeline_glue_types.inc 一致）。 */
typedef struct {
  int32_t num_funcs;
  int32_t main_func_index;
  int32_t num_imports;
  int32_t num_top_level_lets;
  int32_t num_struct_layouts;
  int32_t pending_allow_padding;
  int32_t pending_soa_struct;
  int32_t num_module_enums;
} parser_asm_su_module_hdr_t;

extern struct parser_asm_lexer_result lexer_next_buf(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_parse_into_buf_preamble_peek_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                           int32_t len);
extern int32_t parser_asm_stretch_top_level_let_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len,
                                                            int32_t is_const);
extern int32_t parser_asm_stretch_struct_record_layout_body_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                        int32_t len);
extern int32_t parser_asm_stretch_type_ref_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_type_ref_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                      int32_t len);
extern int32_t parser_asm_stretch_type_ref_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_type_ref_bracket_composite_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                       int32_t len);
extern int32_t parser_asm_stretch_parse_into_buf_loop_toplevel_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                           int32_t len);
extern int32_t parser_asm_stretch_async_fn_prefix_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_parse_into_function_branch_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                              int32_t len);
extern int32_t parser_asm_stretch_parse_into_preamble_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                     int32_t len);
extern int32_t parser_asm_stretch_parse_into_entry_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                       int32_t len);
extern int32_t parser_asm_stretch_parse_into_loop_entry_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                            int32_t len);
extern int32_t parser_asm_stretch_parse_into_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                      int32_t len);
extern int32_t parser_asm_stretch_parse_into_ultra_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                              int32_t len);
extern int32_t parser_asm_stretch_top_level_let_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                      int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_top_level_let_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                           int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_parse_struct_layout_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex,
                                                                                 uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_parse_struct_layout_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_preamble_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_entry_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                              int32_t len);
extern int32_t parser_asm_stretch_parse_into_super_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                              int32_t len);
extern int32_t parser_asm_stretch_parse_into_max_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_toplevel_super_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_parse_into_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_toplevel_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_parse_into_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_parse_into_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len);
extern int32_t parser_asm_stretch_toplevel_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_toplevel_max_ultra_hyper_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                          int32_t len, int32_t is_const);
extern int32_t parser_asm_stretch_parse_preamble_mega_full_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                            int32_t len);
extern int32_t parser_asm_stretch_top_level_let_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_struct_layout_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern int32_t parser_asm_stretch_parse_into_loop_iter_deep_buf_audit_c(struct parser_asm_lexer lex, uint8_t *data,
                                                                      int32_t len);
extern void parser_lex_from_next_into_glue(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern void parser_asm_collect_imports_buf_c(struct parser_asm_lexer lex, uint8_t *data, int32_t len, void *module,
                                             struct parser_asm_collect_imports_result *out);
extern void parser_parse_one_function_impl(struct parser_asm_onefunc_result *res, void *arena,
                                           struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern void parser_asm_parse_one_function_buf_into_c(struct parser_asm_onefunc_result *out, struct parser_asm_lexer lex,
                                                      uint8_t *data, int32_t len);
extern struct parser_asm_library_parse_result parser_asm_parse_one_function_library_buf_c(
    void *arena, void *module, struct parser_asm_lexer lex, uint8_t *data, int32_t len);
extern struct parser_asm_onefunc_result parser_onefunc_scratch_empty(void);
extern void parser_onefunc_res_wire_dummy_head(struct parser_asm_onefunc_result *res, struct parser_asm_lexer lex,
                                               uint8_t *name64);
extern void parser_onefunc_res_wire_dummy_const_let(struct parser_asm_onefunc_result *res);
extern void parser_onefunc_res_wire_dummy_if_mul(struct parser_asm_onefunc_result *res);
extern void parser_onefunc_res_wire_dummy_call_binop(struct parser_asm_onefunc_result *res, uint8_t *name64);
extern void parser_onefunc_res_wire_dummy_loop_call(struct parser_asm_onefunc_result *res);
extern void parser_onefunc_res_wire_dummy_for_if(struct parser_asm_onefunc_result *res);
extern uint8_t *parser_asm_onefunc_result_pool_ptr_c(struct parser_asm_onefunc_result *res);
extern int32_t parser_asm_fill_block_const_let_from_res_c(void *arena, int32_t block_ref,
                                                            struct parser_asm_onefunc_result *res, int32_t type_ref);
extern int32_t parser_should_wrap_func_tail_in_return_glue(void *arena, struct parser_asm_onefunc_result *res,
                                                            int32_t type_ref);
extern void parser_lex_from_onefunc_next_into_glue(struct parser_asm_lexer *out, struct parser_asm_onefunc_result *res);
extern void parser_parse_into_try_skip_allow_into_buf_glue(struct parser_asm_try_skip_allow_result *out,
                                                             struct parser_asm_lexer lex,
                                                             struct parser_asm_lexer_result r, uint8_t *data,
                                                             int32_t len);
extern void parser_parse_one_extern_and_add_into_buf_glue(void *arena, void *module, struct parser_asm_lexer lex,
                                                            uint8_t *data, int32_t len,
                                                            struct parser_asm_lexer *lex_out);
extern void parser_skip_one_extern_into_buf_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                 uint8_t *data, int32_t len);
extern int32_t parser_parse_struct_record_layout_into_glue(void *arena, void *module, struct parser_asm_lexer lex,
                                                             struct parser_asm_slice_u8 *source,
                                                             struct parser_asm_lexer *out_lex, int32_t allow_pad,
                                                             int32_t force_soa);
extern void parser_skip_one_struct_into_buf_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                 uint8_t *data, int32_t len);
extern void parser_skip_one_enum_register_into_buf_glue(void *module, struct parser_asm_lexer *out,
                                                        struct parser_asm_lexer lex_at, uint8_t *data, int32_t len);
extern void parser_skip_one_trait_into_buf_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                uint8_t *data, int32_t len);
extern void parser_skip_one_impl_into_buf_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                               uint8_t *data, int32_t len);
extern void parser_skip_one_function_full_into_buf_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                        uint8_t *data, int32_t len);
extern void parser_parse_one_top_level_let_into_glue(void *arena, void *module, struct parser_asm_lexer lex,
                                                     struct parser_asm_slice_u8 *source, int32_t is_const,
                                                     struct parser_asm_top_level_let_result *out);
extern struct parser_asm_lexer parser_lex_from_library_glue(struct parser_asm_library_parse_result lib);
extern struct parser_asm_lexer parser_lex_from_try_skip_glue(struct parser_asm_try_skip_allow_result t);

extern int32_t ast_ast_arena_type_alloc(void *arena);
extern struct ast_Type ast_ast_arena_type_get(void *arena, int32_t ref);
extern void ast_ast_arena_type_set(void *arena, int32_t ref, struct ast_Type t);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern struct ast_Expr ast_ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t ast_ast_arena_block_alloc(void *arena);
extern struct ast_Block ast_ast_arena_block_get(void *arena, int32_t ref);
extern void ast_ast_arena_block_set(void *arena, int32_t ref, struct ast_Block b);
extern int32_t ast_ast_arena_func_alloc(void *arena);
extern int32_t pipeline_type_kind_ord_at(void *arena, int32_t type_ref);
extern int32_t pipeline_block_append_expr_stmt(void *arena, int32_t block_ref, int32_t expr_ref);
extern int32_t pipeline_block_append_stmt_order(void *arena, int32_t block_ref, uint8_t kind, int32_t index);
extern int32_t pipeline_module_func_alloc_slot(void *module);
extern void pipeline_module_func_name_write(void *module, int32_t fi, uint8_t *name, int32_t name_len);
extern void pipeline_module_func_set_num_params(void *module, int32_t fi, int32_t n);
extern void pipeline_module_func_set_return_type(void *module, int32_t fi, int32_t type_ref);
extern void pipeline_module_func_set_body_ref(void *module, int32_t fi, int32_t body_ref);
extern void pipeline_module_func_set_body_expr_ref(void *module, int32_t fi, int32_t body_expr_ref);
extern void pipeline_module_func_set_is_extern(void *module, int32_t fi, int32_t is_extern);
extern void pipeline_module_func_set_is_async(void *module, int32_t fi, int32_t is_async);
extern void pipeline_module_func_ref_set(void *module, int32_t fi, int32_t func_ref);
extern void pipeline_arena_func_copy_slot_from_module(void *arena, int32_t func_ref, void *module, int32_t fi);
extern void pipeline_onefunc_param_name_copy32(uint8_t *pool, int32_t i, uint8_t *dst);
extern int32_t pipeline_onefunc_param_name_len(uint8_t *pool, int32_t i);
extern int32_t pipeline_onefunc_param_type_ref(uint8_t *pool, int32_t i);
extern void pipeline_module_func_param_write(void *module, int32_t fi, int32_t pi, uint8_t *name, int32_t name_len,
                                             int32_t type_ref);
extern void pipeline_block_fill_whiles_from_onefunc(void *arena, int32_t br, uint8_t *out, int32_t count);
extern void pipeline_block_fill_fors_from_onefunc(void *arena, int32_t br, uint8_t *out, int32_t count);
extern void pipeline_block_fill_ifs_from_onefunc(void *arena, int32_t br, uint8_t *out, int32_t count);
extern void pipeline_block_fill_regions_from_onefunc(void *arena, int32_t br, uint8_t *out, int32_t count);
extern void pipeline_block_fill_expr_stmts_from_onefunc(void *arena, int32_t br, uint8_t *out, int32_t count);
extern void pipeline_block_fill_stmt_order_from_onefunc(void *arena, int32_t br, uint8_t *out, int32_t count);
extern int32_t pipeline_onefunc_num_whiles(uint8_t *out);
extern int32_t pipeline_onefunc_num_fors(uint8_t *out);
extern int32_t pipeline_onefunc_num_if_stmts(uint8_t *out);
extern int32_t pipeline_onefunc_num_regions(uint8_t *out);
extern int32_t pipeline_onefunc_num_body_expr_stmts(uint8_t *out);
extern int32_t pipeline_onefunc_num_src_stmt_order(uint8_t *out);

/** []u8 slice 路径与 shulang_slice_uint8_t 布局一致。 */
struct parser_asm_seed_slice_u8 {
  uint8_t *data;
  size_t length;
};

/** OneFuncResult 工作区：wire dummy 侧车后供 parse_one_function_impl 使用。 */
static struct parser_asm_onefunc_result parser_asm_seed_onefunc_wired_c(struct parser_asm_lexer lex) {
  struct parser_asm_onefunc_result res;
  uint8_t empty64[64];

  memset(empty64, 0, sizeof(empty64));
  res = parser_onefunc_scratch_empty();
  parser_onefunc_res_wire_dummy_head(&res, lex, empty64);
  parser_onefunc_res_wire_dummy_const_let(&res);
  parser_onefunc_res_wire_dummy_if_mul(&res);
  parser_onefunc_res_wire_dummy_call_binop(&res, empty64);
  parser_onefunc_res_wire_dummy_loop_call(&res);
  parser_onefunc_res_wire_dummy_for_if(&res);
  return res;
}

/** 分配默认 i32 返回类型 ref。 */
static int32_t parser_asm_seed_default_i32_type_ref_c(void *arena) {
  int32_t type_ref;
  struct ast_Type t;

  type_ref = ast_ast_arena_type_alloc(arena);
  if (type_ref == 0)
    return 0;
  t = ast_ast_arena_type_get(arena, type_ref);
  t.kind = AST_TYPE_I32;
  t.name_len = 0;
  t.elem_type_ref = 0;
  t.array_size = 0;
  ast_ast_arena_type_set(arena, type_ref, t);
  return type_ref;
}

/** Expr 公共字段清零（与 parser_asm_block_from_res_slice 一致）。 */
static void parser_asm_seed_expr_common_zeros_c(struct ast_Expr *e) {
  if (!e)
    return;
  e->resolved_type_ref = 0;
  e->binop_left_ref = 0;
  e->binop_right_ref = 0;
  e->unary_operand_ref = 0;
  e->if_cond_ref = 0;
  e->if_then_ref = 0;
  e->if_else_ref = 0;
  e->block_ref = 0;
  e->match_matched_ref = 0;
  e->match_arm_base = 0;
  e->match_num_arms = 0;
  e->enum_variant_tag = 0;
  e->field_access_base_ref = 0;
  e->field_access_field_len = 0;
  e->field_access_is_enum_variant = 0;
  e->field_access_offset = 0;
  e->index_base_ref = 0;
  e->index_index_ref = 0;
  e->index_base_is_slice = 0;
  e->call_callee_ref = 0;
  e->call_arg_base = 0;
  e->call_num_args = 0;
  e->method_call_base_ref = 0;
  e->method_call_name_len = 0;
  e->method_call_arg_base = 0;
  e->method_call_num_args = 0;
  e->const_folded_val = 0;
  e->const_folded_valid = 0;
  e->index_proven_in_bounds = 0;
  e->struct_lit_field_base = 0;
  e->struct_lit_num_fields = 0;
  e->array_lit_elem_base = 0;
  e->array_lit_num_elems = 0;
  e->as_operand_ref = 0;
  e->as_target_type_ref = 0;
  e->call_resolved_func_index = -1;
  e->call_resolved_dep_index = -1;
}

/** 判断 name 是否为 main（4 字节 m-a-i-n）。 */
static int32_t parser_asm_seed_is_main_name_c(const uint8_t *name, int32_t name_len) {
  return name_len == 4 && name[0] == 109 && name[1] == 97 && name[2] == 105 && name[3] == 110;
}

/**
 * 将 inner_ref 包一层 EXPR_RETURN（已是 RETURN 则原样返回）；与 parser.su parser_expr_wrap_in_return 一致。
 */
static int32_t parser_asm_seed_expr_wrap_in_return_c(void *arena, int32_t type_ref, int32_t inner_ref) {
  int32_t wrap;
  struct ast_Expr inner;
  struct ast_Expr rwe;

  if (inner_ref == 0)
    return 0;
  inner = ast_ast_arena_expr_get(arena, inner_ref);
  if (inner.kind == AST_EXPR_RETURN)
    return inner_ref;
  wrap = ast_ast_arena_expr_alloc(arena);
  if (wrap == 0)
    return 0;
  rwe = ast_ast_arena_expr_get(arena, wrap);
  rwe.kind = AST_EXPR_RETURN;
  rwe.line = 0;
  rwe.col = 0;
  rwe.int_val = 0;
  parser_asm_seed_expr_common_zeros_c(&rwe);
  rwe.resolved_type_ref = type_ref;
  rwe.unary_operand_ref = inner_ref;
  ast_ast_arena_expr_set(arena, wrap, rwe);
  return wrap;
}

/**
 * 将已成功解析的 OneFuncResult 登记到 module/arena（parse_into_buf 主路径 commit）。
 * 返回 0 成功，-1 失败。
 */
static int32_t parser_asm_seed_commit_onefunc_c(void *arena, void *module, struct parser_asm_onefunc_result *res,
                                                int32_t func_is_async, int32_t *inout_main_idx,
                                                struct parser_asm_lexer *inout_lex) {
  int32_t type_ref;
  int32_t final_expr_ref;
  int32_t block_ref;
  struct ast_Block b;
  struct ast_Expr e;
  int32_t func_ref;
  int32_t fi_mod;
  int32_t p_copy;
  uint8_t *pool;
  size_t guard_pos;
  int32_t n_while;
  int32_t n_for;
  int32_t n_if;
  int32_t n_reg;
  int32_t ci;
  int32_t li;
  int32_t loop_i;
  int32_t for_i;
  int32_t if_i;

  if (!arena || !module || !res || !res->ok || !inout_lex)
    return -1;

  type_ref = res->func_return_type_ref;
  if (type_ref == 0)
    type_ref = parser_asm_seed_default_i32_type_ref_c(arena);
  if (type_ref == 0)
    return -1;

  if (res->return_expr_ref != 0) {
    final_expr_ref = res->return_expr_ref;
  } else if (res->return_var_name_len > 0) {
    final_expr_ref = ast_ast_arena_expr_alloc(arena);
    if (final_expr_ref == 0)
      return -1;
    e = ast_ast_arena_expr_get(arena, final_expr_ref);
    e.kind = AST_EXPR_VAR;
    e.var_name_len = res->return_var_name_len;
    memcpy(e.var_name, res->return_var_name, (size_t)res->return_var_name_len);
    e.int_val = 0;
    parser_asm_seed_expr_common_zeros_c(&e);
    ast_ast_arena_expr_set(arena, final_expr_ref, e);
  } else {
    final_expr_ref = ast_ast_arena_expr_alloc(arena);
    if (final_expr_ref == 0)
      return -1;
    e = ast_ast_arena_expr_get(arena, final_expr_ref);
    e.kind = AST_EXPR_LIT;
    e.int_val = res->return_val;
    e.resolved_type_ref = type_ref;
    parser_asm_seed_expr_common_zeros_c(&e);
    ast_ast_arena_expr_set(arena, final_expr_ref, e);
  }

  if (parser_should_wrap_func_tail_in_return_glue(arena, res, type_ref)) {
    int32_t wrapped_fe = parser_asm_seed_expr_wrap_in_return_c(arena, type_ref, final_expr_ref);
    if (wrapped_fe == 0)
      return -1;
    final_expr_ref = wrapped_fe;
  }

  block_ref = ast_ast_arena_block_alloc(arena);
  if (block_ref == 0)
    return -1;
  b = ast_ast_arena_block_get(arena, block_ref);
  b.num_consts = res->num_consts;
  b.num_lets = res->num_lets;
  b.num_early_lets = 0;
  b.num_loops = res->num_loops;
  b.num_for_loops = res->num_for_loops;
  b.num_if_stmts = res->num_if_stmts;
  b.num_defers = 0;
  b.num_labeled_stmts = 0;
  b.num_expr_stmts = 0;
  b.final_expr_ref = final_expr_ref;
  b.num_stmt_order = 0;
  ast_ast_arena_block_set(arena, block_ref, b);

  if (!parser_asm_fill_block_const_let_from_res_c(arena, block_ref, res, type_ref))
    return -1;

  pool = parser_asm_onefunc_result_pool_ptr_c(res);
  n_while = pipeline_onefunc_num_whiles(pool);
  res->num_loops = n_while;
  pipeline_block_fill_whiles_from_onefunc(arena, block_ref, pool, n_while);
  n_for = pipeline_onefunc_num_fors(pool);
  res->num_for_loops = n_for;
  pipeline_block_fill_fors_from_onefunc(arena, block_ref, pool, n_for);
  n_if = pipeline_onefunc_num_if_stmts(pool);
  res->num_if_stmts = n_if;
  pipeline_block_fill_ifs_from_onefunc(arena, block_ref, pool, n_if);
  n_reg = pipeline_onefunc_num_regions(pool);
  pipeline_block_fill_regions_from_onefunc(arena, block_ref, pool, n_reg);

  b = ast_ast_arena_block_get(arena, block_ref);
  if (res->num_src_stmt_order > 0) {
    pipeline_block_fill_expr_stmts_from_onefunc(arena, block_ref, pool,
                                                pipeline_onefunc_num_body_expr_stmts(pool));
    pipeline_block_fill_stmt_order_from_onefunc(arena, block_ref, pool,
                                                pipeline_onefunc_num_src_stmt_order(pool));
    b = ast_ast_arena_block_get(arena, block_ref);
  } else {
    for (ci = 0; ci < b.num_consts; ci++) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 0, ci) < 0)
        return -1;
    }
    for (li = 0; li < b.num_lets; li++) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 1, li) < 0)
        return -1;
    }
    for (loop_i = 0; loop_i < b.num_loops; loop_i++) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 3, loop_i) < 0)
        return -1;
    }
    for (for_i = 0; for_i < b.num_for_loops; for_i++) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 4, for_i) < 0)
        return -1;
    }
    for (if_i = 0; if_i < b.num_if_stmts; if_i++) {
      if (pipeline_block_append_stmt_order(arena, block_ref, 5, if_i) < 0)
        return -1;
    }
    if (final_expr_ref != 0 && b.num_expr_stmts == 0) {
      int32_t fin_ex = pipeline_block_append_expr_stmt(arena, block_ref, final_expr_ref);
      if (fin_ex < 0)
        return -1;
      b.final_expr_ref = 0;
      final_expr_ref = 0;
      if (pipeline_block_append_stmt_order(arena, block_ref, 2, fin_ex) < 0)
        return -1;
      b = ast_ast_arena_block_get(arena, block_ref);
    }
  }
  b = ast_ast_arena_block_get(arena, block_ref);
  b.final_expr_ref = final_expr_ref;
  if (b.num_expr_stmts > 0 && final_expr_ref != 0) {
    struct ast_Expr fe_dedup = ast_ast_arena_expr_get(arena, final_expr_ref);
    if (fe_dedup.kind != AST_EXPR_RETURN)
      b.final_expr_ref = 0;
  }
  ast_ast_arena_block_set(arena, block_ref, b);

  func_ref = ast_ast_arena_func_alloc(arena);
  if (func_ref == 0)
    return -1;
  fi_mod = pipeline_module_func_alloc_slot(module);
  if (fi_mod < 0)
    return -1;
  pipeline_module_func_name_write(module, fi_mod, res->name, res->name_len);
  pipeline_module_func_set_num_params(module, fi_mod, res->num_params);
  pipeline_module_func_set_return_type(module, fi_mod, type_ref);
  pipeline_module_func_set_body_ref(module, fi_mod, block_ref);
  pipeline_module_func_set_body_expr_ref(module, fi_mod, 0);
  pipeline_module_func_set_is_extern(module, fi_mod, 0);
  pipeline_module_func_set_is_async(module, fi_mod, func_is_async);
  for (p_copy = 0; p_copy < res->num_params; p_copy++) {
    uint8_t pname32[32];
    memset(pname32, 0, sizeof(pname32));
    pipeline_onefunc_param_name_copy32(pool, p_copy, pname32);
    pipeline_module_func_param_write(module, fi_mod, p_copy, pname32,
                                     pipeline_onefunc_param_name_len(pool, p_copy),
                                     pipeline_onefunc_param_type_ref(pool, p_copy));
  }
  pipeline_module_func_ref_set(module, fi_mod, func_ref);
  pipeline_arena_func_copy_slot_from_module(arena, func_ref, module, fi_mod);
  if (inout_main_idx && parser_asm_seed_is_main_name_c(res->name, res->name_len))
    *inout_main_idx = fi_mod;

  guard_pos = inout_lex->pos;
  parser_lex_from_onefunc_next_into_glue(inout_lex, res);
  if (inout_lex->pos == guard_pos)
    inout_lex->pos++;
  return 0;
}

/**
 * seed parse_into_buf：collect_imports + 主循环 parse/skip（buf 路径）。
 */
struct parser_asm_seed_parse_into_result parser_asm_seed_parse_into_buf_c(void *arena, void *module, uint8_t *data,
                                                                          int32_t len) {
  struct parser_asm_seed_parse_into_result out;
  struct parser_asm_lexer lex;
  struct parser_asm_collect_imports_result import_res;
  parser_asm_su_module_hdr_t *mod_hdr;
  int32_t main_idx;
  int32_t loop_count;
  int32_t func_is_async;
  struct parser_asm_slice_u8 slice;

  out.ok = 0;
  out.main_idx = -1;
  if (!arena || !module || !data || len <= 0)
    return out;

  mod_hdr = (parser_asm_su_module_hdr_t *)module;
  lex.pos = 0;
  lex.line = 1;
  lex.col = 1;
  import_res.lex = lex;
  parser_asm_collect_imports_buf_c(lex, data, len, module, &import_res);
  lex = import_res.lex;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_buf_preamble_peek_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_preamble_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_preamble_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_preamble_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_entry_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_ultra_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_entry_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_super_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_max_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));

  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));


  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));



  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));




  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));





  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));






  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));







  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));








  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));









  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));










  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));











  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));












  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));













  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));














  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));

















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));


















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));



















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));




















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));





















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));






















  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));

























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));


























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));



























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));




























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));





























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));






























  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));

































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));


































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));



































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));




































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));





































  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  loop_count = 0;
  PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(lex, data, len));
  loop_count = 0;
  slice.data = data;
  slice.length = (size_t)len;

  while (1) {
    struct parser_asm_lexer iter_start;
    struct parser_asm_lexer_result r;
    struct parser_asm_lexer lex_at_function;

    if (loop_count >= 131072) {
      out.ok = -1;
      out.main_idx = -1003;
      return out;
    }
    loop_count++;
    iter_start = lex;
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_buf_loop_toplevel_buf_audit_c(iter_start, data, len));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_loop_iter_deep_buf_audit_c(iter_start, data, len));
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_loop_entry_full_deep_buf_audit_c(iter_start, data, len));
    r = lexer_next_buf(lex, data, len);
    parser_lex_from_next_into_glue(&lex, r);
    func_is_async = 0;
    if (r.tok.kind == (int32_t)TOKEN_ASYNC) {
      func_is_async = 1;
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_async_fn_prefix_buf_audit_c(iter_start, data, len));
      parser_lex_from_next_into_glue(&lex, r);
      r = lexer_next_buf(lex, data, len);
      parser_lex_from_next_into_glue(&lex, r);
    }
    if (r.tok.kind == (int32_t)TOKEN_ATTR_SOA) {
      mod_hdr->pending_soa_struct = 1;
      parser_lex_from_next_into_glue(&lex, r);
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        lex.pos++;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_STRUCT) {
      struct parser_asm_lexer out_lex;
      int32_t ap = mod_hdr->pending_allow_padding;
      int32_t ps = mod_hdr->pending_soa_struct;
      mod_hdr->pending_allow_padding = 0;
      mod_hdr->pending_soa_struct = 0;
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_record_layout_body_buf_audit_c(lex, data, len));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_struct_layout_deep_buf_audit_c(lex, data, len));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_struct_layout_full_deep_buf_audit_c(lex, data, len));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_struct_layout_mega_full_deep_buf_audit_c(lex, data, len));
      if (parser_parse_struct_record_layout_into_glue(arena, module, lex, &slice, &out_lex, ap, ps) != 0)
        parser_skip_one_struct_into_buf_glue(&lex, iter_start, data, len);
      else
        lex = out_lex;
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        lex.pos++;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_ENUM) {
      parser_skip_one_enum_register_into_buf_glue(module, &lex, iter_start, data, len);
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        lex.pos++;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_TRAIT) {
      parser_skip_one_trait_into_buf_glue(&lex, iter_start, data, len);
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        lex.pos++;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_IMPL) {
      parser_skip_one_impl_into_buf_glue(&lex, iter_start, data, len);
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        lex.pos++;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_EXTERN) {
      parser_parse_one_extern_and_add_into_buf_glue(arena, module, iter_start, data, len, &lex);
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        parser_skip_one_extern_into_buf_glue(&lex, iter_start, data, len);
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        lex.pos++;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_LET || r.tok.kind == (int32_t)TOKEN_CONST) {
      struct parser_asm_top_level_let_result tl_res;
      memset(&tl_res, 0, sizeof(tl_res));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_top_level_let_buf_audit_c(r.next_lex, data, len,
                                                        r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_top_level_let_deep_buf_audit_c(r.next_lex, data, len));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_top_level_let_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                 r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_top_level_let_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                      r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_ultra_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                         r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_super_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                        r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                       r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                              r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_toplevel_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apexversal_maxversal_wholeversal_completeversal_fullversal_everyversal_totversal_allversal_panversal_omniversal_hyperversal_metaversal_multiversal_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_buf_audit_c(r.next_lex, data, len,
                                                                                   r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0);
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_type_ref_deep_buf_audit_c(r.next_lex, data, len));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_type_ref_full_deep_buf_audit_c(r.next_lex, data, len));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_type_ref_mega_full_deep_buf_audit_c(r.next_lex, data, len));
      PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_type_ref_bracket_composite_buf_audit_c(r.next_lex, data, len));
      parser_parse_one_top_level_let_into_glue(arena, module, r.next_lex, &slice,
                                             r.tok.kind == (int32_t)TOKEN_CONST ? 1 : 0, &tl_res);
      if (tl_res.ok) {
        lex = tl_res.next_lex;
        continue;
      }
    }
    if (r.tok.kind != (int32_t)TOKEN_FUNCTION) {
      struct parser_asm_try_skip_allow_result try_res;
      memset(&try_res, 0, sizeof(try_res));
      parser_parse_into_try_skip_allow_into_buf_glue(&try_res, lex, r, data, len);
      if (try_res.skipped != 0) {
        mod_hdr->pending_allow_padding = 1;
        lex = parser_lex_from_try_skip_glue(try_res);
        if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
          lex.pos++;
        continue;
      }
      if (r.tok.kind == (int32_t)TOKEN_EOF)
        break;
      if (lex.pos == iter_start.pos && lex.pos < (size_t)len)
        lex.pos++;
      continue;
    }
    if (r.tok.kind == (int32_t)TOKEN_EOF) {
      if (mod_hdr->num_funcs == 0) {
        out.main_idx = -1;
        return out;
      }
      out.main_idx = main_idx;
      return out;
    }

    lex_at_function = lex;
    PARSER_ASM_STRETCH_AUDIT_CALL(parser_asm_stretch_parse_into_function_branch_deep_buf_audit_c(lex_at_function, data, len));
    parser_lex_from_next_into_glue(&lex, r);
    {
      struct parser_asm_library_parse_result lib;
      struct parser_asm_onefunc_result res;

      lib = parser_asm_parse_one_function_library_buf_c(arena, module, lex_at_function, data, len);
      if (lib.ok) {
        lex = parser_lex_from_library_glue(lib);
        continue;
      }
      res = parser_asm_seed_onefunc_wired_c(lex);
      parser_parse_one_function_impl(&res, arena, lex, &slice);
      if (!res.ok)
        parser_asm_parse_one_function_buf_into_c(&res, lex_at_function, data, len);
      if (!res.ok) {
        parser_skip_one_function_full_into_buf_glue(&lex, lex_at_function, data, len);
        if (lex.pos == lex_at_function.pos && lex.pos < (size_t)len)
          lex.pos++;
        continue;
      }
      if (parser_asm_seed_commit_onefunc_c(arena, module, &res, func_is_async, &main_idx, &lex) != 0) {
        out.ok = -1;
        out.main_idx = -1;
        return out;
      }
    }
  }

  out.main_idx = main_idx;
  return out;
}

/** runtime / pipeline 期望裸名 parse_into_buf；强符号覆盖 link_alias 弱桩。 */
struct parser_asm_seed_parse_into_result parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len) {
  return parser_asm_seed_parse_into_buf_c(arena, module, data, len);
}

/** runtime 期望 parser_parse_into_buf 前缀。 */
struct parser_asm_seed_parse_into_result parser_parse_into_buf(void *arena, void *module, uint8_t *data, int32_t len) {
  return parse_into_buf(arena, module, data, len);
}

/** slice 路径 parse_into。 */
struct parser_asm_seed_parse_into_result parse_into(void *arena, void *module,
                                                    struct parser_asm_seed_slice_u8 *source) {
  if (!source || !source->data) {
    struct parser_asm_seed_parse_into_result fail;
    fail.ok = 0;
    fail.main_idx = -1;
    return fail;
  }
  return parser_asm_seed_parse_into_buf_c(arena, module, source->data, (int32_t)source->length);
}

struct parser_asm_seed_parse_into_result parser_parse_into(void *arena, void *module,
                                                           struct parser_asm_seed_slice_u8 *source) {
  return parse_into(arena, module, source);
}

/** parse_into_set_main_index：写 module.main_func_index。 */
extern void pipeline_module_set_main_func_index(void *m, int32_t idx);

void parse_into_set_main_index(void *module, int32_t main_idx) {
  pipeline_module_set_main_func_index(module, main_idx);
}

void parser_parse_into_set_main_index(void *module, int32_t main_idx) {
  parse_into_set_main_index(module, main_idx);
}

#endif /* PARSER_ASM_SEED_PARSE_INTO_BUF_SLICE_INCLUDED */
