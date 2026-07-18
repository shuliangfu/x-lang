// See implementation.
#[repr(C)]
struct Header {
  tag: u8
  len: u32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let h: Header = Header { tag: 1, len: 42 };
  /* See implementation. */
  return (h.tag as i32) + (h.len as i32);
}
