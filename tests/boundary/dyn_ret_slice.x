// F7 leftover: host-C trait ret `[]i32` (sit-red XP003 entry-module emit).
// Produce: same as dyn_ret_arr.x — emit_type_kind(SLICE) failed; typeck
// skipped kind 11 so the dyn call resolved as 0. G.7 complete wrapper
// emit_type + ret_elem_kind slice stamp + call-site emit_type.
// Do not name the method `gets` (host-C clashes with libc gets).
// Expected: compile = 0, run = 7 (r[0]+r[1] = 1+6).
// Neighborhood: dyn_ret_arr.x (`[2]i32` ret), dyn_add_slice.x (`[]i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait GetSl {
  function getsl(self): []i32;
}
struct A { v: i32 }
impl GetSl for A {
  function getsl(self: A): []i32 {
    let t: [2]i32 = [self.v, 6];
    return t;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: GetSl = a;
  let r: []i32 = x.getsl();
  return r[0] + r[1];
}
