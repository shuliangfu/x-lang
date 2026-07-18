// Minimal: slice indexing.

/**
 * Index slice s[1] after binding from array; expect 20.
 */
function main(): i32 {
  let a: i32[4] = [10, 20, 30, 40];
  let s: i32[] = a;
  return s[1];
}
