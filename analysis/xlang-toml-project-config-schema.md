# ProjectConfig Layer2 — Core schema plant（刀 11.32）

> **Honesty**：本文是 Layer2 类型化 schema 冻结稿，对齐 `xlang.toml.core.example`（刀 11.30）。
> **不**声称 `config_load_toml_buf` runtime 绿（刀 11.31 residual HOLD：`cfg_trim` out_len／Soft Cap CG002）。
> **不**升 Soft Cap／钉／tiphead／Cap tip。Gate：`tests/run-toml0-project-config-schema-gate.sh`（静态核对）。

## 1. 发现顺序（设计）

1. CLI 显式 `--config PATH`
2. 向上找 `xlang.toml`（项目根）
3. 皆无 → defaults（零文件模式；与 Core 字段同形）

来源标签（与 `std/config` source_* 对齐，未来 merge）：`toml` / `env` / `cli` / `default`。

## 2. Core 字段表（MVP · 仅标量 + section）

| 逻辑键（扁平） | TOML 形状 | 类型 | 默认（零文件） | 备注 |
|----------------|-----------|------|----------------|------|
| `version` | `version` | string | `"0.1.0"` | 文件格式版本 |
| `package.name` | `[package] name` | string | `"app"` | |
| `package.edition` | `[package] edition` | string | `"2026"` | |
| `build.root` | `[build] root` | string | `"src/main.x"` | 入口 |
| `build.default-target` | `[build] default-target` | string | `"host"` | Core：单 target 标量（非 array-of-string） |
| `build.out-dir` | `[build] out-dir` | string | `"build"` | |
| `build.backend` | `[build] backend` | string | `"asm"` | |
| `build.link-std` | `[build] link-std` | bool | `true` | |
| `build.freestanding` | `[build] freestanding` | bool | `false` | |
| `build.optimization` | `[build] optimization` | i32 | `0` | |
| `profile.dev.opt-level` | `[profile.dev] opt-level` | i32 | `0` | |
| `profile.dev.debug` | `[profile.dev] debug` | bool | `true` | |
| `profile.release.opt-level` | `[profile.release] opt-level` | i32 | `3` | |
| `profile.release.lto` | `[profile.release] lto` | bool | `false` | |
| `features.std` | `[features] std` | bool | `true` | |
| `features.async` | `[features] async` | bool | `false` | |

## 3. Core 明确不做（Full／正交）

- array-of-string（如 `target = ["a","b"]`）
- inline table（如 `env = { TEMP = "..." }`）
- `[[array-of-tables]]`
- dependencies 图、tool.xlang 超集

这些仍见 `analysis/xlang-toml-实现分析.md`；Core example gate 已禁。

## 4. 下一实现边界（非本刀）

- `project_load` / typed `ProjectConfig` `.x`：须等 `config.o` 诚实可 rebuild（Soft Cap tiphead）或另批 isolate host。
- `--print-config`：打印值+来源；本刀只登记字段，不接线 CLI。

## 5. 核对锚点

静态 gate 要求本文件含上表逻辑键名，且 `xlang.toml.core.example` 仍含对应 TOML 锚点（与刀 11.30 gate 同源）。
