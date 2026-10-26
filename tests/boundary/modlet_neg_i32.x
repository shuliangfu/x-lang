// Expected: run = 0
// Knife 10.52: Darwin module-level negative i32 let entry init must sign-extend.
let GP: i32 = -3;
let GN: i32 = -1;
let GZ: i32 = 0;
let GP2: i32 = -2147483648;

export function main(): i32 {
  if (GP != -3) { return 1; }
  if (GN != -1) { return 2; }
  if (GZ != 0) { return 3; }
  if (GP2 != -2147483648) { return 4; }
  if (GP == -3) {} else { return 5; }
  return 0;
}
