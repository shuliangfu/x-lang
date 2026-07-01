# Debug Session: result-try-typeck
- **Status**: [OPEN]
- **Issue**: `./compiler/shux_asm tests/typeck/result_try.sx` 仍报 `?` requires the enclosing function to return the same Result type
- **Debug Server**: pending
- **Log File**: `.dbg/trae-debug-log-result-try-typeck.ndjson`

## Reproduction Steps
1. `make -C compiler bootstrap-driver-bstrict-relink`
2. `./compiler/shux_asm tests/typeck/result_try.sx`

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | `try_propagate` 执行时 `ctx->current_func_index` 仍为 `-1` 或错误函数下标 | High | Low | Pending |
| B | `pipeline_module_func_return_type_at()` 取到的返回类型 ref 与 `op_ty` 不在同一比较层级 | High | Low | Pending |
| C | `op_ty` 在 `may_fail(x)?` 位置没有解析成 `Result_i32`，而是被上下文 `i32` 污染 | High | Low | Pending |
| D | 当前运行路径没有实际走到已修改的 `pipeline_typeck_check_expr_try_propagate_c` 实现 | Medium | Low | Pending |

## Log Evidence
- Pending

## Verification Conclusion
- Pending
