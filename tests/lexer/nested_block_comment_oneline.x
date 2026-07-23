// Probe: single-line nested block comments use the SAME depth+path-safe
// algorithm as multi-line (not a second grammar). Authority: lexer.x
// skip_whitespace_and_comments — PLATFORM: SHARED.
//
// Best algorithm (head/tail balance, not C first-close):
//   depth=1 on outer /*; each true nest-open /* → +1; each */ → −1;
//   end only when depth==0. Path globs (std/*.o, src/*.x) do NOT nest-open.
//
// Unbalanced `/* /* */` alone leaves depth=1 (unclosed) — write `/* /* */ */`.

/* xxx /* xxx */ xxx */
/* /* */ */
/* process_argv complement after std/*.o pushes */
/* a */ /* b still nested? no — two sequential comments */
/**/
/* outer /* mid /* deep */ mid */ outer */

export function main(): i32 {
  return 77;
}
