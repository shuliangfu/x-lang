// F7 leftover: dest extras dest-ARRAY of SLICE extra `[2][][2]i32`
// dest-stamp (sit-red dyn extra nested ARRAY_LIT run=139). Produce:
// dest extras dest-ARRAY-of-SLICE wrapped slice of leaf once so dest
// was `[2][]i32` not `[2][][2]i32`. Nested `[[[2, 3]], [[1, 4]]]`
// stayed unstamped. Store: skip-trait after `[N][]` then `[M]`
// already keeps elem=SLICE + eek=leaf + ndims>=1 + dims[0]=M
// (wave437 pending LBRACKET dim collector; extra PTR stays ndims==0
// dims[0]; extra SLICE stays ndims=-2; ban -3 / new field). Consume:
// dest extras wrap ARRAY of leaf inner-first then wrap SLICE then
// ARRAY. Named / UFCS / asg / typed lets already dest-stamp via the
// formal (7). Impl-match leftover SLICE vs eek=SLICE is not T001
// (do not add extra ARRAY peels). Neighborhood `[2][]i32` already
// 7; `[][2]i32` already 7; `[2][][]i32` already 6. `[][][2]i32`
// dest extras dest-SLICE-of-SLICE extra ARRAY stays deferred (T001).
// G.7: complete dest extras dest-ARRAY-of-SLICE extra ARRAY wraps
// (no second dest-ARRAY stamp; do not invent -3). Wrapper rdi/x0 =
// data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0][0] + p[1][0][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_arr_slice.x (`[2][]i32`) /
// dyn_add_slice_arr.x (`[][2]i32`) /
// dyn_add_arr_slice_slice.x (`[2][][]i32`) /
// dyn_add_arr_slice_ptr.x (`[2][]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumASA {
  function sumasa(self, p: [2][][2]i32): i32;
}
struct A { v: i32 }
impl SumASA for A {
  function sumasa(self: A, p: [2][][2]i32): i32 {
    return self.v + p[0][0][0] + p[1][0][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumASA = a;
  return x.sumasa([[[2, 3]], [[1, 4]]]);
}
