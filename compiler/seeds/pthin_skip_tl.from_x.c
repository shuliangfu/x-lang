/* seeds/pthin_skip_tl.from_x.c — G-02f-321 P2 parser thin skip top-level
 * Logic source: src/asm/pthin_skip_tl.x
 * Hybrid: XLANG_PTHIN_SKIP_TL_FROM_X + ld -r into parser_asm_thin_glue.o
 *
 * Body: seeds/parser_asm/parser_asm_skip_tl_slice.inc (~8.2k)
 * skip_one_struct/enum/trait/impl/extern + parse_one_extern + enum_register
 *
 * Hybrid P12b (XLANG_PTHIN_SKIP_TL_BODIES_FROM_X): portable skip walks
 * (struct / enum / extern) come from pthin_skip_tl.x; this TU keeps
 * by-value trampolines plus stash_source / trait-reg / enum_register C.
 * Cold: no BODIES define, full .inc.
 * Do not reuse XLANG_PTHIN_SKIP_TL_FROM_X for P12b bodies.
 * PLATFORM: SHARED — do not assemble parser.x.
 */
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
/* Cap residual 9.5.3: skip_tl_slice.inc stderr debug via xlang_io_write. */
#include <xlang_io_cap.h>

#include "parser_asm_stretch_audit_gate.h"
#include "token.h"
#include "ast.h"

/* PLATFORM: SHARED — 7.2.1 P12b B-minus (2026-09-13).
 * pthin_skip_tl.x TOKEN_* are pin copies of this enum.
 * token.h remains the authority; fire if the pin drifts. */
_Static_assert((int)TOKEN_EOF == 0, "skip_tl.x TOKEN_EOF pin");
_Static_assert((int)TOKEN_FUNCTION == 1, "skip_tl.x TOKEN_FUNCTION pin");
_Static_assert((int)TOKEN_STRUCT == 19, "skip_tl.x TOKEN_STRUCT pin");
_Static_assert((int)TOKEN_ENUM == 47, "skip_tl.x TOKEN_ENUM pin");
_Static_assert((int)TOKEN_EXTERN == 54, "skip_tl.x TOKEN_EXTERN pin");
_Static_assert((int)TOKEN_IDENT == 59, "skip_tl.x TOKEN_IDENT pin");
_Static_assert((int)TOKEN_LPAREN == 82, "skip_tl.x TOKEN_LPAREN pin");
_Static_assert((int)TOKEN_LBRACE == 84, "skip_tl.x TOKEN_LBRACE pin");
_Static_assert((int)TOKEN_COLON == 91, "skip_tl.x TOKEN_COLON pin");
_Static_assert((int)TOKEN_SEMICOLON == 95, "skip_tl.x TOKEN_SEMICOLON pin");
_Static_assert((int)TOKEN_LT == 120, "skip_tl.x TOKEN_LT pin");
_Static_assert((int)TOKEN_STRING == 130, "skip_tl.x TOKEN_STRING pin");

struct parser_asm_token {
  int32_t kind;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
};

struct parser_asm_lexer {
  size_t pos;
  int32_t line;
  int32_t col;
};

struct parser_asm_lexer_result {
  struct parser_asm_lexer next_lex;
  struct parser_asm_token tok;
  size_t token_start;
};

struct parser_asm_slice_u8 {
  uint8_t *data;
  size_t length;
};

struct parser_asm_extern_parse_result {
  struct parser_asm_lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  int32_t return_ty_ref;
  int32_t num_params;
  int32_t abi_kind; /**< ABI 标记：0=X ABI（默认），1=C ABI（extern "C"） */
  int32_t is_variadic; /**< 变参：1=extern "C" function f(fmt: *u8, ...); 0=定参 */
  int32_t has_body; /**< 1=extern "C" function ... { body }; 0=pure declaration */
};

struct ast_Func {
  uint8_t name[256];
  int32_t name_len;
  int32_t param_base;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t return_type_ref;
  int32_t body_ref;
  int32_t body_expr_ref;
  int32_t is_extern;
  int32_t is_async;
  int32_t is_used;
  int32_t is_naked;
  int32_t is_entry;
  int32_t is_no_mangle;
  int32_t is_interrupt;
  int32_t abi_kind; /**< ABI 标记：0=X ABI（默认），1=C ABI（extern "C"） */
  int32_t is_variadic; /**< 变参：1=extern "C" function f(fmt: *u8, ...); 0=定参 */
  /** 与 ast.x Func / pipeline_arena_func_get_copy 一致：缺此字段则 sizeof=0x80，get_copy 写 0x84 冲栈。 */
  int32_t is_export;
};


