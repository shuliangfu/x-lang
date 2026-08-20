// UB narrowing: dynamic index OOB on a **slice** must panic (SIGABRT / non-zero).
// Stage 12.0.5 pure-asm policy (glue_emit_index_bounds_guard): fixed array + non-lit
// index intentionally has NO runtime guard (C / freestanding parity; no U xlang_panic_).
// Slice path keeps lo/hi guards. This file must use a real i32[] base, not a[i] on T[N].
// PLATFORM: SHARED — product pure-asm + host-c both panic on slice OOB.
// main: see function docblock below.
/** Internal function `main`.
 * Program/test entry point: OOB index into slice derived from fixed array.
 * @return i32 — unreachable on success path (must panic before return)
 */
function main(): i32 {
  let a: i32[2] = [10, 20];
  let s: i32[] = a;
  let i: i32 = 2;
  return s[i];
}
