// F7 next-wave: dest-ARRAY extra `[2]*[2]i32` (PTR-to-ARRAY elem of dest-ARRAY).
// dest-ARRAY scanner skips elem kind 9 (PTR) — L14779 "Remaining leftover:
// PTR/VECTOR elem of dest-ARRAY". `[2]*Pair` already 7 (ADDR_OF elems, no
// reconstruct needed). This probe tests `[2]*[2]i32` (PTR-to-ARRAY elem):
// ARRAY_LIT `[&r0, &r1]` elems are ADDR_OF of `[2]i32` locals → `*[2]i32`.
// If ADDR_OF elems match the trait formal elem_kind=PTR without reconstruct,
// this should be 7 (twin of `[2]*Pair`). If not, dest-ARRAY-of-PTR path needs
// the same ndims wrap as dest-SLICE-of-PTR (L14612).
// Expected: compile = 0, run = 6 (v + (*p[0])[0] + (*p[1])[0] = 1+2+3).
// Neighborhood: dyn_add_slice_ptr_arr.x ([]*[2]i32) / dyn_add_arr_slice.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumAPA {
  function sumapa(self, p: [2]*[2]i32): i32;
}
struct A { v: i32 }
impl SumAPA for A {
  function sumapa(self: A, p: [2]*[2]i32): i32 {
    let x: i32 = unsafe { (*p[0])[0] };
    let y: i32 = unsafe { (*p[1])[0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumAPA = a;
  let r0: [2]i32 = [2, 4];
  let r1: [2]i32 = [3, 5];
  return x.sumapa([&r0, &r1]);
}
