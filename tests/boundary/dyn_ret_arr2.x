// F7 leftover: dyn ret `[2][2]i32` (sit-red XT001 expected [2][2]i32
// found [2]i32). Produce: typeck TYPE_DYN ret ARRAY reconstructs
// find_or_alloc_array(elem, ret_array_size) — outer N only.
// Registry already stores method_ret_array_ndims=2 + dims[0]=2, dims[1]=2.
// G.7: complete existing dyn ret ARRAY block (ret_array_ndims /
// ret_array_dim + wrap innermost first). No second resolve.
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0 (XT001 gone). host-C run = 10 (1+2+3+4).
// asm dest `[K][N]T` copy leftover is NOT this leaf (named-local
// non-dyn `[2][2]i32` ret also run=3 on Darwin).
// Neighborhood: dyn_ret_arr.x ([2]i32) / dyn_add_arr2.x ([2][2]i32 extra).
// PLATFORM: SHARED — Ubuntu gold.

trait Get22 {
  function get22(self): [2][2]i32;
}
struct A { v: i32 }
impl Get22 for A {
  function get22(self: A): [2][2]i32 {
    let t: [2][2]i32 = [[self.v, 2], [3, 4]];
    return t;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn Get22 = a;
  let r: [2][2]i32 = x.get22();
  return r[0][0] + r[0][1] + r[1][0] + r[1][1];
}
