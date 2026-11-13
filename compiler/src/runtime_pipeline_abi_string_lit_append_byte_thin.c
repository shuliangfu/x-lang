/*
 * Host-gcc twin of parser_asm_string_lit_append_byte_ptr_c
 * (real body in pthin_expr_primary_tramp.x).
 * Root (s49 unofficial hello --check P001 no functions): parse enters
 * function main, folded suffix consumes the '.' of fmt.println, and
 * typool parse_expr_into / primary_string reaches TOKEN_STRING at
 * byte 215 with a good slice (len 233, bytes `"Hello W`...). typool
 * decode_span_x is called with q0=216 nlen=11 line=6 col=15 (correct).
 * ident_byte returns 'H' (72). typool first-wins W of
 * parser_asm_string_lit_append_byte_ptr_c at 0x14046f858 is the
 * pthin_expr_primary_tramp_win_stubs.x face: home args then
 *   movabs $0xffffffffffffffff,%rax / ret
 * so append always returns -1, decode fails, set_onefunc_fail at
 * next_lex.pos=206, skip main at 175, empty module -> P001.
 * Class: Windows typool/stub first-wins always-fail writer (the
 * tramp.x in-place arena writer never ran). Not a missing suffix
 * consume of '.' (suffix entered at 206 and parked at 215).
 * Fold allowlist: parser_asm_string_lit_append_byte_ptr_c only.
 * Do not fold typool pend BSS, typool w1545_pend_rcx_emit, typool
 * onefunc_sidecar_get, formal-ensure, or the sibling win stubs
 * (struct_lit_append_field / shorthand / parse_field_value).
 * Do not idx8 the .x twin.
 * PLATFORM: WINDOWS — PE fold first-wins; keep proven hooks.
 */
#include <stdint.h>

uint8_t *pipeline_arena_expr_ptr(void *arena, int32_t ref);
void lexer_note_string_lit_overflow(int32_t line, int32_t col);
int32_t ast_ast_arena_expr_alloc(void *arena);
void parser_asm_expr_set_common_zeros_c(uint8_t *ov);

static void string_lit_init_overflow(uint8_t *ov, int32_t line, int32_t col) {
  int32_t *p;
  parser_asm_expr_set_common_zeros_c(ov);
  p = (int32_t *)ov;
  p[0] = 59; /* EXPR_STRING_LIT */
  p[2] = line;
  p[3] = col;
  p[4] = 0;
  p[5] = 0;
  p[72] = 0;
}

int32_t parser_asm_string_lit_append_byte_ptr_c(void *arena, int32_t head_ref,
                                               int32_t b, int32_t line,
                                               int32_t col) {
  uint8_t bv;
  uint8_t *he;
  int32_t *hp;
  int32_t total;
  int32_t hline;
  int32_t hcol;
  int32_t cur;
  int32_t off;
  int32_t ov;
  uint8_t *oe;
  int32_t next;
  int32_t nv;
  uint8_t *ce;
  int32_t *cp;
  uint8_t *ne;
  uint8_t *te;
  int32_t *tp;

  if (arena == 0 || head_ref <= 0) {
    return -1;
  }
  bv = (uint8_t)(b & 255);
  he = pipeline_arena_expr_ptr(arena, head_ref);
  if (he == 0) {
    return -1;
  }
  hp = (int32_t *)he;
  total = hp[72];
  if (total < 0) {
    total = 0;
  }
  if (total >= 4095) {
    lexer_note_string_lit_overflow(line, col);
    return -1;
  }
  if (total < 127) {
    he[32 + total] = bv;
    hp[72] = total + 1;
    return 0;
  }
  hline = hp[2];
  hcol = hp[3];
  cur = hp[4];
  off = total - 127;
  if (cur <= 0) {
    ov = ast_ast_arena_expr_alloc(arena);
    if (ov == 0) {
      return -1;
    }
    oe = pipeline_arena_expr_ptr(arena, ov);
    string_lit_init_overflow(oe, hline, hcol);
    he = pipeline_arena_expr_ptr(arena, head_ref);
    hp = (int32_t *)he;
    hp[4] = ov;
    hp[5] = 0;
    cur = ov;
  }
  while (off >= 127) {
    ce = pipeline_arena_expr_ptr(arena, cur);
    cp = (int32_t *)ce;
    next = cp[4];
    if (next <= 0) {
      nv = ast_ast_arena_expr_alloc(arena);
      if (nv == 0) {
        return -1;
      }
      ce = pipeline_arena_expr_ptr(arena, cur);
      cp = (int32_t *)ce;
      cp[4] = nv;
      cp[5] = 0;
      ne = pipeline_arena_expr_ptr(arena, nv);
      string_lit_init_overflow(ne, hline, hcol);
      next = nv;
    }
    off = off - 127;
    cur = next;
  }
  te = pipeline_arena_expr_ptr(arena, cur);
  tp = (int32_t *)te;
  te[32 + off] = bv;
  if (tp[72] < off + 1) {
    tp[72] = off + 1;
  }
  he = pipeline_arena_expr_ptr(arena, head_ref);
  hp = (int32_t *)he;
  hp[72] = total + 1;
  return 0;
}
