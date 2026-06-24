/** u32/i32 计数实参可隐式传给 usize 形参（memcmp/memcpy 长度等）。 */
extern function memcmp(a: *u8, b: *u8, n: usize): i32;
extern function memcpy(dst: *u8, src: *u8, n: usize): *u8;

function keys_eq(a: *u8, alen: u32, b: *u8, blen: u32): i32 {
  if (alen != blen) { return 0; }
  return memcmp(a, b, alen) == 0 ? 1 : 0;
}

function copy_n(dst: *u8, src: *u8, n: i32): void {
  memcpy(dst, src, n);
}

function main(): i32 {
  let a: u8[4] = [1, 2, 3, 4];
  let b: u8[4] = [1, 2, 3, 4];
  if (keys_eq(&a[0], 4, &b[0], 4) != 1) { return 1; }
  return 0;
}
