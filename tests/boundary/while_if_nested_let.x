// while_if_nested_let.x — while 体内 if-then 嵌套 let + 后续赋值（parser lex 回指 + loop body emit let）
function main(): i32 {
  let i: i32 = 0;
  while (i < 10) {
    if (i > 0) {
      let fr: i32 = i + 1;
      i = fr;
    } else {
      i = i + 1;
    }
  }
  return i;
}
