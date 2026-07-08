// NL-04：Linux freestanding 读文件 + mmap 堆缓冲 + stdout（零 libc / 无 fs.c）。
//
// 【Why 自包含】与 linux_heap_mmap_smoke.x 同理：freestanding -backend asm 路径下
// import dep 模块触发 codegen.x 前缀化问题。直接内联 heap + fs read 逻辑 + 直声明
// extern syscall，单入口模块无 import。freestanding_io_x86_64.s 按需链入。

extern function shux_sys_mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;
extern function shux_sys_munmap(addr: *u8, len: usize): i32;
extern function shux_sys_write(fd: i32, buf: *u8, len: i32): i32;
extern function shux_sys_open(path: *u8, flags: i32, mode: i32): i32;
extern function shux_sys_read(fd: i32, buf: *u8, len: i32): i32;
extern function shux_sys_close(fd: i32): i32;

allow(padding) struct PageMmapHeap {
  base: *u8;
  cap: usize;
  off: usize;
}

function page_mmap_heap_init(h: *PageMmapHeap): i32 {
  if (h == 0) {
    return -1;
  }
  h.base = 0 as *u8;
  h.cap = 0;
  h.off = 0;
  let p: *u8 = 0 as *u8;
  unsafe {
    p = shux_sys_mmap(0 as *u8, 65536 as usize, 3 as i32, 0x22 as i32, -1, 0 as i64);
  }
  // 指针比较规避 ASM 后端 i64 cmp 截断 bug（详见 linux_heap_mmap_smoke.x）。
  if (p == 0 as *u8) {
    return -1;
  }
  h.base = p;
  h.cap = 65536 as usize;
  h.off = 0;
  return 0;
}

function page_mmap_heap_alloc(h: *PageMmapHeap, size: usize, align_bytes: usize): *u8 {
  if (h == 0 || h.base == 0 || size == 0) {
    return 0;
  }
  let a: usize = align_bytes;
  if (a == 0) {
    a = 1;
  }
  let start: usize = ((h.off + a - 1) / a) * a;
  let end: usize = start + size;
  if (end > h.cap || end < start) {
    return 0;
  }
  let out: *u8 = h.base + start;
  h.off = end;
  return out;
}

function page_mmap_heap_deinit(h: *PageMmapHeap): void {
  if (h == 0) {
    return;
  }
  if (h.base != 0 && h.cap > 0) {
    unsafe {
      shux_sys_munmap(h.base, h.cap);
    }
  }
  h.base = 0 as *u8;
  h.cap = 0;
  h.off = 0;
}

// 读整文件到 buf[0..cap)（循环 read 至 EOF 或 cap）；成功返回字节数，失败 -1。
function read_file_into(path: *u8, buf: *u8, cap: i32): i32 {
  if (path == 0 || buf == 0 || cap <= 0) {
    return -1;
  }
  let fd: i32 = 0;
  unsafe {
    fd = shux_sys_open(path, 0, 0);
  }
  if (fd < 0) {
    return -1;
  }
  let total: i32 = 0;
  while (total < cap) {
    let chunk: i32 = cap - total;
    let dst: *u8 = buf + total;
    let r: i32 = 0;
    unsafe {
      r = shux_sys_read(fd, dst, chunk);
    }
    if (r < 0) {
      unsafe {
        shux_sys_close(fd);
      }
      return -1;
    }
    if (r == 0) {
      break;
    }
    total = total + r;
  }
  unsafe {
    shux_sys_close(fd);
  }
  return total;
}

function main(): i32 {
  // "/tmp/shux_nolibc_fs_gate.txt\0"
  let path: u8[32] = [
    47, 116, 109, 112, 47, 115, 104, 117, 120, 95, 110, 111, 108, 105, 98, 99,
    95, 102, 115, 95, 103, 97, 116, 101, 46, 116, 120, 116, 0, 0, 0, 0,
  ];
  let h: PageMmapHeap = PageMmapHeap {
    base: 0 as *u8,
    cap: 0 as usize,
    off: 0 as usize,
  };
  if (page_mmap_heap_init(&h) != 0) {
    return 3;
  }
  let buf: *u8 = page_mmap_heap_alloc(&h, 16 as usize, 8 as usize);
  if (buf == 0 as *u8) {
    page_mmap_heap_deinit(&h);
    return 4;
  }
  let n: i32 = read_file_into(&path[0], buf, 16);
  if (n != 2) {
    page_mmap_heap_deinit(&h);
    return 5;
  }
  if (buf[0] != 70 as u8 || buf[1] != 83 as u8) {
    page_mmap_heap_deinit(&h);
    return 6;
  }
  let w: i32 = shux_sys_write(1, buf, n);
  if (w != n) {
    page_mmap_heap_deinit(&h);
    return 7;
  }
  page_mmap_heap_deinit(&h);
  return 0;
}
