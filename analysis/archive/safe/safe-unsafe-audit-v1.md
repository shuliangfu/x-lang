# SAFE-003 unsafe 审计流程 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`SAFE-002`（清单）、`LANG-007`（模式）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **审计可追溯** | 每个 Tier-U / Tier-E unsafe 面有 owner + rationale + reviewer |
| **新增必审计** | 改 `safe-unsafe-api.tsv` / `safe-unsafe-extern.tsv` 须同步审计 ledger |
| **CI 硬门禁** | 清单条目 ⊆ 审计 ledger，字段非空 |

验收（NEXT SAFE-003）：**新增 unsafe 必须有审计记录** + 文档 + 门禁。

---

## 2. 审计 ledger

文件：`tests/baseline/safe-unsafe-audit.tsv`

| 列 | 说明 |
|----|------|
| `scope` | `tier-u`（public API）或 `tier-e`（锁定 extern） |
| `symbol` | 与 SAFE-002 清单 symbol 一致 |
| `owner` | 维护方（v1 默认 `stdlib`） |
| `rationale` | 为何需要 unsafe / 边界约定（一行） |
| `reviewer` | 审计人（PR reviewer 或 `v1-baseline` 初始导入） |
| `audit_date` | `YYYY-MM-DD` |

当前：**60** 条（52 tier-u + 8 tier-e），与 SAFE-002 baseline 同步。

---

## 3. 新增 unsafe 流程（PR）

1. 在 `safe-unsafe-api.tsv` 和/或 `safe-unsafe-extern.tsv` 增条目  
2. **同 PR** 在 `safe-unsafe-audit.tsv` 增一行：

```
tier-u	MyApi	stdlib	One-line rationale your-handle	2026-06-17
```

3. 若新模式 → 更新 `analysis/lang-unsafe-v1-rfc.md`  
4. 跑 `./tests/run-safe-unsafe-audit-gate.sh`（含 SAFE-002）

**PR 检查项（复制到描述）**：

- [ ] `safe-unsafe-api.tsv` / `safe-unsafe-extern.tsv` 已更新  
- [ ] `safe-unsafe-audit.tsv` 已增对应行（owner / rationale / reviewer / date）  
- [ ] `run-safe-unsafe-audit-gate.sh` 本地或 CI 通过  

---

## 4. 门禁

`tests/run-safe-unsafe-audit-gate.sh`：

1. manifest：RFC + audit TSV  
2. **coverage**：SAFE-002 每条 tier-u / tier-e 须在 audit 中有唯一行  
3. **fields**：owner / rationale / reviewer / audit_date 非空；date 格式 `YYYY-MM-DD`  
4. **no orphan**：audit 中不得有多余 symbol（防 ledger 漂移）  
5. hook：`run-safe-unsafe-api-gate.sh`

---

## 5. 字段约定（v1）

| 字段 | 要求 |
|------|------|
| `owner` | 模块维护组：`stdlib` / `compiler` / `core` |
| `rationale` | ≤120 字符；说明责任边界（谁保证 lifetime/ABI） |
| `reviewer` | GitHub handle 或 `v1-baseline`（仅初始导入） |
| `audit_date` | ISO 日期；新增/重审时更新 |

---

## 6. 与 SAFE-002 衔接

| 变更 | 须同步 |
|------|--------|
| 增 Tier-U API | `safe-unsafe-api.tsv` + audit `tier-u` 行 |
| 增 Tier-E extern | `safe-unsafe-extern.tsv` + audit `tier-e` 行 |
| 删 symbol | 两处清单 + audit 同 PR 删除 |

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 清单 RFC | `analysis/safe-unsafe-api-v1.md` |
| 审计 ledger | `tests/baseline/safe-unsafe-audit.tsv` |
| 门禁 | `tests/run-safe-unsafe-audit-gate.sh` |
| 新增模板 | `tests/templates/safe-unsafe-audit-entry.txt` |

**SAFE-003 状态：定版 ✅**
