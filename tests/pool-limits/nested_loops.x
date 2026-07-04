// backend 循环标签栈：6 层嵌套 while（旧硬顶 4 层）；最内层 return 6。
function main(): i32 {
  while (true) {
    while (true) {
      while (true) {
        while (true) {
          while (true) {
            while (true) {
              return 6;
            }
          }
        }
      }
    }
  }
  return 0;
}
