# PLAN-006：Phase 3 第六批路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：PLAN-005 `phase3-roadmap-wave5-v1.md`、§2.16 第五批 ✅  
> 内部追踪：`NEXT.md` §2.17（Phase 3 第六批）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2028-Q1 聚焦 |
| 2 | §3 成功判据 | 第六批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave6 manifest 绿 |

联动：`analysis/doc-public-roadmap-v1.md` §5（对外下季预览）、PLAN-005 §2。

---

## 2. 北极星目标（第六批）

1. **parser C3 gen1/gen2 三代一致性**：stage2-bstrict + dogfood 父波次（BOOT-025）。
2. **WPO 默认全局开启烟测**：`comp-wpo.tsv` global tier 五 hook（COMP-019）。
3. **std.db next_row 列值游标**：`query_begin` / `next_row` / `row_col_i32` 原型（STD-067）。
4. **治理闭环**：第六批路线图 manifest + gate 与 `NEXT.md` §2.17 同步（PLAN-006）。

---

## 3. 成功判据（2028-Q1 预览 · 第六批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-025 gen12 一致性；`gen12_ok=1` Linux |
| **编译器** | COMP-019 `comp-wpo.tsv` **global** tier ×5 |
| **std** | STD-067 `db_sqlite_next_row_smoke_c` 游标烟测 |
| **治理** | §2.17 四项均为 ✅；wave6 gate 绿 |

---

## 4. 第六批待办索引（§2.17）

| ID | 领域 | 待办 | 优先级 | Gate |
|----|------|------|--------|------|
| BOOT-025 | 自举 | parser C3 gen1/gen2 三代一致性 | P0 | `run-boot-025-parser-gen12-consistency-gate.sh` |
| COMP-019 | 编译器 | WPO 默认全局开启烟测 | P1 | `run-comp-wpo-global-gate.sh` |
| STD-067 | 标准库 | `std.db` next_row 列值迭代 | P2 | `run-std-db-next-row-gate.sh` |
| PLAN-006 | 治理 | Phase 3 第六批路线图定版 | P2 | `run-phase3-roadmap-wave6-gate.sh` |

完整状态列见 `NEXT.md` §2.17。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-wave6-gate.sh
```

```
shux: [SHUX_PLAN006_PHASE3_W6] status=ok tasks=4 sections=5 done=4
```

---

## 6. 非目标（v7 第七批定版）

- 文本列见 STD-068 `std-db-row-col-text-v1.md`
- 对外路线图 **2027-Q3** 季度刷新（DOC-013）
