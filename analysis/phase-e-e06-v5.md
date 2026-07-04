# 阶段 E-06 v5（Windows MSYS2 B-strict：禁 cc -c pipeline_gen.c）

> **E-06 v5**：Windows MSYS2 在 **`SHUX_WIN_BSTRICT=1`** 时走 **`bootstrap-driver-bstrict`**（`SKIP_GEN` + experimental X-only），日志 **不得** `cc -c pipeline_gen.c`；默认 **`SHUX_WIN_BSTRICT=0`** 仍为 B-hybrid 回退。

## v5 完成（✅）

| 机制 | 说明 |
|------|------|
| `build_shux_asm_is_msys` | MSYS2/MINGW 探测 |
| MSYS + SKIP_GEN | experimental X-only（无需 build_asm/*.o） |
| `bootstrap-driver-bstrict-windows` | Makefile 别名 → `bootstrap-driver-bstrict` |
| Windows gate | `SHUX_WIN_BSTRICT=1` 硬禁 pipeline_gen cc -c |

## 复现（MSYS2）

```bash
make -C compiler bootstrap-driver-seed OPT=1 all
SHUX_WIN_BSTRICT=1 ./tests/run-bootstrap-bstrict-windows-gate.sh
# 日志 cc -c pipeline_gen.c count 须为 0
```

## 仍 track（E-06 v6+）

| 项 | 说明 |
|----|------|
| Windows CI 默认 B-strict | 待 MSYS experimental 链稳定后改 ci.yml |
| strict 第二遍 MSYS | 仍 `SHUX_ASM_CI_ACCEPT_EXPERIMENTAL_ONLY` 早停 |
