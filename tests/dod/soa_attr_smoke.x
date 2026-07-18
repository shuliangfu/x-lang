/**
 * See implementation.
 * See implementation.
 */
#[soa]
struct Vec2 {
  x: i32
  y: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let arr: Vec2[2] = [];
  arr[0].x = 2;
  arr[1].x = 6;
  let s: i32 = arr[0].x + arr[1].x;
  return s;
}
