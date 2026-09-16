// F7 leftover: dest extras dest-ARRAY of PTR extra `[2]*[2]*i32`
// dest-stamp (sit-red named / dyn extra / UFCS T001). Produce:
// extra STAR after `[K]*[N]` in param_elem_elem_pending required
// SLICE outer so ARRAY outer hit token_to_type_kind=-1 then
// want_param_ty=0; leaf T never committed (impl leftover PTR vs
// eeek=-1 / leftover PTR vs eeek=leaf after extra ARRAY peels).
// dest extras dest-ARRAY-of-PTR wrap-once dest-stamps `[2]*[2]i32`.
// Store: keep elem=PTR + eek=leaf + ndims>=1 + dims[0]=N; extra
// PTR wrap COUNT in unused slot dims[ndims+1] (1 = `[2]*[2]*T`;
// 0 = no extra PTR = `[2]*[2]i32`; extra SLICE stays dims[ndims];
// ban -3 / new field). Discriminant vs dest extras dest-SLICE of
// PTR extra `[]*[2]*T` is ARRAY vs SLICE outer (same unused slot).
// Consume: dest extras wrap PTR of leaf extra times then extra
// SLICE wraps then ARRAY wrap then wrap PTR then outer ARRAY.
// Store-only without ARRAY leftover extra PTR peels is T001
// leftover PTR vs eeek=leaf after extra ARRAY peels. Outer must
// stay ARRAY so `*[N]*T` stays deferred. G.7: complete skip-trait
// extra STAR unused-slot scanner (PTR elem; ARRAY or SLICE outer)
// + ARRAY leftover extra PTR peels + dest extras dest-ARRAY-of-PTR
// extra PTR wraps (no second dest-ARRAY stamp; do not invent -3).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 6 (v + *(*p[0])[0] + *(*p[1])[0]
// = 1+2+3). ADDR_OF of typed `[2]*i32` so dest extras dest-stamp
// fires. Neighborhood: dyn_add_arr_ptr_arr.x (`[2]*[2]i32`) /
// dyn_add_slice_ptr_arr_ptr.x (`[]*[2]*i32`) /
// dyn_add_arr_ptr_slice_slice.x (`[2]*[][]i32`) /
// dyn_add_slice_ptr_arr.x (`[]*[2]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumAPAP {
  function sumapap(self, p: [2]*[2]*i32): i32;
}
struct A { v: i32 }
impl SumAPAP for A {
  function sumapap(self: A, p: [2]*[2]*i32): i32 {
    let x: i32 = unsafe { *(*p[0])[0] };
    let y: i32 = unsafe { *(*p[1])[0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumAPAP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let n2: i32 = 3;
  let m2: i32 = 5;
  let r0: [2]*i32 = [&n, &m];
  let r1: [2]*i32 = [&n2, &m2];
  return x.sumapap([&r0, &r1]);
}
