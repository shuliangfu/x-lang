# STD-147：std.backtrace 跨平台符号质量 v1

> 状态：**定版（v1）**  
> 关联：`STD-052` symbolicate、`TOOL-005` 调试符号

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-147 | Darwin/Windows/Linux 符号质量向量 + `backtrace_xplat_quality_c` + gate |

在 STD-052 金样基础上，统一输出可 grep 的质量行，供 CI 按平台验收。

---

## 2. 平台质量向量

| 平台 | capture | symbolicate | 链接建议 |
|------|---------|-------------|----------|
| **Darwin** | execinfo | dladdr | `-g -Wl,-export_dynamic` |
| **Linux** | execinfo | dladdr | `-g -rdynamic -ldl` |
| **Windows** | CaptureStackBackTrace | DbgHelp | `-g -ldbghelp` |

最低验收：`gold_anchor` 可解析 + `capture` 栈 `resolved >= 1`。

---

## 3. 质量报告格式

```
shux: [SHUX_BT_XPLAT] platform=Darwin gold=1 resolved=3 total=8
```

---

## 4. Gate

```bash
./tests/run-std-backtrace-xplat-gate.sh
```

报告：`shux: [SHUX_STD147_BACKTRACE_XPLAT]`
