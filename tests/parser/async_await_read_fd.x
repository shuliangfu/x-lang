// async_await_read_fd.x — IO-A5 v1：await read_fd(...) → submit_read_async + complete
extern function read_fd(fd: i32, ptr: *u8, len: usize): i32;

/* See implementation. */
async function io_read_fd_demo(): i32 {
  let buf: u8[8] = [];
  let n: i32 = await unsafe { read_fd(0, buf as *u8, 8) };
  return n;
}

/** Internal function `main`.
 * Program/test entry point.
 * @return i32
 */
function main(): i32 {
  return io_read_fd_demo();
}
