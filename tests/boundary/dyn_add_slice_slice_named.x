// F7 leftover: dest-SLICE extra `[][]Pair` dest-stamp (sit-red dyn extra
// asm 139 / host-C `(uint8_t[]){(uint8_t[]){(struct )}}`). Produce: dest
// extras dest-SLICE-of-SLICE skips elem_elem kind 8 so `[[{a:2,b:4}]]`
// stays TYPE_ARRAY of nameless STRUCT_LIT. Store: skip-trait already
// stores elem_kind=SLICE + elem_elem_kind=NAMED + param_name="Pair".
// Consume: host-C dest-SLICE wrap / asm dest wrap. Named local extra
// dest-stamps via the module-func formal. G.7: complete dest-SLICE-of-
// SLICE reconstruct (param_name wrap named then wrap slice then wrap
// slice + typeck_coerce_init_expr_to_decl). No second dest-SLICE stamp.
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0].a + p[0][0].b = 1+2+4).
// Neighborhood: dyn_add_slice_slice.x (`[][]i32`) / dyn_add_slice_named.x
// (`[]Pair`) / dyn_add_slice_arr_named.x (`[][2]Pair`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSP {
  function sumssp(self, p: [][]Pair): i32;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl SumSSP for A {
  function sumssp(self: A, p: [][]Pair): i32 {
    return self.v + p[0][0].a + p[0][0].b;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumSSP = a;
  return x.sumssp([[{ a: 2, b: 4 }]]);
}
