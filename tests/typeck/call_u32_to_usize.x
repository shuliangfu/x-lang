/* See implementation. */
extern function memcmp(a: *u8, b: *u8, n: usize): i32;
extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;

/** Internal function `keys_eq`.
 * Implements `keys_eq`.
 * @param a *u8
 * @param alen u32
 * @param b *u8
 * @param blen u32
 * @return i32
 */
function keys_eq(a: *u8, alen: u32, b: *u8, blen: u32): i32 {
  if (alen != blen) { return 0; }
  return unsafe { memcmp(a, b, alen) } == 0 ? 1 : 0;
}

/** Internal function `copy_n`.
 * Implements `copy_n`.
 * @param dst *u8
 * @param src *u8
 * @param n i32
 * @return void
 */
function copy_n(dst: *u8, src: *u8, n: i32): void {
  unsafe { memcpy(dst, src, n); }
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let a: u8[4] = [1, 2, 3, 4];
  let b: u8[4] = [1, 2, 3, 4];
  if (keys_eq(&a[0], 4, &b[0], 4) != 1) { return 1; }
  return 0;
}
