// F7 leftover: host-C trait ret `[]Pair` (sit-red void-cast assignment).
// Produce: typeck skipped SLICE-of-NAMED (ret_kind=11, ret_elem=8) so
// the call-site cast was void. Registry already stores ret_name="Pair".
// G.7: complete existing dyn ret stamp (ret_name + find_or_alloc_named
// + find_or_alloc_slice). No second wrapper. Wrapper rdi/x0 = data
// unchanged. asm already 7 via dest-let. Expected: compile = 0,
// run = 7 (r[0].a + r[0].b = 1+6).
// Neighborhood: dyn_ret_slice.x ([]i32) / dyn_ret_ptr_named.x (*Pair).
// PLATFORM: SHARED — Ubuntu gold.

trait GetSP {
  function getsp(self): []Pair;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl GetSP for A {
  function getsp(self: A): []Pair {
    let t: [1]Pair = [{ a: self.v, b: 6 }];
    return t;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: GetSP = a;
  let r: []Pair = x.getsp();
  return r[0].a + r[0].b;
}
