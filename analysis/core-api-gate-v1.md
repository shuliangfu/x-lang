# CORE-014 core 全模块 manifest gate v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-014、`BOOT-013` check 矩阵

---

## 1. 目标

| ID | 交付 |
|----|------|
| CORE-014 | 11 个 `core.*` 模块均有 baseline manifest + 符号锚点 |
| 验收 | `run-core-api-gate.sh` 全绿 |

---

## 2. 注册表

`tests/baseline/core-api.tsv` 列：

| 列 | 含义 |
|----|------|
| `module_id` | `core.types` 等 |
| `manifest` | baseline TSV 路径 |
| `mod_path` | `core/xxx/mod.x` |
| `kind` | `api`（每行符号）或 `feature`（CORE 专项 manifest） |
| `sub_gate` | 专项门禁脚本（`-` 表示仅 api manifest） |

**v1 覆盖 11 模块**（`min_modules=11`；与 `stdlib-check-matrix.tsv` 一致）：`core.types`、`core.mem`、`core.option`、`core.result`、`core.slice`、`core.fmt`、`core.builtin`、`core.debug`、`core.cmp`、`core.iterator`、`core.str`。

---

## 3. manifest 类型

- **api**：`core-debug-api.tsv` 等，每行一个 `function` 符号
- **feature**：`core-slice-api.tsv` 等，校验 `kind=symbol` 且 `mod_path` 匹配的行

共享 manifest：`core.option` / `core.result` 共用 `core-option-result.tsv`，按 `mod_path` 列过滤符号。

---

## 4. Gate 与 report

```bash
./tests/run-core-api-gate.sh
```

```
shux: [SHUX_CORE_API] status=ok covered=11 sym_miss=0 gate_miss=0
```

便携回归：`tests/run-portable-suite.sh`

---

## 5. 演进

- CORE-015：同步 `core/README.md` 与 `docs/07` 章节锚点
- 将 api manifest 与 feature manifest 收敛为 STBL-003 模板
