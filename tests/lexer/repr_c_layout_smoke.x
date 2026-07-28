// See implementation.
#[repr(C)]
struct Header {
  tag: u8
  length: u32
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let h: Header = Header { tag: 1, length: 42 };
  /* See implementation. */
  return (h.tag as i32) + (h.length as i32);
}
