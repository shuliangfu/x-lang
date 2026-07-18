/** Internal function `cond_only`.
 * Implements `cond_only`.
 * @param pos *i32
 * @param out_cap i32
 * @return i32
 */
function cond_only(pos: *i32, out_cap: i32): i32 {
  if (*pos < 0 || *pos >= out_cap) { return 1; }
  return 0;
}

/** Internal function `index_only`.
 * Implements `index_only`.
 * @param out *u8
 * @param pos *i32
 * @param b u8
 * @return void
 */
function index_only(out: *u8, pos: *i32, b: u8): void {
  out[*pos] = b;
}

/** Internal function `deref_assign_only`.
 * Implements `deref_assign_only`.
 * @param pos *i32
 * @return void
 */
function deref_assign_only(pos: *i32): void {
  *pos = *pos + 1;
}
