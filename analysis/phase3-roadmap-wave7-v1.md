# PLAN-007：Phase 3 第七批路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：PLAN-006 `phase3-roadmap-wave6-v1.md`、§2.17 第六批 ✅  
> 内部追踪：`NEXT.md` §2.18（Phase 3 第七批）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2028-Q2 聚焦 |
| 2 | §3 成功判据 | 第七批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave7 manifest 绿 |

联动：`analysis/doc-public-roadmap-v1.md` §5（2027-Q3 预览承前）、PLAN-006 §2。

---

## 2. 北极星目标（第七批）

1. **parser C4 SX bootstrap**：无 C TU 切片的全量 parser.sx emit 路径（BOOT-026）。
2. **incr-compile 二次编译烟测扩面**：`comp-incr-compile.tsv` 原型持续门禁（COMP-020）。
3. **std.db 文本列读取**：`row_col_text` 列值原型（STD-068）。
4. **治理闭环**：第七批路线图 manifest + gate 与 `NEXT.md` §2.18 同步（PLAN-007）。

---

## 3. 成功判据（2028-Q2 预览 · 第七批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-026 C4 bootstrap emit；Linux `c4_ok=1` |
| **编译器** | COMP-020 `comp-incr-compile` 烟测 gate 绿 |
| **std** | STD-068 `db_sqlite_row_col_text_smoke_c` 文本列烟测 |
| **治理** | §2.18 四项均为 ✅；wave7 gate 绿 |

---

## 4. 第七批待办索引（§2.18）

| ID | 领域 | 待办 | 优先级 | Gate |
|----|------|------|--------|------|
| BOOT-026 | 自举 | parser C4 全量 SX bootstrap | P0 | `run-boot-026-parser-c4-bootstrap-gate.sh` |
| COMP-020 | 编译器 | incr-compile 二次编译烟测扩面 | P1 | `run-comp-incr-compile-wave-gate.sh` |
| STD-068 | 标准库 | `std.db` row_col_text 文本列 | P2 | `run-std-db-row-col-text-gate.sh` |
| PLAN-007 | 治理 | Phase 3 第七批路线图定版 | P2 | `run-phase3-roadmap-wave7-gate.sh` |

完整状态列见 `NEXT.md` §2.18。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-wave7-gate.sh
```

```
shux: [SHUX_PLAN007_PHASE3_W7] status=ok tasks=4 sections=5 done=4
```

---

## 6. 非目标（v8 第八批定版）

- BOOT-027 / COMP-021 / STD-069 见 wave8 各 RFC
- 对外路线图 **2027-Q4** 季度刷新（DOC-014）
