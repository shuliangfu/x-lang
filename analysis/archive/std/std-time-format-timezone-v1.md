# STD-137：std.time 墙钟格式化与时区偏移 v1

> 状态：**定版（v1）**  
> 高层 DateTime/命名时区见 `std.datetime`（STD-135）

## API

| 名称 | 说明 |
|------|------|
| `format_wall_rfc3339` | 当前墙钟 UTC → RFC3339（Z） |
| `wall_local_offset_min` | 本地相对 UTC 偏移（分钟） |
| `format_timezone_smoke` | C 金样 |

C 层委托 `datetime_format_rfc3339_c` / `datetime_local_offset_min_c`，避免 `.x` 循环 import。

## 3. Gate

```bash
./tests/run-std-time-format-timezone-gate.sh
```

Honesty (2026-08-28 soft fallthrough residual): prefer `xlang_asm` + pin
`XLANG_LINK_XLANG`; explicit-bad `XLANG` / missing native → hard die (refuse
soft fallthrough / prefer-c / soft auto-make / soft SKIP→OK). check
observational (paused 2026-08-05). `format_timezone.x` exit 0 hard-fail
(`run+=`). C smoke observational only (existing `.o`; no soft rebuild;
`obs+=`). Report `run=` / `obs=` / `skip=`.
- 拒顶层 DOC 复活（live = `analysis/archive/std/`）

**Honesty (2026-08-29 leftover wrap dead source)**：leftover `bootstrap-link-xlang.sh` sourced unused（no `RUN_XLANG`）+ unused `compiler-make.sh` retired from `tests/run-std-time-format-timezone-gate.sh`. Prefer asm + `XLANG_LINK_XLANG`；explicit-bad XLANG hard die；missing native FAIL；product `-o` `format_timezone.x` hard；check／C smoke＝obs；report `run=`／`obs=`／`skip=`。Keep `## 3. Gate`。 Leave wrap body / ensure_std family.

manifest：`tests/baseline/std-time-format-timezone-manifest.tsv`

### 3.1 Changelog

- 2026-08-26：Gate honesty soft→硬绿（prefer asm／LINK／check 观测／runnable hard；C smoke 观测；未啃产品 `std/time`）。
- 2026-08-29：leftover wrap 死 source：删 unused wrap source + unused `compiler-make.sh`；Keep `## 3. Gate`。
