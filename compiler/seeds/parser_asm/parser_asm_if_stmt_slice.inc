/**
 * parser_asm_if_stmt_slice.inc — parse_if_stmt_into C 实现。
 *
 * 由 parser_asm_thin_c.c #include；勿单独编译。
 * 单条 if（含 else / else if 链）；回调 parse_cond_expr / parse_block X mega，勿 X emit 本函数体。
 *
 * Hybrid P5b/P5c/P5d: XLANG_PTHIN_CTRL_BODIES_FROM_X skips the portable
 * buf-path region (comment-aware brace skip + kw_at_pos + scan_sync;
 * bodies in src/asm/pthin_ctrl.x + slice trampolines in the seed TU)
 * and, since P5d, the six-stage realign walk (P9a bridge peek family).
 * parse / arena stay here (callback into X mega parse_cond_expr /
 * parse_block; do not X-emit that body). P5k (2026-09-16): the leftover
 * C twin parse_if_stmt_into_slice_c is skipped when BODIES is on
 * (8.3.6 T-shrink; .x is already the product walk). Contiguous
 * already-T AUDIT_CALL padding on the cold twin is compiled only under
 * XLANG_PARSER_STRETCH_AUDIT (product AUDIT_CALL is nop). Cold: no
 * define, full twin. Do not reuse XLANG_PTHIN_CTRL_FROM_X for P5b/P5c/P5d
 * bodies. Do not wrap leftover else-if AUDIT.
 */
#ifndef PARSER_ASM_IF_STMT_SLICE_INCLUDED
#define PARSER_ASM_IF_STMT_SLICE_INCLUDED

/** 与 parser.x ParseBlockResult 布局一致（bool→i32）。 */
#ifndef PARSER_ASM_PARSE_BLOCK_RESULT_FWD
#define PARSER_ASM_PARSE_BLOCK_RESULT_FWD
struct parser_asm_parse_block_result {
  int32_t ok;
  int32_t block_ref;
  struct parser_asm_lexer next_lex;
};
#endif

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

/* =============================================================================
 * if_stmt wave-1 pointer-face shims (2026-09-14): the pthin self-compiled lane
 * is pointer-only (no struct-by-value), so the future .x if_stmt orchestration
 * calls these instead of the by-value glues. Each shim assembles the by-value
 * lexer, drives the existing X-mega glue (single authority), and writes the
 * result back through out-slots with next_lex applied to the caller-owned
 * cursor in place. PLATFORM: SHARED — additive; both lanes link the glues.
 * ============================================================================= */
int32_t parser_parse_cond_expr_ptr_into_c(void *arena, void *lex_inout, void *source,
                                          int32_t *out_ok, int32_t *out_expr_ref) {
  struct parser_asm_parse_expr_result res;
  struct parser_asm_lexer lex;
  if (!arena || !lex_inout || !source || !out_ok || !out_expr_ref)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  memset(&res, 0, sizeof(res));
  parser_parse_cond_expr_into_glue(arena, lex, source, &res);
  *out_ok = res.ok;
  *out_expr_ref = res.expr_ref;
  *(struct parser_asm_lexer *)lex_inout = res.next_lex;
  return 1;
}

int32_t parser_parse_block_ptr_into_c(void *arena, void *lex_inout, void *source, int32_t type_ref,
                                      int32_t *out_ok, int32_t *out_block_ref) {
  struct parser_asm_parse_block_result res;
  struct parser_asm_lexer lex;
  if (!arena || !lex_inout || !source || !out_ok || !out_block_ref)
    return 0;
  lex = *(struct parser_asm_lexer *)lex_inout;
  memset(&res, 0, sizeof(res));
  parser_parse_block_into(arena, lex, source, type_ref, &res);
  *out_ok = res.ok;
  *out_block_ref = res.block_ref;
  *(struct parser_asm_lexer *)lex_inout = res.next_lex;
  return 1;
}

/* if_stmt wave-2: scan-sync from the statement-start snapshot. The .x
 * side keeps only scalars (pos/line/col of `if`), so rebuild the at-lexer
 * here; on success replace the caller's walked cursor with the scanned
 * one (full pos+line+col). Returns 1 when replaced, 0 to let the caller
 * fall back to its realign arm (C tail semantics). */