int32_t parser_asm_module_register_arena_func_c(void *module, int32_t func_ref, struct ast_Func f);
void parser_asm_write_extern_params_to_pools_c(void *arena, void *module, int32_t func_ref, int32_t fi, struct parser_asm_extern_parse_result *res);

extern struct ast_Func ast_arena_func_get(void *arena, int32_t ref);
extern void ast_arena_func_set(void *arena, int32_t ref, struct ast_Func f);
extern int32_t ast_ast_arena_func_alloc(void *arena);
extern void ast_pool_onefunc_reset(uint8_t *out);
extern void lexer_next_into(struct parser_asm_lexer_result *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *data);
extern void parser_asm_copy_slice_to_name64_at_end_slice_c(struct parser_asm_slice_u8 *source, size_t end_pos, int32_t nlen, uint8_t *out);
extern void parser_asm_copy_slice_to_name64_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen, uint8_t *out);
extern void parser_asm_copy_slice_to_param32_slice_c(struct parser_asm_slice_u8 *source, size_t start, int32_t nlen, uint8_t *out);
extern void parser_asm_lex_from_result_val_into(struct parser_asm_lexer *out, struct parser_asm_lexer_result r);
extern size_t parser_asm_lexer_pos_before_run_c(size_t end_pos, int32_t run_len);
extern int32_t parser_asm_module_try_register_enum_name_c(void *module, uint8_t *name, int32_t name_len);
extern int32_t parser_asm_parse_type_ref_for_arena_into_slice_c(void *arena, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source, struct parser_asm_lexer *out_lex);
extern void parser_asm_skip_balanced_braces_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern void parser_asm_skip_balanced_parens_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern void parser_asm_skip_trait_impl_block_raw_c(struct parser_asm_lexer *out, struct parser_asm_lexer start, struct parser_asm_slice_u8 *source);
extern int32_t parser_asm_stretch_collect_imports_bind_audit_c(const uint8_t *bind, int32_t bind_len);
extern int32_t parser_asm_stretch_enum_body_deep_slice_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_enum_header_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_enum_variant_bind_audit_c(struct parser_asm_slice_u8 *source, size_t token_start, int32_t name_len);
extern int32_t parser_asm_stretch_enum_variants_body_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_enum_variants_probe_c(void *lex_inout, void *source, int32_t *out_variant_count);
extern int32_t parser_asm_stretch_extern_fn_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_extern_param_bind_audit_c(const uint8_t *name, int32_t name_len);
extern int32_t parser_asm_stretch_extern_param_count_audit_c(void *lex_inout, void *source, int32_t *out_param_count);
extern int32_t parser_asm_stretch_extern_return_type_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_impl_header_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_impl_items_body_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_impl_items_probe_c(void *lex_inout, void *source, int32_t *out_item_count);
extern int32_t parser_asm_stretch_impl_type_for_trait_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_skip_allow_modifiers_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_skip_one_extern_body_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_skip_return_type_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_fields_probe_c(void *lex_inout, void *source, int32_t *out_field_count);
extern int32_t parser_asm_stretch_vx_struct_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_header_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_layout_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_modifiers_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_pi_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_skip_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_super_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_ultra_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_struct_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_struct_ze_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_trait_header_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_trait_impl_type_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_trait_methods_body_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_trait_methods_probe_c(void *lex_inout, void *source, int32_t *out_method_count);
extern void parser_skip_one_extern_into_glue(struct parser_asm_lexer *out, struct parser_asm_lexer lex, struct parser_asm_slice_u8 *source);
extern void pipeline_arena_func_param_write(void *arena, int32_t func_ref, int32_t param_index, uint8_t *name_bytes, int32_t name_len, int32_t type_ref);
extern int32_t pipeline_module_enum_append_variant(void *module, int32_t idx, uint8_t *bytes, int32_t len);
extern int32_t pipeline_module_func_alloc_slot(void *module);
extern void pipeline_module_func_name_write(void *module, int32_t fi, uint8_t *name_bytes, int32_t name_len);
extern void pipeline_module_func_param_write(void *module, int32_t func_index, int32_t param_index, uint8_t *name_bytes, int32_t name_len, int32_t type_ref);
extern void pipeline_module_func_ref_set(void *module, int32_t fi, int32_t func_ref);
extern void pipeline_module_func_set_body_expr_ref(void *module, int32_t fi, int32_t body_expr_ref);
extern void pipeline_module_func_set_body_ref(void *module, int32_t fi, int32_t body_ref);
extern void pipeline_module_func_set_is_async(void *module, int32_t fi, int32_t is_async);
extern void pipeline_module_func_set_is_variadic(void *module, int32_t fi, int32_t is_variadic);
extern int32_t pipeline_module_func_is_variadic_at(void *module, int32_t fi);
extern void pipeline_module_func_set_is_extern(void *module, int32_t fi, int32_t is_extern);
extern void pipeline_module_func_set_num_params(void *module, int32_t fi, int32_t n);
extern void pipeline_module_func_set_return_type(void *module, int32_t fi, int32_t type_ref);
extern int32_t pipeline_module_num_funcs(void *module);
extern int32_t pipeline_onefunc_append_param(uint8_t *out, uint8_t *name, int32_t name_len, int32_t type_ref);
extern void pipeline_onefunc_param_name_copy32(uint8_t *pool, int32_t i, uint8_t *dst);
extern int32_t pipeline_onefunc_param_name_len(uint8_t *pool, int32_t i);
extern int32_t pipeline_onefunc_param_type_ref(uint8_t *pool, int32_t i);
extern void pipeline_onefunc_set_param_type_ref(uint8_t *out, int32_t pidx, int32_t ty);

