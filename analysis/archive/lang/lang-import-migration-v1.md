# LANG-IMPORT：import("path") 语法

> 更新时间：2026-06-18

## 1. 唯一支持的两种写法

```su
const token = import("std.token");           // 绑定
const { m1, m2 } = import("std.token");      // 解构
```

旧语法（`import path;`、`import("std.io")` 无括号）**已移除**。

## 2. 路径

- 逻辑名：`"std.io"` → `-L` 下 `std/io/mod.x`
- 相对路径：`"../foo/bar.x"` → 相对当前 .x 所在目录
- 绝对路径：`"/path/to/mod.x"`

## 3. 选型

| 条件 | 写法 |
|------|------|
| ≥75% 符号 + 无跨模块类型 | `const x = import("…")` |
| 部分符号或含类型 | `const { … } = import("…")` |

## 4. 工具

```bash
python3 tools/migrate_import_call_syntax.py --write .
python3 tools/migrate_import_to_select.py --write std/
```
