# STD-147：std.backtrace 跨平台符号质量 v1

> 状态：**定版（v1）** · soft→硬绿 2026-08-28  
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
xlang: [XLANG_BT_XPLAT] platform=Darwin gold=1 resolved=3 total=8
```

---

## Gate

Honesty（2026-08-28）：prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft prefer-c／soft SKIP→OK／soft ensure／soft auto-make／化石顶层 DOC section 路径／`quality=`／`host=` 报告；显式坏 XLANG／缺 native 硬 die；host-C／tip quality residual＝obs（现成 `.o` only）；报告 `run=`／`obs=`／`skip=`。

```bash
./tests/run-std-backtrace-xplat-gate.sh
```

```
xlang: [XLANG_STD147_BACKTRACE_XPLAT] status=ok run=N obs=M skip=0
std-backtrace-xplat gate OK
```
