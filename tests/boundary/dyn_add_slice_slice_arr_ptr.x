// F7 leftover: dest extras dest-SLICE of SLICE extra `[][][2]*i32`
// dest-stamp (sit-red dyn extra T001 leftover PTR vs eeek=leaf after
// extra ARRAY peels). Produce: dest extras dest-SLICE-of-SLICE wrap
// ARRAY of leaf then wrap SLICE twice so dest was `[][][2]i32` not
// `[][][2]*i32`; impl-match leftover PTR vs eeek=leaf after extra
// ARRAY peels is T001 (named / UFCS dest-stamp via the formal 6/7;
// typed lets share T001 until extra PTR peels). Nested
// `[[[&n, &m]]]` never dest-stamped. Store: skip-trait extra STAR
// after `[][]` then `[M]` already keeps elem=SLICE + eek=leaf +
// ndims>=1; extra PTR wrap COUNT in unused slot dims[ndims]
// (1 = `[][][2]*T`; 0 = no extra PTR = `[][][2]T`; same unused
// slot as dest extras dest-SLICE-of-ARRAY extra `[][2][]T` and
// dest extras dest-ARRAY-of-SLICE extra `[2][][2]*T`; discriminant
// is elem_kind SLICE vs ARRAY AND SLICE vs ARRAY outer; extra STAR
// commits pending LBRACKET dims first; ban -3 / reuse of
// dims[0..ndims-1]). Consume: dest extras wrap PTR of leaf extra
// times then wrap ARRAY inner-first then wrap SLICE twice;
// impl-match extra PTR peels leftover PTR after extra ARRAY peels.
// Extra wrap `[][][2][2]*T` is covered by prefix_arr_more collecting
// further dims then extra PTR in dims[ndims]. PTR-outer `*[N][]T`
// stays deferred (asm 139). dest extras dest-SLICE of ARRAY extra
// `[][2][]*T` stays deferred (T001). Neighborhood `[][][2]i32`
// already 7; `[2][][2]*i32` already 7; `[][]*i32` already 7;
// `[][2]*i32` already 7; `[2][][2]i32` already 7.
// G.7: complete impl-match extra PTR peels + dest extras dest-
// SLICE-of-SLICE extra PTR wraps (no second dest-SLICE stamp; do
// not invent -3; store extra STAR already complete). Wrapper
// rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0][0] + *p[0][0][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_slice_slice_arr.x (`[][][2]i32`) /
// dyn_add_arr_slice_arr_ptr.x (`[2][][2]*i32`) /
// dyn_add_slice_slice_ptr.x (`[][]*i32`) /
// dyn_add_slice_arr_ptr.x (`[][2]*i32`) /
// dyn_add_arr_slice_arr.x (`[2][][2]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSAPtr {
  function sumssap(self, p: [][][2]*i32): i32;
}
struct A { v: i32 }
impl SumSSAPtr for A {
  function sumssap(self: A, p: [][][2]*i32): i32 {
    let x: i32 = unsafe { *p[0][0][0] };
    let y: i32 = unsafe { *p[0][0][1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSSAPtr = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumssap([[[&n, &m]]]);
}
