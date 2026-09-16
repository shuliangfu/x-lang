// F7 leftover: PTR-outer `*[2][]i32` extra + by-value NAMED `self.v`
// (sit-red dyn extra 139; named / UFCS without `self.v` already 7).
// Produce: same w189 stack_off→param-index miss as dyn extra `*i32`
// (self home 16 classified as param 1 when that extra is TYPE_PTR).
// Not dest extras dest-PTR dest-stamp: ADDR_OF of typed `[2][]i32`
// already has the formal type; dyn extra without `self.v` is 7.
// G.7: complete w189 walk (no second dest-PTR stamp / no -3).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (*p)[0][0] + (*p)[1][0] = 1+2+4).
// ADDR_OF of typed `[2][]i32`. Nested `&[[2],[4]]` is CG002 (addr of
// temporary) — not this leaf.
// Neighborhood: dyn_add_ptr.x (`*i32`) / dyn_add_slice_ptr_arr_slice.x
// (`[]*[2][]i32`) / dyn_add_arr_slice.x (`[2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPAS {
  function sumpas(self, p: *[2][]i32): i32;
}
struct A { v: i32 }
impl SumPAS for A {
  function sumpas(self: A, p: *[2][]i32): i32 {
    let x: i32 = unsafe { (*p)[0][0] };
    let y: i32 = unsafe { (*p)[1][0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPAS = a;
  let row: [2][]i32 = [[2], [4]];
  return x.sumpas(&row);
}
