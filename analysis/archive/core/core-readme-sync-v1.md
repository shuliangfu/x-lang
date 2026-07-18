# CORE-015 core/README 与 docs/07 同步 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-015、`CORE-014` manifest gate

---

## 1. 目标

消除 `core/README.md` 与 `docs/07-内置与标准库.md` 的**文档漂移**（过时「占位」表述、缺模块行、缺 gate 锚点）。

验收：gate 禁止过时措辞 + 要求 11 模块与横切 gate 锚点存在于两份文档。

---

## 2. 禁止措辞

| 过时表述 | 目标文件 | 原因 |
|----------|----------|------|
| `格式化占位` | docs/07 | CORE-010 已交付 fmt_*_to_buf |
| `主要为占位` | docs/07 | CORE-009 builtin 已实装 |
| `阶段 7 扩展清单` | core/README | 已由 Phase 2 模块表替代 |

---

## 3. 必需锚点（各 11 模块 + gate）

两份文件均须包含：

- 11 个 `core.*` 模块名（`core.types` / `core.mem` / `core.option` / `core.result` / `core.slice` / `core.fmt` / `core.builtin` / `core.debug` / `core.cmp` / `core.iterator` / `core.str`）
- `run-core-api-gate`（CORE-014 横切门禁）
- `NEXT.md`（Phase 2 路线图）

---

## 4. Gate 与 report

- 门禁：`tests/run-core-readme-sync-gate.sh`
- manifest：`tests/baseline/core-readme-sync.tsv`
- 便携回归：`tests/run-portable-suite.sh`

```
shux: [SHUX_CORE_README] status=ok forbidden=0 readme_miss=0 doc_miss=0
```

---

## 5. 维护

新增 core 模块时：同步更新 `core-api.tsv`、本 manifest 锚点行、`core/README.md` 与 `docs/07` 表格。
