# LANG-006 编译期常量求值（CTFE）v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `typeck.c` CTFE、`codegen.c` fold 输出对齐  
> 关联：`LANG-001`（feature gate）、`COMP-004`（WPO const spec fold）、`tests/run-let-const.sh`

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 求值层 C1–C6 |
| 2 | 打开 `tests/baseline/lang-const-eval.tsv` |
| 3 | `./tests/run-lang-const-eval-gate.sh` |
| 4 | `./tests/run-lang-const-eval.sh`（单跑金样） |

---

## 2. 求值层 C1–C6（compile-time evaluation）

权威：`tests/baseline/lang-const-eval.tsv`（**6** 条 `layer_*`）。

| 层级 | 模式 | 实现锚点 | v1 状态 |
|------|------|----------|---------|
| **C1-literal** | 整型/布尔/十六进制字面量 | `AST_EXPR_LIT` / `BOOL_LIT` | ✅ |
| **C2-const-bind** | `const A=3; const B=A+2` 链式绑定 | `typeck.c` const 表 + `eval_const_int` | ✅ |
| **C3-binop** | `+-*/%` 比较/逻辑/位运算/移位 | `is_const_expr` + `fold_expr` binop | ✅ |
| **C4-unary** | `-` `~` `!` | `fold_expr` unary | ✅ |
| **C5-array-len** | 数组字面量在 `i32` 上下文求值为元素个数 | `eval_const_int` `ARRAY_LIT` | ✅ |
| **C6-codegen** | 折叠结果写入 `const_folded_valid/val` | `codegen.c` / `pipeline_glue.c` emit | ✅ |

**求值模型**：

1. **const 初值**：须满足 `is_const_expr`；否则 typeck 报 `const init must be constant expression`。
2. **表达式折叠**：typeck 阶段 `fold_expr` 对可折叠子树写入 `const_folded_val`；codegen/asm 优先发射立即数。
3. **作用域**：块内 `const` 可被同块及子块后续 const/折叠引用；父块 const 经 `parent_n_consts` 可见。

```su
const A: i32 = 3;
const B: i32 = A + 2;
return B * 2;  // → exit 10（见 tests/let-const/const_expr.sx）
```

**v1 非目标**：

- 浮点 CTFE 完整语义（仅字面量截断为 int fold）
- `if`/`?:` 常量分支选择
- 跨函数 `constexpr` 调用（WPO `const_spec_fold` 为独立优化线）

---

## 3. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_binop_mix` | `tests/lang-const/c_binop_mix.sx` | exit **20** |
| `case_bitwise` | `tests/lang-const/c_bitwise.sx` | exit **131** |
| `case_shift` | `tests/lang-const/c_shift.sx` | exit **0** |
| `case_compare` | `tests/lang-const/c_compare.sx` | exit **2** |
| `case_unary` | `tests/lang-const/c_unary.sx` | exit **260** |
| `case_logical` | `tests/lang-const/c_logical.sx` | exit **1** |
| `case_const_chain` | `tests/lang-const/c_const_chain.sx` | exit **20** |
| `case_mod_div` | `tests/lang-const/c_mod_div.sx` | exit **7** |
| `case_nested` | `tests/lang-const/c_nested.sx` | exit **13** |
| `case_hex` | `tests/lang-const/c_hex.sx` | exit **42** |
| `case_array_len` | `tests/lang-const/c_array_len.sx` | exit **4** |
| `case_let_const_hook` | `tests/run-let-const.sh` | hook **0** |

---

## 4. Gate 与 report

| 组件 | 路径 |
|------|------|
| manifest | `tests/baseline/lang-const-eval.tsv` |
| runner | `tests/lib/lang-const-eval.sh` |
| gate | `tests/run-lang-const-eval-gate.sh` |
| hook | `tests/run-lang-const-eval.sh` |

gate 输出 **`lang-const-eval gate OK`**；无 native `shux` 时 manifest 仍过、bench **SKIP**；有 native `shux` 时全量 **runnable** report。

---

## 5. 与 WPO 联动

`tests/wpo/const_spec_fold.sx`：`scale(1024,64)` 调用点特化折叠（**C6-codegen** 延伸）；由 `run-wpo-s2.sh` 覆盖，本 gate 仅登记 symbol 锚点。

---

## 6. 验收

- [x] RFC + manifest **6** layer + **≥10** case
- [x] `tests/lang-const/*.sx` 常见算术/位运算/const 链
- [x] `run-lang-const-eval-gate.sh` + `run-portable-suite.sh`
