// 10.43: i8 / i16 / u16 arithmetic must wrap at width in the register
// (not only via a later narrow store). Compare via as i32 so a missing
// wrap shows as 200 / 300 / 65540 instead of -56 / 44 / 4.
// Expected: compile = 0, run = 0.
// PLATFORM: SHARED — Ubuntu gold; Win deferred.

export function main(): i32 {
  let a: i8 = 100;
  let b: i8 = 100;
  // 100+100 → -56 (not 200)
  if (((a + b) as i32) != (0 - 56)) {
    return 1;
  }
  // nested: (-56)+100 → 44 (not 300)
  if ((((a + b) + a) as i32) != 44) {
    return 2;
  }
  // 100*3 → 44 (not 300)
  if (((a * 3) as i32) != 44) {
    return 3;
  }
  let c: i16 = 32000;
  // 32000+1000 → -32536
  if (((c + 1000) as i32) != (0 - 32536)) {
    return 4;
  }
  let d: u16 = 65530;
  // 65530+10 → 4
  if (((d + 10) as i32) != 4) {
    return 5;
  }
  let e: u16 = 0;
  // 0-1 → 65535
  if (((e - 1) as i32) != 65535) {
    return 6;
  }
  let f: i8 = 50;
  // 50-100 → -50
  if (((f - 100) as i32) != (0 - 50)) {
    return 7;
  }
  return 0;
}
