# STD-051：std.regex 纯引擎三平台 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：P4 最小正则、`std/regex/regex_min.inc.c`

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4 |
| 2 | `tests/baseline/std-regex.tsv` |
| 3 | `./tests/run-std-regex-gate.sh` |
| 4 | 烟测：`tests/regex/*.sx`、`regex_min_ok.c` |

---

## 2. API 与子集语法

| API | 说明 |
|-----|------|
| `compile(pat, pat_len): *u8` | 编译模式；失败 `NULL` |
| `regex_match(re, str, len): i32` | 子串匹配；成功 `0`，失败 `-1` |
| `free(re): void` | 释放 |

**v1 纯引擎子集**（`regex_min.inc.c`，三平台同一实现）：

| 构造 | 示例 |
|------|------|
| 字面量 | `hello` |
| 任意单字节 | `.` |
| 字符类 | `[0-9]`、`[a-z]`、`[^x]` |
| 零或多次 | `a*b` |
| 零或一次 | `colou?r` |
| 转义 | `\.`、`\[` |

**不含**：分组 `()`、锚点 `^$`、`|`、POSIX 扩展。Windows 不再 stub，与 Linux/macOS 行为一致。

---

## 3. 三平台验收

| 平台 | 策略 |
|------|------|
| Linux | manifest `must`：C 烟测 + `.sx` compile/match |
| macOS | 同上 |
| Windows (MSYS) | 同上（无 `regex.h`） |

C 烟测 `regex_min_smoke_c` 覆盖 literal/dot/class/star/question；`.sx` 烟测验证 `import("std.regex")` 链入。

---

## 4. 可选链入

引用 `compile` / `regex_match` 时链接 `std/regex/regex.o`（`get_std_regex_o_path`）。

---

## 5. 门禁

```bash
./tests/run-std-regex-gate.sh
```

```
shux: [SHUX_STD_REGEX] status=ok c_smoke=1 su=1 skip=0 host=Darwin-arm64
```

---

## 6. 变更记录

| 版本 | 日期 | 说明 |
|------|------|------|
| v1 | 2026-06-17 | 纯 C 引擎替代 POSIX/Windows stub；三平台 compile/match |

---

## 7. STD-062 性能优化

详见 `analysis/std-regex-perf-v1.md`：字面量 `memcmp` 快路径 + `first_lit` 跳跃；`run-perf-regex-match.sh` ratio **≥1.0×** 朴素桩。

---

## 8. STD-099 占有型量词

| 构造 | 示例 | 语义 |
|------|------|------|
| 占有零或多 | `a*+b` | 尽量多匹配 `a`，**不回溯**重复段 |
| 占有一或多 | `a++b` | 至少一个 `a`，再多尽量吞，不回溯 |
| 占有零或一 | `u?+r` | 能匹配一次则匹配，不回溯到零次 |

烟测：`tests/regex/possessive_match.sx`（`.++!` 与贪婪 `.+!` 对照）。
