// F7 leftover: dest extras dest-RET PTR-to-ARRAY extra empty `[]`
// `*[2][]i32` dest-stamp (sit-red extra empty `[]` after `*[N]`
// set elem_kind=-1; leftover skip eek=-1; dest extras dest-RET
// wrap-once dest-stamps `*[2]i32` so typed let `*[2][]i32` T001).
// Produce: ret extra empty `[]` after `*[N]` in
// ret_elem_arr_need_size. Store: keep elem=ARRAY + eek=leaf +
// ndims>=1 + dims[0]=N; extra SLICE wrap COUNT in unused slot
// dims[ndims] (1 = `*[2][]T`; 2 = `*[2][][]T`; 0 = no extra wrap
// = `*[2]i32`; ban -3 / new field). Discriminant vs dest extras
// dest-ARRAY of PTR extra empty `[]` `[2]*[2][]T` / dest extras
// dest-SLICE of ARRAY extra `[][2][]T` (same unused slot) is PTR
// ret vs ARRAY vs SLICE param. Consume: leftover PTR vs eek=ARRAY
// peels extra SLICE after ARRAY peels; dest extras dest-RET wrap
// extra SLICE of leaf extra times then ARRAY inner-first then
// wrap ptr. Assign-only: impl returns &self.p of by-value self
// (dangling — do not INDEX; dest extras dest-RET PTR-to-ARRAY
// identity INDEX is a pre-existing emit leftover, `*[2]i32`
// identity INDEX also 139). Extra STAR `*[2]*T` dest extras
// dest-RET unused slot stays deferred. G.7: complete skip-trait
// ret extra empty `[]` unused-slot scanner (ARRAY elem; PTR
// outer) + leftover extra SLICE peels + dest extras dest-RET
// extra SLICE wraps (no dest extras dest-PTR stamp; do not
// invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_arr.x (`*[2]i32`) /
// dyn_add_ptr_arr_slice.x (`*[2][]i32` extra) /
// dyn_add_arr_slice.x (`[2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPAS {
  /**
   * Return a PTR-outer extra empty `[]` `*[2][]i32`.
   * @param self GetPAS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return *[2][]i32 — pointer to `[2]` of `[]i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpas(self): *[2][]i32;
}
struct A { p: [2][]i32 }
impl GetPAS for A {
  /**
   * Impl of GetPAS.getpas: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return *[2][]i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpas(self: A): *[2][]i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `*[2][]i32` (assign-only;
 * do not INDEX the dangling &self.p).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { p: [[2], [4]] };
  let x: GetPAS = a;
  let p: *[2][]i32 = x.getpas();
  return 7;
}
