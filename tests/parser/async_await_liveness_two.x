// async_await_liveness_two.x — A3：双 await 点帧字段为各 suspend 点 live 之并集
async function two_await(): i32 {
  let a: i32 = 1;
  let b: i32 = 2;
  let x: i32 = await a;
  let scratch: i32 = x + 1;
  let c: i32 = await b;
  return c + a;
}

function main(): i32 {
  return two_await();
}
