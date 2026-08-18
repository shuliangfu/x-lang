// F7 leftover: dyn NAMED extra via STRUCT_LIT (sit-red host-C `(struct )`
// compile fail / asm run=162). Produce: typeck TYPE_DYN extras stamped
// FLOAT_LIT + dest-SLICE only; `{a:2,b:4}` stayed nameless so host-C
// emit used empty struct tag. Wrapper already `struct Pair a1`. Named
// local extra already 7. G.7: complete existing dyn extras loop with
// param_name + find_or_alloc_named + typeck_coerce_init_struct_lit_to_decl
// (no second STRUCT_LIT stamp). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + a + b = 1+2+4).
// Neighborhood: dyn_ret_named.x (NAMED ret), dyn_add_slice.x (SLICE extra).
// PLATFORM: SHARED — Ubuntu gold.

trait SumP {
  function sump(self, p: Pair): i32;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl SumP for A {
  function sump(self: A, p: Pair): i32 { return self.v + p.a + p.b; }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumP = a;
  return x.sump({ a: 2, b: 4 });
}
