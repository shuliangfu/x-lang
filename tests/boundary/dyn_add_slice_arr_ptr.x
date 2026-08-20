// F7 leftover: dest extras dest-SLICE of ARRAY extra `[][2]*i32`
// dest-stamp (sit-red dyn extra T001). Produce: extra STAR after
// ARRAY in param_elem_elem_pending hit token_to_type_kind=-1 then
// want_param_ty=0 so eek never captured; impl-match leftover PTR vs
// eeek=-1 (T001). dest extras dest-SLICE-of-ARRAY wrap-once dest-
// stamps `[][2]i32` (or skips when store unset). Nested ARRAY_LIT
// `[[&n, &m]]` never dest-stamped as dest-SLICE of dest-ARRAY[2] of
// PTR. Store: keep elem=ARRAY + eek=leaf + ndims=1 + dims[0]=2;
// extra PTR wrap COUNT in unused slot dims[ndims+1] (1 = `[][2]*T`;
// 0 = no extra PTR = `[][2]i32`; extra SLICE stays dims[ndims];
// ban -3 / new field). Consume: dest extras wrap PTR of leaf extra
// times then ARRAY wrap then outer SLICE; impl-match ARRAY extra
// PTR peels leftover PTR. Named / UFCS share T001 until store +
// extra PTR peel. Module-func / assign already dest-stamp via the
// formal (6). Neighborhood `[][2]i32` already 7; `[]*[2]i32`
// already 7; `[2]*i32` already 7 via ADDR_OF. G.7: complete skip-
// trait store + impl-match extra PTR peel + dest extras dest-SLICE-
// of-ARRAY extra PTR wraps (no second dest-SLICE stamp; do not
// invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0] + *p[0][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_slice_arr.x (`[][2]i32`) /
// dyn_add_slice_ptr.x (`[]*i32`) /
// dyn_add_slice_ptr_arr.x (`[]*[2]i32`) /
// dyn_add_slice_arr_slice.x (`[][2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSAP {
  function sumsap(self, p: [][2]*i32): i32;
}
struct A { v: i32 }
impl SumSAP for A {
  function sumsap(self: A, p: [][2]*i32): i32 {
    let x: i32 = unsafe { *p[0][0] };
    let y: i32 = unsafe { *p[0][1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSAP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumsap([[&n, &m]]);
}
