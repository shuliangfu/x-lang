# TOOL-004 LSP 诊断性能（performance）v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`TOOL-003`（补全）、`OBS-001`（编译阶段耗时）、`compiler/src/lsp/lsp_diag.c`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 优化策略 P1–P6 |
| 2 | 打开 `tests/baseline/tool-lsp-diag-perf.tsv` |
| 3 | `./tests/run-tool-lsp-diag-perf-gate.sh` |
| 4 | 本地：`./tests/run-lsp-diag-perf.sh`（须 native `shux --lsp`） |

---

## 2. 优化策略 P1–P6

权威：`tests/baseline/tool-lsp-diag-perf.tsv`（**6** 条 `opt_*`）。

| 策略 | 锚点 | 作用 |
|------|------|------|
| **P1-module-cache** | `lsp_ensure_module` | 文档 `(len, hash)` 未变时复用 AST 模块 |
| **P2-diag-json-cache** | `s_last_diag_json` | parse+typeck 后缓存 Diagnostic[] JSON |
| **P3-len-before-hash** | `lsp_ensure_module` | 先比 `source_len` 再算 hash，大文件省时 |
| **P4-in-place-parse** | `lsp_ensure_module` | 就地 NUL 终止 lexer 输入，避免整份 memcpy |
| **P5-lazy-typeck** | `lsp_typeck_entry_module` | `cursor_line_1≥0` 时仅 typeck 光标所在函数 |
| **P6-line-index** | `build_line_index` | 按行 O(1) 定位函数，减少 definition/hover 全树遍历 |

**路径说明**：

- `completion` / `definition` / `hover`（C 路径）走 `lsp_ensure_module`，**命中 P1–P6**。
- `textDocument/diagnostic`（`.x` 路径 `lsp_build_diagnostics_response`）v1 每次 `invalidate` 后全量 pipeline；大文件性能靠 **P4 同类 buffer 复用**（`lsp_diag_x_reset_parse_buffers`）与后续 v1.1 诊断缓存收敛。

---

## 3. 性能指标与 report

| 指标 | 阈值（`ci-default`） | 说明 |
|------|----------------------|------|
| `min_large_funcs` | 30 | 金样 `diag_large_ok.x` 顶层函数数 |
| `max_wall_ms` | 15000 | 大文件 LSP 会话墙钟上限（ms） |
| `warm_same_items` | 1 | 同文档连续两次 completion 条数一致（缓存正确性） |

门禁输出：**report** 行示例：

```
tool-lsp-diag-perf report wall_ms=1234 funcs=40 warm_items=52/52 large=OK
```

---

## 4. Golden 用例

| case_id | 文件 | 场景 |
|---------|------|------|
| `case_large` | `tests/lsp/diag_large_ok.x` | 40 个 `fN` + `main`；diagnostic + 双次 completion |
| `case_small` | `tests/lsp/main.x` | 对照小文件（`run-lsp.sh` 已覆盖） |

烟测：`initialize` → `didOpen` large → `textDocument/diagnostic` → 两次 `textDocument/completion`（同光标）。

---

## 5. 非目标（v1）

- 不改动 `lsp_build_diagnostics_response` 为全量诊断缓存（v1.1）。
- 不做跨文件 workspace 增量诊断。
- 不以绝对 ms 做发布硬门禁（仅 manifest 上限 + Linux 烟测）。

---

## 6. 验证与门禁

```bash
./tests/run-tool-lsp-diag-perf-gate.sh   # runnable：manifest + perf hooks
./tests/run-lsp-diag-perf.sh             # 大文件 LSP 烟测 + report
./tests/run-lsp.sh                       # 基础 LSP
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-lsp-diag-perf-v1.md` |
| matrix | `tests/baseline/tool-lsp-diag-perf.tsv` |
| 库 | `tests/lib/tool-lsp-diag-perf.sh` |
| 门禁 | `tests/run-tool-lsp-diag-perf-gate.sh` |
| hook | `tests/run-lsp-diag-perf.sh` |

**TOOL-004 状态：定版 ✅**
