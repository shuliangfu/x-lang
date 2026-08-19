// F7 leftover: dest-SLICE extra `[][2]Pair` (NAMED leaf of dest-SLICE-of-ARRAY).
// Produce (typeck): dest extras dest-SLICE-of-ARRAY skipped elem_elem
// kind 8, so `[[{a:2,b:4}]]` stayed TYPE_ARRAY of nameless STRUCT_LIT.
// Produce (host-C): codegen_emit_slice_of_fixed_array_layouts ran at
// prologue, so `struct xlang_slice_xlang_arr2_Pair { struct Pair (*data)[2]; }`
// preceded `struct Pair` (incomplete type BLD001).
// Store: registry elem_kind=ARRAY + elem_elem_kind=NAMED + param_name=Pair
// (skip-trait IDENT after `[][N]` already stored).
// Consume: host-C emit_call_arg_slice_abi / asm dest-SLICE wrap only when
// dest-stamped; fat layout needs Pair complete.
// Sit-red dyn extra asm=139 / host-C `(struct )` + BLD001; named local /
// UFCS already dest-stamp (asm 7) but host-C BLD001. dest-SLICE extra
// `[][2]i32` and dest-ARRAY extra `[2][]Pair` already closed.
// G.7: complete dest-SLICE-of-ARRAY reconstruct (param_name wrap named
// then wrap ARRAY then wrap slice) + same layout walker after struct defs.
// No second dest-SLICE stamp / no second layout walker.
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0].a + p[0][0].b = 1+2+4).
// Neighborhood: dyn_add_slice_arr.x / dyn_add_slice_named.x /
// dyn_add_arr_slice_named.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumSAP {
  function sumsaps(self, p: [][2]Pair): i32;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl SumSAP for A {
  function sumsaps(self: A, p: [][2]Pair): i32 {
    return self.v + p[0][0].a + p[0][0].b;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSAP = a;
  return x.sumsaps([[{ a: 2, b: 4 }]]);
}
