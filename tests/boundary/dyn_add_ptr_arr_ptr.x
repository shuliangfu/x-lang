// F7 leftover: PTR-outer extra `[2]*i32` dest-stamp of `*[2]*i32`
// (sit-red named / dyn extra / UFCS T001). Produce: extra STAR
// after `*[N]` in param_elem_elem_pending required SLICE outer so
// PTR outer hit token_to_type_kind=-1 then want_param_ty=0; leaf T
// never committed; param_elem_dim_n stayed live; COMMA/RPAREN
// wave434 *T[N] lift overwrote kind=ARRAY (impl leftover PTR vs
// ARRAY / leftover PTR vs eeek=-1). dest extras dest-SLICE of
// ARRAY extra `[][2]*T` already dest-stamps. Store: keep
// elem=ARRAY + eek=leaf + ndims>=1 + dims[0]=N; extra PTR wrap
// COUNT in unused slot dims[ndims+1] (1 = `*[2]*T`; 0 = no extra
// PTR = `*[2]i32`; extra SLICE stays dims[ndims]; `*[2][]*T`
// both slots; ban -3 / new field). Discriminant vs dest extras
// dest-SLICE of ARRAY extra `[][2]*T` is PTR vs SLICE outer
// (same unused slot). Consume: ARRAY leftover extra PTR peels
// leftover PTR after extra ARRAY peels (PTR-or-SLICE outer walk
// already peels dims[ndims+1]; extra ADDR_OF of typed `[2]*i32`
// dest-stamps via the formal — no dest extras dest-PTR stamp).
// Store-only without ARRAY leftover extra PTR peels is T001
// leftover PTR vs eeek=leaf after extra ARRAY peels. G.7:
// complete skip-trait extra STAR unused-slot scanner (ARRAY
// elem; SLICE or PTR outer) + existing ARRAY leftover extra PTR
// peels (no second dest-PTR stamp; do not invent -3). Wrapper
// rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *(*p)[0] + *(*p)[1]
// = 1+2+4). ADDR_OF of typed `[2]*i32` so skip-trait dest-stamp
// fires. Neighborhood: dyn_add_ptr.x (`*i32`) /
// dyn_add_ptr_arr_slice.x (`*[2][]i32`) /
// dyn_add_arr_ptr_arr_ptr.x (`[2]*[2]*i32`) /
// dyn_add_slice_arr_ptr.x (`[][2]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPAP {
  function sumpap(self, p: *[2]*i32): i32;
}
struct A { v: i32 }
impl SumPAP for A {
  function sumpap(self: A, p: *[2]*i32): i32 {
    let x: i32 = unsafe { *(*p)[0] };
    let y: i32 = unsafe { *(*p)[1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPAP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let row: [2]*i32 = [&n, &m];
  return x.sumpap(&row);
}
