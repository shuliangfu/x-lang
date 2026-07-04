// async_await_liveness.x — A3：跨 await liveness 烟测（帧仅含 continuation 仍引用的符号）
/** dead/tmp 仅用于首个 await 前；keep 在 return 中跨 await 仍被读。 */
async function liveness_demo(): i32 {
  let dead: i32 = 1;
  let keep: i32 = 2;
  let tmp: i32 = dead + 1;
  let mid: i32 = await tmp;
  return mid + keep;
}

function main(): i32 {
  return liveness_demo();
}
