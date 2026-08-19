// F7 leftover: dest extras dest-SLICE of ARRAY extra `[][2][]i32`
// dest-stamp (sit-red dyn extra nested ARRAY_LIT run=139). Produce:
// dest extras dest-SLICE-of-ARRAY wrapped ARRAY of leaf once so dest
// was `[][2]i32` not `[][2][]i32` (or dest extras skipped because
// store set elem_kind=-1). Nested `[[[2], [4]]]` stayed unstamped.
// Store: keep elem=ARRAY + eek=leaf + ndims=1 + dims[0]=2; extra wrap
// COUNT in unused slot dims[ndims] (1 = `[][2][]T`; 2 = `[][2][][]T`;
// 0 means no extra wrap = `[][2]i32`; ban -3 / new field). Consume:
// dest extras extra wraps of SLICE of leaf then ARRAY wrap then outer
// SLICE; impl-match ARRAY walk extra peels leftover SLICE. Named /
// UFCS / module-func already dest-stamp via the formal (6). Assign
// already 6. Neighborhood `[][2]i32` already 7. G.7: complete skip-
// trait store + impl-match extra peel + dest extras dest-SLICE-of-ARRAY
// extra wraps (no second dest-SLICE stamp; do not invent -3). Wrapper
// rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0][0] + p[0][1][0]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires (typed
// lets dyn extra was panic 1).
// Neighborhood: dyn_add_slice_arr.x (`[][2]i32`) /
// dyn_add_slice_slice.x (`[][]i32`) /
// dyn_add_arr_slice_slice.x (`[2][][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSAS {
  function sumsas(self, p: [][2][]i32): i32;
}
struct A { v: i32 }
impl SumSAS for A {
  function sumsas(self: A, p: [][2][]i32): i32 {
    let x: i32 = p[0][0][0];
    let y: i32 = p[0][1][0];
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSAS = a;
  return x.sumsas([[[2], [4]]]);
}
