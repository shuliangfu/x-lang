# CORE-009 core.builtin 位运算内建 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`NEXT.md` CORE-009、`core/builtin/mod.sx`、`core/builtin/builtin.c`

---

## 1. 目标

`clz_u32` / `ctz_u32` / `popcount_u32` 跨模块 import 调用时，生成 C 直达 `shux_builtin_*`（内部 `__builtin_clz/ctz/popcount`），优于 `.sx` 逐位循环。

| API | C 符号（调用点） | 实现 |
|-----|------------------|------|
| `clz_u32` | `shux_builtin_clz_u32` | `__builtin_clz`，x==0→32 |
| `ctz_u32` | `shux_builtin_ctz_u32` | `__builtin_ctz`，x==0→32 |
| `popcount_u32` | `shux_builtin_popcount_u32` | `__builtin_popcount` |
| `bswap_u32` | `shux_builtin_bswap_u32` | 纯 C 交换（CORE-018） |
| `rotl_u32` / `rotr_u32` | `shux_builtin_rotl/rotr_u32` | 循环移位（CORE-018） |

---

## 2. 链接

- `compiler/src/runtime.c`：`generated_c_needs_core_builtin` 扫描生成 C，按需链 `core/builtin/builtin.o`
- `compiler/Makefile`：`../core/builtin/builtin.o` 目标

---

## 3. 金样向量

| x | clz | ctz | popcount |
|---|-----|-----|----------|
| 0 | 32 | 32 | 0 |
| 1 | 31 | 0 | 1 |
| 4 | 29 | 2 | 1 |
| 5 | 29 | 0 | 2 |
| 0x80000000 | 0 | 31 | 1 |

---

## 4. 验收

- manifest：`tests/baseline/core-builtin-bitops.tsv`
- 语义：`tests/builtin/main.sx`、`tests/run-builtin.sh`
- emit：`SHUX_DEBUG_C=1` 生成 C 含 `shux_builtin_*`
- 报告：`shux: [SHUX_CORE_BUILTIN_BITOPS] status=ok emit=3/3`

---

## 5. 演进

- `clz_u64`/`ctz_u64` 镜像族；自举 codegen 路径同步 intrinsic 表。
