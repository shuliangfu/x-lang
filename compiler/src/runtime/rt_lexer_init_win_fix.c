/* Win tip-cold: lexer_init was hollow TAIL (xor eax; ret). Tip ABI is
 * lexer_init(out: *Lexer): void — write Lexer{pos:0,line:1,col:1} via *out.
 * Callers (xlang_module_collect_imports_from_buf etc.) pass &lex in rcx then
 * read *out; hollow left the slot uninit → Heisenbug SEGV / num_funcs=0 →
 * empty codegen → XP003. Strong T before pe.s/no_c/hollow (PE first-win).
 * PLATFORM: WINDOWS. */
#include <stdint.h>

typedef struct {
  uint64_t pos;
  int32_t line;
  int32_t col;
} LexerInitWin;

void lexer_init(LexerInitWin *out) {
  if (!out) {
    return;
  }
  out->pos = 0;
  out->line = 1;
  out->col = 1;
}
