# EXC-005 CLI/LSP 错误显示统一 v1

> 更新时间：2026-08-26  
> **Honesty 2026-08-24 #8: lsp_diag.c retired; hubs live in lsp_diag.h + runtime_lsp_glue.**
> 状态：**硬绿（v1 honesty）** — soft→硬绿 2026-08-26（prefer asm；无 soft SKIP→OK）  
> 关联：`EXC-004`（ErrorChain 展示 v2）、`lsp_diag.h`、`run-check.sh`

> **Honesty 2026-08-24 #12:** top-level DOC retired; live = this archive path.
> **Honesty 2026-08-26:** DOC `## 7. Gate`；gate prefer `xlang_asm` + `XLANG_LINK_XLANG`；
> check observational；golden compile hard；no native → FAIL；report `check=`／`compile=`／`skip=`.

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **同错同文案** | 同一 typeck/parse 错误，CLI 与 LSP 的 **message 正文** 一致 |
| **同定位** | line/col 均为 **1-based**，与源码行列对齐 |
| **统一 hub** | typeck 经 `lsp_diag_report_typeck`；parse 经 `parser fail()` |
| **check 形态** | `xlang check` 输出 `path:line:col - error: msg`（deno 风格） |

验收（NEXT EXC-005）：**同错同文案同定位** + manifest + golden 烟测。

---

## 2. 三态模型

```
                    ┌─────────────────────┐
                    │  Diagnostic body    │
                    │  (无前缀 msg)       │
                    └──────────┬──────────┘
                               │
         lsp_diag_enabled=0    │    lsp_diag_enabled=1
              ┌────────────────┼────────────────┐
              ▼                ▼                ▼
     CLI compile        CLI check         LSP JSON
  typeck error: msg   path:L:C - error:   Diagnostic.message
       at L:C              msg                 = msg
  parse error at L:C: msg
```

| 表面 | 格式 | 实现 |
|------|------|------|
| **CLI typeck** | `typeck error: {msg} at {line}:{col}\n` | `lsp_diag_report_typeck` |
| **CLI parse** | `parse error at {line}:{col}: {msg}\n` | `parser.c` `fail()` |
| **CLI check** | `{path}:{line}:{col} - error: {msg}\n` | `lsp_diag_print_stderr_human` |
| **LSP** | JSON `message` = `{msg}`（**无** `typeck error:` 前缀） | `lsp_diag_add` |

**v1 规则**：写入 `lsp_diag_add` 的 `msg` **不得**含 `typeck error:` / `parse error at` 前缀（fallback 诊断除外，见 §5）。

---

## 3. 统一入口（Hub）

| 阶段 | Hub | 文件 |
|------|-----|------|
| typeck（C + X glue） | `lsp_diag_report_typeck(line, col, fmt, ...)` | `lsp/lsp_diag.c` |
| typeck 宏 | `TYPECK_ERR` / `TYPECK_ERR_AT` | `typeck/typeck.c` |
| parse | `fail(Parser *, msg)` | `parser/parser.c` |
| check 打印 | `lsp_diag_print_stderr_human(path)` | `lsp/lsp_diag.c` |
| X 细粒度 | `driver_diagnostic_typeck_*` → 优先 `lsp_diag_report_typeck` | `runtime.c` |

---

## 4. Golden 用例（manifest）

| case_id |  fixture | 期望 message 子串 |
|---------|----------|-------------------|
| `typeck_assign` | `tests/typeck/type_mismatch_assign.x` | `assignment type mismatch: expected i32, found bool` |
| `typeck_return` | `tests/typeck/return_operand_type_mismatch.x` | `return expression type mismatch` |
| `check_format` | `xlang check` + assign fixture | ` - error: ` + 上列正文 |

行列：须匹配 `\d+:\d+`（check）或 ` at \d+:\d+`（compile typeck）。

---

## 5. 已知例外（v1 文档化，v1.1 收敛）

| 路径 | 说明 |
|------|------|
| `driver_diagnostic_typeck_fail` | 泛化 fallback 行可含 `typeck error:` 前缀 |
| `XLANG_DEBUG_*` | 调试行非用户诊断 |
| codegen/link | 非 frontend 诊断，不在本规范范围 |

---

## 6. 与 EXC-004 关系

- v1：`ErrorChain` 打印由调用方组装；**不**改变 LSP message 格式。
- v2：可选 `error_chain_format_stderr` / LSP relatedInformation。

---

## 7. Gate

| 脚本 | 覆盖 |
|------|------|
| `tests/run-exc-cli-lsp-error-gate.sh` | manifest + honesty smoke（prefer asm） |
| `tests/baseline/exc-cli-lsp-error.tsv` | hub／format／2× golden compile + check hook |
| `tests/typeck/type_mismatch_assign.x` 等 | compile stderr phrase+kind+line:col hard |

**Honesty contract（2026-08-26）**

| 项 | 规则 |
|----|------|
| compiler | prefer `./compiler/xlang_asm` then `xlang-c`／`xlang`；pin `XLANG_LINK_XLANG` |
| check | observational only（check gate paused 2026-08-05） |
| golden compile | TSV `kind=golden` stderr phrase + CLI kind + `line:col` **hard-fail** |
| no native | **FAIL**（exit 2）— 禁止 soft SKIP→OK |
| report | `check=`／`compile=`／`skip=` |
| DOC | refuse top-level resurrect；live = `analysis/archive/exc/` |

```bash
./tests/run-exc-cli-lsp-error-gate.sh
```

矩阵：`tests/baseline/exc-cli-lsp-error.tsv`

报告示例：`exc-cli-lsp-error status=ok check=0|1 compile=1 skip=0`

---

## 8. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/exc-cli-lsp-error.tsv` |
| 门禁 | `tests/run-exc-cli-lsp-error-gate.sh` |
| LSP API | `compiler/src/lsp/lsp_diag.h` |
| check 烟测 | `tests/run-check.sh` |

**EXC-005 状态：硬绿 ✅（soft→硬绿）**
