# Parser mega 7 路径能力差距拆解（BOOT-009）

> 更新时间：2026-06-17  
> 目的：为 `mega 7` 从 C glue / ret0 桩迁移到 SX 真 emit 提供分阶段路线图。

---

## 1. mega 7 项清单（当前状态）

| 序号 | 函数 | 当前策略 | bisect delta | 阻塞级别 |
|---|---|---|---|---|
| 1 | `parse_into_buf` | C glue + ret0 桩 | 0（不可迁） | P0 |
| 2 | `parse_into` | C glue + ret0 桩 | 0 | P0 |
| 3 | `parse` | C glue + ret0 桩 | 0 | P0 |
| 4 | `parse_one_function_impl` | C glue + ret0 桩 | 0 | P0 |
| 5 | `parse_expr_into` | C glue + ret0 桩 | 0 | P0 |
| 6 | `parse_block_into` | C glue + ret0 桩 | 0 | P0 |
| 7 | `parse_body_lets_into` | C glue + ret0 桩 | 0 | P0 |

基准来源：`tests/baseline/parser-mega-bisect.tsv`（7/7 delta=0）。

---

## 2. 根因分类

| 类别 | 表现 | 影响函数 |
|---|---|---|
| 深循环 + 大栈帧 | SX emit code_len 爆炸或 Segfault | parse_into* / parse / parse_one_function_impl |
| 按值返回复杂结构 | emit 失败，需 C 包装 | lex_from_* / library parse 邻域 |
| buf 路径递归 | lexer_next_buf 深递归 | *_buf 系列 |
| force_stub 邻域 | elf_ec=-1 或崩溃 | try_skip_allow_padding_struct* |
| slot fallback 上限 | >8 slots Segfault | 批量 safe_helper 迁移 |

---

## 3. 分阶段迁移路线

### 阶段 A：能力补齐（编译器，不迁 mega）

| 步骤 | 内容 | 验收 |
|---|---|---|
| A1 | 符号完整性门禁替代体积 ratchet | `run-parser-thin-glue-symbol-integrity-gate.sh` ✅ |
| A2 | 大函数体分段 emit（basic block 切片） | 单函数 emit 不再 Segfault |
| A3 | 复杂返回值 lowering（LibraryParseResult 等） | 3 个按值返回包装可 SX emit |
| A4 | buf 路径尾调用优化 | 深递归深度可配置上限 |

### 阶段 B：mega 子路径拆分（whitelist 渐进）

| 步骤 | 目标函数 | 策略 |
|---|---|---|
| B1 | `parse_body_lets_into` | 最小循环体，先迁 |
| B2 | `parse_block_into` | 依赖 B1 |
| B3 | `parse_expr_into` | 依赖 primary/unary 链稳定 |
| B4 | `parse_one_function_impl` | 依赖 library/extern skip 链 |
| B5 | `parse_into` / `parse_into_buf` | 最后迁，依赖 import/toplevel 链 |
| B6 | `parse` | 顶层入口，最后统一 |

### 阶段 C：SX bootstrap 全量

| 步骤 | 内容 | 验收 |
|---|---|---|
| C1 | MINIMAL 白名单保持绿色 | init + set_main_index |
| C2 | 139 函数全量 emit | `SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1` 无 ret0 |
| C3 | gen1 SX 编 gen2 parser 大体 | Stage2 三代一致性 |

---

## 4. force_stub 6 项（关联）

| 函数 | 策略 | 备注 |
|---|---|---|
| `wrap_block_ref_as_expr` | 保持 C glue | SX safe 失败 |
| `parser_alloc_true_bool_lit` | 保持 C glue | |
| `parser_alloc_float_lit` | 保持 C glue | |
| `parser_expr_wrap_in_return` | 保持 C glue | |
| `try_skip_allow_padding_struct` | 保持 C glue | force_stub |
| `try_skip_allow_padding_struct_buf` | 保持 C glue | force_stub |

---

## 5. 近期执行顺序（与 NEXT.md 对齐）

1. BOOT-008：符号完整性门禁（已完成）
2. BOOT-009：本文档 + 阶段 A 能力项立项
3. COMP-001：parser 深循环改造计划（对接阶段 A2/A3）
4. 暂停 tier stretch 体积推进

---

## 6. 风险与约束

- 禁止批量 safe_helper 迁移（已证失败）。
- slot fallback 上限 16（>8 易 Segfault）。
- mega 迁移必须逐项 bisect，不可 batch。
- 生产链路在 mega 未迁完前继续依赖 C glue + 符号完整性门禁。

---

## 7. 与 std 迭代解耦（BOOT-018）

| 原则 | 说明 |
|------|------|
| **双轨** | std/core 迭代（BOOT-013 check 矩阵、STD-* gate）与 mega7 迁移（COMP-001）分轨 |
| **STD P0** | 新 std 模块合并**不要求** B1–B7 从 stub 晋升 |
| **生产** | mega7 保持 C glue + symbol-integrity 直至逐项 bisect promote |
| **CI** | `run-comp-parser-mega7-gate.sh` 在 portable 轨可 `SKIP hooks`；非 ENG-002 `ci_hard` |

详见 `analysis/boot-018-parser-std-decouple-v1.md`。
