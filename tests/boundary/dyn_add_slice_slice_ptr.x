// F7 leftover: dest extras dest-SLICE of SLICE extra `[][]*i32`
// dest-stamp (sit-red dyn extra nested ARRAY_LIT run=139). Produce:
// dest extras dest-SLICE-of-SLICE wrapped slice of leaf twice so dest
// was `[][]i32` not `[][]*i32`. Extra STAR after `[][]` was ARRAY-
// outer only (`[2][]*T`); eek unset so dest extras skipped extra PTR
// (named / UFCS dest-stamp via the formal 7). Store-only capturing
// leaf is T001 (impl-match leftover PTR vs eeek=leaf). Nested
// `[[&n, &m]]` stayed unstamped. Store: keep elem=SLICE + eek=leaf +
// ndims=0; extra PTR wrap COUNT in unused slot dims[0] (1 =
// `[][]*T`; 0 = no extra PTR = `[][]i32`; extra SLICE stays
// ndims=-2; ban -3 / new field). Consume: dest extras wrap PTR of
// leaf extra times then wrap SLICE twice; impl-match extra PTR peels
// leftover PTR after leftover SLICE. Outer SLICE so `[2][]*T` stays
// the dest-ARRAY path (same dims[0] extra PTR encoding; discriminant
// is param kind). `[][][]*T` ndims==-2 extra STAR stays deferred.
// G.7: complete skip-trait store + impl-match extra PTR peel + dest
// extras dest-SLICE-of-SLICE extra PTR wraps (no second dest-SLICE
// stamp; do not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0] + *p[0][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_slice_slice.x (`[][]i32`) /
// dyn_add_arr_slice_ptr.x (`[2][]*i32`) /
// dyn_add_slice_arr_ptr.x (`[][2]*i32`) /
// dyn_add_slice_ptr.x (`[]*i32`) /
// dyn_add_slice_slice_slice.x (`[][][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSPtr {
  function sumssp(self, p: [][]*i32): i32;
}
struct A { v: i32 }
impl SumSSPtr for A {
  function sumssp(self: A, p: [][]*i32): i32 {
    let x: i32 = unsafe { *p[0][0] };
    let y: i32 = unsafe { *p[0][1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSSPtr = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumssp([[&n, &m]]);
}
