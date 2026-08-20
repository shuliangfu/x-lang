// F7 leftover: dest extras dest-ARRAY of SLICE extra `[2][][]*i32`
// dest-stamp (sit-red dyn extra nested ARRAY_LIT run=139). Produce:
// extra STAR after `[N][][]` (ndims==-2, ARRAY outer) set
// elem_kind=-1 so dest extras dest-ARRAY-of-SLICE never extra-wraps
// PTR after extra SLICE wraps (dest-stamps `[2][][]i32` not
// `[2][][]*i32`). Named / UFCS / module-func / assign dest-stamp
// via the formal (7/7/6/7). Typed lets dest-stamp via the formal
// (7). Store: keep elem=SLICE + eek=leaf + ndims=-2; extra SLICE
// wrap COUNT stays dims[0]; extra PTR wrap COUNT in unused slot
// dims[1] (1 = `[2][][]*T`; 0 = no extra PTR = `[2][][]T`; same
// encoding as `[][][]*T`; discriminant is ARRAY vs SLICE outer;
// ban -3 / reuse of dims[0]). Consume: dest extras wrap PTR of
// leaf extra times then wrap SLICE then extra SLICE wraps then
// ARRAY. ARRAY leftover impl-match leftover SLICE vs eek=SLICE
// is not T001 (do not add extra PTR peels). Extra wrap
// `[2][][][]*T` is covered by extra SLICE count in dims[0].
// G.7: complete skip-trait store + dest extras dest-ARRAY-of-SLICE
// extra PTR wraps (no second dest-ARRAY stamp; do not invent -3;
// do not add impl-match extra PTR peels). Wrapper rdi/x0 = data
// unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0][0] + *p[1][0][0]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_arr_slice_ptr.x (`[2][]*i32`) /
// dyn_add_arr_slice_slice.x (`[2][][]i32`) /
// dyn_add_slice_slice_slice_ptr.x (`[][][]*i32`) /
// dyn_add_slice_slice_ptr.x (`[][]*i32`) /
// dyn_add_arr_slice_arr.x (`[2][][2]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumASSPtr {
  function sumassp(self, p: [2][][]*i32): i32;
}
struct A { v: i32 }
impl SumASSPtr for A {
  function sumassp(self: A, p: [2][][]*i32): i32 {
    let x: i32 = unsafe { *p[0][0][0] };
    let y: i32 = unsafe { *p[1][0][0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumASSPtr = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumassp([[[&n]], [[&m]]]);
}
