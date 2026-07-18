// async_await_io_write.x — IO-A5 v1：await write(...) → submit_write_async + suspend_io + complete
extern function write(handle: usize, ptr: *u8, len: usize, timeout_ms: u32): i32;

/* See implementation. */
async function io_write_demo(): i32 {
  let msg: u8[4] = [104, 105, 10, 0];
  let n: i32 = await unsafe { write(1, msg as *u8, 3, 0) };
  return n;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return io_write_demo();
}
