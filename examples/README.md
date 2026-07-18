# examples/ — 示例程序

**示例 .x 程序**，便于上手与回归测试。

- **用途**：用户参考「如何写 .x」；CI/本地测试时编译并运行，验证编译器与标准库。
- **内容**：例如：
  - Hello World（`examples/hello.x`：`function main(): void`，Zig 风格隐含 exit 0）
  - 使用 core / std 的简单示例（需要非零退出码时仍可用 `main(): i32`）
  - 嵌入式最小可运行示例（若支持 freestanding）
- **使用**：手动用 `shux examples/hello.x` 编译，或由 `make test` / `tests/run-hello.sh` 覆盖。

建议 M1/M2 起就加少量示例，便于验证「能编译、能跑」。