static struct parser_asm_lexer parser_asm_scan_sync_after_if_stmt_c(struct parser_asm_lexer lex_cur,
                                                                    struct parser_asm_slice_u8 *source);
int32_t parser_if_stmt_scan_sync_from_pos_ptr_into_c(void *source, size_t pos0, int32_t line0,
                                                     int32_t col0, void *lex_inout) {
  struct parser_asm_lexer at;
  struct parser_asm_lexer scanned;
  if (!source || !lex_inout)
    return 0;
  memset(&at, 0, sizeof(at));
  at.pos = pos0;
  at.line = line0;
  at.col = col0;
  scanned = parser_asm_scan_sync_after_if_stmt_c(at, source);
  if (scanned.pos > at.pos) {
    *(struct parser_asm_lexer *)lex_inout = scanned;
    return 1;
  }
  return 0;
}
extern int32_t ast_ast_arena_block_alloc(void *arena);
extern int32_t pipeline_block_append_if(void *arena, int32_t br, int32_t cond_ref, int32_t then_ref, int32_t else_ref);
extern int32_t pipeline_block_append_stmt_order(void *arena, int32_t br, uint8_t kind, int32_t idx);
extern size_t parser_asm_lexer_pos_before_run_c(size_t end_pos, int32_t run_len);
extern size_t parser_asm_stretch_skip_ws_and_comments_c(const uint8_t *data, size_t len, size_t pos);
extern struct parser_asm_lexer parser_asm_lex_at_token_from_result_c(struct parser_asm_lexer_result r);
extern struct parser_asm_lexer parser_asm_parser_rewind_lex_for_following_stmt_c(struct parser_asm_lexer lex_in,
                                                                                  struct parser_asm_lexer_result r);
extern int32_t parser_asm_ident_is_unsafe_stmt_slice_c(struct parser_asm_lexer_result r,
                                                       struct parser_asm_slice_u8 *source);
/** 从已消费 '(' 的 lex 起跳过匹配括号，返回 ')' 之后的 lex。 */
extern struct parser_asm_lexer parser_asm_skip_balanced_parens_slice_c(struct parser_asm_lexer lex,
                                                                       struct parser_asm_slice_u8 *source);

#ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X
/* 记253／9.1: cold under #ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X removed */
#endif /* !XLANG_PTHIN_CTRL_BODIES_FROM_X sync_lex fwd */
/** 从当前 if 起点扫描整句 if/else 并返回下一语句首 token（前向声明）。 */
static struct parser_asm_lexer parser_asm_scan_sync_after_if_stmt_c(struct parser_asm_lexer lex_cur,
                                                                    struct parser_asm_slice_u8 *source);

/**
 * then/else 块结束后对齐 lex：parse_block 有时落在下一 if 的 `(`，回扫至 TOKEN_IF 或 stmt 关键字。
 * 非 static：供 parse_one_function_impl if 后 onefunc 回扫 glue 调用。
 * Hybrid P5d: six-stage walk body in pthin_ctrl.x over the P9a bridge
 * peek family; this trampoline keeps the by-value lexer ABI (language
 * has no struct-by-value). Null source keeps lex_cur (safe superset).
 */
