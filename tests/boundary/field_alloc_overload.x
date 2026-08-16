// Isolated green: import-qualified FIELD as 2-arg heap.alloc overload arg.
// typeck: last-segment concrete so `h.al` scores as Allocator (not first-wins
// `alloc(i32):*u64`). asm `-o`: 16B FIELD call-arg dual-GP via deref_struct16
// → load_qword_*_arch (ARM64 ldr x0,[x1] / ldr x1,[x1,#8]).
// Gate = typeck + host-C `-E` 2-arg mangle + product `-o` run 0.
// PLATFORM: SHARED — Ubuntu gold typeck; MACOS|ARM64 dual-GP emit.

const heap = import("std.heap");

allow(padding) struct Holder {
  al: heap.Allocator;
}

/**
 * Allocate via FIELD `h.al` (not a let-bound Allocator) and free.
 * @return i32 — 0 ok, 1 alloc failed
 */
export function main(): i32 {
  let h: Holder = { al: heap.default_alloc() };
  let p: *u8 = heap.alloc(h.al, 8 as usize);
  if (p == 0) { return 1; }
  heap.free(h.al, p);
  return 0;
}
