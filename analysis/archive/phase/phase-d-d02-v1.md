# 阶段 D-02 完成标准 v1（NEXT §7）

> **D-02 v1**：**Stage 1**（`xlang_asm_stage1`）用同一源码 tree 再编 → **Stage 2**（`xlang_asm2`），行为 parity 由 `verify-selfhost-stage2-bstrict.sh` 验收。

## v1 完成（✅）

| 项 | 标准 | Gate |
|----|------|------|
| 二遍 build | `XLANG=xlang_asm_stage1 ./scripts/build_xlang_asm.sh` round2 | `verify-selfhost-stage2-bstrict.sh` |
| 行为 | 42 + hello + struct_mk inline | `run-stage2-bstrict-gate.sh`（委托） |
| 产物 | `xlang_asm_stage1` / `xlang_asm2` 存在 | 同上 |
| 哈希 | 委托 D-03 | `run-d03-stage2-hash-gate.sh` |

## 复现

```bash
make -C compiler bootstrap-verify-stage2-bstrict
# 或
XLANG_D02_FAIL=1 ./tests/run-d02-stage1-to-stage2-gate.sh
```

## 平台

| 宿主 | 说明 |
|------|------|
| **Linux x86_64** | 硬门禁（GHA / Docker） |
| **macOS** | gate N/A；Docker `run-linux-a09-a11-gate.sh` 覆盖 |

## 延后（D-02 v2）

- Stage2 全量 `run-portable-suite` 两代 diff（D-04 v2 扩面）
