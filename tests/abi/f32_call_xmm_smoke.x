/**
 * See implementation.
 * add3(1.0, 2.0, 3.0) → exit=6。
 */
function add3(x: f32, y: f32, z: f32): f32 {
  let a: f32 = x + y;
  return a + z;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: f32 = add3(1.0, 2.0, 3.0);
  return s as i32;
}
