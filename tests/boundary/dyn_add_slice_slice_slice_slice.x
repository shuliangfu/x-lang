// F7 leftover: dest-SLICE extra `[][][][]i32` dest-stamp (sit-red dyn
// extra / named extra T001 method parameter type mismatch). Produce:
// skip-trait after `[][][]` then `[` then `]` re-applied ndims=-2
// (idempotent) so extra wrap count stayed 1; impl-match peeled once
// while pipeline pelem was still SLICE vs eek=leaf. Store: keep
// elem=SLICE + eek=leaf + ndims=-2 + dims[0]=2 (extra wrap count;
// 0 means 1 = 3-layer). Consume: impl-match extra peels / dest extras
// extra wraps. UFCS / module-func already dest-stamp via the formal
// (7 / 6). G.7: complete skip-trait scanner + SLICE-of-SLICE walk +
// dest-SLICE-of-SLICE wrap (no second dest-SLICE stamp; do not invent
// -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0][0][0] + p[0][0][0][1]
// = 1+2+4).
// Neighborhood: dyn_add_slice_slice_slice.x (`[][][]i32`) /
// dyn_add_slice_slice.x (`[][]i32`) / dyn_add_slice_ptr_slice.x
// (`[]*[]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSSS {
  function sumssss(self, p: [][][][]i32): i32;
}
struct A { v: i32 }
impl SumSSSS for A {
  function sumssss(self: A, p: [][][][]i32): i32 {
    return self.v + p[0][0][0][0] + p[0][0][0][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSSSS = a;
  return x.sumssss([[[[2, 4]]]]);
}
