// w1508 (终局待办 10.33): variable index inside a loop.
// Before w1508 Darwin and Windows reported CG002 (the index-assign seed only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
function main(): i32 {
  let a: [4]i32 = [1, 2, 3, 4];
  let i: i32 = 0;
  while i < 4 {
    a[i] += i * 10;
    i = i + 1;
  }
  if a[0] != 1 { return 1; }
  if a[3] != 34 { return 2; }
  return 0;
}
