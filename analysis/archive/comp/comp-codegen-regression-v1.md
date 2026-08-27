# COMP-003 codegen 稳定性回归 v1

> 更新时间：2026-08-27  
> 状态：**定版（v1）** · honesty soft→硬绿  
> 关联：`PERF-004`（compile dogfood）、`run-asm-73-gate.sh`

---

## 1. 目标

| 目标 | 说明 |
|------|------|
| **关键架构** | x86_64 / arm64 / Windows MSYS 均能编译+运行核心用例 |
| **回归套件** | 固定矩阵 TSV + 门禁，防 codegen/asm 静默破坏 |
| **与 dogfood 分工** | dogfood 测**耗时**；本套件测**正确性**（exit code / hook 绿） |

验收（NEXT COMP-003）：**关键目标架构全部通过** + 文档 + 门禁。

---

## 2. 目标架构（v1）

| 架构 | 宿主示例 | 门禁策略 |
|------|----------|----------|
| **x86_64** | Linux GHA、macOS Intel | 全 matrix + asm-73 hook |
| **arm64** | Linux ARM GHA、macOS Apple Silicon | `any` 行全跑；asm hook SKIP |
| **Windows MSYS2** | ci.yml windows job | `any` 行 + xlang-c 链接 |

矩阵 `arch` 列：`any` = 全平台；`x86_64` = 仅 x86_64 宿主。

---

## 3. 用例矩阵

文件：`tests/baseline/codegen-regression-matrix.tsv`

| case | 覆盖 |
|------|------|
| loop_i32 / mem_copy | 标量 + 内存（live `bench/r01_loop_i32.x` / `m03_mem_copy.x`） |
| struct_param / call_boundary | ABI / 调用（live `r10_struct_param.x` / `a01_call_boundary.x`） |
| float_f64 | 浮点 |
| match_expr / slice_view | 控制流 / slice |
| enum_suite | 枚举（hook） |
| asm_compute | asm 后端（x86_64 + xlang_asm） |

---

## Gate

`tests/run-codegen-regression-gate.sh`（honesty 2026-08-27）：

1. manifest：archive DOC（`## Gate`）+ matrix；拒顶层 DOC／化石 `bench/loop_i32.x` 等复活  
2. prefer product `xlang_asm`；pin `XLANG_LINK_XLANG`；显式坏 XLANG／缺 native **硬 die**（拒 soft SKIP→OK／prefer-c）  
3. `policy=run`：`-o` 编译并运行，校验 `expected_exit`（硬）  
4. `policy=hook`：调用已有 `run-*.sh`；产品残＝obs（非静默 OK）  
5. 报告 `run=`／`hook=`／`obs=`／`skip=`；arch 不匹配＝`skip=`（非 bare exit0）

变更流程：增 matrix 行 + 烟测 `.x`；改 asm 后端确保 asm_compute hook；本地 `XLANG=./compiler/xlang_asm ./tests/run-codegen-regression-gate.sh`。

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/codegen-regression-matrix.tsv` |
| 门禁 | `tests/run-codegen-regression-gate.sh` |
| asm 深测 | `tests/run-asm-73-gate.sh` |
| 编译耗时 | `tests/run-perf-compile-dogfood-gate.sh` |

**COMP-003 状态：定版 ✅ · soft SKIP→OK 池空**
