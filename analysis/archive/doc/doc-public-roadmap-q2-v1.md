# DOC-012：2027-Q2 对外路线图刷新 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：DOC-011 Q1 刷新、`NEXT.md` §2.14 Phase 3 第三批全 ✅  
> 触发：wave3 收官后按 `doc-public-roadmap-v1.md` §6 季度流程执行 Q1→Q2 bump

---

## 1. 阅读路径

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 变更摘要 |
| 2 | 对照 `analysis/doc-public-roadmap-v1.md` §3～§5 |
| 3 | `./tests/run-doc-public-roadmap-q2-gate.sh` |

---

## 2. Q2 变更摘要

| 项 | Q1（旧） | Q2（新） |
|----|----------|----------|
| 当季版本 | 2027-Q1 | **2027-Q2** |
| §3 主题 | Phase 3 第二批收官 | **Phase 3 第三批收官** |
| M1 第三批 | ⚪ 预览 | **✅** §2.14 全 4 项 |
| M2 mega7 emit | BOOT-021 promote | **✅** BOOT-022 emit 晋升 |
| M3 编译器 | COMP-015 WPO prod | **✅** COMP-016 riscv64 矩阵 |
| M4 std.elf | STD-063 节深化 | **✅** STD-064 program header |
| §4 亮点 | wave2 自举/WPO/ELF | **wave3** emit/riscv64/phdr/治理 |
| §5 预览 | 2027-Q2（已交付） | **2027-Q3** 第四批预览 |
| manifest | `quarter_anchor=2027-Q1` | `quarter_anchor=2027-Q2` |

---

## 3. 验收

```bash
./tests/run-doc-public-roadmap-q2-gate.sh
```

```
shux: [SHUX_DOC012_ROADMAP_Q2] status=ok quarter=2027-Q2 roadmap_gate=1
```

联动：`run-doc-public-roadmap-gate.sh`（DOC-005）须同步绿；遵循 DOC-005 `public quarterly` 流程。

---

## 4. 非目标

- Phase 3 第四批任务 ID 全表（留待 §2.15 独立 RFC）  
- 社区 Release Notes 正文撰写
