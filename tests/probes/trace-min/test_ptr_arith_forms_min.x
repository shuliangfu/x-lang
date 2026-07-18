/** Internal function `test_io_append_byte`.
 * Implements `test_io_append_byte`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param b u8
 * @return i32
 */
function test_io_append_byte(out: *u8, pos: i32, cap: i32, b: u8): i32 {
  return pos;
}

/** Internal function `ptr_add_index_load`.
 * Implements `ptr_add_index_load`.
 * @param s *u8
 * @param i i32
 * @return u8
 */
function ptr_add_index_load(s: *u8, i: i32): u8 {
  return (s + i)[0];
}

/** Internal function `ptr_add_only`.
 * Implements `ptr_add_only`.
 * @param s *u8
 * @param i i32
 * @return *u8
 */
function ptr_add_only(s: *u8, i: i32): *u8 {
  return s + i;
}

/** Internal function `ptr_add_index_call`.
 * Implements `ptr_add_index_call`.
 * @param out *u8
 * @param pos i32
 * @param cap i32
 * @param s *u8
 * @param i i32
 * @return i32
 */
function ptr_add_index_call(out: *u8, pos: i32, cap: i32, s: *u8, i: i32): i32 {
  return test_io_append_byte(out, pos, cap, (s + i)[0]);
}

/** Internal function `deref_store_u32`.
 * Implements `deref_store_u32`.
 * @param state *u32
 * @param s u32
 * @return void
 */
function deref_store_u32(state: *u32, s: u32): void {
  *state = s;
}
