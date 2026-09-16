// F7 leftover: dest extras dest-PARAM extra empty `[]` PTR-elem
// ndims=0 `**[]i32` dest-stamp (sit-red extra empty `[]` after
// `**` hit nd>0 fail then elem_kind=-1 leftover skip eek=-1;
// extra ADDR_OF of typed dest dest-stamps via the formal =
// false green even leftover skip; leftover mismatch impl
// `**i32` vs trait `**[]i32` compile=0 run=1). Produce: extra
// empty `[]` after `**` in param_elem_arr_need_size (elem=PTR,
// PTR outer, ndims=0). Store: keep elem=PTR + eek=leaf +
// ndims=0; extra SLICE wrap COUNT in unused slot dims[0]
// (1 = `**[]T`; 2 = `**[][]T`; 0 = no extra SLICE = `**T` /
// `***T`; extra PTR stays dims[1]; both slots = `**[]*T`;
// ban -3 / new field). Discriminant vs dest extras dest-PARAM
// extra empty `[]` PTR-elem ndims>=1 `**[2][]T` (extra SLICE
// in dims[ndims]) is ndims=0 vs ndims>=1. Discriminant vs
// dest extras dest-PARAM extra STAR PTR-elem ndims=0 `***T`
// (extra PTR in dims[1]; this leaf) is extra SLICE vs
// extra PTR. Consume: leftover PTR vs eek=PTR peels leftover
// PTR then extra SLICE then extra PTR when ndims=0; extra
// ADDR_OF of typed `*[]i32` dest-stamps via the formal (no
// dest extras dest-PTR stamp). dest extras dest-PTR stamp
// stays banned. G.7: complete skip-trait extra empty `[]`
// unused-slot scanner (PTR elem; PTR outer; ndims=0 extra
// SLICE in dims[0]) + leftover eand==0 extra SLICE peels
// (no dest extras dest-PTR stamp; do not invent -3). Wrapper
// rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (**p)[0] = 1+6).
// ADDR_OF of typed `*[]i32` so skip-trait dest-stamp fires.
// Neighborhood: dyn_add_ptr_ptr_arr_slice.x (`**[2][]i32`) /
// dyn_ret_ptr_ptr_slice.x (`**[]i32` ret) /
// dyn_add_ptr_ptr_arr_ptr.x (`**[2]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPPS {
  /**
   * Sum `self.v` with the first element of a dest extras dest-PARAM
   * extra empty `[]` PTR-elem ndims=0 `**[]i32`.
   * @param self SumPPS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @param p **[]i32 — pointer to `*[]i32` (dest extras dest-PARAM dest-stamp)
   * @return i32 — v + (**p)[0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpps(self, p: **[]i32): i32;
}
struct A { v: i32 }
impl SumPPS for A {
  /**
   * Impl of SumPPS.sumpps: INDEX the extra SLICE then add.
   * @param self A — by-value NAMED receiver
   * @param p **[]i32 — skip-trait extra; dest-stamps via the formal
   * @return i32 — self.v + (**p)[0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpps(self: A, p: **[]i32): i32 {
    let x: i32 = unsafe { (**p)[0] };
    return self.v + x;
  }
}
/**
 * Dyn extra ADDR_OF of typed `*[]i32` so skip-trait dest-stamp fires.
 * Named `[]i32` then `&inner` (do not init `**[]i32` with nested extra
 * lit — dest extras dest-PTR still banned → CG002).
 * @return i32 — expected 7 (1+6)
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPPS = a;
  let inner: []i32 = [6];
  let innerp: *[]i32 = &inner;
  return x.sumpps(&innerp);
}
