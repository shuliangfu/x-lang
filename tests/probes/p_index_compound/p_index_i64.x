// w1508 (终局待办 10.33): i64 element with a literal wider than 32 bits.
// Before w1508 Darwin and Windows reported CG002 (the index-assign seed only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
function main(): i32 {
  let a: [3]i64 = [1, 2, 3];
  a[1] += 20000000000;
  if a[1] != 20000000002 { return 1; }
  a[2] *= 3;
  if a[2] != 9 { return 2; }
  return 0;
}