#ifdef XLANG_PTHIN_CTRL_BODIES_FROM_X
extern int32_t parser_asm_realign_lex_after_if_arm_into_c(void *lex_inout, void *source);
struct parser_asm_lexer parser_asm_realign_lex_after_if_arm_c(struct parser_asm_lexer lex_cur,
                                                                     struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out = lex_cur;
  parser_asm_realign_lex_after_if_arm_into_c(&out, source);
  return out;
}
#else
struct parser_asm_lexer parser_asm_realign_lex_after_if_arm_c(struct parser_asm_lexer lex_cur,
                                                                     struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer_result at_cur = {0};
  struct parser_asm_lexer_result peek = {0};
  at_cur.next_lex = lex_cur;
  lexer_next_into(&at_cur, lex_cur, source);
  /** lex 已在 stmt 关键字上时直接保留（peek 会落到 expr 首 token，勿误回扫）。 */
  if (at_cur.tok.kind == (int32_t)TOKEN_RETURN || at_cur.tok.kind == (int32_t)TOKEN_IF ||
      at_cur.tok.kind == (int32_t)TOKEN_WHILE || at_cur.tok.kind == (int32_t)TOKEN_FOR ||
      at_cur.tok.kind == (int32_t)TOKEN_MATCH || at_cur.tok.kind == (int32_t)TOKEN_RBRACE ||
      at_cur.tok.kind == (int32_t)TOKEN_LET || at_cur.tok.kind == (int32_t)TOKEN_CONST ||
      parser_asm_ident_is_unsafe_stmt_slice_c(at_cur, source) != 0)
    return parser_asm_lex_at_token_from_result_c(at_cur);
  peek = at_cur;
  if (peek.tok.kind == (int32_t)TOKEN_LPAREN) {
    int32_t back_pos = 2;
    while (back_pos <= 128) {
      struct parser_asm_lexer lex_b;
      struct parser_asm_lexer_result r_b = {0};
      lex_b.pos = (int32_t)parser_asm_lexer_pos_before_run_c((size_t)lex_cur.pos, (size_t)back_pos);
      lex_b.line = peek.tok.line;
      lex_b.col = peek.tok.col;
      r_b.next_lex = lex_b;
      lexer_next_into(&r_b, lex_b, source);
      if (r_b.tok.kind == (int32_t)TOKEN_IF)
        return parser_asm_lex_at_token_from_result_c(r_b);
      back_pos = back_pos + 1;
    }
  }
  if (peek.tok.kind == (int32_t)TOKEN_RETURN || peek.tok.kind == (int32_t)TOKEN_IF ||
      peek.tok.kind == (int32_t)TOKEN_WHILE || peek.tok.kind == (int32_t)TOKEN_FOR ||
      peek.tok.kind == (int32_t)TOKEN_MATCH || peek.tok.kind == (int32_t)TOKEN_RBRACE ||
      peek.tok.kind == (int32_t)TOKEN_LET || peek.tok.kind == (int32_t)TOKEN_CONST ||
      parser_asm_ident_is_unsafe_stmt_slice_c(peek, source) != 0)
    return parser_asm_lex_at_token_from_result_c(peek);
  /*
   * if 条件含 struct.field 时 lex 偶发落在 `return r3.value` 的 expr 首 ident；按 ident_start 回溯 "return"。
   */
  if (peek.tok.kind == (int32_t)TOKEN_IDENT) {
    size_t ident_start = (size_t)peek.token_start;
    if (ident_start == 0 && peek.tok.ident_len > 0)
      ident_start = parser_asm_lexer_pos_before_run_c((size_t)peek.next_lex.pos, peek.tok.ident_len);
    if (ident_start >= 7 && source->data != NULL) {
      const uint8_t *sp = source->data + ident_start;
      if (sp[-7] == (uint8_t)'r' && sp[-6] == (uint8_t)'e' && sp[-5] == (uint8_t)'t' && sp[-4] == (uint8_t)'u'
          && sp[-3] == (uint8_t)'r' && sp[-2] == (uint8_t)'n') {
        uint8_t sep = sp[-1];
        if (sep == (uint8_t)' ' || sep == (uint8_t)'\t' || sep == (uint8_t)'\n' || sep == (uint8_t)'\r') {
          struct parser_asm_lexer ret_lex;
          ret_lex.pos = (int32_t)(ident_start - 7);
          ret_lex.line = peek.tok.line;
          ret_lex.col = peek.tok.col;
          return ret_lex;
        }
      }
    }
  }
  /*
   * if 条件含 struct.field 时 parse_cond 偶发将 lex 落在下一 stmt 的 return 之后（如 r3.value 的 r3）；
   * 回扫至 return/if/while 等 stmt 关键字。
   */
  {
    int32_t back_kw = 2;
    while (back_kw <= 160) {
      struct parser_asm_lexer lex_kw;
      struct parser_asm_lexer_result r_kw = {0};
      lex_kw.pos = (int32_t)parser_asm_lexer_pos_before_run_c((size_t)lex_cur.pos, (size_t)back_kw);
      lex_kw.line = peek.tok.line;
      lex_kw.col = peek.tok.col;
      r_kw.next_lex = lex_kw;
      lexer_next_into(&r_kw, lex_kw, source);
      if (r_kw.tok.kind == (int32_t)TOKEN_RETURN || r_kw.tok.kind == (int32_t)TOKEN_IF ||
          r_kw.tok.kind == (int32_t)TOKEN_WHILE || r_kw.tok.kind == (int32_t)TOKEN_FOR ||
          r_kw.tok.kind == (int32_t)TOKEN_MATCH || r_kw.tok.kind == (int32_t)TOKEN_LET ||
          r_kw.tok.kind == (int32_t)TOKEN_CONST || parser_asm_ident_is_unsafe_stmt_slice_c(r_kw, source) != 0)
        return parser_asm_lex_at_token_from_result_c(r_kw);
      back_kw = back_kw + 1;
    }
  }
  /*
   * if 条件含 struct.field 时 lex 可能滑入下一 stmt 中部；自当前 pos 向前（最多 512B）找 depth==0 的 stmt 关键字。
   */
  {
    size_t scan = (size_t)lex_cur.pos;
    size_t scan_end = scan + 512;
    int32_t depth = 0;
    if (scan_end > source->length)
      scan_end = source->length;
    while (scan + 2 < scan_end) {
      uint8_t ch = source->data[scan];
      if (ch == (uint8_t)'(')
        depth = depth + 1;
      else if (ch == (uint8_t)')' && depth > 0)
        depth = depth - 1;
      else if (ch == (uint8_t)'{')
        depth = depth + 1;
      else if (ch == (uint8_t)'}' && depth > 0)
        depth = depth - 1;
      if (depth == 0) {
        static const struct {
          const char *kw;
          int32_t klen;
          int32_t tok;
        } stmt_kws[] = {
            {"return", 6, (int32_t)TOKEN_RETURN}, {"let", 3, (int32_t)TOKEN_LET},
            {"const", 5, (int32_t)TOKEN_CONST},   {"if", 2, (int32_t)TOKEN_IF},
            {"while", 5, (int32_t)TOKEN_WHILE},   {"for", 3, (int32_t)TOKEN_FOR},
            {"match", 5, (int32_t)TOKEN_MATCH},   {"unsafe", 6, (int32_t)TOKEN_IDENT},
        };
        size_t ki;
        for (ki = 0; ki < sizeof(stmt_kws) / sizeof(stmt_kws[0]); ki++) {
          int32_t klen = stmt_kws[ki].klen;
          if (scan + (size_t)klen > scan_end)
            continue;
          if (memcmp(source->data + scan, stmt_kws[ki].kw, (size_t)klen) != 0)
            continue;
          if (scan > 0) {
            uint8_t prev = source->data[scan - 1];
            if ((prev >= (uint8_t)'a' && prev <= (uint8_t)'z') || (prev >= (uint8_t)'A' && prev <= (uint8_t)'Z')
                || (prev >= (uint8_t)'0' && prev <= (uint8_t)'9') || prev == (uint8_t)'_')
              continue;
          }
          if (scan + (size_t)klen < source->length) {
            uint8_t nx = source->data[scan + (size_t)klen];
            if (nx != (uint8_t)' ' && nx != (uint8_t)'\t' && nx != (uint8_t)'\n' && nx != (uint8_t)'\r'
                && nx != (uint8_t)'(' && nx != (uint8_t)';' && nx != (uint8_t)'{')
              continue;
          }
          {
            struct parser_asm_lexer lx;
            struct parser_asm_lexer_result rr = {0};
            lx.pos = (int32_t)scan;
            lx.line = lex_cur.line;
            lx.col = lex_cur.col;
            rr.next_lex = lx;
            lexer_next_into(&rr, lx, source);
            if (rr.tok.kind == stmt_kws[ki].tok)
              return parser_asm_lex_at_token_from_result_c(rr);
          }
        }
      }
      scan = scan + 1;
    }
  }
  return parser_asm_parser_rewind_lex_for_following_stmt_c(lex_cur, peek);
}
#endif /* XLANG_PTHIN_CTRL_BODIES_FROM_X realign */

