# TOOL-002 linter 规则分层（error / warn / info）v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`TOOL-001`（fmt）、`EXC-005`（CLI/LSP 诊断）、`lsp_diag.h`、`shux check`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 三层模型与 LSP severity 映射 |
| 2 | 打开 `tests/baseline/tool-lint-rules.tsv`（规则目录 L1–L6） |
| 3 | 打开 `tests/baseline/tool-lint-ci-profile.tsv`（CI 可配置档位） |
| 4 | `./tests/run-tool-lint-gate.sh` |

---

## 2. 三层模型（error / warn / info）

| 层级 | 含义 | LSP `severity` | CLI `check` 行前缀 | CI 默认 |
|------|------|----------------|-------------------|---------|
| **error** | 阻断编译/typeck | `1` (Error) | `path:line:col - error:` | **失败** |
| **warn** | 可修复风险/布局 hint | `2` (Warning) | `path:line:col - warning:` 或 `warning:` 行 | **不失败**（可配置） |
| **info** | 风格/建议（不阻断） | 预留 `3` (Information) | 无统一前缀（v1 走 fmt） | **不失败** |

v1 **不新增** `shux lint` 子命令；分层通过 **`shux check`** + 环境开关 + CI profile 表达。`shux fmt --check` 归属 **info** 层（TOOL-001）。

```
  ┌─────────────┐     SHUX_PAD_FIELDS=1      ┌──────────┐
  │ typeck/parse│ ──error──────────────────►│ CI fail  │
  └─────────────┘                           └──────────┘
         │
         │ warn (-pad-fields / -hot-reorder)
         ▼
  ┌─────────────┐   SHUX_LINT_CI_FAIL_ON=warn  ┌──────────┐
  │ layout hint │ ───────────────────────────►│ CI fail  │
  └─────────────┘                             └──────────┘
         │
         │ info (fmt --check)
         ▼
  ┌─────────────┐
  │ TOOL-001 fmt│
  └─────────────┘
```

---

## 3. 规则目录 L1–L6

权威：`tests/baseline/tool-lint-rules.tsv`（**6** 条 `rule_*`）。

| 规则 id | 层级 | 触发 | 实现锚点 |
|---------|------|------|----------|
| **L1-type-error** | error | 类型/借用冲突 | `lsp_diag_report_typeck`、`TYPECK_ERR` |
| **L2-parse-error** | error | 词法/语法错误 | `parser.c` `fail()` |
| **L3-pad-fields** | warn | `SHUX_PAD_FIELDS=1` + 相邻字段同 cache line | `runtime.c` `typeck_pad_fields_warn` |
| **L4-hot-reorder** | warn | `SHUX_HOT_REORDER=1` + 热字段置后 | `runtime.c` `typeck_hot_reorder_warn` |
| **L5-fmt-style** | info | 未格式化 `.x` | `driver_run_fmt` `--check`（TOOL-001） |
| **L6-unused-hint** | info | `SHUX_UNUSED_HINT=1` + 未使用 let/const/import 绑定 | `typeck.c` `typeck_unused_hints_module` |

---

## 4. CI 可配置 profile

权威：`tests/baseline/tool-lint-ci-profile.tsv`。

| 环境变量 | 说明 |
|----------|------|
| `SHUX_LINT_PROFILE` | 选用 profile 名（默认 `ci-default`）；CI **configurable** |
| `SHUX_LINT_CI_FAIL_ON` | `error`（默认）或 `warn`：warn 层也令 `check` 非零退出 |
| `SHUX_PAD_FIELDS` | `1` 启用 L3 |
| `SHUX_HOT_REORDER` | `1` 启用 L4 |
| `SHUX_UNUSED_HINT` | `1` 启用 L6（info，默认不阻断） |

`ci-default` profile：**仅 error 层失败**；warn/info 打印但不阻断流水线。

---

## 5. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_clean` | `tests/lint/lint_clean_ok.x` | `check` 静默 exit 0 |
| `case_error` | `tests/lint/lint_error_assign.x` | `check` exit 1 + ` - error: ` |
| `case_warn_pad` | `tests/lint/lint_warn_pad.x` | `SHUX_PAD_FIELDS=1 check` 含 `warning: -pad-fields`，exit 0 |
| `case_warn_reorder` | `tests/lint/lint_warn_reorder.x` | `SHUX_HOT_REORDER=1 check` 含 `warning: -hot-reorder`，exit 0 |
| `case_info_unused` | `tests/lint/lint_unused_hint.x` | `SHUX_UNUSED_HINT=1 check` 含 `unused binding`，exit 0 |

---

## 6. 非目标（v1）

- 不实现独立 `shux lint` CLI（v1.1 可收敛 check+profile）。
- 不新增 LSP Information 级别诊断（info 层暂由 fmt 承担）。
- 不把 warn 默认升为 CI 失败（须显式 `SHUX_LINT_CI_FAIL_ON=warn`）。

---

## 7. 验证与门禁

```bash
./tests/run-tool-lint-gate.sh   # runnable：manifest + lint hooks
./tests/run-lint-check.sh       # check 分层烟测
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-lint-rules-v1.md` |
| 规则 | `tests/baseline/tool-lint-rules.tsv` |
| profile | `tests/baseline/tool-lint-ci-profile.tsv` |
| 库 | `tests/lib/tool-lint.sh` |
| 门禁 | `tests/run-tool-lint-gate.sh` |
| hook | `tests/run-lint-check.sh` |

**TOOL-002 状态：定版 ✅**
