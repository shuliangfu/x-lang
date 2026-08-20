// F7 leftover: dest extras dest-RET extra empty `[]` PTR-elem
// ndims=0 `**[]i32` dest-stamp (sit-red extra empty `[]` after
// `**` hit nd>0 fail then elem_kind=-1 leftover skip eek=-1;
// dest extras dest-RET wrap rek3==9 dest-stamps `**i32` so
// typed let `**[]i32` T001; dest-stamp via the local of typed
// dest = false green even Ubuntu). Produce: extra empty `[]`
// after `**` in ret_elem_arr_need_size (elem=PTR, PTR outer,
// ndims=0). Store: keep elem=PTR + eek=leaf + ndims=0; extra
// SLICE wrap COUNT in unused slot dims[0] (1 = `**[]T`; 2 =
// `**[][]T`; 0 = no extra SLICE = `**T` / `***T`; extra PTR
// stays dims[1]; both slots = `**[]*T`; ban -3 / new field).
// Discriminant vs dest extras dest-RET extra empty `[]`
// PTR-elem ndims>=1 `**[2][]T` (extra SLICE in dims[ndims])
// is ndims=0 vs ndims>=1. Discriminant vs dest extras dest-RET
// extra STAR PTR-elem ndims=0 `***T` (extra PTR in dims[1]) is
// extra SLICE vs extra PTR. Consume: leftover PTR vs eek=PTR
// peels leftover PTR then extra SLICE then extra PTR; dest
// extras dest-RET wrap extra PTR of leaf extra times then extra
// SLICE then wrap PTR then wrap outer ptr. Assign-only: impl
// returns &self.p of by-value self (dangling — do not INDEX;
// dest extras dest-RET PTR-to-ARRAY identity INDEX is a pre-
// existing emit leftover). dest extras dest-PTR stamp stays
// banned. G.7: complete skip-trait ret extra empty `[]`
// unused-slot scanner (PTR elem; PTR outer; ndims=0 extra
// SLICE in dims[0]) + leftover eend==0 extra SLICE peels +
// dest extras dest-RET wrap rek3==9 extra SLICE when ndims=0
// (no dest extras dest-PTR stamp; do not invent -3). Wrapper
// rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_ptr_arr_slice.x (`**[2][]i32`) /
// dyn_ret_ptr_ptr_ptr.x (`***i32`) /
// dyn_ret_ptr_slice_ptr.x (`*[]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPPS {
  /**
   * Return a dest extras dest-RET extra empty `[]` PTR-elem ndims=0 `**[]i32`.
   * @param self GetPPS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return **[]i32 — pointer to `*[]i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpps(self): **[]i32;
}
struct A { p: *[]i32 }
impl GetPPS for A {
  /**
   * Impl of GetPPS.getpps: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return **[]i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpps(self: A): **[]i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `**[]i32` (assign-only;
 * do not INDEX the dangling &self.p). Named `[]i32` then `&inner`
 * field-copy (do not init `**[]i32` with nested extra lit —
 * dest extras dest-PTR still banned → CG002).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let inner: []i32 = [2, 4];
  let a: A = { p: &inner };
  let x: GetPPS = a;
  let p: **[]i32 = x.getpps();
  return 7;
}
