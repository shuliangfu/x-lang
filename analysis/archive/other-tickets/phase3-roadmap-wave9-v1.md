# PLAN-009：Phase 3 第九批路线图 v1

> 更新时间：2026-06-18  
> 状态：**草稿（v1）**  
> 前置：PLAN-008 `phase3-roadmap-wave8-v1.md`、§2.19 第八批 ✅  
> 内部追踪：`NEXT.md` §2.20（Phase 3 第九批 · 2028-Q4 预览）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2028-Q4 聚焦 |
| 2 | §3 成功判据 | 第九批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave9 manifest 绿（草稿 `min_done=0`） |

联动：`analysis/doc-public-roadmap-v1.md` §5（2028-Q1 预览承前）、PLAN-008 §2。

---

## 2. 北极星目标（第九批）

1. **parser C6 shux_asm2 CI 矩阵**：Linux/Darwin 双平台 native 二进制 + manifest 烟测（BOOT-028）。
2. **incr-compile bench tier 扩面**：`comp-incr-compile.tsv` bench 级 hook 与 timing 报告（COMP-022）。
3. **std.db 预编译语句缓存**：`stmt_cache` 原型与重复查询烟测（STD-070）。
4. **治理闭环**：第九批路线图 manifest + gate 与 `NEXT.md` §2.20 同步（PLAN-009）。

---

## 3. 成功判据（2028-Q4 预览 · 第九批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-028 C6 CI 矩阵；`c6_matrix_ok=1` 双平台 |
| **编译器** | COMP-022 incr-compile bench tier gate 绿 |
| **std** | STD-070 `db_stmt_cache_smoke_c` 预编译缓存烟测 |
| **治理** | §2.20 四项均为 ✅；wave9 gate 绿（`min_done=4` 定版后） |

---

## 4. 第九批待办索引（§2.20）

| ID | 领域 | 待办 | 优先级 | Gate（计划） |
|----|------|------|--------|--------------|
| BOOT-028 | 自举 | parser C6 shux_asm2 CI 矩阵 | P0 | `run-boot-028-shux-asm2-ci-matrix-gate.sh` |
| COMP-022 | 编译器 | incr-compile bench tier 扩面 | P1 | `run-comp-incr-compile-bench-gate.sh` |
| STD-070 | 标准库 | `std.db` 预编译语句缓存 | P2 | `run-std-db-stmt-cache-gate.sh` |
| PLAN-009 | 治理 | Phase 3 第九批路线图定版 | P2 | `run-phase3-roadmap-wave9-gate.sh` |

完整状态列见 `NEXT.md` §2.20。

---

## 5. Gate（草稿）

```bash
./tests/run-phase3-roadmap-wave9-gate.sh
```

草稿期望（`min_done=0`）：

```
shux: [SHUX_PLAN009_PHASE3_W9] status=ok tasks=4 sections=5 done=0 draft=1
```

定版后：`done=4`，报告行去掉 `draft`。

---

## 6. 非目标（v10 第十批草稿）

- 对外路线图 **2028-Q1** 季度刷新（DOC-015）
- parser C7 全量自举链接矩阵
- `std.db` 连接池与并发读
