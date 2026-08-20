// F7 leftover: dest extras dest-PARAM extra STAR PTR-elem
// ndims=0 `***i32` dest-stamp (sit-red extra STAR after `**`
// hit nd>0 fail then elem_kind=-1 leftover skip eek=-1;
// extra ADDR_OF of typed dest dest-stamps via the formal =
// false green even leftover skip; leftover mismatch impl
// `**i32` vs trait `***i32` compile=0 run=1). Produce: extra
// STAR after `**` in param_elem_elem_pending (elem=PTR, PTR
// outer, ndims=0). Store: keep elem=PTR + eek=leaf +
// ndims=0; extra PTR wrap COUNT in unused slot dims[1]
// (1 = `***T`; 2 = `****T`; 0 = no extra PTR = `**T` /
// `**[]T`; extra SLICE stays dims[0]; both slots = `**[]*T`;
// ban -3 / new field). Discriminant vs dest extras dest-PARAM
// extra STAR PTR-elem ndims>=1 `**[2]*T` (extra PTR in
// dims[ndims+1]) is ndims=0 vs ndims>=1. Discriminant vs
// dest extras dest-PARAM extra empty `[]` PTR-elem ndims=0
// `**[]T` (extra SLICE in dims[0]; already closed) is extra
// PTR vs extra SLICE. Consume: leftover PTR vs eek=PTR peels
// leftover PTR then extra SLICE then extra PTR when ndims=0
// (leftover extra PTR peels already live from dest extras
// dest-PARAM extra empty `[]` PTR-elem ndims=0); extra
// ADDR_OF of typed `**i32` dest-stamps via the formal (no
// dest extras dest-PTR stamp). dest extras dest-PTR stamp
// stays banned. G.7: complete skip-trait extra STAR unused-
// slot scanner (PTR elem; PTR outer; ndims=0 extra PTR in
// dims[1]) + leftover eand==0 extra PTR peels (already live)
// + PARAM dim accessor nd==0 dim_ix==1 (no dest extras dest-
// PTR stamp; do not invent -3). Wrapper rdi/x0 = data
// unchanged.
// Expected: compile = 0, run = 7 (v + ***p = 1+6).
// ADDR_OF of typed `**i32` so skip-trait dest-stamp fires.
// Neighborhood: dyn_add_ptr_ptr_arr_ptr.x (`**[2]*i32`) /
// dyn_ret_ptr_ptr_ptr.x (`***i32` ret) /
// dyn_add_ptr_ptr_slice.x (`**[]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPPP {
  /**
   * Sum `self.v` with the pointee of a dest extras dest-PARAM
   * extra STAR PTR-elem ndims=0 `***i32`.
   * @param self SumPPP — dyn receiver (vtable wrapper rdi/x0 = data)
   * @param p ***i32 — pointer to `**i32` (dest extras dest-PARAM dest-stamp)
   * @return i32 — v + ***p
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumppp(self, p: ***i32): i32;
}
struct A { v: i32 }
impl SumPPP for A {
  /**
   * Impl of SumPPP.sumppp: DEREF the extra PTR then add.
   * @param self A — by-value NAMED receiver
   * @param p ***i32 — skip-trait extra; dest-stamps via the formal
   * @return i32 — self.v + ***p
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumppp(self: A, p: ***i32): i32 {
    let x: i32 = unsafe { ***p };
    return self.v + x;
  }
}
/**
 * Dyn extra ADDR_OF of typed `**i32` so skip-trait dest-stamp fires.
 * Named `*i32` then `&inner` then extra ADDR_OF of typed dest (do not
 * init `***i32` with nested extra lit — dest extras dest-PTR still
 * banned → CG002).
 * @return i32 — expected 7 (1+6)
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPPP = a;
  let n: i32 = 6;
  let inner: *i32 = &n;
  let innerp: **i32 = &inner;
  return x.sumppp(&innerp);
}
