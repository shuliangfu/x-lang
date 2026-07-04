// async_await_write_fd.x — IO-A5 v1：`await write_fd(...)` → submit_write_async + complete
extern function write_fd(fd: i32, ptr: *u8, len: usize): i32;

/** await 向 fd 写；codegen 将 fd 转为 handle。 */
async function io_write_fd_demo(): i32 {
  let msg: u8[4] = [72, 73, 33, 10];
  let n: i32 = await write_fd(1, msg as *u8, 4);
  return n;
}

function main(): i32 {
  return io_write_fd_demo();
}
