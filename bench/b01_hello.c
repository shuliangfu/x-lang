/* b01_hello.c — 最小 hello world 程序，用于二进制体积对比。
 * 不调用 printf，仅返回 42，测纯运行时体积。
 * 与 bench/b01_hello.x / .zig 三语言同语义。无防常量折叠（测体积）。 */

int main(void) {
  return 42;
}
