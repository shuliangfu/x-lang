/** Internal function `id_i32`.
 * Implements `id_i32`.
 * @param x i32
 * @return i32
 */
function id_i32(x: i32): i32 { return x; }

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return id_i32<i32>(42);
}
