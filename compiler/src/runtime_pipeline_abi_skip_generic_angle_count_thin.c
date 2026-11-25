/*
 * Host-gcc twin of parser_asm_skip_generic_angle_list_count_into_c
 * (pthin_lex_skip.x).
 * Root (s47 unofficial hello check/build 139): typool first-wins W at
 *   0x140451590, frame 0xc28. Caller
 *   parser_asm_skip_generic_angle_list_count_into_slice_c+246 passed a
 *   live count (r8=0x103c74bc) and pending_n (arg6=0x103c74b8). typool
 *   lowered the entry `count[0]=0; pending_n[0]=0` as
 *     lea -0x20(%rbp) / mov $0, (%rbx)
 *     lea -0x38(%rbp) / mov $0, (%rbx)
 *   i.e. it stored 0 into the saved pointer slots themselves, not
 *   through them. The abort path (after lex_set_col_c) then correctly
 *   loaded -0x20(%rbp) and did `mov %eax,(%rbx)`: first-chance write AV
 *   at 0x140451fdd (ExceptionInformation[0]=1, addr 0). Same face on
 *   hello check and hello build.
 * Class: typool pointer-element store uses lea of the out-slot instead
 *   of loading the pointer (write-one-slot cousin). Not a missing null
 *   guard, and not a caller that failed to pass a live out slot. typool
 *   already homes arg5/arg6 at rbp+0x30/0x38 correctly.
 * Fold allowlist: parser_asm_skip_generic_angle_list_count_into_c only.
 * Do not fold typool pend BSS, typool onefunc_sidecar_get,
 *   typool w1545_pend_rcx_emit, or formal-ensure.
 * Do not idx8 the .x twin.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>
#include <stddef.h>

#define TOKEN_EOF 0
#define TOKEN_IDENT 59
#define TOKEN_RPAREN 83
#define TOKEN_COMMA 90
#define TOKEN_COLON 91
#define TOKEN_LT 120
#define TOKEN_GT 121
#define GP_PENDING_MAX 8
#define GP_NAME_CAP 64

int32_t parser_asm_lex_step_kind_c(uint8_t *lex_inout, uint8_t *source);
int32_t parser_asm_lex_peek_kind_c(uint8_t *lex_inout, uint8_t *source);
int32_t parser_asm_lex_peek_ident_len_c(uint8_t *lex_inout, uint8_t *source);
size_t parser_asm_lex_peek_token_start_c(uint8_t *lex_inout, uint8_t *source);
size_t parser_asm_lex_pos_c(uint8_t *lex_inout);
int32_t parser_asm_lex_line_c(uint8_t *lex_inout);
int32_t parser_asm_lex_col_c(uint8_t *lex_inout);
void parser_asm_lex_set_pos_c(uint8_t *lex_inout, size_t pos);
void parser_asm_lex_set_line_c(uint8_t *lex_inout, int32_t line);
void parser_asm_lex_set_col_c(uint8_t *lex_inout, int32_t col);
uint8_t *parser_asm_lex_source_data_c(uint8_t *source);
size_t parser_asm_lex_source_length_c(uint8_t *source);
int32_t parser_asm_angle_list_token_is_stmt_boundary_c(int32_t k);
void parser_asm_copy_slice_to_name64_buf_c(uint8_t *source, int32_t source_len,
                                           size_t start, int32_t nlen, uint8_t *out);

int32_t parser_asm_skip_generic_angle_list_count_into_c(uint8_t *lex_inout,
                                                       uint8_t *source,
                                                       int32_t *count,
                                                       uint8_t *names,
                                                       int32_t *lenses,
                                                       int32_t *pending_n) {
  size_t pos0;
  int32_t line0;
  int32_t col0;
  int32_t depth;
  int32_t kind;
  int32_t top_count;
  int32_t saw_any;
  int32_t expect_tp;
  int32_t pn;
  int32_t pl;
  size_t ts;
  uint8_t *data;
  size_t slen_us;
  int32_t slen;
  int32_t zi;
  size_t slot_off;

  if (lex_inout == 0 || source == 0 || count == 0 || names == 0 || lenses == 0 ||
      pending_n == 0) {
    return 0;
  }

  count[0] = 0;
  pending_n[0] = 0;
  pos0 = parser_asm_lex_pos_c(lex_inout);
  line0 = parser_asm_lex_line_c(lex_inout);
  col0 = parser_asm_lex_col_c(lex_inout);
  data = parser_asm_lex_source_data_c(source);
  slen_us = parser_asm_lex_source_length_c(source);
  if (slen_us > (size_t)2147483647) {
    slen = 2147483647;
  } else {
    slen = (int32_t)slen_us;
  }
  depth = 0;
  top_count = 0;
  saw_any = 0;
  expect_tp = 0;
  pn = 0;
  for (;;) {
    kind = parser_asm_lex_peek_kind_c(lex_inout, source);
    if (kind == TOKEN_LT) {
      depth = depth + 1;
      if (depth == 1) {
        expect_tp = 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      continue;
    }
    if (kind == TOKEN_GT) {
      depth = depth - 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      if (depth <= 0) {
        if (saw_any != 0) {
          count[0] = top_count + 1;
        } else {
          count[0] = 0;
        }
        pending_n[0] = pn;
        return 1;
      }
      continue;
    }
    if (kind == TOKEN_COMMA) {
      if (depth == 1) {
        top_count = top_count + 1;
        expect_tp = 1;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      continue;
    }
    if (kind == TOKEN_COLON) {
      if (depth == 1) {
        expect_tp = 0;
      }
      parser_asm_lex_step_kind_c(lex_inout, source);
      continue;
    }
    if (kind == TOKEN_IDENT && depth == 1 && expect_tp != 0) {
      if (pn < GP_PENDING_MAX) {
        pl = parser_asm_lex_peek_ident_len_c(lex_inout, source);
        if (pl > 63) {
          pl = 63;
        }
        ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
        if (ts == 0) {
          ts = parser_asm_lex_pos_c(lex_inout);
        }
        slot_off = (size_t)pn * (size_t)GP_NAME_CAP;
        zi = 0;
        while (zi < GP_NAME_CAP) {
          names[slot_off + (size_t)zi] = 0;
          zi = zi + 1;
        }
        if (pl > 0 && data != 0) {
          parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, pl,
                                                names + slot_off);
        }
        lenses[pn] = pl;
        pn = pn + 1;
      }
      expect_tp = 0;
      saw_any = 1;
      parser_asm_lex_step_kind_c(lex_inout, source);
      continue;
    }
    if (kind == TOKEN_EOF) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      count[0] = 0;
      pending_n[0] = 0;
      return 1;
    }
    if (parser_asm_angle_list_token_is_stmt_boundary_c(kind) != 0) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      count[0] = 0;
      pending_n[0] = 0;
      return 1;
    }
    if (depth == 1 && kind == TOKEN_RPAREN) {
      parser_asm_lex_set_pos_c(lex_inout, pos0);
      parser_asm_lex_set_line_c(lex_inout, line0);
      parser_asm_lex_set_col_c(lex_inout, col0);
      count[0] = 0;
      pending_n[0] = 0;
      return 1;
    }
    if (depth == 1) {
      saw_any = 1;
    }
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  return 1;
}
