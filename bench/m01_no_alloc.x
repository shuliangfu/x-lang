// m01_no_alloc.x — 纯栈上计算 sum of squares 1..N, N=100000000
// 与 bench/m01_no_alloc.c / .zig 三语言同算法同 N。
// 无 malloc / 无 I/O，纯整数循环。i32 算术溢出按二补码回绕，
// 与 C / Zig 参照实现一致；返回 sum & 0xFFFF 保证结果确定性。

/** Internal function `main`.
 * Program/test entry point. Computes sum of squares 1..N (N=100000000)
 * on the stack with no heap allocation. Arithmetic wraps on i32 overflow
 * (two's complement), consistent with the C and Zig reference implementations.
 * @return i32 — low 16 bits of the accumulated sum
 */
function main(): i32 {
  let n: i32 = 100000000;
  let sum: i32 = 0;
  let i: i32 = 1;
  while (i <= n) {
    sum = sum + i * i;
    i = i + 1;
  }
  return sum & 0xFFFF;
}
