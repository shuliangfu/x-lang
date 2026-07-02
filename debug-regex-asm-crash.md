# Debug Session: regex-asm-crash
- **Status**: [OPEN]
- **Issue**: `./shux_asm -backend asm -L .. ../std/regex/regex.sx -o ...` compiles through parse/typeck and then crashes with `Segmentation fault: 11` after `pipeline thread done ec=0`.
- **Debug Server**: N/A
- **Log File**: `tests/probes/bootstrap-parser/regex_asm_probe.stderr`

## Reproduction Steps
1. Run `perl -e 'alarm shift; exec @ARGV' 15 env SHUX_DEBUG_PARSE=1 SHUX_DEBUG_PIPE=1 SHUX_ASM_WPO_DCE=0 ./shux_asm -backend asm -L .. ../std/regex/regex.sx -o ../tests/probes/bootstrap-parser/regex_asm_core.o`
2. Observe parse/typeck reaches `pipeline thread done ec=0`.
3. Process crashes with `Segmentation fault: 11`.

## Hypotheses & Verification
| ID | Hypothesis | Likelihood | Effort | Evidence |
|----|------------|------------|--------|----------|
| A | Crash is in asm expr emit after successful typeck, likely while lowering one regex function | High | Low | Confirmed |
| B | Crash is in object/output write path after asm text is already produced | High | Low | Rejected |
| C | Crash is caused by stale `shux_asm` / object topology mismatch rather than regex logic itself | Medium | Low | Rejected |
| D | Crash is triggered by one specific regex construct that sends expr emit into self-recursion or a cycle | Medium | Medium | Inconclusive |
| E | Crash is in post-pipeline driver cleanup/finalization, not regex-specific codegen | Low | Low | Rejected |

## Log Evidence
- `tests/probes/bootstrap-parser/regex_asm_probe.stderr`: parse/typeck reaches `pipeline thread done ec=0`, so failure is after pipeline success.
- `tests/probes/bootstrap-parser/regex_asm_lldb_bt_short.txt`: crash stops in `pipeline_arena_expr_ptr`, but the stack is a long repetition of `pipeline_asm_emit_expr_elf_rec -> backend_emit_expr_elf_slow -> backend_emit_expr_elf_full -> backend_emit_expr_elf`.
- The repeated recursive frames indicate stack exhaustion / unbounded recursion is more likely than a simple invalid output-path crash.

## Verification Conclusion
- Confirmed: crash is inside asm expr emission after parse/typeck complete.
- Rejected: pure output write-path crash, stale `shux_asm` sync issue, and generic post-pipeline cleanup crash.
- Confirmed by instrumentation: `expr_ref=4420`, `ko=26` (`AST_EXPR_BLOCK`) repeatedly recurses back into `pipeline_asm_emit_expr_elf_rec`, so the crash is an unbounded self-recursion rather than output write failure.

## Fix & Retest
- Applied a minimal fix in `compiler/pipeline_glue.c`: route `ko == 26` in `pipeline_asm_emit_expr_elf_rec()` to the existing `pipeline_asm_emit_expr_if_arm_elf_c()` block-body path instead of falling through to `backend_emit_expr_elf_slow()`.
- Retest command now succeeds in 15s: `perl -e 'alarm shift; exec @ARGV' 15 env SHUX_DEBUG_PARSE=1 SHUX_DEBUG_PIPE=1 SHUX_ASM_WPO_DCE=0 ./shux_asm -backend asm -L .. ../std/regex/regex.sx -o ../tests/probes/bootstrap-parser/regex_asm_core.o`
- `pipeline thread done ec=0` is now followed by normal exit code `0`, with no `Segmentation fault: 11`.

## Front Gate After Fix
- `make bootstrap-parser` no longer stops at `std/regex/regex.sx`.
- The next front gate has moved to `std/context/context.sx`: `codegen error[CG002]: asm_codegen_elf_o failed (elf_ec=-1, out_len=0, num_funcs=34)`.
