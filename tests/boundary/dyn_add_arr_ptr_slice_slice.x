// F7 leftover: dest extras dest-ARRAY of PTR `[2]*[][]i32` dest-stamp
// (sit-red dyn extra T001 impl param type mismatch). Produce: ARRAY+PTR
// impl-match peeled ndims=-2 once (pelem still SLICE vs eeek=leaf) AND
// dest extras dest-ARRAY-of-PTR wrapped SLICE of leaf once so dest would
// be `[2]*[]i32` not `[2]*[][]i32` after T001. Store: keep elem=PTR +
// eek=leaf + ndims=-2 + dims[0]=2 (extra wrap count; 0 means 1 =
// `[2]*[]T`; ban -3). Consume: dest extras extra wraps. Named / UFCS /
// module-func already dest-stamp via the formal (7). Assign-only
// false-green 7. Neighborhood `[2]*[]i32` dyn extra already 6.
// G.7: complete ARRAY+PTR impl-match extra peels + dest extras
// dest-ARRAY-of-PTR extra wraps (no second dest-ARRAY stamp; do not
// invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 6 (v + (*p[0])[0][0] + (*p[1])[0][0]
// = 1+2+3).
// Neighborhood: dyn_add_arr_ptr_arr.x (`[2]*[2]i32`) /
// dyn_add_slice_ptr_slice_slice.x (`[]*[][]i32`) /
// dyn_add_arr_slice.x (`[2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumAPSS {
  function sumapss(self, p: [2]*[][]i32): i32;
}
struct A { v: i32 }
impl SumAPSS for A {
  function sumapss(self: A, p: [2]*[][]i32): i32 {
    let x: i32 = unsafe { (*p[0])[0][0] };
    let y: i32 = unsafe { (*p[1])[0][0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumAPSS = a;
  let r0: [][]i32 = [[2, 4]];
  let r1: [][]i32 = [[3, 5]];
  return x.sumapss([&r0, &r1]);
}
