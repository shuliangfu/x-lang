// F7 leftover: dest extras dest-SLICE of SLICE extra wrap
// `[][][2][]i32` dest-stamp (sit-red dyn extra nested ARRAY_LIT
// compile=0 run=1 panic). Produce: extra empty `[]` after `[][][M]`
// (ndims>=1, SLICE outer, elem=SLICE) set elem_kind=-1 so dest
// extras skipped (dest never extra-wrapped SLICE of leaf before
// inner ARRAY; extra stayed `int32_t[][1][2][1]`). Named / UFCS
// dest-stamp via the formal (7). Store: keep elem=SLICE + eek=leaf
// + ndims>=1; extra SLICE wrap COUNT in unused slot dims[ndims+1]
// (1 = `[][][2][]T`; 2 = `[][][2][][]T`; 0 = no extra wrap =
// `[][][2]T`). Extra PTR of `[][][2]*T` stays dims[ndims] — do
// not reopen that encoding. ndims=-2 would lose [M] (ban -3 /
// reuse of dims[0..ndims-1]). Discriminant vs dest extras dest-
// ARRAY of SLICE extra wrap `[2][][2][]T` (same unused slot) is
// SLICE vs ARRAY outer. Consume: dest extras wrap extra SLICE of
// leaf extra times then wrap ARRAY inner-first then wrap SLICE
// twice. Store-only without impl-match extra SLICE peels is T001
// leftover SLICE vs eeek=leaf after extra ARRAY peels. G.7:
// complete skip-trait store + impl-match extra SLICE peels + dest
// extras dest-SLICE-of-SLICE extra SLICE wraps (no second dest-
// SLICE stamp; do not invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0][0][0] + p[0][0][1][0]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_slice_slice_arr.x (`[][][2]i32`) /
// dyn_add_arr_slice_arr_slice.x (`[2][][2][]i32`) /
// dyn_add_slice_arr_slice.x (`[][2][]i32`) /
// dyn_add_slice_slice.x (`[][]i32`) /
// dyn_add_slice_slice_arr_ptr.x (`[][][2]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSAS {
  function sumssas(self, p: [][][2][]i32): i32;
}
struct A { v: i32 }
impl SumSSAS for A {
  function sumssas(self: A, p: [][][2][]i32): i32 {
    return self.v + p[0][0][0][0] + p[0][0][1][0];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSSAS = a;
  return x.sumssas([[[[2], [4]]]]);
}
