// d5_bit_ops.x — D5 位运算/移位差分测试（与 d5_bit_ops.c 同源）
// 验证：负数右移（算术 vs 逻辑）/ 大数移位 / 位域提取 / 位设置清除
function main(): i32 {
  let acc: u32 = 0;
  let allones: u32 = 0xFFFFFFFF;

  // 1. 负数右移（算术右移）：-1 >> 1 = 0xFFFFFFFF
  let neg: i32 = -1;
  acc = acc ^ ((neg >> 1) as u32);

  // 2. 无符号右移：0x80000000 >> 4 = 0x08000000
  let high: u32 = 0x80000000;
  acc = acc ^ (high >> 4);

  // 3. 大数左移：1 << 30 = 0x40000000
  let one: u32 = 1;
  acc = acc ^ (one << 30);

  // 4. 取反：~0x0F0F = 0xFFFFF0F0
  let mask: u32 = 0x0F0F;
  acc = acc ^ (allones ^ mask);

  // 5. 位与：0xAA55 & 0x0FF0 = 0x0A50
  let a1: u32 = 0xAA55;
  let a2: u32 = 0x0FF0;
  acc = acc ^ (a1 & a2);

  // 6-9. 位域提取
  let v: u32 = 0xDEADBEEF;
  let ff: u32 = 0xFF;
  acc = acc ^ ((v >> 24) & ff);
  acc = acc ^ ((v >> 16) & ff);
  acc = acc ^ ((v >> 8) & ff);
  acc = acc ^ (v & ff);

  // 10-11. 位设置 + 清除
  let x: u32 = 0;
  let bit7: u32 = one << 7;
  x = x | bit7;
  x = x & (allones ^ bit7);
  acc = acc ^ x;

  // 12. 位移组合：(0xFF << 16) | 0xFF = 0x00FF00FF
  let ff16: u32 = ff << 16;
  acc = acc ^ (ff16 | ff);

  return (acc & 0xFF) as i32;
}
