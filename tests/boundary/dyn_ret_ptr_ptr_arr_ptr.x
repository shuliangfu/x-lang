// F7 leftover: dest extras dest-RET extra STAR PTR-elem `**[2]*i32`
// dest-stamp (sit-red extra STAR after `**` hit token_to_type_kind=-1
// then ret_elem_suffix_pending; after `**[N]` wave434 *T[N] lift
// leftover PTR vs ARRAY T001; dest extras dest-RET wrap-once dest-
// stamps `**[2]i32` so typed let `**[2]*i32` T001). Produce:
// ret_elem_pending STAR stores elem=PTR + extra STAR after `**[N]`
// in ret_elem_elem_pending. Store: keep elem=PTR + eek=leaf +
// ndims>=1 + dims[0]=N; extra PTR wrap COUNT in unused slot
// dims[ndims+1] (1 = `**[2]*T`; 0 = no extra PTR = `**[2]i32`;
// extra SLICE stays dims[ndims]; `**[2][]*T` both slots; ban
// -3 / new field). Discriminant vs dest extras dest-RET extra
// STAR ARRAY-elem `*[2]*T` (same unused-slot family) is PTR vs
// ARRAY elem. Consume: leftover PTR vs eek=PTR peels leftover
// PTR then ARRAY then extra SLICE then extra PTR; dest extras
// dest-RET wrap extra PTR of leaf extra times then extra SLICE
// then ARRAY inner-first then wrap PTR then wrap outer ptr.
// Assign-only: impl returns &self.p of by-value self (dangling
// — do not INDEX; dest extras dest-RET PTR-to-ARRAY identity
// INDEX is a pre-existing emit leftover). dest extras dest-PTR
// stamp stays banned. G.7: complete skip-trait ret_elem_pending
// STAR + ret extra STAR unused-slot scanner (PTR elem; PTR
// outer) + leftover extra ARRAY peels + dest extras dest-RET
// extra PTR wraps (no dest extras dest-PTR stamp; do not invent
// -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_arr_ptr.x (`*[2]*i32`) /
// dyn_ret_ptr_arr.x (`*[2]i32`) /
// dyn_add_ptr_ptr_arr_ptr.x (`**[2]*i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPPAP {
  /**
   * Return a dest extras dest-RET extra STAR PTR-elem `**[2]*i32`.
   * @param self GetPPAP — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return **[2]*i32 — pointer to `*[2]` of `*i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getppap(self): **[2]*i32;
}
struct A { p: *[2]*i32 }
impl GetPPAP for A {
  /**
   * Impl of GetPPAP.getppap: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return **[2]*i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getppap(self: A): **[2]*i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `**[2]*i32` (assign-only;
 * do not INDEX the dangling &self.p).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let n: i32 = 2;
  let m: i32 = 4;
  let inner: [2]*i32 = [&n, &m];
  let a: A = { p: &inner };
  let x: GetPPAP = a;
  let p: **[2]*i32 = x.getppap();
  return 7;
}
