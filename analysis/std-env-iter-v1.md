# STD-025 std.env 命令行与环境块遍历 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` STD-025、`std.process` argc/argv

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-025 | `env_iter` 遍历环境块；`args_iter` 遍历命令行参数 |

`args_iter_*` 委托 `process_args_count_c` / `process_arg_c`（与 std.process 共享全局 argc/argv）。

---

## 2. API

### 2.1 环境块

| 函数 | 说明 |
|------|------|
| `env_iter()` | 构造 `EnvIter { index: 0 }` |
| `env_iter_count()` | 条目总数 |
| `env_iter_next(it, key_out, key_cap, val_out, val_cap)` | 返回 1/0/-1 |

### 2.2 命令行

| 函数 | 说明 |
|------|------|
| `args_iter()` | 构造 `ArgsIter` |
| `args_iter_count()` | argc（含 argv[0]） |
| `args_iter_next(it)` | 下一 `*u8` 或 0 |

---

## 3. 平台实现

| 平台 | 环境块来源 |
|------|------------|
| POSIX | `environ[]` |
| Windows | `GetEnvironmentStringsA` |

---

## 4. 边界金样

| 场景 | 期望 |
|------|------|
| `args_iter_next` 首次 | 非空（程序名） |
| `setenv("X_IT","v1")` 后 `env_iter` | 能找到 key/value |
| `env_iter_count()` | ≥ 1 |
| key_cap 不足 | `env_iter_next` 返回 -1 |

---

## 5. 验收

- manifest：`tests/baseline/std-env-iter.tsv`
- 烟测：`tests/env/env_iter.sx`
- 回归：`tests/run-env.sh`
- 报告：`shux: [SHUX_STD_ENV_ITER] status=ok`

---

## 6. 演进

- 与 `core.iterator` Option 风格 `next` 对齐；Windows 环境块增量变更通知。
