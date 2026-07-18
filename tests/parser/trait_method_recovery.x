// See implementation.
trait Bad {
  /** Internal function `ok1`.
   * Implements `ok1`.
   * @param self
   * @return i32;
   */
  function ok1(self): i32;
  /** Internal function `bad`.
   * Implements `bad`.
   * @param self
   * @return void
   */
  function bad(self) i32;
  /** Internal function `ok2`.
   * Implements `ok2`.
   * @param self
   * @return u64;
   */
  function ok2(self): u64;
}

/** Internal function `good`.
 * Implements `good`.
 * @return i32
 */
function good(): i32 {
  return 0;
}
