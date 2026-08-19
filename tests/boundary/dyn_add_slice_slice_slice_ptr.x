// F7 leftover: dest extras dest-SLICE of SLICE extra `[][][]*i32`
// dest-stamp (sit-red dyn extra nested ARRAY_LIT run=139). Produce:
// extra STAR after `[][][]` (ndims==-2) set elem_kind=-1 so dest
// extras dest-SLICE-of-SLICE never entered; store-only capturing
// leaf is T001 (impl-match leftover PTR vs eeek=leaf after extra
// SLICE peels). Named / UFCS / module-func / assign dest-stamp via
// the formal (7). Store: keep elem=SLICE + eek=leaf + ndims=-2;
// extra SLICE wrap COUNT stays dims[0]; extra PTR wrap COUNT in
// unused slot dims[1] (1 = `[][][]*T`; 0 = no extra PTR =
// `[][][]T`; ban -3 / reuse of dims[0]). Consume: dest extras wrap
// PTR of leaf extra times then wrap SLICE twice then extra SLICE
// wraps; impl-match extra PTR peels leftover PTR after extra SLICE
// peels. Outer SLICE so `[2][][]*T` stays deferred. Extra wrap
// `[][][][]*T` is covered by extra SLICE count in dims[0].
// G.7: complete skip-trait store + impl-match extra PTR peel + dest
// extras dest-SLICE-of-SLICE extra PTR wraps (no second dest-SLICE
// stamp; do not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0][0] + *p[0][0][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_slice_slice_ptr.x (`[][]*i32`) /
// dyn_add_slice_slice_slice.x (`[][][]i32`) /
// dyn_add_slice_slice_slice_slice.x (`[][][][]i32`) /
// dyn_add_slice_slice_arr.x (`[][][2]i32`) /
// dyn_add_arr_slice_ptr.x (`[2][]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSSPtr {
  function sumsssp(self, p: [][][]*i32): i32;
}
struct A { v: i32 }
impl SumSSSPtr for A {
  function sumsssp(self: A, p: [][][]*i32): i32 {
    let x: i32 = unsafe { *p[0][0][0] };
    let y: i32 = unsafe { *p[0][0][1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSSSPtr = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumsssp([[[&n, &m]]]);
}
