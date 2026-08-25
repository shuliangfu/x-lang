# STD-135：std.datetime 固定偏移时区 v1

> 更新时间：2026-08-26  
> 状态：**定版（v1，内置名 + ±HH:MM；无 IANA DST 表）** · Gate honesty soft→硬绿  
> 关联：STD-074 `std.datetime`；完整 IANA／DST 留后续

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-135 | 固定偏移 `TimeZone` + 墙钟字段互转 + 偏移文本解析 |
| 验收 | `timezone.x` 金样 + `run-std-datetime-timezone-gate.sh` 全绿（`check=`／`run=`／`skip=`） |

---

## 2. API

| 名称 | 说明 |
|------|------|
| `TimeZone` | 固定 `offset_min`（东为正） |
| `timezone_utc` / `timezone_local` / `timezone_fixed` | 构造 |
| `timezone_from_name` | UTC/JST/CST/HKT/IST/CET/EST/PST 等 |
| `parse_offset_min` | `+08:00` / `-0500` / `Z` |
| `to_zoned_fields` / `from_zoned_fields` | UTC ↔ 墙钟字段 |
| `timezone_smoke` | C／.x 金样入口 |

完整 IANA 时区表与 DST 规则留待后续；v1 覆盖工程常见固定偏移与 RFC3339 偏移文本。

实现：`std/datetime/mod.x` + `datetime.x`；墙钟复用 `std.time`。

---

## 3. 边界向量（金样）

`tests/std-datetime/timezone.x`：

1. JST `timezone_from_name` → `offset_min=540`；`from_zoned_fields`／`to_zoned_fields` round-trip  
2. `parse_offset_min("+08:00")` → 480；`timezone_fixed` 墙钟互转  
3. `timezone_smoke()`／`timezone_utc()` 回归

---

## 4. Gate

```bash
./tests/run-std-datetime-timezone-gate.sh
```

Honesty（2026-08-26）：

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（禁 Darwin asm→c 假权威）
- `xlang check` **观测**（自举期 check 闸门暂停；CHK 红不硬失败）
- `timezone.x` **exit 0 硬失败**（有 native xlang 时无 soft SKIP）
- C smoke **仅观测**（archaeology host-C；非硬绿信号）
- 报告行：`check=`／`run=`／`skip=`（硬绿信号＝`run=`）

manifest：`tests/baseline/std-datetime-timezone-manifest.tsv`

### Changelog

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；C smoke 观测；未啃产品 `std/datetime`）。
