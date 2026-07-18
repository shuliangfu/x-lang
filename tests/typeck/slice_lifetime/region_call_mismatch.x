// See implementation.
extern function slice_src(): i32[];
/** Internal function `take_ra`.
 * Implements `take_ra`.
 * @param x i32[]<ra>
 * @return i32
 */
function take_ra(x: i32[]<ra>): i32 { return 0; }

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  region rb {
    let s: i32[]<rb> = unsafe { slice_src() };
    take_ra(s);
  }
  return 0;
}
