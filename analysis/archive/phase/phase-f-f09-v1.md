# 阶段 F-09 v1（手写 C 清零审计门禁）

> **F-09 v1**：建立 **全仓库手写 C 跟踪门禁**；终局目标为 **白名单为空**（std/core/compiler 零 `.c`）。

## 范围

| scope | 路径 | 当前存量（v1 基线） |
|-------|------|---------------------|
| std | `std/**/*.c` | 88 |
| core | `core/**/*.c` | 4 |
| compiler | `compiler/src/**/*.c` | 98 |
| **合计** | | **190** |

**不含**：`tests/**` 夹具 C、`compiler/*_gen*.c` 生成物、构建产物目录。

## 模式

| 模式 | 环境变量 | 行为 |
|------|----------|------|
| **跟踪**（默认） | — | 禁止新增未登记 `.c`；已迁移删除 `.c` 时提示刷新 baseline |
| **刷新 baseline** | `SHUX_NO_HANDWRITTEN_C_UPDATE=1` | 重写 `tests/baseline/no-handwritten-c-whitelist.tsv` |
| **硬失败** | `SHUX_NO_HANDWRITTEN_C_FAIL=1` | 审计失败时 exit 1 |
| **终局零 C** | `SHUX_NO_HANDWRITTEN_C_STRICT=1` | 存量 > 0 即 FAIL（CI 预留；当前必红） |

## 子 gate 委托

- `run-std-c-inventory-gate.sh` — F-01 std/core 存量不增
- `run-f04-std-crypto-closure-gate.sh` — crypto 模块闭合
- `run-f05-std-db-closure-gate.sh` — db 模块闭合
- `run-e-soft-retire-gate.sh`（manifest only）— 编译器 C 软退役跟踪

## 门禁

```bash
./tests/run-no-handwritten-c-gate.sh
SHUX_NO_HANDWRITTEN_C_FAIL=1 ./tests/run-no-handwritten-c-gate.sh
SHUX_NO_HANDWRITTEN_C_UPDATE=1 ./tests/run-no-handwritten-c-gate.sh   # 迁移后刷新
```

## 下一项

- 按 inventory 分批迁移其余 std `.c`（http/json/regex 等）
- **F-04 v20**（可选）：ed25519 ref10 去 C
- **F-10**：无 std C 构建下 `make test_x` 全绿
- 终局：`SHUX_NO_HANDWRITTEN_C_STRICT=1` 硬绿 = 完全自举 F 完成
