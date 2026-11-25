/**
 * PLATFORM: MACOS|DARWIN arm64 tip PE only —
 * tip_l4_tip_pe_println_method_call_p001 follow-on.
 *
 * Tip PE selfhost-emitted g05_pthin_p11b_thin hollows the import-collect
 * family (peek elision): Cap collect_imports_into_c 26 bl vs tip 12;
 * try_skip 12 vs 4; consume_path 15 vs 4; expect_kind peek+step vs tip
 * step-only. Product hello `const fmt = import("std/io");` never binds
 * / never advances → let twin re-parses IMPORT via primary (no TOKEN_IMPORT
 * arm) → FACE peek=53 fail → typeck/diag hang. Soft Cap Prefer / Cap
 * aside / Win banned. Twin from src/asm/pthin_imports.x.
 */
#include <stddef.h>
#include <stdint.h>

enum {
  TOKEN_CONST = 3,
  TOKEN_ATTR_CFG = 24,
  TOKEN_IMPORT = 53,
  TOKEN_IDENT = 59,
  TOKEN_LPAREN = 82,
  TOKEN_RPAREN = 83,
  TOKEN_SEMICOLON = 95,
  TOKEN_ASSIGN = 117,
  TOKEN_STRING = 130,
  IMPORT_BIND_CAP = 128
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex_inout, void *source);
extern int32_t parser_asm_lex_peek_int_val_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_peek_token_start_c(void *lex_inout, void *source);
extern size_t parser_asm_lex_pos_c(void *lex_inout);
extern int32_t parser_asm_lex_line_c(void *lex_inout);
extern int32_t parser_asm_lex_col_c(void *lex_inout);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern size_t parser_asm_lex_source_length_c(void *source);
extern void parser_asm_imports_restore_lex(void *lex_inout, size_t pos, int32_t line,
                                          int32_t col);
extern void parser_asm_copy_slice_to_name64_buf_c(const uint8_t *data, int32_t slen,
                                                 size_t ts, int32_t n, uint8_t *dest);
extern int32_t parser_asm_imports_copy_quoted_path(const uint8_t *data, size_t slen_us,
                                                  size_t ts, uint8_t *path_buf,
                                                  int32_t *path_len);
extern int32_t parser_asm_stretch_import_path_validate_c(uint8_t *path_buf, int32_t n);
extern int32_t parser_asm_stretch_import_path_finalize_c(uint8_t *path_buf, int32_t n,
                                                        uint8_t *data, size_t slen_us);
extern int32_t parser_asm_cfg_skip_pending_apply_c(void *lex_inout, void *source,
                                                  int32_t pending);
extern int32_t pipeline_module_import_alloc(void *module);
extern void pipeline_module_import_set_path(void *module, int32_t ix, uint8_t *path,
                                           int32_t path_len);
extern void pipeline_module_import_set_kind(void *module, int32_t ix, int32_t kind);
extern void pipeline_module_import_set_binding_name(void *module, int32_t ix,
                                                   uint8_t *name, int32_t name_len);
extern void pipeline_module_import_set_select_count(void *module, int32_t ix, int32_t n);
extern int32_t parser_asm_try_skip_const_import_stmt(void *lex_inout, void *source);

int32_t parser_asm_imports_expect_kind(void *lex_inout, void *source, int32_t want) {
  int32_t kind;
  if (!lex_inout || !source)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != want)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  return 1;
}

int32_t parser_asm_collect_imports_consume_path_into_c(void *lex_inout, void *source,
                                                      uint8_t *path_buf,
                                                      int32_t *path_len) {
  int32_t kind, n, slen, copied, finalized, first;
  size_t ts, slen_us;
  uint8_t *data;

  if (!lex_inout || !source || !path_buf || !path_len)
    return 0;
  path_len[0] = 0;
  if (parser_asm_imports_expect_kind(lex_inout, source, TOKEN_LPAREN) == 0)
    return 0;
  data = parser_asm_lex_source_data_c(source);
  slen_us = parser_asm_lex_source_length_c(source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  slen = (slen_us > 2147483647ULL) ? 2147483647 : (int32_t)slen_us;
  if (kind == TOKEN_STRING && n > 0 && n <= 255) {
    parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, n, path_buf);
    path_len[0] = n;
    parser_asm_lex_step_kind_c(lex_inout, source);
  } else {
    copied = 0;
    if (kind == TOKEN_IDENT && n > 0 && n <= 255) {
      if (data && ts < slen_us) {
        first = (int32_t)data[ts];
        if (first == 34)
          copied = parser_asm_imports_copy_quoted_path(data, slen_us, ts, path_buf,
                                                      path_len);
      }
    }
    if (copied == 0)
      return 0;
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  if (parser_asm_imports_expect_kind(lex_inout, source, TOKEN_RPAREN) == 0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_SEMICOLON)
    return 0;
  n = path_len[0];
  if (parser_asm_stretch_import_path_validate_c(path_buf, n) == 0)
    return 0;
  finalized = parser_asm_stretch_import_path_finalize_c(path_buf, n, data, slen_us);
  if (finalized <= 0)
    return 0;
  path_len[0] = finalized;
  parser_asm_lex_step_kind_c(lex_inout, source);
  return 1;
}

int32_t parser_asm_try_skip_const_import_into_c(void *lex_inout, void *source,
                                               uint8_t *path_buf, int32_t *path_len) {
  size_t pos0;
  int32_t line0, col0, kind, n, ok;

  if (!lex_inout || !source || !path_buf || !path_len)
    return 0;
  pos0 = parser_asm_lex_pos_c(lex_inout);
  line0 = parser_asm_lex_line_c(lex_inout);
  col0 = parser_asm_lex_col_c(lex_inout);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  if (kind != TOKEN_IDENT || n <= 0)
    return 0;
  parser_asm_lex_step_kind_c(lex_inout, source);
  ok = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_ASSIGN);
  if (ok == 0) {
    parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
    return 0;
  }
  ok = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_IMPORT);
  if (ok == 0) {
    parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
    return 0;
  }
  ok = parser_asm_collect_imports_consume_path_into_c(lex_inout, source, path_buf,
                                                     path_len);
  if (ok == 0) {
    parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
    return 0;
  }
  return 1;
}

