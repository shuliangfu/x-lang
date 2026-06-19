# DOC-010：2026-Q4 对外路线图刷新 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：DOC-009 Q3 刷新、`NEXT.md` §2.12 Phase 3 首批全 ✅  
> 触发：Phase 3 收官后按 `doc-public-roadmap-v1.md` §6 季度流程执行 Q3→Q4 bump

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 变更摘要 |
| 2 | 对照 `analysis/doc-public-roadmap-v1.md` §3～§5 |
| 3 | `./tests/run-doc-public-roadmap-q4-gate.sh` |

---

## 2. Q4 变更摘要

| 项 | Q3（旧） | Q4（新） |
|----|----------|----------|
| 当季版本 | 2026-Q3 | **2026-Q4** |
| §3 主题 | 自举深化 + mega7 推进 | **Phase 3 首批收官** |
| M2 mega7 | 🟡 | **✅** BOOT-020 里程碑 gate |
| M3 WPO/isel | 🟡 | **✅** COMP-013/014 质量波次 |
| M6 VS Code | 🟡 0.1.x | **✅** `vscode-shux` **0.2.0** |
| §4 亮点 | Phase 2 摘要 | **Phase 3** 泛型/自举/编译器/std/生态 |
| §5 预览 | Q4 计划（已交付） | **2027-Q1** 第二批预览 |
| manifest | `quarter_anchor=2026-Q3` | `quarter_anchor=2026-Q4` |

---

## 3. 验收

```bash
./tests/run-doc-public-roadmap-q4-gate.sh
```

```
shux: [SHUX_DOC010_ROADMAP_Q4] status=ok quarter=2026-Q4 roadmap_gate=1
```

联动：`run-doc-public-roadmap-gate.sh`（DOC-005）须同步绿；遵循 DOC-005 `public quarterly` 流程。

---

## 4. 非目标

- Phase 3 第二批任务 ID 全表（留待 §2.13 独立 RFC）  
- 社区 Release Notes 正文撰写
