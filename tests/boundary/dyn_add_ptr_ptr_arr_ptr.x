// F7 leftover: PTR-elem + PTR-outer extra `**[2]*i32` dest-stamp
// (sit-red named / dyn extra / UFCS T001). Produce: extra STAR
// after `**[N]` in param_elem_elem_pending required ARRAY or
// SLICE outer so PTR outer hit token_to_type_kind=-1 then
// want_param_ty=0; leaf T never committed; param_elem_dim_n
// stayed live; COMMA/RPAREN wave434 *T[N] lift overwrote
// kind=ARRAY (impl leftover PTR vs ARRAY / leftover PTR vs
// eeek=-1). dest extras dest-ARRAY of PTR extra `[2]*[2]*T`
// and dest extras dest-SLICE of PTR extra `[]*[2]*T` already
// dest-stamp. Store: keep elem=PTR + eek=leaf + ndims>=1 +
// dims[0]=N; extra PTR wrap COUNT in unused slot
// dims[ndims+1] (1 = `**[2]*T`; 0 = no extra PTR = `**[2]i32`;
// extra SLICE stays dims[ndims]; `**[2][]*T` both slots; ban
// -3 / new field). Discriminant vs dest extras dest-ARRAY of
// PTR extra `[2]*[2]*T` / dest extras dest-SLICE of PTR extra
// `[]*[2]*T` (same unused slot) is PTR vs ARRAY vs SLICE
// outer. Consume: leftover PTR vs eek=PTR is not T001 (PTR-
// or-SLICE outer walk matches at leftover PTR); extra ADDR_OF
// of typed `*[2]*i32` dest-stamps via the formal (no dest
// extras dest-PTR stamp). Store-only of ARRAY-outer
// `[2]*[2]*T` without ARRAY leftover extra PTR peels is T001
// leftover PTR vs eeek=leaf after extra ARRAY peels. G.7:
// complete skip-trait extra STAR unused-slot scanner (PTR
// elem; ARRAY or SLICE or PTR outer) + existing unused-slot
// extra PTR wrap (no second dest-PTR stamp; do not invent
// -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *(**p)[0] + *(**p)[1]
// = 1+2+4). ADDR_OF of typed `*[2]*i32` so skip-trait
// dest-stamp fires. Neighborhood: dyn_add_ptr_arr_ptr.x
// (`*[2]*i32`) / dyn_add_arr_ptr_arr_ptr.x (`[2]*[2]*i32`) /
// dyn_add_slice_ptr_arr_ptr.x (`[]*[2]*i32`) /
// dyn_add_ptr_arr_slice_ptr.x (`*[2][]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPPAP {
  function sumppap(self, p: **[2]*i32): i32;
}
struct A { v: i32 }
impl SumPPAP for A {
  function sumppap(self: A, p: **[2]*i32): i32 {
    let x: i32 = unsafe { *(**p)[0] };
    let y: i32 = unsafe { *(**p)[1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPPAP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let row: [2]*i32 = [&n, &m];
  let rowp: *[2]*i32 = &row;
  return x.sumppap(&rowp);
}
