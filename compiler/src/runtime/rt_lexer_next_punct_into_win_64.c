/* Win tip-cold: lexer_next_punct_into — dig_min puncts with product Token layout.
 *
 * Soft Cap s241: tipU next_body calls POINTER ABI (rdx=*Lexer, r9=c), not the
 * older by-value peel (rdx=pos, r8=line|col, stack c). Mirror tipU call site.
 * PLATFORM: WINDOWS|X86_64
 *
 * Note: g05 links the .s twin; keep this .c semantically identical for DIG.
 */
#include <stdint.h>
#include <string.h>

typedef struct {
  uint8_t *ptr;
  uint64_t len;
} Fat;

typedef struct {
  uint64_t pos;
  int32_t line;
  int32_t col;
} Lexer;

typedef struct {
  uint64_t next_pos;
  int32_t next_line;
  int32_t next_col;
  uint8_t tok_bytes[48];
  uint64_t token_start;
} LR;

static void put_tok(LR *out, int kind, int line, int col) {
  memset(out->tok_bytes, 0, 48);
  int32_t *t = (int32_t *)out->tok_bytes;
  t[0] = kind;
  t[1] = line;
  t[2] = col;
}

/**
 * Emit one punctuation token into out from tipU pointer-ABI args.
 *
 * @param out LexerResult buffer (next_lex + Token + token_start)
 * @param lex tipU *Lexer (pos@0 line@8 col@12)
 * @param data unused Fat* (tipU still passes it)
 * @param c punctuation byte
 */
void lexer_next_punct_into(LR *out, Lexer *lex, Fat *data, uint8_t c) {
  (void)data;
  if (!out || !lex) {
    return;
  }
  uint64_t pos = lex->pos;
  int line = lex->line;
  int col = lex->col;
  uint64_t start = pos;
  pos += 1;
  col += 1;
  int kind = 0;
  switch (c) {
    case 40: kind = 82; break;
    case 41: kind = 83; break;
    case 123: kind = 84; break;
    case 125: kind = 85; break;
    case 91: kind = 86; break;
    case 93: kind = 87; break;
    case 44: kind = 90; break;
    case 58: kind = 91; break;
    case 59: kind = 95; break;
    case 46: kind = 92; break;
    case 43: kind = 96; break;
    case 45: kind = 97; break;
    case 42: kind = 98; break;
    case 47: kind = 99; break;
    case 37: kind = 100; break;
    case 61: kind = 117; break;
    default: kind = 0; break;
  }
  out->next_pos = pos;
  out->next_line = line;
  out->next_col = col;
  put_tok(out, kind, line, col - 1);
  out->token_start = start;
}
