// 测试 std.random：fill_bytes、next、range、flip
const random = import("std.random");

function main(): i32 {
  let buf: u8[32] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0];
  let n: i32 = random.fill_bytes(&buf[0], 32);
  if (n != 32) {
    return 1;
  }
  let x: u32 = random.next() as u32;
  let y: u64 = random.next();
  let r: u32 = random.range(0, 9);
  if (r > 9) {
    return 2;
  }
  let b: i32 = random.flip();
  if (b != 0 && b != 1) {
    return 3;
  }
  let r2: u32 = random.range(100, 100);
  if (r2 != 100) {
    return 4;
  }
  return 0;
}
