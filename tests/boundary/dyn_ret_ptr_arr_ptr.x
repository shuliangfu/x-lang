// F7 leftover: dest extras dest-RET extra STAR `*[2]*i32` dest-stamp
// (sit-red extra STAR after `*[N]` hit token_to_type_kind=-1 then
// want_ret=0; leftover skip eek=-1; dest extras dest-RET wrap-once
// dest-stamps `*[2]i32` so typed let `*[2]*i32` T001). Produce:
// extra STAR after `*[N]` in ret_elem_elem_pending. Store: keep
// elem=ARRAY + eek=leaf + ndims>=1 + dims[0]=N; extra PTR wrap
// COUNT in unused slot dims[ndims+1] (1 = `*[2]*T`; 0 = no extra
// PTR = `*[2]i32`; extra SLICE stays dims[ndims]; `*[2][]*T` both
// slots; ban -3 / new field). Discriminant vs dest extras dest-RET
// extra empty `[]` `*[2][]T` (same unused-slot family) is extra PTR
// vs extra SLICE. Consume: leftover PTR vs eek=ARRAY peels extra
// PTR after extra SLICE after ARRAY peels; dest extras dest-RET
// wrap extra PTR of leaf extra times then extra SLICE then ARRAY
// inner-first then wrap ptr. Assign-only: impl returns &self.p of
// by-value self (dangling — do not INDEX; dest extras dest-RET
// PTR-to-ARRAY identity INDEX is a pre-existing emit leftover,
// `*[2]i32` identity INDEX also 139). dest extras dest-PTR stamp
// stays banned. G.7: complete skip-trait ret extra STAR unused-
// slot scanner (ARRAY elem; PTR outer) + leftover extra PTR peels
// + dest extras dest-RET extra PTR wraps (no dest extras dest-PTR
// stamp; do not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_arr.x (`*[2]i32`) /
// dyn_ret_ptr_arr_slice.x (`*[2][]i32`) /
// dyn_add_ptr_arr_ptr.x (`*[2]*i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPAP {
  /**
   * Return a PTR-outer extra STAR `*[2]*i32`.
   * @param self GetPAP — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return *[2]*i32 — pointer to `[2]` of `*i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpap(self): *[2]*i32;
}
struct A { p: [2]*i32 }
impl GetPAP for A {
  /**
   * Impl of GetPAP.getpap: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return *[2]*i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpap(self: A): *[2]*i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `*[2]*i32` (assign-only;
 * do not INDEX the dangling &self.p).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let n: i32 = 2;
  let m: i32 = 4;
  let a: A = { p: [&n, &m] };
  let x: GetPAP = a;
  let p: *[2]*i32 = x.getpap();
  return 7;
}
