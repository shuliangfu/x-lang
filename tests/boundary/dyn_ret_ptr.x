// F7 leftover: host-C trait ret `*i32` (sit-red void-cast assignment).
// Produce: typeck skipped kind 9 so the call-site cast was void.
// G.7: complete existing dyn ret stamp (ret_elem_kind + find_or_alloc_ptr)
// + call-site emit_type. No second wrapper. Wrapper rdi/x0 = data unchanged.
// Do not deref `p`: impl returns &self.v of a by-value self (dangling).
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_named.x / dyn_ret_arr.x.
// PLATFORM: SHARED — Ubuntu gold.

trait GetI {
  function geti(self): *i32;
}
struct A { v: i32 }
impl GetI for A {
  function geti(self: A): *i32 {
    return &self.v;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn GetI = a;
  let p: *i32 = x.geti();
  return 7;
}
