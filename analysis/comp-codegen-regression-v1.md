# COMP-003 codegen 稳定性回归 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）**  
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
| **Windows MSYS2** | ci.yml windows job | `any` 行 + shux-c 链接 |

矩阵 `arch` 列：`any` = 全平台；`x86_64` = 仅 x86_64 宿主。

---

## 3. 用例矩阵

文件：`tests/baseline/codegen-regression-matrix.tsv`

| case | 覆盖 |
|------|------|
| loop_i32 / mem_copy | 标量 + 内存 |
| struct_param / call_boundary | ABI / 调用 |
| float_f64 | 浮点 |
| match_expr / slice_view | 控制流 / slice |
| enum_suite | 枚举（hook） |
| asm_compute | asm 后端（x86_64 + shux_asm） |

---

## 4. 门禁

`tests/run-codegen-regression-gate.sh`：

1. manifest：RFC + matrix  
2. `policy=run`：`-o` 编译并运行，校验 `expected_exit`  
3. `policy=hook`：调用已有 run-*.sh  
4. 无 native shux → manifest + SKIP bench（与 portable gate 一致）

---

## 5. 变更流程

1. 新增 codegen 特性 → 增 matrix 行 + 烟测 `.x`  
2. 改 asm 后端 → 确保 asm_compute hook 仍绿（Linux x86_64 CI）  
3. 本地：`SHUX=./compiler/shux-c ./tests/run-codegen-regression-gate.sh`

---

## 6. 索引

| 资源 | 路径 |
|------|------|
| 矩阵 | `tests/baseline/codegen-regression-matrix.tsv` |
| 门禁 | `tests/run-codegen-regression-gate.sh` |
| asm 深测 | `tests/run-asm-73-gate.sh` |
| 编译耗时 | `tests/run-perf-compile-dogfood-gate.sh` |

**COMP-003 状态：定版 ✅**
