/* Host-gcc twin of parse_directive_into (preprocess.x). typool first-wins
 * T 0x140391325 (fromsrc_s84; no leftover W) compiled
 * `if (pp_is_ws(ws0)) { pos = pos + 1; } else { break; }`
 * as a jump to the while condition, not out of the loop:
 *   call pp_is_ws; test eax,eax; je +0x58 (nop);
 *   ...; cmp pos,line_len; jl body
 * When the byte is not whitespace, typool falls into the while-head
 * with pos unchanged and spins. Writer RIP typool 0x140391375
 * (je to the nop that falls into the condition) / typool 0x140391384
 * (jl back to the body). GDB on fromsrc_s84 check examples/hello.x
 * (repo cwd): first line `// Hello World...` line_len=63, pos=0, c=47
 * ('/'), pp_is_ws returned 0, EXIT_SKIP_WS i=0, then the same
 * BEFORE_WS i=0 c=47 forever; parse_directive_into never returned to
 * preprocess_x_buf+0x127 at 0x140391d2a. Same typool-wrong class as
 * typool path_should_ignore break-as-jmp to while-head. Host-gcc twin
 * uses a real break. The three later skip-ws loops in this face have
 * the same typool-wrong pattern and are fixed together. docs-only .x,
 * do not idx8. Do not JMP typool rec T 0x140087de4. Do not fold typool
 * diag_io_fputc / typool preprocess_x_buf in this thin. */
#include <stdint.h>

extern int32_t g_pp_kind;
extern int32_t g_pp_sym_len;

extern int32_t pp_is_ws(uint8_t ch);
extern int32_t pp_at_end_or_not_byte(uint8_t *buf, int32_t pos, int32_t line_len, uint8_t target);
extern int32_t pp_match_if(uint8_t *buf, int32_t pos, int32_t line_len);
extern int32_t pp_match_elseif(uint8_t *buf, int32_t pos, int32_t line_len);
extern int32_t pp_match_else(uint8_t *buf, int32_t pos, int32_t line_len);
extern int32_t pp_match_endif(uint8_t *buf, int32_t pos, int32_t line_len);
extern int32_t pp_is_word_boundary(uint8_t *buf, int32_t pos, int32_t line_len);
extern int32_t pp_at_end_or_token_end(uint8_t *buf, int32_t pos, int32_t line_len);
extern int32_t parse_copy_cond_from_line(uint8_t *cond, uint8_t *line_buf, int32_t pos, int32_t line_len);

void parse_directive_into(uint8_t *line_buf, int32_t line_len, uint8_t *cond) {
  int32_t pos;
  uint8_t ws;
  int32_t cl;

  pos = 0;
  g_pp_kind = 0;
  g_pp_sym_len = 0;
  while (pos < line_len) {
    ws = line_buf[pos];
    if (pp_is_ws(ws)) {
      pos = pos + 1;
    } else {
      break;
    }
  }
  if (pp_at_end_or_not_byte(line_buf, pos, line_len, 35)) {
    return;
  }
  pos = pos + 1;
  while (pos < line_len) {
    ws = line_buf[pos];
    if (pp_is_ws(ws)) {
      pos = pos + 1;
    } else {
      break;
    }
  }
  if (pos >= line_len) {
    return;
  }
  if (pp_match_if(line_buf, pos, line_len)) {
    pos = pos + 2;
    if (pp_is_word_boundary(line_buf, pos, line_len)) {
      return;
    }
    while (pos < line_len) {
      ws = line_buf[pos];
      if (pp_is_ws(ws)) {
        pos = pos + 1;
      } else {
        break;
      }
    }
    if (pos >= line_len) {
      return;
    }
    cl = parse_copy_cond_from_line(cond, line_buf, pos, line_len);
    if (cl <= 0) {
      return;
    }
    g_pp_kind = 1;
    g_pp_sym_len = cl;
    return;
  }
  if (pp_match_elseif(line_buf, pos, line_len)) {
    pos = pos + 6;
    if (pp_is_word_boundary(line_buf, pos, line_len)) {
      return;
    }
    while (pos < line_len) {
      ws = line_buf[pos];
      if (pp_is_ws(ws)) {
        pos = pos + 1;
      } else {
        break;
      }
    }
    if (pos >= line_len) {
      return;
    }
    cl = parse_copy_cond_from_line(cond, line_buf, pos, line_len);
    if (cl <= 0) {
      return;
    }
    g_pp_kind = 4;
    g_pp_sym_len = cl;
    return;
  }
  if (pp_match_else(line_buf, pos, line_len)) {
    pos = pos + 4;
    if (pp_at_end_or_token_end(line_buf, pos, line_len)) {
      g_pp_kind = 2;
      g_pp_sym_len = 0;
      return;
    }
    return;
  }
  if (pp_match_endif(line_buf, pos, line_len)) {
    pos = pos + 5;
    if (pp_at_end_or_token_end(line_buf, pos, line_len)) {
      g_pp_kind = 3;
      g_pp_sym_len = 0;
      return;
    }
    return;
  }
}
