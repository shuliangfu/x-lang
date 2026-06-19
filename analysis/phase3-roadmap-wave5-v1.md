# PLAN-005：Phase 3 第五批路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：PLAN-004 `phase3-roadmap-wave4-v1.md`、§2.15 第四批 ✅  
> 内部追踪：`NEXT.md` §2.16（Phase 3 第五批）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2027-Q4 聚焦 |
| 2 | §3 成功判据 | 第五批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave5 manifest 绿 |

联动：`analysis/doc-public-roadmap-v1.md` §5（2027-Q4 预览）、PLAN-004 §2。

---

## 2. 北极星目标（第五批）

1. **parser C2 bootstrap emit**：`SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1` bisect 基础设施（BOOT-024）。
2. **riscv64 QEMU 用户态**：2 case `qemu-riscv64` 烟测（COMP-018）。
3. **std.db query_rows**：SELECT 行数迭代原型（STD-066）。
4. **治理闭环**：第五批路线图 manifest + gate 与 `NEXT.md` §2.16 同步（PLAN-005）。

---

## 3. 成功判据（2027-Q4 预览 · 第五批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-024 bootstrap bisect；`bootstrap_minimal_ok=1` Linux |
| **编译器** | COMP-018 `comp-riscv64-qemu.tsv` **2** case |
| **std** | STD-066 `db_query_rows_c` 行计数烟测 |
| **治理** | §2.16 四项均为 ✅；wave5 gate 绿 |

---

## 4. 第五批待办索引（§2.16）

| ID | 领域 | 待办 | 优先级 | Gate |
|----|------|------|--------|------|
| BOOT-024 | 自举 | parser C2 139 函数全量 emit | P0 | `run-boot-024-parser-bootstrap-emit-gate.sh` |
| COMP-018 | 编译器 | riscv64 QEMU 用户态烟测 | P1 | `run-comp-riscv64-qemu-gate.sh` |
| STD-066 | 标准库 | `std.db` query_rows 原型 | P2 | `run-std-db-query-rows-gate.sh` |
| PLAN-005 | 治理 | Phase 3 第五批路线图定版 | P2 | `run-phase3-roadmap-wave5-gate.sh` |

完整状态列见 `NEXT.md` §2.16。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-wave5-gate.sh
```

```
shux: [SHUX_PLAN005_PHASE3_W5] status=ok tasks=4 sections=5 done=4
```

---

## 6. 非目标（v6 第六批草稿）

- parser C3 gen1/gen2 三代一致性
- WPO 默认对所有 `shux` 构建全局开启
- `std.db` 列值游标 `next_row`
