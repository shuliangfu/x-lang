# 阶段 E-06 v4（gen_driver 回退 omit SEED C 前端 cc -c / 链接）

> **E-06 v4**：在 E-06 v2/v3 基础上，**gen_driver hybrid / fallback** 链路与 `ensure_asm_driver_seed_c_objs` 在 X 前端 `*.o` 就绪时同样跳过 C 前端 seed `cc -c` 与链接；**不要求** `SHUX_ASM_EXPERIMENTAL_SKIP_GEN`（B-strict 仍禁 gen_driver 回退）。

## v4 完成（✅）

| 机制 | 说明 |
|------|------|
| `asm_seed_x_frontend_o_ready` | 共用 X 就绪检测 |
| `asm_seed_omit_c_frontend_seed` | X 就绪即 omit（无 SKIP_GEN 要求） |
| `asm_seed_use_x_frontend` | B-strict：SKIP_GEN + X 就绪 |
| `ensure_asm_driver_seed_c_objs` | 改用 `asm_seed_omit_c_frontend_seed` |
| `asm_seed_gen_driver_c_frontend_link` | gen_driver 链条件 omit preprocess/lexer/ast/parser/typeck/codegen seed |
| hybrid + fallback 两路 | `$ASM_GEN_DRIVER_*` 变量替换硬编码 SEED 前端 |

## 仍 track / 延后（E-06 v6+）

| 路径 | 说明 |
|------|------|
| ~~Windows B-strict~~ | ✅ E-06 v5：`SHUX_WIN_BSTRICT=1` + `phase-e-e06-v5.md` |
| Windows CI 默认 B-strict | 待 MSYS 链稳定后改 ci.yml |

## 复现

```bash
SHUX_E06_FAIL=1 ./tests/run-e06-no-compiler-frontend-cc-gate.sh
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log
SHUX_E06_BUILD_LOG=/tmp/build_bstrict.log SHUX_E06_FAIL=1 ./tests/run-e06-no-compiler-frontend-cc-gate.sh
```
