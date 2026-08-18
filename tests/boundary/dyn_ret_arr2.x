// F7 leftover: asm dest `[2][2]i32` copy (sit-red dual-end run=3;
// named-local `let r = t` / dest-CALL same). host-C ret emit already
// closed (run=10).
// Produce: dest-ARRAY memcpy / return Path B0 passed elem to
// glue_index_elem_byte_sz which peels again → leaf 4B, first row only.
// G.7: reuse glue_array_lit_force_esz_from_elem_type (TYPE_ARRAY →
// glue_fixed_array_total_bytes). Twin of 4.2.7 nested SLICE esz.
// No second memcpy. Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0. asm / host-C run = 10 (1+2+3+4) both ends.
// Neighborhood: dyn_ret_arr.x ([2]i32) / dyn_add_arr2.x ([2][2]i32 extra).
// PLATFORM: SHARED — Ubuntu gold.

trait Get22 {
  function get22(self): [2][2]i32;
}
struct A { v: i32 }
impl Get22 for A {
  function get22(self: A): [2][2]i32 {
    let t: [2][2]i32 = [[self.v, 2], [3, 4]];
    return t;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn Get22 = a;
  let r: [2][2]i32 = x.get22();
  return r[0][0] + r[0][1] + r[1][0] + r[1][1];
}
