# SAFE-005 泄漏检测夜跑 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`SAFE-001`（M-6 sanitize）、`SAFE-004`（FFI 契约）、`ENG-003`（夜跑）

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2–§4（ASAN 策略、用例、报告） |
| 2 | 打开 `tests/baseline/safe-leak-nightly.tsv` |
| 3 | `./tests/run-safe-leak-nightly-gate.sh` |
| 4 | Linux CI：`./tests/run-safe-leak-nightly.sh` |

---

## 2. ASAN/LSAN 策略

| 项 | v1 约定 |
|----|---------|
| 工具链 | `cc -fsanitize=address` + `detect_leaks=1` |
| 编译 | `shux -fsanitize=address -L . <case>.sx -o exe` |
| 运行 | `ASAN_OPTIONS=detect_leaks=1:exitcode=23:halt_on_error=1` |
| 平台 | **Linux** 夜跑主路径；macOS/Windows gate manifest only |
| 探测器 | `SHUX_LEAK_PROBE=1` 时运行 `leak_probe.c` 校验 ASAN 能抓故意泄漏 |

与 SAFE-001 `run-sanitize-gate.sh`（编译期边界）互补：本任务覆盖 **堆/owned 指针运行时泄漏**。

---

## 3. 夜跑用例矩阵

权威：`tests/baseline/safe-leak-nightly.tsv`（**3** 条 `no_leak_*`）。

| case | 路径 | 覆盖 |
|------|------|------|
| `case_heap` | `tests/leak/no_leak_heap.sx` | `alloc` / `free` |
| `case_ffi` | `tests/leak/no_leak_ffi.sx` | `cstring_new` / `cstring_free` |
| `case_arena` | `tests/leak/no_leak_arena.sx` | `arena64_deinit` |

---

## 4. 报告格式（leak report）

stderr 结构化行（OBS bracket 兼容）：

```
shux: [SHUX_LEAK_NIGHTLY] status=ok cases_ok=3 cases_fail=0 leaks=0
```

| 字段 | 含义 |
|------|------|
| `status` | `ok` / `fail` / `skip` |
| `cases_ok` | 通过用例数 |
| `cases_fail` | 失败用例数 |
| `leaks` | 检出泄漏数（失败时 ≥1） |

**每周**：取 `ci-nightly` Linux job 最近一次 `SHUX_LEAK_NIGHTLY` 行作为周报输入（cron 每日 02:00 UTC，聚合 7 天）。

---

## 5. 调度与门禁

| 入口 | 角色 |
|------|------|
| `.github/workflows/ci-nightly.yml` | Linux job 在 full suite 后跑 `run-safe-leak-nightly.sh` |
| 库 | `tests/lib/safe-leak.sh` |
| runner | `tests/run-safe-leak-nightly.sh` |
| 门禁 | `tests/run-safe-leak-nightly-gate.sh` |

```bash
./tests/run-safe-leak-nightly-gate.sh
SHUX_LEAK_PROBE=1 ./tests/run-safe-leak-nightly.sh   # runnable 夜跑
```

联动：`tests/run-safe-ffi-contract-gate.sh`（SAFE-004）、`tests/run-sanitize-gate.sh`（SAFE-001）。

**SAFE-005 状态：定版 ✅**
