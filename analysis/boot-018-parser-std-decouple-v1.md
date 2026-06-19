# BOOT-018 mega7 parser 与 std 迭代解耦 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 关联：`COMP-001`、`BOOT-013`（check 矩阵）、`ENG-002`、`boot-mega7-gap.md`

---

## 1. 目标

**STD P0 合并不依赖 mega7 B1–B7 真 emit 完成**。parser 深循环迁移（COMP-001 阶段 B/C）与 std/core 模块迭代分轨推进；生产链路继续 **C glue + 符号完整性**（BOOT-008 / ENG-002）。

验收：`tests/run-boot-018-parser-std-decouple-gate.sh` 绿。

---

## 2. 双轨模型

| 轨道 | 范围 | 硬门禁（CI / PR） | 不阻塞对方 |
|------|------|-------------------|------------|
| **std 轨** | `core/` + `std/` API、manifest、check 矩阵、Cookbook | `run-stdlib-check-matrix-gate.sh`、STBL/STD-* gate | mega7 stub 状态 |
| **parser 轨** | mega7、切片 emit、bootstrap parse TU | symbol-integrity（ENG-002 Q）、COMP-001（portable，可 SKIP hooks） | std 新模块合并 |

---

## 3. 解耦规则（STD P0 合并）

1. **mega7 矩阵 B1–B7 保持 `stub`**，直至单项 bisect promote；不得作为 std PR 前置条件。  
2. **`run-portable-suite.sh`**：`COMP-001` 接受 `gate OK` 或 `gate SKIP hooks`（Darwin / 无 Linux hook）。  
3. **`eng-quality-gate-matrix.tsv`**：`comp_parser_mega7` 为 **Qp/portable**，非 `ci_hard=yes`。  
4. **std 轨门禁**须先于或与 parser 轨并行，**不得** grep `mega7.*done` 作为 std 绿条件。  
5. 新增 std 模块：仅需 `stdlib-check-matrix.tsv` + 对应 STD manifest；**无需**修改 `parser.sx` mega7。

---

## 4. 关联文档

| 资源 | 路径 |
|------|------|
| mega7 差距 | `analysis/boot-mega7-gap.md` §7 |
| COMP-001 计划 | `analysis/comp-parser-mega7-v1.md` |
| std check 矩阵 | `tests/baseline/stdlib-check-matrix.tsv` |
| mega7 矩阵 | `tests/baseline/comp-parser-mega7-matrix.tsv` |

---

## 5. Gate 与 report

```bash
./tests/run-boot-018-parser-std-decouple-gate.sh
```

manifest：`tests/baseline/boot-018-parser-std-decouple.tsv`

```
shux: [SHUX_BOOT018] status=ok mega7_stub=7 std_independent=1 parser_portable=1
```

---

## 6. 维护

- mega7 某项从 `stub` → `done` 时：仅更新 COMP-001 矩阵，**不**提升为 std 轨硬门禁。  
- 若需将 mega7 迁入 CI hard：须单独 ENG 变更 + 不阻塞 STD P0 的显式豁免条款。