extern int32_t parser_asm_stretch_if_stmt_branch_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_stmt_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_if_else_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_ultra_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_super_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_control_flow_intergalactic_galactic_celestial_divine_imperial_sovereign_omnipotent_universal_cosmic_eternal_infinite_transcendent_absolute_ultimate_supreme_crown_pinnacle_zenith_peak_summit_apex_max_ultra_hyper_mega_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_vx_control_flow_pk_sm_xv_nv_wv_cv_fv_ev_tv_av_pv_ov_hv_mv_uv_ig_ga_ce_dv_im_sv_om_un_co_et_ifn_tr_ab_ul_su_cr_pi_ze_pk_sm_ax_mx_ut_hy_mg_full_deep_audit_c(void *lex_inout, void *source);
extern int32_t parser_asm_stretch_else_if_chain_audit_c(void *lex_inout, void *source);

#ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X
#ifdef XLANG_PARSER_STRETCH_AUDIT
#endif /* XLANG_PARSER_STRETCH_AUDIT parse_if_stmt prefix */
#endif /* !XLANG_PTHIN_CTRL_BODIES_FROM_X parse_if_stmt_into_slice */

/** 非 static 导出供 glue 调用。 */
#ifdef XLANG_PTHIN_CTRL_BODIES_FROM_X
/* if_stmt wave-2: body in pthin_ctrl.x (cond/block ptr shims + P1b rparen
 * advance + scan-sync shim + P5d realign; else-if chains recurse). */
