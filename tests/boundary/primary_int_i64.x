// INT head via .x + large i64 literal + int suffix chains.
function main(): i32 {
  let big: i64 = 9223372036854775807;
  let n: i32 = 5;
  let a: [2]i32 = [11, 22];
  return n + a[1] + ((big > 0) as unknown as i32) * 1;  // 5+22+1=28
}
