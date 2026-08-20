// F7 leftover: host-C dyn ret `*[2]i32` (sit-red void-cast assignment).
// Produce: typeck TYPE_DYN ret PTR skips elem kind 10 so `*[2]i32` has
// no type_ref; call-site emit_type_kind(VOID).
// Store: registry ret_elem_kind=ARRAY + ret_elem_elem_kind +
// ret_elem_array_ndims/dims (skip-trait wave438 `*[N]T` already stores).
// Consume: host-C `int32_t (*p)[2] = (void)call`. emit_type already
// emits abstract `E (*)[N]` once the call is dest-stamped.
// G.7: complete dyn ret PTR block (elem_elem + elem_array wrap then
// wrap ptr). No second resolve. Wrapper rdi/x0 = data unchanged.
// Do not deref `p`: impl returns &self.p of a by-value self (dangling).
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr.x / dyn_ret_arr.x / dyn_ret_arr2.x.
// PLATFORM: SHARED — Ubuntu gold.

trait GetPA {
  function getpa(self): *[2]i32;
}
struct A { v: i32, p: [2]i32 }
impl GetPA for A {
  function getpa(self: A): *[2]i32 {
    return &self.p;
  }
}
function main(): i32 {
  let a: A = { v: 1, p: [2, 4] };
  let x: GetPA = a;
  let p: *[2]i32 = x.getpa();
  return 7;
}
