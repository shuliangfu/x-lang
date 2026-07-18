// See implementation.
extern function slice_src(): i32[];

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  region ra {
    let a: i32[] = unsafe { slice_src() };
    let b: i32[] = unsafe { slice_src() };
    b = a;
  }
  return 0;
}
