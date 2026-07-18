// See implementation.
struct Point {
  x: i32
  y: i32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let p: Point = Point { x: 3, y: 4 };
  let arr: u8[3] = [10, 20, 30];
  let i: i32 = 1;
  let j: i32 = 2;
  /** p.x + p.y = 7 */
  let a: i32 = p.x + p.y;
  /** arr[i] = 20 */
  let b: i32 = arr[i] as i32;
  /** arr[j] = 30 */
  let c: i32 = arr[j] as i32;
  /** p.x + arr[i] = 23 */
  let d: i32 = p.x + b;
  /** arr[i] + p.y = 24 */
  let e: i32 = b + p.y;
  /* See implementation. */
  let f: i32 = arr[i] as i32 + c;
  /* See implementation. */
  let g: i32 = arr[i] as i32 + arr[j] as i32;
  /** p.x < p.y → a+…+g+1 = 155+50=205 */
  if (p.x < p.y) {
    return a + b + c + d + e + f + g + 1;
  }
  return a + b + c + d + e + f + g;
}
