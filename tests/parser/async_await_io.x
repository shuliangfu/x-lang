// async_await_io.x — IO-A5 v1：`await read(...)` → submit_read_async + suspend_io + complete
extern function read(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32;

/* See implementation. */
async function io_read_demo(): i32 {
  let buf: u8[8] = [];
  let n: i32 = await unsafe { read(0, buf as *u8, 8, 0) };
  return n;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return io_read_demo();
}
