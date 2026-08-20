// F7 leftover: dest extras dest-ARRAY of SLICE `[2][][]i32` dest-stamp
// (sit-red dyn extra nested ARRAY_LIT run=139). Produce: dest extras
// dest-ARRAY-of-SLICE wrapped slice of leaf once so dest was `[2][]i32`
// not `[2][][]i32`; nested `[[[2, 4]], [[3, 5]]]` stayed
// `(int32_t[][1][2])` into a `[][]i32*` wrapper. Store: keep
// elem=SLICE + eek=leaf + ndims=-2 + dims[0]=0 (extra wrap count;
// 0 means 1 = `[2][][]T`; ban -3). Consume: dest extras extra wraps.
// Named / UFCS / module-func with typed lets already dest-stamp via
// the formal (6). Assign-only false-green 5. Neighborhood `[2][]i32`
// already 7. Impl-match already matches at SLICE (not T001). G.7:
// complete dest extras dest-ARRAY-of-SLICE extra wraps (no second
// dest-ARRAY stamp; do not invent -3; do not add impl-match extra
// peels). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 6 (v + p[0][0][0] + p[1][0][0]
// = 1+2+3). Nested ARRAY_LIT so INDEX is dest-stamp, not peel.
// Neighborhood: dyn_add_arr_slice.x (`[2][]i32`) /
// dyn_add_slice_slice.x (`[][]i32`) /
// dyn_add_slice_slice_slice.x (`[][][]i32`) /
// dyn_add_arr_ptr_slice_slice.x (`[2]*[][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumASS {
  function sumass(self, p: [2][][]i32): i32;
}
struct A { v: i32 }
impl SumASS for A {
  function sumass(self: A, p: [2][][]i32): i32 {
    let x: i32 = p[0][0][0];
    let y: i32 = p[1][0][0];
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumASS = a;
  return x.sumass([[[2, 4]], [[3, 5]]]);
}
