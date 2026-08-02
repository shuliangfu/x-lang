// r09_recursion_vs_iter.x — fib(35) recursive vs iterative (matches r09_recursion_vs_iter.c / .zig)
// Tests: recursive function call overhead vs tight iterative loop.
// Returns rec ^ iter (should be 0, verifying both produce fib(35)=9227465).

/** Internal function `fib_rec`.
 * Naive recursive Fibonacci: fib(n) = fib(n-1) + fib(n-2).
 * fib(0)=0, fib(1)=1. Exponential call count — stress-tests call overhead.
 * @param n index into the Fibonacci sequence
 * @return i32 fib(n)
 */
function fib_rec(n: i32): i32 {
  if (n < 2) { return n; }
  return fib_rec(n - 1) + fib_rec(n - 2);
}

/** Internal function `fib_iter`.
 * Iterative Fibonacci using a tight accumulation loop.
 * @param n index into the Fibonacci sequence
 * @return i32 fib(n)
 */
function fib_iter(n: i32): i32 {
  if (n < 2) { return n; }
  let a: i32 = 0;
  let b: i32 = 1;
  let i: i32 = 2;
  while (i <= n) {
    let c: i32 = a + b;
    a = b;
    b = c;
    i = i + 1;
  }
  return b;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let n: i32 = 35;
  let rec: i32 = fib_rec(n);
  let iter: i32 = fib_iter(n);
  return rec ^ iter;
}
