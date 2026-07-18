extern function foo(): usize;

/** Internal function `helper`.
 * Implements `helper`.
 * @param p *i32
 * @param i i32
 * @return void
 */
function helper(p: *i32, i: i32): void {
  p[0] = i;
}

/** Internal function `test`.
 * Implements `test`.
 * @param n i32
 * @return i32
 */
function test(n: i32): i32 {
  let args: i32[64] = [];
  let tids: i64[64] = [];
  let entry: usize = 0;
  let i: i32 = 0;
  while (i < n) {
    helper(&args[0], i);
    i = i + 1;
  }
  unsafe { entry = foo(); }
  i = 0;
  while (i < n) {
    i = i + 1;
  }
  return 0;
}