/* wave473 onefunc arena path prerequisites: skip_tl_slice.inc's tail (the
 * parse-one-function + fill-block-from-res subsystem) grew these struct /
 * enum / extern dependencies while the main TU picked them up from earlier
 * slices (library/type_ref/block_from_res + TU body). This hybrid TU starved
 * silently and the g05 P12 lane fell back to the full seed. Mirrors must stay
 * field-for-field identical to their authorities (same commit on any layout
 * change): ast_Block ≡ library_slice.inc:14, ast_Expr ≡ thin_c.from_x.c:4049,
 * onefunc_result ≡ thin_c.from_x.c:147, TypeKind enum ≡ type_ref_slice.inc:64,
 * arena/fill externs ≡ block_from_res_slice.inc:10 / library_slice.inc:55. */
struct ast_Block {
  int32_t const_base;
  int32_t num_consts;
  int32_t let_base;
  int32_t num_lets;
  int32_t num_early_lets;
  int32_t loop_base;
  int32_t num_loops;
  int32_t for_loop_base;
  int32_t num_for_loops;
  int32_t if_base;
  int32_t num_if_stmts;
  int32_t region_base;
  int32_t num_regions;
  int32_t defer_base;
  int32_t num_defers;
  int32_t labeled_base;
  int32_t num_labeled_stmts;
  int32_t expr_stmt_base;
  int32_t num_expr_stmts;
  int32_t final_expr_ref;
  int32_t stmt_order_base;
  int32_t num_stmt_order;
  int32_t parent_block_ref;
};
struct ast_Expr {
  int32_t kind;
  int32_t resolved_type_ref;
  int32_t line;
  int32_t col;
  int64_t int_val;
  double float_val;
  uint8_t var_name[256];
  int32_t var_name_len;
  int32_t binop_left_ref;
  int32_t binop_right_ref;
  int32_t unary_operand_ref;
  int32_t if_cond_ref;
  int32_t if_then_ref;
  int32_t if_else_ref;
  int32_t block_ref;
  int32_t match_matched_ref;
  int32_t match_arm_base;
  int32_t match_num_arms;
  int32_t field_access_base_ref;
  uint8_t field_access_field_name[256];
  int32_t field_access_field_len;
  int32_t field_access_is_enum_variant;
  int32_t field_access_offset;
  int32_t field_access_soa_stride;
  int32_t index_base_ref;
  int32_t index_index_ref;
  int32_t index_base_is_slice;
  int32_t call_callee_ref;
  int32_t call_arg_base;
  int32_t call_num_args;
  int32_t call_num_type_args;
  int32_t method_call_base_ref;
  uint8_t method_call_name[256];
  int32_t method_call_name_len;
  int32_t method_call_arg_base;
  int32_t method_call_num_args;
  int32_t const_folded_val;
  int32_t const_folded_valid;
  int32_t index_proven_in_bounds;
  uint8_t struct_lit_struct_name[256];
  int32_t struct_lit_struct_name_len;
  int32_t struct_lit_field_base;
  int32_t struct_lit_num_fields;
  int32_t array_lit_elem_base;
  int32_t array_lit_num_elems;
  int32_t float_bits_lo;
  int32_t float_bits_hi;
  int32_t enum_variant_tag;
  int32_t as_operand_ref;
  int32_t as_target_type_ref;
  int32_t call_resolved_func_index;
  int32_t call_resolved_dep_index;
};
struct parser_asm_onefunc_result {
  int32_t ok;
  struct parser_asm_lexer next_lex;
  uint8_t name[256];
  int32_t name_len;
  int32_t num_params;
  int32_t num_generic_params;
  int32_t num_consts;
  int32_t num_lets;
  int32_t has_if_expr;
  int32_t if_cond_true;
  int32_t if_then_val;
  int32_t if_else_val;
  int32_t if_cond_expr_ref;
  int32_t has_mul;
  int32_t mul_right_val;
  int32_t has_binop;
  int32_t binop_right_val;
  int32_t binop_left_param_idx;
  int32_t binop_right_param_idx;
  int32_t has_unary_neg;
  int32_t return_val;
  int32_t has_call_expr;
  uint8_t call_callee_name[256];
  int32_t call_callee_len;
  uint8_t return_var_name[256];
  int32_t return_var_name_len;
  int32_t return_expr_ref;
  int32_t has_final_expr;
  int32_t has_explicit_return_kw;
  int32_t call_num_args;
  int32_t num_loops;
  int32_t num_for_loops;
  int32_t num_if_stmts;
  int32_t num_src_stmt_order;
  int32_t num_src_body_expr_stmts;
  int32_t func_return_type_ref;
};
enum {
  PARSER_ASM_TYPE_I32 = 0,
  PARSER_ASM_TYPE_BOOL = 1,
  PARSER_ASM_TYPE_U8 = 2,
  PARSER_ASM_TYPE_U32 = 3,
  PARSER_ASM_TYPE_U64 = 4,
  PARSER_ASM_TYPE_I64 = 5,
  PARSER_ASM_TYPE_USIZE = 6,
  PARSER_ASM_TYPE_ISIZE = 7,
  PARSER_ASM_TYPE_NAMED = 8,
  PARSER_ASM_TYPE_PTR = 9,
  PARSER_ASM_TYPE_ARRAY = 10,
  PARSER_ASM_TYPE_SLICE = 11,
  PARSER_ASM_TYPE_LINEAR = 12,
  PARSER_ASM_TYPE_VECTOR = 13,
  PARSER_ASM_TYPE_F32 = 14,
  PARSER_ASM_TYPE_F64 = 15,
  PARSER_ASM_TYPE_VOID = 16,
  PARSER_ASM_TYPE_DYN = 17,
  /* 10.3.1 TYPE_FN — G.7 ≡ type_ref_slice.inc / ast.x. */
  PARSER_ASM_TYPE_FN = 18
};
extern int32_t ast_ast_arena_block_alloc(void *arena);
extern struct ast_Block ast_ast_arena_block_get(void *arena, int32_t ref);
extern void ast_ast_arena_block_set(void *arena, int32_t ref, struct ast_Block b);
extern int32_t ast_ast_arena_expr_alloc(void *arena);
extern struct ast_Expr ast_ast_arena_expr_get(void *arena, int32_t ref);
extern void ast_ast_arena_expr_set(void *arena, int32_t ref, struct ast_Expr e);
extern int32_t parser_asm_fill_block_const_let_from_res_c(void *arena, int32_t block_ref,
                                                          struct parser_asm_onefunc_result *res,
                                                          int32_t type_ref);
