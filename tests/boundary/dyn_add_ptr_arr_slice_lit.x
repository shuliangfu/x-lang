// dest extras dest-PTR stamp: nested extra lit `&[[2],[4]]` of
// PTR-outer extra empty `[]` `*[2][]i32`. Named ADDR_OF of typed
// `[2][]i32` already dest-stamps via the formal (dyn_add_ptr_arr_slice.x
// = 7). Produce: ADDR_OF of ARRAY_LIT is not VAR/INDEX/FIELD/DEREF so
// pipeline_asm_emit_addr_of_elf_c returns -99 FAST_UNHANDLED → CG002.
// Discriminant vs dest extras dest-ARRAY of SLICE extra `[2][]i32`
// (dyn_add_arr_slice.x nested ARRAY_LIT, no ADDR_OF) is PTR wrap.
// G.7: complete existing dest extras dest-PTR wrap extra SLICE of
// ARRAY dest-stamp + existing ADDR_OF emit (no second dest-PTR stamp;
// do not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (*p)[0][0] + (*p)[1][0] = 1+2+4).
// Neighborhood: dyn_add_ptr_arr_slice.x (`*[2][]i32` named) /
// dyn_add_arr_slice.x (`[2][]i32` extra lit) / dyn_add_ptr.x (`*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPASL {
  /**
   * Sum `self.v` with the first extra-SLICE element of each ARRAY row
   * of a PTR-outer extra empty `[]` `*[2][]i32`.
   * @param self SumPASL — dyn receiver (vtable wrapper rdi/x0 = data)
   * @param p *[2][]i32 — pointer to `[2]` of `[]i32`
   * @return i32 — v + (*p)[0][0] + (*p)[1][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpasl(self, p: *[2][]i32): i32;
}
struct A { v: i32 }
impl SumPASL for A {
  /**
   * Impl of SumPASL.sumpasl: INDEX each extra SLICE then add.
   * @param self A — by-value NAMED receiver
   * @param p *[2][]i32 — skip-trait extra; dest extras dest-PTR stamp of nested extra lit
   * @return i32 — self.v + (*p)[0][0] + (*p)[1][0]
   * PLATFORM: SHARED — Ubuntu gold.
   */
  function sumpasl(self: A, p: *[2][]i32): i32 {
    let x: i32 = unsafe { (*p)[0][0] };
    let y: i32 = unsafe { (*p)[1][0] };
    return self.v + x + y;
  }
}
/**
 * Dyn extra ADDR_OF of nested extra lit `&[[2],[4]]` so dest extras
 * dest-PTR stamp fires (not ADDR_OF of a typed named local).
 * @return i32 — expected 7 (1+2+4)
 * PLATFORM: SHARED — Ubuntu gold.
 */
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPASL = a;
  return x.sumpasl(&[[2], [4]]);
}
