# BOOT-021：mega7 parser 实替换（B1–B7 晋升波次）v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-020 里程碑、`parser-mega-bisect.tsv`、`comp-parser-mega7-matrix.tsv`  
> 关联：`boot-mega7-gap.md` 阶段 B、COMP-001

---

## 1. 目标

将 mega7 **B1–B7** 从 BOOT-020 的 `stub` 推进到 **runnable 晋升波次**：逐项 `SHUX_ASM_PARSER_MEGA_BISECT=<fn>` 探测 SU emit（`delta ≥ 8192` 为 `emit`）。

验收：`tests/run-boot-021-mega7-promote-gate.sh` 绿；`parser-mega7-promote-wave.tsv` **7** 条 `promote_*` runnable。

---

## 2. 晋升矩阵（B1→B7）

| ID | 函数 | 顺序 | bisect 锚点 |
|----|------|------|-------------|
| `promote_b1` | `parse_body_lets_into` | B1 | 最小循环体 |
| `promote_b2` | `parse_block_into` | B2 | 依赖 B1 |
| `promote_b3` | `parse_expr_into` | B3 | primary/unary |
| `promote_b4` | `parse_one_function_impl` | B4 | library skip |
| `promote_b5` | `parse_into` | B5 | import/toplevel |
| `promote_b6` | `parse_into_buf` | B6 | buf 路径 |
| `promote_b7` | `parse` | B7 | 顶层入口 |

`min_delta_pass=8192`（与 `parser-mega-bisect.tsv` 一致）。

---

## 3. Runnable 波次

```bash
./tests/run-parser-mega7-promote-wave.sh
```

逐函数编译 `parser.sx` 并记录 `ec/text/delta/status`；Linux + `shux_asm` 时更新 `parser-mega-bisect.tsv` 漂移检测。

---

## 4. Gate

```bash
./tests/run-boot-021-mega7-promote-gate.sh
```

```
shux: [SHUX_BOOT021] status=ok runnable_ok=7 promote_emit=0 skip=1
```

- **runnable_ok=7**：7 项 bisect 均已执行（或 manifest 绿 + Darwin SKIP）
- **promote_emit**：`status=emit` 计数（v1 可为 0；Linux CI 晋升后递增）
- Darwin / 无 `shux_asm`：manifest 绿 + wave **SKIP**

---

## 5. 联动

- manifest：`tests/baseline/boot-021-mega7-promote.tsv`
- 波次表：`tests/baseline/parser-mega7-promote-wave.tsv`
- 父里程碑：`run-boot-020-mega7-milestone-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（B1–B7 状态 `runnable`）

---

## 6. 非目标（v2）

- 7/7 全量 `emit`（阶段 C3）
- Darwin nm / objdump 硬门禁
- 批量 safe_helper 迁移
