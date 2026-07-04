// async_cps_yield.x — A3：SHUX_ASYNC_YIELD=1 时 await 边界 yield（手工 poll 对照）
/** await 后 +1；首次调用 yield，resume 后返回 2。 */
async function yield_demo(): i32 {
  let a: i32 = 1;
  let b: i32 = await a;
  return b + 1;
}

function main(): i32 {
  let suspended: i32 = 1095980800;
  let r: i32 = yield_demo();
  if (r == suspended) {
    r = yield_demo();
  }
  if (r != 2) {
    return 11;
  }
  return 0;
}
