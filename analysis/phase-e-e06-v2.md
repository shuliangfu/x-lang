# 阶段 E-06 v2（experimental 链跳过 asm_driver_seed 前端 cc -c）

> **E-06 v2**：`SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1` 且 `parser_sx.o` 等 SX 前端就绪时，**experimental bootstrap** 不再 `cc -c` / 链接 `asm_driver_seed` 内 E-03 软退役前端 `.c`；strict 第二遍见 **E-06 v3**（`analysis/phase-e-e06-v3.md`）。

## v2 完成（✅）

| 机制 | 说明 |
|------|------|
| `asm_seed_use_sx_frontend()` | SKIP_GEN + `*_sx.o` 就绪 → 跳过前端 seed |
| `ensure_asm_driver_seed_frontend_c_objs` | 考古 / strict 回退专用 |
| `ensure_asm_driver_seed_support_c_objs` | async / lsp_state 等仍 cc -c |
| experimental link | `ASM_SEED_FRONTEND_LINK` 条件省略 SEED 前端 `.o` |
| 考古 | `SHUX_LEGACY_SEED_FRONTEND_CC=1` 恢复全量 seed cc -c |

## 仍 track / 延后（E-06 v3+）

| 路径 | 说明 |
|------|------|
| ~~strict 第二遍~~ | ✅ E-06 v3：`analysis/phase-e-e06-v3.md` |
| gen_driver 回退 | 全量 `ensure_asm_driver_seed_c_objs` |
| Windows B-strict | 硬禁 `pipeline_gen.c`（C-03 v2） |

## 复现

```bash
SHUX_E06_FAIL=1 ./tests/run-e06-no-compiler-frontend-cc-gate.sh
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log
SHUX_E06_BUILD_LOG=/tmp/build_bstrict.log SHUX_E06_FAIL=1 ./tests/run-e06-no-compiler-frontend-cc-gate.sh
```
