// F7 leftover: PTR-elem + PTR-outer extra empty `[]`
// `**[2][]i32` dest-stamp (sit-red extra / named dest-stamp via
// the formal — leftover skip eek=-1 false green; UFCS named A
// dest-stamps via the formal; dyn UFCS T001 is receiver vs A,
// not this leaf — same as closed `**[2]*T`). Produce: extra
// empty `[]` after `**[N]` in param_elem_arr_need_size required
// ARRAY or SLICE outer, or ARRAY-elem PTR outer, so PTR-elem +
// PTR outer hit wave434 deferred elem_kind=-1 (leaf T never
// committed). dest extras dest-SLICE of PTR extra `[]*[2][]T`
// and PTR-outer extra wrap `*[2][]T` already dest-stamp. Store:
// keep elem=PTR + eek=leaf + ndims>=1 + dims[0]=N; extra SLICE
// wrap COUNT in unused slot dims[ndims] (1 = `**[2][]T`; 2 =
// `**[2][][]T`; 0 = no extra SLICE = `**[2]i32` / `**[2]*T`);
// extra PTR wrap COUNT in unused slot dims[ndims+1] (1 =
// `**[2]*T` / `**[2][]*T`; 0 = no extra PTR = `**[2]i32` /
// `**[2][]T`; both slots = `**[2][]*T`; ban -3 / new field).
// Discriminant vs dest extras dest-SLICE of PTR extra
// `[]*[2][]T` / PTR-outer `*[2][]T` (same unused slot) is PTR
// vs SLICE outer AND PTR vs ARRAY elem. Consume: leftover PTR
// vs eek=PTR is not T001 (PTR-or-SLICE outer walk matches at
// leftover PTR); extra ADDR_OF of typed `*[2][]i32` dest-stamps
// via the formal (no dest extras dest-PTR stamp). G.7: complete
// skip-trait extra empty `[]` unused-slot scanner (ARRAY or PTR
// elem; SLICE or PTR outer) + existing unused-slot extra PTR
// wrap (no second dest-PTR stamp; do not invent -3). Wrapper
// rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (**p)[0][0] + (**p)[1][0]
// = 1+2+4). ADDR_OF of typed `*[2][]i32` so skip-trait
// dest-stamp fires. Neighborhood: dyn_add_ptr_ptr_arr_ptr.x
// (`**[2]*i32`) / dyn_add_ptr_arr_slice.x (`*[2][]i32`) /
// dyn_add_ptr_arr_slice_ptr.x (`*[2][]*i32`) /
// dyn_add_slice_ptr_arr_slice.x (`[]*[2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPPAS {
  /**
   * Sum `self.v` with the first element of each extra SLICE in
   * a PTR-elem + PTR-outer extra `**[2][]i32`.
   * @param self SumPPAS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @param p **[2][]i32 — pointer to pointer to `[2]` of `[]i32`
   * @return i32 — v + (**p)[0][0] + (**p)[1][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumppas(self, p: **[2][]i32): i32;
}
struct A { v: i32 }
impl SumPPAS for A {
  /**
   * Impl of SumPPAS.sumppas: INDEX each extra SLICE then add.
   * @param self A — by-value NAMED receiver
   * @param p **[2][]i32 — skip-trait extra; dest-stamps via the formal
   * @return i32 — self.v + (**p)[0][0] + (**p)[1][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumppas(self: A, p: **[2][]i32): i32 {
    let x: i32 = unsafe { (**p)[0][0] };
    let y: i32 = unsafe { (**p)[1][0] };
    return self.v + x + y;
  }
}
/**
 * Dyn extra ADDR_OF of typed `*[2][]i32` so skip-trait dest-stamp fires.
 * @return i32 — expected 7 (1+2+4)
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPPAS = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let row: [2][]i32 = [[n], [m]];
  let rowp: *[2][]i32 = &row;
  return x.sumppas(&rowp);
}
