// F7 leftover: PTR-outer extra STAR `*[][2]*i32` dest-stamp
// (sit-red extra / named / UFCS T001 leftover PTR vs ARRAY —
// extra STAR after `*[][N]` required ARRAY or SLICE outer so PTR
// outer hit token_to_type_kind=-1 then want_param_ty=0, leaf T
// never committed, param_elem_dim_n stayed live, COMMA/RPAREN
// wave434 *T[N] lift overwrote kind=ARRAY). Produce: extra STAR
// after `*[][M]` in param_elem_elem_pending (elem=SLICE, PTR
// outer, ndims>=1). dest extras dest-ARRAY of SLICE extra
// `[2][][2]*T` and dest extras dest-SLICE of SLICE extra
// `[][][2]*T` already dest-stamp. Store: keep elem=SLICE +
// eek=leaf + ndims>=1 + dims[0]=M; extra PTR wrap COUNT in
// unused slot dims[ndims] (1 = `*[][2]*T`; 2 = `*[][2]**T`;
// 0 = no extra PTR = `*[][2]i32`; extra SLICE stays
// dims[ndims+1]; `*[][2][]*T` has both slots; ban -3 / new
// field). Discriminant vs dest extras dest-ARRAY of SLICE extra
// `[2][][2]*T` / dest extras dest-SLICE of SLICE extra
// `[][][2]*T` (same unused slot) is PTR vs ARRAY vs SLICE outer.
// Consume: leftover PTR vs eek=SLICE is not T001 (walk peels
// leftover SLICE then extra ARRAY then extra PTR); extra ADDR_OF
// of typed `[][2]*i32` dest-stamps via the formal (no dest extras
// dest-PTR stamp). `*[]*T` leftover skip eek=-1 was false green
// via the formal. Nested extra lit dest extras dest-PTR stamp
// stays deferred. G.7: complete skip-trait extra STAR unused-slot
// scanner (SLICE elem; ARRAY or SLICE or PTR outer) + existing
// leftover extra PTR peels (no second dest-PTR stamp; do not
// invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *(*p)[0][0] + *(*p)[0][1]
// = 1+2+4). ADDR_OF of typed `[][2]*i32` so dest extras dest-stamp
// fires via the formal. Neighborhood: dyn_add_slice_arr_ptr.x
// (`[][2]*i32`) / dyn_add_slice_slice_arr_ptr.x (`[][][2]*i32`) /
// dyn_add_arr_slice_arr_ptr.x (`[2][][2]*i32`) /
// dyn_add_ptr_arr_ptr.x (`*[2]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPSAP {
  /**
   * Sum `self.v` with the two extra PTR cells in a PTR-outer extra
   * STAR `*[][2]*i32`.
   * @param self SumPSAP — dyn receiver (vtable wrapper rdi/x0 = data)
   * @param p *[][2]*i32 — pointer to slice of `[2]` of `*i32`
   * @return i32 — v + *(*p)[0][0] + *(*p)[0][1]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpsap(self, p: *[][2]*i32): i32;
}
struct A { v: i32 }
impl SumPSAP for A {
  /**
   * Impl of SumPSAP.sumpsap: DEREF each extra PTR then add.
   * @param self A — by-value NAMED receiver
   * @param p *[][2]*i32 — skip-trait extra; dest-stamps via the formal
   * @return i32 — self.v + *(*p)[0][0] + *(*p)[0][1]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpsap(self: A, p: *[][2]*i32): i32 {
    let x: i32 = unsafe { *(*p)[0][0] };
    let y: i32 = unsafe { *(*p)[0][1] };
    return self.v + x + y;
  }
}
/**
 * Dyn extra ADDR_OF of typed `[][2]*i32` so dest extras dest-stamp
 * fires via the formal (no dest extras dest-PTR stamp).
 * @return i32 — expected 7 (1+2+4)
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPSAP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let row: [][2]*i32 = [[&n, &m]];
  return x.sumpsap(&row);
}
