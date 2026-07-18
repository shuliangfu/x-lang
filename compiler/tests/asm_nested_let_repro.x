// asm_nested_let_repro.x — repro while-body if-then nested let asm slot registration
// (fr not in ctx / exit 139).

/**
 * while + if-then let fr; asm must register fr in the block tree or if-then ensure path.
 * Returns the final i after the loop (expect 10).
 */
function demo_nested_let(): i32 {
  let i: i32 = 0;
  while (i < 10) {
    if (i > 0) {
      let fr: i32 = i + 1;
      i = fr;
    } else {
      i = i + 1;
    }
  }
  return i;
}
