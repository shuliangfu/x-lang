/* Win tip-cold: lexer_next_punct_into — dig_min puncts with product Token layout.
 * Tip PE: write_tok by-value ABI mismatch + tip-stride Token + Lex.col@+0x10 OOB
 * → "(" becomes kind=0 (EOF) → P001.
 * ABI: rcx=out, rdx+r8=Lexer by-value (pos, line|col<<32), r9=&Fat, stack c.
 * PLATFORM: WINDOWS|X86_64
 */
#include <stdint.h>
#include <string.h>

typedef struct { uint8_t *ptr; uint64_t len; } Fat;
typedef struct {
  int32_t kind, line, col, _pad;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len, _pad2;
} Token; /* 48 */

typedef struct {
  uint64_t pos;
  int32_t line, col;
  Token tok;
  uint64_t token_start;
} LexerResult; /* next_lex@0/16 tok@16/48 token_start@64 — with pad after col? */
/* LexerResult actual: Lexer 16 + Token 48 + u64 = 72. col at @12 no pad inside Lexer. */
typedef struct {
  uint64_t next_pos;
  int32_t next_line, next_col;
  uint8_t tok_bytes[48];
  uint64_t token_start;
} LR;

static void put_tok(LR *out, int kind, int line, int col) {
  memset(out->tok_bytes, 0, 48);
  int32_t *t = (int32_t *)out->tok_bytes;
  t[0] = kind; t[1] = line; t[2] = col;
}

void lexer_next_punct_into(LR *out, uint64_t pos, uint64_t line_col, Fat *data, uint8_t c) {
  (void)data;
  int line = (int)(line_col & 0xffffffffu);
  int col = (int)(line_col >> 32);
  uint64_t start = pos;
  /* advance one: pos++, col++ */
  pos += 1;
  col += 1;
  int kind = 0;
  switch (c) {
    case 40: kind = 82; break; /* ( */
    case 41: kind = 83; break; /* ) */
    case 123: kind = 84; break; /* { */
    case 125: kind = 85; break; /* } */
    case 91: kind = 86; break; /* [ */
    case 93: kind = 87; break; /* ] */
    case 44: kind = 90; break; /* , */
    case 58: kind = 91; break; /* : */
    case 59: kind = 95; break; /* ; */
    case 46: kind = 92; break; /* .  (ellipsis handled loosely) */
    case 43: kind = 96; break;
    case 45: kind = 97; break;
    case 42: kind = 98; break;
    case 47: kind = 99; break;
    case 37: kind = 100; break;
    case 61: kind = 115; break; /* = ASSIGN approx — check enum */
    default: kind = 0; break;
  }
  out->next_pos = pos;
  out->next_line = line;
  out->next_col = col;
  put_tok(out, kind, line, (int)(start < 0xffffffffu ? col - 1 : col)); /* col0 before advance */
  /* fix col0: we advanced col already; token col should be pre-advance */
  {
    int32_t *t = (int32_t *)out->tok_bytes;
    t[2] = (int)(col - 1);
  }
  out->token_start = start;
}
