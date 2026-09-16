// F7 leftover: dest extras dest-RET extra empty `[]` PTR-elem
// `**[2][]i32` dest-stamp (sit-red extra empty `[]` after `**[N]`
// set elem_kind=-1; leftover skip eek=-1; dest extras dest-RET
// wrap never fires rek=-1 so typed let `**[2][]i32` T001).
// Produce: ret extra empty `[]` after `**[N]` in
// ret_elem_arr_need_size. Store: keep elem=PTR + eek=leaf +
// ndims>=1 + dims[0]=N; extra SLICE wrap COUNT in unused slot
// dims[ndims] (1 = `**[2][]T`; 2 = `**[2][][]T`; 0 = no extra
// wrap = `**[2]i32` / `**[2]*T`; extra PTR stays dims[ndims+1];
// both slots = `**[2][]*T`; ban -3 / new field). Discriminant vs
// dest extras dest-RET extra empty `[]` ARRAY-elem `*[2][]T`
// (same unused-slot family) is PTR vs ARRAY elem. Consume:
// leftover PTR vs eek=PTR peels leftover PTR then ARRAY then
// extra SLICE then extra PTR; dest extras dest-RET wrap extra
// PTR of leaf extra times then extra SLICE then ARRAY inner-
// first then wrap PTR then wrap outer ptr. Assign-only: impl
// returns &self.p of by-value self (dangling — do not INDEX;
// dest extras dest-RET PTR-to-ARRAY identity INDEX is a pre-
// existing emit leftover). dest extras dest-PTR stamp stays
// banned. G.7: complete skip-trait ret extra empty `[]`
// unused-slot scanner (PTR elem; PTR outer) + existing leftover
// extra SLICE peels + existing dest extras dest-RET extra SLICE
// wraps (no dest extras dest-PTR stamp; do not invent -3).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_arr_slice.x (`*[2][]i32`) /
// dyn_ret_ptr_ptr_arr_ptr.x (`**[2]*i32`) /
// dyn_add_ptr_ptr_arr_slice.x (`**[2][]i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPPAS {
  /**
   * Return a dest extras dest-RET extra empty `[]` PTR-elem `**[2][]i32`.
   * @param self GetPPAS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return **[2][]i32 — pointer to `*[2]` of `[]i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getppas(self): **[2][]i32;
}
struct A { p: *[2][]i32 }
impl GetPPAS for A {
  /**
   * Impl of GetPPAS.getppas: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return **[2][]i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getppas(self: A): **[2][]i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `**[2][]i32` (assign-only;
 * do not INDEX the dangling &self.p). Named `[2][]i32` local then
 * `&inner` (do not init `*[2][]i32` with `&[[2],[4]]` — that is
 * expected `*[2][]i32` found `*[2][1]i32`, not leftover T001).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let inner: [2][]i32 = [[2], [4]];
  let a: A = { p: &inner };
  let x: GetPPAS = a;
  let p: **[2][]i32 = x.getppas();
  return 7;
}
