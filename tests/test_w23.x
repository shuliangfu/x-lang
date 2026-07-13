extern function foo(): usize;

function test(n: i32): i32 {
  let entry: usize = 0;
  let i: i32 = 0;
  unsafe { entry = foo(); }
  return 0;
}
