// 10.3.1 slice11: local [N]function let host-C Ret (*fs[N])(args).
// Init with null Caps via as. Expect -E host-cc + run=42. PLATFORM: SHARED.

function main(): i32 {
  let fs: [2]function(i32): i32 = [
    0 as *u8 as function(i32): i32,
    0 as *u8 as function(i32): i32
  ];
  return 42;
}
