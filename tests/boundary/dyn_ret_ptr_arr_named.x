// F7 leftover: host-C dyn ret `*[2]Pair` (sit-red dest-cast of void).
// Produce: dest ret PTR-to-ARRAY skips NAMED leaf (dyn_reek==8) so
// dyn_ret_ty stays 0; call-site emit_type_kind(VOID) →
// `(void(*)(void*))`. Ubuntu gcc then rejects dest-cast of a void
// expression (`invalid use of void expression`); mac clang
// false-greens run=7. Store: skip-trait wave438 `*[N]T` already stores
// ret_kind=PTR + ret_elem=ARRAY + ret_elem_elem=NAMED + ret_name="Pair"
// + ret_elem_array ndims/dims. Consume: host-C dest let `E (*p)[N]` +
// emit_type peel to first-element `E *` (same as `*[2]i32`).
// G.7: complete dest ret PTR-to-ARRAY (ret_name wrap named then
// existing ARRAY wrap + wrap ptr). No second dest-ret resolve.
// Wrapper rdi/x0 = data unchanged. asm already 7 via dest-let.
// Do not deref `p`: impl returns &self.p of a by-value self (dangling).
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_arr.x (`*[2]i32`) / dyn_ret_ptr_named.x
// (`*Pair`) / dyn_ret_arr_named.x (`[2]Pair`).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPAP {
  function getpap(self): *[2]Pair;
}
struct Pair { a: i32, b: i32 }
struct A { p: [2]Pair }
impl GetPAP for A {
  function getpap(self: A): *[2]Pair {
    return &self.p;
  }
}
function main(): i32 {
  let a: A = { p: [{ a: 2, b: 4 }, { a: 0, b: 0 }] };
  let x: GetPAP = a;
  let p: *[2]Pair = x.getpap();
  return 7;
}
