// F7 leftover: dest extras dest-RET extra STAR PTR-elem
// ndims=0 `***i32` dest-stamp (sit-red extra STAR after `**`
// hit nd>0 fail then elem_kind=-1 leftover skip eek=-1;
// dest extras dest-RET wrap rek3==9 dest-stamps `**i32` so
// typed let `***i32` T001; dest-stamp via the local of typed
// dest = false green even Ubuntu). Produce: extra STAR after
// `**` in ret_elem_elem_pending (elem=PTR, PTR outer,
// ndims=0). Store: keep elem=PTR + eek=leaf + ndims=0; extra
// PTR wrap COUNT in unused slot dims[1] (1 = `***T`; 2 =
// `****T`; 0 = no extra PTR = `**T`; extra SLICE stays
// dims[0] for `**[]T` — not this leaf; ban -3 / new field).
// Discriminant vs dest extras dest-RET extra STAR PTR-elem
// ndims>=1 `**[2]*T` (extra PTR in dims[ndims+1]) is ndims=0
// vs ndims>=1. Discriminant vs dest extras dest-RET extra
// STAR SLICE-elem ndims=0 `*[]*T` (extra PTR in dims[0]) is
// PTR vs SLICE elem. Consume: leftover PTR vs eek=PTR peels
// leftover PTR then extra PTR; dest extras dest-RET wrap
// extra PTR of leaf extra times then wrap PTR then wrap
// outer ptr. Assign-only: impl returns &self.p of by-value
// self (dangling — do not INDEX; dest extras dest-RET
// PTR-to-ARRAY identity INDEX is a pre-existing emit
// leftover). dest extras dest-PTR stamp stays banned. G.7:
// complete skip-trait ret extra STAR unused-slot scanner
// (PTR elem; PTR outer; ndims=0 extra PTR in dims[1]) +
// leftover eend==0 extra PTR peels + dest extras dest-RET
// wrap rek3==9 extra PTR when ndims=0 (no dest extras
// dest-PTR stamp; do not invent -3). Wrapper rdi/x0 = data
// unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_ptr_arr_ptr.x (`**[2]*i32`) /
// dyn_ret_ptr.x (`*i32`) /
// dyn_ret_ptr_slice_ptr.x (`*[]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPPP {
  /**
   * Return a dest extras dest-RET extra STAR PTR-elem ndims=0 `***i32`.
   * @param self GetPPP — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return ***i32 — pointer to `**i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getppp(self): ***i32;
}
struct A { p: **i32 }
impl GetPPP for A {
  /**
   * Impl of GetPPP.getppp: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return ***i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getppp(self: A): ***i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `***i32` (assign-only;
 * do not INDEX the dangling &self.p). Named `*i32` then `&inner`
 * field-copy (do not init `***i32` with nested extra lit —
 * dest extras dest-PTR still banned → CG002).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let n: i32 = 2;
  let inner: *i32 = &n;
  let a: A = { p: &inner };
  let x: GetPPP = a;
  let p: ***i32 = x.getppp();
  return 7;
}
