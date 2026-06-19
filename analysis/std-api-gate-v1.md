# STD-136：std 全模块 manifest/gate 全覆盖 v1

> 状态：**定版（v1）**  
> 关联：`NEXT.md` P2、`CORE-014` core-api 模式

---

## 1. 目标

| ID | 交付 |
|----|------|
| STD-136 | 60 个 `std.*` 模块均注册 baseline manifest + 专项 gate |
| 验收 | `run-std-api-gate.sh` 全绿 |

v1 验收**注册表完整性**（manifest / mod.sx / gate 脚本存在）；符号深度校验沿用各模块专项 gate。

---

## 2. 注册表

`tests/baseline/std-api.tsv` 列：`module_id`、`manifest`、`mod_path`、`kind`、`sub_gate`。

与 `stdlib-check-matrix.tsv` 中 60 个 std 模块一一对应。

---

## 3. 门禁

`./tests/run-std-api-gate.sh`

报告前缀：`shux: [SHUX_STD136_STD_API]`
