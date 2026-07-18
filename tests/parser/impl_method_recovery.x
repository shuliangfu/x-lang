// See implementation.
trait Dub { function dub(self): i32; }
impl Dub for i32 {
  /** Internal function `ok1`.
   * Implements `ok1`.
   * @param self i32
   * @return i32
   */
  function ok1(self: i32): i32 { return self * 2; }
  /** Internal function `bad`.
   * Implements `bad`.
   * @param self i32
   * @return i32
   */
  function bad(self i32): i32 { return self; }
  /** Internal function `ok2`.
   * Implements `ok2`.
   * @param self i32
   * @return i32
   */
  function ok2(self: i32): i32 { return self + 1; }
}

/** Internal function `good`.
 * Implements `good`.
 * @return i32
 */
function good(): i32 {
  return 0;
}
