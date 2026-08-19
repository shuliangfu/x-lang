// F7 leftover: dest-ARRAY `[2]Pair` extra via ARRAY_LIT (sit-red host-C
// `(uint8_t[]){(struct )}` compile fail). Produce: typeck TYPE_DYN extras
// stamped FLOAT_LIT / dest-SLICE / dest-NAMED only; `[{a:2,b:3},{a:4,b:4}]`
// stayed TYPE_ARRAY of nameless STRUCT_LIT. Registry already stores
// param_name="Pair" + param_array_ndims/dims (NAMED leaf of [N]T). Named
// local extra already 7; asm dyn already 7 (field stores by name).
// G.7: complete existing extras loop with param_elem / param_name +
// find_or_alloc_named + find_or_alloc_array + typeck_coerce_init_expr_to_decl
// (no second ARRAY_LIT / STRUCT_LIT stamp). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0].a + p[1].b = 1+2+4).
// Neighborhood: dyn_add_arr1.x ([2]i32) / dyn_add_named.x (Pair extra) /
// dyn_add_slice_named.x ([]Pair extra). UFCS extras are a different produce.
// PLATFORM: SHARED — Ubuntu gold.

trait SumAP {
  function sumap(self, p: [2]Pair): i32;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl SumAP for A {
  function sumap(self: A, p: [2]Pair): i32 { return self.v + p[0].a + p[1].b; }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumAP = a;
  return x.sumap([{ a: 2, b: 3 }, { a: 4, b: 4 }]);
}
