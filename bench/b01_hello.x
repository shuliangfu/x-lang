// b01_hello.x — 最小 hello world 程序，用于二进制体积对比。
// 不调用 printf，仅返回 42，测纯运行时体积。
// 与 bench/b01_hello.c / .zig 三语言同语义。无防常量折叠（测体积）。

/** Internal function `main`.
 * Program/test entry point. Minimal program for binary size comparison;
 * returns 42 without any I/O or allocation.
 * @return i32
 */
function main(): i32 {
  return 42;
}
