// w1508 (终局待办 10.33): f32 and f64 elements.
// Before w1508 Darwin and Windows reported CG002 (the index-assign seed only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
function main(): i32 {
  let a: [4]f32 = [1.5, 2.0, 3.0, 4.0];
  a[0] += 2.25;
  if (a[0] != 3.75) { return 1; }
  a[1] *= 1.5;
  if (a[1] != 3.0) { return 2; }
  let y: f32 = 0.5;
  a[2] -= y;
  if (a[2] != 2.5) { return 3; }
  a[3] /= 8.0;
  if (a[3] != 0.5) { return 4; }
  let b: [2]f64 = [1.5, 2.0];
  b[1] += 0.25;
  if (b[1] != 2.25) { return 5; }
  return 0;
}
