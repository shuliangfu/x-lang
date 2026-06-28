// MEM-D2.2：ASP 别名正例 — 块内 q = p 后 consumer 读字段，仍 stack promote。
const heap = import("std.heap");

struct Pair {
  a: i32
  b: i32
}

function make_pair_arena(al: Allocator, x: i32, y: i32): *Pair {
  let raw: *u8 = heap.alloc(al, 8 as usize);
  let p: *Pair = raw as *Pair;
  p.a = x;
  p.b = y;
  return p;
}

function sum_pair_ptr(p: *Pair): i32 {
  return p.a + p.b;
}

function main(): i32 {
  with_arena(4096) {
    let p: *Pair = make_pair_arena(heap.scope_alloc(), 3, 4);
    let q: *Pair = p;
    return sum_pair_ptr(q);
  }
  return 0;
}
