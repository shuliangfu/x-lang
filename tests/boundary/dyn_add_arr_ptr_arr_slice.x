// F7 leftover: dest extras dest-ARRAY of PTR extra empty `[]`
// `[2]*[2][]i32` dest-stamp (sit-red extra ADDR_OF of typed
// `[2][]i32` dest-stamps via the formal = false green leftover
// skip eek=-1; nested ARRAY_LIT dest extras wrap-once dest-stamps
// `[2]*[2]i32` → CG002). Produce: extra empty `[]` after `[K]*[N]`
// in param_elem_arr_need_size required SLICE or PTR outer, so
// PTR-elem + ARRAY outer hit wave434 deferred elem_kind=-1
// (leaf T never committed). dest extras dest-ARRAY-of-PTR extra
// SLICE wraps already live (dims[ndims]). dest extras dest-SLICE
// of PTR extra `[]*[2][]T` and PTR-elem + PTR-outer extra
// `**[2][]T` already dest-stamp. Store: keep elem=PTR + eek=leaf
// + ndims>=1 + dims[0]=N; extra SLICE wrap COUNT in unused slot
// dims[ndims] (1 = `[2]*[2][]T`; 2 = `[2]*[2][][]T`; 0 = no extra
// SLICE = `[2]*[2]i32` / `[2]*[2]*T`); extra PTR wrap COUNT in
// unused slot dims[ndims+1] (1 = `[2]*[2]*T` / `[2]*[2][]*T`;
// 0 = no extra PTR = `[2]*[2]i32` / `[2]*[2][]T`; both slots =
// `[2]*[2][]*T`; ban -3 / new field). Discriminant vs dest extras
// dest-SLICE of PTR extra `[]*[2][]T` / PTR-elem + PTR-outer
// `**[2][]T` (same unused slot) is ARRAY vs SLICE vs PTR outer.
// Consume: leftover PTR vs eek=PTR is not T001; extra ADDR_OF of
// typed `[2][]i32` dest-stamps via the formal (no dest extras
// dest-PTR stamp); dest extras dest-ARRAY-of-PTR extra SLICE
// wraps dest-stamp nested ARRAY_LIT. G.7: complete skip-trait
// extra empty `[]` unused-slot scanner (PTR elem; ARRAY or SLICE
// or PTR outer) + existing dest extras dest-ARRAY-of-PTR extra
// SLICE wraps (no second dest-ARRAY stamp; do not invent -3).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 6 (v + (*p[0])[0][0] + (*p[1])[0][0]
// = 1+2+3). ADDR_OF of typed `[2][]i32` so dest extras dest-stamp
// fires. Neighborhood: dyn_add_arr_ptr_arr_ptr.x (`[2]*[2]*i32`) /
// dyn_add_arr_ptr_arr.x (`[2]*[2]i32`) /
// dyn_add_slice_ptr_arr_slice.x (`[]*[2][]i32`) /
// dyn_add_ptr_ptr_arr_slice.x (`**[2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumAPAS {
  /**
   * Sum `self.v` with the first element of each extra SLICE in
   * a dest extras dest-ARRAY of PTR extra `[2]*[2][]i32`.
   * @param self SumAPAS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @param p [2]*[2][]i32 — array of pointer to `[2]` of `[]i32`
   * @return i32 — v + (*p[0])[0][0] + (*p[1])[0][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumapas(self, p: [2]*[2][]i32): i32;
}
struct A { v: i32 }
impl SumAPAS for A {
  /**
   * Impl of SumAPAS.sumapas: INDEX each extra SLICE then add.
   * @param self A — by-value NAMED receiver
   * @param p [2]*[2][]i32 — skip-trait extra; dest-stamps via the formal
   * @return i32 — self.v + (*p[0])[0][0] + (*p[1])[0][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumapas(self: A, p: [2]*[2][]i32): i32 {
    let x: i32 = unsafe { (*p[0])[0][0] };
    let y: i32 = unsafe { (*p[1])[0][0] };
    return self.v + x + y;
  }
}
/**
 * Dyn extra ADDR_OF of typed `[2][]i32` so dest extras dest-stamp fires.
 * @return i32 — expected 6 (1+2+3)
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumAPAS = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let n2: i32 = 3;
  let m2: i32 = 5;
  let r0: [2][]i32 = [[n], [m]];
  let r1: [2][]i32 = [[n2], [m2]];
  return x.sumapas([&r0, &r1]);
}
