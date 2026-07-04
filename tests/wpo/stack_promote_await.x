// stack_promote_await.x — WPO-S3：小 struct 跨 await 仍可读（协程帧 liveness + codegen DCE 豁免）
// typeck + C CPS：帧含 struct Pair p；sync run exit=10（3+4+3）；asm sync stub 同 exit 10。

/** 两字段 POD。 */
struct Pair {
  a: i32
  b: i32
}

/** await 前后均读 p 字段；帧须保留整个 Pair。 */
async function struct_across_await(): i32 {
  let p: Pair = Pair { a: 3, b: 4 };
  let kick: i32 = p.a;
  let mid: i32 = await kick;
  return p.a + p.b + mid;
}

function main(): i32 {
  return struct_across_await();
}
