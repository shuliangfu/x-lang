# PLAN-002：Phase 3 第二批路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：PLAN-001 `phase3-roadmap-v1.md`、§2.12 首批 ✅  
> 内部追踪：`NEXT.md` §2.13（Phase 3 第二批）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 2027-Q1 聚焦 |
| 2 | §3 成功判据 | 第二批验收维度 |
| 3 | §4 待办索引 | 认领 P0/P1 项 |
| 4 | §5 Gate | 验证 wave2 manifest 绿 |

联动：`analysis/doc-public-roadmap-v1.md` §5（2026-Q4 预览）、PLAN-001 §2。

---

## 2. 北极星目标（第二批）

1. **mega7 实替换波次**：B1–B7 bisect runnable 晋升基础设施（BOOT-021）。
2. **WPO 生产持续启用**：`comp-wpo.tsv` prod tier 五 hook 登记（COMP-015）。
3. **工具链只读 ELF**：`std.elf` 节名查找与节体字节访问（STD-063）。
4. **治理闭环**：第二批路线图 manifest + gate 与 `NEXT.md` §2.13 同步（PLAN-002）。

### 战略约束（继承 Phase 3）

- P0 项须 gate 绿方可标 ✅。
- Linux-only runnable（shux_asm / build_asm）在 Darwin manifest 绿 + SKIP。
- 对外路线图季度条目由 DOC-010 维护，本 RFC 仅内部 wave2 定版。

---

## 3. 成功判据（2027-Q1 预览 · 第二批）

| 维度 | 目标 |
|------|------|
| **自举** | BOOT-021 promote wave 7 项 runnable；矩阵 B1–B7 非 stub |
| **编译器** | COMP-015 prod_ok=5；父 COMP-004 manifest 绿 |
| **std** | STD-063 deep_c=1；`find_section_idx` / `read_sec_byte` API |
| **治理** | §2.13 四项均为 ✅；wave2 gate 绿 |

---

## 4. 第二批待办索引（§2.13）

| ID | 领域 | 待办 | 优先级 | Gate |
|----|------|------|--------|------|
| BOOT-021 | 自举 | mega7 parser 实替换（非 stub） | P0 | `run-boot-021-mega7-promote-gate.sh` |
| COMP-015 | 编译器 | WPO 小规模持续启用 | P1 | `run-comp-wpo-prod-gate.sh` |
| STD-063 | 标准库 | `std.elf` 只读解析深化 | P2 | `run-std-elf-deep-gate.sh` |
| PLAN-002 | 治理 | Phase 3 第二批路线图定版 | P2 | `run-phase3-roadmap-wave2-gate.sh` |

完整状态列见 `NEXT.md` §2.13。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-wave2-gate.sh
```

```
shux: [SHUX_PLAN002_PHASE3_W2] status=ok tasks=4 sections=5 done=4
```

- **tasks**：manifest 登记 task 数（**4**）
- **done**：§2.13 表中已标 ✅ 的 task 数
- **sections**：RFC 章节锚点命中数

---

## 6. 非目标（v3 第三批草稿）

- mega7 全量 emit（7/7 `delta≥8192`）
- WPO 默认全局开启（非 opt-in）
- ELF program header / 重定位解析
