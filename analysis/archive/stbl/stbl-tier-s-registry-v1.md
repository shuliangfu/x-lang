# STBL-001 全模块 Tier-S manifest 注册表 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` §1 成功判据、`BOOT-013` check 矩阵

---

## 1. 目标

| ID | 交付 |
|----|------|
| STBL-001 | ≥25 个 `std.*` 子模块有 `tests/baseline/std-*-api.tsv` 或 feature manifest |
| 验收 | `run-stbl-001-tier-s-gate.sh` 全绿 |

---

## 2. 注册表

`tests/baseline/stbl-tier-s-registry.tsv` 列：

| 列 | 含义 |
|----|------|
| `module_id` | `std.io` 等 |
| `manifest` | baseline TSV 路径 |
| `mod_path` | `std/xxx/mod.x` |
| `kind` | `api`（每行符号）或 `feature`（STD 专项 manifest） |

**v1 覆盖 28 模块**（`min_modules=28`；含既有 STD-001～024 manifest + 本轮新增 12 个 `*-api.tsv`）。

---

## 3. 新增 api manifest（STBL-001 波次 1）

`heap` `fmt` `path` `thread` `channel` `atomic` `sync` `env` `base64` `random` `hash` `queue` `set`（示例：`std.heap` → `tests/baseline/std-heap-api.tsv`）

每文件 5～9 个 Tier-S 公开符号；gate 用 `function <sym>(` 锚定。

---

## 4. Gate 与 report

```bash
./tests/run-stbl-001-tier-s-gate.sh
```

```
shux: [SHUX_STBL_TIER_S] status=ok covered=28 sym_miss=0
```

便携回归：`tests/run-portable-suite.sh`

---

## 5. 后续波次（非 v1 阻塞）

- 波次 2：为 `log` `encoding` `tar` `unicode` `regex` `simd` `math` 等补 api manifest  
- 波次 3：将 feature manifest 统一收敛为 `api` + 可选 `gate` 行（STBL-003 模板）
