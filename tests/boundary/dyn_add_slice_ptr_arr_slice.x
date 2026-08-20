// F7 leftover: dest extras dest-SLICE of PTR extra `[]*[2][]i32`
// dest-stamp (sit-red dyn extra ADDR_OF of typed `[2][]i32` run=1
// panic: 0 / host-C 133). Produce: extra empty `[]` after `[]*` then
// `[N]` set elem_kind=-1 so dest extras dest-SLICE-of-PTR never
// extra-wrapped SLICE after ARRAY (dest would be `[]*[2]i32`).
// Named / UFCS dest-stamp via the formal (7). Store: keep elem=PTR
// + eek=leaf + ndims>=1 + dims[0]=N; extra wrap COUNT in unused
// slot dims[ndims] (1 = `[]*[2][]T`; 2 = `[]*[2][][]T`; 0 means no
// extra wrap = `[]*[2]i32`; ban -3 / new field). Discriminant vs
// dest extras dest-SLICE-of-ARRAY extra `[][2][]T` is elem_kind
// (PTR vs ARRAY). Consume: dest extras wrap SLICE of leaf extra
// times THEN wrap ARRAY THEN wrap PTR THEN outer SLICE. SLICE-
// outer PTR-elem impl-match does not walk leftover SLICE (not
// T001 — do not mix a third produce). Outer must stay SLICE so
// `*[N][]T` stays deferred. G.7: complete skip-trait extra empty
// `[]` unused-slot scanner (ARRAY or PTR elem) + dest extras dest-
// SLICE-of-PTR extra SLICE wraps (no second dest-SLICE stamp; do
// not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (*p[0])[0][0] + (*p[0])[1][0]
// = 1+2+4). ADDR_OF of typed `[2][]i32` so dest extras dest-stamp
// fires (nested `[[[2],[4]]]` is `[][2][]T`, wrong dest shape).
// Neighborhood: dyn_add_slice_ptr_arr.x (`[]*[2]i32`) /
// dyn_add_slice_arr_slice.x (`[][2][]i32`) /
// dyn_add_slice_ptr_slice.x (`[]*[]i32`) /
// dyn_add_slice_ptr_slice_slice.x (`[]*[][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSPAS {
  function sumspas(self, p: []*[2][]i32): i32;
}
struct A { v: i32 }
impl SumSPAS for A {
  function sumspas(self: A, p: []*[2][]i32): i32 {
    let x: i32 = unsafe { (*p[0])[0][0] };
    let y: i32 = unsafe { (*p[0])[1][0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSPAS = a;
  let row: [2][]i32 = [[2], [4]];
  return x.sumspas([&row]);
}
