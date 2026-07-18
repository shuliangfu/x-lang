// public_add: see function docblock below.
/** Exported function `public_add`.
 * Implements `public_add`.
 * @param a i32
 * @param b i32
 * @return i32
 */
export function public_add(a: i32, b: i32): i32 {
  return a + b;
}

/** Internal function `private_mul`.
 * Implements `private_mul`.
 * @param a i32
 * @param b i32
 * @return i32
 */
function private_mul(a: i32, b: i32): i32 {
  return a * b;
}

/** Exported function `public_via_private`.
 * Implements `public_via_private`.
 * @param x i32
 * @return i32
 */
export function public_via_private(x: i32): i32 {
  return private_mul(x, 2);
}
