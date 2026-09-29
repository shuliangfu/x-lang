// w1509 (终局待办 10.32): fields of a module-level struct.
// Before w1509 Darwin and Windows reported CG002 (the field-assign body only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
struct C { n: i32, m: i32 }
let g: C = C { n: 1, m: 100 };
function main(): i32 {
  g.n += 41;
  if (g.n != 42) { return 1; }
  g.m /= 4;
  if (g.m != 25) { return 2; }
  return 0;
}
