# SAFE-002 unsafe API 清单化管理 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`LANG-007`（模式边界）、`SAFE-003`（审计流程）

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **清单化** | Tier-U public API 与关键 extern 有权威 TSV |
| **自动检查** | CI 验证符号存在 + extern 无未登记漂移 |
| **变更可控** | 新增 unsafe 面须改 baseline（SAFE-003 审计后续） |

验收（NEXT SAFE-002）：**unsafe 清单自动检查** + 文档 + 门禁。

---

## 2. 清单分层

| 清单 | 文件 | 范围 |
|------|------|------|
| **Tier-U API** | `tests/baseline/safe-unsafe-api.tsv` | 52 个 public struct/function（U1/U2/U3） |
| **Tier-E extern** | `tests/baseline/safe-unsafe-extern.tsv` | std.ffi / std.runtime / std.dynlib 全量 extern（8） |

**不在 v1 全量锁定**：std.heap / std.fs 内部 `_c` extern（数量大）；其 **public wrapper** 已入 Tier-U API。

---

## 3. 模式映射（LANG-007）

| mode | 清单示例 |
|------|----------|
| **U1** | `Arena64`、`ReadPtrView`、`Vec_i32` |
| **U2** | `read`/`write`（*u8+len）、`path_join` |
| **U3** | `alloc`/`free`、`fs_mmap_*`、`dynlib.open`、`panic` |

---

## 4. 门禁行为

`tests/run-safe-unsafe-api-gate.sh`：

1. **manifest**：RFC + 两份 TSV 存在  
2. **symbol check**：每个 Tier-U 条目在 `source_file` 可 grep 到  
3. **extern drift**：对 Tier-E 模块，源码中 `extern function` 集合须与 baseline **完全一致**  
4. **联动**：`run-lang-unsafe-gate.sh`（LANG-007 模式烟测）

---

## 5. 变更流程

| 操作 | 步骤 |
|------|------|
| 新增 Tier-U public API | 更新 `safe-unsafe-api.tsv` + LANG-007 文档（若新模式） |
| 新增 Tier-E extern | 更新 `safe-unsafe-extern.tsv` + SAFE-003 审计记录 |
| 删除符号 | 从 TSV 移除 + 确认无用户依赖 |

---

## 6. 与 SAFE-003 衔接

✅ **审计 ledger**：`tests/baseline/safe-unsafe-audit.tsv`（每条 Tier-U/Tier-E 须 owner + rationale + reviewer + date）。  
新增清单条目 **同 PR** 增审计行；门禁 `run-safe-unsafe-audit-gate.sh`。

---

## 7. 索引

| 资源 | 路径 |
|------|------|
| 模式 RFC | `analysis/lang-unsafe-v1-rfc.md` |
| Tier-U 清单 | `tests/baseline/safe-unsafe-api.tsv` |
| Tier-E 清单 | `tests/baseline/safe-unsafe-extern.tsv` |
| 门禁 | `tests/run-safe-unsafe-api-gate.sh` |

**SAFE-002 状态：定版 ✅**
