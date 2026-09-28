// w1508 (终局待办 10.33): compound ops on a module-level array element.
// Before w1508 Darwin and Windows reported CG002 (the index-assign seed only
// took plain `=`). Exit 0 when right; a non-zero code names the first wrong check.
let g: [4]i32 = [1, 2, 3, 4];
function main(): i32 {
  g[1] += 10;
  if g[1] != 12 { return 1; }
  g[0] *= 7;
  if g[0] != 7 { return 2; }
  return 0;
}
