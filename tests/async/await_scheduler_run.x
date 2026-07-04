// STD-041：language run/await 与 scheduler.c 对接烟测（无 import，避免 extern 重声明）
//
// 【文件职责】验证 codegen CPS + seed 队列与 scheduler.o 链接。
// 【运行方式】tests/run-std-async-language-gate.sh
/** run v4：双 await + seed 队列注入形参。 */
async function add_two(a: i32, b: i32): i32 {
  let x: i32 = await a;
  let y: i32 = await b;
  return x + y;
}

function main(): i32 {
  let r: i32 = run add_two(40, 2);
  if (r != 42) {
    return 1;
  }
  let r2: i32 = run add_two(10, 32);
  if (r2 != 42) {
    return 2;
  }
  return 0;
}
