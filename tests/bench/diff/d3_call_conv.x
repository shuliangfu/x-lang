// d3_call_conv.x — D3 函数调用约定差分测试（与 d3_call_conv.c 同源）
// 验证：多参数传递（>6 寄存器参数溢出栈）/ struct 返回值 / 递归调用
#[repr(C)]
struct Pair { a: i32; b: i32; }

function make_pair(a: i32, b: i32, c: i32, d: i32): Pair {
  let p: Pair = Pair { a: a + c, b: b + d };
  return p;
}

function sum6(a: i32, b: i32, c: i32, d: i32, e: i32, f: i32): i32 {
  return a + b + c + d + e + f;
}

function fib(n: i32): i32 {
  if (n < 2) { return n; }
  return fib(n - 1) + fib(n - 2);
}

function main(): i32 {
  let acc: u32 = 0;

  let p: Pair = make_pair(1, 2, 3, 4);
  acc = acc ^ ((p.a ^ p.b) as u32);

  acc = acc ^ (sum6(10, 20, 30, 40, 50, 60) as u32);

  acc = acc ^ (fib(15) as u32);

  return (acc & 0xFF) as i32;
}
