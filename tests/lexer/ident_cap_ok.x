// Probe: identifier length 63 (AST name cap content) must compile and run 42.
// wave284 Cap residual pure — boundary still green; L012 only for >63.
// PLATFORM: SHARED.

function main(): i32 {
  let aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: i32 = 42;
  return aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;
}
