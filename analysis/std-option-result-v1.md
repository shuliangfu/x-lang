# STD-080 std.option & STD-081 std.result v1

> 更新时间：2026-06-18  
> 状态：**可用** — core 重导出 + 互转/错误桥接 + gate

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
| `ok_i32` / `err_i32` | 构造 |
| `is_ok_i32` / `is_err_i32` / `unwrap_or_i32` | 解包与判定 |
| `result_map_i32` / `result_and_then_i32` / `result_or_else_i32` | eager 组合子（Result 侧，避免与 option 重名） |
| `result_from_code` / `result_from_value_i32` | std.error 桥接 |
| `result_err_code` | 提取错误码 |

---

## 3. Gate

```
shux: [SHUX_STD_OPTION_RESULT] status=ok sx=1 skip=0
std-option-result gate OK
```