int32_t parser_asm_skip_imports_into_c(void *lex_inout, void *source) {
  int32_t pending = 0, kind, skipped;

  if (!lex_inout || !source)
    return 0;
  for (;;) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_ATTR_CFG) {
      pending = 0;
      if (parser_asm_lex_peek_int_val_c(lex_inout, source) == 0)
        pending = 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      continue;
    }
    if (pending != 0) {
      pending = parser_asm_cfg_skip_pending_apply_c(lex_inout, source, pending);
      if (pending != 0)
        pending = 0;
      continue;
    }
    if (kind != TOKEN_CONST)
      return 1;
    parser_asm_lex_step_kind_c(lex_inout, source);
    skipped = parser_asm_try_skip_const_import_stmt(lex_inout, source);
    if (skipped != 0)
      continue;
    return 1;
  }
}

int32_t parser_asm_collect_imports_into_c(void *lex_inout, void *source, void *module,
                                         uint8_t *path_buf, uint8_t *bind_buf,
                                         int32_t *path_len) {
  int32_t pending = 0, kind, n, pl, ok, zi, imp_ix, line0, col0, slen;
  size_t pos0, ts, slen_us;
  uint8_t *data;

  if (!lex_inout || !source || !module || !path_buf || !bind_buf || !path_len)
    return 0;
  for (;;) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_ATTR_CFG) {
      pending = 0;
      if (parser_asm_lex_peek_int_val_c(lex_inout, source) == 0)
        pending = 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      continue;
    }
    if (pending != 0) {
      pending = parser_asm_cfg_skip_pending_apply_c(lex_inout, source, pending);
      if (pending != 0)
        pending = 0;
      continue;
    }
    if (kind != TOKEN_CONST)
      return 1;
    pos0 = parser_asm_lex_pos_c(lex_inout);
    line0 = parser_asm_lex_line_c(lex_inout);
    col0 = parser_asm_lex_col_c(lex_inout);
    parser_asm_lex_step_kind_c(lex_inout, source);
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
    if (kind != TOKEN_IDENT || n <= 0 || n > 255) {
      parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
      return 1;
    }
    ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
    data = parser_asm_lex_source_data_c(source);
    slen_us = parser_asm_lex_source_length_c(source);
    slen = (slen_us > 2147483647ULL) ? 2147483647 : (int32_t)slen_us;
    pl = n;
    if (pl > 127)
      pl = 127;
    for (zi = 0; zi < IMPORT_BIND_CAP; zi++)
      bind_buf[zi] = 0;
    if (pl > 0 && data)
      parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl, bind_buf);
    parser_asm_lex_step_kind_c(lex_inout, source);
    ok = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_ASSIGN);
    if (ok == 0) {
      parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
      return 1;
    }
    ok = parser_asm_imports_expect_kind(lex_inout, source, TOKEN_IMPORT);
    if (ok == 0) {
      parser_asm_imports_restore_lex(lex_inout, pos0, line0, col0);
      return 1;
    }
    ok = parser_asm_collect_imports_consume_path_into_c(lex_inout, source, path_buf,
                                                       path_len);
    if (ok == 0)
      return 0;
    imp_ix = pipeline_module_import_alloc(module);
    if (imp_ix < 0)
      return 0;
    pipeline_module_import_set_path(module, imp_ix, path_buf, path_len[0]);
    pipeline_module_import_set_kind(module, imp_ix, 1);
    pipeline_module_import_set_binding_name(module, imp_ix, bind_buf, pl);
    pipeline_module_import_set_select_count(module, imp_ix, 0);
  }
}
