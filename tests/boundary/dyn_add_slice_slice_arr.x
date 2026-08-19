// F7 leftover: dest extras dest-SLICE of SLICE extra `[][][2]i32`
// dest-stamp (sit-red dyn extra T001). Produce: dest extras dest-
// SLICE-of-SLICE wrapped slice of leaf twice so dest was `[][]i32`
// not `[][][2]i32`; impl-match leftover ARRAY vs eeek=leaf is T001
// (named / UFCS dest-stamp via the formal 7; dyn extra never
// reached dest extras). Nested `[[[2, 4]]]` stayed unstamped.
// Store: skip-trait after `[][]` then `[M]` already keeps
// elem=SLICE + eek=leaf + ndims>=1 + dims[0]=M (wave437 pending
// LBRACKET dim collector; extra PTR stays ndims==0 dims[0]; extra
// SLICE stays ndims=-2; ban -3 / new field). Consume: dest extras
// wrap ARRAY of leaf inner-first then wrap SLICE twice; impl-match
// extra ARRAY peels leftover ARRAY after leftover SLICE.
// Discriminant: ndims==0 extra PTR = `[][]*T`; ndims>=1 inner
// ARRAY = `[][][2]T`; ndims==-2 extra SLICE = `[][][]T`. Extra
// wrap `[][][2][2]i32` covered by prefix_arr_more collecting
// further dims. Neighborhood `[][]i32` already 7; `[2][][2]i32`
// already 7; `[][2]i32` already 7; `[][]*i32` already 7.
// G.7: complete impl-match extra ARRAY peels + dest extras dest-
// SLICE-of-SLICE extra ARRAY wraps + codegen_emit_slice_of_fixed_
// array_layouts SLICE-of-(SLICE-of-ARRAY) fat (no second dest-SLICE
// stamp / no second layout walker; do not invent -3). Wrapper
// rdi/x0 = data unchanged. Host-C sit-red incomplete
// `xlang_slice_xlang_slice_xlang_arr2_int32_t`.
// Expected: compile = 0, run = 7 (v + p[0][0][0] + p[0][0][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_slice_slice.x (`[][]i32`) /
// dyn_add_arr_slice_arr.x (`[2][][2]i32`) /
// dyn_add_slice_arr.x (`[][2]i32`) /
// dyn_add_slice_slice_ptr.x (`[][]*i32`) /
// dyn_add_slice_slice_slice.x (`[][][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSA {
  function sumssa(self, p: [][][2]i32): i32;
}
struct A { v: i32 }
impl SumSSA for A {
  function sumssa(self: A, p: [][][2]i32): i32 {
    return self.v + p[0][0][0] + p[0][0][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSSA = a;
  return x.sumssa([[[2, 4]]]);
}
