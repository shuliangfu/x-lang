# TOOL-005 调试符号与源码映射 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
> 关联：`SAFE-007`（崩溃证据）、`std.backtrace`、`TOOL-003`（LSP 行列）、`invoke_cc`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 契约 D1–D6 |
| 2 | 打开 `tests/baseline/tool-debug-symbols.tsv` |
| 3 | `./tests/run-tool-debug-symbols-gate.sh` |
| 4 | 本地：`./tests/run-debug-symbols.sh`（须 native `shux`） |

---

## 2. 契约 D1–D6（debug symbols contract）

权威：`tests/baseline/tool-debug-symbols.tsv`（**6** 条 `rule_*`）。

| 规则 | 层级 | 说明 | 实现锚点 |
|------|------|------|----------|
| **D1-o0-no-strip** | 构建 | `-O 0` 链接后**不**执行 `strip` | `invoke_cc` 阶段 8 |
| **D2-o0-no-ndebug** | 构建 | `-O 0` 不传 `-DNDEBUG` | `invoke_cc` |
| **D3-symtab-main** | 符号 | `-O 0` 产物 `nm` 可见 `main` | cc 默认 symtab |
| **D4-backtrace-capture** | 堆栈（stack） | `std.backtrace.capture` 可返回 ≥1 帧（支持平台） | `backtrace_glue.c` |
| **D5-ast-line-col** | 源码映射 | AST 节点带 `line`/`col`（LSP 断点/definition） | `lsp_ensure_module` |
| **D6-release-strip** | 发布 | `-O 2` 默认 `strip` 减小体积 | `invoke_cc` |

**调试构建推荐**（v1 文档化，非强制改 driver）：

```bash
shux -O 0 -L . app.sx -o app.debug    # 保留 symtab，无 strip
# Linux 符号化增强（手工链接场景）：cc ... -g -rdynamic
```

v1 **不**要求 ASM 后端产出 DWARF（v1.1）；C 路径 `-O 0` + symtab 为断点/gdb 最小可用基线。

---

## 3. Golden 用例与 report

| case_id | 文件 | 检查 |
|---------|------|------|
| `case_marker` | `tests/debug/symbols_marker.sx` | `-O 0` 编译；`nm` 含 `main`；`file` 为 not stripped |
| `case_backtrace` | `tests/backtrace/main.sx` | `capture` 烟测（`run-backtrace.sh`） |

门禁 **report** 示例：

```
tool-debug-symbols report sym=main stripped=no o0=OK capture=skip|OK
```

---

## 4. 与 LSP / 崩溃证据关系

| 能力 | 路径 |
|------|------|
| 编辑器断点（breakpoint）行列 | AST `line`/`col` + `lsp_definition_at`（TOOL-003/004） |
| 运行时堆栈 | `std.backtrace` + `-O 0` symtab |
| 崩溃证据 | `collect_crash_evidence`（SAFE-007） |

---

## 5. 非目标（v1）

- 不生成 `.sx`→机器码 DWARF line table（ASM 后端 v1.1）。
- 不实现完整 `symbolicate`（`backtrace_symbolicate_c` 仍为 stub）。
- 不把 `-g` 默认注入 `invoke_cc`（用户/CI 按需扩展）。

---

## 6. 验证与门禁

```bash
./tests/run-tool-debug-symbols-gate.sh   # runnable：manifest + debug hooks
./tests/run-debug-symbols.sh             # -O0 symtab 烟测
./tests/run-backtrace.sh                 # backtrace capture
```

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/tool-debug-symbols-v1.md` |
| matrix | `tests/baseline/tool-debug-symbols.tsv` |
| 库 | `tests/lib/tool-debug-symbols.sh` |
| 门禁 | `tests/run-tool-debug-symbols-gate.sh` |

**TOOL-005 状态：定版 ✅**
