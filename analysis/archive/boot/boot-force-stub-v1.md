# BOOT-010 force_stub 6 风险处置 v1

> 更新时间：2026-06-17 · **honesty 2026-08-24 / 2026-08-26**  
> 状态：**硬绿 ✅（soft→硬绿）** — live `PARSER_STUB_EQ` = `compiler/seeds/runtime_pipeline_abi.from_x.c`（`ast_pool.c` left wave309）  
> 关联：`COMP-001`、`analysis/archive/boot/boot-mega7-gap.md` §4、abi seed `asm_parser_emit_heavy_force_stub`  
> **honesty 2026-08-24**：archived; gate default = `analysis/archive/.../`; live roadmap = `analysis/自举进度.md`.  
> **honesty 2026-08-26**：gate prefer asm + `XLANG_LINK_XLANG`; matrix `reg_src` link+run hard; `check_only` observational; no soft SKIP→OK; DOC `## 7. Gate`.

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **清单固定** | 6 项 force_stub 函数有根因、策略、回归用例 |
| **不可 silent 删除** | `runtime_pipeline_abi.from_x.c` 须保留 `PARSER_STUB_EQ`；删 stub 表须 CI fail（historical `ast_pool.c` left wave309） |
| **与 mega7 分工** | force_stub ≠ mega7；前者为 X emit 安全桩，后者为入口 ret0 |

验收：`tests/run-boot-force-stub-gate.sh` 绿；每项有根因/策略/回归 `.x` + 矩阵 + honesty gate。

---

## 2. force_stub 6 项总表

| stub_id | 函数 | 根因 | 策略 | 回归 |
|---------|------|------|------|------|
| wrap_block | `wrap_block_ref_as_expr` | if 表达式块→EXPR 包装；X 真 emit code_len/SIG | C slice `parser_asm_if_expr_slice.inc` + force_stub | `tests/if-expr/simple.x` link+run exit 10 |
| alloc_bool | `parser_alloc_true_bool_lit` | 深循环内 bool 字面量节点分配 | force_stub；调用路径走 glue/已 emit helper | `tests/if-expr/no_else.x` link+run exit 42 |
| alloc_float | `parser_alloc_float_lit` | 浮点 primary 路径 alloc | C slice `parser_asm_primary_slice.inc` + force_stub | `tests/float/f32_f64.x` link+run exit 0 |
| wrap_return | `parser_expr_wrap_in_return` | 单表达式函数体 RETURN 包装 | C seed slice + force_stub | `tests/parser/if_expr_return.x` check_only（观测） |
| skip_padding | `try_skip_allow_padding_struct` | allow(padding) 深循环；X emit elf_ec=-1 | extern→`parser_try_skip_allow_padding_struct_glue` | `tests/struct/padding_allow.x` check_only（观测） |
| skip_padding_buf | `try_skip_allow_padding_struct_buf` | buf 路径同上 | thin_c buf glue + force_stub | `tests/unsafe/allow_padding_ok.x` link+run exit 2 |

另：`onefunc_*` / `copy_onefunc_*` / `set_onefunc_*` 前缀桩为 **OneFuncResult** 池路径（非本 6 项；见 matrix `prefix_stub` 追踪行）。

---

## 3. 实现锚点

| 机制 | 位置 |
|------|------|
| force_stub 判定 | `compiler/seeds/runtime_pipeline_abi.from_x.c` → `asm_parser_emit_heavy_force_stub`（`ast_pool.c` left wave309） |
| thin delegate | `k_asm_parser_thin_delegate`（padding → glue 名） |
| if-expr C 包装 | `compiler/seeds/parser_asm/parser_asm_if_expr_slice.inc` |
| float alloc C | `compiler/seeds/parser_asm/parser_asm_primary_slice.inc` |
| padding glue | `parser_asm_thin_c.c` → `parser_try_skip_allow_padding_struct_*_glue` |

**禁止**：批量将 force_stub 项迁入 safe_helper 白名单（已证 Segfault / elf_ec=-1）。

---

## 4. Gate（历史入口）

见 **§7 Gate**（honesty 权威）。历史口令仍可用：

```bash
./tests/run-boot-force-stub-gate.sh
```

---

## 5. 变更流程

1. 新增 force_stub → 增 matrix 行 + 根因/策略 + 回归 `.x` +（若 link 行）`boot010_want_exit` 映射  
2. 尝试去 stub → 须 mega bisect / second-pass 绿 + 更新 matrix `strategy`  
3. 本地：`./tests/run-boot-force-stub-gate.sh`

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/boot-force-stub-matrix.tsv` |
| 门禁 | `tests/run-boot-force-stub-gate.sh` |
| helpers | `tests/lib/boot-force-stub.sh` |
| mega7 关联 | `analysis/archive/boot/boot-mega7-gap.md` §4 |
| 符号完整性 | `tests/run-parser-thin-glue-symbol-integrity-gate.sh` |

---

## 7. Gate

| 脚本 | 覆盖 |
|------|------|
| `tests/run-boot-force-stub-gate.sh` | manifest + honesty（prefer asm） |
| `tests/baseline/boot-force-stub-matrix.tsv` | 6 stub 行 + `min_stub_rows` |
| `tests/lib/boot-force-stub.sh` | `want_exit` 映射 + link+run + report |
| `compiler/seeds/runtime_pipeline_abi.from_x.c` | live `PARSER_STUB_EQ`（禁 `ast_pool.c` 复活） |

**Honesty contract（2026-08-26）**

| 项 | 规则 |
|----|------|
| compiler | prefer `./compiler/xlang_asm` then `xlang-c`／`xlang`；pin `XLANG_LINK_XLANG` |
| check_only | **observational**（自举期暂停；`wrap_return`／`skip_padding` 不挡门） |
| link+run | matrix 唯一 `reg_src` 产品 `-o` + 约定 exit **hard-fail**（须 4／4：simple=10／no_else=42／f32_f64=0／allow_padding_ok=2） |
| hooks | **不**再整闸调用 `run-float.sh`／`run-lang-unsafe-gate.sh`（其 check 负例在暂停闸门下 portable 假红）；权威回归 = matrix `reg_src` |
| no native | **FAIL**（exit 2）— 禁止 soft SKIP→OK |
| report | `link=`／`skip=`（`skip` = check_only 行数） |
| DOC | refuse top-level resurrect；live = `analysis/archive/boot/`；禁 `ast_pool.c` 复活 |

```bash
./tests/run-boot-force-stub-gate.sh
```

报告示例：`xlang: [XLANG_BOOT010] status=ok link=4 skip=2`

**BOOT-010 状态：硬绿 ✅（soft→硬绿）**

---

## 8. 索引（续）

见 §6；Gate 细节以 §7 为准。
