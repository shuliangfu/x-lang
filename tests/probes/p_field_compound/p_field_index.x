// w1509 (终局待办 10.32): fields of array elements (a[1].n, a[i].m).
// Before w1509 Darwin and Windows reported CG002 (the field-assign body only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
struct C { n: i32, m: i32 }
function main(): i32 {
  let a: [3]C = [C { n: 1, m: 2 }, C { n: 3, m: 4 }, C { n: 5, m: 6 }];
  a[1].n += 39;
  if (a[1].n != 42) { return 1; }
  let i: i32 = 2;
  a[i].m *= 7;
  if (a[2].m != 42) { return 2; }
  if (a[0].n != 1 || a[0].m != 2 || a[1].m != 4 || a[2].n != 5) { return 3; }
  return 0;
}
