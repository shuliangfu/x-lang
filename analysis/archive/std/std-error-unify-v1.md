# STD-011 标准库错误码统一 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-011、`EXC-003`、`STD-020`

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-011 | 各 std 模块 `error_base_*` + `<mod>_err_*` 与 EXC-003 分层对齐 |
| STD-020 | 扩展 `last_error` 侧车映射（见 `std-error-map-v1.md`） |

---

## 2. 模块码段（v1）

| 模块 | base | 首批 B 层码 | 侧车 |
|------|------|-------------|------|
| std.io | `-1000` | `io_err_generic/timeout/cancelled` | — |
| std.fs | `-1100` | `fs_err_generic/not_found` | `fs_last_error()` |
| std.net | `-1200` | `net_err_generic` | — |
| std.async | `-1300` | `async_err_generic` | — |
| coll/heap | `-1400` | `coll_err_generic`；C 层 `-1` = alloc | — |

全局 L 层：`-1..-99`（`error_code_alloc_fail` 等）。

---

## 3. manifest

- 矩阵：`tests/baseline/std-error-unify.tsv`
- 分层：`tests/baseline/exc-error-code-layer.tsv`
- last_error 扩展：`tests/baseline/std-error-map.tsv`（STD-020）
- EXC 分层 / Result RFC（已归档）：`analysis/archive/exc/exc-error-code-layer-v1.md` · `analysis/archive/exc/exc-result-error-v1-rfc.md`（**勿**再依赖顶层 `analysis/exc-*.md` 化石）

---

## 4. Gate

### 假权威诚实验收（2026-08-25）

- Prefer `xlang_asm`；钉 `XLANG_LINK_XLANG`（防 Darwin-arm64 asm→c remap）。
- `xlang check` **观测**（自举期 check 闸门暂停 2026-08-05）；不硬失败。
- 可跑烟测 `tests/std/error_unify_smoke.x` exit **0** 硬失败；有原生 xlang 时 **禁 soft SKIP**。
- EXC DOC 依赖指向 `analysis/archive/exc/`（顶层化石已迁走）。
- 报告：`check=`／`run=`／`skip=`（`run=1` 为硬绿信号）。

```
xlang: [XLANG_STD_ERROR_UNIFY] status=ok check=0|1 run=1 skip=0
std-error-unify gate OK
```

- API：`std/error/mod.x`（`error_base_*` / `<mod>_err_*` / helper）
- 烟测：`tests/std/error_unify_smoke.x`
- 门禁：`tests/run-std-error-unify-gate.sh` · lib：`tests/lib/std-error-unify.sh`

---

## 5. 演进

- 新模块先登记 `exc-error-code-layer.tsv` 再分配 `error_base_*`
- `error_code_to_module_base` 随新 base 扩展（STD-020）
