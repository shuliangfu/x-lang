// a03_trait_monomorphization.x — trait monomorphization vs dynamic dispatch
// fallback: xlang trait/impl not yet available; using if-else dispatch.
// xlang has no function pointers (see a02_indirect_call.x) and no trait/impl,
// so both monomorphization and dynamic dispatch degrade to the same if-else
// pattern with direct function calls.
//
// Matches bench/a03_trait_monomorphization.c / .zig algorithm.
// N=100000000 iterations, alternating op_add and op_mul.

/** Internal function `op_add`.
 * Wrapping add (i32 two's complement).
 * @param x left operand
 * @param y right operand
 * @return i32 x + y
 */
function op_add(x: i32, y: i32): i32 {
  return x + y;
}

/** Internal function `op_mul`.
 * Wrapping multiply (i32 two's complement).
 * @param x left operand
 * @param y right operand
 * @return i32 x * y
 */
function op_mul(x: i32, y: i32): i32 {
  return x * y;
}

/** Internal function `main`.
 * Program/test entry point. Alternates between op_add and op_mul via
 * if-else dispatch (degraded from trait monomorphization / function pointer
 * dynamic dispatch because xlang has neither trait/impl nor function pointers).
 * @return i32 accumulated sum
 */
function main(): i32 {
  let n: i32 = 100000000;
  let sum: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    if (i % 2 == 0) {
      sum = sum + op_add(sum, i);
    } else {
      sum = sum + op_mul(sum, i);
    }
    i = i + 1;
  }
  return sum;
}
