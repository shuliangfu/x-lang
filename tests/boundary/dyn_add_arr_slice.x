// F7 leftover: dest-ARRAY extra `[2][]i32` (SLICE elem of dest-ARRAY).
// Produce: skip-trait `param_prefix_arr_need_size` after `[N][` wanted
// INT only, so `[2][]i32` bailed and dest-ARRAY extras skipped elem
// kind 11. `[[2, 3], [1, 4]]` stayed TYPE_ARRAY of ARRAY.
// Store: registry elem_kind=SLICE + elem_elem_kind after `[N][]`.
// Consume: host-C / asm dest-ARRAY of SLICE wrap only when dest-stamped.
// Sit-red asm=139 / host-C=133 (`(int32_t[][2])` into slice*). Named
// local / UFCS already dest-stamp. G.7: complete scanner + dest-ARRAY
// extras (wrap slice of leaf then existing ARRAY wrap). No second
// dest-ARRAY stamp. Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0] + p[1][1] = 1+2+4).
// Neighborhood: dyn_add_arr2.x / dyn_add_slice.x / dyn_add_slice_arr.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumAS {
  function sumas(self, p: [2][]i32): i32;
}
struct A { v: i32 }
impl SumAS for A {
  function sumas(self: A, p: [2][]i32): i32 {
    return self.v + p[0][0] + p[1][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: dyn SumAS = a;
  return x.sumas([[2, 3], [1, 4]]);
}
