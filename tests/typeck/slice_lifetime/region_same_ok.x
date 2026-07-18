// See implementation.
extern function slice_src(): i32[];

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let x: i32[]<ra> = unsafe { slice_src() };
  let y: i32[]<ra> = unsafe { slice_src() };
  y = x;
  return 0;
}
