// See implementation.
struct Point { x: i32; y: i32; }

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Point = { x: 1, y: 2 };
  if (p.x != 1 || p.y != 2) {
    return 1;
  }
  return 0;
}
