// F7 leftover: PTR-outer extra empty `[]` `*[][2][]i32`
// dest-stamp (sit-red extra / named dest-stamp via the formal
// — leftover skip eek=-1 false green; nested extra lit dest
// extras dest-PTR still banned → CG002). Produce: extra empty
// `[]` after `*[][N]` in param_elem_arr_need_size required
// ARRAY or SLICE outer so PTR outer hit wave434 deferred
// elem_kind=-1 (leaf T never committed). dest extras dest-ARRAY
// of SLICE extra wrap `[2][][2][]T` and dest extras dest-SLICE
// of SLICE extra wrap `[][][2][]T` already dest-stamp. Store:
// keep elem=SLICE + eek=leaf + ndims>=1 + dims[0]=N; extra
// SLICE wrap COUNT in unused slot dims[ndims+1] (1 =
// `*[][2][]T`; 2 = `*[][2][][]T`; 0 = no extra wrap =
// `*[][2]i32` / `*[][2]*T`); extra PTR wrap COUNT in unused
// slot dims[ndims] (1 = `*[][2]*T` / `*[][2][]*T`; 0 = no
// extra PTR = `*[][2]i32` / `*[][2][]T`; both slots =
// `*[][2][]*T`; ban -3 / new field). Discriminant vs dest
// extras dest-ARRAY of SLICE extra wrap `[2][][2][]T` / dest
// extras dest-SLICE of SLICE extra wrap `[][][2][]T` (same
// unused slot) is PTR vs ARRAY vs SLICE outer. Consume:
// leftover PTR vs eek=SLICE is not T001 (walk peels leftover
// SLICE then extra ARRAY then extra SLICE then extra PTR);
// extra ADDR_OF of typed `[][2][]i32` dest-stamps via the
// formal (no dest extras dest-PTR stamp). Nested extra lit
// dest extras dest-PTR stamp stays deferred. G.7: complete
// skip-trait extra empty `[]` unused-slot scanner (SLICE
// elem; ARRAY or SLICE or PTR outer) + existing leftover
// extra SLICE peels (no second dest-PTR stamp; do not invent
// -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (*p)[0][0][0] +
// (*p)[0][1][0] = 1+2+4). ADDR_OF of typed `[][2][]i32` so
// dest extras dest-stamp fires via the formal.
// Neighborhood: dyn_add_ptr_slice_arr_ptr.x (`*[][2]*i32`) /
// dyn_add_slice_arr_slice.x (`[][2][]i32`) /
// dyn_add_arr_slice_arr_slice.x (`[2][][2][]i32`) /
// dyn_add_slice_slice_arr_slice.x (`[][][2][]i32`) /
// dyn_add_ptr_arr_slice.x (`*[2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPSAS {
  /**
   * Sum `self.v` with the first element of each extra SLICE in
   * a PTR-outer extra empty `[]` `*[][2][]i32`.
   * @param self SumPSAS — dyn receiver (vtable wrapper rdi/x0 = data)
   * @param p *[][2][]i32 — pointer to slice of `[2]` of `[]i32`
   * @return i32 — v + (*p)[0][0][0] + (*p)[0][1][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpsas(self, p: *[][2][]i32): i32;
}
struct A { v: i32 }
impl SumPSAS for A {
  /**
   * Impl of SumPSAS.sumpsas: INDEX each extra SLICE then add.
   * @param self A — by-value NAMED receiver
   * @param p *[][2][]i32 — skip-trait extra; dest-stamps via the formal
   * @return i32 — self.v + (*p)[0][0][0] + (*p)[0][1][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpsas(self: A, p: *[][2][]i32): i32 {
    let x: i32 = unsafe { (*p)[0][0][0] };
    let y: i32 = unsafe { (*p)[0][1][0] };
    return self.v + x + y;
  }
}
/**
 * Dyn extra ADDR_OF of typed `[][2][]i32` so dest extras dest-stamp
 * fires via the formal (no dest extras dest-PTR stamp).
 * @return i32 — expected 7 (1+2+4)
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPSAS = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let row: [][2][]i32 = [[[n], [m]]];
  return x.sumpsas(&row);
}
