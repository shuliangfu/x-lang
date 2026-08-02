// a02_indirect_call.x — 间接调用/函数指针密集，N=100000000 次
// 与 bench/a02_indirect_call.c / .zig 同算法。
//
// 注意：xlang 当前不支持函数指针（fn pointer / 取函数地址），
// 故退化为 if-else 链按 i&3 选择调用对应 function。这是间接调用的
// 退化版（控制流等价，但无间接分支指令），用于对比 xlang 在缺少
// 函数指针时的等效实现性能。

/** Internal function `op_add`.
 * Wrapping add (i32 two's complement).
 * @param a i32
 * @param b i32
 * @return i32
 */
function op_add(a: i32, b: i32): i32 {
  return a + b;
}

/** Internal function `op_sub`.
 * Wrapping sub (i32 two's complement).
 * @param a i32
 * @param b i32
 * @return i32
 */
function op_sub(a: i32, b: i32): i32 {
  return a - b;
}

/** Internal function `op_mul`.
 * Wrapping mul (i32 two's complement).
 * @param a i32
 * @param b i32
 * @return i32
 */
function op_mul(a: i32, b: i32): i32 {
  return a * b;
}

/** Internal function `op_xor`.
 * Bitwise XOR.
 * @param a i32
 * @param b i32
 * @return i32
 */
function op_xor(a: i32, b: i32): i32 {
  return a ^ b;
}

/** Internal function `main`.
 * Program/test entry point. Densely dispatches to one of four op_*
 * functions per iteration (degraded from function-pointer table to
 * if-else chain because xlang has no first-class function pointers).
 * Loops N=100000000 times, returns acc & 0xFFFF.
 * @return i32 — low 16 bits of the accumulated result
 */
function main(): i32 {
  let n: i32 = 100000000;
  let acc: i32 = 0;
  let i: i32 = 0;
  while (i < n) {
    let sel: i32 = i & 3;
    if (sel == 0) {
      acc = op_add(acc, i);
    } else if (sel == 1) {
      acc = op_sub(acc, i);
    } else if (sel == 2) {
      acc = op_mul(acc, i);
    } else {
      acc = op_xor(acc, i);
    }
    i = i + 1;
  }
  return acc & 0xFFFF;
}
