# ENV prefix convention design plant（刀 11.35）

> **Honesty**：环境变量覆盖约定冻结稿。本刀 **不**接线 `load_env_prefix` 实测路径为产品默认，**不**声称 tip `config.o` load 绿（刀 11.31 HOLD）。
> 对齐：刀 **11.32** 逻辑键、**11.33** `source=env`、**11.34** discovery。
> Gate：`tests/run-toml0-env-prefix-design-gate.sh`（静态）。闸位 HOLD。

## 1. 前缀

- 产品约定前缀：**`XLANG_`**（大写）。
- 扁平逻辑键转 env：`.` → `_`，全大写。
  - 例：`build.backend` → `XLANG_BUILD_BACKEND`
  - 例：`features.std` → `XLANG_FEATURES_STD`
  - 例：`package.name` → `XLANG_PACKAGE_NAME`

## 2. 类型解码（v1）

| Layer2 类型 | env 字符串约定 |
|-------------|----------------|
| string | 原样 |
| i32 | 十进制；非法 → 错误（不静默 0） |
| bool | `1`/`true`/`yes`／`0`/`false`/`no`（大小写不敏感）；其它 → 错误 |

## 3. 与 `--print-config`（11.33）

- 胜出源为 env 时打印 `source=env`。
- 优先级：cli > env > toml > default（同 11.33）。

## 4. 最小可测契约（未来实现；本刀只登记）

| ID | 契约 |
|----|------|
| E1 | 未设 env → 不影响 toml／default |
| E2 | `XLANG_BUILD_BACKEND=llvm` 覆盖 toml／default |
| E3 | 非法 bool／i32 → non-zero，不部分应用 |
| E4 | 未知 `XLANG_*` 键：v1 **ignore**（登记；可改 warn） |
| E5 | 本刀静态 only；不触发 Soft Cap／假绿 load |

## 5. 非目标

- 嵌套 JSON-in-env
- 覆盖 Full array／inline 键
- 改 tip Soft Cap／钉／tiphead
