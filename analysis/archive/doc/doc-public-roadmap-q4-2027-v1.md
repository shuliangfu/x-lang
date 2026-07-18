# DOC-014：2027-Q4 对外路线图刷新 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：DOC-013 Q3 刷新、`NEXT.md` §2.16 Phase 3 第五批全 ✅  
> 触发：wave5 收官后按 `doc-public-roadmap-v1.md` §6 季度流程执行 Q3→Q4 bump

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 变更摘要 |
| 2 | 对照 `analysis/doc-public-roadmap-v1.md` §3～§5 |
| 3 | `./tests/run-doc-public-roadmap-q4-2027-gate.sh` |

---

## 2. Q4 变更摘要

| 项 | Q3（旧） | Q4（新） |
|----|----------|----------|
| 当季版本 | 2027-Q3 | **2027-Q4** |
| §3 主题 | Phase 3 第四批收官 | **Phase 3 第五批收官** |
| M1 第五批 | ⚪ 预览 | **✅** §2.16 全 4 项 |
| M2 parser C2 emit | BOOT-023 7/7 | **✅** BOOT-024 bootstrap emit |
| M3 编译器 | COMP-017 WPO default | **✅** COMP-018 riscv64 QEMU |
| M4 std.db | STD-065 exec 深化 | **✅** STD-066 query_rows 原型 |
| §4 亮点 | wave4 7/7/WPO/db/治理 | **wave5** C2/QEMU/query_rows/治理 |
| §5 预览 | 2027-Q4（已交付） | **2028-Q1** 第六批预览 |
| manifest | `quarter_anchor=2027-Q3` | `quarter_anchor=2027-Q4` |

---

## 3. 验收

```bash
./tests/run-doc-public-roadmap-q4-2027-gate.sh
```

```
shux: [SHUX_DOC014_ROADMAP_Q4Y7] status=ok quarter=2027-Q4 roadmap_gate=1
```

联动：`run-doc-public-roadmap-gate.sh`（DOC-005）须同步绿；遵循 DOC-005 `public quarterly` 流程。

---

## 4. 非目标

- Phase 3 第六批任务 ID 全表（留待 §2.17 独立 RFC）  
- 社区 Release Notes 正文撰写
