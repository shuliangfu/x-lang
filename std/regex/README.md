# std.regex — 最小正则（纯 .sx 引擎）

**模块路径**：`std/regex/mod.sx` + `std/regex/regex.sx`（F-regex v2 纯 .sx）  
**对标**：Rust `regex` 子集；全平台无 `regex.h` 依赖。

## API

| API | 说明 |
|-----|------|
| `compile(pat, pat_len)` | 编译模式；失败 null |
| `regex_match(re, str, len)` | 子串匹配；成功 0 |
| `free(re)` | 释放句柄 |
| `group_count(re)` | capture 槽数（含 group 0） |
| `group_offset(re, group)` | 上次 match 的组起始偏移 |
| `group_length(re, group)` | 上次 match 的组长度 |

## 语法子集

字面量、`.`、`[]`、`?` `*` `+` 及贪婪/懒惰/占有变体、`\` 转义、分组 `()`、交替 `|`、锚点 `^`/`$`、`\p{}`/`\P{}`（ASCII 子集）、原子分组 `(?>...)`。

## 测试

```bash
./tests/run-f-regex-v2-gate.sh
./tests/run-std-regex-gate.sh
./tests/run-std-regex-atomic-gate.sh
```
