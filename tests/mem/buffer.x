// See implementation.
const mem = import("std.mem");

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  let b: Buffer = Buffer { ptr: 0, length: 0, handle: 0 }
  return mem.register_buffer(b);
}
