# DOC-005 对外路线图（季度版）v1

> 更新时间：2026-06-18  
> 当季版本：**2027-Q4**  
> 状态：**定版（Q4 季度快照）**  
> 读者：贡献者、早期用户、关注 Shux 演进的社区  
> 内部追踪：`NEXT.md`（深度版，含 ID/验收/状态）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 章节 | 产出 |
|------|------|------|
| 1 | §2 愿景与北极星 | 理解项目定位 |
| 2 | §3 当季主题与里程碑 | 知道本季重点 |
| 3 | §4 已交付亮点 | 把握当前能力边界 |
| 4 | §5 下季预览 | 了解近期方向 |
| 5 | §8 自检 | 能向他人复述路线图 |

深度资料：`docs/README.md`（语言参考）、`analysis/doc-selfhost-architecture-v1.md`（自举全景）。

---

## 2. 愿景与北极星

Shux（`.sx`）面向**高性能系统编程**：在 C 的执行模型上，用更简单、默认安全的语法与工具链，达成可维护、可自举、跨平台一致的开发体验。

| 支柱 | 对外承诺（2026） |
|------|------------------|
| **性能** | IO/NET 核心场景对标 Zig；编译 dogfood 可度量回归 |
| **零拷贝** | 语义白皮书 + 指标看板；用户态冗余拷贝趋近 0 |
| **内存安全** | 默认安全子集 + 显式 `unsafe` + sanitize/审计门禁 |
| **自举** | Stage2 B-strict 与符号完整性门禁持续绿 |
| **生态** | LSP/格式化/示例/Cookbook；季度公开路线图更新 |

---

## 3. 当季主题与里程碑（2027-Q4）

**主题**：Phase 3 第五批收官 · parser C2 bootstrap emit · riscv64 QEMU · std.db query_rows

| 里程碑 | 状态 | 说明 |
|--------|------|------|
| M1 Phase 3 第五批待办 | ✅ | `NEXT.md` §2.16 全 4 项 ✅（PLAN-005～BOOT-024） |
| M2 parser C2 emit | ✅ | BOOT-024 `SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1` |
| M3 riscv64 QEMU | ✅ | COMP-018 `comp-riscv64-qemu.tsv` gate |
| M4 std.db query_rows | ✅ | STD-066 行迭代烟测 gate |
| M5 Phase 3 第四批（承前） | ✅ | §2.15 全 4 项 ✅ |
| M6 mega7 7/7（承前） | ✅ | BOOT-023 `promote_emit=7` Linux |
| M7 对外路线图季度 | ✅ | `quarter=2027-Q4` + manifest gate 绿 |

当季验收：**对外路线图 quarterly 可发布**（`quarter=2027-Q4`）+ manifest gate 绿。

---

## 4. 已交付亮点（2027-Q4 摘要）

以下为社区可见能力快照（承接 2027-Q3，详见各 RFC）：

| 领域 | 代表交付 | 深度文档 |
|------|----------|----------|
| 自举 parser C2 | BOOT-024 139 函数 bootstrap emit | `boot-024-parser-bootstrap-emit-v1.md` |
| 编译器 riscv64 | COMP-018 QEMU 用户态烟测 | `comp-riscv64-qemu-v1.md` |
| 标准库 db | STD-066 query_rows 行迭代原型 | `std-db-query-rows-v1.md` |
| 治理 | PLAN-005 第五批路线图定版 | `phase3-roadmap-wave5-v1.md` |
| mega7 7/7（承前） | BOOT-023 全量 emit | `boot-023-mega7-full-emit-v1.md` |
| 编译器 WPO（承前） | COMP-017 default tier | `comp-wpo-default-v1.md` |
| Cookbook | 36 条食谱（承前） | `doc-cookbook-expand-v1.md` |

**2027-Q3 回顾**：Phase 3 第四批收官、mega7 7/7、WPO default、std.db exec，见 `doc-public-roadmap-q3-v1.md`。

---

## 5. 下季预览（2028-Q1）

| 方向 | 计划 | 优先级 |
|------|------|--------|
| 自举 | parser C3 **gen1/gen2 三代一致性** | P0 |
| 编译器 | WPO **默认全局开启**烟测 | P1 |
| 标准库 | `std.db` **next_row** 列值迭代 | P2 |
| 文档 | Phase 3 第六批待办定版（`NEXT.md` §2.17） | P2 |
| 生态 | Cookbook 扩至 40+；VS Code Marketplace 发布预研 | P2 |

下季首周动作：将 §3 版本号 bump 为 `2028-Q1`，并重跑 `run-doc-public-roadmap-gate.sh`。

---

## 6. 季度更新流程（public quarterly）

权威清单：`tests/templates/doc-public-roadmap-quarter.txt`。

```
每季度第 1 周：
  1. 从 NEXT.md 汇总 ✅ / 🟡 / ⚪ 到 §4 / §5
  2. 更新文首「更新时间」与「当季版本」
  3. ./tests/run-doc-public-roadmap.sh → 确认 SHUX_DOC_ROADMAP 报告
  4. ./tests/run-doc-public-roadmap-gate.sh
  5. （可选）在 Release Notes / 社区公告引用本文 §3–§5
```

**v1 非目标**：逐条同步 NEXT 全表（对外仅摘要）；未验收项不作公开日期承诺。

---

## 7. 深度资料索引

| 资料 | 路径 |
|------|------|
| 语言参考 | `docs/README.md` |
| 自举架构 | `analysis/doc-selfhost-architecture-v1.md` |
| 性能对标 | `analysis/perf-zig-baseline-v1.md` |
| 零拷贝语义 | `analysis/zc-semantics-v1.md` |
| 内存安全实践 | `analysis/doc-memory-safety-error-v1.md` |
| 内部深度路线图 | `NEXT.md` |
| Q3 刷新记录 | `analysis/doc-public-roadmap-q3-v1.md` |
| Q4 2027 刷新记录 | `analysis/doc-public-roadmap-q4-2027-v1.md` |
| Q4 2026 刷新记录 | `analysis/doc-public-roadmap-q4-v1.md` |
| Q1 刷新记录 | `analysis/doc-public-roadmap-q1-v1.md` |
| Q2 刷新记录 | `analysis/doc-public-roadmap-q2-v1.md` |

---

## 8. 自检（5 题）

1. 当前公开季度版本号是？→ **2027-Q4**  
2. 性能对标基准语言？→ **Zig**（见 perf-zig-baseline）  
3. 零拷贝语义权威文档？→ **zc-semantics-v1.md**  
4. 季度更新 checklist 路径？→ **doc-public-roadmap-quarter.txt**  
5. 结构化报告前缀？→ **`SHUX_DOC_ROADMAP`**

---

## 9. 报告格式（runnable）

runner 通过 `doc_roadmap_emit_report` 输出：

```
shux: [SHUX_DOC_ROADMAP] status=ok quarter=2027-Q4 sections=8 cross_refs=5
```

| 字段 | 含义 |
|------|------|
| `status` | `ok` / `fail` |
| `quarter` | 当季版本（与 manifest `quarter_anchor` 一致） |
| `sections` | manifest 校验通过章节数 |
| `cross_refs` | 交叉引用文件数 |

门禁：`tests/run-doc-public-roadmap-gate.sh`；runner：`tests/run-doc-public-roadmap.sh`；库：`tests/lib/doc-public-roadmap.sh`；便携回归：`tests/run-portable-suite.sh`。
