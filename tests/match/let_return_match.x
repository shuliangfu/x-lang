/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: i32 = 1;
  return match x { 1 => 2; _ => 0; }
}
