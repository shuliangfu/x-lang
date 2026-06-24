# 阶段 C-05 完成标准 v1（NEXT §6）

> **C-05 v1**：采用前置清单 **方案 B 子集** — `lsp_diag.sx` 经 `-E-extern` 链入 `lsp_diag_sx.o`，诊断路径走 **parse_into_buf + typeck_sx_ast**；`lsp_diag.c` 仍提供收集器 / definition / hover / formatting glue。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| lsp_diag.sx | 诊断 JSON 响应；`pipeline_lsp_diag_parse_typeck_buf` | `run-c05-lsp-sx-gate.sh` |
| Makefile 链 | `bootstrap-driver-seed` 链 `lsp_diag_sx.o` + alias | 同上 |
| LSP 烟测 | `shux --lsp` initialize / diagnostics / format / definition | `run-lsp.sh`（委托） |
| 补全 | C1–C6 completion | `run-lsp-completion.sh`（登记） |

## 仍留 C（不阻塞 v1 ✅）

- **lsp_diag.c**：诊断收集、`lsp_build_response_with_result`、definition/hover/references C 路径（E-02）
- **lsp_diag_sx_alias.c**：强符号覆盖 C weak 实现

## 复现

```bash
make -C compiler bootstrap-driver-seed
SHUX_C05_FAIL=1 ./tests/run-c05-lsp-sx-gate.sh
```

## 延后（C-05 v2 / E-02）

- 删 `lsp_diag.c` 或收成仅 ABI 薄层
- definition/hover/references 全迁 `.sx`
