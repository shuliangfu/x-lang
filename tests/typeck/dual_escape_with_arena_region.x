// See implementation.
extern function slice_src(): u8[];

/** Internal function `leak`.
 * Implements `leak`.
 * @return u8[]
 */
function leak(): u8[] {
  with_arena(4096) {
    region ra {
      let s: u8[] = unsafe { slice_src() };
      return s;
    }
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
