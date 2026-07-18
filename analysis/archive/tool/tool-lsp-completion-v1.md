# TOOL-003 LSP 补全质量 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`EXC-005`（诊断统一）、`compiler/src/lsp/lsp_diag.c`、`tests/run-lsp.sh`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 补全分层 C1–C6 |
| 2 | 打开 `tests/baseline/tool-lsp-completion.tsv` |
| 3 | `./tests/run-tool-lsp-completion-gate.sh` |
| 4 | 本地：`./tests/run-lsp-completion.sh`（须 native `shux --lsp`） |

---

## 2. 补全分层 C1–C6（CompletionItem kind）

权威：`tests/baseline/tool-lsp-completion.tsv`（**6** 层 `tier_*`）。

| 层级 | LSP `kind` | 来源 | v1 命中要求 |
|------|------------|------|-------------|
| **C1-function** | `3` (Function) | 模块顶层 `function` | 金样须含 `add_one` |
| **C2-struct** | `7` (Struct) | `struct` 定义 | 金样须含 `Point` |
| **C3-enum** | `13` (Enum) | `enum` 定义 | 金样须含 `Kind` |
| **C4-import** | `9` (Module) | `import` 路径 | 金样须含 `core.mem` |
| **C5-keyword** | `14` (Keyword) | 语言关键字表 | 金样须含 `function` |
| **C6-type** | `25` (TypeParameter) | 内建类型表 | 金样须含 `i32` |

实现：`lsp_build_completion_response`（`lsp_diag.c`）在 `lsp_ensure_module` 后聚合上述六类符号；**v1 不做前缀过滤**（全量列表）。

`initialize` capabilities 须声明：

```json
"completionProvider":{"triggerCharacters":[".",":","("]}
```

---

## 3. 命中率（hit rate）与 report

v1 **命中率**定义为：对金样 `completion_symbols.x` 发 `textDocument/completion` 后，`result` 数组 JSON 中 **6/6** 期望 `label` 均出现。

| 指标 | 阈值 | 说明 |
|------|------|------|
| `min_tier_hits` | 6 | C1–C6 各至少 1 条 |
| `min_completion_items` | 10 | 除六类外尚含其它关键字/类型 |

门禁输出一行 **report**：`tool-lsp-completion report hits=6/6 items=N`。

---

## 4. Golden 用例

| case_id | 文件 | 光标 | 期望 label（子集） |
|---------|------|------|-------------------|
| `case_symbols` | `tests/lsp/completion_symbols.x` | `main` 函数体末行 | `add_one`、`Point`、`Kind`、`core.mem`、`function`、`i32` |

烟测流程：`initialize` → `didOpen` → `textDocument/completion` → 校验 `CompletionItem` JSON。

---

## 5. 非目标（v1）

- 不做 fuzzy / 前缀过滤（v1.1）。
- 不补全 struct 字段成员（`.` 触发，v1.1）。
- 不跨文件 workspace 符号（仅当前文档模块缓存）。

---

## 6. 验证与门禁

```bash
./tests/run-tool-lsp-completion-gate.sh   # runnable：manifest + completion hooks
./tests/run-lsp-completion.sh             # completion 烟测
./tests/run-lsp.sh                        # 基础 LSP 烟测（diagnostic/definition/fmt）
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-lsp-completion-v1.md` |
| matrix | `tests/baseline/tool-lsp-completion.tsv` |
| 库 | `tests/lib/tool-lsp-completion.sh` |
| 门禁 | `tests/run-tool-lsp-completion-gate.sh` |
| hook | `tests/run-lsp-completion.sh` |

**TOOL-003 状态：定版 ✅**
