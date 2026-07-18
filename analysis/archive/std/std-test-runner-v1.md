# STD-145：std.test 统一 test runner v1

> 状态：**定版（v1）**  
> 关联：`STD-054` expect、`STD-143` bench/fuzz 可执行框架

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
| `runner_case(name, name_len, exit_code)` | 输出 `shux: [SHUX_TEST] name=… status=pass\|fail code=…` |
| `runner_skip(name, name_len)` | 输出 `status=skip` |
| `runner_finish()` | 输出 `shux: [SHUX_TEST_SUMMARY] total=… pass=… fail=… skip=…`；返回 fail 数 |

C 层另有 `test_runner_run_case_c(name, fn)` 供纯 C 烟测；v1 不向 .x 暴露函数指针 cast。

---

## 3. 报告格式

```
shux: [SHUX_TEST] name=case_ok status=pass code=0
shux: [SHUX_TEST] name=case_skip status=skip code=0
shux: [SHUX_TEST_SUMMARY] total=2 pass=1 fail=0 skip=1
```

---

## 4. Gate

```bash
./tests/run-std-test-runner-gate.sh
```

烟测：`tests/std-test/runner_smoke.x`

报告：`shux: [SHUX_STD145_TEST_RUNNER]`
