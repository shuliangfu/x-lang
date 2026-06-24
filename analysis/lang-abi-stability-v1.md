# LANG-005 ABI 稳定承诺边界 v1

> 更新时间：2026-06-17  
> 状态：**定版（v1）** — 与 `tests/baseline/lang-abi-compat-levels.tsv`、`tests/run-abi-layout.sh` 对齐  
> 关联：`ENG-005`（发布节奏）、`SAFE-004`（FFI）、`compiler/docs/F32_XMM_ABI.md`

---

## 1. 阅读路径（约 15 分钟）

| 步骤 | 动作 |
|------|------|
| 1 | 读本文 §2 承诺层 A1–A6 |
| 2 | 打开 `tests/baseline/lang-abi-compat-levels.tsv`（**release** 兼容级别表） |
| 3 | `./tests/run-lang-abi-stability-gate.sh` |
| 4 | `./tests/run-abi-layout.sh`（C 布局断言） |

---

## 2. 承诺层 A1–A6（ABI stability）

权威：`tests/baseline/lang-abi-stability.tsv`（**6** 条 `layer_*`）。

| 层级 | 表面 | stability | 说明 |
|------|------|-----------|------|
| **A1-scalar-layout** | 标量 `i32`/`u64`/`f64`/`bool` 大小与对齐 | **stable** | 与 C 等价；变更须 **major** |
| **A2-slice-abi** | `T[]` → `{ data*, length }` | **stable** | `layout_abi.c` 16B@x64 |
| **A3-struct-pack** | struct 字段偏移、隐式 padding 拒绝 | **stable** | typeck `implicit padding` |
| **A4-calling-convention** | 用户函数 SysV x86_64 / AAPCS64 | **stable** | 与平台 C 默认一致 |
| **A5-f32-xmm** | x86_64 f32 实参 xmm0–7 | **transitional** | 默认 xmm；`-legacy-f32-abi` 保留至 v1.1 移除 |
| **A6-stdlib-abi** | `std/*_abi.h` 结构体布局 | **stable** | 头文件字段顺序锁定 |

**compatibility 原则**：

1. **stable**：次版本内二进制/布局不变；破坏兼容 → **major** + 迁移说明。
2. **transitional**：双轨并存须带显式开关（环境变量或 CLI），默认轨为 forward。
3. **internal**：编译器内部 wire 布局（parser glue、CodegenOutBuf）**不**对外承诺。

---

## 3. 兼容级别表（release）

机器可读：`tests/baseline/lang-abi-compat-levels.tsv`（**6** 级 `L0`–`L6`）。

| level | surface | stability | bump_policy | 验证 |
|-------|---------|-----------|-------------|------|
| **L0** | primitive scalar | stable | major | 语言规范 §标量 |
| **L1** | slice `T[]` | stable | major | `layout_abi.c` |
| **L2** | struct field layout | stable | major | typeck padding gate |
| **L3** | `extern` C SysV | stable | major | `safe-ffi-contract` |
| **L4** | f32 xmm x86_64 | transitional | minor+flag | `run-abi-f32-xmm-gate.sh` |
| **L5** | std `*_abi.h` | stable | major | `std/fs/fs_abi.h` 等 |
| **L6** | compiler wire ABI | internal | none | 不保证跨版本 |

发布 checklist（**release**）：打 tag 前须 `lang-abi-stability gate OK` + 级别表无未登记 **stable** 破坏项。

---

## 4. Golden 用例

| case_id | 文件 | 期望 |
|---------|------|------|
| `case_layout` | `tests/abi/layout_abi.c` | cc 编译运行 exit **0** |
| `case_slice` | `layout_abi.c` §slice | sizeof=16, offsetof 0/8 |
| `case_f32_xmm` | `tests/abi/f32_call_xmm_smoke.sx` | xmm gate exit **6**（Linux x86_64） |

---

## 5. 非目标（v1）

- Windows x64 ABI 全量承诺表（见 COMP-011）
- WASM / riscv64 调用约定定版
- 跨编译器版本 .o 混链保证

---

## 6. 验证与门禁

```bash
./tests/run-lang-abi-stability-gate.sh   # runnable：manifest + ABI hooks
./tests/run-lang-abi-stability.sh        # layout + f32 xmm（可 SKIP）
./tests/run-abi-layout.sh                # 纯 C 布局断言
```

**gate report**：stdout 须含 `lang-abi-stability gate OK`；失败打印 `lang-abi-stability FAIL:` 行。

| 资源 | 路径 |
|------|------|
| 本文 | `analysis/lang-abi-stability-v1.md` |
| manifest | `tests/baseline/lang-abi-stability.tsv` |
| 级别表 | `tests/baseline/lang-abi-compat-levels.tsv` |
| f32 细则 | `compiler/docs/F32_XMM_ABI.md` |

**LANG-005 状态：定版 ✅**
