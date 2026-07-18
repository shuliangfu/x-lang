# STD-168 placeholder() 清单冻结 v1

> 更新时间：2026-06-18  
> 状态：**审计冻结（v2 · 清理后）**  
> 关联：`NEXT.md` §6.1

---

## 1. 说明

`placeholder()` 为历史 **import 烟测钩子**，不是业务 API。Tier-S manifest（`std-fmt-api.tsv`、`std-async-api.tsv`）中保留的 `placeholder` 表示「模块可链接」。

**保留 6 处（烟测 / Tier-S 依赖）：**

| 模块 | 原因 |
|------|------|
| `core.types` | `tests/stdlib-import/main.x` |
| `core.builtin` | `tests/builtin/main.x` |
| `core.mem` | `tests/mem/main.x` |
| `core.fmt` | `std.fmt.placeholder()` 委托 |
| `std.fmt` | Tier-S manifest |
| `std.async` | Tier-S manifest |

其余 31 个模块已移除 `placeholder()`（2026-06-18 清理）。

---

## 2. 冻结策略

- manifest：`tests/baseline/placeholder-inventory.tsv`（`max_count=6`）
- 门禁：`tests/run-placeholder-inventory-gate.sh`
- 规则：源码中 `function placeholder()` 数量 **不得高于** manifest `max_count`（只减不增）

---

## 3. 演进

- 新模块**禁止**新增 `placeholder()`；用真实 API 或测试专用符号。
- 进一步移除时须同步 Tier-S manifest + 烟测。
