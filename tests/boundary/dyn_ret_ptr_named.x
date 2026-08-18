// F7 leftover: host-C trait ret `*Pair` (sit-red void-cast assignment).
// Produce: typeck skipped PTR-to-NAMED (ret_kind=9, ret_elem=8) so the
// call-site cast was void. Registry already stores ret_name="Pair".
// G.7: complete existing dyn ret stamp (ret_name + find_or_alloc_named
// + find_or_alloc_ptr). No second wrapper. Wrapper rdi/x0 = data
// unchanged. Do not deref `p`: impl returns &self.p of a by-value
// self (dangling). Expected: compile = 0, run = 7 (assign-only).
// Neighborhood: dyn_ret_ptr.x (*i32) / dyn_ret_named.x (Pair) /
// dyn_ret_slice_named.x ([]Pair) / dyn_ret_arr_named.x ([2]Pair).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPP {
  function getpp(self): *Pair;
}
struct Pair { a: i32, b: i32 }
struct A { p: Pair }
impl GetPP for A {
  function getpp(self: A): *Pair {
    return &self.p;
  }
}
function main(): i32 {
  let a: A = { p: { a: 1, b: 6 } };
  let x: dyn GetPP = a;
  let p: *Pair = x.getpp();
  return 7;
}
