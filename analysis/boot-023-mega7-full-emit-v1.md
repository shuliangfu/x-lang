# BOOT-023：mega7 7/7 全量 emit v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-022 emit 晋升、`parser-mega7-emit-wave.tsv`  
> 关联：`boot-mega7-gap.md` 阶段 C3、COMP-001

---

## 1. 目标

在 BOOT-022 **≥1 emit** 基础上推进 **7/7 全量 emit**：`SHUX_ASM_PARSER_MEGA_BISECT=<fn>` 对 B1–B7 逐项探测，`delta ≥ 8192` 计为 `emit`；**全部 7** 项须达标。

验收：`tests/run-boot-023-mega7-full-emit-gate.sh` 绿；`min_promote_emit=7`（Linux + `shux_asm`）。

---

## 2. 全量 Emit 矩阵

| ID | 函数 | 角色 | 顺序 |
|----|------|------|------|
| `full_emit_b1` | `parse_body_lets_into` | **lead** | B1 首探 |
| `full_emit_b2` | `parse_block_into` | wave | B2 |
| `full_emit_b3` | `parse_expr_into` | wave | B3 |
| `full_emit_b4` | `parse_one_function_impl` | wave | B4 |
| `full_emit_b5` | `parse_into` | wave | B5 |
| `full_emit_b6` | `parse_into_buf` | wave | B6 |
| `full_emit_b7` | `parse` | wave | B7 |

`min_delta_pass=8192`（与 `parser-mega-bisect.tsv` 一致）。

---

## 3. 全量 Emit 波次

复用 BOOT-022 emit runner（同一 7 项 bisect 序列）：

```bash
./tests/run-parser-mega7-emit-wave.sh
```

Linux 上须 **promote_emit=7**；Darwin / 无 `shux_asm` 时 manifest 绿 + wave **SKIP**。

---

## 4. Gate

```bash
./tests/run-boot-023-mega7-full-emit-gate.sh
```

```
shux: [SHUX_BOOT023] status=ok promote_emit=7 emit_full=7 skip=1
```

- **promote_emit**：`status=emit` 计数；Linux 须 **=7**
- **emit_full**：与 `promote_emit` 同义，强调 7/7 闭环
- Darwin / 无 `shux_asm`：manifest 绿 + wave **SKIP**

---

## 5. 联动

- manifest：`tests/baseline/boot-023-mega7-full-emit.tsv`
- 波次表：`tests/baseline/parser-mega7-emit-wave.tsv`（BOOT-022 共用）
- 父波次：`run-boot-022-mega7-emit-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（B1–B7 状态 `emit_target`）

---

## 6. 非目标（v2）

- 139 函数 C2 全量 bootstrap emit
- QEMU / Darwin nm 硬门禁
- 批量 safe_helper 全替换
