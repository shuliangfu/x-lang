# EXC-006 错误恢复测试集 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `EXC-001~005`、`core.result`、`std.error` 对齐  
> 关联：`analysis/exc-result-error-v1-rfc.md`、`analysis/exc-panic-abort-v1-rfc.md`

---

## 1. 阅读路径（约 10 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 恢复场景 R1–R6 |
| 2 | 打开 `tests/baseline/exc-error-recovery-cases.tsv` |
| 3 | `./tests/run-exc-error-recovery-gate.sh` |
| 4 | 可选：`./tests/lib/exc-error-recovery.sh` 单跑某 case |

---

## 2. 恢复场景 R1–R6

权威矩阵：`tests/baseline/exc-error-recovery-cases.tsv`（**≥30** 条 `case_*`）。

| 层级 | 模式 | 恢复手段 | 代表用例 |
|------|------|----------|----------|
| **R1-unwrap-or** | `Result` Err | `unwrap_or_i32` / `expect_i32` 默认值 | `recovery/r_double_default.sx` |
| **R2-or-and** | `or_i32` / `and_i32` | 短路传播或 Err 后默认 | `recovery/r_or_fallback.sx` |
| **R3-branch** | `is_ok` 三元 | 显式分支恢复 | `recovery/r_ternary_recover.sx` |
| **R4-layer-c** | fs/io 语义码 | `fs_last_error` + 默认 | `layer_c_recoverable.sx` |
| **R5-chain** | `ErrorChain` | `error_chain_root` + 分支映射 | `recovery/r_root_from_chain.sx` |
| **R6-suite** | 聚合回归 | `run-result.sh` 等 hook | `run-result.sh` |

**原则**：

1. **可恢复路径禁止 panic**：Err 须经 `unwrap_or`、分支或 hook 套件消化。
2. **与 EXC-002 边界一致**：`expect_i32_or_panic` 仅用于 Ok 路径烟测。
3. **矩阵可扩展**：新增 `.sx` 登记一行 `case_*` 即可纳入 gate。

---

## 3. Gate 与 report

| 组件 | 路径 | 说明 |
|------|------|------|
| manifest | `tests/baseline/exc-error-recovery-cases.tsv` | `min_cases` + `case_*` |
| runner | `tests/lib/exc-error-recovery.sh` | 单 case / 全量 **runnable** |
| gate | `tests/run-exc-error-recovery-gate.sh` | manifest + 烟测；无 native `shux` 时 **SKIP** bench |
| report | gate stdout | `exc-error-recovery gate OK` / 失败 case 列表 |

`policy`：

- `run` — 编译运行 `tests/exc/<script>`
- `run_path` — 编译运行仓库根相对路径
- `hook` — 调用 `tests/<script>`

---

## 4. 与 EXC-001~005 联动

| ID | 本集覆盖点 |
|----|-----------|
| EXC-001 | `ok_i32` / `err_i32` / `unwrap_or` |
| EXC-002 | 可恢复 vs panic 边界 |
| EXC-003 | 分层错误码 + `error_code_layer.sx` |
| EXC-004 | `error_chain_smoke` + `r_root_from_chain` |
| EXC-005 | （CLI 显示不在此集；编译失败不纳入恢复 runnable） |

---

## 5. 验收

- [x] RFC 本文 + manifest **≥30** case
- [x] `tests/exc/recovery/*.sx` 专项用例
- [x] `run-exc-error-recovery-gate.sh` 纳入 `run-portable-suite.sh`
- [x] Darwin 无 native `shux` 时 manifest 仍通过
