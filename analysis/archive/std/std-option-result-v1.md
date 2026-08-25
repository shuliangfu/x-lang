# STD-080 std.option & STD-081 std.result v1

> 更新时间：2026-08-26  
> 状态：**可用** — core 重导出 + 互转/错误桥接 + gate honesty（prefer asm）

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-option-manifest.tsv` / `std-result-manifest.tsv` |
| 3 | `./tests/run-std-option-result-gate.sh` |
| 4 | 联动 `tests/run-core-option-result-gate.sh` |

---

## 2. API

### std.option

| API | 说明 |
|-----|------|
| `none` / `some` | 构造 |
| `unwrap_or` / `is_some` / `is_none` | 解包与判定 |
| `map` / `and_then` / `or` | eager 组合子 |
| `from_result` | Result → Option（i32/u8 重载） |
| `to_result` | Option → Result |

### std.result

| API | 说明 |
|-----|------|
| `ok` / `err` | 构造（产品短名；**非**化石 `ok_i32` / `err_i32`） |
| `is_ok` / `is_err` / `unwrap_or` | 解包与判定 |
| `map` / `and_then` / `or_else` | eager 组合子 |
| `from_error_code` / `from_value` | std.error 桥接 |
| `err_code` | 提取错误码 |

烟测须 `err.ok()` / `err.code_*()`（裸 `ok()` 会命中 `result.ok` 一元 → arity T001）。

---

## 3. Gate

```
xlang: [XLANG_STD_OPTION_RESULT] status=ok check=0|1 run=1 skip=0
std-option-result gate OK
```

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`
- `check` 仅观测（自举期暂停 check 闸门）
- `roundtrip.x` exit 0 硬失败（无 soft SKIP）
- formal_mod：`std/option/option.o` + `std/result/result.o`（`mod|0`）；fk0 k25/k26；plan 入链

### Changelog

- **2026-08-26**：Gate honesty + API 锚对齐产品短名；formal_mod＋fk0＋plan；烟测 `err.*`／bool `false`。
