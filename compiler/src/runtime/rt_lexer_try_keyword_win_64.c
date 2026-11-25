/* Win tip-cold: lexer_try_keyword — product Token layout (48B natural).
 *
 * Tip PE DIG 2026-11-09: builds local Token at -0x718 then field-copies from
 * wrong escalating slots (-0x88 function / -0x4e8 return / -0x168 i32) so
 * *out.kind stays 0 or stale → P001. next_body may also pass a non-zeroed
 * tok slot (-0x298 vs zero-init -0xe08), so no-match MUST store kind=0.
 *
 * ABI (tip Win64): rcx=out *Token, rdx=&Fat{ptr,len}, r8=start, r9=len,
 *   [rsp+0x28]=line0, [rsp+0x30]=col0.
 * Layout: kind@0 line@4 col@8 int_val@16 float@24 ident@32 ident_len@40.
 * PLATFORM: WINDOWS|X86_64
 */
#include <stdint.h>
#include <string.h>

typedef struct {
  uint8_t *ptr;
  uint64_t len;
} Fat;

typedef struct {
  int32_t kind;
  int32_t line;
  int32_t col;
  int32_t _pad;
  int64_t int_val;
  double float_val;
  uint8_t *ident;
  int32_t ident_len;
  int32_t _pad2;
} Token; /* 48 */

static int mk(const Fat *fat, uint64_t start, int n, const char *kw) {
  if (!fat || !fat->ptr) return 0;
  if (start + (uint64_t)n > fat->len) return 0;
  const uint8_t *p = fat->ptr + start;
  for (int i = 0; i < n; i++) {
    if (p[i] != (uint8_t)kw[i]) return 0;
  }
  return kw[n] == 0;
}

static void put(Token *out, int kind, int line, int col) {
  memset(out, 0, 48);
  out->kind = kind;
  out->line = line;
  out->col = col;
}

void lexer_try_keyword(Token *out, Fat *data, uint64_t start, uint64_t len,
                       int line0, int col0) {
  int n = (int)len;
  if (!out) return;
  /* Always clear first — next_body may pass a stale non-zeroed slot. */
  put(out, 0, line0, col0);
  if (!data || !data->ptr) return;
  if (n <= 0) return;
  if (start + (uint64_t)n > data->len) return;

  /* kinds mirror compiler/src/lexer/lexer.x try_keyword{,_b,_c,_d}. */
#define K(N, S, KIND)                                                          \
  do {                                                                         \
    if (n == (N) && mk(data, start, (N), (S))) {                               \
      put(out, (KIND), line0, col0);                                           \
      return;                                                                  \
    }                                                                          \
  } while (0)

  K(8, "function", 1);
  K(3, "let", 2);
  K(5, "const", 3);
  K(2, "if", 4);
  K(4, "else", 5);
  K(5, "while", 6);
  K(4, "loop", 7);
  K(3, "for", 8);
  K(5, "break", 9);
  K(8, "continue", 10);
  K(6, "return", 11);
  K(5, "panic", 12);
  K(5, "defer", 13);
  K(6, "region", 16);
  K(10, "with_arena", 17);
  K(5, "match", 18);
  K(6, "struct", 19);
  K(4, "type", 20);
  K(6, "packed", 21);
  K(3, "soa", 22);
  K(5, "align", 46);
  K(4, "enum", 47);
  K(4, "goto", 48);
  K(5, "trait", 49);
  K(4, "impl", 50);
  K(4, "self", 51);
  /* underscore ident "_" → kind 52 */
  if (n == 1 && data->ptr[start] == 95) {
    put(out, 52, line0, col0);
    return;
  }
  K(6, "import", 53);
  K(6, "extern", 54);
  K(5, "async", 55);
  K(5, "await", 56);
  K(3, "run", 57);
  K(5, "spawn", 58);
  K(6, "export", 131);
  K(3, "i32", 60);
  K(4, "bool", 61);
  K(2, "u8", 62);
  K(3, "u32", 63);
  K(3, "u64", 64);
  K(3, "i64", 65);
  K(5, "usize", 66);
  K(5, "isize", 67);
  K(5, "i3x4", 68);
  K(5, "i3x8", 69);
  K(6, "i3x16", 70);
  K(5, "u3x4", 71);
  K(5, "u3x8", 72);
  K(6, "u3x16", 73);
  K(4, "true", 75);
  K(5, "false", 76);
  K(4, "null", 132);
  K(3, "f32", 77);
  K(3, "f64", 78);
  K(4, "void", 79);
  K(2, "as", 128);
#undef K
  /* no-match: kind already 0 from put() at entry */
}
