// F7 leftover: host-C trait ret `[2]Pair` (sit-red memcpy of void-cast).
// Produce: typeck skipped ARRAY-of-NAMED (ret_kind=10, ret_elem=8) so
// the call-site cast was void. Registry already stores ret_name="Pair"
// + ret_array_size=2. G.7: complete existing dyn ret stamp (ret_name +
// find_or_alloc_named + find_or_alloc_array). No second wrapper.
// Wrapper rdi/x0 = data unchanged. asm already 5 via dest-let.
// Expected: compile = 0, run = 5 (r[0].a + r[1].b = 1+4).
// Neighborhood: dyn_ret_arr.x ([2]i32) / dyn_ret_ptr_named.x (*Pair).
// `[K][N]T` ndims leftover is not this leaf.
// PLATFORM: SHARED — Ubuntu gold.

trait GetAP {
  function getap(self): [2]Pair;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl GetAP for A {
  function getap(self: A): [2]Pair {
    let t: [2]Pair = [{ a: self.v, b: 2 }, { a: 3, b: 4 }];
    return t;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: GetAP = a;
  let r: [2]Pair = x.getap();
  return r[0].a + r[1].b;
}
