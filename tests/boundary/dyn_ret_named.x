// F7 leftover: host-C trait ret `Pair` (sit-red void-cast assignment).
// Produce: typeck skipped kind 8 so the call-site cast was void;
// wrapper already emit_type(impl ret) (`static struct Pair wrap`).
// G.7: complete existing dyn ret stamp (ret_name + find_or_alloc_named)
// + call-site emit_type when type_ref exists. No second wrapper.
// Wrapper rdi/x0 = data unchanged. asm already 7.
// Expected: compile = 0, run = 7 (r.a+r.b = 1+6).
// Neighborhood: dyn_ret_arr.x / dyn_ret_slice.x / dyn_ret_ptr.x.
// PLATFORM: SHARED — Ubuntu gold.

trait GetP {
  function getp(self): Pair;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl GetP for A {
  function getp(self: A): Pair {
    return { a: self.v, b: 6 };
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn GetP = a;
  let r: Pair = x.getp();
  return r.a + r.b;
}
