/**
 * See implementation.
 * See implementation.
 */
struct F32Tri {
  x: f32
  y: f32
  z: f32
}

/** Internal function `write3`.
 * Write path helper `write3`.
 * @param v *F32Tri
 * @param x f32
 * @param y f32
 * @param z f32
 * @return f32
 */
function write3(v: *F32Tri, x: f32, y: f32, z: f32): f32 {
  v.x = x;
  v.y = y;
  v.z = z;
  return 0.0;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let t: F32Tri = F32Tri { x: 0.0, y: 0.0, z: 0.0 };
  write3(&t, 1.0, 2.0, 3.0);
  let s: f32 = t.x + t.y + t.z;
  return s as i32;
}
