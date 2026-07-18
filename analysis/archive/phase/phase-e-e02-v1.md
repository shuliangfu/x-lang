# 阶段 E-02 完成标准 v1（lsp_diag.c 软退役）

> **E-02 v1**：默认 bootstrap / shux-x / build_shux_asm **不链** `lsp_diag.c`；用 `lsp_diag_stubs_no_c.o` + `lsp_diag_x.o` + `lsp_diag_x_alias.c`。文件保留。

## v1 完成（✅）

| 项 | 标准 | 产物 |
|----|------|------|
| Makefile | `LSP_DIAG_LINK_O` 默认 stubs | `compiler/Makefile` |
| build_shux_asm | `ensure_lsp_diag_seed_obj` 默认 stubs | `compiler/scripts/build_shux_asm.sh` |
| 考古开关 | `SHUX_LEGACY_LSP_DIAG_C=1` 恢复 C 路径 | Makefile + build script |
| Gate | manifest + C-05 委托 | `tests/run-e02-lsp-diag-soft-gate.sh` |

## 复现

```bash
SHUX_E02_FAIL=1 ./tests/run-e02-lsp-diag-soft-gate.sh
make -C compiler bootstrap-driver-seed   # 默认 stubs
SHUX_LEGACY_LSP_DIAG_C=1 make -C compiler bootstrap-driver-seed  # 考古 C 路径
```

## 延后（E-02 v2）

- definition/hover/references 全迁 `.x`，删 stubs 中的 null 桩
- `OBJS_CORE`（shux-c）改链 stubs 或纯 `.x`
