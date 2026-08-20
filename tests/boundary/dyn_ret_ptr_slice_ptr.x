// F7 leftover: dest extras dest-RET extra STAR SLICE-elem
// ndims=0 `*[]*i32` dest-stamp (sit-red extra STAR after `*[]`
// hit nd>0 fail then elem_kind=-1 leftover skip eek=-1; dest
// extras dest-RET wrap rek3==11 dest-stamps `*[]i32` so typed
// let `*[]*i32` T001; dest-stamp via the local of typed dest =
// false green even Ubuntu). Produce: extra STAR after `*[]` in
// ret_elem_elem_pending (elem=SLICE, PTR outer, ndims=0). Store:
// keep elem=SLICE + eek=leaf + ndims=0; extra PTR wrap COUNT in
// unused slot dims[0] (1 = `*[]*T`; 2 = `*[]**T`; 0 = no extra
// PTR = `*[]i32`; ban -3 / new field). Discriminant vs dest
// extras dest-RET extra STAR SLICE-elem ndims>=1 `*[][2]*T`
// (extra PTR in dims[ndims]) is ndims==0 vs ndims>=1. Consume:
// leftover PTR vs eek=SLICE peels leftover SLICE then extra PTR
// (ndims=0 unused slot dims[0]); dest extras dest-RET wrap extra
// PTR of leaf extra times then wrap SLICE then wrap outer ptr.
// Assign-only: impl returns &self.p of by-value self (dangling
// — do not INDEX; dest extras dest-RET PTR-to-ARRAY identity
// INDEX is a pre-existing emit leftover). dest extras dest-PTR
// stamp stays banned. G.7: complete skip-trait ret extra STAR
// unused-slot scanner (SLICE elem; PTR outer; ndims=0 extra PTR
// in dims[0]) + leftover extra PTR peels + dest extras dest-RET
// wrap extra PTR when ndims=0 (no dest extras dest-PTR stamp; do
// not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (assign-only; type is the leaf).
// Neighborhood: dyn_ret_ptr_slice_arr_ptr.x (`*[][2]*i32`) /
// dyn_ret_ptr_slice_arr_slice.x (`*[][2][]i32`) /
// dyn_ret_ptr.x (`*i32`) / dyn_add_ptr_slice_arr_ptr.x
// (`*[][2]*i32` extra).
// PLATFORM: SHARED — Ubuntu gold.

trait GetPSP {
  /**
   * Return a dest extras dest-RET extra STAR SLICE-elem ndims=0 `*[]*i32`.
   * @param self GetPSP — dyn receiver (vtable wrapper rdi/x0 = data)
   * @return *[]*i32 — pointer to `[]` of `*i32` (dest extras dest-RET dest-stamp)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpsp(self): *[]*i32;
}
struct A { p: []*i32 }
impl GetPSP for A {
  /**
   * Impl of GetPSP.getpsp: return &self.p.
   * @param self A — by-value NAMED receiver
   * @return *[]*i32 — &self.p (dangling after return; assign-only)
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function getpsp(self: A): *[]*i32 {
    return &self.p;
  }
}
/**
 * Dyn dest extras dest-RET dest-stamp of `*[]*i32` (assign-only;
 * do not INDEX the dangling &self.p). Named `[]*i32` local then
 * field-copy (do not init `*[]*i32` with `&[&n, &m]` — nested
 * extra lit dest extras dest-PTR still banned → CG002).
 * @return i32 — expected 7
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let n: i32 = 2;
  let m: i32 = 4;
  let inner: []*i32 = [&n, &m];
  let a: A = { p: inner };
  let x: GetPSP = a;
  let p: *[]*i32 = x.getpsp();
  return 7;
}
