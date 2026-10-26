// Knife 10.52: module-level negative i32 let must sign-extend on Darwin entry.
// Expected: run = 0
let GP: i32 = -3;

export function main(): i32 {
  if (GP != -3) {
    return 1;
  }
  if (GP == -3) {
  } else {
    return 2;
  }
  let local: i32 = -3;
  if (local != GP) {
    return 3;
  }
  // other negatives
  return 0;
}
