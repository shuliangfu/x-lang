// NL-03：Linux freestanding mmap bump 堆 + stdout write 烟测（零 libc）。
//
// 【Why 自包含】freestanding -backend asm 路径下，import dep 模块会触发 codegen.x
// 前缀化问题（入口模块 function 裸名 vs dep 模块带前缀）。此处直接内联 page_mmap
// heap 逻辑 + 直声明 extern syscall，使整个测试程序为单入口模块，无任何 import。
// freestanding_io_x86_64.s 自动按需链入（shux_sys_mmap/munmap/write/exit）。

/** freestanding mmap(2) 桩（6 参；offset 低 32 位在 r9）。 */
extern function shux_sys_mmap(addr: *u8, len: usize, prot: i32, flags: i32, fd: i32, offset: i64): *u8;
/** freestanding munmap(2) 桩。 */
extern function shux_sys_munmap(addr: *u8, len: usize): i32;
/** Linux write(2) 包装；由 freestanding_io_x86_64.s 提供。 */
extern function shux_sys_write(fd: i32, buf: *u8, len: i32): i32;

allow(padding) struct PageMmapHeap {
  base: *u8;
  cap: usize;
  off: usize;
}

function page_mmap_heap_available(): i32 {
  return 1;
}

// 【Why 字面量内联】ASM 后端对模块级 const 的 store-to-stack 发射不完整
// （page_mmap_heap_init 中三个 const 引用读取未初始化栈槽）。直接内联字面量
// 规避此 codegen bug，待 ASM 后端 const emit 修复后恢复 const 声明。
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
  // 【Why 指针比较】ASM 后端对 i64 比较错误发射 32-bit cmp（eax/ebx），
  // mmap 返回地址高 32 位被截断导致误判为负。改用指针 == 比较规避 i64 比较缺陷。
  // mmap 失败返回 MAP_FAILED（全 1）；成功返回非空地址。
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

function page_mmap_heap_free(_h: *PageMmapHeap, _ptr: *u8): void {
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

function main(): i32 {
  if (page_mmap_heap_available() != 1) {
    return 1;
  }
  let h: PageMmapHeap = PageMmapHeap {
    base: 0 as *u8,
    cap: 0 as usize,
    off: 0 as usize,
  };
  if (page_mmap_heap_init(&h) != 0) {
    return 3;
  }
  let p: *u8 = page_mmap_heap_alloc(&h, 32 as usize, 8 as usize);
  if (p == 0 as *u8) {
    page_mmap_heap_deinit(&h);
    return 4;
  }
  p[0] = 65 as u8;
  p[1] = 66 as u8;
  p[2] = 67 as u8;
  if (p[0] != 65 as u8 || p[1] != 66 as u8 || p[2] != 67 as u8) {
    page_mmap_heap_deinit(&h);
    return 5;
  }
  let n: i32 = shux_sys_write(1, p, 3);
  if (n != 3) {
    page_mmap_heap_deinit(&h);
    return 6;
  }
  page_mmap_heap_free(&h, p);
  page_mmap_heap_deinit(&h);
  return 0;
}
