// Leftover twin: UFCS dest-SLICE `[]Pair` extra via ARRAY_LIT (sit-red
// host-C `__xlang_sp` + `(struct )` / asm run=2). Same produce as
// ufcs_add_arr_named.x: extras dest-stamp ARRAY/SLICE dest but not
// STRUCT_LIT elems. G.7: same typeck_coerce_array_lit_struct_elems_to_decl
// on the UFCS extras loop. No second dest-SLICE stamp.
// Expected: compile = 0, run = 7 (v + p[0].a + p[0].b = 1+2+4).
// Neighborhood: ufcs_add_arr_named.x / dyn_add_slice_named.x.
// PLATFORM: SHARED — Ubuntu gold.

struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl A {
  function sumsp(self: A, p: []Pair): i32 { return self.v + p[0].a + p[0].b; }
}
function main(): i32 {
  let a: A = { v: 1 };
  return a.sumsp([{ a: 2, b: 4 }]);
}
