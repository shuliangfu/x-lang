# STD-090 std.schema v1

> 更新时间：2026-06-18  
> 状态：**可用** — Schema 注册 + JSON/CSV/列映射 decode + gate

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 API |
| 2 | `tests/baseline/std-schema-manifest.tsv` |
| 3 | `./tests/run-std-schema-gate.sh` |

---

## 2. API

| API（活面 `.x` 短名） | 说明 |
|-----|------|
| `new` / `add_field`（DOC 旧称 `schema_new` / `schema_add_field`） | 字段类型注册（标量/可选/col_index） |
| `decode_json` | JSON 对象 typed decode + 校验错误 |
| `decode_csv_row` | CSV 行按 col_index 映射 |
| `map_columns` | SQLite/CSV 列文本统一映射 |
| `get_string` / `get`（overload i32/bool/f64；DOC 旧称 `get_i32`／`get_bool`） | 读取 decode 结果 |
| `last_error_field` / `last_error_message` | 字段级错误路径 |
| `to_code`（DOC 旧称 `schema_to_error_code`） | 与 std.error 负码桥接 |

实现：`std/schema/mod.x` + `std/schema/schema.x`；链入 json + csv。Manifest 锚为活面短名（拒化石 `schema_new`／`get_i32` 假红）。

---

## 3. Gate

```
xlang: [XLANG_STD_SCHEMA] status=ok run=0 obs=3 skip=0
std-schema gate OK
```

### Gate honesty (2026-08-28)

- Prefer product `xlang_asm`; pin `XLANG_LINK_XLANG`. Explicit bad / missing native = hard die.
- Refuse soft prefer-c / soft auto-make / soft SKIP→OK / check-as-sole-green.
- check residual = obs (paused 2026-08-05). tip product `-o` `std_schema_*` UNDEF = obs (product debt leave).
- Host-C smoke: prebuilt `.o` only (refuse soft ensure / soft auto-make); miss/fail = obs archaeology.
- Report contract: `run=` / `obs=` / `skip=` (retired `c_smoke=` / `x=`). Archive DOC is live authority (refuse top-level resurrect).
- Cross-links: [std-metrics-v1](std-metrics-v1.md) · [std-codec-v1](std-codec-v1.md).

---

## 4. 后续（非 v1 阻塞）

- 嵌套 object / array 字段  
- 与 std.db.sqlite stmt 一步 decode  
- JSON Schema 子集导入  
