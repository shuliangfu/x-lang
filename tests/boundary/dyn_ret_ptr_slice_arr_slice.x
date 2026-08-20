// F7 leftover: dest extras dest-RET extra empty `[]` SLICE-elem
// `*[][2][]i32` dest-stamp (sit-red extra empty `[]` after
// `*[][N]` set elem_kind=-1; leftover skip eek=-1; dest extras
// dest-RET wrap never fires rek=-1 so typed let dest-stamps via
// the local = false green; impl `*[][2]i32` vs trait
// `*[][2][]i32` compile=0). Produce: ret extra empty `[]` after
// `*[][N]` in ret_elem_arr_need_size. Store: keep elem=SLICE +
// eek=leaf + ndims>=1 + dims[0]=N; extra SLICE wrap COUNT in
// unused slot dims[ndims+1] (1 = `*[][2][]T`; 2 =
// `*[][2][][]T`; 0 = no extra wrap = `*[][2]i32` / `*[][2]*T`;
// extra PTR stays dims[ndims]; both slots = `*[][2][]*T`; ban
// -3 / new field). Discriminant vs dest extras dest-RET extra
// empty `[]` ARRAY-elem `*[2][]T` / PTR-elem `**[2][]T` (same
// unused-slot family) is SLICE vs ARRAY vs PTR elem. Consume:
// leftover PTR vs eek=SLICE peels leftover SLICE then extra
// ARRAY then extra SLICE then extra PTR; dest extras dest-RET
// wrap extra PTR of leaf extra times then extra SLICE then
// ARRAY inner-first then wrap SLICE then wrap outer ptr.
// Assign-only: impl returns &self.p of by-value self (dangling
// — do not INDEX; dest extras dest-RET PTR-to-ARRAY identity
// INDEX is a pre-existing emit leftover). dest extras dest-PTR
// stamp stays banned. G.7: complete skip-trait ret extra empty
// `[]` unused-slot scanner (SLICE elem; PTR outer) + leftover
// extra ARRAY/SLICE peels + dest extras dest-RET extra SLICE
// wraps (no dest extras dest-PTR stamp; do not invent -3).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_arr_slice.x (`*[2][]i32`) /
// dyn_ret_ptr_ptr_arr_slice.x (`**[2][]i32`) /
// dyn_add_ptr_slice_arr_slice.x (`*[][2][]i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPSAS {
  /**
   * Return a dest extras dest-RET extra empty `[]` SLICE-elem `*[][2][]i32`.
   * @param self GetPSAS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return *[][2][]i32 — pointer to `[][2]` of `[]i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpsas(self): *[][2][]i32;
}
struct A { p: [][2][]i32 }
impl GetPSAS for A {
  /**
   * Impl of GetPSAS.getpsas: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return *[][2][]i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpsas(self: A): *[][2][]i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `*[][2][]i32` (assign-only;
 * do not INDEX the dangling &self.p). Named `[][2][]i32` local then
 * field-copy (do not init `*[][2][]i32` with `&[[[2],[4]]]` — nested
 * extra lit dest extras dest-PTR still banned → CG002).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let inner: [][2][]i32 = [[[2], [4]]];
  let a: A = { p: inner };
  let x: GetPSAS = a;
  let p: *[][2][]i32 = x.getpsas();
  return 7;
}
