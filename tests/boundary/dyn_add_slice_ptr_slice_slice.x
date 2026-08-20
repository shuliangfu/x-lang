// F7 leftover: dest extras dest-SLICE of PTR `[]*[][]i32` dest-stamp
// (sit-red dyn extra compile=0 run=1 panic: 0). Produce: skip-trait
// after `[]*` then `[` then `]` sets ndims=-2 (first extra wrap = 1
// inner SLICE); a further empty `[]` (`[]*[][]T`) did not increment
// extra wrap because the increment branch required elem==SLICE. dest
// extras dest-SLICE-of-PTR wrapped SLICE of leaf once so dest was
// `[]*[]i32` not `[]*[][]i32`. Store: keep elem=PTR + eek=leaf +
// ndims=-2 + dims[0]=2 (extra wrap count; 0 means 1 = `[]*[]T`).
// Consume: dest extras extra wraps. Named / UFCS / module-func
// already dest-stamp via the formal (7). Assign-only false-green 7.
// G.7: complete skip-trait extra wrap count for PTR + dest extras
// dest-SLICE-of-PTR extra wraps (no second dest-SLICE stamp; do not
// invent -3). Wrapper rdi/x0 = data unchanged.
// Expected: compile = 0, run = 7 (v + (*p[0])[0][0] + (*p[0])[0][1]
// = 1+2+4).
// Neighborhood: dyn_add_slice_ptr_slice.x (`[]*[]i32`) /
// dyn_add_slice_slice_slice.x (`[][][]i32`) /
// dyn_add_slice_slice_slice_slice.x (`[][][][]i32`).
// PLATFORM: SHARED — Ubuntu gold.

trait SumSPSSS {
  function sumsps(self, p: []*[][]i32): i32;
}
struct A { v: i32 }
impl SumSPSSS for A {
  function sumsps(self: A, p: []*[][]i32): i32 {
    let x: i32 = unsafe { (*p[0])[0][0] };
    let y: i32 = unsafe { (*p[0])[0][1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSPSSS = a;
  let row: [][]i32 = [[2, 4]];
  return x.sumsps([&row]);
}
