// See implementation.
trait Twice { function twice(self): i32; function triple(self): i32; }
impl Twice for i32 {
  /** Internal function `twice`.
   * Implements `twice`.
   * @param self i32
   * @return i32
   */
  function twice(self: i32): i32 { return self * 2; }
}
/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 0; }
