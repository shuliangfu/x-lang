# STD-136：std.datetime IANA 时区 + DST v1

> 更新时间：2026-08-26  
> 状态：**定版（v1，内置 IANA 名表 + DST 偏移）** · Gate honesty soft→硬绿  
> 关联：STD-074 `std.datetime` · STD-135 固定偏移时区

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-136 | IANA 时区解析 + `timezone_offset_at` DST 墙钟偏移 + DST 烟测 |
| 验收 | `iana_dst_smoke.x` 金样 + `run-std-datetime-iana-gate.sh` 全绿（`check=`／`run=`／`skip=`） |

---

## 2. API

| 名称 | 说明 |
|------|------|
| `timezone_iana` | 按 IANA 名（如 `America/New_York`）填 `TimeZone.iana_id` |
| `timezone_offset_at` | 给定 UTC 时刻返回该区墙钟偏移（分；含 DST） |
| `iana_dst_smoke` | C／.x 金样入口（NY 冬夏偏移） |

实现：`std/datetime/mod.x` + `datetime.x`；墙钟复用 `std.time`。  
固定偏移面见 STD-135；本闸覆盖 IANA 名表与 DST 规则烟测。

---

## 3. 边界向量（金样）

`tests/std-datetime/iana_dst_smoke.x`：

1. `iana_dst_smoke()` 回归  
2. NY `timezone_iana` → 冬 `offset=-300`／夏 `offset=-240`；墙钟小时互转

Cookbook：`examples/cookbook/datetime_iana.x`（DT-01；非本闸硬绿，探针邻域）。

---

## 4. Gate

```bash
./tests/run-std-datetime-iana-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `iana_dst_smoke.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- C smoke **仅观测**（archaeology host-C；非硬绿信号）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`）
- 禁顶层 DOC 复活（live = `analysis/archive/std/`）

manifest：`tests/baseline/std-datetime-iana-manifest.tsv`

### 4.1 Changelog

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；C smoke 观测；未啃产品 `std/datetime`）。
