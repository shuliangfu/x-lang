# DOC-011：2027-Q1 对外路线图刷新 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：DOC-010 Q4 刷新、`NEXT.md` §2.13 Phase 3 第二批全 ✅  
> 触发：wave2 收官后按 `doc-public-roadmap-v1.md` §6 季度流程执行 Q4→Q1 bump

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 变更摘要 |
| 2 | 对照 `analysis/doc-public-roadmap-v1.md` §3～§5 |
| 3 | `./tests/run-doc-public-roadmap-q1-gate.sh` |

---

## 2. Q1 变更摘要

| 项 | Q4（旧） | Q1（新） |
|----|----------|----------|
| 当季版本 | 2026-Q4 | **2027-Q1** |
| §3 主题 | Phase 3 首批收官 | **Phase 3 第二批收官** |
| M1 第二批 | ⚪ 预览 | **✅** §2.13 全 4 项 |
| M2 mega7 | BOOT-020 里程碑 | **✅** BOOT-021 promote wave |
| M3 WPO | COMP-013/014 波次 | **✅** COMP-015 prod tier |
| M4 std.elf | 占位 | **✅** STD-063 深化 API |
| §4 亮点 | Phase 3 首批 | **wave2** 自举/WPO/ELF/治理 |
| §5 预览 | 2027-Q1（已交付） | **2027-Q2** 第三批预览 |
| manifest | `quarter_anchor=2026-Q4` | `quarter_anchor=2027-Q1` |

---

## 3. 验收

```bash
./tests/run-doc-public-roadmap-q1-gate.sh
```

```
shux: [SHUX_DOC011_ROADMAP_Q1] status=ok quarter=2027-Q1 roadmap_gate=1
```

联动：`run-doc-public-roadmap-gate.sh`（DOC-005）须同步绿；遵循 DOC-005 `public quarterly` 流程。

---

## 4. 非目标

- Phase 3 第三批任务 ID 全表（留待 §2.14 独立 RFC）  
- 社区 Release Notes 正文撰写
