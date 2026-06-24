# 阶段 E-06 v3（strict 第二遍重链 SX-only，不再考古 SEED C 前端）

> **E-06 v3**：在 E-06 v2 experimental 跳过 seed 前端 `cc -c` 基础上，**strict 第二遍重链**同样不再因缺 `parser.o` 等触发 `ensure_asm_driver_seed_frontend_c_objs`；`ST_SEED_PARSER_TCK` 仅保留 async seed + SX glue，`parser_sx.o` 在 `ST_PARSER_SX_TAIL` 压符号。

## v3 完成（✅）

| 机制 | 说明 |
|------|------|
| `asm_seed_st_async_support_link` | strict 链仅 async_liveness + async_cps_codegen seed |
| `asm_seed_st_preprocess_link` | SX 路径 omit `$SEED_O/preprocess.o`（用 preprocess_sx.o） |
| `ensure_asm_driver_seed_c_objs` | 移除「缺 parser.o → 考古 cc -c」回退 |
| strict `ST_SEED_PARSER_TCK` | 各分支按 `asm_seed_use_sx_frontend` 选 SX-only / legacy |
| strict fallback 重链 | SX 路径用 async + SX tail；legacy 仍全量 SEED |

## 仍 track / 延后（E-06 v4+）

| 路径 | 说明 |
|------|------|
| ~~gen_driver 回退~~ | ✅ E-06 v4：`analysis/phase-e-e06-v4.md` |
| Windows B-strict | 硬禁 `pipeline_gen.c`（C-03 v2） |

## 复现

```bash
SHUX_E06_FAIL=1 ./tests/run-e06-no-compiler-frontend-cc-gate.sh
make -C compiler bootstrap-driver-bstrict 2>&1 | tee /tmp/build_bstrict.log
SHUX_E06_BUILD_LOG=/tmp/build_bstrict.log SHUX_E06_FAIL=1 ./tests/run-e06-no-compiler-frontend-cc-gate.sh
```
