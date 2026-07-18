#[max_stack(64)]
/** Internal function `small_func`.
 * Implements `small_func`.
 * @param a i32
 * @param b i32
 * @return i32
 */
function small_func(a: i32, b: i32): i32 {
  let x: i32 = a + b;
  let y: i32 = x * 2;
  return y;
}

#[max_stack(32)]
/** Internal function `tiny_func`.
 * Implements `tiny_func`.
 * @return i32
 */
function tiny_func(): i32 {
  return 42;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return small_func(1, 2) + tiny_func();
}
