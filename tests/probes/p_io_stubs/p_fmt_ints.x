// w1515 (5.7a): integer print faces of runtime_asm_io_stubs (fmt / io).
const fmt = import("std.fmt");
const io = import("std.io");

function main(): i32 {
  let a: i32 = 0 - 2147483647 - 1;
  fmt.println(a);
  let b: i64 = 0 - 9223372036854775807 - 1;
  fmt.println(b);
  let c: i64 = 9223372036854775807;
  fmt.println(c);
  let d: u64 = 18446744073709551615;
  fmt.println(d);
  let e: u32 = 4294967295;
  fmt.println(e);
  let f: i64 = 0 - 9000000000000000000;
  fmt.println(f);
  fmt.println(0);
  fmt.print(b);
  fmt.print(a);
  fmt.println("");
  let hi: u8[3] = [104, 105, 10];
  io.write_stdout(&hi[0], 3);
  fmt.println("str");
  return 0;
}
