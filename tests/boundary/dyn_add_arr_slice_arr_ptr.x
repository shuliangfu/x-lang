// F7 leftover: dest extras dest-ARRAY of SLICE extra `[2][][2]*i32`
// dest-stamp (sit-red dyn extra nested ARRAY_LIT run=139). Produce:
// extra STAR after `[N][][M]` (ndims>=1, ARRAY outer) set
// elem_kind=-1 so dest extras dest-ARRAY-of-SLICE never extra-wraps
// PTR after extra ARRAY wraps (dest-stamps `[2][][2]i32` not
// `[2][][2]*i32`). Named / UFCS / typed lets dest-stamp via the
// formal (6/7/7). Store: keep elem=SLICE + eek=leaf + ndims>=1;
// extra PTR wrap COUNT in unused slot dims[ndims] (1 = `[2][][2]*T`;
// 0 = no extra PTR = `[2][][2]T`; same unused slot as dest extras
// dest-SLICE-of-ARRAY extra `[][2][]T`; discriminant is elem_kind
// SLICE vs ARRAY; ban -3 / reuse of dims[0..ndims-1]). Extra STAR
// must commit pending LBRACKET dims first or ndims stays 0 and the
// inner ARRAY is lost. Consume: dest extras wrap PTR of leaf extra
// times then wrap ARRAY inner-first then wrap SLICE then ARRAY.
// ARRAY leftover impl-match leftover SLICE vs eek=SLICE is not T001
// (do not add extra PTR peels). Extra wrap `[2][][2][2]*T` is
// covered by prefix_arr_more collecting further dims then extra PTR
// in dims[ndims]. dest extras dest-SLICE-of-SLICE extra ARRAY extra
// PTR (`[][][2]*T`) stays deferred (T001 leftover PTR vs eeek=leaf).
// G.7: complete skip-trait store + dest extras dest-ARRAY-of-SLICE
// extra PTR wraps (no second dest-ARRAY stamp; do not invent -3;
// do not add impl-match extra PTR peels). Wrapper rdi/x0 = data
// unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0][0] + *p[1][0][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_arr_slice_arr.x (`[2][][2]i32`) /
// dyn_add_arr_slice_ptr.x (`[2][]*i32`) /
// dyn_add_slice_arr_ptr.x (`[][2]*i32`) /
// dyn_add_arr_slice_slice_ptr.x (`[2][][]*i32`) /
// dyn_add_slice_slice_arr.x (`[][][2]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumASAPtr {
  function sumasap(self, p: [2][][2]*i32): i32;
}
struct A { v: i32 }
impl SumASAPtr for A {
  function sumasap(self: A, p: [2][][2]*i32): i32 {
    let x: i32 = unsafe { *p[0][0][0] };
    let y: i32 = unsafe { *p[1][0][1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumASAPtr = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumasap([[[&n, &n]], [[&m, &m]]]);
}
