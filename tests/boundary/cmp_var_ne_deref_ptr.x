// Expected: run = 0
// Knife 10.47: arm64 must park lhs across `var != *(p + j)` / `as i32`
// (right-hand address arith must not clobber the left operand register).
export function main(): i32 {
  let name: [4]u8 = [97, 98, 99, 100];
  let p: *u8 = &name[0];
  let j: i32 = 1;
  let b: i32 = 98;
  unsafe {
    if (b != *(p + j)) {
      return 1;
    }
    if (b != (*(p + j) as i32)) {
      return 2;
    }
    if (b == (*(p + j) as i32)) {
    } else {
      return 3;
    }
    let c: i32 = 97;
    if (c != *(p + j)) {
    } else {
      return 4;
    }
  }
  let k: i32 = 0;
  while (k < 4) {
    let expect: i32 = 0;
    unsafe { expect = name[k] as i32; }
    unsafe {
      if (expect != (*(p + k) as i32)) {
        return 10 + k;
      }
    }
    k = k + 1;
  }
  return 0;
}
