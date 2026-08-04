// See implementation.
/** Function `id`.
 * Purpose: implements `id`; params/returns as declared (may be multi-line).
 * Contracts: null/cap/PLATFORM as enforced in the body.
 */
function id<T>(x: T): T { return x; }

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 10000000;
  let s: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    s = s ^ id<i32>(i);
    i = i + 1;
  }
  return s;
}
