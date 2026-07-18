# PLAN-001：Phase 3 路线图 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：Phase 2 全表 ✅（`NEXT.md` §2.1～§2.11）、DOC-009 Q3 路线图  
> 内部追踪：`NEXT.md` §2.12（Phase 3 待办总表）

---

## 1. 阅读路径

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 北极星 | 理解 Phase 3 聚焦 |
| 2 | §3 成功判据 | 知道 2026H2 验收维度 |
| 3 | §4 首批待办 | 认领 P0 项 |
| 4 | §5 Gate | 验证路线图 manifest 绿 |

深度联动：`analysis/doc-public-roadmap-v1.md` §5（2026-Q4 预览）、`analysis/boot-018-parser-std-decouple-v1.md`。

---

## 2. 北极星目标（Phase 3）

1. **泛型类型族收官**：`Option<T>` / `Result<T,E>` 从多类型族过渡到完整泛型 struct，与 typeck/codegen ABI 一致。
2. **自举前沿替换**：mega7 parser thin glue 分片验收；Stage2 扩面 dogfood 覆盖 parser/typeck 子集。
3. **编译器质量波次**：regalloc / isel 回归矩阵扩展，WPO 小规模持续启用。
4. **std 桩函数清零**：simd shuffle/select、regex 纯引擎路径达到生产可用 bench。
5. **生态发布**：VS Code 扩展稳定版；Cookbook 与对外路线图季度同步。

### 战略约束（继承 Phase 1～2）

- 用户只写一套 API；平台差异在 std 内部。
- 新增 `unsafe` / `extern` 须走 SAFE-003 审计。
- P0 项未验收不得标 ✅；bench 须可复现。

---

## 3. 成功判据（2026H2 · Phase 3）

| 维度 | 目标 |
|------|------|
| **泛型** | `Option<T>` / `Result<T,E>` 至少 3 种 `T` 金样 typeck + codegen |
| **自举** | BOOT-020 mega7 里程碑 gate 绿；BOOT-019 Stage2 扩面 smoke |
| **编译器** | COMP-013/014 回归矩阵无 P0 回退 |
| **std 深化** | STD-061/062 bench 可复现且优于桩基线 |
| **生态** | TOOL-009 vsix 发布 + grammar gate |
| **治理** | Phase 3 表项均有 RFC 或 README 锚点 |

---

## 4. 首批待办索引（§2.12）

| ID | 领域 | 待办 | 优先级 |
|----|------|------|--------|
| LANG-009 | 语言 | `Option<T>` 泛型 struct 完整形态 | P0 |
| LANG-010 | 语言 | `Result<T,E>` 泛型 struct 完整形态 | P0 |
| CORE-016 | core | 泛型 Option/Result 与 core 模块统一 | P0 |
| BOOT-019 | 自举 | Stage2 扩面 dogfood smoke | P0 |
| BOOT-020 | 自举 | mega7 parser 替换里程碑验收 | P0 |
| COMP-013 | 编译器 | regalloc 质量波次 gate 扩展 | P1 |
| COMP-014 | 编译器 | isel 回归矩阵扩展 | P1 |
| STD-061 | 标准库 | simd shuffle/select 生产级深化 | P2 |
| STD-062 | 标准库 | regex 纯引擎性能优化 | P2 |
| TOOL-009 | 工具 | VS Code 扩展 0.2 稳定发布 | P1 |
| PLAN-001 | 治理 | Phase 3 路线图定版 | P0 |

完整状态列见 `NEXT.md` §2.12。

---

## 5. Gate

```bash
./tests/run-phase3-roadmap-gate.sh
```

```
shux: [SHUX_PLAN001_PHASE3] status=ok tasks=11 sections=5
```

---

## 6. 非目标（v1）

- 完整 GC / 异步运行时重写  
- 全平台 TLS 生产链入（STD-030 仍为预研）  
- Phase 3 全部任务一次性标 ✅（按周迭代）
