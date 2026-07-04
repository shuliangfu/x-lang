/**
 * DOD-S1 smoke：`struct Name soa { ... }` + `T[N]` 列主序 + `arr[i].field` 读写。
 * 期望：arr[0].x=3, arr[1].x=5 → 返回 8（i32 x/y 列读写）。
 */
struct Vec2 soa {
  x: i32
  y: i32
}

function main(): i32 {
  let arr: Vec2[2] = [];
  arr[0].x = 3;
  arr[1].x = 5;
  arr[0].y = 1;
  let s: i32 = arr[0].x + arr[1].x;
  return s;
}
