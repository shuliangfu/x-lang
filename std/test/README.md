# std.test — 测试断言与 runner

**路径**：`std/test/`（mod.sx + test.c）  
**依赖**：core。对标 Zig std.testing、Rust test。

| API | 说明 |
|-----|------|
| `expect(cond): i32` | 0 通过，1 失败 |
| `expect_eq_i32(a, b): i32` | 相等 0 |
| `expect_eq_u32(a, b): i32` | 相等 0 |
| `expect_ne_i32(a, b): i32` | 不等 0 |
| `test_run(fn: usize): i32` | 调用无参返回 i32 的测试函数 |
| `runner_reset(): void` | 重置 runner 计数（STD-145） |
| `runner_case(name, len, code): i32` | 报告单条用例 pass/fail |
| `runner_skip(name, len): i32` | 报告 skip 用例 |
| `runner_finish(): i32` | 输出汇总行，返回 fail 数 |
