// d1_int_arith.x — D1 整数运算边界差分测试（与 d1_int_arith.c 同源）
// 验证：u32 溢出回绕 / 有符号除法向零截断 / 取模符号 / 移位 / 位运算
function main(): i32 {
  let acc: u32 = 0;

  // 1. u32 溢出回绕：0xFFFFFFFF + 1 = 0
  let m1: u32 = 0xFFFFFFFF;
  acc = acc ^ (m1 + 1);

  // 2. 负数转 u32：-1 → 0xFFFFFFFF
  let neg1: i32 = -1;
  acc = acc ^ (neg1 as u32);

  // 3. 有符号除法向零截断：-7 / 2 = -3
  let neg7: i32 = -7;
  acc = acc ^ ((neg7 / 2) as u32);

  // 4. 有符号取模符号跟随被除数：-7 % 2 = -1
  acc = acc ^ ((neg7 % 2) as u32);

  // 5. 无符号除法：0xFFFFFFFF / 2 = 0x7FFFFFFF
  acc = acc ^ (m1 / 2);

  // 6. u32 左移：1 << 31 = 0x80000000
  let one: u32 = 1;
  acc = acc ^ (one << 31);

  // 7. u32 逻辑右移：0x80000000 >> 1 = 0x40000000
  let high: u32 = 0x80000000;
  acc = acc ^ (high >> 1);

  // 8. 位与：0xF0F0 & 0x0FF0 = 0x0F0
  acc = acc ^ (0xF0F0 & 0x0FF0);

  // 9. 位或：0xF0F0 | 0x0FF0 = 0xFFF0
  acc = acc ^ (0xF0F0 | 0x0FF0);

  // 10. 位异或：0xFF00 ^ 0x0FF0 = 0xF0F0
  acc = acc ^ (0xFF00 ^ 0x0FF0);

  // 11. i64 低 32 位：(1<<40) 低 32 位 = 0
  let big: i64 = 1 << 40;
  acc = acc ^ (big as u32);

  // 12. i64 乘法低 32 位：(1<<40)*3 低 32 位 = 0
  acc = acc ^ ((big * 3) as u32);

  return (acc & 0xFF) as i32;
}
