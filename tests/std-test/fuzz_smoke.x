// STD-054：fuzz_seed / fuzz_next 占位
const test = import("std.test");

function main(): i32 {
  let st: u32 = test.fuzz_seed();
  let n: u32 = test.fuzz_next(&st);
  if (n == 0) {
    return 1;
  }
  return 0;
}
