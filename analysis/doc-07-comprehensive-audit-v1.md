# STD-168 docs/07 全面审计 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` §7、`STD-156～167`、`CORE-018～020`

---

## 1. 目标

在 DOC-007 全表 gate 之上，校验 **近期交付**（NEXT-YELLOW / STD-156～167）是否已写入 `docs/07-内置与标准库.md` 与 Cookbook 索引。

---

## 2. manifest

- 关键词矩阵：`tests/baseline/doc-07-comprehensive-audit.tsv`
- 用户文档：`docs/07-内置与标准库.md` §「STD-156～167 / CORE-018～020」
- placeholder 冻结：`tests/run-placeholder-inventory-gate.sh`

---

## 3. 验收

- 门禁：`tests/run-doc-07-comprehensive-audit-gate.sh`
- 汇总：`tests/run-comprehensive-check-gate.sh`（全面检查入口）
- 报告：`doc-07-comprehensive-audit gate OK`
