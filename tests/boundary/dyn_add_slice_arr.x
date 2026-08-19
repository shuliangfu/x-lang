// F7 leftover: dest-SLICE extra `[][2]i32` (ARRAY elem of dest-SLICE).
// Produce: typeck TYPE_DYN dest-SLICE extras skip elem kind 10, so
// `[[2, 4]]` stays TYPE_ARRAY of ARRAY (no dest-SLICE wrap).
// Store: registry param_elem_elem_kind + param_elem_array_ndims/dims
// (already stored by skip-trait after `[]` then `[N]`).
// Consume: host-C emit_call_arg_slice_abi / asm dest-SLICE wrap.
// Sit-red asm=1 (panic) / host-C=139. Named local extra already dest-stamps.
// G.7: complete dest-SLICE extras (elem_elem + elem_array wrap then
// typeck_coerce_init_expr_to_decl). No second dest-SLICE stamp.
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0] + p[0][1] = 1+2+4).
// Neighborhood: dyn_add_slice.x / dyn_add_arr2.x / dyn_add_slice_named.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumSA {
  function sumsa(self, p: [][2]i32): i32;
}
struct A { v: i32 }
impl SumSA for A {
  function sumsa(self: A, p: [][2]i32): i32 {
    return self.v + p[0][0] + p[0][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumSA = a;
  return x.sumsa([[2, 4]]);
}
