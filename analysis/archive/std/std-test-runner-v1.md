# STD-145：std.test 统一 test runner v1

> 状态：**定版（v1）** · honesty 2026-08-26（prefer asm／check 观测／run 硬绿）  
> 关联：`STD-054` expect、`STD-143` bench/fuzz 可执行框架  
> 活路线图：`analysis/自举进度.md`（禁止顶层 `analysis/std-test-runner-v1.md` 复活）

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-145 | 统一用例报告格式 + 汇总行 + `.x` runner API + gate |

v1 不自动扫描文件系统；用例由测试 `main` 显式调用 `runner_case` / `runner_skip`，脚本 gate 可 grep 统一行。

---

## 2. Runner API

| API | 说明 |
|-----|------|
| `runner_reset()` | 重置 total/fail/skip 计数 |
| `runner_case(name, name_len, exit_code)` | 输出 `xlang: [XLANG_TEST] name=… status=pass\|fail code=…` |
| `runner_skip(name, name_len)` | 输出 `status=skip` |
| `runner_finish()` | 输出 `xlang: [XLANG_TEST_SUMMARY] total=… pass=… fail=… skip=…`；返回 fail 数 |

C 层另有 `test_runner_run_case_c(name, fn)` 供纯 C 烟测；v1 不向 .x 暴露函数指针 cast。  
报告字面量权威：`std/test/test.x`（`TST_LIT_SUMMARY`／case-line `mid` 必须含 NUL，否则 `append_cstr` 会溢写）。

---

## 3. 报告格式

```
xlang: [XLANG_TEST] name=case_ok status=pass code=0
xlang: [XLANG_TEST] name=case_skip status=skip code=0
xlang: [XLANG_TEST_SUMMARY] total=2 pass=1 fail=0 skip=1
```

---

## 4. Gate

```bash
./tests/run-std-test-runner-gate.sh
```

Honesty (2026-08-28 soft fallthrough residual): prefer `xlang_asm` + pin
`XLANG_LINK_XLANG`; explicit-bad `XLANG` / missing native → hard die (refuse
soft fallthrough / prefer-c / soft auto-make / soft SKIP→OK). check
observational (paused 2026-08-05). `runner_smoke.x` exit 0 + report lines
hard-fail (`run+=`). Report `run=` / `obs=` / `skip=`.

**Honesty (2026-08-29 leftover wrap dead source)**：leftover `bootstrap-link-xlang.sh` sourced unused（no `RUN_XLANG`）+ unused `compiler-make.sh` retired from `tests/run-std-test-runner-gate.sh`. Prefer asm + `XLANG_LINK_XLANG`；explicit-bad XLANG hard die；missing native FAIL；product `-o` `runner_smoke.x` hard；check＝obs；report `run=`／`obs=`／`skip=`。Keep `## 4. Gate`。 Leave wrap body / ensure_std family.

烟测：`tests/std-test/runner_smoke.x`

```
xlang: [XLANG_STD145_TEST_RUNNER] status=ok run=1 obs=1 skip=0
```
