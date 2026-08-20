// F7 leftover: dest extras dest-SLICE of PTR extra `[]*[2]*i32`
// dest-stamp (sit-red named / dyn extra T001). Produce: extra STAR
// after `[]*[N]` in param_elem_elem_pending hit token_to_type_kind=-1
// then want_param_ty=0 so leaf T never committed; COMMA/RPAREN
// wave434 *T[N] lift overwrote kind=ARRAY (impl leftover SLICE vs
// ARRAY). dest extras dest-SLICE-of-PTR wrap-once dest-stamps
// `[]*[2]i32` (or skips when store unset). ADDR_OF of typed
// `[2]*i32` never dest-stamped as dest-SLICE of dest-PTR of
// dest-ARRAY[2] of PTR. Store: keep elem=PTR + eek=leaf + ndims>=1
// + dims[0]=N; extra PTR wrap COUNT in unused slot dims[ndims+1]
// (1 = `[]*[2]*T`; 0 = no extra PTR = `[]*[2]i32`; extra SLICE
// stays dims[ndims]; ban -3 / new field). Discriminant vs dest
// extras dest-SLICE of ARRAY extra `[][2]*T` is elem_kind PTR vs
// ARRAY (same unused slot). Consume: dest extras wrap PTR of leaf
// extra times then extra SLICE wraps then ARRAY wrap then wrap PTR
// then outer SLICE. SLICE-outer PTR-elem impl-match matches leftover
// PTR vs eek=PTR without walking extra inner PTR (not T001). Outer
// must stay SLICE so `*[N]*T` stays deferred. G.7: complete skip-
// trait extra STAR unused-slot scanner (PTR elem) + dest extras
// dest-SLICE-of-PTR extra PTR wraps (no second dest-SLICE stamp; do
// not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *(*p[0])[0] + *(*p[0])[1]
// = 1+2+4). ADDR_OF of typed `[2]*i32` so dest extras dest-stamp
// fires. Neighborhood: dyn_add_slice_ptr_arr.x (`[]*[2]i32`) /
// dyn_add_slice_ptr_arr_slice.x (`[]*[2][]i32`) /
// dyn_add_slice_arr_ptr.x (`[][2]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSPAP {
  function sumspap(self, p: []*[2]*i32): i32;
}
struct A { v: i32 }
impl SumSPAP for A {
  function sumspap(self: A, p: []*[2]*i32): i32 {
    let x: i32 = unsafe { *(*p[0])[0] };
    let y: i32 = unsafe { *(*p[0])[1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSPAP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let row: [2]*i32 = [&n, &m];
  return x.sumspap([&row]);
}
