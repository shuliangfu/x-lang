// F7 leftover: host-C `[]*i32` type_to_c_repr tag sanitizer.
// Produce: TYPE_SLICE type_to_c_repr copied `int32_t *` raw into the fat
// tag → `struct xlang_slice_int32_t *` (a pointer, not a tag). Named
// local / UFCS / dyn extra all sit-red host-C; asm let-only already 7.
// Store: sanitized tag `struct xlang_slice_int32_t_p`.
// Consume: locals / params / compound lits + fat layout `{ E **data }`.
// G.7: complete type_to_c_repr SLICE (ARRAY already `*`→`_p`) + complete
// codegen_emit_slice_of_fixed_array_layouts PTR elem (no second emitter).
// INDEX of []*i32 / [2]*i32 remains asm CG002 leftover.
// Expected: compile = 0, run = 7 (assign-only; no INDEX).
// Neighborhood: dyn_add_slice.x / named [2]*i32 let-only.
// PLATFORM: SHARED — Ubuntu gold.

function main(): i32 {
  let a: i32 = 2;
  let b: i32 = 4;
  let p: []*i32 = [&a, &b];
  return 7;
}
