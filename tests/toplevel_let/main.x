// 测试顶层 let：与 import/const 同级，在 main 之前初始化，main 中可引用。
// 运行：./compiler/shux -L . tests/toplevel_let/main.x -o /tmp/toplevel_let && /tmp/toplevel_let
let global_x: i32 = 42;

function main(): i32 {
  return global_x;
}
