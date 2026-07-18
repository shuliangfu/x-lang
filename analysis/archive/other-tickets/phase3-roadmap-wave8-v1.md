# PLAN-008：Phase 3 第八批路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：PLAN-007 `phase3-roadmap-wave7-v1.md`、§2.18 第七批 ✅  
> 内部追踪：`NEXT.md` §2.19（Phase 3 第八批）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2028-Q3 聚焦 |
| 2 | §3 成功判据 | 第八批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave8 manifest 绿 |

联动：`analysis/doc-public-roadmap-v1.md` §5（2027-Q4 预览承前）、PLAN-007 §2。

---

## 2. 北极星目标（第八批）

1. **parser C5 跨平台 shux_asm2**：Darwin/Linux native 二进制烟测（BOOT-027）。
2. **incr-compile 生产 tier**：`comp-incr-compile.tsv` 生产级 hook 扩面（COMP-021）。
3. **std.db BLOB 列读取**：`row_col_blob` 列值原型（STD-069）。
4. **治理闭环**：第八批路线图 manifest + gate 与 `NEXT.md` §2.19 同步（PLAN-008）。

---

## 3. 成功判据（2028-Q3 预览 · 第八批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-027 C5 shux_asm2 跨平台烟测；Linux `c5_ok=1` |
| **编译器** | COMP-021 `comp-incr-compile` 生产 tier gate 绿 |
| **std** | STD-069 `db_sqlite_row_col_blob_smoke_c` BLOB 列烟测 |
| **治理** | §2.19 四项均为 ✅；wave8 gate 绿 |

---

## 4. 第八批待办索引（§2.19）

| ID | 领域 | 待办 | 优先级 | Gate |
|----|------|------|--------|------|
| BOOT-027 | 自举 | parser C5 shux_asm2 跨平台发布 | P0 | `run-boot-027-shux-asm2-cross-gate.sh` |
| COMP-021 | 编译器 | incr-compile 生产 tier 烟测 | P1 | `run-comp-incr-compile-prod-gate.sh` |
| STD-069 | 标准库 | `std.db` row_col_blob BLOB 列 | P2 | `run-std-db-row-col-blob-gate.sh` |
| PLAN-008 | 治理 | Phase 3 第八批路线图定版 | P2 | `run-phase3-roadmap-wave8-gate.sh` |

完整状态列见 `NEXT.md` §2.19。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-wave8-gate.sh
```

```
shux: [SHUX_PLAN008_PHASE3_W8] status=ok tasks=4 sections=5 done=4
```

---

## 6. 非目标（v9 第九批草稿）

- 第九批任务见 `phase3-roadmap-wave9-v1.md`（PLAN-009）
