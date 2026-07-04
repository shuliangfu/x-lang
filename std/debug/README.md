# std.debug — 开发调试（stderr）

**模块路径**：`std/debug/mod.x`  
**依赖**：core.fmt、core.assert、std.io。  
**对标**：Zig `std.debug`（print 写 stderr；assert 可从此 import）。

### print / println

- 字符串字面量、标量与 **任意复合类型**（JSON 风格，与 `std.fmt` 相同规则；输出目标为 **stderr**）。

## 与 std.fmt / std.log 的分工

| 模块 | 用途 | 输出 |
|------|------|------|
| **std.fmt** | 程序正常输出、Hello World | stdout |
| **std.debug** | 临时调试、看变量 | stderr |
| **std.log** | 带级别的正式日志 | stderr / 文件 |

## API

- `print` / `println` — 字符串 `(ptr, len)` 或标量重载；写 **stderr**
- `assert` / `assert_eq_*` — 重导出 **core.assert**（失败 panic）

## 示例

```x
const dbg = import("std.debug");

function main(): i32 {
  dbg.println("trace");
  dbg.println(42);
  dbg.assert(true);
  return 0;
}
```
