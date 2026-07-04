# STD-062：std.regex 纯引擎性能优化 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：STD-051 `std-regex-v1.md`  
> 关联：`regex.x`、`std-regex-xplat.tsv`

---

## 1. 目标

在 STD-051 纯引擎基础上，新增 **match 性能优化** 与 **三平台 bench 门禁**：

- 编译期 **字面量快路径**（`memcmp` 滑动）
- **首字节跳跃**（`first_lit` 锚点）
- bench ratio **≥1.0×** 朴素桩基线

验收：`tests/run-std-regex-perf-gate.sh` 绿；`min_benches=3`；xplat 矩阵 **linux/macos/windows** 均为 `must`。

---

## 2. 引擎优化（STD-062）

| 优化 | 锚点 | 说明 |
|------|------|------|
| `opt_literal_only` | `is_literal_only` | 无元字符模式走 `memchr`+`memcmp` |
| `opt_first_lit` | `first_lit` | 非字面量模式仅扫描首字节匹配位置 |

实现：`std/regex/regex.x`。

---

## 3. Bench 矩阵

| bench_id | 文件 | 角色 |
|----------|------|------|
| `bench_engine` | `regex_match_bench.c` | 链接 `regex.o` 热循环 |
| `bench_naive_stub` | `regex_match_naive_stub.c` | 无快路径朴素桩 |
| `bench_hook` | `run-perf-regex-match.sh` | stub/engine ratio |

热循环：**500K** ×（`needle` 字面量 + `a*b` 星号）。

---

## 4. 三平台 xplat

`tests/baseline/std-regex-perf-xplat.tsv`：

| 平台 | 策略 |
|------|------|
| Linux | `must`：C bench + perf hook |
| macOS | `must` |
| Windows (MSYS) | `must` |

---

## 5. Gate

```bash
./tests/run-std-regex-perf-gate.sh
./tests/run-perf-regex-match.sh
```

```
shux: [SHUX_STD062_REGEX_PERF] status=ok bench_ok=1 bench_skip=0 skip=0 ratio=1.12 host=Darwin/arm64
```

无 `cc` 时 manifest 仍须绿；perf runnable **SKIP**。

---

## 6. 联动

- manifest：`tests/baseline/std-regex-perf-wave.tsv`
- 父表：`std-regex.tsv`；父 RFC `std-regex-v1.md` §7
- CI：`tests/run-portable-suite.sh`

---

## 7. 非目标（v2）

- NFA/DFA 编译
- PCRE 对标
- JIT 正则
