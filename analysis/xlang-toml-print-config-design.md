# `--print-config` design plant（刀 11.33）

> **Honesty**：CLI 设计冻结稿。本刀 **不**接线 `main`／driver，**不**声称 `load_toml` runtime 绿（刀 11.31 HOLD）。
> 字段权威：`analysis/xlang-toml-project-config-schema.md`（刀 11.32）。Gate：`tests/run-toml0-print-config-design-gate.sh`（静态）。
> 闸位 HOLD：不升 Soft Cap／钉／tiphead／Cap tip。

## 1. 行为

```
xlang build --print-config           # 打印后 exit 0
xlang build --print-config --config PATH
```

- 解析／merge 完成后、真正编译前打印并退出。
- 每行：`KEY = VALUE  # source=<toml|env|cli|default>`
- KEY 用 Layer2 逻辑键（见 11.32 表），例如 `build.backend`、`features.std`。

## 2. 来源优先级（打印须反映最终胜出源）

1. `cli` — 命令行显式覆盖
2. `env` — 约定前缀（设计：`XLANG_BUILD_*`／产品定稿时再钉）
3. `toml` — `xlang.toml`／`--config`
4. `default` — 零文件默认

## 3. 最小可测契约（未来实现；本刀只登记）

| ID | 契约 |
|----|------|
| T1 | 无 toml → 全部 `source=default`，字段集＝Core schema |
| T2 | 仅 Core example 文件 → 文件内键 `source=toml`，缺省键 `default` |
| T3 | env 覆盖某键 → 该键 `source=env`，值＝env |
| T4 | CLI 再覆盖 → `source=cli` |
| T5 | exit 0；不触发 compile／link |

## 4. 非目标（本刀／近期）

- `--print-config-json`
- Full schema（array／inline）键
- 在 tip `config.o` 上跑 load 实测（blocked＠11.31）

## 5. 实现对齐点（非本刀）

实现须等诚实 `project_load`（依赖 Soft Cap tiphead 可编 `config.x`，或另批 isolate host）。在此之前本文件＋gate 仅守设计锚点。
