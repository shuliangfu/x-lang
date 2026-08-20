// F7 leftover: dest extras dest-RET extra STAR SLICE-elem
// `*[][2]*i32` dest-stamp (sit-red extra STAR after `*[][N]`
// hit token_to_type_kind=-1 then want_ret=0; leftover skip
// eek=-1; dest extras dest-RET wrap rek3==11 dest-stamps
// `*[][2]i32` so typed let `*[][2]*i32` T001; dest-stamp via
// the local of typed dest = false green even Ubuntu). Produce:
// extra STAR after `*[][N]` in ret_elem_elem_pending. Store:
// keep elem=SLICE + eek=leaf + ndims>=1 + dims[0]=N; extra PTR
// wrap COUNT in unused slot dims[ndims] (1 = `*[][2]*T`; 2 =
// `*[][2]**T`; 0 = no extra PTR = `*[][2]i32` / `*[][2][]T`;
// extra SLICE stays dims[ndims+1]; both slots = `*[][2][]*T`;
// ban -3 / new field). Discriminant vs dest extras dest-RET
// extra STAR ARRAY-elem `*[2]*T` / PTR-elem `**[2]*T` (same
// unused-slot family; ARRAY/PTR extra PTR lives in
// dims[ndims+1]) is SLICE vs ARRAY vs PTR elem. Consume:
// leftover PTR vs eek=SLICE peels leftover SLICE then extra
// ARRAY then extra SLICE then extra PTR; dest extras dest-RET
// wrap extra PTR of leaf extra times then extra SLICE then
// ARRAY inner-first then wrap SLICE then wrap outer ptr
// (already live from extra empty `[]` SLICE-elem wrap
// rek3==11). Assign-only: impl returns &self.p of by-value
// self (dangling — do not INDEX; dest extras dest-RET
// PTR-to-ARRAY identity INDEX is a pre-existing emit leftover).
// dest extras dest-PTR stamp stays banned. G.7: complete
// skip-trait ret extra STAR unused-slot scanner (SLICE elem;
// PTR outer; extra PTR in dims[ndims]) (no dest extras dest-PTR
// stamp; do not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_arr_ptr.x (`*[2]*i32`) /
// dyn_ret_ptr_ptr_arr_ptr.x (`**[2]*i32`) /
// dyn_ret_ptr_slice_arr_slice.x (`*[][2][]i32`) /
// dyn_add_ptr_slice_arr_ptr.x (`*[][2]*i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPSAP {
  /**
   * Return a dest extras dest-RET extra STAR SLICE-elem `*[][2]*i32`.
   * @param self GetPSAP — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return *[][2]*i32 — pointer to `[][2]` of `*i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpsap(self): *[][2]*i32;
}
struct A { p: [][2]*i32 }
impl GetPSAP for A {
  /**
   * Impl of GetPSAP.getpsap: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return *[][2]*i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpsap(self: A): *[][2]*i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `*[][2]*i32` (assign-only;
 * do not INDEX the dangling &self.p). Named `[][2]*i32` local then
 * field-copy (do not init `*[][2]*i32` with `&[[&n, &m]]` — nested
 * extra lit dest extras dest-PTR still banned → CG002).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let n: i32 = 2;
  let m: i32 = 4;
  let inner: [][2]*i32 = [[&n, &m]];
  let a: A = { p: inner };
  let x: GetPSAP = a;
  let p: *[][2]*i32 = x.getpsap();
  return 7;
}
