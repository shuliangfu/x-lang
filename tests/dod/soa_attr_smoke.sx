/**
 * DOD-S1：`#[soa]` 属性语法 smoke（等价 struct Name soa { }）。
 * arr[0].x=2 + arr[1].x=6 → 返回 8（i32 路径）。
 */
#[soa]
struct Vec2 {
  x: i32
  y: i32
}

function main(): i32 {
  let arr: Vec2[2] = [];
  arr[0].x = 2;
  arr[1].x = 6;
  let s: i32 = arr[0].x + arr[1].x;
  return s;
}
