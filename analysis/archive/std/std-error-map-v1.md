# STD-020 std.error 错误码映射与 last_error 约定 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-020、`STD-011`、`EXC-003`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-020 | 码 → 模块 base 查询 API + 各模块 `last_error` 侧车约定表 |

在 STD-011 段分配之上，提供**可编程映射**与**侧车种类**文档，避免 errno 写入 `Result.err`。

---

## 2. 查询 API（std.error）

| 函数 | 说明 |
|------|------|
| `error_code_to_module_base(code)` | 负码 → 所属 `error_base_*`；L 层/未知 → `0` |
| `error_mod_tag_from_base(base)` | base → 模块标签（1..9） |
| `error_mod_base_from_tag(tag)` | 标签 → base（无 B 层段则 `0`） |
| `error_module_sidecar_kind(tag)` | 侧车种类：`none` / `errno_i32` / `db_struct` |

侧车常量：`error_sidecar_none` / `error_sidecar_errno_i32` / `error_sidecar_db_struct`。

---

## 3. last_error 约定表

| 模块 | 失败形态 | 侧车 API | 侧车种类 | 备注 |
|------|----------|----------|----------|------|
| std.io | Layer C `-1` | — | none | 无 errno 侧车 v1 |
| std.fs | Layer C `-1` + B 层码 | `fs_last_error()` | errno_i32 | S 层正 errno |
| std.net | Layer C `-1` | — | none | DNS 用 `resolve_err_*` |
| std.async | B 层占位 | — | none | v1 占位 |
| coll/heap | `-1` = alloc | — | none | 映射 `error_code_alloc_fail` |
| std.db | 本地 `-1..-9` | `last_error()` → `DbError` | db_struct | 无 `error_base_db` v1 |
| std.process | Layer C `-1` | — | none | spawn/wait 标量 |
| std.http | Layer C `-1` | — | none | 状态行/读写失败 |
| std.json | 本地负码 | — | none | parse/serialize |

**铁律**：`fs_last_error()` 返回值**不得**写入 `Result_i32.err`（EXC-003 S 层）。

---

## 4. 边界金样

| 场景 | 期望 |
|------|------|
| `error_code_to_module_base(io_err_timeout())` | `error_base_io()` |
| `error_code_to_module_base(error_code_invalid())` | `0`（L 层） |
| `error_module_sidecar_kind(error_mod_tag_fs())` | `error_sidecar_errno_i32()` |
| `error_module_sidecar_kind(error_mod_tag_db())` | `error_sidecar_db_struct()` |
| `error_mod_base_from_tag(error_mod_tag_db())` | `0`（尚无 B 层段） |

---

## 5. 验收

- manifest：`tests/baseline/std-error-map.tsv`
- 烟测：`tests/std/error_map_smoke.x`
- 门禁：`tests/run-std-error-map-gate.sh`（`SHUX_STD_ERROR_MAP`）
- 报告：`shux: [SHUX_STD_ERROR_MAP] status=ok`

---

## 6. 演进

- `error_base_db` 分配后更新 `error_code_to_module_base` 与 manifest
- `std.net` / `std.process` 可选 errno 侧车需新 RFC
