// STD-112：std.heap Allocator trait + Vec_u8 接入烟测
const heap = import("std.heap");
const vec = import("std.vec");

function main(): i32 {
  let al: heap.Allocator = heap.heap_alloc();
  let v: Vec_u8 = vec.new();
  if (vec.with_alloc(&v, al, 4) != 0) {
    return 1;
  }
  if (vec.push(&v, al, 65) != 0) {
    vec.deinit(&v, al);
    return 2;
  }
  if (vec.push(&v, al, 66) != 0) {
    vec.deinit(&v, al);
    return 3;
  }
  if (vec.len(v) != 2) {
    vec.deinit(&v, al);
    return 4;
  }
  if (v.ptr[0] != 65 || v.ptr[1] != 66) {
    vec.deinit(&v, al);
    return 5;
  }
  vec.deinit(&v, al);

  let ar: heap.Arena64 = heap.arena64_empty();
  if (heap.arena64_init(&ar, 512 as usize) != 0) {
    return 6;
  }
  let al2: heap.Allocator = heap.from_arena(&ar);
  let p: *u8 = heap.alloc(al2, 16 as usize);
  if (p == 0 as *u8) {
    heap.arena64_deinit(&ar);
    return 7;
  }
  p[0] = 67;
  heap.free(al2, p);
  let v2: Vec_u8 = vec.new();
  if (vec.with_alloc(&v2, al2, 8) != 0) {
    heap.arena64_deinit(&ar);
    return 8;
  }
  if (vec.push(&v2, al2, 68) != 0) {
    vec.deinit(&v2, al2);
    heap.arena64_deinit(&ar);
    return 9;
  }
  if (vec.len(v2) != 1 || v2.ptr[0] != 68) {
    vec.deinit(&v2, al2);
    heap.arena64_deinit(&ar);
    return 10;
  }
  vec.deinit(&v2, al2);
  heap.arena64_deinit(&ar);
  return 0;
}
