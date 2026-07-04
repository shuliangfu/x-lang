// run_async_arg.x — A4/run v1：`run async_fn(i32)` 经 seed 传参 + scheduler drain
/** 单 i32 形参 + await；run 时 seed 注入 x。 */
async function add_one(x: i32): i32 {
  let v: i32 = await x;
  return v + 1;
}

function main(): i32 {
  let r: i32 = run add_one(41);
  if (r != 42) {
    return 11;
  }
  let r2: i32 = run add_one(99);
  if (r2 != 100) {
    return 12;
  }
  return 0;
}