/* lex_skip family (P1 lane provides the definition). */
void parser_asm_skip_generic_angle_list_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                                     struct parser_asm_slice_u8 *source);

#ifdef XLANG_PTHIN_SKIP_TL_BODIES_FROM_X
/* .x product bodies (pointer ABI). C names stay on the trampolines.
 * stash_source stays C (file-global generic-bound scan); defined in the .inc. */
extern int32_t parser_asm_skip_one_struct_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_one_enum_into_c(void *lex_inout, void *source);
extern int32_t parser_asm_skip_one_extern_into_c(void *lex_inout, void *source);
void xlang_generic_bound_stash_source_c(struct parser_asm_slice_u8 *source);

void parser_asm_skip_one_struct_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  xlang_generic_bound_stash_source_c(source);
  cur = lex;
  (void)parser_asm_skip_one_struct_into_c(&cur, source);
  *out = cur;
}

struct parser_asm_lexer parser_asm_skip_one_struct_slice_c(struct parser_asm_lexer lex,
                                                           struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out;
  parser_asm_skip_one_struct_into_slice_c(&out, lex, source);
  return out;
}

void parser_asm_skip_one_enum_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                          struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  xlang_generic_bound_stash_source_c(source);
  cur = lex;
  (void)parser_asm_skip_one_enum_into_c(&cur, source);
  *out = cur;
}

void parser_asm_skip_one_extern_into_slice_c(struct parser_asm_lexer *out, struct parser_asm_lexer lex,
                                             struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer cur;
  if (!out || !source)
    return;
  cur = lex;
  (void)parser_asm_skip_one_extern_into_c(&cur, source);
  *out = cur;
}
#endif /* XLANG_PTHIN_SKIP_TL_BODIES_FROM_X */

#include "parser_asm_skip_tl_slice.inc"

int labi_pthin_skip_tl_slice_marker(void) {
  return 1;
}
