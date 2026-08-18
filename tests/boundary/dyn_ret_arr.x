// F7 leftover: host-C trait ret `[2]i32` (sit-red XP003 entry-module emit).
// Produce: wrapper used emit_type_kind(ret_kind=ARRAY) which returns -1;
// typeck left dyn METHOD resolved=0 so the call-site cast was void.
// G.7: complete existing wrapper (emit_type of impl ret) + dyn ret stamp
// (ret_elem_kind + find_or_alloc_array) + call-site emit_type. No second
// wrapper. Wrapper rdi/x0 = data unchanged. asm already 7.
// Expected: compile = 0, run = 7 (r[0]+r[1] = 1+6).
// Neighborhood: dyn_ret_slice.x (`[]i32` ret), dyn_add_arr1.x (`[2]i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait Get2 {
  function get2(self): [2]i32;
}
struct A { v: i32 }
impl Get2 for A {
  function get2(self: A): [2]i32 {
    let t: [2]i32 = [self.v, 6];
    return t;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn Get2 = a;
  let r: [2]i32 = x.get2();
  return r[0] + r[1];
}
