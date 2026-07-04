#[max_stack(64)]
function small_func(a: i32, b: i32): i32 {
  let x: i32 = a + b;
  let y: i32 = x * 2;
  return y;
}

#[max_stack(32)]
function tiny_func(): i32 {
  return 42;
}

function main(): i32 {
  return small_func(1, 2) + tiny_func();
}
