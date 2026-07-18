# 阶段 C-07 完成标准 v1（NEXT §6）

> **目标**：`.x` 前端编译器（shux / shux_asm）与 C 前端（shux-c）对**同一输入**行为一致（v1 不测二进制像素级 / AST 字节级）。

## v1 完成（✅）

| 项 | 标准 |
|----|------|
| Harness | `tests/lib/c07-frontend-parity.sh` |
| 矩阵 | `tests/baseline/c07-frontend-parity-matrix.tsv` |
| Gate | `run-c07-frontend-parity-gate.sh` |
| REF | `./compiler/shux-c`（C parser/typeck/codegen） |
| CAND | `./compiler/shux_asm` 或 `./compiler/shux`（C-06 `*_x.o` 前端） |
| 对齐策略 | CAND 编译加 `-backend c`，与 shux-c 同走 C codegen |
| 断言 | compile 成败一致；typeck_ok 时双方 `typeck OK`；可选 `SHUX_C07_TRY_RUN=1` 做 -o 运行 |

## 矩阵策略

- **run 用例**：`tests/c07/minimal_*.x`（无 std import）
- **compile_fail 用例**：`tests/typeck/*` 类型错误
- **默认**：typeck-only（无 `-o`）；完整 `-o` run 需 `SHUX_C07_TRY_RUN=1` + liburing

## 延后（C-07 v2+）

- **AST / -E 输出** SHA256 像素级 diff
- **asm 后端** 产物 object 级 diff（与 S2/S3 parity 合并）
- **全量 run-all** 双轨（已有 L5 白名单，非本 gate 范围）
