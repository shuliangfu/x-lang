// F7 leftover: dest extras dest-SLICE of ARRAY extra `[][2][]*i32`
// dest-stamp (sit-red dyn extra / UFCS / lets T001). Produce:
// impl-match ARRAY leftover peeled extra PTR first then extra
// SLICE so leftover SLICE-of-PTR of `[][2][]*T` vs PTR → T001.
// Store already keeps elem=ARRAY + eek=leaf + ndims=1 + dims[0]=2
// + extra SLICE in unused slot dims[ndims] + extra PTR in unused
// slot dims[ndims+1] (1 = `[][2][]*T`; extra SLICE-only =
// `[][2][]T`; extra PTR-only = `[][2]*T`; both 0 = `[][2]i32`;
// ban -3 / new field). dest extras dest-SLICE-of-ARRAY already
// wraps PTR of leaf then extra SLICE then ARRAY then outer SLICE
// (`[][2][]*T` is wrap-both). Named extra already dest-stamps
// via the formal (7). Consume: impl-match extra SLICE peels
// leftover SLICE (outer extra) then extra PTR peels leftover PTR
// (inner extra). Nested ARRAY_LIT `[[[&n], [&m]]]` dest-stamps as
// dest-SLICE of dest-ARRAY[2] of dest-SLICE of PTR. Extra wrap
// `[][2][][]*T` covered by extra SLICE count. Neighborhood
// `[][2][]i32` already 7; `[][2]*i32` already 7; `[][][2]*i32`
// already 7. `*[N][]T` PTR-outer stays deferred. G.7: complete
// skip-trait ARRAY leftover peel order (no second dest-SLICE
// stamp; do not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0][0] + *p[0][1][0]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_slice_arr_slice.x (`[][2][]i32`) /
// dyn_add_slice_arr_ptr.x (`[][2]*i32`) /
// dyn_add_slice_slice_arr_ptr.x (`[][][2]*i32`) /
// dyn_add_slice_arr.x (`[][2]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSASP {
  function sumsasp(self, p: [][2][]*i32): i32;
}
struct A { v: i32 }
impl SumSASP for A {
  function sumsasp(self: A, p: [][2][]*i32): i32 {
    let x: i32 = unsafe { *p[0][0][0] };
    let y: i32 = unsafe { *p[0][1][0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSASP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumsasp([[[&n], [&m]]]);
}
