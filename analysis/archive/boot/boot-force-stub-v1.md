# BOOT-010 force_stub 6 风险处置 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`COMP-001`、`analysis/boot-mega7-gap.md` §4、`ast_pool.c` `asm_parser_emit_heavy_force_stub`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **清单固定** | 6 项 force_stub 函数有根因、策略、回归用例 |
| **不可 silent 删除** | `ast_pool.c` 须保留 `PARSER_STUB_EQ`；删 glue 须 CI fail |
| **与 mega7 分工** | force_stub ≠ mega7；前者为 X emit 安全桩，后者为入口 ret0 |

验收（NEXT BOOT-010）：**每项有根因/策略/回归用例** + 矩阵 + manifest gate。

---

## 2. force_stub 6 项总表

| stub_id | 函数 | 根因 | 策略 | 回归 |
|---------|------|------|------|------|
| wrap_block | `wrap_block_ref_as_expr` | if 表达式块→EXPR 包装；X 真 emit code_len/SIG | C slice `parser_asm_if_expr_slice.inc` + force_stub | `run-if-expr.sh` |
| alloc_bool | `parser_alloc_true_bool_lit` | 深循环内 bool 字面量节点分配 | force_stub；调用路径走 glue/已 emit helper | `run-if-expr.sh` |
| alloc_float | `parser_alloc_float_lit` | 浮点 primary 路径 alloc | C slice `parser_asm_primary_slice.inc` + force_stub | `run-float.sh` |
| wrap_return | `parser_expr_wrap_in_return` | 单表达式函数体 RETURN 包装 | C seed slice + force_stub | `tests/parser/if_expr_return.x` |
| skip_padding | `try_skip_allow_padding_struct` | allow(padding) 深循环；X emit elf_ec=-1 | extern→`parser_try_skip_allow_padding_struct_glue` | `tests/struct/padding_allow.x` |
| skip_padding_buf | `try_skip_allow_padding_struct_buf` | buf 路径同上 | thin_c buf glue + force_stub | `tests/unsafe/allow_padding_ok.x` |

另：`onefunc_*` / `copy_onefunc_*` / `set_onefunc_*` 前缀桩为 **OneFuncResult** 池路径（非本 6 项；见 matrix `prefix_stub` 追踪行）。

---

## 3. 实现锚点

| 机制 | 位置 |
|------|------|
| force_stub 判定 | `compiler/ast_pool.c` → `asm_parser_emit_heavy_force_stub` |
| thin delegate | `k_asm_parser_thin_delegate`（padding → glue 名） |
| if-expr C 包装 | `compiler/seeds/parser_asm/parser_asm_if_expr_slice.inc` |
| float alloc C | `compiler/seeds/parser_asm/parser_asm_primary_slice.inc` |
| padding glue | `parser_asm_thin_c.c` → `parser_try_skip_allow_padding_struct_*_glue` |

**禁止**：批量将 force_stub 项迁入 safe_helper 白名单（已证 Segfault / elf_ec=-1）。

---

## 4. 门禁

`tests/run-boot-force-stub-gate.sh`：

1. manifest：RFC + matrix + `ast_pool.c`  
2. 6 符号在 `parser.x` + `PARSER_STUB_EQ` 在 `ast_pool.c`  
3. padding glue 符号在 thin delegate / thin_c  
4. 回归源文件存在；有 native shux 时 `check` 烟测  

---

## 5. 变更流程

1. 新增 force_stub → 增 matrix 行 + 根因/策略 + 回归 `.x`  
2. 尝试去 stub → 须 mega bisect / second-pass 绿 + 更新 matrix `strategy`  
3. 本地：`./tests/run-boot-force-stub-gate.sh`

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/boot-force-stub-matrix.tsv` |
| 门禁 | `tests/run-boot-force-stub-gate.sh` |
| mega7 关联 | `analysis/boot-mega7-gap.md` §4 |
| 符号完整性 | `tests/run-parser-thin-glue-symbol-integrity-gate.sh` |

**BOOT-010 状态：定版 ✅**
