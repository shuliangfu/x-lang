# 阶段 D-01 完成标准 v1（NEXT §7）

> **D-01 v1**：**Stage 0**（C/seed：`bootstrap-driver-seed` / `shux-c` 冷启动）→ **Stage 1**（`shux_asm` B-strict asm 链编译器）。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| Stage 0 | `make bootstrap-driver-seed` 或 `bootstrap.sh` 产出 seed `shux` | manifest 登记 |
| Stage 1 | `make bootstrap-driver-bstrict` → `compiler/shux_asm` | `run-d01-stage0-to-stage1-gate.sh` |
| 拓扑 | `SHUX_ASM_EXPERIMENTAL_SKIP_GEN=1` + B-strict 日志标记 | 同上 + C-03 衔接 |
| 发布 | `shux_asm` → `compiler/shux`（D-05） | 委托 D-05 gate 登记 |

## 复现

```bash
make -C compiler bootstrap-driver-seed
make -C compiler bootstrap-driver-bstrict
SHUX_D01_FAIL=1 ./tests/run-d01-stage0-to-stage1-gate.sh
```

## track-only（不阻塞 v1 ✅）

- Stage1 仍链 **少量 C seed / runtime_panic / ast_seed**（完全无 C 属阶段 E）
- Windows / 非 Linux：B-hybrid 路径见 C-03 track

## 延后（D-01 v2）

- Stage1 **零** C 前端 `.o`（与 E-03 对齐）
- Stage1 与 `shux-c` 输出能力 **字节级** diff（非 v1 范围）
