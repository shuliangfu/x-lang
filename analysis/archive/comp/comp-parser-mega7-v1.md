# COMP-001 Parser mega 7 深循环改造 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`BOOT-009`（`analysis/boot-mega7-gap.md`）、`ENG-002`、`parser_asm_*_slice.c`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **阶段性方案** | mega 7 从 ret0/C glue → X 真 emit 的 A/B/C 三阶段可执行计划 |
| **能力先行** | 阶段 A 补齐 emit 能力（切片、符号完整性）再迁 mega |
| **逐项 bisect** | 每项 mega 独立 `SHUX_ASM_PARSER_MEGA_BISECT`，禁止 batch |
| **质量门禁** | 符号完整性 + second-pass + mega bisect 基线联动 |

验收（NEXT COMP-001）：**mega 7 有阶段性替换方案** + 矩阵 + manifest gate。

---

## 2. 三阶段总览

```
阶段 A（能力）  →  阶段 B（mega 7 逐项）  →  阶段 C（bootstrap 全量）
     │                    │                         │
  切片/符号/返回值        B1→B7 迁移顺序           139 func 无 ret0
```

详见 `analysis/boot-mega7-gap.md` §3；本 RFC 固化 **矩阵 + 门禁 hook**。

---

## 3. 阶段 A：能力补齐（不迁 mega）

| ID | 内容 | 状态 | 门禁 |
|----|------|------|------|
| A1 | 符号完整性替代体积 ratchet | ✅ done | `run-parser-thin-glue-symbol-integrity-gate.sh` |
| A2 | basic block / 函数体切片 emit | 🟡 in_progress | 20× `parser_asm_*_slice.c` + second-pass |
| A3 | 复杂返回值 lowering | ⚪ planned | LibraryParseResult 等 |
| A4 | buf 路径尾调用 / 递归上限 | ⚪ planned | `*_buf` 系列 |

---

## 4. 阶段 B：mega 7 迁移顺序

| 序 | 函数 | 状态 | bisect |
|----|------|------|--------|
| B1 | `parse_body_lets_into` | stub | delta=0 |
| B2 | `parse_block_into` | stub | delta=0 |
| B3 | `parse_expr_into` | stub | delta=0 |
| B4 | `parse_one_function_impl` | stub | delta=0 |
| B5 | `parse_into` | stub | delta=0 |
| B6 | `parse_into_buf` | stub | delta=0 |
| B7 | `parse` | stub | delta=0 |

基线：`tests/baseline/parser-mega-bisect.tsv`（7/7 stub）。  
探测：`run-parser-mega-bisect-sweep-gate.sh`（track-only；delta≥8KiB 才提示 promote）。

---

## 5. 阶段 C：bootstrap 全量

| ID | 内容 | 门禁 |
|----|------|------|
| C1 | C seed `parse_into_buf` TU | `run-parser-parse-bootstrap-gate.sh` |
| C2 | experimental 链 link smoke | `run-parser-parse-bootstrap-link-smoke.sh` |
| C3 | 139 func X emit（无 ret0） | `SHUX_ASM_PARSER_PARSE_BOOTSTRAP_EMIT=1`（后续） |

---

## 6. 已落地切片（A2 进展）

| 切片 TU | 覆盖域 |
|---------|--------|
| `parser_asm_expr_binop_slice.c` | expr binop |
| `parser_asm_primary_slice.c` | primary |
| `parser_asm_body_let_slice.c` | body let |
| `parser_asm_block_from_res_slice.c` | block |
| `parser_asm_one_function_buf_slice.c` | one function buf |
| `parser_asm_seed_parse_into_buf_slice.c` | seed parse_into_buf |
| … | 共 **20** 个 `parser_asm_*_slice.c` |

---

## 7. 门禁

`tests/run-comp-parser-mega7-gate.sh`：

1. manifest：RFC + matrix + `boot-mega7-gap.md` + `parser-mega-bisect.tsv`  
2. mega 7 函数须在 `parser.x` 存在  
3. matrix：`phase A` ≥2 行、`mega7` 7 行、`capability` done ≥ `min_slice_done`  
4. hook：symbol-integrity（Linux）；mega bisect sweep baseline 行数=7  

---

## 8. 约束（不可违反）

- 禁止批量 safe_helper 迁移  
- slot fallback ≤16（>8 易 Segfault）  
- mega 须逐项 bisect，不可 batch  
- 生产链路在 mega 未迁完前：**C glue + 符号完整性**（ENG-002）

---

## 9. 索引

| 资源 | 路径 |
|------|------|
| 差距拆解 | `analysis/boot-mega7-gap.md` |
| 矩阵 | `tests/baseline/comp-parser-mega7-matrix.tsv` |
| 门禁 | `tests/run-comp-parser-mega7-gate.sh` |
| mega bisect | `tests/baseline/parser-mega-bisect.tsv` |
| 符号完整性 | `tests/baseline/parser-thin-glue-symbols.tsv` |

**COMP-001 状态：定版 ✅**

---

## 10. 与 std 迭代解耦（BOOT-018）

- mega7 阶段 B 保持 **stub** 不阻塞 STD P0 合并  
- 门禁：`tests/run-boot-018-parser-std-decouple-gate.sh`  
- RFC：`analysis/boot-018-parser-std-decouple-v1.md`
