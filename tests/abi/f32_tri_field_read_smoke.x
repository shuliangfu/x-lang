/**
 * See implementation.
 * See implementation.
 */
struct F32Tri {
  x: f32
  y: f32
  z: f32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let t: F32Tri = F32Tri { x: 1.0, y: 2.0, z: 3.0 };
  let s: f32 = t.x + t.y + t.z;
  return s as i32;
}
