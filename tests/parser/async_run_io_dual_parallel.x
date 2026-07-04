// async_run_io_dual_parallel.x — IO-A5：两次 run 读 fd 3/4（与 dual_pipe 同类全链路）
// 由 async_run_io_dual_pipe_wrapper.c 在 fd 3/4 注入 pipe 后 exec。
extern function read_fd(fd: i32, ptr: *u8, len: usize): i32;

/** 读 pipe A（独立 static 帧）。 */
async function read_a(fd: i32): i32 {
  let buf: u8[8] = [];
  let n: i32 = await read_fd(fd, buf as *u8, 8);
  return n;
}

/** 读 pipe B（独立 static 帧；与 read_a 并行 in-flight）。 */
async function read_b(fd: i32): i32 {
  let buf: u8[8] = [];
  let n: i32 = await read_fd(fd, buf as *u8, 8);
  return n;
}

function main(): i32 {
  /* 顺序 run 两协程（与 dual_pipe 相同调度语义；spawn 并行见 async_run_io_spawn_parallel.c 烟测）。 */
  let n1: i32 = run read_a(3);
  let n2: i32 = run read_b(4);
  if (n1 + n2 != 5) {
    return 1;
  }
  return 0;
}
