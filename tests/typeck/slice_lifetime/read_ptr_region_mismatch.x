/* See implementation. */
extern function read_ptr_slice(): u8[];

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let s: u8[]<other> = unsafe { read_ptr_slice() };
  return 0;
}
