// run_async_sync_err.x — async 内 run 应 typeck 报错
async function inner(): i32 {
  return run yield_demo();
}

async function yield_demo(): i32 {
  let a: i32 = await 1;
  return a;
}

function main(): i32 {
  return 0;
}
