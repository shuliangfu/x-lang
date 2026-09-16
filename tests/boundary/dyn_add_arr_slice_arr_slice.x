// F7 leftover: dest extras dest-ARRAY of SLICE extra wrap
// `[2][][2][]i32` dest-stamp (sit-red dyn extra nested ARRAY_LIT
// run=139). Produce: extra empty `[]` after `[N][][M]` (ndims>=1,
// ARRAY outer, elem=SLICE) set elem_kind=-1 so dest extras skipped
// (dest never extra-wrapped SLICE of leaf before inner ARRAY;
// dest-stamps `[2][][2]i32` not `[2][][2][]i32`). Named / UFCS
// dest-stamp via the formal (7). Store: keep elem=SLICE + eek=leaf
// + ndims>=1; extra SLICE wrap COUNT in unused slot dims[ndims+1]
// (1 = `[2][][2][]T`; 2 = `[2][][2][][]T`; 0 = no extra wrap =
// `[2][][2]T`). Extra PTR of `[2][][2]*T` stays dims[ndims] — do
// not reopen that encoding. ndims=-2 would lose [M] (ban -3 /
// reuse of dims[0..ndims-1]). Discriminant vs dest extras dest-
// SLICE of ARRAY extra PTR `[][2]*T` (same unused slot) is
// elem_kind SLICE vs ARRAY AND param kind ARRAY vs SLICE. Consume:
// dest extras wrap extra SLICE of leaf extra times then wrap ARRAY
// inner-first then wrap SLICE then ARRAY. ARRAY leftover impl-match
// leftover SLICE vs eek=SLICE is not T001 (do not add extra SLICE
// peels). dest extras dest-SLICE-of-SLICE extra wrap `[][][2][]T`
// stays deferred (outer must stay ARRAY). G.7: complete skip-trait
// store + dest extras dest-ARRAY-of-SLICE extra SLICE wraps (no
// second dest-ARRAY stamp; do not invent -3; do not add impl-match
// extra SLICE peels). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0][0][0] + p[1][0][1][0]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_arr_slice_arr.x (`[2][][2]i32`) /
// dyn_add_arr_slice_slice.x (`[2][][]i32`) /
// dyn_add_slice_arr_slice.x (`[][2][]i32`) /
// dyn_add_arr_slice_arr_ptr.x (`[2][][2]*i32`) /
// dyn_add_arr_slice.x (`[2][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumASAS {
  function sumasas(self, p: [2][][2][]i32): i32;
}
struct A { v: i32 }
impl SumASAS for A {
  function sumasas(self: A, p: [2][][2][]i32): i32 {
    return self.v + p[0][0][0][0] + p[1][0][1][0];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumASAS = a;
  return x.sumasas([[[[2], [3]]], [[[1], [4]]]]);
}
