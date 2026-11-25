// Knife 10.47: arm64 `var != *(p + j)` must not clobber lhs while forming
// the right-hand address (cast as i32 still wrong before the fix).
// Expected: run = 0
export function main(): i32 {
  let buf: [4]i32 = [10, 20, 30, 40];
  let p: *i32 = &buf[0];
  let j: i32 = 2;
  let b: i32 = 30;
  unsafe {
    if (b != *(p + j)) {
      return 1;
    }
    if (b != (*(p + j) as i32)) {
      return 2;
    }
    let c: i32 = 99;
    if (c != *(p + j)) {
    } else {
      return 3;
    }
    if (b == *(p + j)) {
    } else {
      return 4;
    }
  }
  if (b != buf[j]) {
    return 5;
  }
  return 0;
}
