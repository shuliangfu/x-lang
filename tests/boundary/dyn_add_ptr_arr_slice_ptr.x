// F7 leftover: PTR-outer extra wrap extra PTR `*[2][]*i32`
// dest-stamp (sit-red named / dyn extra / UFCS XT001). Produce:
// extra empty `[]` after `*[N]` in param_elem_arr_need_size
// required SLICE outer so PTR outer hit wave434 deferred
// elem_kind=-1 (leaf T never committed; extra STAR after that
// also missed). Store: keep elem=ARRAY + eek=leaf + ndims>=1 +
// dims[0]=N; extra SLICE wrap COUNT in unused slot dims[ndims]
// (1 = `*[2][]T` / `*[2][]*T`; 0 = no extra SLICE = `*[2]i32` /
// `*[2]*T`); extra PTR wrap COUNT in unused slot dims[ndims+1]
// (1 = `*[2]*T` / `*[2][]*T`; 0 = no extra PTR = `*[2]i32` /
// `*[2][]T`; both slots = `*[2][]*T`; ban -3 / new field).
// Discriminant vs dest extras dest-SLICE of ARRAY extra
// `[][2][]T` / `[][2][]*T` (same unused slots) is PTR vs SLICE
// outer. Consume: ARRAY leftover extra SLICE peels leftover
// SLICE after extra ARRAY peels then extra PTR peels leftover
// PTR (PTR-or-SLICE outer walk already peels both unused
// slots); extra ADDR_OF of typed `[2][]*i32` dest-stamps via
// the formal (no dest extras dest-PTR stamp; dest extras
// dest-ARRAY-of-SLICE extra PTR already dest-stamps
// `[2][]*T`). Store-only without extra empty `[]` unused-slot
// is XT001 leftover PTR vs ARRAY / leftover PTR vs eeek=-1.
// G.7: complete skip-trait extra empty `[]` unused-slot
// scanner (ARRAY elem; SLICE or PTR outer) + existing extra
// STAR unused-slot + existing ARRAY leftover extra SLICE-then-
// PTR peels (no second dest-PTR stamp; do not invent -3).
// Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + *(*p)[0][0] + *(*p)[1][0]
// = 1+2+4). ADDR_OF of typed `[2][]*i32` so skip-trait
// dest-stamp fires. Nested `&[[&n], [&m]]` is CG002 (addr of
// temporary) — not this leaf.
// Neighborhood: dyn_add_ptr_arr_ptr.x (`*[2]*i32`) /
// dyn_add_ptr_arr_slice.x (`*[2][]i32`) /
// dyn_add_arr_slice_ptr.x (`[2][]*i32`) /
// dyn_add_slice_arr_slice_ptr.x (`[][2][]*i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumPASP {
  function sumpasp(self, p: *[2][]*i32): i32;
}
struct A { v: i32 }
impl SumPASP for A {
  function sumpasp(self: A, p: *[2][]*i32): i32 {
    let x: i32 = unsafe { *(*p)[0][0] };
    let y: i32 = unsafe { *(*p)[1][0] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumPASP = a;
  let n: i32 = 2;
  let m: i32 = 4;
  let row: [2][]*i32 = [[&n], [&m]];
  return x.sumpasp(&row);
}
