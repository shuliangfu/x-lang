// See implementation.
extern function slice_src(): i32[];

/** Internal function `leak`.
 * Implements `leak`.
 * @return i32[]
 */
function leak(): i32[] {
  region ra {
    let s: i32[]<ra> = unsafe { slice_src() };
    return s;
  }
  return unsafe { slice_src() };
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return 0;
}
