# PLAN-003：Phase 3 第三批路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：PLAN-002 `phase3-roadmap-wave2-v1.md`、§2.13 第二批 ✅  
> 内部追踪：`NEXT.md` §2.14（Phase 3 第三批）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2027-Q2 聚焦 |
| 2 | §3 成功判据 | 第三批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave3 manifest 绿 |

联动：`analysis/doc-public-roadmap-v1.md` §5（2027-Q2 预览）、PLAN-002 §2。

---

## 2. 北极星目标（第三批）

1. **mega7 emit 晋升**：B1–B7 bisect 真 emit 门禁（BOOT-022）。
2. **riscv64 矩阵扩展**：wave 回归 3 项 asm_text（COMP-016）。
3. **工具链 ELF phdr**：program header 只读 API（STD-064）。
4. **治理闭环**：第三批路线图 manifest + gate 与 `NEXT.md` §2.14 同步（PLAN-003）。

---

## 3. 成功判据（2027-Q2 预览 · 第三批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-022 emit wave 基础设施；`promote_emit≥1` Linux |
| **编译器** | COMP-016 `comp-riscv64-matrix.tsv` **9** case |
| **std** | STD-064 `read_phdr` + `elf64_min_phdr.bin` 烟测 |
| **治理** | §2.14 四项均为 ✅；wave3 gate 绿 |

---

## 4. 第三批待办索引（§2.14）

| ID | 领域 | 待办 | 优先级 | Gate |
|----|------|------|--------|------|
| BOOT-022 | 自举 | mega7 B1–B7 emit 晋升 | P0 | `run-boot-022-mega7-emit-gate.sh` |
| COMP-016 | 编译器 | riscv64 后端矩阵扩展 | P1 | `run-comp-riscv64-wave-gate.sh` |
| STD-064 | 标准库 | `std.elf` program header 只读 | P2 | `run-std-elf-phdr-gate.sh` |
| PLAN-003 | 治理 | Phase 3 第三批路线图定版 | P2 | `run-phase3-roadmap-wave3-gate.sh` |

完整状态列见 `NEXT.md` §2.14。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-wave3-gate.sh
```

```
shux: [SHUX_PLAN003_PHASE3_W3] status=ok tasks=4 sections=5 done=4
```

---

## 6. 非目标（v4 第四批草稿）

- mega7 7/7 全量 emit（C3）
- QEMU riscv 仿真 CI
- ELF 动态段解析
