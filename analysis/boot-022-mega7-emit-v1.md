# BOOT-022：mega7 B1–B7 emit 晋升 v1

> 更新时间：2026-06-18  
> 状态：**定版（v1）**  
> 前置：BOOT-021 promote wave、`parser-mega-bisect.tsv`  
> 关联：`boot-mega7-gap.md` 阶段 B2、COMP-001

---

## 1. 目标

在 BOOT-021 runnable 波次上推进 **真 emit 晋升**：`SHUX_ASM_PARSER_MEGA_BISECT=<fn>` 探测 `delta ≥ 8192` 计为 `emit`；**至少 1** 项达标。

验收：`tests/run-boot-022-mega7-emit-gate.sh` 绿；`min_promote_emit=1`（Linux + `shux_asm`）。

---

## 2. Emit 晋升矩阵

| ID | 函数 | 角色 | 顺序 |
|----|------|------|------|
| `emit_b1` | `parse_body_lets_into` | **lead** | B1 首探 |
| `emit_b2` | `parse_block_into` | wave | B2 |
| `emit_b3` | `parse_expr_into` | wave | B3 |
| `emit_b4` | `parse_one_function_impl` | wave | B4 |
| `emit_b5` | `parse_into` | wave | B5 |
| `emit_b6` | `parse_into_buf` | wave | B6 |
| `emit_b7` | `parse` | wave | B7 |

`min_delta_pass=8192`（与 `parser-mega-bisect.tsv` 一致）。

---

## 3. Emit 波次

```bash
./tests/run-parser-mega7-emit-wave.sh
```

先探测 **B1 lead**，再全量 7 项；Linux 上更新 `parser-mega-bisect.tsv` 漂移追踪。

---

## 4. Gate

```bash
./tests/run-boot-022-mega7-emit-gate.sh
```

```
shux: [SHUX_BOOT022] status=ok promote_emit=1 emit_lead=parse_body_lets_into skip=1
```

- **promote_emit**：`status=emit` 计数；Linux 须 **≥1**
- **emit_lead**：首个 emit 函数名（期望 B1）
- Darwin / 无 `shux_asm`：manifest 绿 + wave **SKIP**

---

## 5. 联动

- manifest：`tests/baseline/boot-022-mega7-emit.tsv`
- 波次表：`tests/baseline/parser-mega7-emit-wave.tsv`
- 父波次：`run-boot-021-mega7-promote-gate.sh`
- 矩阵：`comp-parser-mega7-matrix.tsv`（B1 状态 `emit_target`）

---

## 6. 非目标（v2）

- 7/7 全量 emit（C3）
- Darwin nm 硬门禁
- 批量 safe_helper 全替换
