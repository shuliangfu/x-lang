// Expected: run = 0
// boundary: u64 / and /= with bit63 set must be unsigned (arm64 udiv).
export function main(): i32 {
  let one: u64 = 1;
  let a: u64 = one << 63;
  let q: u64 = a / 2;
  let e62: u64 = one << 62;
  if (q != e62) { return 1; }
  let z: u64 = 0;
  let all: u64 = z - 1;
  let q2: u64 = all / 2;
  let e2: u64 = (one << 63) - 1;
  if (q2 != e2) { return 2; }
  let b: u64 = all;
  b /= 2;
  if (b != e2) { return 3; }
  return 0;
}
