// F7 leftover: dest-SLICE extra `[]*[]T` (PTR-to-SLICE elem of dest-SLICE).
// Produce: skip-trait after `[]*` then `[` then `]` set elem_kind=-1
// (wave434 3-layer defer) so dest extras dest-SLICE-of-PTR never ran.
// Dyn INDEX sit-red 139; assign-only false-green 7 (impl ignores p).
// Named / UFCS already dest-stamp via the formal (7).
// Store: registry elem_kind=PTR + eek=leaf + ndims=-2 (SLICE pointee;
// 0 = scalar, >=1 = ARRAY, accessor invalid = -1).
// Consume: host-C dest-SLICE wrap / asm dest wrap.
// G.7: complete the scanner (keep PTR, ndims=-2, capture leaf) + dest
// extras dest-SLICE-of-PTR (wrap SLICE of leaf then existing wrap
// ptr / slice). No second dest-SLICE stamp.
// Wrapper rdi/x0 = data unchanged.
// Lets (not a two-unsafe binop) so INDEX is the dest-stamp, not peel.
// Expected: compile = 0, run = 7 (v + (*p[0])[0] + (*p[0])[1] = 1+2+4).
// Neighborhood: dyn_add_slice_ptr.x / dyn_add_slice_slice.x /
// dyn_add_slice_ptr_arr.x.
// PLATFORM: SHARED — Ubuntu gold.

trait SumSPSS {
  function sumsps(self, p: []*[]i32): i32;
}
struct A { v: i32 }
impl SumSPSS for A {
  function sumsps(self: A, p: []*[]i32): i32 {
    let x: i32 = unsafe { (*p[0])[0] };
    let y: i32 = unsafe { (*p[0])[1] };
    return self.v + x + y;
  }
}
function main(): i32 {
  let a: A = { v: 1 };
  let x: SumSPSS = a;
  let row: []i32 = [2, 4];
  return x.sumsps([&row]);
}
