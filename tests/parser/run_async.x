// run_async.x — A4：`run async_fn()` 语法经 scheduler drain
async function yield_demo(): i32 {
  let a: i32 = 1;
  let b: i32 = await a;
  return b + 1;
}

function main(): i32 {
  let r: i32 = run yield_demo();
  if (r != 2) {
    return 11;
  }
  let r2: i32 = run yield_demo();
  if (r2 != 2) {
    return 12;
  }
  return 0;
}
