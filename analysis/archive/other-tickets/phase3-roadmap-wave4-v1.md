# PLAN-004：Phase 3 第四批路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：PLAN-003 `phase3-roadmap-wave3-v1.md`、§2.14 第三批 ✅  
> 内部追踪：`NEXT.md` §2.15（Phase 3 第四批）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2027-Q3 聚焦 |
| 2 | §3 成功判据 | 第四批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave4 manifest 绿 |

联动：`analysis/doc-public-roadmap-v1.md` §5（2027-Q3 预览）、PLAN-003 §2。

---

## 2. 北极星目标（第四批）

1. **mega7 全量 emit**：B1–B7 全部 `promote_emit=7`（BOOT-023）。
2. **WPO default tier**：持续扩面 5 hook 登记（COMP-017）。
3. **std.db 事务 exec**：begin/commit/rollback 烟测（STD-065）。
4. **治理闭环**：第四批路线图 manifest + gate 与 `NEXT.md` §2.15 同步（PLAN-004）。

---

## 3. 成功判据（2027-Q3 预览 · 第四批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-023 7/7 emit_target；Linux `promote_emit=7` |
| **编译器** | COMP-017 `comp-wpo.tsv` **5** 条 `tier=default` |
| **std** | STD-065 `db_sqlite_tx_exec_smoke_c` + tx 向量烟测 |
| **治理** | §2.15 四项均为 ✅；wave4 gate 绿 |

---

## 4. 第四批待办索引（§2.15）

| ID | 领域 | 待办 | 优先级 | Gate |
|----|------|------|--------|------|
| BOOT-023 | 自举 | mega7 7/7 全量 emit | P0 | `run-boot-023-mega7-full-emit-gate.sh` |
| COMP-017 | 编译器 | WPO 持续扩面 gate | P1 | `run-comp-wpo-default-gate.sh` |
| STD-065 | 标准库 | `std.db` SQLite 原型深化 | P2 | `run-std-db-exec-deep-gate.sh` |
| PLAN-004 | 治理 | Phase 3 第四批路线图定版 | P2 | `run-phase3-roadmap-wave4-gate.sh` |

完整状态列见 `NEXT.md` §2.15。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-wave4-gate.sh
```

```
shux: [SHUX_PLAN004_PHASE3_W4] status=ok tasks=4 sections=5 done=4
```

---

## 6. 非目标（v5 第五批草稿）

- parser 139 函数 C2 全量 bootstrap emit
- QEMU riscv 用户态仿真 CI
- `std.db` `query_rows` 行迭代
