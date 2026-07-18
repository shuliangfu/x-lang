// Hello World — void main implies process exit 0 (Zig-like).
// PLATFORM: SHARED — product entry contract (see docs/05-函数与模块.md).
const fmt = import("std.fmt");

function main(): void {
  fmt.println("Hello World");
}
