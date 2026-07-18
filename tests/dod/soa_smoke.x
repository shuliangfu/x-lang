/**
 * See implementation.
 * See implementation.
 */
struct Vec2 soa {
  x: i32
  y: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: Vec2[2] = [];
  arr[0].x = 3;
  arr[1].x = 5;
  arr[0].y = 1;
  let s: i32 = arr[0].x + arr[1].x;
  return s;
}
