/* Host-gcc twin of typool parser_asm_collect_imports_consume_path_into_c
 * (pthin_imports.x). typool first-wins W (fromsrc_s101 0x1404a9808)
 * typool-wrongs every `path_len[0] = ...` store as
 *   lea -0x28(%rbp), %rbx; mov %rax, (%rbx)
 * i.e. it writes through the ADDRESS of the local that holds the
 * path_len pointer, overwriting that pointer with the integer length,
 * and never stores through the real out-param. Live INT3 on
 * fromsrc_s101_noaslr check examples/hello.x (repo cwd):
 * ENTER path_len_arg=0x103f810c *path_len=0 path_buf="";
 * STORE0_MOV rbx=slot(=rbp-0x28) val=0 is_path_len_arg=False;
 * STORE_FIN_MOV rbx=slot val=7 is_path_len_arg=False (writer RIP
 * typool 0x1404a9e45); RET rax=1 *path_len_arg still 0 path_buf="std.fmt".
 * Same typool typool-wrong class as typool primary_suffix pending_refs
 * scale-8 through the ADDRESS of a local slot. Downstream
 * pipeline_module_import_set_path then records len=0, so
 * xlang_load_one builds `_tmpdig/.x` and IMP001 fires. typool tip /
 * body_into / skip_function / append_i32 / fputc / try_keyword_c /
 * typool rec / typool lexer_next_impl wholesale / typool normalize
 * leftovers are not in this thin. docs-only .x, do not idx8. Do not
 * JMP typool rec T 0x140087de4. */
#include <stdint.h>

enum {
  TOKEN_LPAREN = 82,
  TOKEN_RPAREN = 83,
  TOKEN_SEMICOLON = 95,
  TOKEN_IDENT = 59,
  TOKEN_STRING = 130
};

extern int32_t parser_asm_lex_peek_kind_c(void *lex, void *source);
extern int32_t parser_asm_lex_peek_ident_len_c(void *lex, void *source);
extern uint64_t parser_asm_lex_peek_token_start_c(void *lex, void *source);
extern int32_t parser_asm_lex_step_kind_c(void *lex, void *source);
extern uint8_t *parser_asm_lex_source_data_c(void *source);
extern uint64_t parser_asm_lex_source_length_c(void *source);
extern void parser_asm_copy_slice_to_name64_buf_c(uint8_t *data, int32_t slen,
                                                 uint64_t ts, int32_t n,
                                                 uint8_t *path_buf);
extern int32_t parser_asm_stretch_import_path_validate_c(uint8_t *path_buf,
                                                         int32_t path_len);
extern int32_t parser_asm_stretch_import_path_finalize_c(uint8_t *path_buf,
                                                          int32_t path_len,
                                                          uint8_t *source,
                                                          uint64_t source_len);

static int32_t imports_expect_kind(void *lex, void *source, int32_t want) {
  int32_t kind = parser_asm_lex_peek_kind_c(lex, source);
  if (kind != want)
    return 0;
  parser_asm_lex_step_kind_c(lex, source);
  return 1;
}

static int32_t imports_copy_quoted_path(uint8_t *data, uint64_t slen_us,
                                        uint64_t ts, uint8_t *path_buf,
                                        int32_t *path_len) {
  uint64_t q0;
  uint64_t q1;
  uint64_t k;
  uint8_t c;
  if (data == 0 || path_buf == 0 || path_len == 0)
    return 0;
  q0 = ts + 1;
  q1 = q0;
  while (q1 < slen_us) {
    c = data[q1];
    if (c == 34)
      break;
    q1 = q1 + 1;
  }
  if (q1 >= slen_us)
    return 0;
  if (q1 - q0 > 127)
    return 0;
  k = 0;
  while (k < q1 - q0) {
    c = data[q0 + k];
    path_buf[k] = c;
    k = k + 1;
  }
  path_buf[k] = 0;
  path_len[0] = (int32_t)k;
  return 1;
}

int32_t parser_asm_collect_imports_consume_path_into_c(void *lex_inout,
                                                      void *source,
                                                      uint8_t *path_buf,
                                                      int32_t *path_len) {
  int32_t kind;
  int32_t n;
  uint64_t ts;
  uint8_t *data;
  uint64_t slen_us;
  int32_t slen;
  int32_t copied;
  int32_t finalized;
  int32_t first;

  if (lex_inout == 0 || source == 0 || path_buf == 0 || path_len == 0)
    return 0;
  path_len[0] = 0;
  copied = imports_expect_kind(lex_inout, source, TOKEN_LPAREN);
  if (copied == 0)
    return 0;
  data = parser_asm_lex_source_data_c(source);
  slen_us = parser_asm_lex_source_length_c(source);
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  n = parser_asm_lex_peek_ident_len_c(lex_inout, source);
  ts = parser_asm_lex_peek_token_start_c(lex_inout, source);
  if (slen_us > 2147483647ull)
    slen = 2147483647;
  else
    slen = (int32_t)slen_us;
  if (kind == TOKEN_STRING && n > 0 && n <= 255) {
    parser_asm_copy_slice_to_name64_buf_c(data, slen, ts, n, path_buf);
    path_len[0] = n;
    parser_asm_lex_step_kind_c(lex_inout, source);
  } else {
    copied = 0;
    if (kind == TOKEN_IDENT && n > 0 && n <= 255) {
      if (data != 0 && ts < slen_us) {
        first = (int32_t)data[ts];
        if (first == 34)
          copied = imports_copy_quoted_path(data, slen_us, ts, path_buf, path_len);
      }
    }
    if (copied == 0)
      return 0;
    parser_asm_lex_step_kind_c(lex_inout, source);
  }
  copied = imports_expect_kind(lex_inout, source, TOKEN_RPAREN);
  if (copied == 0)
    return 0;
  kind = parser_asm_lex_peek_kind_c(lex_inout, source);
  if (kind != TOKEN_SEMICOLON)
    return 0;
  n = path_len[0];
  copied = parser_asm_stretch_import_path_validate_c(path_buf, n);
  if (copied == 0)
    return 0;
  finalized = parser_asm_stretch_import_path_finalize_c(path_buf, n, data, slen_us);
  if (finalized <= 0)
    return 0;
  path_len[0] = finalized;
  parser_asm_lex_step_kind_c(lex_inout, source);
  return 1;
}
