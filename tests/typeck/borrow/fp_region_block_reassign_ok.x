// See implementation.
extern function slice_src(): i32[];

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  region ra {
    let s: i32[] = unsafe { slice_src() };
    let t: i32[] = unsafe { slice_src() };
    t = s;
  }
  return 0;
}
