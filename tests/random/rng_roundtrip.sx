// STD-130：可复现 PRNG（SplitMix64）烟测
const random = import("std.random");

function main(): i32 {
  let _csr: u64 = random.next();
  let r1: Rng = random.seed(0 as u64);
  let r2: Rng = random.seed(0 as u64);
  let a: u64 = random.step(&r1);
  let b: u64 = random.step(&r1);
  if (random.step(&r2) != a) { return 1; }
  if (random.step(&r2) != b) { return 2; }
  let r3: Rng = random.seed(1 as u64);
  if (random.step(&r3) == a) { return 3; }
  let r4: Rng = random.seed(99 as u64);
  let x: u32 = random.range(&r4, 10 as u32, 12 as u32);
  if (x < (10 as u32) || x > (12 as u32)) { return 4; }
  let r5: Rng = random.seed(42 as u64);
  let buf: u8[4] = [];
  random.fill(&r5, &buf[0], 4);
  let r6: Rng = random.seed(42 as u64);
  let buf2: u8[4] = [];
  random.fill(&r6, &buf2[0], 4);
  let i: i32 = 0;
  while (i < 4) {
    if (buf[i] != buf2[i]) { return 5; }
    i = i + 1;
  }
  return 0;
}
