// d4_float.x — D4 浮点运算差分测试（P2，占位）
// 验证：IEEE 754 基本运算 / 浮点比较
// 时机：P2，ASM 后端浮点支持完善后激活
function main(): i32 {
  let x: f64 = 1.5;
  let y: f64 = 2.5;
  let z: f64 = x * y;
  if (z > 3.0) { return 1; }
  return 0;
}
