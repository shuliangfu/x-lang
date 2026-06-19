# STD-132：std.env 平台编码 / 环境块边界 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` std.env 平台编码边界、`STD-025` env_iter

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-132 | 环境块 KV 解析金样 + 空 value / value 含 `=` / key_len 边界 |

POSIX 与 Windows 共用 `env_parse_kv_entry`；Windows 环境块来源 `GetEnvironmentStringsA`（ANSI/ACP，非 UTF-8 保证）。

---

## 2. 边界金样

| 场景 | 期望 |
|------|------|
| `KEY=` | key=`KEY`，value 空串 |
| `K=V=W` | 仅首 `=` 分割，value=`V=W` |
| `NOEQ` | key=`NOEQ`，value 空 |
| key_cap / val_cap 不足 | `env_parse_kv_entry` 返回 -1 |
| `setenv` 空 value | `getenv` 返回长度 0 |
| `setenv` value 含 `=` | 完整回读 |
| `env_iter` | 与 `getenv` 一致 |
| `key_len` ≥ 256 或 ≤ 0 | `getenv` / `getenv_exists` 拒绝 |

---

## 3. 验收

- manifest：`tests/baseline/std-env-platform-encoding-manifest.tsv`
- C 金样：`env_platform_encoding_smoke_c`（`std/env/env.c`）
- 烟测：`tests/env/platform_encoding.sx`
- 门禁：`./tests/run-std-env-platform-encoding-gate.sh`
- 报告：`shux: [SHUX_STD132_ENV_PLATFORM_ENCODING]`

---

## 4. 平台说明

| 平台 | 编码 |
|------|------|
| POSIX | 环境块为进程 byte 串（通常 UTF-8，取决于 locale） |
| Windows | `GetEnvironmentStringsA` / `GetEnvironmentVariableA`（系统 ANSI） |

非 ASCII 环境变量值的行为以 OS 编码为准；v1 仅保证解析语义一致、不崩溃。
