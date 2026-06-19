# LANG-001 语法版本化与 feature gate v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`docs/01-关键字.md`（预处理）、`driver_argv_collect_defines`、`LANG-002`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 版本层 G1–G6 |
| 2 | 打开 `tests/baseline/lang-feature-gate.tsv` |
| 3 | `./tests/run-lang-feature-gate-gate.sh` |
| 4 | `./scripts/shux-lang-edition.sh 2024 tests/lang-feature/edition_stable.sx` |

---

## 2. 版本层 G1–G6（feature gate）

权威：`tests/baseline/lang-feature-gate.tsv`（**6** 条 `gate_*`）。

| 层级 | 符号 / 机制 | 说明 |
|------|-------------|------|
| **G1-edition-2024** | `SHUX_EDITION_2024` | 稳定语法基线（默认推荐） |
| **G2-edition-2025** | `SHUX_EDITION_2025` | 实验语法，须显式 `-D` 启用 |
| **G3-feature-flag** | `SHUX_FEATURE_<NAME>` | 单特性灰度（如 `SHUX_FEATURE_MATCH_STMT`） |
| **G4-preprocessor** | `#if` / `#else` / `#endif` | 词法前条件编译，保持行号 |
| **G5-driver-define** | `shux -D SYMBOL` | `driver_argv_collect_defines` 注入 |
| **G6-platform-auto** | `SHUX_OS_*` / `SHUX_ARCH_*` | uname / `-target` 自动定义 |

**灰度（grayscale）工作流**：

```bash
# 稳定 edition（wrapper 注入 -D）
./scripts/shux-lang-edition.sh 2024 app.sx -o app

# 实验 edition
./scripts/shux-lang-edition.sh 2025 app.sx -o app.exp

# 单特性
shux -D SHUX_FEATURE_MATCH_STMT app.sx -o app
```

v1 **不**解析源码 `edition 2024` 文件头（v1.1）；版本仅通过 **`-D` + wrapper** 表达。

---

## 3. 特性目录

`tests/baseline/lang-feature-catalog.tsv` 登记 gate 符号与 tier。

| symbol | tier | 说明 |
|--------|------|------|
| `SHUX_EDITION_2024` | stable | 默认稳定 |
| `SHUX_EDITION_2025` | experimental |  opt-in |
| `SHUX_FEATURE_MATCH_STMT` | experimental | `match` 语句灰度样例 |

---

## 4. Golden 用例

| case_id | 文件 | 编译方式 | 期望 exit |
|---------|------|----------|-----------|
| `case_edition_stable` | `edition_stable.sx` | 无 `-D SHUX_EDITION_2025` | 0 |
| `case_edition_exp` | `edition_stable.sx` | `-D SHUX_EDITION_2025` | 99 |
| `case_feature_off` | `feature_match.sx` | 无 feature flag | 0 |
| `case_feature_on` | `feature_match.sx` | `-D SHUX_FEATURE_MATCH_STMT` | 42 |

---

## 5. 非目标（v1）

- 不实现源码级 `edition` 关键字声明。
- 不做特性依赖求解器（仅扁平 `-D`）。
- 不改变默认 `shux` 无 `-D` 时的 define 集合（v1.1 可默认注入 `SHUX_EDITION_2024`）。

---

## 6. 验证与门禁

```bash
./tests/run-lang-feature-gate-gate.sh   # runnable：manifest + feature hooks
./tests/run-lang-feature-gate.sh        # edition/feature 烟测
```

**gate report**：门禁 stdout 须含 `lang-feature-gate gate OK`；失败时打印 `lang-feature-gate FAIL:` / `gate FAIL:` 行便于 CI 解析。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/lang-feature-gate-v1.md` |
| manifest | `tests/baseline/lang-feature-gate.tsv` |
| catalog | `tests/baseline/lang-feature-catalog.tsv` |
| wrapper | `scripts/shux-lang-edition.sh` |

**LANG-001 状态：定版 ✅**
