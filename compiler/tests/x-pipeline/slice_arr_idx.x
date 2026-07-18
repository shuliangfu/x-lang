// Minimal: array literal + index.

/**
 * Return a[1] from fixed array [10,20,30,40] (expect 20).
 */
function main(): i32 {
  let a: i32[4] = [10, 20, 30, 40];
  return a[1];
}