extern int32_t parser_asm_parse_if_stmt_x_into_c(void *arena, void *lex_inout, void *source, int32_t type_ref,
                                                 int32_t *out_cond, int32_t *out_then, int32_t *out_else);
int32_t parser_asm_parse_if_stmt_into_c(void *arena, struct parser_asm_lexer lex_at_if,
                                        struct parser_asm_slice_u8 *source, int32_t type_ref, int32_t *out_cond,
                                        int32_t *out_then, int32_t *out_else, struct parser_asm_lexer *lex_out) {
  struct parser_asm_lexer cur;
  int32_t rc;
  if (!lex_out)
    return 0;
  cur = lex_at_if;
  rc = parser_asm_parse_if_stmt_x_into_c(arena, &cur, source, type_ref, out_cond, out_then, out_else);
  lex_out->pos = cur.pos;
  lex_out->line = cur.line;
  lex_out->col = cur.col;
  return rc;
}
#else
int32_t parser_asm_parse_if_stmt_into_c(void *arena, struct parser_asm_lexer lex_at_if,
                                        struct parser_asm_slice_u8 *source, int32_t type_ref, int32_t *out_cond,
                                        int32_t *out_then, int32_t *out_else, struct parser_asm_lexer *lex_out) {
  return parser_asm_parse_if_stmt_into_slice_c(arena, lex_at_if, source, type_ref, out_cond, out_then, out_else,
                                               lex_out);
}
#endif /* XLANG_PTHIN_CTRL_BODIES_FROM_X parse_if_stmt */

#ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_CTRL_BODIES_FROM_X is_ws_byte */

#ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_CTRL_BODIES_FROM_X kw_at_pos */

#ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_CTRL_BODIES_FROM_X skip_braces_bytes */

#ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_CTRL_BODIES_FROM_X scan_sync */

#ifndef XLANG_PTHIN_CTRL_BODIES_FROM_X
#endif /* !XLANG_PTHIN_CTRL_BODIES_FROM_X sync_lex */

/** parse_one_function_impl：if 语句后 lex 回扫（field cond 后偶发落在 return 之后）。 */
void parser_realign_lex_after_if_stmt_onefunc_glue(struct parser_asm_lexer *lex,
                                                   struct parser_asm_slice_u8 *source) {
  struct parser_asm_lexer out;
  if (!lex || !source)
    return;
  /**
   * parse_if_stmt_into_slice_c 已从 lex_at_if 重扫整句 if/else 并返回“整条语句之后”的 lex_out。
   * 这里若再从当前 lex 反向找最近的 if，会在嵌套 if 场景误命中内层 if，
   * 把 then 臂里的 `continue;` / `return;` 重新暴露给外层 block 或函数体。
   * 因此这里只做当前位置附近的 stmt 对齐，不再二次整句回扫。
   */
  out = parser_asm_realign_lex_after_if_arm_c(*lex, source);
  lex->pos = out.pos;
  lex->line = out.line;
  lex->col = out.col;
}

#endif /* PARSER_ASM_IF_STMT_SLICE_INCLUDED */
