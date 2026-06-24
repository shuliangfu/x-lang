// let x: T; 省略 `=`：栈零填，等价 let buf: u8[N] = [] / let n: i32 = 0
allow(padding) struct Pair { a: i16; b: i32; }

function main(): i32 {
  let buf: u8[4];
  let n: i32;
  let z: i32x4;
  let p: Pair;
  buf[0] = 1;
  n = 42;
  if (buf[1] != 0 || buf[2] != 0 || buf[3] != 0) {
    return 1;
  }
  if (n != 42) {
    return 2;
  }
  if (p.a != 0 || p.b != 0) {
    return 3;
  }
  if (z[0] != 0 || z[1] != 0 || z[2] != 0 || z[3] != 0) {
    return 4;
  }
  return 0;
}
