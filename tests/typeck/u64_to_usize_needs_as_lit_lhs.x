/* See implementation. */
allow(padding) struct Entry { off: u64; }
allow(padding) struct Store { mt: Entry[4]; }

/** Internal function `bad_offset`.
 * Implements `bad_offset`.
 * @param s *Store
 * @param i u32
 * @return usize
 */
function bad_offset(s: *Store, i: u32): usize {
  return 24 + s.mt[i].off;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 { return 0; }
