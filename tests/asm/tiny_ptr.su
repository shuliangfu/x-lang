// asm 烟测：用户 struct + `*Ty` 字段赋值（对齐 compiler/tmp_tiny_ptr）。
// 约束：当前解析器在「struct + 复杂 main」组合下易丢失 main，故保持 main
// 为第一函数且仅返回常量；
//       void 辅助函数紧随其后，用于生成 poke 的机器码路径。
struct Tiny {
  a: i32;
}

function main(): i32 {
  return 42;
}

function poke(p: *Tiny): void {
  p.a = 0;
}
