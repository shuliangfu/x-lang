// F7 leftover: dest extras dest-ARRAY of SLICE extra wrap extra
// `[2][][2][][]i32` dest-stamp. Previous leftover extra lit 139 /
// named 195 used a 5-bracket ARRAY_LIT whose innermost was `[2]`
// (ARRAY of i32). COUNT=2 dest-stamps to `[][]i32` at the leaf, so
// that lit typeck-mismatched (`expected []i32, found i32`) and the
// binary SIGSEGV'd (Darwin 139 / Ubuntu 128+11). Named INDEX on the
// half-stamped dest was 195. Produce / store / consume already live
// from dest extras dest-ARRAY of SLICE extra wrap `[2][][2][]T`
// (dims[ndims+1] extra SLICE wrap COUNT; 1 = `[2][][2][]T`; 2 =
// `[2][][2][][]T`; extra PTR of `[2][][2]*T` stays dims[ndims] —
// do not reopen). Innermost ARRAY_LIT must be `[[2]]` so dest
// extras wraps SLICE of SLICE of i32. G.7: no second dest-ARRAY
// stamp; do not invent -3; do not add impl-match extra SLICE
// peels; scanner + dest extras extra wraps already complete.
// dest extras dest-SLICE-of-SLICE extra wrap `[][][2][]T` stays
// deferred (outer must stay ARRAY). Wrapper rdi/x0 = data
// unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0][0][0][0] +
// p[1][0][1][0][0] = 1+2+4). Nested ARRAY_LIT so dest extras
// dest-stamp fires.
// Neighborhood: dyn_add_arr_slice_arr_slice.x (`[2][][2][]i32`) /
// dyn_add_arr_slice_slice.x (`[2][][]i32`) /
// dyn_add_arr_slice_arr.x (`[2][][2]i32`) /
// dyn_add_slice_arr_slice.x (`[][2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumASASS {
  function sumasass(self, p: [2][][2][][]i32): i32;
}
struct A { v: i32 }
impl SumASASS for A {
  function sumasass(self: A, p: [2][][2][][]i32): i32 {
    return self.v + p[0][0][0][0][0] + p[1][0][1][0][0];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumASASS = a;
  return x.sumasass([[[[[2]], [[3]]]], [[[[1]], [[4]]]]]);
}
