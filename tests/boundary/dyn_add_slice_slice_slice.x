// F7 leftover: dest-SLICE extra `[][][]i32` dest-stamp (sit-red dyn extra
// asm 139 / host-C 139). Produce: skip-trait after `[][]` then `[` then
// `]` set elem_kind=-1 so dest extras dest-SLICE-of-SLICE never entered;
// store ndims=-2 without impl-match extra peel is T001 (pipeline pelem
// is SLICE, registry eek is the leaf). Store: keep elem=SLICE + eek=leaf
// + ndims=-2 (same sentinel as `[]*[]T`; discriminant is elem_kind).
// Consume: dest extras third wrap / impl-match extra peel. Named local
// extra already dest-stamps via the module-func formal (7). G.7: complete
// skip-trait scanner + SLICE-of-SLICE walk + dest-SLICE-of-SLICE wrap
// (no second dest-SLICE stamp). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + p[0][0][0] + p[0][0][1] = 1+2+4).
// Neighborhood: dyn_add_slice_slice.x (`[][]i32`) / dyn_add_slice_ptr_slice.x
// (`[]*[]i32`) / dyn_add_slice_slice_named.x (`[][]Pair`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSSS {
  function sumsss(self, p: [][][]i32): i32;
}
struct A { v: i32 }
impl SumSSS for A {
  function sumsss(self: A, p: [][][]i32): i32 {
    return self.v + p[0][0][0] + p[0][0][1];
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSSS = a;
  return x.sumsss([[[2, 4]]]);
}
