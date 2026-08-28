# STD-088 std.trace v1

> 更新时间：2026-08-28  
> 状态：**可用** — Span 嵌套 + id + text 导出 + context 集成 + gate（soft→硬绿）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-trace-manifest.tsv` |
| 3 | `./tests/run-std-trace-gate.sh` |

---

## 2. API

产品短名（`std/trace/mod.x`）：

| API | 说明 |
|-----|------|
| `new` / `free` | 追踪会话 |
| `start` / `start_child` / `end` | 嵌套 Span |
| `id` / `current_span` / `count` | ID 与栈顶／计数 |
| `export_text` | OTLP 风格简化 text |
| `attach` / `from_ctx` | 与 std.context 集成 |

实现：`std/trace/mod.x` + `std/trace/trace.x`（F-trace v2 纯 .x，无 glue）。

---

## Gate

Honesty（2026-08-28）：prefer asm＋`XLANG_LINK_XLANG`＋`dod_native_exe`；退役 soft prefer-c／soft SKIP→OK／soft `ensure_std_c_o`／`c_smoke=`／`x=` 报告；显式坏 XLANG／缺 native 硬 die；check／host-C／tip product `-o` UNDEF＝obs；报告 `run=`／`obs=`／`skip=`。

```
xlang: [XLANG_STD_TRACE] status=ok run=N obs=M skip=0
std-trace gate OK
```

---

## 4. 后续（非 v1 阻塞）

- async/io/net 自动 span 挂钩  
- OTLP JSON/protobuf 导出  
- 并发安全  
- tip `std_trace_*` 产品 UNDEF 另案  
