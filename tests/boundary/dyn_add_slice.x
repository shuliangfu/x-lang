// F7 leftover: dyn `[]i32` extra via ARRAY_LIT (sit-red asm=1 / host-C=139).
// Produce: typeck TYPE_DYN extras stamped FLOAT_LIT only; ARRAY_LIT stayed
// TYPE_ARRAY so emit_call_arg_slice_abi / asm call-args skipped dest-SLICE
// fat wrap. Named local + static UFCS already 7.
// G.7: complete existing dyn extras loop with
// typeck_coerce_init_slice_from_array (no second ARRAY_LIT emitter).
// Expected: compile = 0, run = 7 (v + p[0] + p[1] = 1+2+4).
// Neighborhood: dyn_add_arr1.x (`[2]i32`), dyn_add.x (i32 extra).
// PLATFORM: SHARED — Ubuntu gold.

trait SumS {
  function sums(self, p: []i32): i32;
}
struct A { v: i32 }
impl SumS for A {
  function sums(self: A, p: []i32): i32 { return self.v + p[0] + p[1]; }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumS = a;
  return x.sums([2, 4]);
}
