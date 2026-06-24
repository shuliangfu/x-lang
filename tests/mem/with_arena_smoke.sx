// MEM-C1：with_arena 语法烟测 — 验证 codegen 发出 scope Arena init/deinit。
function main(): i32 {
  with_arena(4096) {
    let x: i32 = 0;
    x
  }
  return 0;
}
