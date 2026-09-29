// w1509 (终局待办 10.32): compound field ops inside a loop.
// Before w1509 Darwin and Windows reported CG002 (the field-assign body only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
struct C { n: i32, m: i32 }
function main(): i32 {
  let c: C = C { n: 0, m: 1 };
  let i: i32 = 0;
  while (i < 10) {
    c.n += i;
    c.m *= 2;
    i += 1;
  }
  if (c.n != 45) { return 1; }
  if (c.m != 1024) { return 2; }
  return 0;
}
