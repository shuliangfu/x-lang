// F7 leftover: dest extras dest-ARRAY of SLICE extra `[2][]*i32`
// dest-stamp (sit-red dyn extra nested ARRAY_LIT run=139). Produce:
// dest extras dest-ARRAY-of-SLICE wrapped slice of leaf once so dest
// was `[2][]i32` not `[2][]*i32`. Extra STAR after `[N][]` hit
// token_to_type_kind=-1 then want_param_ty=0 so eek never captured;
// impl-match still matches at SLICE (not T001). Nested
// `[[&n, &n], [&m, &m]]` stayed unstamped. Named / UFCS / typed
// lets already dest-stamp via the formal (6/7). Neighborhood
// `[2][]i32` already 7; `[2][][]i32` already 6; `[][2]*i32`
// already 7; `[2]*i32` already 7 via ADDR_OF. Store: keep
// elem=SLICE + eek=leaf + ndims=0; extra PTR wrap COUNT in unused
// slot dims[0] (1 = `[2][]*T`; 0 = no extra PTR = `[2][]i32`;
// extra SLICE stays ndims=-2; ban -3 / new field). Consume: dest
// extras wrap PTR of leaf extra times then wrap SLICE then ARRAY.
// Outer must be ARRAY so `[][]*T` dest-SLICE-of-SLICE extra PTR
// stays deferred. G.7: complete skip-trait store + dest extras
// dest-ARRAY-of-SLICE extra PTR wraps (no second dest-ARRAY stamp;
// do not invent -3; do not add impl-match extra PTR peels).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *p[0][0] + *p[1][1]
// = 1+2+4). Nested ARRAY_LIT so dest extras dest-stamp fires.
// Neighborhood: dyn_add_arr_slice.x (`[2][]i32`) /
// dyn_add_arr_slice_slice.x (`[2][][]i32`) /
// dyn_add_slice_arr_ptr.x (`[][2]*i32`) /
// dyn_add_arr1.x (`[2]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumASPtr {
  function sumasp(self, p: [2][]*i32): i32;
}
struct A { v: i32 }
impl SumASPtr for A {
  function sumasp(self: A, p: [2][]*i32): i32 {
    let x: i32 = unsafe { *p[0][0] };
    let y: i32 = unsafe { *p[1][1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumASPtr = a;
  let n: i32 = 2;
  let m: i32 = 4;
  return x.sumasp([[&n, &n], [&m, &m]]);
}
