# DOC-013：2027-Q3 对外路线图刷新 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：DOC-012 Q2 刷新、`NEXT.md` §2.15 Phase 3 第四批全 ✅  
> 触发：wave4 收官后按 `doc-public-roadmap-v1.md` §6 季度流程执行 Q2→Q3 bump

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 变更摘要 |
| 2 | 对照 `analysis/doc-public-roadmap-v1.md` §3～§5 |
| 3 | `./tests/run-doc-public-roadmap-q3-gate.sh` |

---

## 2. Q3 变更摘要

| 项 | Q2（旧） | Q3（新） |
|----|----------|----------|
| 当季版本 | 2027-Q2 | **2027-Q3** |
| §3 主题 | Phase 3 第三批收官 | **Phase 3 第四批收官** |
| M1 第四批 | ⚪ 预览 | **✅** §2.15 全 4 项 |
| M2 mega7 7/7 | BOOT-022 emit 晋升 | **✅** BOOT-023 `promote_emit=7` |
| M3 编译器 | COMP-016 riscv64 矩阵 | **✅** COMP-017 WPO default tier |
| M4 std.db | STD-064 phdr | **✅** STD-065 exec 深化烟测 |
| §4 亮点 | wave3 emit/riscv64/phdr | **wave4** 7/7/WPO/db/治理 |
| §5 预览 | 2027-Q3（已交付） | **2027-Q4** 第五批预览 |
| manifest | `quarter_anchor=2027-Q2` | `quarter_anchor=2027-Q3` |

---

## 3. 验收

```bash
./tests/run-doc-public-roadmap-q3-gate.sh
```

```
shux: [SHUX_DOC013_ROADMAP_Q3] status=ok quarter=2027-Q3 roadmap_gate=1
```

联动：`run-doc-public-roadmap-gate.sh`（DOC-005）须同步绿；遵循 DOC-005 `public quarterly` 流程。

---

## 4. 非目标

- Phase 3 第五批任务 ID 全表（留待 §2.16 独立 RFC）  
- 社区 Release Notes 正文撰写
