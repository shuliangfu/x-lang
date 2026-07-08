// NL-02：Linux freestanding socket(2)+close(2) 烟测（零 libc）。
//
// 【Why 自包含】与 linux_heap_mmap_smoke.x 同理：freestanding -backend asm 路径下
// import dep 模块触发 codegen.x 前缀化问题。直接声明 extern syscall，单入口模块。

extern function shux_sys_socket(domain: i32, sock_type: i32, protocol: i32): i32;
extern function shux_sys_close(fd: i32): i32;

function main(): i32 {
  let fd: i32 = 0;
  unsafe {
    fd = shux_sys_socket(2, 1, 0);
  }
  if (fd < 0) {
    return 2;
  }
  let rc: i32 = 0;
  unsafe {
    rc = shux_sys_close(fd);
  }
  if (rc != 0) {
    return 3;
  }
  return 0;
}
