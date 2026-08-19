// F7 leftover: dest-SLICE extra `[][]i32` dest-stamp (sit-red dyn extra
// asm 139 / host-C 139). Produce: dest extras dest-SLICE skips elem
// kind 11 so `[[2, 4]]` stays TYPE_ARRAY of ARRAY (no dest-SLICE stamp).
// Store: skip-trait already stores elem_kind=SLICE + elem_elem_kind=leaf
// after `[]` then `[]`. Consume: host-C dest-SLICE wrap / asm dest wrap.
// Named local extra already dest-stamps via the module-func formal (7).
// G.7: complete dest-SLICE extras (wrap slice of leaf then wrap slice +
// typeck_coerce_init_expr_to_decl). No second dest-SLICE stamp.
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0] + p[0][1] = 1+2+4).
// Neighborhood: dyn_add_slice.x (`[]i32`) / dyn_add_slice_arr.x
// (`[][2]i32`) / dyn_add_slice_named.x (`[]Pair`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSS {
  function sumss(self, p: [][]i32): i32;
}
struct A { v: i32 }
impl SumSS for A {
  function sumss(self: A, p: [][]i32): i32 {
    return self.v + p[0][0] + p[0][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumSS = a;
  return x.sumss([[2, 4]]);
}
