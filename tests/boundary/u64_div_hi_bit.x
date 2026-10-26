// Expected: run = 0
// boundary: u64 / and /= with bit63 set must be unsigned (arm64 udiv).
export function main(): i32 {
  let one: u64 = 1;
  let a: u64 = one << 63;
  if ((a / 2) != (one << 62)) { return 1; }
  let z: u64 = 0;
  let all: u64 = z - 1;
  if ((all / 2) != ((one << 63) - 1)) { return 2; }
  let b: u64 = all;
  b /= 2;
  if (b != ((one << 63) - 1)) { return 3; }
  return 0;
}
