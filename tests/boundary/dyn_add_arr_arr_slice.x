// F7 leftover: dest extras dest-ARRAY of ARRAY extra `[2][2][]i32`
// dest-stamp+asm emit (sit-red dyn extra nested ARRAY_LIT asm 139;
// host-C already 8). Produce: dest extras dest-ARRAY wrapping SLICE
// then two ARRAY dims dest-stamps `[2][2][]i32` (host-C nested lit
// 8) but asm flatten of dest-ARRAY of ARRAY of SLICE wrote i32
// leaves (`[[[2],[4]],[[3],[5]]]` as 4×i32). INDEX of slice fat
// SIGSEGV 139; asg run=1 (zeros). Named / UFCS / module-func share
// the asm flatten (host-C 8). Typed lets of `[2][]i32` already 8
// (VAR elems). Neighborhood `[2][2]i32` already 11; `[2][]i32`
// already 7; `[2][][]i32` already 6; `[][2][]i32` already 7.
// Store: skip-trait ARRAY ndims=2 dims=[2,2] elem=SLICE eek=leaf
// already correct. Consume: flatten walk dest elem `[2][]i32`
// (ARRAY of SLICE) then per-cell glue_emit_slice_from_array_let_init
// (same writer as dest-ARRAY extra `[2][]i32`; no second flatten;
// ban -3). G.7: complete pipeline_asm_emit_array_lit_flat_elf_c
// (mega + seed + arrcopy thin). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 8 (v + p[0][0][0] + p[1][1][0]
// = 1+2+5). Nested ARRAY_LIT so flatten dest-stamp fires.
// Neighborhood: dyn_add_arr2.x (`[2][2]i32`) /
// dyn_add_arr_slice.x (`[2][]i32`) /
// dyn_add_arr_slice_slice.x (`[2][][]i32`) /
// dyn_add_slice_arr_slice.x (`[][2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumAAAS {
  function sumaaas(self, p: [2][2][]i32): i32;
}
struct A { v: i32 }
impl SumAAAS for A {
  function sumaaas(self: A, p: [2][2][]i32): i32 {
    let x: i32 = p[0][0][0];
    let y: i32 = p[1][1][0];
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumAAAS = a;
  return x.sumaaas([[[2], [4]], [[3], [5]]]);
}
