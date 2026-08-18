// F7 leftover: dyn `[]Pair` extra via ARRAY_LIT (sit-red run=139).
// Produce: typeck TYPE_DYN dest-SLICE extras skip elem kind 8 so
// `[{a:2,b:4}]` stays TYPE_ARRAY of nameless STRUCT_LIT; emit skips
// dest-SLICE fat wrap. Registry already stores param_name="Pair"
// (NAMED leaf of []T). Named local + UFCS dest-stamp via the
// module-func formal. G.7: complete existing dest-SLICE extras
// (param_name + find_or_alloc_named + find_or_alloc_slice +
// typeck_coerce_init_expr_to_decl). No second dest-SLICE stamp /
// ARRAY_LIT emitter. Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0].a + p[0].b = 1+2+4).
// Neighborhood: dyn_add_slice.x ([]i32) / dyn_add_named.x (Pair extra).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSP {
  function sumsp(self, p: []Pair): i32;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl SumSP for A {
  function sumsp(self: A, p: []Pair): i32 { return self.v + p[0].a + p[0].b; }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumSP = a;
  return x.sumsp([{ a: 2, b: 4 }]);
}
