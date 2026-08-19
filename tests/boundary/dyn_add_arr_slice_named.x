// F7 leftover: dest-ARRAY extra `[2][]Pair` (NAMED leaf of dest-ARRAY-of-SLICE).
// Produce: dest extras dest-ARRAY-of-SLICE skipped elem_elem kind 8, so
// `[[{a:2,b:3}],[{a:4,b:4}]]` stayed TYPE_ARRAY of nameless STRUCT_LIT.
// Store: registry elem_kind=SLICE + elem_elem_kind=NAMED + param_name=Pair
// (skip-trait IDENT after `[N][]` already stored).
// Consume: host-C / asm dest-ARRAY of SLICE wrap only when dest-stamped.
// Sit-red dyn extra asm=139 / host-C=139 (`(uint8_t[]){(struct )}`).
// Named local / UFCS already dest-stamp (7). dest-ARRAY extra `[2][]i32`
// already closed. dest-SLICE extra `[][2]Pair` leftover (host-C layout
// order of `struct xlang_slice_xlang_arr2_Pair` before `struct Pair`).
// G.7: complete dest-ARRAY-of-SLICE reconstruct (named then wrap slice).
// No second dest-ARRAY stamp. Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0].a + p[1][0].b = 1+2+4).
// Neighborhood: dyn_add_arr_slice.x / dyn_add_arr_named.x / dyn_add_slice_named.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumASN {
  function sumasn(self, p: [2][]Pair): i32;
}
struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl SumASN for A {
  function sumasn(self: A, p: [2][]Pair): i32 {
    return self.v + p[0][0].a + p[1][0].b;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumASN = a;
  return x.sumasn([[{ a: 2, b: 3 }], [{ a: 4, b: 4 }]]);
}
