# STD-074 std.datetime v1

> 更新时间：2026-08-29  
> 状态：**可用** — DateTime + RFC3339 + Duration + gate honesty（残 auto-make 已退役）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-datetime-manifest.tsv` |
| 3 | `./tests/run-std-datetime-gate.sh` |

---

## 2. API

| API | 说明 |
|-----|------|
| `DateTime` / `now_utc` / `from_unix` | UTC 墙钟表示 |
| `DateFields` / `from_utc_fields` / `to_utc_fields` | 日历字段 |
| `parse_rfc3339` / `format_rfc3339` / `format_rfc3339_nano` | RFC3339 与 Nano |
| `local_offset_min` / `to_local_fields` | 平台本地时区偏移 |
| `Duration` / `add_duration` / `duration_between` | 纳秒算术 |
| `duration_sleep` / `duration_from_monotonic` | 与 std.time 互操作 |
| `compare` | 时刻比较 |

实现：`std/datetime/mod.x` + `datetime.x`/`datetime_tz_glue.c`；墙钟复用 `std.time`。

---

## 3. Gate

Honesty（2026-08-29 残 auto-make）：prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`；显式坏 XLANG／缺 native 硬 die；拒 soft `xlang_compiler_make` 重建 datetime.o／time.o／runtime_time_os.o；host-C 仅现成 `.o`＝obs；`check` 观测；`roundtrip.x` exit0 硬失败；报告 `run=`／`obs=`／`skip=`。

```bash
./tests/run-std-datetime-gate.sh
```

```
xlang: [XLANG_STD_DATETIME] status=ok run=1 obs=2 skip=0
std-datetime gate OK
```

（Darwin 上 `check` CHK residual＝obs；host-C 现成 `.o` 或缺 `.o` 均为 obs。硬绿信号是 `run=1`。）

向量：`tests/baseline/std-datetime-vectors.tsv`。

---

## 4. Changelog

- 2026-08-29：残 soft auto-make（host-C 前 `xlang_compiler_make` 重建 datetime.o／time.o／runtime_time_os.o）退役；host-C 仅现成 `.o`＝obs；报告 `run=`／`obs=`／`skip=`。
- 2026-08-25：闸／TSV／DOC 假权威诚实化；钉盘不升。
- 2026-06-18：v1 初版（DateTime + RFC3339 + Duration + gate）。

## 5. 后续（非 v1 阻塞）

- IANA TZ / DST（STD-136；同波 honesty 见 `std-datetime-iana-v1.md`）
- 固定偏移 timezone（STD-135；见 `std-datetime-timezone-v1.md`）
