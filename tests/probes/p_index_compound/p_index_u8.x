// w1508 (终局待办 10.33): u8 element, the sum wraps at 256.
// Before w1508 Darwin and Windows reported CG002 (the index-assign seed only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
function main(): i32 {
  let a: [4]u8 = [1, 2, 3, 250];
  a[1] += 40;
  if a[1] != 42 { return 1; }
  a[3] += 10;
  if a[3] != 4 { return 2; }
  return 0;
}
