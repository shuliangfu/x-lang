// Isolated green: import-qualified FIELD as 2-arg heap.alloc overload arg.
// `let p: *u8 = heap.alloc(h.al, n)` used to T001: apply_ambient treated
// TYPE_NAMED `heap.Allocator` as a free type-param (exact name != layout
// `Allocator`) and stamped the CALL return `*u8` onto the field → score -1
// → first_idx `alloc(i32):*u64`. Same-module FIELD already greened.
// Gate = typeck + host-C `-E` (formal_mod path): must emit
// `std_heap_alloc_Allocator_usize(((h).al), …)`. Product `-o` asm
// still CG002 on struct-field-by-value (separate emit residual).
// Expected: -E = 0 and 2-arg mangle present.
// PLATFORM: SHARED — Ubuntu gold typeck pick.

const heap = import("std.heap");

allow(padding) struct Holder {
  al: heap.Allocator;
}

/**
 * Allocate via FIELD `h.al` (not a let-bound Allocator) and free.
 * @return i32 — 0 ok, 1 alloc failed
 */
export function main(): i32 {
  let h: Holder = Holder { al: heap.default_alloc() };
  let p: *u8 = heap.alloc(h.al, 8 as usize);
  if (p == 0) { return 1; }
  heap.free(h.al, p);
  return 0;
}
