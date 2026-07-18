// See implementation.
enum E { A, B }
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let e: E = E.A;
  return match e { E.C => 1; _ => 0; }
}
