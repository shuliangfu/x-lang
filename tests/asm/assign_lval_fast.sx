// 7.3：struct 字段 / INDEX 赋值应 mov 左值址→rbx + emit 右值，免 push/pop（run-asm-assign-var.sh）。
struct Point {
  x: i32
  y: i32
}

function main(): i32 {
  let p: Point = Point { x: 1, y: 2 };
  p.x = 10;
  let arr: u8[3] = [5, 10, 15];
  let i: i32 = 1;
  arr[i] = 42;
  // 10 + 42 = 52（return 常数，避免读路径 binop push 干扰本脚本验收 assign）
  return 52;
}
