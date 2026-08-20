// Leftover: UFCS dest-ARRAY `[2]Pair` extra via ARRAY_LIT (sit-red
// host-C `(struct Pair[]){(struct )}` / asm run=3 first field only).
// Produce: same-module UFCS extras called only
// typeck_coerce_init_array_vector_lit_to_decl so ARRAY dest stamped
// but STRUCT_LIT elems stayed nameless. CALL extras same produce
// (typeck_check_call_arg_types). Named local already 7 via let dest.
// Dyn dest-ARRAY extra already 7 (TYPE_DYN extras loop).
// G.7: complete UFCS extras + typeck_check_call_arg_types with
// typeck_coerce_array_lit_struct_elems_to_decl (no second STRUCT_LIT
// stamp). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0].a + p[1].b = 1+2+4).
// Neighborhood: ufcs_add_slice_named.x / dyn_add_arr_named.x.
// PLATFORM: SHARED — Ubuntu gold.

struct Pair { a: i32, b: i32 }
struct A { v: i32 }
impl A {
  function sumap(self: A, p: [2]Pair): i32 { return self.v + p[0].a + p[1].b; }
}
function main(): i32 {
  let a: A = { v: 1 };
  return a.sumap([{ a: 2, b: 3 }, { a: 4, b: 4 }]);
}
