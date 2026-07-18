// See implementation.
extern function slice_src(): i32[];

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let outer: i32[]<rb> = unsafe { slice_src() };
  region ra {
    let inner: i32[]<ra> = unsafe { slice_src() };
    outer = inner;
  }
  return 0;
}
