# Config discovery design plant（刀 11.34）

> **Honesty**：发现路径设计冻结稿。本刀 **不**接线 `main`／`project_load`，**不**声称 `load_toml` runtime 绿（刀 11.31 HOLD）。
> 字段权威：刀 **11.32** schema；打印契约：刀 **11.33** `--print-config`。
> Gate：`tests/run-toml0-config-discovery-design-gate.sh`（静态）。闸位 HOLD。

## 1. 发现顺序（最终胜出文件）

1. CLI `--config PATH`（必须存在且可读；否则错误退出，不静默回退）
2. 从 CWD 起向上逐级找 `xlang.toml`（止于 FS 根或跨设备策略：v1 止于 `/`）
3. 皆无 → **零文件模式**：全部键走 Core defaults（见 11.32 表）

## 2. 与 Core example 的关系

- 用户可复制 `xlang.toml.core.example` → 项目根 `xlang.toml`。
- Full `xlang.toml`（仓内设计稿）可含 array／inline；**discovery 仍可找到该文件**，但 Layer2 Core 校验／消费只认 Core 键（Full 超集键策略：warn／error／ignore — 产品未钉，本刀登记为 **PUNT**）。

## 3. 最小可测契约（未来实现；本刀只登记）

| ID | 契约 |
|----|------|
| D1 | `--config missing` → non-zero；不读 CWD toml |
| D2 | CWD 有 `xlang.toml` → 选用该文件 |
| D3 | 仅父目录有 `xlang.toml` → 向上找到后选用 |
| D4 | 无文件 → defaults；`--print-config` 全 `source=default`（依 11.33 T1） |
| D5 | discovery **不**触发 Soft Cap rebuild／不假绿 load |

## 4. 非目标

- 多文件 merge（除 env／cli 覆盖层外）
- XDG／home 全局 config（远期）
- 在 tip `config.o` 上实测 load（blocked＠11.31）

## 5. 实现对齐点（非本刀）

`project_load(path|null)` 落地须等诚实 config codegen（Soft Cap tiphead）或另批 isolate host。
